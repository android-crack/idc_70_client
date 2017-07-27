--
-- Author: lzg0496
-- Date: 2017-01-13 17:33:46
-- Function: 港口争夺战副本逻辑
--

local copySceneLogicBase = require("gameobj/copyScene/copySceneLogicBase")
local ClsFoodUiComponent = require("gameobj/copyScene/copySceneComponent/clsFoodUiComponent")
local ClsVSUIComponent = require("gameobj/copyScene/copySceneComponent/clsVSUIComponent")
local ui_word = require("game_config/ui_word")
local clsAlert = require("ui/tools/alert")
local cfg_music_info = require("game_config/music_info")
local cfg_error_info = require("game_config/error_info")
local clsCommonFuns = require("gameobj/commonFuns")

local ClsPortBattleLogic = class("ClsPortBattleLoic", copySceneLogicBase)

local left_ship_pos_list = {ccp(-160, 12), ccp(-125, 12), ccp(-90, 12), ccp(-55, 12), ccp(0, 12)}
local right_ship_pos_list = {ccp(160, 12), ccp(125, 12), ccp(90, 12), ccp(55, 12), ccp(0, 12)}

local camp_wall_line_1 = {ccp(143, 36), ccp(143, 48)}
local camp_wall_line_2 = {ccp(22, 5), ccp(22, 22)}
local camp_wall_line_3 = {ccp(22, 50), ccp(22, 72)}


local DEFEND_CAMP = 1
local ATTACK_LEFT_CAMP = 2
local ATTACK_RIGHT_CAMP = 3

local CAMP_COLOR = {
	COLOR_RED,
	COLOR_BLUE,
	COLOR_GREEN,
}

local not_need_look_forward = 76 --巨舰打事件时，不需要瞄准事件


local START_FIGHT_USERS = 5

function ClsPortBattleLogic:ctor()
	self.map_land_params = {
		bit_res = "explorer/copy_scene_port_battle_map.bit",
		map_res = "explorer/map/land/copy_scene_port_battle_land.tmx",
		tile_height = 80,
		tile_width = 160,
		block_width_count = 0,
		block_height_count = 0,
		block_up_count = 0,
		block_down_count = 0,
		block_left_count = 0,
		block_right_count = 0,
	}

	self.model_count = {}
	self.supply_goods = nil
	self.remain_time = nil
	self.m_player_camp = getGameData():getSceneDataHandler():getMyCamp()
	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
	getGameData():getExplorePlayerShipsData():setIsActiveEnemyRule(true)
end

function ClsPortBattleLogic:createPlayerShip(parent)
	local ClsCopyPlayerShipsLayer = require("gameobj/copyScene/clsCopyPlayerShipsLayer")
	return ClsCopyPlayerShipsLayer.new(parent)
end

function ClsPortBattleLogic:init()
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:setSceneAttr("port_battle_datas", {})

	local scene_ui = ClsSceneManage:getSceneUILayer()
	scene_ui:addComponent("vs_ui", ClsVSUIComponent) 
	scene_ui:callComponent("vs_ui", "showCopyStronghold", true)
	scene_ui:callComponent("vs_ui", "changeUIToPortBattle")
	scene_ui:setIsShowHintBtn(true)
	scene_ui:setIsShowStopBtn(true)

	self:createChatComponent()
	
	self.m_scene_ui = scene_ui
	self.m_scene_layer = ClsSceneManage:getSceneLayer()
	local map = getUIManager():create("gameobj/copyScene/clsPortBattleSmallMap", nil, self.m_scene_layer)
	map:showMin()
	self.m_map_ui = map
	
	self.m_ships_layer = self.m_scene_layer:getShipsLayer()
	self.m_tile_width = ClsSceneManage:getSceneMapLayer():getTileWidth()
	self.m_ships_layer:setIsCheckGhost(true)
	self.m_scene_layer:getPlayerShip():setIsCheckCameraFollow(true)
	

	if self.remain_time then
		self:updateTimeUI(self.remain_time)
	end

	local copy_scene_data = getGameData():getCopySceneData()
	local win_camp = copy_scene_data:getCopyWinCamp()
	if win_camp ~= nil then
		self:showResultUI(win_camp)
		self:showResultTips(win_camp, true)
	end
