--2016/07/27
--create by wmh0497
--据点战用到的逻辑

local ClsCopySceneLogicBase = require("gameobj/copyScene/copySceneLogicBase")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ClsGuildSmallMap = require("gameobj/copyScene/guildSmallMap")
local ClsVSUIComponent = require("gameobj/copyScene/copySceneComponent/clsVSUIComponent")
local ClsTeamSelectUiComponent = require("gameobj/copyScene/copySceneComponent/clsTeamSelectUiComponent")
local ClsChatUiComponent = require("gameobj/copyScene/copySceneComponent/clsChatUiComponent")
local guild_explore_pos = require("game_config/guildExplore/guild_explore_pos")
local ui_word = require("game_config/ui_word")
local clsAlert = require("ui/tools/alert")
local clsCommonFuns = require("gameobj/commonFuns")

local ClsGuildBattleLogic = class("ClsGuildBattleLogic", ClsCopySceneLogicBase)

local MY_COLOR = ccc3(dexToColor3B(COLOR_BLUE))
local ENEMY_COLOR = ccc3(dexToColor3B(COLOR_RED))

local START_FIGHT_USERS = 5
local GUILD_BATTLE_ACTITY_TIME = 1500 --商会战真正活动时间

local camp_wall_line_1 = {ccp(44, 54), ccp(48, 58)}
local camp_wall_line_2 = {ccp(120, 71), ccp(126, 65)}

ClsGuildBattleLogic.ctor = function(self)
	self.map_land_params = {
		bit_res = "explorer/guild_map.bit",
		map_res = "explorer/map/land/guild_land.tmx", --地图资源
		tile_height = 80, --地图高度，格子数目
		tile_width = 148, -- 地图宽度，格子数目
		block_width_count = 0, --地图宽度遮挡
		block_height_count = 0, --地图高度挡住
		block_up_count = 0,
		block_down_count = 0,
		block_left_count = 0,
		block_right_count = 0,
	}

	--策划每次修改事件表时，都需要告诉相应的程序修改数量值
	self.model_count = {
	}
	self.my_camp = getGameData():getSceneDataHandler():getMyCamp()

	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
	self.m_map_ui = nil
	self.remain_time = 0
	self.is_auto_create_solo = false
end

ClsGuildBattleLogic.init = function(self)
	local scene_ui = ClsSceneManage:getSceneUILayer()
	scene_ui:addComponent("vs_ui", ClsVSUIComponent)
	scene_ui:callComponent("vs_ui", "showCopyStronghold", true)
	scene_ui:addComponent("team_select_ui", ClsTeamSelectUiComponent) 
	scene_ui:setIsShowSoloBtn(true)
	scene_ui:setIsShowStopBtn(true)

	self:createChatComponent()
	
	self.m_scene_ui = scene_ui
	self.m_scene_layer = ClsSceneManage:getSceneLayer()
	local map = getUIManager():create("gameobj/copyScene/guildSmallMap", nil, self.m_scene_layer)
	map:showMin()
	self.m_map_ui = map
	
	self.m_ships_layer = self.m_scene_layer:getShipsLayer()
	self.m_tile_width = ClsSceneManage:getSceneMapLayer():getTileWidth()
	
	ClsSceneManage:setSceneAttr("judian_datas", {})
	self.m_ships_layer:setIsCheckGhost(true)
	self.m_scene_layer:getPlayerShip():setIsCheckCameraFollow(true)
	getGameData():getExplorePlayerShipsData():setIsActiveEnemyRule(true)

	local guild_fight_data = getGameData():getGuildFightData()
	local our_name = guild_fight_data:getOurName()
	local your_name = guild_fight_data:getYourName()
	if our_name then
		self:updateMyName(our_name)
	end
	if your_name then
		self:updateEnemyName(your_name)
	end

	local our_point = guild_fight_data:getOurPoint()
	local your_pint = guild_fight_data:getYourPoint()
	if our_point then
		self:updateMePoint(our_point)
	end
	if your_point then
		self:updateEnemyPoint(your_point)
	end

	local our_users = guild_fight_data:getOurUsers()
	local your_users = guild_fight_data:getYourUsers()
	if our_users then
		self:updateMePeople(our_users)
	end
	if your_users then
		self:updateEnemyPeople(your_users)
	end

	self:updateGuildFightStatus() --修复在战斗时，状态切换，没被及时刷新。
	self:updateTimeUI(self.remain_time)

	local copy_scene_data = getGameData():getCopySceneData()
	local win_camp = copy_scene_data:getCopyWinCamp()
	if win_camp ~= nil then
		self:showResultUI(win_camp)
	end
