----------- Explore sea layer ----------------------
local exploreItem = require("gameobj/explore/exploreItemEntity")
local ClsExplorePlayerShipsLayer = require("gameobj/explore/explorePlayerShipsLayer")
local port_info = require("game_config/port/port_info")
local music_info = require("game_config/music_info")
local tips = require("game_config/tips")
local missionGuide = require("gameobj/mission/missionGuide")
local exploreWalk = require("gameobj/explore/exploreWalk")
local boat_info = require("game_config/boat/boat_info")
local compositeEffect = require("gameobj/composite_effect")
local exploreUtil = require("module/explore/exploreUtils")
local ClsBroadcast = require("gameobj/chat/clsBroadcast")
local gamePlot = require("gameobj/mission/gamePlot")
local area_info = require("game_config/port/area_info")
local on_off_info = require("game_config/on_off_info")
local explore_whirlpool = require("game_config/explore/explore_whirlpool")
local seaforce_boat_config = require("game_config/mission/seaforce_boat_config")

local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsSkillTipsQuene = require("gameobj/quene/clsSkillTipsQuene")

-- z轴层次关系
local ORDE_SEA = 1
local ORDE_LAND = 3
local ORDE_ITEM_LAYER = 4
local ORDE_SHIP = 5
local ORDE_EFFECT_LAYER = 7
local ORDE_EXCESSIVE_LAYER = 8
local ORDE_ANNOUNCE_LAYER = 9
local ORDE_SHAKE_LAYER = 100
local plotVoiceAudio = require("gameobj/plotVoiceAudio")
local voice_info = getLangVoiceInfo()

local random_events = {
	"explore_sea_rock",
	"explore_down_fish", 
	"explore_sea_shark",
	"explore_sea_werck",
	"explore_cloud",
	"explore_whale",
	"explore_seagull",
}

-- 探索层
local ClsBaseLayer = require("gameobj/explore/exploreBaseLayer")

local ExploreLayer = class("ExploreLayer", ClsBaseLayer)

function ExploreLayer:onEnter()
	-- ProFi = require ('module/profiler')
	-- ProFi:start()
	IS_AUTO = false
	local exploreData = getGameData():getExploreData()
	self.is_first = exploreData:initData()
	self.super.onEnter(self)
	self:onEnterTransitionDidFinish()
	self.tip_time_count = 0  -- 30秒未操作提示

	self.firstPlayAudio = true
	self.hander_time = nil
	self.map_rect = CCRect(display.width - 134, display.height - 134, 134, 134) -- 小地图位置

	if IS_AUTO == false then
		getGameData():getExploreData():setAutoPos(nil)
	end

	local sailor_data = getGameData():getSailorData()
	self.mate_id = sailor_data:getCaptain() -- 大副id

	self:regFuns() --注册方法

	self:createExploreLayer()
	self:regTouchEvent(self, function(...) return self:onTouch(...) end, -1)

	self:setMoveCamera(self:getCamera())

	self:tryPlayPirateEndDialog()
end

function ExploreLayer:createMapLand() --todo 重写, 用到不同的地图要重写这个方法
	-- todo
	local exploreLand = require("gameobj/explore/exploreLand")
	self.land = exploreLand.new(self)
	self.land:init()
	self:addChild(self.land, ORDE_LAND)
end

function ExploreLayer:getShipsLayer()
	return self.ships_layer
end

function ExploreLayer:getPirateLayer()
	return self.pirate_layer
end

function ExploreLayer:getExploreEventLayer()
	return self.explore_event_layer
end

function ExploreLayer:getNpcLayer()
	return self.npc_layer
end

function ExploreLayer:getLand()
	return self.land
end

function ExploreLayer:initShipSeaPos()
	--初始化船的位置
	local tpos = getGameData():getSceneDataHandler():getSceneInitPos()
	local pos = exploreUtil:cocosToTile2(tpos)
	self.player_ship:setPos(pos.x, pos.y)
end