end

function ClsPortBattleLogic:updateTimeUI(time)
	self.remain_time = time
	if self.m_ships_layer then
		self.m_ships_layer:setIsBuffUp(true)
	end
	if tolua.isnull(self.m_scene_ui) then
		return 
	end
	self.m_scene_ui:callComponent("vs_ui", "updatePortBattleTime", self.remain_time)

	self:showSceneTips(self.remain_time)
end

function ClsPortBattleLogic:showSceneTips(time)
	local scheduler = CCDirector:sharedDirector():getScheduler()

	local copy_scene_data = getGameData():getCopySceneData()
	local port_battle_data = getGameData():getPortBattleData()
	local player_data = getGameData():getPlayerData()
	local time = time - (os.time() + player_data:getTimeDelta())
	local updateTime_func = function()
		time = time - 1
		local status = port_battle_data:getPortBattleStatus()
		if status == PORT_BATTLE_END_STATUS then
			if self.updateTimeHandle then
				scheduler:unscheduleScriptEntry(self.updateTimeHandle)
				self.updateTimeHandle = nil
			end
			return
		end

		if status == PORT_BATTLE_FIGHTING_STATUS then
			if self.m_player_camp ~= DEFEND_CAMP then
				local our_users = 0

				local port_battle_data = getGameData():getPortBattleData()
				if self.m_player_camp == ATTACK_LEFT_CAMP then
					our_users = port_battle_data:getAttackerLeftPeople()
				elseif self.m_player_camp == ATTACK_RIGHT_CAMP then
					our_users = port_battle_data:getAttackerRightPeople()
				end
				local status = port_battle_data:getPortBattleStatus()
				print("time ------------", time)
				if our_users ~= 0 and our_users < START_FIGHT_USERS and time == POPT_BATTLE_ACTITY_TIME then
					if self.updateTimeHandle then
						scheduler:unscheduleScriptEntry(self.updateTimeHandle)
						self.updateTimeHandle = nil
					end
					local str_tips = ui_word.STR_PORT_BATTLE_FIGHT_FAIL_TIPS_2
					clsAlert:showAttention(str_tips, nil, nil, nil, {is_add_touch_close_bg = true, hide_close_btn = true, hide_cancel_btn = true})
					return
				end

				local ship_data = getGameData():getExplorePlayerShipsData()
				local str_tips = ui_word.STR_PORT_BATTLE_FIGHT_DEFEND_TIPS
				copy_scene_data:addTips(str_tips, time)
				return
			end

			local str_tips = ui_word.STR_PORT_BATTLE_FIGHT_ATTECK_TIPS
			copy_scene_data:addTips(str_tips, time)
			return
		end

		local our_users = 0
		if self.m_player_camp ~= DEFEND_CAMP then
			if self.m_player_camp == ATTACK_LEFT_CAMP then
				our_users = port_battle_data:getAttackerLeftPeople()
			elseif self.m_player_camp == ATTACK_RIGHT_CAMP then
				our_users = port_battle_data:getAttackerRightPeople()
			end
			
			if our_users < START_FIGHT_USERS then
				local copy_scene_data = getGameData():getCopySceneData()
				local str_tips = ui_word.GUILD_FIGHT_NOT_DISSATISFY_TIPS
				copy_scene_data:addTips(str_tips, time)
				return
			end
		end

		local copy_scene_data = getGameData():getCopySceneData()
		local str_tips = ui_word.STR_PORT_BATTLE_READY_FIGHT_ATTECK_TIPS
		copy_scene_data:addTips(str_tips, time)
	end

	if self.updateTimeHandle then
		scheduler:unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end
	self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime_func, 1, false)
end

function ClsPortBattleLogic:showKillTips(time)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.updateTimeHandle then
		scheduler:unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end

	local updateTime_func = function()
		scheduler:unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil

		local our_users = 0
		local port_battle_data = getGameData():getPortBattleData()
		if self.m_player_camp == ATTACK_LEFT_CAMP then
			our_users = port_battle_data:getAttackerLeftPeople()
		elseif self.m_player_camp == ATTACK_RIGHT_CAMP then
			our_users = port_battle_data:getAttackerRightPeople()
		end
		local status = port_battle_data:getPortBattleStatus()
		if our_users ~= 0 and our_users < START_FIGHT_USERS then
			local str_tips = ui_word.STR_PORT_BATTLE_FIGHT_FAIL_TIPS_2
			clsAlert:showAttention(str_tips, nil, nil, nil, {is_add_touch_close_bg = true, hide_close_btn = true, hide_cancel_btn = true})
			return
		end
		self:showSceneTips(self.remain_time)
	end
	self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime_func, time, false)