end

ClsGuildBattleLogic.createChatComponent = function(self)
	getUIManager():close("ClsChatComponent")
	getUIManager():create("gameobj/chat/clsChatComponent")
end

ClsGuildBattleLogic.updateTimeUI = function(self, time)
	self.remain_time = time
	self.m_ships_layer:setIsBuffUp(true) --默认加速
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if tolua.isnull(scene_ui) then
		return
	end

	local updateTime_func = function()
		local guild_fight_data = getGameData():getGuildFightData()
		local status = guild_fight_data:getGroupFightStatus()
		if status == GROUP_FIGHT_FIGHTING_STATUS or status == GROUP_FIGHT_END_STATUS then
			if self.updateTimeHandle then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
				self.updateTimeHandle = nil
			end
			scene_ui:removeTipLayer()
			return
		end

		local our_users = guild_fight_data:getOurUsers()
		if our_users then
			self:tryAutoCreateSoloUI()
			if our_users < START_FIGHT_USERS then
				local copy_scene_data = getGameData():getCopySceneData()
				local str_tips = ui_word.GUILD_FIGHT_NOT_DISSATISFY_TIPS
				copy_scene_data:addTips(str_tips, time)
				return
			end
			if self.updateTimeHandle then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
				self.updateTimeHandle = nil
				scene_ui:removeTipLayer()
			end
			return
		end
	end

	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.updateTimeHandle then
		scheduler:unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end
	self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime_func, 1, false)
	scene_ui:callComponent("vs_ui", "updateGuildBattleTime", time) 
end

ClsGuildBattleLogic.updateMePeople = function(self, peoples)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setOurUsers(peoples)
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if tolua.isnull(scene_ui) then
		return
	end

	if self.my_camp == 1 then
		scene_ui:callComponent("vs_ui", "updateMePeople", peoples, MY_COLOR) 
	else
		scene_ui:callComponent("vs_ui", "updateEnemyPeople", peoples, MY_COLOR) 
	end

end

ClsGuildBattleLogic.updateEnemyPeople = function(self, peoples)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setYourUsers(peoples)
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if tolua.isnull(scene_ui) then
		return
	end
  
	if self.my_camp == 1 then
		scene_ui:callComponent("vs_ui", "updateEnemyPeople", peoples, ENEMY_COLOR) 
	else
		scene_ui:callComponent("vs_ui", "updateMePeople", peoples, ENEMY_COLOR) 
	end
end

ClsGuildBattleLogic.updateMePoint = function(self, points)
	ClsSceneManage:setSceneAttr("blue_point", points)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setOurPoint(points)
	self:updateGuildPoint()
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if tolua.isnull(scene_ui) then
		return
	end

	if self.my_camp == 1 then
		scene_ui:callComponent("vs_ui", "updateMePoint", points, MY_COLOR)
	else
		scene_ui:callComponent("vs_ui", "updateEnemyPoint", points, MY_COLOR) 
	end
end

ClsGuildBattleLogic.updateEnemyPoint = function(self, points)
	ClsSceneManage:setSceneAttr("red_point", points)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setYourPoint(points)
	self:updateGuildPoint()
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if tolua.isnull(scene_ui) then
		return
	end
	if self.my_camp == 1 then
		scene_ui:callComponent("vs_ui", "updateEnemyPoint", points, ENEMY_COLOR) 
	else
		scene_ui:callComponent("vs_ui", "updateMePoint", points, ENEMY_COLOR)
	end
end

ClsGuildBattleLogic.updateMyName = function(self, name)
	ClsSceneManage:setSceneAttr("blue_name", name)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setOurName(name)
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if tolua.isnull(scene_ui) then
		return
	end
	if self.my_camp == 1 then
		scene_ui:callComponent("vs_ui", "updateMyName", name, MY_COLOR) 
	else
		scene_ui:callComponent("vs_ui", "updateEnemyName", name, MY_COLOR) 
	end
end

ClsGuildBattleLogic.updateEnemyName = function(self, name)
	ClsSceneManage:setSceneAttr("red_name", name)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:setYourName(name)
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if tolua.isnull(scene_ui) then
		return
	end
	if self.my_camp == 1 then
		scene_ui:callComponent("vs_ui", "updateEnemyName", name, ENEMY_COLOR)
	else
		scene_ui:callComponent("vs_ui", "updateMyName", name, ENEMY_COLOR)
	end
end

ClsGuildBattleLogic.updateMap = function(self)
	if tolua.isnull(self.m_map_ui) then
		return
	end
	self.m_map_ui:updateIcon()
