--场景管理
-- 协议在 module/rpcs/rpc_copy_scene
local ClsAlert = require("ui/tools/alert")
local tips = require("game_config/tips")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsCopySceneManage = class("ClsCopySceneManage")
local ModuleServerOpt = require("gameobj/copyScene/serverOpt")
require("module/explore/exploreConfig")

local near_tips = {
	[SCENE_OBJECT_TYPE_BOX] = 173,
	[SCENE_OBJECT_TYPE_FLAT] = 182,
	[SCENE_OBJECT_TYPE_SEA_WRECK] = 175,
	[SCENE_OBJECT_TYPE_BITE_BOAT] = 176,
	[SCENE_OBJECT_TYPE_MONSTER] = 177,
	[SCENE_OBJECT_TYPE_ROCK] = 183,
	[SCENE_OBJECT_TYPE_ICE] = 184,
}

local near_crash_tips = {
	[SCENE_OBJECT_TYPE_BITE_BOAT] = 185,
	[SCENE_OBJECT_TYPE_MONSTER] = 186,
	[SCENE_OBJECT_TYPE_ROCK] = 187,
	[SCENE_OBJECT_TYPE_ICE] = 187,
}

--副本类型
local SCENE_TYPE_MAP = {
	GUILD_BATTLE = 1, --公会据点战
	SPORTS = 2, --竞速副本
	TREASURE = 3, --寻宝副本
	MANUAL = 4, --新手引导副本
	MELEE = 5, --大乱斗系统
	PORT_BATTLE = 6, --港口争夺战
	HAI_SHEN = 41, --海神挑战
}

function ClsCopySceneManage:ctor()
end

function ClsCopySceneManage:cleanBeforeSceneLayer()
	if not tolua.isnull(self.scene_ui) then
		self.scene_ui:close()
	end
	if not tolua.isnull(self.scene_layer) then
		self.scene_layer:close()
	end
end

function ClsCopySceneManage:initSceneConfig(x, y)
	self:cleanBeforeSceneLayer()
	local sceneDataHander = getGameData():getSceneDataHandler()
	self.event_objects = {}
	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
	self.event_data = {}
	self.scene_layer = nil
	self.scene_ui = nil
	self.map_layer = nil
	self.map_id = sceneDataHander:getMapId()
	self.sid = sceneDataHander:getSceneId()
	self.copy_result_layer = nil
	self.dialog_time = 0
	self.is_show_end_box = false

	self.model_objects = nil

	self.m_logic = nil
	self.m_init_pos = {["x"] = x, ["y"] = y}
	self.m_scene_attr = {}
	self.m_my_ship_attr = {}
	self.m_is_end = false

	if self.map_id == SCENE_TYPE_MAP.GUILD_BATTLE then
		self.m_logic = require("gameobj/copyScene/clsGuildBattleLogic").new()
	elseif self.map_id == SCENE_TYPE_MAP.TREASURE then
		self.m_logic = require("gameobj/copyScene/treasureLogic").new()
	elseif self.map_id == SCENE_TYPE_MAP.SPORTS then
		self.m_logic = require("gameobj/copyScene/sportsLogic").new()
	elseif self.map_id == SCENE_TYPE_MAP.MANUAL then
		self.m_logic = require("gameobj/copyScene/manualLogic").new()
	elseif self.map_id == SCENE_TYPE_MAP.MELEE then
		self.m_logic = require("gameobj/copyScene/clsMeleeLogic").new()
	elseif self.map_id == SCENE_TYPE_MAP.PORT_BATTLE then
		self.m_logic = require("gameobj/copyScene/clsPortBattleLogic").new()
	elseif self.map_id == SCENE_TYPE_MAP.HAI_SHEN then
		self.m_logic = require("gameobj/copyScene/clsHaiShenLogic").new()
	end
end

function ClsCopySceneManage:doLogic(str_event, ...)
	if self.m_logic then
	   return self.m_logic:doLogic(str_event, ...)
	end
end

function ClsCopySceneManage:isShowEndBox()
	return self.is_show_end_box
end

function ClsCopySceneManage:getSceneLayer() --场景层，负责update
	return getUIManager():get("ClsCopySceneLayer")
end

function ClsCopySceneManage:getSceneUILayer() --场景ui层，负责创建界面ui
	return getUIManager():get("ClsCopySceneUI")
end

function ClsCopySceneManage:getSceneMapLayer() --地图层
	return self.map_layer
end