end

function ClsPortBattleLogic:showResultTips(camp, is_result)
	if self.updateTimeHandle then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end

	if tolua.isnull(self.m_scene_ui) then
		return 
	end

	local str_tips = ""
	local copy_scene_data = getGameData():getCopySceneData()
	if not is_result then
		str_tips = ui_word.STR_PORT_BATTLE_SCULPTURE_DIE_TIPS
		if camp ~= DEFEND_CAMP then
			str_tips = ui_word.STR_PORT_BATTLE_WARSHIP_DIE_TIPS
		end
		copy_scene_data:addTips(str_tips, self.remain_time or os.time())
	else

		if camp == self.m_player_camp then
			str_tips = ui_word.STR_PORT_BATTLE_WIN_TIPS
		else
			str_tips = ui_word.STR_PORT_BATTLE_SCULPTURE_DIE_TIPS
			if self.m_player_camp ~= DEFEND_CAMP then
				str_tips = ui_word.STR_PORT_BATTLE_WARSHIP_DIE_TIPS
			end
		end
		copy_scene_data:addTips(str_tips, self.remain_time or os.time())
	end
end

function ClsPortBattleLogic:createChatComponent()
	getUIManager():close("ClsChatComponent")
	getUIManager():create("gameobj/chat/clsChatComponent")
end

function ClsPortBattleLogic:isHasSupply()
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	return ClsSceneManage:getMyShipAttr("supply") == 1
end

function ClsPortBattleLogic:updateBattleChart()
	local port_battle_rank_ui = getUIManager():get("ClsPortBattleRankUI")
	if not tolua.isnull(port_battle_rank_ui) then
		port_battle_rank_ui:updateRankUI()
	end
end

function ClsPortBattleLogic:showBattleFail(camp)
	self.m_scene_ui:callComponent("vs_ui", "changePointText", ui_word.GUILD_FIGHT_END_TIP)
	if camp == self.my_camp then
		clsAlert:showAttention(ui_word.STR_PORT_BATTLE_FIGHT_FAIL_TIPS, function()
			ClsSceneManage:sendExitSceneMessage()
		end, nil, nil, {hide_close_btn = true, hide_cancel_btn = true})
	else
		self.m_scene_ui:callComponent("vs_ui", "showRankUI", true, function()
			ClsSceneManage:sendExitSceneMessage()
		end)
	end
end

function ClsPortBattleLogic:playFightMusic()
	audioExt.playEffect(cfg_music_info.UI_HORN.res)
end

function ClsPortBattleLogic:showResultUI(win_camp)
	local copy_scene_data = getGameData():getCopySceneData()
	copy_scene_data:setCopyWinCamp(nil)
	local is_win = (self.m_player_camp == win_camp)
	getUIManager():create("gameobj/copyScene/clsCopySceneResultUI", nil, is_win)
end


function ClsPortBattleLogic:isPassTouchEvent(x, y)
	if self.m_map_ui and self.m_map_ui:isTouchMinRect(x, y) then
		self.m_map_ui:showMax()
		return false
	end
	if self:commonLock(x, y) then
		return true
	end
end

function ClsPortBattleLogic:commonLock(x, y)
	if self.m_map_ui and self.m_map_ui:getShowMax()then
		return true
	end
	
	if self.m_scene_ui:callComponent("chat_ui", "isTouchBigChatUI", x, y) then
		return true
	end
end

function ClsPortBattleLogic:showRankUI(is_guide, guide_call_back)
	getUIManager():create("gameobj/port/clsPortBattleRankUI", nil, 0, is_guide, guide_call_back, true)
end

function ClsPortBattleLogic:showMVP()
	local ask_data_handler = function()
		getGameData():getPortBattleData():askPortBattleMVP(0)
	end
	local get_data_handler = function()
		return getGameData():getPortBattleData():getMVPData()
	end
	getUIManager():create("gameobj/guild/clsGuildFightMVPUi", nil, ask_data_handler, get_data_handler, true)