-- 播放音乐等
function ExploreLayer:onEnterTransitionDidFinish()
	audioExt.stopMusic()
	audioExt.stopAllEffects()
	local explore_map_data = getGameData():getExploreMapData()
	local area_id = explore_map_data:getCurAreaId()
	
	if area_info[area_id] then 
		local key = area_info[area_id].music
		audioExt.playMusic(music_info[key].res, true)
	else 
		audioExt.playMusic(music_info['EX_BGM'].res, true)
	end 
end

--显示任务海盗的结束对白
function ExploreLayer:tryPlayPirateEndDialog()
	local mission_pirate_data = getGameData():getMissionPirateData()
	local pirate_id = mission_pirate_data:getFightPirateId()
	local cfg_item = seaforce_boat_config[pirate_id]
	if not cfg_item or not cfg_item.end_diaolog then
		return
	end

	local str_stop_reason = "stop_go_for_pirate"

	self.ships_layer:setStopShipReason(str_stop_reason)

	local dialog_tab = table.clone(cfg_item.end_diaolog)
	dialog_tab.call_back = function()
		self.ships_layer:releaseStopShipReason(str_stop_reason)
		mission_pirate_data:setFightPirateId(0)
	end
	getUIManager():create("gameobj/mission/plotDialog", nil, dialog_tab)
end

function ExploreLayer:autoTreasureGo()
	local propDataHandle = getGameData():getPropDataHandler()
	local treasure_data = propDataHandle:getTreasureInfo()
	local pos = propDataHandle:getTreasureCoordBig()
	
	if treasure_data and pos then
		
		self.land:breakAuto() -- 先中断原先的寻路
		IS_AUTO = true
		self.treasureAutoGo = true
		if self.ships_layer:isWaitingTouch() then
			self.ships_layer:setIsWaitingTouch(false)
		end
		self.player_ship:setPause(false)
		self.land:beginFindPath(pos, function()
				self.ships_layer:setIsWaitingTouch(true)
				self.player_ship:setPause(true)
			end)
		getGameData():getExploreData():setAutoPos({is_treasure_go = true})
		local ui = getExploreUI()
		ui:releaseDropAchnor()
		self.land:showDropAnchorTips(nil, true)
	end
end

-- 初始信息,包括UI 、地图等
ExploreLayer.initExploreInfo = function(self)
	local exploreData = getGameData():getExploreData()
	local portData = getGameData():getPortData()
	local portId = portData:getPortId()
	local angle = port_info[portId].ship_dir
	self:shipRotate(angle)
	self.task_port_id = nil
	local missionDataHandler = getGameData():getMissionData()
	local missionTable = missionDataHandler:getDoingMissionInfo()
	local msLength = #missionTable
	local ui = getExploreUI()
	local is_show_no_port_tips_b = true
	if msLength > 0 then
		local missionInfo = nil
		local guideTab = nil
		for i=msLength,1,-1 do
			missionInfo = missionTable[i]
			guideTab = missionTable[i].guide

			if guideTab then
				for i=1,#guideTab do
					if not missionGuide:judgeMissionFinishByPort(missionInfo,guideTab[i]) then
						self.task_port_id = guideTab[i]
						break
					end
				end
			end
		end

		if self.task_port_id and (self.task_port_id > 0)  then
			local port_name = port_info[self.task_port_id].name
			local curTipId= nil
			local lootDataHandle = getGameData():getLootData()
			if lootDataHandle.isComePortLoot then
				curTipId = 156
			else
				curTipId = 80
			end
			EventTrigger(EVENT_EXPLORE_SHOW_DIALOG,{tip_id = curTipId, seaman_id = self.mate_id, duration = 8}, port_name)
			is_show_no_port_tips_b = false
		end
	end
	if is_show_no_port_tips_b then
		--EventTrigger(EVENT_EXPLORE_SHOW_DIALOG,{tip_id = 96, seaman_id = self.mate_id, duration = 8})
	end

	--有些事件在场景没有创建的时候就下发
	exploreData:initEvent()
	exploreData:setIsExplore(true)
	--打印
	if device.platform == "windows" then 
		print("探索刚刚创建完--------------------", self.is_first) 
	end

	local action_node = display.newLayer()
	self:addChild(action_node)

	--进入探索之后的回调
	action_node:performWithDelay(function() 
		exploreData:checkEnterCallBack()
	end, 1)

	if not tolua.isnull(self.ships_layer) then
		self.ships_layer:update(0) --保证其出港后某些东西立即出现
	end
	
	self:tryToOpenTransferFinishView()