function ClsCopySceneManage:getMapId()
	return self.map_id
end

function ClsCopySceneManage:getSceneTypeMap()
	return SCENE_TYPE_MAP
end

function ClsCopySceneManage:createSceneLayers()
	local map_params = self:doLogic("getMapLandParams")
	local map_layer = require("gameobj/copyScene/copySceneLand").new(map_params)
	local scene_layer = getUIManager():create("gameobj/copyScene/copySceneLayer", nil, map_layer)
	local scene_ui = getUIManager():create("gameobj/copyScene/copySceneUI")
	self.scene_layer = scene_layer
	self.scene_ui = scene_ui
	self.map_layer = map_layer
end

function ClsCopySceneManage:enterScene()
	--进入场景, 创建
	local function createLayer()
		local running_scene = GameUtil.getRunningScene()
		self:createSceneLayers() -- 创建场景layers
		self.scene_ui:setSceneLayer(self.scene_layer)
		self.scene_layer:initShipSeaPos(self.m_init_pos.x, self.m_init_pos.y) --初始化船的位置
		self.map_layer:initLandField(self.scene_layer) --初始化地图
		self.scene_layer:getPlayerShip():checkBoundOut() --检查策划配置的位置，是否在边界
		self.scene_layer:initUpdate() --海水初始化
		self.map_layer:update( 1 / FRAME_CNT_PER_SEC)
		self.scene_layer:addChild(self.map_layer, 3)

		self:doLogic("init")

		local copy_scene_3dModel_Pool = require("gameobj/copyScene/copyScene3DModelPool")
		local model_count = self:doLogic("getModelCounts")
		self.model_objects = copy_scene_3dModel_Pool.new(model_count)

		setNetPause(false)

		--主动同步一次服务端时间
		GameUtil.callRpc("rpc_server_sync_server_time", {})
	end

	local function mkScene()
		local ModuleExploreLoading = require("gameobj/explore/exploreLoading")
		local plist = {
			["ui/guild_badge.plist"] = 1,
			["ui/skill_icon.plist"] = 1,
			["ui/title_icon.plist"] = 1,
			["ui/title_name.plist"] = 1,
			["ui/explore_sea.plist"] = 1,
			["ui/instance_ui.plist"] = 1,
			["ui/head_frame.plist"] = 1,
			["ui/battle_ui.plist"] = 1,
			["ui/elite_battle.plist"] = 1,
			["ui/chat_ui.plist"] = 1,
			["ui/baowu.plist"] = 1,
			["ui/guild_ui.plist"] = 1,
			["ui/ship_icon.plist"] = 1,
			["ui/activity_ui.plist"] = 1,
			["ui/arena_rank.plist"] = 1, -- 竞技场
			["ui/cityhall_ui.plist"] = 1,
			["ui/map.plist"] = 1, 
		}
		ModuleExploreLoading:loading(createLayer, plist)
	end
	setNetPause(true)
	GameUtil.runScene(mkScene, SCENE_TYPE_GUILD_EXPLORE)

end

function ClsCopySceneManage:addSceneEventData(scene_object)
	if true == self.m_is_end or tolua.isnull(self.scene_layer) then
		return
	end
	if not self.event_data[scene_object.id] then
		self.event_data[scene_object.id] = scene_object
		self:createSceneItemModel(scene_object)
	end
end

function ClsCopySceneManage:getSceneId()
	return self.sid
end

function ClsCopySceneManage:sendExitSceneMessage()
	GameUtil.callRpc("rpc_server_exit_fuben", {self.sid})
end

function ClsCopySceneManage:heartBeat(dt)
	for event_id, event_obj in pairs(self.event_objects) do
		event_obj:update(dt)
	end

	local event_layer = self:getSceneLayer():getEventLayer()
	if not tolua.isnull(event_layer) then
		event_layer:update(dt)
	end

	if true == self:getSceneAttr("show_point_map") then
		self:showNearDialogAndMap(dt)
	end

	self:doLogic("update", dt)
end

function ClsCopySceneManage:tryToPrepareRunning()
	self.scene_ui:setEnabledUI(true)
end

function ClsCopySceneManage:playRewardEff()
	audioExt.playEffect(music_info.SHIPYARD_DISMANTLE_AWARD.res)
end