end

function ClsPortBattleLogic:updatePortBattleStatus()
	if tolua.isnull(self.m_scene_ui) then 
		return 
	end

	if self.remain_time then
		self.m_scene_ui:callComponent("vs_ui", "updatePortBattleTime", self.remain_time)
	end
end

function ClsPortBattleLogic:setDefenderName()
	local port_battle_data = getGameData():getPortBattleData()
	local defender_name = port_battle_data:getDefenderName()
	self.m_scene_ui:callComponent("vs_ui", "setDefenderName", defender_name)
end

function ClsPortBattleLogic:setAttackerLeftName()
	local port_battle_data = getGameData():getPortBattleData()
	local attacker_left_name = port_battle_data:getAttackerLeftName()
	self.m_scene_ui:callComponent("vs_ui", "setAttackerLeftName", attacker_left_name)
end

function ClsPortBattleLogic:setAttackerRightName()
	local port_battle_data = getGameData():getPortBattleData()
	local attacker_right_name = port_battle_data:getAttackerRightName()
	self.m_scene_ui:callComponent("vs_ui", "setAttackerRightName", attacker_right_name)
end

function ClsPortBattleLogic:setAttackerLeftPeople()
	local port_battle_data = getGameData():getPortBattleData()
	local attacker_left_people = port_battle_data:getAttackerLeftPeople()
	self.m_scene_ui:callComponent("vs_ui", "setAttackerLeftPeople", attacker_left_people)
end

function ClsPortBattleLogic:setAttackerRightPeople()
	local port_battle_data = getGameData():getPortBattleData()
	local attacker_right_people = port_battle_data:getAttackerRightPeople()
	self.m_scene_ui:callComponent("vs_ui", "setAttackerRightPeople", attacker_right_people)
end

function ClsPortBattleLogic:setShipVisible(dir_ship, is_visible)
	self.m_scene_ui:callComponent("vs_ui", "setShipVisible", dir_ship, is_visible)
end

function ClsPortBattleLogic:setShipPos(dir_ship, pos_index, rate_n)
	local pos_x = 0
	local pos_list = left_ship_pos_list
	if dir_ship == "right" then
		pos_list = right_ship_pos_list
	end

	if pos_index > #pos_list then
		pos_index = #pos_list
		rate_n = 1
	end
	pos_x = pos_list[pos_index - 1].x + (pos_list[pos_index].x - pos_list[pos_index - 1].x) * rate_n
	if pos_list[pos_index - 1].x > 0 then
		pos_x = pos_x + 35 
	else
		pos_x = pos_x - 35 
	end

	if pos_list[pos_index - 1].x == 160 or pos_list[pos_index - 1].x == -160 then
		pos_x = pos_list[pos_index - 1].x
	end

	self.m_scene_ui:callComponent("vs_ui", "setShipPos", dir_ship, ccp(pos_x, pos_list[pos_index].y))
end

function ClsPortBattleLogic:showAddScore(ship_id, score)
	if not self.m_ships_layer then return end
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

function ClsPortBattleLogic:setIsSupply(is_has_supply)
	if not self.m_ships_layer then return end
	self.m_ships_layer:setIsSupply(is_has_supply, self.remain_time)
end

function ClsPortBattleLogic:updateMap()
	if tolua.isnull(self.m_map_ui) then return end
	self.m_map_ui:updateIcon()
end

function ClsPortBattleLogic:isNotCanSailing()
	local port_battle_data = getGameData():getPortBattleData()
	local status = port_battle_data:getPortBattleStatus()
	return status == PORT_BATTLE_WAIT_STATUS
end

function ClsPortBattleLogic:isCanFight(event_index)
	if type(event_index) ~= "number" then return false end
	if event_index % 3 == 1 then return true end --首塔做特殊处理

	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local event_objs = ClsSceneManage:getAllEventObj()
	for k, v in pairs(event_objs) do
		if event_index == 9 then --市长雕像做特殊处理
			if self.m_player_camp == 2 then
				if v.m_attr.index == 3 then 
					return false
				end
			end

			if self.m_player_camp == 3 then
				if v.m_attr.index == 6 then
					return false
				end
			end
		else
			if v.m_attr.index == (event_index - 1) then
				return false
			end
		end
	end
	return true