end

ClsGuildBattleLogic.updateGuildPoint = function(self)
	if tolua.isnull(self.m_map_ui) then
		return
	end
	self.m_map_ui:updateStrongScoreUI()
end

ClsGuildBattleLogic.commonLock = function(self, x, y)
	if self.m_map_ui and self.m_map_ui:getShowMax()then
		return true
	end
	if self.m_scene_ui:callComponent("chat_ui", "isTouchBigChatUI", x, y) then
		return true
	end
end

ClsGuildBattleLogic.isPassTouchEvent = function(self, x, y)
	if self.m_map_ui and self.m_map_ui:isTouchMinRect(x, y) then
		self.m_map_ui:showMax()
		return true
	end
	if self:commonLock(x, y) then
		return true
	end
end

ClsGuildBattleLogic.isLockTouch = function(self)
	if getGameData():getTeamData():isLock() then
		return true
	end
	if self:commonLock(0,0) then
		return true
	end
end

ClsGuildBattleLogic.isTouchSomething = function(self, tpos)
	local stronghold_id = guild_explore_pos[tpos.x + tpos.y * self.m_tile_width]
	if stronghold_id and self.m_map_ui then
		self.m_map_ui:navToStronghold(stronghold_id)
		return true
	end
	return false
end

ClsGuildBattleLogic.touchEnd = function(self)
	if ClsSceneManage:getMyShipAttr("is_firing_judian") then
		ClsSceneManage:setMyShipAttr("is_firing_judian", false)
		self.m_ships_layer:releaseStopShipReason("is_firing_judian")
		self.m_ships_layer:fastUpMyShipPos(true)
	end
end

ClsGuildBattleLogic.putNoticeMsg = function(self, msg_str)
	if tolua.isnull(self.m_scene_ui) then
		return
	end
	self.m_scene_ui:callComponent("guild_scene_ui", "putNoticeMsg", msg_str)
end

ClsGuildBattleLogic.updateGuildFightStatus = function(self)
	if tolua.isnull(self.m_scene_ui) then
		return
	end
	local guild_fight_data = getGameData():getGuildFightData()
	local status = guild_fight_data:getGroupFightStatus()
	if status == GROUP_FIGHT_END_STATUS then
		self.m_scene_ui:callComponent("vs_ui", "changePointText", ui_word.GUILD_FIGHT_END_TIP)
		return 
	end

	if self.remain_time ~= 0 then
		self.m_scene_ui:callComponent("vs_ui", "updateGuildBattleTime",  self.remain_time)
	end
end

ClsGuildBattleLogic.showBattleFail = function(self, camp)
	self.m_scene_ui:callComponent("vs_ui", "changePointText", ui_word.GUILD_FIGHT_END_TIP)
	if camp == self.my_camp then
		clsAlert:showAttention(ui_word.GUILD_FIGHT_FAIL_TIPS, function()
			ClsSceneManage:sendExitSceneMessage()
		end, nil, nil, {hide_close_btn = true, hide_cancel_btn = true})
	else
		self.m_scene_ui:callComponent("vs_ui", "showRankUI", true, function()
			ClsSceneManage:sendExitSceneMessage()
		end)
	end
end

ClsGuildBattleLogic.createPlayerShip = function(self, parent)
	local ClsCopyPlayerShipsLayer = require("gameobj/copyScene/clsCopyPlayerShipsLayer")
	return ClsCopyPlayerShipsLayer.new(parent)
end

ClsGuildBattleLogic.isXuanWoName = function(self)
	return true
end

ClsGuildBattleLogic.isXuanWoJoinTips = function(self)
	return true
end

