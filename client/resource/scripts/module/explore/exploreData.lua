-- 探索各种数据
local port_info = require("game_config/port/port_info")
local relic_info = require("game_config/collect/relic_info")
local explore_whirlpool = require("game_config/explore/explore_whirlpool")
local goods_info = require("game_config/port/goods_info")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local on_off_info = require("game_config/on_off_info")
local explore_event = require("game_config/explore/explore_event")
local Alert = require("ui/tools/alert")
local scheduler = CCDirector:sharedDirector():getScheduler()
local ui_word = require("game_config/ui_word")
local dataTools = require("module/dataHandle/dataTools")

--------------------------------------------------
local ExploreData = class("ExploreData")

local LOOT_BOT_EVENT_ID = 29

ExploreData.ctor = function(self)
	self.sailorCurrent = 0          -- 当前水手
	self.sailorTotal   = 0          -- 水手容量
	self.foodCurrent   = 0          -- 当前食物
	self.foodTotal     = 0          -- 食物容量
	self.silver        = 0          -- 银币
	self.startTime     = 0          -- 开始探索时间
	self.sailorExp     = 0          -- 航海士获得经验

	self.shipInfo = {}              -- 船信息
	self.exploreBreakEvent = nil    -- 探索中断事件
	self.speedRateSchHandler = nil
	self.speedRateSchCd = 0
	self.eventLists = {}
	self.pirate_ships = {}
	self._table_ = nil
	self.goalInfo = nil 
	self.saveAutoPos = nil
	self.afterAutoPos = nil
	self.currentAudioHandle = nil
	self.treasureNavgation = nil

	self.m_wind_info = {}
	self.m_wind_info.dir = WIND_NO_EFFECT
	self.m_wind_info.event_type = nil

	self.m_is_explore = false
	self.m_is_mermainevent_success = false
	self.m_is_storming = false

	self.m_def_wind = nil

	--是否屏蔽逆风
	self.m_is_shield_wind_head = false 
	--是否播放阳光加海鸥特效
	self.m_is_play_sunshine_seagull = false
	--是否每3秒随机生成一些事件(单号#47385)
	self.m_is_random_event = true
	self.enter_call_back_list = {}
	self:initEnterEvent()

	self.find_new_port_list = {} --发现新港口列表

	self.m_transfer_info = {}

	self.ask_convey_move_time = 0
	
	getGameData():getPortData():setEnterPortCallBack(function()
		self.battle_relic_id = nil
	end, true)
end

ExploreData.closeTradeScheduler = function(self)
	if self.trade_scheduler then
		scheduler:unscheduleScriptEntry(self.trade_scheduler)
		self.trade_scheduler = nil
	end
end

ExploreData.openTradeScheduler = function(self)
	local updateCount
	updateCount = function()
		Alert:warning({msg = ui_word.HAVE_TRADE_CAREFUL})
	end

	self:closeTradeScheduler()
	self.trade_scheduler = scheduler:scheduleScriptFunc(updateCount, 10, false)
end

--初始化进入探索时判断的事件
ExploreData.initEnterEvent = function(self)
	local trade_temp = {call = function() 
		--进入探索时判断是否有贸易竞争
		local trade_complete_data = getGameData():getTradeCompleteData()
		local is_have_task = trade_complete_data:isHaveTask()
		if is_have_task and isExplore then
			Alert:warning({msg = ui_word.HAVE_TRADE_CAREFUL})
			self:openTradeScheduler()
		else
			self:closeTradeScheduler()
		end
	end, is_reamin = true}
	table.insert(self.enter_call_back_list, trade_temp)
end

--添加进入探索时的判断事件
ExploreData.addEnterExploreCallBack = function(self, call_back)
	table.insert(self.enter_call_back_list, call_back)
end

--检查执行进入的事件列表并将该移除的移除
ExploreData.checkEnterCallBack = function(self)
	local remain_list = {}
	for k, v in ipairs(self.enter_call_back_list) do
		if type(v.call) == "function" then
			v.call()
		end

		if v.is_reamin then
			table.insert(remain_list, v)
		end
	end
	self.enter_call_back_list = remain_list
end

ExploreData.leaveExploreCloseShceduler = function(self)
	self:closeTradeScheduler()
end

ExploreData.clearData = function(self)
	self.sailorCurrent = 0          --当前水手
	self.sailorTotal   = 0          --水手容量
	self.foodCurrent   = 0          --当前食物
	self.foodTotal     = 0          --食物容量
	self.silver        = 0          --银币
	self.startTime     = 0		   --开始时间
	self.sailorExp     = 0

	self.shipInfo = {}
	self.events = {}
	self.pirate_ships = {}
	self._table_ = nil

	self.currentAudioHandle = nil
	self.treasureNavgation = nil
	self.eventLists = {}

	local portPveData = getGameData():getPortPveData()
	portPveData:clearOpponentData()
	--清除音效
	local voice_info = getLangVoiceInfo()
	audioExt.unloadEffect(voice_info.VOICE_EXPLORE_1019.res)
	audioExt.unloadEffect(voice_info.VOICE_EXPLORE_1000.res)

	self.m_wind_info = {}
	self.m_wind_info.dir = WIND_NO_EFFECT
	self.m_wind_info.event_type = nil
	self.m_is_explore = false
	self.m_is_mermainevent_success = false
	self.m_is_storming = false
	self.enter_call_back = nil
end

ExploreData.clearEventData = function(self)
	self.eventLists = {}
end

ExploreData.setIsExplore = function(self, state_b)
	self.m_is_explore = state_b
end

ExploreData.getIsExplore = function(self)
	return self.m_is_explore
end

ExploreData.setShieldWindHead = function(self, status)
	self.m_is_shield_wind_head = status
end

ExploreData.getShieldWindHead = function(self)
	return self.m_is_shield_wind_head
end

ExploreData.setPlaySunshineSeagull = function(self, status)
	self.m_is_play_sunshine_seagull = status
end

ExploreData.getPlaySunshineSeagull = function(self)
	return self.m_is_play_sunshine_seagull
end

ExploreData.setRandomEvent = function(self, status)
	self.m_is_random_event = status
end

ExploreData.getRandomEvent = function(self)
	return self.m_is_random_event
end

ExploreData.setPirateShips = function(self, pirates, pirate_boss)
	self.pirate_ships.boss_pirate = pirate_boss
	self.pirate_ships.pirate = pirate_boss
end

ExploreData.getPirateShips = function(self)
	return self.pirate_ships
end

ExploreData.setTreasureNavgation = function(self, enable)
	self.treasureNavgation = enable
end

ExploreData.getTreasureNavgation = function(self)
	return self.treasureNavgation
end

ExploreData.getGoalInfo = function(self)
	return self.goalInfo
end

ExploreData.setGoalInfo = function(self, info)
	self.goalInfo = info
end

--保存导航的数据
ExploreData.getAutoPos = function(self)
	return self.saveAutoPos
end

ExploreData.setAutoPos = function(self, info)
	self.saveAutoPos = info
end

ExploreData.getAfterAutoPos = function(self)
	return self.afterAutoPos
end

ExploreData.setAfterAutoPos = function(self, info)
	self.afterAutoPos = info
end

ExploreData.getOriginAreaId = function(self)
	local portData = getGameData():getPortData()
	local originAreaId = port_info[portData:getPortId()].areaId -- 出发港口所在海域id
	return originAreaId
end

--[[
// 场景事件结束
void rpc_server_scene_event_end(object oUser, int evnetId, int flag );]]
ExploreData.exploreEventEnd = function(self, eventId, flag) --事件交互
	eventId = eventId or 0
	flag = flag or 0
	GameUtil.callRpc("rpc_server_scene_event_end", {eventId, flag})
end

ExploreData.setTargetPort = function(self, targetPort)
	self.targetPort = targetPort
end

ExploreData.getTargetPort = function(self)
	local temp = self.targetPort or 0
	return temp
end

ExploreData.setPortType = function(self, portType)
	self.selectPortType = portType
end

ExploreData.getPortType = function(self)
	local temp = self.selectPortType or 0
	return temp
end

ExploreData.initData = function(self)
	if self.startTime > 0 then
		return false
	end
	self.startTime     = os.time()
	self:getShipInfo()
	self.events = {}
	self._table_ = {}

	-- local mapAttrs = getGameData():getWorldMapAttrsData()
	-- mapAttrs:askPortList()

	return true
end

ExploreData.isStartExplore = function(self)
	if self.startTime > 0 then
		return false
	end
	return true
end

ExploreData.resetExplore = function(self)
	local portPveData = getGameData():getPortPveData()
	portPveData:resetExplore()
end

ExploreData.getShipInfo = function(self)  -- 获取玩家船信息
	self.shipInfo = {}

	local sceneDataHandler = getGameData():getSceneDataHandler()
	local tempSpeed = self:getShipNormalSpeed()
	self.shipInfo.baseSpeed = tempSpeed
	self.shipInfo.speed = self.shipInfo.baseSpeed
	self.shipInfo.add_speed = sceneDataHandler:getMyAddSpeed()

	self.shipInfo.id = sceneDataHandler:getMyShipId()

	return self.shipInfo
end

ExploreData.whirlConvey = function(self, whirlID, flag)  --漩涡传送
	self.ask_convey_move_time = (CCTime:getmillistimeofCocos2d() / 1000)
	flag = flag or 0
	GameUtil.callRpc("rpc_server_scene_explore_convey", {whirlID, flag})
end

ExploreData.isCanConveyMove = function(self)
	return (CCTime:getmillistimeofCocos2d() / 1000 - self.ask_convey_move_time) >= 1
end

ExploreData.getShipNormalSpeed = function(self)  -- 获取玩家船正常速度信息
	return EXPLORE_BASE_SPEED
end

ExploreData.setShipSpeedAdd = function(self)
	if self.shipInfo.speed  then

	end
end

ExploreData.addBuff = function(self, time)
	GameUtil.callRpc("rpc_server_user_add_status", {"explore_boat_speed", time})
end

-- 设置打捞宝物完成
ExploreData.setTreasure = function(self)

end

-- 添加银币
ExploreData.addSilver = function(self, value)
	self.silver = self.silver + value
end

-- 添加打捞到的物品
ExploreData.addItems = function(self, item)
	table.insert(items, item)
end

ExploreData.getCurrentAreaPorts = function(self)
	local port_info = require("game_config/port/port_info")
	local portData = getGameData():getPortData()
	local port_id = portData:getPortId() -- 当前港口id
	local layer = getExploreLayer()
	if tolua.isnull(layer) then
		return
	end
	local px, py = layer:getShipPos()
	local minDistance = 0
	local min_port_id = 0
	local openPorts = {}
	for key, value in ipairs(port_info) do

		local exploreUtil = require("module/explore/exploreUtils")
		local port_pos = exploreUtil:cocosToTile2(ccp(value.ship_pos[1], value.ship_pos[2]))
		local dis = Math.distance(px, py, port_pos.x, port_pos.y)
		if key == 1 then
			minDistance = dis
		end
		if  dis <= minDistance then
			minDistance = dis
			min_port_id = key
		end
	end

	local tornado = port_info[min_port_id].tornado
	openPorts = tornado
	if tornado == nil then
		print("--------------------  current port id ---", port_id)
	end
	return openPorts
end

-- 增加航海士经验
ExploreData.addSailorExp = function(self, value)
	local playerData = getGameData():getPlayerData()
	local player_level = playerData:getLevel()

	local add_exp = value
	local relicHandel = getGameData():getRelicData()
	local relicSailorAdd = relicHandel:getExploreSailorExp() --遗迹航海士经验加成
	add_exp = add_exp * relicSailorAdd / 100 + add_exp

	self.sailorExp = self.sailorExp + math.floor(add_exp)
	local sailorUpLevelData = getGameData():getSailorUpLevelData()
	sailorUpLevelData:addSailorExp(add_exp)
end

-- 添加事件 {name, amount}
ExploreData.addExploreEvent = function(self, eventItem)
	if eventItem then
		local isHas = false
		for i = 1, #self.events do
			if self.events[i].name == eventItem.name then
				self.events[i].amount = self.events[i].amount + eventItem.amount
				isHas = true
				break
			end
		end
		if not isHas then
			self.events[#self.events+1] = eventItem
		end
	end
end

--添加事件，也会删掉多余的机器人
ExploreData.addEvent = function(self, eventLists)
	if eventLists == nil then
		return
	end
	local explore_layer = getExploreLayer()
	for key, value in pairs(eventLists) do
		self.eventLists[value.evId] = value
		if not tolua.isnull(explore_layer) then
			local explore_event_item = explore_event[value.evType]
			if explore_event_item then
				local event_type = explore_event_item.event_type
				if event_type == "patrol" or event_type == "patrol_boss" then
					--巡逻海盗 海盗boss
					local is_boss = false
					if event_type == "patrol_boss" then
						is_boss = true
					end
					explore_layer:getPirateLayer():createPirateShip(value.evId, is_boss)
				else
					explore_layer:getExploreEventLayer():createEvent(value)
				end
			end
		end
	end
end

ExploreData.initEvent = function(self) --在创建场景的时候调用
	self:addEvent(self.eventLists)
end

ExploreData.removeUselessEvent = function(self)
	local ids = {11,12}
	if self.eventLists then
		local results = {}
		for k, v in pairs(self.eventLists) do
			local is_keep_b = true
			for i = 1, #ids do
				if ids[i] == v.evType then
					is_keep_b = false
					break
				end
			end
			if is_keep_b then
				results[k] = v
			end
		end
		self.eventLists = results
	end
end

ExploreData.removeEventById = function(self, eventId)
	local tempEvent = self.eventLists[eventId]
	if tempEvent == nil then
		return
	end
	local explore_layer = getExploreLayer()
	local explore_event_item = explore_event[tempEvent.evType]
	if not tolua.isnull(explore_layer) and explore_event_item then
		local event_type = explore_event_item.event_type
		if event_type == "patrol" or event_type == "patrol_boss" then
			explore_layer:getPirateLayer():removeShipByEventId(eventId)
		else
			explore_layer:getExploreEventLayer():deleteEventById(eventId)
		end
	end
	self.eventLists[eventId] = nil
end

ExploreData.getEventById = function(self, eventId)
	return self.eventLists[eventId]
end

ExploreData.setEventById = function(self, eventId)
	if self.eventLists[eventId] then
		self.eventLists[eventId] = nil
	end
end

ExploreData.setWindInfo = function(self, wind_info)
	self.m_wind_info.dir = wind_info

end

ExploreData.getWindInfo = function(self)
	return self.m_wind_info
end

-- 探索中断（水手死光）
ExploreData.exploreBreak = function(self)
	local portData = getGameData():getPortData()
	local dialog_callback
	dialog_callback = function()
	end

	local tip_id = 20
	EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {tip_id = tip_id, call_back = dialog_callback, noDialogSequence = true})
end

---------------------------------------------------------
--探索结束调用接口(包括主动、被动)
ExploreData.exploreOver = function(self)
	if startTime == 0 then  return end -- 已经结算过了
	self:clearData()
end

--开始探索
ExploreData.askStartExplore = function(self)
	--进入场景
	local pos, port_id = getGameData():getExplorePlayerShipsData():getPortPos()
	local area_id = port_info[port_id].areaId
	getGameData():getExplorePlayerShipsData():askEnterArea(area_id, pos.x, pos.y)
	getGameData():getExplorePlayerShipsData():cleanInfo()
end

ExploreData.isGoBackPort = function(self)
	if isExplore then
		local port_info = require("game_config/port/port_info")
		local portData = getGameData():getPortData()
		local portName = port_info[portData:getPortId()].name
		local tips = require("game_config/tips")
		local str = string.format(tips[77].msg, portName)
		Alert:showAttention(str, function()
				portData:askBackEnterPort()
			end, nil, nil, {hide_cancel_btn = true})
		return true
	end
	return false
end

-------------------------------------------------
-- 清除所有货物
ExploreData.clearGoods = function(self)
	GameUtil.callRpc("rpc_server_business_clear_all_goods", {},"rpc_client_business_clear_all_goods")
end

ExploreData.askLootPlayer = function(self, uid)
	GameUtil.callRpc("rpc_server_plunder_player_fight", {uid})
end

ExploreData.askLootWho = function(self, uid)
	GameUtil.callRpc("rpc_server_plunder_team_leader", {uid})
end

ExploreData.askLootPlayerCD = function(self, uid)
	GameUtil.callRpc("rpc_server_get_plunder_cd", {uid})
end

ExploreData.askExploreTransfer = function(self, type_n, id_n, ok_callback)
	if getGameData():getConvoyMissionData():isDoingMission() then return end
	if not getGameData():getBuffStateData():IsCanGoExplore(true) then return end
	if getGameData():getTeamData():isLock(true) then return end

	local name = ""
	local area_id = 0
	if type_n == EXPLORE_TRANSFER_TYPE.PORT then
		name = port_info[id_n].name
		area_id = port_info[id_n].areaId
	elseif type_n == EXPLORE_TRANSFER_TYPE.RELIC then
		name = relic_info[id_n].name
		area_id = relic_info[id_n].areaId
	elseif type_n == EXPLORE_TRANSFER_TYPE.WHIRLPOOL then
		name = explore_whirlpool[id_n].name
		area_id = explore_whirlpool[id_n].sea_index
	else
		local world_mission_data = getGameData():getWorldMissionData()
		local info = world_mission_data:getWorldMissionList()[id_n]
		name = info.cfg.name
		area_id = info.cfg.area
	end

	name = dataTools:getNameWithAreaName(area_id, name)
	
	local item_data = getGameData():getPropDataHandler():get_propItem_by_id(TRANSFER_ITEM.ID) or {count = 0}
	local cost_type = ITEM_INDEX_PROP
	local cost_num = string.format("%s/%s", item_data.count, 1)
	local cost_id = TRANSFER_ITEM.ID
	local red_tips = nil
	if item_data.count < 1 then
		cost_type = ITEM_INDEX_GOLD
		cost_num = TRANSFER_ITEM.NEED_GOLD
		cost_id = 0
		red_tips = ui_word.USE_TRANSFER_ITEM_NONENOUNGH_STR
	end

	Alert:showCostDetailTips(string.format(ui_word.JION_NOT_SAME_PORT_TIPS, name), ui_word.USE_TO_TARGER_PORT_STR, cost_type, 
		cost_id, cost_num, ui_word.USE_TRANSFER_ITEM_STR, function()
			if item_data.count < 1 and getGameData():getPlayerData():getGold() < TRANSFER_ITEM.NEED_GOLD then
				Alert:warning({msg = ui_word.GET_GOLD_LACK_TIPS})
				return
			end
			local go_rpc_func = function() 
					local explore_map = getUIManager():get("ExploreMap")
					local btn_go = nil
					if tolua.isnull(explore_map) then
						explore_map = getUIManager():get("PortMap")
					end

					if not tolua.isnull(explore_map) then
						btn_go = explore_map:getBtnGo()
					end

					if not tolua.isnull(btn_go) then
						btn_go:disable()
					end

					GameUtil.callRpc("rpc_server_transfer_position", {type_n, id_n})
					self:setTransferInfo({type = type_n, id = id_n})
					if type(ok_callback) == "function" then
						ok_callback()
					end
				end
			if type_n ~= EXPLORE_TRANSFER_TYPE.PORT and getGameData():getSceneDataHandler():isInPortScene() then
				getGameData():getSupplyData():startExplore(function() go_rpc_func() end, SUPPLY_GO_SAILING)
			else
				go_rpc_func()
			end
		end, {red_tips = red_tips})
end

ExploreData.handleTansferBtn = function(self, btn, parent_str, btn_res, scale_n)
	scale_n = scale_n or 0.5
	getGameData():getOnOffData():pushOpenBtn(on_off_info.TRANSFER_BUTTON.value, {openBtn = btn, openEnable = true, addLock = true, btn_scale = scale_n, btnRes = btn_res, parent = parent_str})
end

ExploreData.getIsOpenTransfer = function(self)
	if getGameData():getConvoyMissionData():isDoingMission() then return false end
	if not getGameData():getOnOffData():isOpen(on_off_info.TRANSFER_BUTTON.value) then return false end
	return true
end

ExploreData.setTransferInfo = function(self, info)
	self.m_transfer_info = info
end

ExploreData.getTransferInfo = function(self)
	return self.m_transfer_info
end

ExploreData.SetTable = function(self, name, tab)
	if not self._table_ then
		return
	end
	self._table_[name] = tab
end

ExploreData.GetTable = function(self, name)
	if not self._table_ then
		return nil
	end
	return self._table_[name]
end

ExploreData.getTableValue = function(self)
	return self._table_
end

ExploreData.setBattleBackRelicID = function(self, relic_id)
	self.battle_relic_id = relic_id
end

ExploreData.autoRelicPopView = function(self)
	if type(self.battle_relic_id) == "number" and self.battle_relic_id > 0 then
		local relic_data_handler = getGameData():getRelicData()
		relic_data_handler:askCollectRelicArrive(self.battle_relic_id)
		local collect_data = getGameData():getCollectData()
		local relic_info = collect_data:getRelicInfoById(self.battle_relic_id)
		if not cur_info then
			cur_info = collect_data:getConfigInfo(self.battle_relic_id)
		end
		require("gameobj/relic/RelicEnterAndSuplyView"):showDiscoverUi(relic_info)
		local explore_layer = getExploreLayer()
		if not tolua.isnull(explore_layer) then 
			local explore_land = explore_layer:getLand()
			if not tolua.isnull(explore_land) then
				explore_land:setMyShipWaiting(true)
			end
		end

		self.battle_relic_id = nil
	end
end
-- local new_port_data = {["portId"] = portId,["old_prestige"] = old_prestige,["new_prestige"] = new_prestige}
ExploreData.findNewPort = function(self, port_data)
	if getGameData():getOnOffData():isOpen(on_off_info.SHARE_INTERFACE .value) then
		table.insert(self.find_new_port_list,port_data)
		self:showNewPort()
	end
end

ExploreData.showNewPort = function(self)
	-- print("收到服务器下发的发现新港口")
	if not getGameData():getOnOffData():isOpen(on_off_info.SHARE_INTERFACE .value) then return end
	if #self.find_new_port_list > 0 then
		if not getUIManager():isLive("ClsExploreFindPortPanel") then
			local DialogQuene = require("gameobj/quene/clsDialogQuene")
			local clsExploreFindQuene = require("gameobj/explore/clsExploreFindPortQuene")
			DialogQuene:insertTaskToQuene(clsExploreFindQuene.new(self.find_new_port_list[1]))	

			-- getUIManager():create("gameobj/explore/clsExploreFindPortPanel",nil,self.find_new_port_list[1])
			table.remove(self.find_new_port_list, 1)
		end
	end
end

--发现新港口
ExploreData.sendFindNewPort = function(self, port_id)
		GameUtil.callRpc("rpc_server_near_port", {port_id},"rpc_client_near_port")
end

-------------------------------------------------

return ExploreData