end

function ClsPortBattleLogic:setTurretVisible(index, is_visible)
	if tolua.isnull(self.m_scene_ui) then return end
	self.m_scene_ui:callComponent("vs_ui", "setTurretVisible", index, is_visible)
end

function ClsPortBattleLogic:updataEventPos(event_obj)
	if tolua.isnull(self.m_map_ui) then return end
	self.m_map_ui:updataEventPos(event_obj)
end

function ClsPortBattleLogic:updataEventVisible(event_obj)
	if tolua.isnull(self.m_map_ui) then return end
	self.m_map_ui:updataEventVisible(event_obj)
end

function ClsPortBattleLogic:updateEventUI()
	if tolua.isnull(self.m_map_ui) then return end
	self.m_map_ui:updateEventUI(event_obj)
end

function ClsPortBattleLogic:setTurretHP(event_index, percent)
	if not tolua.isnull(self.m_scene_ui) then
		self.m_scene_ui:callComponent("vs_ui", "setTurretHP", event_index, percent)
	end
end

function ClsPortBattleLogic:getExitTips()
	return ui_word.STR_PORT_BATTLE_EXIT_TIPS
end

function ClsPortBattleLogic:isNeedLookForward(event_type)
	return not_need_look_forward ~= event_type
end

function ClsPortBattleLogic:getWarshipName()
	return ui_word.STR_WARSHIP_NAME
end

function ClsPortBattleLogic:getSculptureName()
	return ui_word.STR_SCULPTURE_NAME
end

function ClsPortBattleLogic:getCampColor(camp)
	return CAMP_COLOR[camp]
end

function ClsPortBattleLogic:setCampShipName(ship, camp)
	if ship then
		ship:updatePlayerNameColor(self:getCampColor(camp))
	end
end

function ClsPortBattleLogic:setCampBuff(buff, camp)
	if not tolua.isnull(self.m_scene_ui) then
		self.m_scene_ui:callComponent("vs_ui", "setCampBuff", buff, camp)
	end
end

function ClsPortBattleLogic:isNotCanInteractive()
	local port_battle_data = getGameData():getPortBattleData()
	local status = port_battle_data:getPortBattleStatus()
	local ship_data = getGameData():getExplorePlayerShipsData()
	
	if status == PORT_BATTLE_END_STATUS or ship_data:isGhostStatus(self.m_my_uid) then
		clsAlert:warning({msg = cfg_error_info[643].message})        
		return true
	end
end

function ClsPortBattleLogic:createRuleUI()
	getUIManager():create("gameobj/copyScene/clsPortBattleRuleExplainUI")
end

function ClsPortBattleLogic:setHallHp(percent)
	if not tolua.isnull(self.m_scene_ui) then
		self.m_scene_ui:callComponent("vs_ui", "setHallHp", percent)
	end
end

function ClsPortBattleLogic:setShipHp(dir_ship, percent)
	if not tolua.isnull(self.m_scene_ui) then
		self.m_scene_ui:callComponent("vs_ui", "setShipHp", dir_ship, percent)
	end
end

function ClsPortBattleLogic:checkPassPos(screen_x, screen_y)
	local port_battle_data = getGameData():getPortBattleData()
	local status = port_battle_data:getPortBattleStatus()
	if status == PORT_BATTLE_FIGHTING_STATUS then
		return true
	end

	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local copy_land = ClsSceneManage:getSceneLayer():getLand()
	local target_x, target_y = copy_land:getPosInLand(screen_x, screen_y)
	local check_pos = ccp( target_x, target_y)
	
	local wall = camp_wall_line_1
	if self.m_player_camp == 2 then
		wall = camp_wall_line_2
	elseif self.m_player_camp == 3 then
		wall = camp_wall_line_3
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
		return false
	end

	return true
end

function ClsPortBattleLogic:setShipKillTitle(ship, kill_title_n)
	if ship then
		ship:hideTitleNode()
		ship:createKillTitle(kill_title_n)
	end
end


function ClsPortBattleLogic:onExit()
	if self.updateTimeHandle then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end
end


return ClsPortBattleLogic