end

function ExploreLayer:tryToOpenTransferFinishView()
	local exploreData = getGameData():getExploreData()
	local transfer_info = exploreData:getTransferInfo()
	if transfer_info and transfer_info.id and transfer_info.type then
		local arrive_callback = nil
		local pos = nil
		if transfer_info.type == EXPLORE_TRANSFER_TYPE.WHIRLPOOL then
			arrive_callback = function() EventTrigger(EVENT_EXPLORE_SHOW_WHIRLPOOL_INFO, transfer_info.id) end
			local whirlpool_item = require("game_config/explore/explore_whirlpool")[transfer_info.id]
			pos = ccp(whirlpool_item.sea_pos[1], whirlpool_item.sea_pos[2])
		end
		
		local explore_map = getUIManager():get("ExploreMap")
		if not tolua.isnull(explore_map) then
			if explore_map:isShowMax() then
				explore_map:showMin()
			end
		end
		
		if arrive_callback and pos then
			local net_pos = getGameData():getSceneDataHandler():getSceneInitPos()
			if math.abs(net_pos.x - pos.x) <= 4 and math.abs(net_pos.y - pos.y) <= 4 then
				arrive_callback()
			end
		end
	end
	exploreData:setTransferInfo(nil)
end

function ExploreLayer:createExploreLayer()
	getUIManager():create("gameobj/explore/clsExploreEffectLayer")
	-- 事件层
	self.item_layer = exploreItem.new(self, self.player_ship)
	self:addChild(self.item_layer, ORDE_ITEM_LAYER)

	-- 特效技能层
	self.effect_layer2 = display.newLayer()
	self:addChild(self.effect_layer2, ORDE_EFFECT_LAYER)

	self.effect_shake_layer = CCLayerColor:create(ccc4(0, 0, 0, 128))
	self.effect_shake_layer:setVisible(false)
	local function onTouch(eventType, x, y)
		local touchNodePos = self.effect_shake_layer:convertToNodeSpace(ccp(x,y))
		if eventType == "began" then
			return true
		elseif eventType == "ended" then
			return true
		end
	end

	local explore_scene = getExploreScene()
	self.effect_shake_layer:registerScriptTouchHandler(onTouch, false, TOUCH_PRIORITY_CRAZY, true)
	explore_scene:addChild(self.effect_shake_layer,ORDE_SHAKE_LAYER)

	self.announce_layer = display.newLayer()
	explore_scene:addChild(self.announce_layer, ORDE_ANNOUNCE_LAYER)

	self.ships_layer = ClsExplorePlayerShipsLayer.new(self)
	self:addChild(self.ships_layer, ORDE_SHIP)
	
	getGameData():getConvoyMissionData():updateLockSpeedInfo()
	
	--npc层
	self.npc_layer = require("gameobj/explore/exploreNpc/exploreNpcLayer").new(self)
	self:addChild(self.npc_layer, ORDE_SHIP)

	self.explore_event_layer = require("gameobj/explore/exploreEvent/exploreEventLayer").new(self, ORDE_EFFECT_LAYER)
	self:addChild(self.explore_event_layer, ORDE_EFFECT_LAYER)
	
	--主线海盗层
	local ClsPirateLayer = require("gameobj/explore/explorePirateLayer")
	self.pirate_layer = ClsPirateLayer.new(self)
	self:addChild(self.pirate_layer, ORDE_EFFECT_LAYER)

	-- 过度
	local function tran()
		local layerColor = CCLayerColor:create(ccc4(0,0,0,255))
		layerColor:registerScriptTouchHandler(function(eventType, touches) 
			if eventType =="began" then 
				return true 
			end
		end, false, TOUCH_PRIORITY_HIGHT, true)
		layerColor:setTouchEnabled(true)
		explore_scene:addChild(layerColor, ORDE_EXCESSIVE_LAYER)
		local actions = {}
		local t = 1
		actions[1] = CCFadeOut:create(t)
		actions[2] = CCCallFunc:create( function()
			self:exploreTimer()
			local exploreData = getGameData():getExploreData()
			local lootDataHandle = getGameData():getLootData()
			local goalInfo = exploreData:getGoalInfo()
			local ui = getExploreUI()
			-- local function playFirstAudio()
			--     local playLevel = getGameData():getPlayerData():getLevel()
			--     local limitLevel = 5
			--     if self.is_first and (playLevel > limitLevel) then
			--         local explore_ui = getExploreUI()
			--         explore_ui:playAudio({f = "VOICE_EXPLORE_1022", m = "VOICE_EXPLORE_1002"})
			--     end
			-- end
			if exploreData:getTreasureNavgation() then
				--导航到藏宝图
				self:autoTreasureGo()
				--playFirstAudio()
			else
				if goalInfo then
					if goalInfo.navType == EXPLORE_NAV_TYPE_LOOT then
						
					elseif goalInfo.navType ~= EXPLORE_NAV_TYPE_NONE then
						EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, table.clone(goalInfo))
						ui:playAudio({f = "VOICE_EXPLORE_1023", m = "VOICE_EXPLORE_1003"})
					end
				else
					--playFirstAudio()
				end
			end
			-- exploreData:setGoalInfo(nil) --注释代码，战斗后继续自动导航
			exploreData:setTreasureNavgation(nil)
			if not tolua.isnull(ui) then
				ui.btn_mate_click = nil
			end
			layerColor:removeFromParentAndCleanup(true)
			self:showBeinviteList()
			self:popBattleReward()

			exploreData:autoRelicPopView()

		end)
		local action = transition.sequence(actions)
		layerColor:runAction(action)
	end
	tran()
	gamePlot:resetPlot()
	
	