ClsGuildBattleLogic.showAddScore = function(self, ship_id, score)
	local ship = self.m_ships_layer:getShipWithMyShip(ship_id)
	if ship then
		local label = createBMFont({text = string.format(ui_word.STR_ADD_SCORE, score), size = 16, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
		label:setPosition(ccp(0, 20))
		ship.ui:addChild(label)
		local actions = {}
		actions[#actions + 1] = CCDelayTime:create(0.3)
		local ac_1 = CCFadeOut:create(2)
		local ac_2 = CCMoveBy:create(1, ccp(0, 50))
		actions[#actions + 1] = CCSpawn:createWithTwoActions(ac_1, ac_2)
		actions[#actions + 1] = CCCallFunc:create(function()
			label:removeFromParentAndCleanup(true)
		end)
		label:runAction(transition.sequence(actions))
	end
end

ClsGuildBattleLogic.showRankUI = function(self, is_guide, guide_call_back)
	local scene_data_handle = getGameData():getSceneDataHandler()
	getUIManager():create("gameobj/guild/clsGuildFightRankUI", nil, is_guide, guide_call_back)
end

ClsGuildBattleLogic.showMVP = function()
	getUIManager():create("gameobj/guild/clsGuildFightMVPUi")
end

ClsGuildBattleLogic.createSoloUI = function(self)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:askSoleInfo()
	local camp_name_1 = ClsSceneManage:getSceneAttr("blue_name")
	local camp_name_2 = ClsSceneManage:getSceneAttr("red_name")
	local camp_tmp = camp_name_1 
	if self.my_camp == 2 then 
		camp_name_1 = camp_name_2
		camp_name_2 = camp_tmp
	end

	local player_data = getGameData():getPlayerData()
	--活动的前5分钟报名
	local remain_time = (self.remain_time - player_data:getCurServerTime()) - GUILD_BATTLE_ACTITY_TIME
	getUIManager():create("gameobj/copyScene/clsGuildBattleSoloUI", nil, remain_time, camp_name_1, camp_name_2)
end

ClsGuildBattleLogic.tryAutoCreateSoloUI = function(self)
	if self.is_auto_create_solo then return end

	local guild_fight_data = getGameData():getGuildFightData()
	local camp_name_1 = ClsSceneManage:getSceneAttr("blue_name")
	local camp_name_2 = ClsSceneManage:getSceneAttr("red_name")
	local camp_tmp = camp_name_1 

	if camp_name_1 and camp_name_2 and self.remain_time > 0 then
		guild_fight_data:askSoleInfo()
		if self.my_camp == 2 then 
			camp_name_1 = camp_name_2
			camp_name_2 = camp_tmp
		end

		local player_data = getGameData():getPlayerData()
		--活动的前5分钟报名
		local remain_time = (self.remain_time - player_data:getCurServerTime()) - GUILD_BATTLE_ACTITY_TIME
		--前5分钟自动弹出
		if remain_time >= 0 then 
			getUIManager():create("gameobj/copyScene/clsGuildBattleSoloUI", nil, remain_time, camp_name_1, camp_name_2)
			self.is_auto_create_solo = true
		end
	end
end

ClsGuildBattleLogic.checkPassPos = function(self, screen_x, screen_y)
	local copy_land = ClsSceneManage:getSceneLayer():getLand()
	local target_x, target_y = copy_land:getPosInLand(screen_x, screen_y)
	local check_pos = ccp( target_x, target_y)
	
	local wall = camp_wall_line_1
	if self.my_camp == 2 then
		wall = camp_wall_line_2
	end

	local start_pos = copy_land:tileSizeToCocos(wall[1])
	local end_pos = copy_land:tileSizeToCocos(wall[2])

	local player_ship = self.m_scene_layer:getPlayerShip()
	local player_x, player_y = player_ship:getPos()
	local reslute = clsCommonFuns:IsLineLeft(start_pos.x, start_pos.y, end_pos.x, end_pos.y, player_x, player_y) 

	if reslute > 0 then --已经在空气墙的外面不任何处理
		return true
	end
	
	local reslute = clsCommonFuns:IsLineLeft(start_pos.x, start_pos.y, end_pos.x, end_pos.y, check_pos.x, check_pos.y) 
	if reslute > 0 or reslute == 0 then
		local guild_fight_data = getGameData():getGuildFightData()
		local status = guild_fight_data:getGroupFightStatus()
		if status == GROUP_FIGHT_WAIT_STATUS then
			clsAlert:warning({msg = ui_word.GUILD_STRONGHOLD_WAIT_TIPS})            
		end
		return false
	end

	return true
end

ClsGuildBattleLogic.setShipKillTitle = function(self, ship, kill_title_n)
	if ship then
		ship:hideTitleNode()
		ship:createKillTitle(kill_title_n)
	end
end

ClsGuildBattleLogic.getCampColor = function(self, camp)
	return CAMP_COLOR[camp]
end

ClsGuildBattleLogic.showResultUI = function(self, win_camp)
	local copy_scene_data = getGameData():getCopySceneData()
	copy_scene_data:setCopyWinCamp(nil)
	local is_win = (self.my_camp == win_camp)
	getUIManager():create("gameobj/copyScene/clsCopySceneResultUI", nil, is_win)
end

ClsGuildBattleLogic.getExitTips = function(self)
	return ui_word.GUILD_STRONGHOLD_STATION_LEVEA_LEADER_TIPS
end

ClsGuildBattleLogic.onExit = function(self)
	if self.updateTimeHandle then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end
end


return ClsGuildBattleLogic