function ClsCopySceneManage:showNearDialogAndMap(dt)
	--是否触发对话
	self.dialog_time = self.dialog_time + dt
	local eff_id_tab = {}
	local map_pos_tab = {}
	local px, py = self.scene_layer:getPlayerShip():getPos()
	local player_pos = {x = px, y = py}
	--物品
	for event_id, event_obj in pairs(self.event_objects) do
		if not event_obj.is_delete then
			local obj = event_obj.item_model
			local obj_x = nil
			local obj_y = nil
			if obj then
				if type(obj.getPos) == "function" then
					obj_x, obj_y = obj:getPos()
				end

				if type(obj.getPosition) == "function" then
					print("获取位置 =================")
					obj_x = obj:getPosition().x
					obj_y = obj:getPosition().y
				end
				
				if self.dialog_time > 6 and near_tips[event_obj:getEventType()] then
					local len_2 = (px - obj_x)*(px - obj_x) + (py - obj_y)*(py - obj_y)
					if len_2 < 90000 then
						eff_id_tab[#eff_id_tab + 1] = {["len_2"] = len_2,["event_obj"] = event_obj}
					end
				end
			end
			if obj_x then
				local pos_info = {id = event_id, x = obj_x, y = obj_y}
				if not self:doLogic("hideEvent", event_obj:getEventType(), pos_info) then
					map_pos_tab[#map_pos_tab + 1] = pos_info
				end
			end
		end
	end

	--玩家
	local ships = self.scene_layer:getShipsLayer():getAllShips()
	for uid, ship in pairs(ships) do
		local ship_x, ship_y = ship:getPos()
		local is_player = not self:doLogic("isPlayer", uid)
		map_pos_tab[#map_pos_tab + 1] = {id = uid, x = ship_x, y = ship_y, is_player = is_player}
	end

	self:getSceneUILayer():updateSmallMapUi(player_pos, map_pos_tab)

	if #eff_id_tab > 0 then
		local min_id = 1
		for i = 1, #eff_id_tab do
			if eff_id_tab[i].event_obj:getEventType() == SCENE_OBJECT_TYPE_SEA_WRECK then
				min_id = i
				break
			end
			if eff_id_tab[i].len_2 < eff_id_tab[min_id].len_2 then
				min_id = i
			end
		end
		local event_obj = eff_id_tab[min_id].event_obj
		local event_type = event_obj:getEventType()
		self:showDialogBoxWithSailorId(near_tips[event_type])
	end
end

function ClsCopySceneManage:showDialogBoxWithCrash(event_type)
	self:showDialogBox({tip_id = near_crash_tips[event_type]})
end

function ClsCopySceneManage:showDialogBoxWithSailorId(tips_id)
	self:showDialogBox({tip_id = tips_id})
end

function ClsCopySceneManage:showDialogBox(params)
	if self.is_show_end_box then
		return
	end
	self.dialog_time = 0
	if not tolua.isnull(self.scene_layer) then
		EventTrigger(EVENT_EXPLORE_SHOW_DIALOG, params)
	end
end

function ClsCopySceneManage:showCompleteTips(sid)
	if not self:isCurrentScene(sid) then
		return
	end
	if not tolua.isnull(self.scene_ui) then
		self.scene_ui:showStartOrEndIconTips(false)
	end
end

function ClsCopySceneManage:touchObject(node) --由copySceneLayer层的触摸事件，调用
	for _, obj in pairs(self.event_objects) do
		local result = obj:touch(node)
		if result then
			return true
		end
	end
	return self.scene_layer:getShipsLayer():touchShip(node)
end

function ClsCopySceneManage:removeAllSceneModel()
	for _, scene_object in pairs(self.event_data) do
		if self.event_objects[scene_object.id] then
			self:removeItem(scene_object.id)
		end
	end
	self.event_data = {}
end

function ClsCopySceneManage:sceneEnd()
	self.m_logic = nil
	self.m_is_end = true
end

function ClsCopySceneManage:isCurrentScene(sid)
	if self.sid == nil and (not self:getSceneLayer()) then
		return false
	end
	if self.sid ~= sid then
		print("xxxxxxxxxxxx场景错误---前端保存的---id----", self.sid)
		print("xxxxxxxxxxxx场景错误xxxxx----后端发送的---id---xxxxx", sid)
		print("LUA ERROR: "..tostring(errorMessage).."\n")
		local trackback = debug.traceback("", 2)
		print(trackback)
		print("----------------------------------------")
		return false
	end
	return true
end

function ClsCopySceneManage:removeItem(event_id)
	if not self.event_data then return end
	self.event_data[event_id] = nil
	local model = self.event_objects[event_id]
	if model then
		model:release() --模型释放
		self.event_objects[event_id] = nil
	else
		print("删除找不到--------------------------", event_id)
	end
end

function ClsCopySceneManage:getEventByEventId(event_id)
	return self.event_objects[event_id]
end

function ClsCopySceneManage:deleteSceneEventData(obj_id)
	self:removeItem(obj_id)
end

function ClsCopySceneManage:isInSeaGodEvent(id)
	for _, event_id in ipairs(SCENE_OBJECT_SEAGOD_BOSS) do
		if event_id == id then
			return true
		end
	end
end

function ClsCopySceneManage:isInHaiShenEvent(id)
	for _, event_id in ipairs(SCENE_OBJECT_TYPE_HAISHEN) do
		if event_id == id then
			return true
		end
	end
end

function ClsCopySceneManage:createSceneItemModel(scene_object)
	if self.event_objects[scene_object.id] then
		return
	end
	scene_object.sea_pos = self.map_layer:tileSizeToCocos(ccp(scene_object.x, scene_object.y))
	local obj = nil
	local sid = self.sid
	if scene_object.type == SCENE_OBJECT_TYPE_BOX or
		scene_object.type == SCENE_OBJECT_TYPE_FLAT or
		scene_object.type == SCENE_OBJECT_TYPE_SEA_WRECK or
		scene_object.type == SCENE_OBJECT_TYPE_MELEE_WRECK then --宝箱
		local r_str = "gameobj/copyScene/boxEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)

		if scene_object.type == SCENE_OBJECT_TYPE_MELEE_WRECK then
			self:doLogic("setAttackStatus", false)
		end
	elseif scene_object.type == SCENE_OBJECT_TYPE_ROCK or scene_object.type == SCENE_OBJECT_TYPE_ICE then --浮冰和礁石
		local r_str = "gameobj/copyScene/fireEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_BITE_BOAT or scene_object.type == SCENE_OBJECT_TYPE_MONSTER then --鲨鱼和海怪
		local r_str = "gameobj/copyScene/fishEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_XUANWO or scene_object.type == SCENE_OBJECT_TYPE_WHIRLPOOL then
		local r_str = "gameobj/copyScene/xuanwoEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_MERMAID then -- 美人鱼
		local r_str = "gameobj/copyScene/mermaidEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_FOG then --迷雾
		local r_str = "gameobj/copyScene/fogEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_JUDIAN then --迷雾
		local r_str = "gameobj/copyScene/clsJudianEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif self:isInHaiShenEvent(scene_object.type) then
		local r_str = "gameobj/copyScene/clsHaiShenEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif self:isInSeaGodEvent(scene_object.type) then
		local r_str = "gameobj/copyScene/clsSeaGodBossEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_SCULPTURE then
		local r_str = "gameobj/copyScene/clsSculptureEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_BATTERY then
		local r_str = "gameobj/copyScene/clsBatteryEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_WARSHIP then
		local r_str = "gameobj/copyScene/clsWarshipEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_SUPPLY then
		local r_str = "gameobj/copyScene/clsSupplyEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_MELEE_GOD then
		local r_str = "gameobj/copyScene/clsMeleeGodEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	elseif scene_object.type == SCENE_OBJECT_TYPE_MELEE_BOSS then
		local r_str = "gameobj/copyScene/clsMeleeBossEvent"
		local ClsObject = require(r_str)
		obj = ClsObject.new(sid, scene_object)
	end
	self.event_objects[scene_object.id] = obj
end

--[[[S->C][rpc_client_object_action{ ['1']=10642,['2']=1,['3']={ ['1']={ ['key']=target,['value']=187904
8198,} ,['2']={ ['key']=sub_hp,['value']=1,} ,['3']={ ['key']=hp,['value']=998,} ,} ,} ] --]]

function ClsCopySceneManage:updateSceneAction(source_id, action_id, params)
	if tolua.isnull(self.scene_layer) then return end

	if SCENE_ACTION_FIGHT == action_id then --发炮
		-- key:"target", "sub_hp", "hp"
		local ship = self.scene_layer:getShipsLayer():getShipWithMyShip(source_id)
		if ship then --玩家与事件交互
			local my_uid = getGameData():getSceneDataHandler():getMyUid()
			local is_sound = (my_uid == source_id)
			local obj = self.event_objects[params.target]
			if obj then
				obj:fireFromShip(params, ship, is_sound)
			end
			return 
		end

		--事件跟事件交互
		local obj = self.event_objects[source_id]
		if obj then
			obj:fireForObject(params)
		end
	end
end

function ClsCopySceneManage:updataInteractiveResult(obj_id, interactive_type, result)
	local obj = self.event_objects[obj_id]
	if obj then
		obj:updataInteractiveResult(interactive_type, result)
	end
end

function ClsCopySceneManage:updataEventAttr(obj_id, key, value)
	if tolua.isnull(self.scene_layer) then return end
	local obj = self.event_objects[obj_id]
	if obj then
		self:doLogic("updataEventObjectAttr", obj, key, value)
		return
	end
	local pos_info = getGameData():getExplorePlayerShipsData():getPosInfo(obj_id)
	if pos_info then--这个有，可以认为是玩家
		pos_info.attr[key] = value
		if obj_id == self.m_my_uid then --自己的处理
			self:updateMyShipAttr(key, value)
		end
		if key == "canrao" then
			local obj = self.event_objects[value]
			self:doLogic("updataEventObjectAttr", obj, key, obj_id)
			return
		end
		if key == "add_score" then
			self:doLogic("showAddScore", obj_id, value)
		end
		if key == "buff_cd" then
			self:doLogic("updateEventBuffCD", value)
		end
		if key == "buff" then
			self:doLogic("updateAttrText", value)
		end
		self.scene_layer:getShipsLayer():updateAttr(obj_id)
	end
end

function ClsCopySceneManage:updateMyShipAttr(key, value)
	local before_value = self:getMyShipAttr(key)
	self.m_my_ship_attr[key] = value
	before_value = before_value or 0 -- 断线重连.
	if key == "food_max" then
		local food_n = self:getMyShipAttr("food") or value
		self.scene_ui:callComponent("copy_food_ui", "updateFoodUI", food_n, value)
	elseif key == "food" then
		if value == 0 then
			if (true == self.m_is_end) or (not tolua.isnull(self.copy_result_layer)) then return end

			EventTrigger(EVENT_EXPLORE_PLOT_DIALOG,
				{is_player = true,
				txt = tips[180].msg,
				call_back = end_callback,
				delay_time = 10000,
				is_lock_touch = true,
				touch_priority = TOUCH_PRIORITY_HIGHT
				})
		end

		local max_food = self:getMyShipAttr("food_max") or value
		if not max_food then
			self:setMyShipAttr("food_max", value)
			max_food = value
		end
		self.scene_ui:callComponent("copy_food_ui", "updateFoodUI", value, max_food)
		if before_value and (before_value > 0) and (value > before_value) then
			--特殊处理，物品弹框
			--用的老队列，被我删了，出问题
		end
	elseif key == "supply" then --是否身上带补给
		self:setMyShipAttr(key, value)
		self:doLogic("setIsSupply", value == 1)
	end
end

function ClsCopySceneManage:updateSceneAttr(key, value)
	if not self.m_scene_attr then
		print("--------------mid-----------------------log----------- not m_scene_attr -------")
		return
	end
	self.m_scene_attr[key] = value
	--执行场景操作
	if ModuleServerOpt[key] then
		ModuleServerOpt[key](value)
	end
	self:doLogic("updateSceneAttr", key, value)
end

function ClsCopySceneManage:setSceneAttr(key, value)
	self.m_scene_attr[key] = value
end
function ClsCopySceneManage:getSceneAttr(key)
	return self.m_scene_attr[key]
end

function ClsCopySceneManage:setMyShipAttr(key, value)
	self.m_my_ship_attr[key] = value
end

function ClsCopySceneManage:getMyShipAttr(key)
	return self.m_my_ship_attr[key]
end

function ClsCopySceneManage:showErrorTips(sid)
	local exit_callback = function()
	end
	ClsAlert:showAttention(ui_word.EXPLORE_INTERNET_TIPS, exit_callback, exit_callback, nil, {hide_cancel_btn = true})
end

function ClsCopySceneManage:setResultLayer(result_layer)
	self.copy_result_layer = result_layer
end

function ClsCopySceneManage:getResultLayer()
	return self.copy_result_layer
end

function ClsCopySceneManage:getEvenObjById(event_id)
	if not self.event_objects then return end
	return self.event_objects[event_id]
end

function ClsCopySceneManage:getAllEventObj()
	return self.event_objects
end

function ClsCopySceneManage:setSceneEnd()
	self.m_is_end = true
end

return ClsCopySceneManage