end

function ExploreLayer:showBeinviteList()

end

function ExploreLayer:popBattleReward()
	local port_data = getGameData():getPortData()
	local reward = port_data:popBattleReward()
	if type(reward) == "table" and #reward > 0 then
		local Alert = require("ui/tools/alert")
		Alert:showCommonReward(reward)
	end
end
function ExploreLayer:removeScene3D()

	self.super.removeScene3D(self) --调用父类的
	
	if self.explore_event_layer then
		self.explore_event_layer:release()
		self.explore_event_layer = nil
	end
	
	if self.item_layer then
		self.item_layer:removeItem3D()
	end
	if self.pirate_layer then
		self.pirate_layer:removeAllPirates()
	end
end

function ExploreLayer:getItemLayer()
	return self.item_layer
end

-- 心跳
function ExploreLayer:exploreTimer()

	local exp_time = 10   --经验
	local exp_time_count  = 0
	local exploreData = getGameData():getExploreData()

	local function exploreTimerCB(dt)
		if self.land then
			self.land:update(dt)
		end
		self.ships_layer:update(dt)
		self.npc_layer:update(dt)
		self.explore_event_layer:update(dt)
		-- 经验
		-- exp_time_count = exp_time_count + dt 
		-- if exp_time_count > exp_time then 
			-- exp_time_count = 0 
			-- exploreData:addSailorExp(10)
		-- end 
		
		self:updateNotControlTipsHander(dt)
	end

	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.hander_time = scheduler:scheduleScriptFunc(exploreTimerCB, 0, false)
end

function ExploreLayer:updateNotControlTipsHander(dt)
	if self.tip_time_count and (not IS_AUTO) then
		self.tip_time_count = self.tip_time_count + dt
		if self.tip_time_count > 30 then
			self.tip_time_count = nil
			local DialogQuene = require("gameobj/quene/clsDialogQuene")
			if not getGameData():getTeamData():isInTeam() and (not DialogQuene:isShowing()) then
				--local ui = getExploreUI()
				-- local begin_callback = function()
				-- 		self.ships_layer:setStopShipReason("explore_un_control_tips_stop")
				-- 		self.ships_layer:setStopFoodReason("explore_un_control_tips_stop")
				-- 	end
				-- local end_callback =  function()
				-- 		self.ships_layer:releaseStopShipReason("explore_un_control_tips_stop")
				-- 		self.ships_layer:releaseStopFoodReason("explore_un_control_tips_stop")
				-- 	end
				-- if self.task_port_id and port_info[self.task_port_id] then 
				-- 	ui:playAudio({f = "VOICE_EXPLORE_1026", m = "VOICE_EXPLORE_1006"})
				-- 	local port_name = port_info[self.task_port_id].name
				-- 	EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {beganCallBack = begin_callback, call_back = end_callback, tip_id = 14, seaman_id = self.mate_id}, port_name)
				-- else
				-- 	ui:playAudio({f = "VOICE_EXPLORE_1041", m = "VOICE_EXPLORE_1040"})
				-- 	EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {beganCallBack = begin_callback, call_back = end_callback, tip_id = 28, seaman_id = self.mate_id})
				-- end
			end
		end
	end
end

function ExploreLayer:onTouch(event, x, y)
	x, y = self:getOriginScreenXY(x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	elseif event == "moved" then
		self:onTouchMoved(x, y)
	elseif event == "ended" then
		self:onTouchEnded(x, y)
	end
end

function ExploreLayer:onTouchBegan(x, y)
	if getGameData():getTeamData():isLock() then
		return
	end

	local exploreData = getGameData():getExploreData()
	local ui = getExploreUI()
	if not tolua.isnull(ui) then
		if not tolua.isnull(ui.world_map) and ui.world_map:getShowMax() then
			return
		end
	end
	
	local node = Explore3D:clickObject(x, y)

	if self.map_rect:containsPoint(ccp(x,y)) then  -- 点击的是小地图位置
		audioExt.playEffect(music_info.EX_DRAGMAP.res, false)
		ui.world_map:showMax()
		return false
	end
	
	if self.is_first then -- 暂停时停止触摸
		missionGuide:clearGuideLayer()
		self.is_first = false
	end

	local check_pos, port_id = self.land:checkPos(x, y)
	if check_pos == MAP_LAND then
		if port_id then
			self.land:selectPortIcon(port_id)
		end
	end
	return true
end

function ExploreLayer:onTouchMoved(x, y)
end

-- wmh todo 删除
-- RegTrigger(EVENT_EXPLORE_PAUSE, evPauseExplore)
-- RegTrigger(EVENT_EXPLORE_RESUME, evResumExplore)

-- RegTrigger(EVENT_EXPLORE_MYSHIP_PAUSE, evMyShipPauseExplore)
-- RegTrigger(EVENT_EXPLORE_MYSHIP_RESUME, evMyShipResumExplore)
function ExploreLayer:endPauseExploreAndShip()
end

--wmh todo
function ExploreLayer:releaseTreasureAuto()--取消自动寻宝
	if self.treasureAutoGo then
		self.treasureAutoGo = nil
		self.land:showDropAnchorTips(true, true)
	end
end

function ExploreLayer:onTouchEnded(x, y)

	if getGameData():getTeamData():isLock() then return end
	
	local ui = getExploreUI()
	if not tolua.isnull(ui) and not tolua.isnull(ui.world_map) and ui.world_map:getShowMax() then
		return
	end
	
	local tempTarget = 0
	local exploreData = getGameData():getExploreData()
	exploreData:setTargetPort(tempTarget)
	self.item_layer:setWhilrMove(1)
	local check_pos, port_id, relic_id, whirlpool_id, mineral_id = self.land:checkPos(x, y)

	EventTrigger(EVENT_EXPLORE_HIDE_GOAL_PORT)
	
	self.ships_layer:setPlayerAttr("touch_something", nil)
	self.ships_layer:releaseStopShipReason("mission_pirate_stop")

	local target_x, target_y = self:getLand():getPosInLand(x, y)
	local node = Explore3D:clickObject(x, y)
	if self.ships_layer:touchShip(node) then
		return
	end
	
	self.npc_layer:setTouchXY(target_x, target_y)
	if self.npc_layer:touchNpc(node) then
		return
	end

	if self.explore_event_layer:touchEvent(node) then
		return
	end

	self:releaseTreasureAuto()
	if check_pos == MAP_LAND then
		if port_id then
			plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
			self.land:unSelectPortIcon(port_id)
			self.ships_layer:setPlayerAttr("touch_something", {type = "touch_land_port", port_id = port_id})
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = port_id, navType = EXPLORE_NAV_TYPE_PORT}, true)
			return
		end
		if relic_id then
			plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
			self.ships_layer:setPlayerAttr("touch_something", {type = "touch_land_relic", relic_id = relic_id})
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = relic_id, navType = EXPLORE_NAV_TYPE_RELIC, click = "land"}, true)
			return
		end
		if mineral_id then
			plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
			getGameData():getAreaCompetitionData():tryToCallMineral(mineral_id)
			return
		end
	else -- 点击不是陆地
		--看他是不是点了漩涡
		if whirlpool_id then
			local explore_whirlpool_item = explore_whirlpool[whirlpool_id]
			local on_off_item = on_off_info[explore_whirlpool_item.switch_key]
			if getGameData():getOnOffData():isOpen(on_off_item.value) then
				plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
				EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = whirlpool_id, navType = EXPLORE_NAV_TYPE_WHIRLPOOL})
				return
			end
		end
		
		if IS_AUTO then  -- 自动导航中断
			if self.firstPlayAudio then
				self.firstPlayAudio = nil
				--ui:playAudio({f = "VOICE_EXPLORE_1021", m = "VOICE_EXPLORE_1001"})
			end
			self.land:breakAuto(true)
		end
		--抛锚
		if not tolua.isnull(ui) then
			ui:releaseDropAchnor()
		end
		if self.ships_layer:setMyShipMoveDir(x, y) then
			exploreUtil:showClickEffect(target_x, target_y, self.ships_layer)
		end
		if self.ships_layer:isWaitingTouch() then
			self.ships_layer:setIsWaitingTouch(false)
		end
	end
end

-- 转动船
function ExploreLayer:shipRotate(angle)
	local angle = math.mod(angle + 360, 360)
	self.player_ship:setAngle(angle)
	local ui = getExploreUI()
	local pos_info = {angle = angle, x = 0, y = 0}
	ui:shipUIRotate(pos_info)
end

function ExploreLayer:regFuns()

	-- 震屏效果
	local function sceneShake(offset, beganCallBack, endCallBack)
		if beganCallBack and type(beganCallBack) == "function" then
			beganCallBack()
		end
		local offset = offset or 0
		local scheduler = CCDirector:sharedDirector():getScheduler()
		if self.shake_hander_time then
			scheduler:unscheduleScriptEntry(self.shake_hander_time)
			self.shake_hander_time = nil
		end
		self.count = 0
		local shake_num = 12
		local function step(dt)
			self.count = self.count + 1
			if self.count > shake_num then
				if self.shake_hander_time then
					scheduler:unscheduleScriptEntry(self.shake_hander_time)
					self.shake_hander_time = nil
				end
				if endCallBack and type(endCallBack) == "function" then
					endCallBack()
				end
				CameraFollow:LockTarget(self.player_ship.node)
				return
			end

			local tran = Vector3.new(self.player_ship.node:getTranslationWorld())
			local off = (-1)^self.count*2 + offset
			tran:set(tran:x()+off, tran:y() + offset, tran:z()+off)
			CameraFollow:SetFreeMove(tran)
		end
		self.shake_hander_time = scheduler:scheduleScriptFunc(step, 0.05, false)
	end

	--弹出技能框
	local function showTriggerSkillDialog(skillId, callBack)
		local appointSkills = getGameData():getSailorData():getRoomSailorsSkill()

		if appointSkills[skillId] then
			if appointSkills[skillId].add_child_skill_id then
				skillId = appointSkills[skillId].add_child_skill_id
				if not appointSkills[skillId] then
					return
				end
			end
			-- local SkillDialogView = require("gameobj/skillDialog")
			-- SkillDialogView:showDialog(appointSkills[skillId].sailorId, skillId, callBack)
			ClsDialogSequene:insertTaskToQuene(ClsSkillTipsQuene.new({sailor_id = appointSkills[skillId].sailorId, skillId = skillId, call_back = callBack}))
		end
	end

	local function playBroadcast()
		if tolua.isnull(self) then return end
		local endCallBack = function()
			if self.broadcast_entity then 
				self.broadcast_entity = nil
			end
		end

		local broadcast_data = getGameData():getBroadcastData()
		local broadcast_list = broadcast_data:getBroadcastList()
		local index = broadcast_data:getCurrentScrolledIndex()

		if #broadcast_list > 0 and broadcast_list[index] then
			if not self.broadcast_entity then
				self.broadcast_entity = ClsBroadcast.new(self.announce_layer, endCallBack)
				self.broadcast_entity:playPlot(broadcast_list[index])
			end
		end
	end

	local function setEffectLayerIsOrNotClick(enable)
		if tolua.isnull(self) or tolua.isnull(self.effect_shake_layer) then return end
		self.effect_shake_layer:setTouchEnabled(enable)
	end
	RegTrigger(EVENT_EXPLORE_EFFECT_LAYER_IS_OR_NOT_CLICK,setEffectLayerIsOrNotClick)
	RegTrigger(EVENT_EXPLORE_SHOW_SKILL_DIALOG, showTriggerSkillDialog)

	RegTrigger(EVENT_EXPLORE_SCENE_SHAKE, sceneShake)
	RegTrigger(EVENT_EXPLORE_ANNOUNCE_PLOT, playBroadcast)
end

function ExploreLayer:getPlayerShip()
	return self.player_ship
end

--退出处理
function ExploreLayer:onExit()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end

	if self.shake_hander_time then
		scheduler:unscheduleScriptEntry(self.shake_hander_time)
		self.shake_hander_time = nil
	end

	if self.create_random_event_time then
		scheduler:unscheduleScriptEntry(self.create_random_event_time)
		self.create_random_event_time = nil
	end
	
	UnRegTrigger(EVENT_EXPLORE_EFFECT_LAYER_IS_OR_NOT_CLICK)
	UnRegTrigger(EVENT_EXPLORE_SHOW_SKILL_DIALOG)
	UnRegTrigger(EVENT_EXPLORE_SCENE_SHAKE)
	UnRegTrigger(EVENT_EXPLORE_ANNOUNCE_PLOT)
	
	--清除探索数据中的一些东西
	local explore_data = getGameData():getExploreData()
	explore_data:removeUselessEvent()
	explore_data:leaveExploreCloseShceduler()

	local ModuleExploreLoading = require("gameobj/explore/exploreLoading")
	ModuleExploreLoading:clearPreload()

	
	-- 删除3d资源
	Explore3D:removeScene3D()
	self.land = nil
	
	-- ProFi:stop()
	-- ProFi:writeReport( 'MyProfilingReport.txt' )
end

function ExploreLayer:upShipPosToServer()
	local pos_x, pos_y = self.player_ship:getPos()
	local t_pos = self.land:tileToCocos(ccp(pos_x, pos_y)) -- 转化坐标
	getGameData():getExplorePlayerShipsData():upPosToServer(t_pos.x, t_pos.y)
end

function ExploreLayer:setEnabledUI(is_enabled)
end

return ExploreLayer  



