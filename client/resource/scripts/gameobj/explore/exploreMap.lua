-- 探索小地图
require("gameobj/mission/missionInfo")
local ClsSmallMap = require("gameobj/explore/smallMap")
local ClsEMapPointInfoPanel = require("gameobj/explore/eMapPointInfoPanel")
local exploreMapUtil = require("module/explore/exploreMapUtil")
local area_info = require("game_config/port/area_info")
local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
local relic_info = require("game_config/collect/relic_info")
local music_info = require("game_config/music_info")
local on_off_info=require("game_config/on_off_info")
local UiCommon = require("ui/tools/UiCommon")
local ui_word = require("game_config/ui_word")
local plotVoiceAudio = require("gameobj/plotVoiceAudio")
local ClsAlert = require("ui/tools/alert")
local port_info = require("game_config/port/port_info")
local explore_whirlpool = require("game_config/explore/explore_whirlpool")
local explore_objects_config = require("game_config/explore/explore_objects_config")
local dataTools = require("module/dataHandle/dataTools")
local world_mission_info = require("game_config/world_mission/world_mission_info")
local team_world_mission_conf = require("game_config/world_mission/world_mission_team")
local scheduler = CCDirector:sharedDirector():getScheduler()
local port_power = require("game_config/mission/port_power")
local composite_effect = require("gameobj/composite_effect")
--暂时方案，合成表，保证获取到对应的数据
local world_mission_total_cfg = {}
for k, v in pairs(world_mission_info) do
	world_mission_total_cfg[k] = v
end
for k, v in pairs(team_world_mission_conf) do
	world_mission_total_cfg[k] = v
end

local ExploreMap = class("ExploreMap", ClsSmallMap)

ExploreMap.getViewConfig = function(self)
	return { hide_before_view = true, }
end

ExploreMap.POINT_RES = {
	["forbidden_port"] = {"#map_forbidden.png", "#map_forbidden.png"},
	["enemy_stronghold"] = {"#map_stronghold_enemy.png"},
	["forbidden_stronghold"] = {"#map_stronghold_enemy.png", "#map_forbidden.png"},
	["forbidden_flag"] = {"#map_forbidden.png"},
	["goal_port"] = {"#map_goal.png"},
	["goal_whirlpool"] = {"#map_whirlpool.png"},
	["task_effect"] = {"#map_icon_task.png"},
	["good_port"] = {"#map_icon_goods.png"},
	["hot_sell"] = {"#map_goods_hotsell.png"},
	["unfinish_relic"] = {"#map_relic_found.png"},
	["finish_relic"] = {"#map_relic_enter.png"},
	["map_boss"] = {"#map_boss.png"},
	["time_pirate"] = {"#map_batman.png"},
	["time_pirate_boss"] = {"#map_task_octopus.png"},
	["mineral_point_me"] = {"#map_mineral_me.png"},
	["mineral_point_enemy"] = {"#map_mineral_enemy.png"},
	["mineral_point_neutral"] = {"#map_mineral_enter.png"},
	["port_appoint"] = {"#map_icon_crown.png"},
	["reward_pirate"] = {"#map_icon_reward.png"},
	["world_mission"] = {"#common_btn_help2.png"},
	["port_pre_task"] = {"#map_forbidden.png"},
	-- ["ship_wrecks"] = {"#map_boss.png"},
	["ship_wrecks"] = {"#map_icon_reward.png"},
	["convoy_mission"] = {"#map_task_diamond.png"},
	--港口势力相关的
	[PORT_POWER_STATUS_NEUTRAL .."_culture"] = {"#common_port_culture_neutrality.png"},
	[PORT_POWER_STATUS_HOSTILITY .."_culture"] = {"#common_port_culture_rivalry.png"},
	[PORT_POWER_STATUS_FRIENDLY .."_culture"] = {"#common_port_culture_friendly.png"},

	[PORT_POWER_STATUS_NEUTRAL .."_industry"] = {"#common_port_industry_neutrality.png"},
	[PORT_POWER_STATUS_HOSTILITY .."_industry"] = {"#common_port_industry_rivalry.png"},
	[PORT_POWER_STATUS_FRIENDLY .."_industry"] = {"#common_port_industry_friendly.png"},

	[PORT_POWER_STATUS_NEUTRAL .."_business"] = {"#common_port_business_neutrality.png"},
	[PORT_POWER_STATUS_HOSTILITY .."_business"] = {"#common_port_business_rivalry.png"},
	[PORT_POWER_STATUS_FRIENDLY .."_business"] = {"#common_port_business_friendly.png"},
	["empty"] = {},
}

local map_good_key = {
	[PORT_POWER_STATUS_NEUTRAL] = "yellow",
	[PORT_POWER_STATUS_HOSTILITY] = "red",
	[PORT_POWER_STATUS_FRIENDLY] = "green",
}
for i = 0, 8 do
	local y_key = string.format("%d_goods_%d", PORT_POWER_STATUS_NEUTRAL, i)
	local r_key = string.format("%d_goods_%d", PORT_POWER_STATUS_HOSTILITY, i)
	local g_key = string.format("%d_goods_%d", PORT_POWER_STATUS_FRIENDLY, i)

	local y_value = string.format("#map_goods_%s_%d.png", map_good_key[PORT_POWER_STATUS_NEUTRAL], i)
	local r_value = string.format("#map_goods_%s_%d.png", map_good_key[PORT_POWER_STATUS_HOSTILITY], i)
	local g_value = string.format("#map_goods_%s_%d.png", map_good_key[PORT_POWER_STATUS_FRIENDLY], i)

	if i > 0 then
		ExploreMap.POINT_RES[y_key] = {y_value}
		ExploreMap.POINT_RES[r_key] = {r_value}
		ExploreMap.POINT_RES[g_key] = {g_value}
	else
		ExploreMap.POINT_RES[y_key] = {"#map_goods_rest_0.png"}
		ExploreMap.POINT_RES[r_key] = {"#map_goods_rest_0.png"}
		ExploreMap.POINT_RES[g_key] = {"#map_goods_rest_0.png"}
	end
end
for k, v in pairs(port_power) do
	local key = v.flagship_map_res
	ExploreMap.POINT_RES[key] = {"#" .. v.flagship_map_res}
end

ExploreMap.NEED_WIDGET_NAME = {
	{name = "btn_worldmap"},
	{name = "btn_go", children = {"btn_go_text"}},
	{name = "btn_sail"},
	{name = "btn_transfer"},
	{name = "distance_num"},
	{name = "cost_num"},
	{name = "capacity_num"},
	{name = "supply_num"},
	{name = "purpose_info"},
	{name = "purpose_name"},
	{name = "supply_info"},
	{name = "line_1"},
	{name = "line_2"},
	{name = "line_3"},
	{name = "info_panel"},
	{name = "time_panel", children = {"time_tips", "time_num"}},
	{name = "touch_sceen"},
	{name = "port_panel"},
	{name = "red_tips_bg"},
}

ExploreMap.NAVTYPE_TO_CONFIG = {
	[EXPLORE_NAV_TYPE_PORT] = port_info,
	[EXPLORE_NAV_TYPE_SH] = pve_stronghold_info,
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = explore_whirlpool,
	[EXPLORE_NAV_TYPE_RELIC] = relic_info,
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = explore_objects_config,
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = explore_objects_config,
	[EXPLORE_NAV_TYPE_OTHER] = area_info,
	[EXPLORE_NAV_TYPE_WORLD_MISSION] = world_mission_total_cfg,
	[EXPLORE_NAV_TYPE_CONVOY_MISSION] = require("game_config/loot/time_plunder_info"),
}

ExploreMap.NAVTYPE_TO_CONFIG_POS = {
	[EXPLORE_NAV_TYPE_PORT] = function(self, id) return port_info[id].port_pos end,
	[EXPLORE_NAV_TYPE_SH] = function(self, id) return pve_stronghold_info[id].point_pos end,
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = function(self, id) return explore_whirlpool[id].map_pos end,
	[EXPLORE_NAV_TYPE_RELIC] = function(self, id) return relic_info[id].coord end,
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = function(self, id) return getGameData():getExplorePirateEventData():getTimePirateConfig()[id].map_pos end,
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = function(self, id) return getGameData():getAreaCompetitionData():getMineralPointConfig()[id].map_pos end,
	[EXPLORE_NAV_TYPE_REWARD_PIRATE] = function(self) return getGameData():getExploreRewardPirateEventData():getMapPos() end,
	[EXPLORE_NAV_TYPE_WORLD_MISSION] = function(self,id)
		local item = getGameData():getWorldMissionData():getWorldMissionList()[id]
		if item then
			return item.cfg.position_map
		else
			print(" error no cfg ExploreMap NAVTYPE_TO_CONFIG_POS")
			return nil
		end
	end,
	[EXPLORE_NAV_TYPE_CONVOY_MISSION] = function(self,id)
		local item = getGameData():getConvoyMissionData():getShowList()[id]
		if item then
			return item.cfg.position_map
		else
			return nil
		end
	end,
	[EXPLORE_NAV_TYPE_SALVE_SHIP] = function (self,id)
		return nil
	end
}

--直接调用updatePoint，切勿调用具体的updateXXXPoint函数
ExploreMap.NAVTYPE_TO_POINT_UPDATE = {
	[EXPLORE_NAV_TYPE_PORT] = function(self, id) return self:updatePortPoint(id) end,
	[EXPLORE_NAV_TYPE_SH] = function(self, id) return self:updateStrongHoldPoint(id) end,
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = function(self, id) return self:updateWhirlPoolPoint(id) end,
	[EXPLORE_NAV_TYPE_RELIC] = function(self, id) return self:updateRelicPlacePoint(id) end,
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = function(self, id) return self:updateTimePiratePoint(id) end,
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = function(self, id) return self:updateMineralPoint(id) end,
	[EXPLORE_NAV_TYPE_REWARD_PIRATE] = function(self, id) return self:updataRewardPiratePoint(id) end,
	[EXPLORE_NAV_TYPE_WORLD_MISSION] = function (self,id ) return self:updateWorldMissionPoint(id) end, -- 世界随机任务
	[EXPLORE_NAV_TYPE_CONVOY_MISSION] = function (self,id ) return self:updateConvoyMissionPoint(id) end, -- 运镖
	[EXPLORE_NAV_TYPE_SALVE_SHIP] = function (self,id) return self:updateSalveShipPoint(id) end, --打捞沉船点
}

--直接调用resetPoint，切勿调用具体的resetXXXPoint函数
ExploreMap.NAVTYPE_TO_POINT_RESET = {
	[EXPLORE_NAV_TYPE_PORT] = function(self) return self:resetPortPoint() end,
	[EXPLORE_NAV_TYPE_SH] = function(self) return self:resetStrongHoldPoint() end,
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = function(self) return self:resetWhirlPoolPoint() end,
	[EXPLORE_NAV_TYPE_RELIC] = function(self) return self:resetRelicPlacePoint() end,
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = function(self) return self:resetTimePiratePoint() end,
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = function(self) return self:resetMineralPoint() end,
	[EXPLORE_NAV_TYPE_REWARD_PIRATE] = function(self, id) return self:resetRewardPiratePoint(id) end,
	[EXPLORE_NAV_TYPE_WORLD_MISSION] = function (self) return self:resetWorldMissionPoint() end,
	[EXPLORE_NAV_TYPE_CONVOY_MISSION] = function (self) return self:resetConvoyMissionPoint() end, -- 运镖
	[EXPLORE_NAV_TYPE_SALVE_SHIP] = function (self) return self:resetSalveShipPoint() end,
}

ExploreMap.onEnter = function(self, AStar)
	self.AStar = AStar
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:askPortList()

	local port_battle_data = getGameData():getPortBattleData()
	local area_id = getGameData():getExploreMapData():getCurAreaId()
	port_battle_data:askPortsOccupyInfo(area_id)

	local collect_handle = getGameData():getCollectData()
	collect_handle:reAskRelicInfo()
	collect_handle:askShareTimes()
	
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:askTraceingPlayerInfo()


	local explore_map_data = getGameData():getExploreMapData()

	explore_map_data:init() ---初始化pve，数据

	-- 请求世界随机任务数据
	-- getGameData():getWorldMissionData():askWorldMissionList()

	ExploreMap.super.onEnter(self)

	self.plist_res_2 = {
		["ui/map.plist"] = 1,
		["ui/box.plist"] = 1,
		["ui/port_cargo.plist"] = 1,
		["ui/explore_sea.plist"] = 1,
		["ui/force_icon.plist"] = 1,
		["ui/cityhall_ui.plist"] = 1,
		["ui/item_box.plist"] = 1,
	}

	self.area_res = {
		"world_map/wm_arena_1.jpg",
		"world_map/wm_arena_2.jpg",
		"world_map/wm_arena_3.jpg",
		"world_map/wm_arena_4.jpg",
		"world_map/wm_arena_5.jpg",
		"world_map/wm_arena_6.jpg",
		"world_map/wm_arena_7.jpg",
	}

	self.armature_res_2 = {
		"effects/tx_0052.ExportJson",
	}
	self.worldmap_bg_res = "world_map/world_map.jpg"

	LoadArmature(self.armature_res_2)
	LoadPlist(self.plist_res_2)

	local explore_data = getGameData():getExploreData()
	self.cur_goal_place = explore_data:getGoalInfo()
	if self.cur_goal_place and self.cur_goal_place.navType == EXPLORE_NAV_TYPE_NONE then
		self.cur_goal_place = nil
	end

	self.show_worldmap_viewport_rect = CCRect(0, 0, 960, 540)
	self.show_areamap_viewport_rect = CCRect(0, 0, 700, 540)
	self.show_max_viewport_rect = self.show_areamap_viewport_rect

	self.show_min_viewport_rect = CCRect(display.width - 132, display.height - 132, 130, 130)

	self.show_worldmap_show_nodes = {}
	self.show_worldmap_hide_nodes = {}
	self.show_areamap_show_nodes = {}
	self.show_areamap_hide_nodes = {}

	self.is_go_explore = false

	self.ship_pos_rate = EXPLORE_RATE
	self.area_map_dic = {}
	self.point_dic = {}
	self.point_visible_dic = {
		[EXPLORE_NAV_TYPE_PORT] = true,
		[EXPLORE_NAV_TYPE_SH] = true,
		[EXPLORE_NAV_TYPE_WHIRLPOOL] = true,
		[EXPLORE_NAV_TYPE_RELIC] = true,
		[EXPLORE_NAV_TYPE_TIME_PIRATE] = true,
		-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = true,
		[EXPLORE_NAV_TYPE_REWARD_PIRATE] = true,
		[EXPLORE_NAV_TYPE_WORLD_MISSION] = true,
		[EXPLORE_NAV_TYPE_CONVOY_MISSION] = true,
	}

	self.show_worldmap_map_layer_scale = nil
	self.worldmap_relic_sp_scale = 2
	self.has_init_worldmap_relic_scale = nil
	self.worldmap_point_effect_scale = 1.3
	self.relic_worldmap_effect_scale = 2.5
	self.border_max_offset = 30
	self.drag_out_area_id = 0
	self.drag_out_area_dis = 180

	self.cur_select_point_info = nil
	self.cocostudio_ui_layer = nil
	self.widget_panel = nil
	self.widget_panel_area = nil
	self.widget_panel_world = nil
	self.point_info_panel = nil

	self.worldmap_show = nil       --是否世界地图
	self.is_cross_unknow_area = nil
	self.team_world_mission_max_schedule = 20 --组队世界任务最大进度值

	self:initUI()
end

ExploreMap.initUI = function(self)
	local init_result = ExploreMap.super.initUI(self, "world_map/exploreMap.tmx", ExploreMap.MAP_RES_TYPE_TMX)
	local mapAttrs = getGameData():getWorldMapAttrsData()

	local initBg
	initBg = function()
		self.color_bg = CCLayerColor:create(ccc4(0,0,0,230))
		self:addChild(self.color_bg, -1)
		self.cocostudio_ui_layer = UIWidget:create()
		self.cocostudio_ui_layer:setZOrder(2)
		self.widget_panel = GUIReader:shareReader():widgetFromJsonFile("json/worldmap.json")
		self.cocostudio_ui_layer:addChild(self.widget_panel)
		self:addWidget(self.cocostudio_ui_layer)
		for k1,v1 in pairs(self.NEED_WIDGET_NAME) do
			self.widget_panel[v1.name] = getConvertChildByName(self.widget_panel, v1.name)
			if v1.children then
				for k2,v2 in pairs(v1.children) do
					self.widget_panel[v1.name][v2] = getConvertChildByName(self.widget_panel[v1.name], v2)
				end
			end
		end

		self.widget_panel.worldmap_area = GUIReader:shareReader():widgetFromJsonFile("json/worldmap_area.json")
		convertUIType(self.widget_panel.worldmap_area)

		self.widget_panel.worldmap_area:setZOrder(5)
		self:addWidget(self.widget_panel.worldmap_area)

		self.widget_panel.btn_worldmap = getConvertChildByName(self.widget_panel.worldmap_area, "btn_worldmap")
		self.widget_panel.btn_ship = getConvertChildByName(self.widget_panel.worldmap_area, "btn_ship")
		self.widget_panel.btn_purpose = getConvertChildByName(self.widget_panel.worldmap_area, "btn_purpose")

		self.widget_panel.diamond_num = getConvertChildByName(self.widget_panel.worldmap_area, "diamond_num")
		self.widget_panel.port_amount_num = getConvertChildByName(self.widget_panel.worldmap_area, "port_amount_num")
		self.widget_panel.relic_amount_num = getConvertChildByName(self.widget_panel.worldmap_area, "relic_amount_num")
		self.widget_panel.btn_award = getConvertChildByName(self.widget_panel.worldmap_area, "btn_award")
		self.widget_panel.award_available = getConvertChildByName(self.widget_panel.worldmap_area, "award_available")
		self.widget_panel.award_have_get = getConvertChildByName(self.widget_panel.worldmap_area, "award_have_get")
		self.widget_panel.red_point = getConvertChildByName(self.widget_panel.worldmap_area, "red_point")
		self.widget_panel.present_area = getConvertChildByName(self.widget_panel.worldmap_area, "present_area")

		-- local task_data = getGameData():getTaskData()
		-- local task_keys = {
		-- 	on_off_info.WORLD_MISSION.value,
		-- }
		-- task_data:regTask(self.widget_panel.btn_worldmap, task_keys, KIND_CIRCLE, task_keys[1], 15, 15, true)

		self.widget_panel.touch_sceen:setTouchEnabled(false)
		self.widget_panel.port_panel:setTouchEnabled(false)

		self.widget_panel.touch_sceen:addEventListener(function (  )
			if self.help_layer.isShow then
				self:helpBtnCallBack(false)
			end
			if self.visible_of_wmt_panel then
				self:setVisibleOfWorldMissionPanel(false)
			end
		end,TOUCH_EVENT_ENDED)

		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.color_bg
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.cocostudio_ui_layer
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.color_bg
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.cocostudio_ui_layer
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.widget_panel.worldmap_area

		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.widget_panel.info_panel
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.widget_panel.worldmap_area

		self:setWorldmapHideNode(self.widget_panel.info_panel)
		self:setWorldmapHideNode(self.widget_panel.worldmap_area)
	end

	local initTmxMap
	initTmxMap = function()
		local world_map_res_width = 912
		local world_map_res_height = 512
		local world_map_scale_x = self.show_worldmap_viewport_rect.size.width / world_map_res_width
		local world_map_scale_y = self.show_worldmap_viewport_rect.size.height / world_map_res_height
		self.show_worldmap_map_layer_scale = self.show_worldmap_viewport_rect.size.width / self.map_width

		------------- tilemap图层 ---------------
		for k,v in pairs(MAP_LAYER_NAMES) do
			self[k] = self.map:layerNamed(v)
			self[k]:setVisible(false)
		end
	end

	local initAreaMap
	initAreaMap = function()
		self.arena_name_layer = display.newLayer()
		self.map:addChild(self.arena_name_layer)
		
		local special_scale = {
			["APPOINT_FZ"] = 1.5,
			["APPOINT_YDY"] = 2,
			["APPOINT_DNY"] = 2,
			["APPOINT_DY"] = 2,
			["APPOINT_XDL"] = 1.5,
		}
		for k, v in pairs(area_info) do
			if v.map_show ~= 0 then
				local show_scale = v.zoom / 100
				if special_scale[v.auto_trade] then
					show_scale = special_scale[v.auto_trade]
				end
				self.area_map_dic[k] = {mapRes = v.map_res, map = nil, lootMap = nil, base = v,
					minScale = v.zoom / 100, showScale = show_scale, mapPos = ccp(v.lbPos[1] + v.width/2,v.lbPos[2] + v.height/2),
					mapRect = CCRect(v.lbPos[1], v.lbPos[2], v.width, v.height)}
			end
		end

		self.top_area_name = createBMFont({text = "", size = 20, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), align = ui.TEXT_ALIGN_CENTER})
		self.top_area_name:setPosition(ccp(self.show_areamap_viewport_rect.size.width/2, self.show_areamap_viewport_rect.size.height-18))

		self.bottom_area_name = createBMFont({text = "", size = 20, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), align = ui.TEXT_ALIGN_CENTER})
		self.bottom_area_name:setPosition(ccp(self.show_areamap_viewport_rect.size.width/2, 18))

		self.left_area_name = createBMFont({text = "", size = 20, width = 20, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), align = ui.TEXT_ALIGN_CENTER})
		self.left_area_name:setPosition(ccp(18, self.show_areamap_viewport_rect.size.height/2))

		self.right_area_name = createBMFont({text = "", size = 20, width = 20, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), align = ui.TEXT_ALIGN_CENTER})
		self.right_area_name:setPosition(ccp(self.show_areamap_viewport_rect.size.width-18, self.show_areamap_viewport_rect.size.height/2))

		self.map_border:addChild(self.top_area_name, 3)
		self.map_border:addChild(self.bottom_area_name, 3)
		self.map_border:addChild(self.left_area_name, 3)
		self.map_border:addChild(self.right_area_name, 3)

		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.arena_name_layer
		self.show_areamap_hide_nodes[#self.show_areamap_hide_nodes + 1] = self.arena_name_layer
		self.show_worldmap_show_nodes[#self.show_worldmap_show_nodes + 1] = self.arena_name_layer
	end

	local initWorldMissionTip
	initWorldMissionTip = function()
		local panel = GUIReader:shareReader():widgetFromJsonFile("json/worldmap_port_tips.json")
		convertUIType(panel)
		self.world_mission_tip_json_panel = panel
		self.world_mission_tip_panel = UIWidget:create()
		self.world_mission_tip_panel:addChild(panel)

		self.world_mission_tip_panel.tips_panel = getConvertChildByName(panel,"tips_panel")
		self.world_mission_tip_panel:setZOrder(5)
		self:addWidget(self.world_mission_tip_panel)
		self.visible_of_wmt_panel = false

		local pos = self.widget_panel.port_panel:getWorldPosition()
		local view_pos = self.widget_panel:getWorldPosition()
		self.world_mission_tip_panel:setPosition(ccp(pos.x - view_pos.x, pos.y - view_pos.y))

		self.world_mission_percent_panel = GUIReader:shareReader():widgetFromJsonFile("json/worldmap_world.json")
		self.world_mission_percent_panel.percent_bar = getConvertChildByName(self.world_mission_percent_panel, "bar")
		self.world_mission_percent_panel.percent_label = getConvertChildByName(self.world_mission_percent_panel, "txt_percent")
		self.world_mission_percent_panel.percent_label:setText(string.format("0/%s", self.team_world_mission_max_schedule))
		self.world_mission_percent_panel.percent_bar:setPercent(0)

		self.world_mission_percent_panel:setZOrder(5)
		self:addWidget(self.world_mission_percent_panel)

		self.widget_panel.red_tips_bg = getConvertChildByName(self.world_mission_percent_panel, "red_tips_bg")
		self.widget_panel.btn_back = getConvertChildByName(self.world_mission_percent_panel, "btn_back")

		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.widget_panel.red_tips_bg
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.world_mission_tip_panel
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.world_mission_percent_panel
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.widget_panel.btn_back

		self:setWorldmapHideNode(self.world_mission_tip_panel)

		self.show_worldmap_show_nodes[#self.show_worldmap_show_nodes + 1] = self.widget_panel.btn_back
		self.show_worldmap_show_nodes[#self.show_worldmap_show_nodes + 1] = self.widget_panel.red_tips_bg
		self.show_worldmap_show_nodes[#self.show_worldmap_show_nodes + 1] = self.world_mission_percent_panel

		self.show_areamap_hide_nodes[#self.show_areamap_hide_nodes + 1] = self.widget_panel.btn_back
		self.show_areamap_hide_nodes[#self.show_areamap_hide_nodes + 1] = self.widget_panel.red_tips_bg
		self.show_areamap_hide_nodes[#self.show_areamap_hide_nodes + 1] = self.world_mission_percent_panel
	end

	local initHelp
	initHelp = function()
		local panel = GUIReader:shareReader():widgetFromJsonFile("json/worldmap_port_littlemap.json")
		convertUIType(panel)

		self.help_layer = UIWidget:create()
		self.help_layer:addChild(panel)
		self.help_layer:setZOrder(6)
		self:addWidget(self.help_layer)

		self.help_layer.isShow = false
		self.help_layer.btn_tips = getConvertChildByName(panel, "btn_tips")
		self.help_layer.tips_panel = getConvertChildByName(panel, "tips_panel")

		self.help_layer:setPosition(ccp(466, 39))

		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.help_layer
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.help_layer

		self:setWorldmapHideNode(self.help_layer)
	end

	local initBtn
	initBtn = function()
		self.widget_panel.btn_award:setPressedActionEnabled(true)
		self.widget_panel.btn_ship:setPressedActionEnabled(true)
		self.widget_panel.btn_purpose:setPressedActionEnabled(true)
		self.widget_panel.btn_back:setPressedActionEnabled(true)
		self.help_layer.btn_tips:setPressedActionEnabled(true)
		self.widget_panel.btn_worldmap:setPressedActionEnabled(true)
		self.widget_panel.btn_go:setPressedActionEnabled(true)
		self.widget_panel.btn_transfer:setPressedActionEnabled(true)
		self.widget_panel.btn_sail:setTouchEnabled(false)

		self.move_btns_spr = display.newSprite()
		self.map_border:addChild(self.move_btns_spr, 2)
		self.top_border_btn = self:createButton({image = "#map_arrow_1.png", imageSelected = "#map_arrow_2.png", x = self.show_areamap_viewport_rect.size.width/2, y = self.show_areamap_viewport_rect.size.height-18})

		self.bottom_border_btn = self:createButton({image = "#map_arrow_1.png", imageSelected = "#map_arrow_2.png", x = self.show_areamap_viewport_rect.size.width/2, y = 18})
		self.bottom_border_btn:setRotation(180)

		self.left_border_btn = self:createButton({image = "#map_arrow_1.png", imageSelected = "#map_arrow_2.png", x = 18, y = self.show_areamap_viewport_rect.size.height/2})
		self.left_border_btn:setRotation(270)

		self.right_border_btn = self:createButton({image = "#map_arrow_1.png", imageSelected = "#map_arrow_2.png", x = self.show_areamap_viewport_rect.size.width-18, y = self.show_areamap_viewport_rect.size.height/2})
		self.right_border_btn:setRotation(90)

		self.move_btns_spr:addChild(self.top_border_btn)
		self.move_btns_spr:addChild(self.bottom_border_btn)
		self.move_btns_spr:addChild(self.left_border_btn)
		self.move_btns_spr:addChild(self.right_border_btn)
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.move_btns_spr
		self.show_worldmap_hide_nodes[#self.show_worldmap_hide_nodes + 1] = self.move_btns_spr
	end

	local initPoint
	initPoint = function()
		self.mission_pirate_layer = require("gameobj/explore/clsMoveMissionPirate").new(self)
		self.map:addChild(self.mission_pirate_layer, 11)

		self.point_name_layer = display.newLayer()
		self.map:addChild(self.point_name_layer, 10)
		self.point_name_layer:setVisible(false)

		self.effect_layer = display.newLayer()
		self.map:addChild(self.effect_layer)

		self.point_layer = display.newLayer()
		self.map:addChild(self.point_layer, 8)

		--批量渲染（暂时不能用了，由于策划需求名字和point同时缩放而且位置不能偏移）
		self.point_batch = display.newBatchNode("ui/map.pvr.ccz", #port_info+#pve_stronghold_info+#relic_info)
		self.point_layer:addChild(self.point_batch)

		self.point_info_panel = ClsEMapPointInfoPanel.create()
		self.point_info_panel:setPosition(ccp(700, 190))
		self.point_info_panel:setZOrder(2)
		self:addWidget(self.point_info_panel)

		mapAttrs:initShHash()
		mapAttrs:initWpHash()
		mapAttrs:initRelicHash()

		self.show_min_show_nodes[#self.show_min_show_nodes + 1] = self.point_name_layer
		self.show_min_show_nodes[#self.show_min_show_nodes + 1] = self.mission_pirate_layer
		self.show_min_show_nodes[#self.show_min_show_nodes + 1] = self.point_layer
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.point_info_panel
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.point_info_panel
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.point_name_layer
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.mission_pirate_layer
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.point_layer
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.point_info_panel
		self.show_areamap_show_nodes[#self.show_areamap_show_nodes + 1] = self.effect_layer
		self.show_worldmap_hide_nodes[#self.show_worldmap_hide_nodes + 1] = self.effect_layer
		self.show_worldmap_hide_nodes[#self.show_worldmap_hide_nodes + 1] = self.point_info_panel
		self.show_worldmap_hide_nodes[#self.show_worldmap_hide_nodes + 1] = self.mission_pirate_layer
	end

	local initShipPos
	initShipPos = function()
		local sceneDataHander = getGameData():getSceneDataHandler()
		local dx, dy = nil
		local angle = 0
		local pos_rate = nil
		if sceneDataHander:isInExplore() then
			pos = sceneDataHander:getSceneInitPos()
			local p = exploreMapUtil.cocosToTileByLand(pos)
			dx = p.x
			dy = p.y
		else
			local port_data = getGameData():getPortData()
			local port_id = port_data:getPortId() -- 当前港口
			local port_base = port_info[port_id]
			pos = ccp(port_base.port_pos[1], port_base.port_pos[2])
			local p = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
			dx = p.x + port_base.deviation_pos[1]
			dy = p.y + port_base.deviation_pos[2]
			angle = port_base.ship_dir
			pos_rate = 1
		end
		self:setShipPosInfo({x = dx, y = dy, pos_rate = pos_rate, angle = angle})
	end

	local initOtherPoint
	initOtherPoint = function()
		self:resetPoint(EXPLORE_NAV_TYPE_SALVE_SHIP)

		--强制试图刷新悬赏海盗图标
		self:updatePoint(1, EXPLORE_NAV_TYPE_REWARD_PIRATE)
	end

	initBg()
	initTmxMap()
	initAreaMap()
	initWorldMissionTip()
	initHelp()
	initBtn()
	initPoint()
	initOtherPoint()

	self:initEvent()

	--最后才调用更新位置，保证其有回调执行可能出现的海域移动
	initShipPos()
	return init_result
end

ExploreMap.setWorldmapHideNode = function(self, node)
	self.show_worldmap_hide_nodes[#self.show_worldmap_hide_nodes + 1] = node
end

ExploreMap.updateTeamWorldMissionSchedule = function(self, schedule)
	if not tolua.isnull(self.world_mission_percent_panel) then
		self.world_mission_percent_panel.percent_label:setText(string.format("%s/%s", schedule, self.team_world_mission_max_schedule))
		self.world_mission_percent_panel.percent_bar:setPercent(schedule / self.team_world_mission_max_schedule * 100)
	end
end

ExploreMap.updateTracePoint = function(self, info)
	if not info or info.id == nil or info.id <= 0 then
		self.trace_obj:setVisible(false)
		return
	else
		self.trace_obj:setVisible(true)
		self.trace_obj.name:setString(info.name or "")
		local dx, dy = nil, nil
		if info.port_id and info.port_id > 0 then
			local port_data = getGameData():getPortData()
			local port_base = port_info[tonumber(info.port_id)]
			pos = ccp(port_base.port_pos[1], port_base.port_pos[2])
			local p = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
			dx = p.x + port_base.deviation_pos[1] - 10
			dy = p.y + port_base.deviation_pos[2]
		else
			local p = exploreMapUtil.landTileToThumbTile(ccp(info.x, info.y))
			dx = p.x
			dy = p.y + 20
		end
		self.trace_obj:setPosition(ccp(dx, dy))
	end
end

ExploreMap.initPortPowerUI = function(self, port_power_list, area_id)
	local port_data = getGameData():getPortData()
	if not tolua.isnull(self.force_layer) then
		self.force_layer:removeFromParentAndCleanup(true)
		self.force_layer = nil
	end

	if self.effect_power_node then
		for k, node in pairs(self.effect_power_node) do
			node:removeFromParentAndCleanup(true)
		end
		self.effect_power_node = {}
	end

	local panel = GUIReader:shareReader():widgetFromJsonFile("json/worldmap_force.json")
	convertUIType(panel)
	self.force_layer = UIWidget:create()
	self.force_layer:addChild(panel)
	self.force_layer:setZOrder(5)
	self:addWidget(self.force_layer)
	self.force_layer:setVisible(self.show_max)
	self.force_layer.worldmap_force = getConvertChildByName(panel, "worldmap_force")
	self.force_layer.worldmap_force:setPosition(ccp(0, 360))
	self.force_layer.area_id = area_id

	local explore_map_data = getGameData():getExploreMapData()
	local cur_area_id = area_id
	local port_power_info = port_data:getPortPowerInfo()
	local area_port_power_list = port_data:getPortPowerList(port_power_info, cur_area_id)
	local map_attr_data = getGameData():getWorldMapAttrsData()

	for i = 1, 4 do
		local bg = "power_icon_bg_" .. i
		local icon = "force_icon_" .. i
		local name = "force_name_" .. i
		local amount = "force_amount_" .. i
		local power = "power_" .. i
		self.force_layer[icon] = getConvertChildByName(panel, icon)
		self.force_layer[name] = getConvertChildByName(panel, name)
		self.force_layer[amount] = getConvertChildByName(panel, amount)
		self.force_layer[power] = getConvertChildByName(panel, power)
		self.force_layer[bg] = getConvertChildByName(panel, bg)
		local is_visible = (i <= #port_power_list)
		self.force_layer[power]:setVisible(is_visible)
		self.force_layer[bg]:setVisible(is_visible)
		if is_visible then
			local power_id = port_power_list[i].power_id
			local power_info = port_power[power_id]
			self.force_layer[icon]:changeTexture(power_info.flagship_map_res, UI_TEX_TYPE_PLIST)
			self.force_layer[name]:setText(power_info.name)
			self.force_layer[amount]:setText(port_power_list[i].amount)
			self.force_layer[bg]:addEventListener(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				if self.force_layer.effect_power_node then
					self.force_layer.effect_power_node:removeFromParentAndCleanup(true)
					self.force_layer.effect_power_node = nil
				end
				self.force_layer.effect_power_node = composite_effect.new("tx_map_light", 0, 0, self.force_layer[bg], nil, nil, nil, nil, true)
				self.force_layer.effect_power_node:setScale(0.75)
				if self.effect_power_node then
					for k, node in pairs(self.effect_power_node) do
						node:removeFromParentAndCleanup(true)
					end
				end
				self.effect_power_node = {}
				local port_ids = area_port_power_list[i].port_ids

				local select_point_mark = false
				local mapAttrs = getGameData():getWorldMapAttrsData()
				for k, port_id in pairs(port_ids) do
					if mapAttrs:isMapOpenPort(port_id) then
						local _pos = self.NAVTYPE_TO_CONFIG_POS[EXPLORE_NAV_TYPE_PORT](self, port_id)
						local _p = exploreMapUtil.cocosToTile(ccp(_pos[1], _pos[2]), self.map_height, self.map_tile_size)
						local effer_power = composite_effect.new("tx_map_light", 0, 0, self.effect_layer)
						local goalEffectScale = 0
						if not self.worldmap_show then
							local layerScale = self.map_layer:getScale()
							if layerScale ~= 0 then
								goalEffectScale = 1/layerScale
							end
						else
							goalEffectScale = self.worldmap_point_effect_scale
						end
						effer_power:setScale(goalEffectScale)
						effer_power:setPosition(ccp(_p.x, _p.y - 1))
						self.effect_power_node[#self.effect_power_node + 1] = effer_power
						if not select_point_mark then
							self:turnToPointArea(port_id, EXPLORE_NAV_TYPE_PORT, true)
							select_point_mark = true
						end
					end
				end
			end, TOUCH_EVENT_ENDED)
		end
	end
end

ExploreMap.tryUpdatePortPowerUI = function(self, area_id)
	local port_data = getGameData():getPortData()
	local change_power_data = port_data:getChangePowerInfo(area_id)
	local port_power_list = port_data:getPortPowerList(nil, area_id)
	if not change_power_data or change_power_data.del_t then
		self:initPortPowerUI(port_power_list, area_id)
		return
	end
	for k, v in ipairs(change_power_data.del_t) do
		table.insert(port_power_list, 1, {power_id = v, amount = 0})
	end
	local time = 0.8
	local arr_action = CCArray:create()
	self:initPortPowerUI(port_power_list, area_id)
	if not table.is_empty(change_power_data.del_t) then
		local pos = ccp(-self.force_layer["power_1"]:getContentSize().width - 50, self.force_layer["power_1"]:getPosition().y)
		arr_action:addObject(CCCallFunc:create(function()
			self.force_layer["power_icon_bg_1"]:runAction(CCMoveTo:create(time, pos))
		end))
		arr_action:addObject(CCMoveTo:create(time, pos))
		arr_action:addObject(CCCallFunc:create(function()
			for i = 2, 4 do
				local pos = ccp(self.force_layer["power_" .. i]:getPosition().x, self.force_layer["power_" .. i - 1]:getPosition().y)
				local pos_bg = ccp(self.force_layer["power_icon_bg_" .. i]:getPosition().x, self.force_layer["power_icon_bg_" .. i - 1]:getPosition().y)
				self.force_layer["power_" .. i]:runAction(CCMoveTo:create(time, pos))
				self.force_layer["power_icon_bg_" .. i]:runAction(CCMoveTo:create(time, pos_bg))
			end
		end))
		arr_action:addObject(CCDelayTime:create(time))
	end

	if not table.is_empty(change_power_data.add_t) then
		port_power_list = port_data:getPortPowerList(nil, area_id)
		table.remove(port_power_list, 1)
		self:initPortPowerUI(port_power_list, area_id)
		local power_node = self.force_layer["power_" .. #port_power_list+1]
		local icon_bg_node = self.force_layer["power_icon_bg_" .. #port_power_list+1]
		local pos = power_node:getPosition()
		power_node:setPosition(ccp(-power_node:getContentSize().width - 50, pos.y))
		local power_id = change_power_data.add_t[1]
		local power_info = port_power[power_id]
		self.force_layer["force_icon_" .. #port_power_list+1]:changeTexture(power_info.flagship_map_res, UI_TEX_TYPE_PLIST)
		self.force_layer["force_name_" .. #port_power_list+1]:setText(power_info.name)
		self.force_layer["force_amount_" .. #port_power_list+1]:setText(1)
		arr_action:addObject(CCCallFunc:create(function()
			icon_bg_node:setVisible(true)
			power_node:setVisible(true)
			power_node:runAction(CCMoveTo:create(time, ccp(pos.x, pos.y)))
		end))
		arr_action:addObject(CCDelayTime:create(time))
	end
	arr_action:addObject(CCCallFunc:create(function()
		local list = port_data:getPortPowerList(nil, area_id)
		self:initPortPowerUI(list, area_id)
		self:updataPortPower(area_id)
	end))
	self.force_layer["power_1"]:runAction(CCSequence:create(arr_action))
end

ExploreMap.updataPortPower = function(self, area_id)
	local port_data = getGameData():getPortData()
	local change_power_data = port_data:getChangePowerInfo(area_id)
	local port_power_list = port_data:getPortPowerList(nil, area_id)

	for k, v in pairs(port_power_list) do
		for k1, v1 in pairs(change_power_data.down_t) do
			if v.power_id == v1 then
				composite_effect.new("tx_arrow_roll_down", 25, 0, self.force_layer["force_amount_" .. k], nil, nil, nil, nil, true)
			end
		end

		for k1, v1 in pairs(change_power_data.up_t) do
			if v.power_id == v1 then
				composite_effect.new("tx_arrow_roll_up", 25, 0, self.force_layer["force_amount_" .. k], nil, nil, nil, nil, true)
			end
		end
	end
	port_data:setChangePowerInfo(area_id)
end

ExploreMap.initEvent = function(self)
	ExploreMap.super.initEvent(self)
	local explore_map_data = getGameData():getExploreMapData()

	self.widget_panel.btn_award:addEventListener(function()
		if not self.widget_panel.btn_award.invest_finished then
			ClsAlert:warning({msg = ui_word.AREA_INVEST_NOT_SATISFIED})
			return
		elseif not self.widget_panel.btn_award.relic_finished then
			ClsAlert:warning({msg = ui_word.AREA_RELIC_NOT_SATISFIED})
			return
		end

		self.widget_panel.btn_award:setTouchEnabled(false)

		local area_reward_data = getGameData():getAreaRewardData()

		local area_id = explore_map_data:getCurClickAreaId()

		area_reward_data:askGetAreaReward(0, area_id)
		area_reward_data:askAreaRewardInfo(area_id)
	end, TOUCH_EVENT_ENDED)

	self.widget_panel.btn_purpose:addEventListener(function()
		local point_info = self.cur_goal_place and self.cur_goal_place or self.last_select_point_info

		if not point_info then return end

		self:selectPoint(point_info.id, point_info.navType, true)
		self:turnToPointArea(point_info.id, point_info.navType)
	end, TOUCH_EVENT_ENDED)

	self.widget_panel.btn_ship:addEventListener(function()
		self:turnToCurArea()
	end, TOUCH_EVENT_ENDED)

	self.widget_panel.btn_back:addEventListener(function()
		self:turnToCurArea()
		self.point_info_panel:setTouch(true)
		audioExt.playEffect(music_info.EX_DRAGMAP.res, false)
	end, TOUCH_EVENT_ENDED)

	self.help_layer.btn_tips:addEventListener(function()
		if self.help_layer.isShow then
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:helpBtnCallBack(false)
		else
			self:helpBtnCallBack(true)
		end
	end,TOUCH_EVENT_ENDED)

	self.widget_panel.btn_worldmap:addEventListener(function()
		if self.is_go_explore then return end --点击出海按钮时，不给显示世界地图
		self:turnToWorldExt()
		self.point_info_panel:setTouch(false)
		sound = music_info.EX_DRAGMAP

		self:helpBtnCallBack(false)
		self:setVisibleOfWorldMissionPanel(false)
		audioExt.playEffect(music_info.EX_DRAGMAP.res, false)
	end,TOUCH_EVENT_ENDED)

	self.widget_panel.btn_go:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local teamData = getGameData():getTeamData()

		if not getGameData():getBuffStateData():IsCanGoExplore(true) then
			return
		end

		if teamData:isInTeam() and not teamData:isTeamLeader() then
			local Alert = require("ui/tools/alert")
			local uiWord = require("game_config/ui_word")
			Alert:showAttention(uiWord.LEAVE_TEAM_TIP, function()
				local teamData = getGameData():getTeamData()
				teamData:askLeaveTeam()
			end)
			return
		end

		local point_info = self.cur_select_point_info

		if self.go_now then
			point_info = nil
			self.go_now = false
		end
		
		if point_info and point_info.id and point_info.navType and point_info.navType ~= EXPLORE_NAV_TYPE_OTHER then
			if point_info.navType == EXPLORE_NAV_TYPE_TIME_PIRATE then
				if not getGameData():getExplorePirateEventData():getPirateByCfgId(point_info.id) then
					ClsAlert:showAttention(ui_word.THIS_POINT_IS_MISS, nil, nil, nil, {hide_cancel_btn = true})
					local area_id = getGameData():getExploreMapData():getCurAreaId()
					self:selectPoint(area_id, EXPLORE_NAV_TYPE_OTHER)
					return
				end
			end
			
			if not tolua.isnull(self) then
				self.widget_panel.btn_go.has_clicked = true
				self:btnGoNowListener(point_info.id, point_info.navType)
			end
			return
		end
		self.widget_panel.btn_go.has_clicked = true
		local portData = getGameData():getPortData()
		local port_id = portData:getPortId() -- 当前港口id
		local exploreData = getGameData():getExploreData()
		exploreData:setTargetPort(port_id)
		self:btnGoSailingListener()
	end,TOUCH_EVENT_ENDED)
	
	local btn_transfer = self.widget_panel.btn_transfer
	btn_transfer.last_time = 0
	btn_transfer:addEventListener(function()
		if self.cur_select_point_info and self.cur_select_point_info.id and self.cur_select_point_info.navType then
			local type_n = nil
			if self.cur_select_point_info.navType == EXPLORE_NAV_TYPE_PORT then type_n = EXPLORE_TRANSFER_TYPE.PORT end
			if self.cur_select_point_info.navType == EXPLORE_NAV_TYPE_RELIC then type_n = EXPLORE_TRANSFER_TYPE.RELIC end
			if self.cur_select_point_info.navType == EXPLORE_NAV_TYPE_WHIRLPOOL then type_n = EXPLORE_TRANSFER_TYPE.WHIRLPOOL end
			
			if type_n then
				getGameData():getExploreData():askExploreTransfer(type_n, self.cur_select_point_info.id, function()
							if not tolua.isnull(btn_transfer) then
								btn_transfer.last_time = CCTime:getmillistimeofCocos2d()
							end
						end)
			end
		end
	end, TOUCH_EVENT_ENDED)

	self.top_border_btn:regCallBack(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		self.drag_out_area_y = 0

		self:turnToDragArea((self.area_map_dic[explore_map_data:getCurClickAreaId()]).base.around_areas[1])
	end)
	self.top_border_btn:setIsAcceptTouchCallback(function()
		if self.worldmap_show then return false end
		return true
	end)

	self.bottom_border_btn:regCallBack(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		self.drag_out_area_y = 1

		self:turnToDragArea((self.area_map_dic[explore_map_data:getCurClickAreaId()]).base.around_areas[2])
	end)
	self.bottom_border_btn:setIsAcceptTouchCallback(function()
		if self.worldmap_show then return false end
		return true
	end)

	self.left_border_btn:regCallBack(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		self.drag_out_area_x = 1

		self:turnToDragArea((self.area_map_dic[explore_map_data:getCurClickAreaId()]).base.around_areas[3])
	end)
	self.left_border_btn:setIsAcceptTouchCallback(function()
		if self.worldmap_show then return false end
		return true
	end)

	self.right_border_btn:regCallBack(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		self.drag_out_area_x = 0

		self:turnToDragArea((self.area_map_dic[explore_map_data:getCurClickAreaId()]).base.around_areas[4])
	end)
	self.right_border_btn:setIsAcceptTouchCallback(function()
		if self.worldmap_show then return false end
		return true
	end)

	RegTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT, function(id, nav_type)
		if tolua.isnull(self) then return end
		self.cur_goal_place = {id = id, navType = nav_type}
		self:selectPoint(id, nav_type)
	end)

	RegTrigger(EVENT_EXPLORE_HIDE_GOAL_PORT, function()
		if tolua.isnull(self) then return end
		self:selectPoint(nil, nil, true)
	end)

	RegTrigger(EVENT_EXPLORE_CANCEL_GOAL_PORT, function()
		if tolua.isnull(self) then return end
		self.cur_goal_place = nil
	end)

	RegTrigger(EVENT_MISSION_UPDATE, function()
		if tolua.isnull(self) then return end
		self:resetPoint(EXPLORE_NAV_TYPE_PORT)
	end)

	RegTrigger(EVENT_PORT_LIST_UPDATE, function()
		if tolua.isnull(self) then return end
		self:resetPoint(EXPLORE_NAV_TYPE_PORT)
	end)

	RegTrigger(EVENT_PORT_PVE_CPDATA_ALL_UPDATE, function(port_datas, stronghold_datas)
		if tolua.isnull(self) then return end
		self:resetPoint(EXPLORE_NAV_TYPE_PORT)
		self:resetPoint(EXPLORE_NAV_TYPE_SH)
	end)

	RegTrigger(EVENT_PORT_PVE_CPDATA_PORT_UPDATE, function(port_id)
		if tolua.isnull(self) then return end
		self:updatePoint(port_id, EXPLORE_NAV_TYPE_PORT)
	end)

	RegTrigger(EVENT_PORT_PVE_CPDATA_SH_UPDATE, function(stronghold_id)
		if tolua.isnull(self) then return end
		self:updatePoint(stronghold_id, EXPLORE_NAV_TYPE_SH)
	end)

	RegTrigger(EVENT_PORT_SAILOR_FOOD, function(info)
		if tolua.isnull(self) then return end
		if self.cur_select_point_info and self:isShowMax() then
			if info and (self.cur_select_point_info.navType == EXPLORE_NAV_TYPE_TIME_PIRATE or self.cur_select_point_info.navType == EXPLORE_NAV_TYPE_MINERAL_POINT) then --临时代码，保证食物更新不会向后端请求东东
				return
			end
			self:reSelectPoint(self.cur_select_point_info.id, self.cur_select_point_info.navType)
		end
	end)

	RegTrigger(EVENT_PORT_MARKET_PORT_STORE2, function(business_ports)
		if tolua.isnull(self) then return end
		for k, v in pairs(business_ports) do
			self:updatePoint(v, EXPLORE_NAV_TYPE_PORT)
		end
	end)

	RegTrigger(EVENT_PORT_MARKET_PORT_CARGO2, function(business_ports)
		if tolua.isnull(self) then return end
		self:resetPoint(EXPLORE_NAV_TYPE_PORT)

		if self.show_max then
			local select_point_id = explore_map_data:getTaskMapSelectPortId()
			if select_point_id and self.cur_select_point_info then
				self:reSelectPoint(self.cur_select_point_info.id, self.cur_select_point_info.navType)
				return
			end
			local market_data = getGameData():getMarketData()
			local need_good_port_id = market_data:getMinDistancePortId()
			if need_good_port_id then
				self:selectPoint(need_good_port_id, EXPLORE_NAV_TYPE_PORT)
			end
		end
	end)

	RegTrigger(EVENT_PORT_PVE_CPDATA_RELIC_UPDATE, function(relic_id)
		if tolua.isnull(self) then return end
		self:updatePoint(relic_id, EXPLORE_NAV_TYPE_RELIC)
	end)

	RegTrigger(EVENT_PORT_PVE_CPDATA_RELIC_OPEN, function()
		if tolua.isnull(self) then return end
		self:resetPoint(EXPLORE_NAV_TYPE_RELIC)
	end)

	RegTrigger(EVENT_PORT_GOOD_INFO_UPDATE, function(port_id)
		if tolua.isnull(self) then return end
		self:updatePoint(port_id, EXPLORE_NAV_TYPE_PORT)
		self:reSelectPoint(port_id, EXPLORE_NAV_TYPE_PORT)
	end)

	RegTrigger(EVENT_PORT_OWNER_INFO_UPDATE, function(port_id)
		if tolua.isnull(self) then return end
		self:updatePoint(port_id, EXPLORE_NAV_TYPE_PORT)
	end)

	self:initFinish()
end

ExploreMap.btnCloseListener = function(self)
	ExploreMap.super.btnCloseListener(self)

	local port_data = getGameData():getPortData()
	port_data:setExploreDiffPowerInfo() --清除港口状态变化标志

	if isExplore then

	else
		local explore_data = getGameData():getExploreData()
		explore_data:setTreasureNavgation(nil) --清除藏宝图导航标志
	end
end

ExploreMap.onTouchBegan = function(self, x, y, isMutilTouchMode)
	-- if getGameData():getTeamData():isLock() then
	--     return false
	-- end
	local result = ExploreMap.super.onTouchBegan(self, x, y, isMutilTouchMode)
	self.drag_out_area_flag = false
	self.drag_out_area_id = 0
	return result
end

ExploreMap.onTouchEndedDrag = function(self, x, y, isMutilTouchMode)
	if self.touchBeginPoint and not self.drag_out_area_flag then
		local distance = self.drag_out_area_dis
		local is_drag = (self.is_horizontal and math.abs(self.touchBeginPoint.x - self.touchLastPoint.x) > distance) or 
			(not self.is_horizontal and math.abs(self.touchBeginPoint.y - self.touchLastPoint.y) > distance)

		if self.drag_out_area_id > 0 and is_drag then
			self.drag_out_area_flag = true
			self:turnToDragArea(self.drag_out_area_id)
		end
	end
end

ExploreMap.createPoint = function(self, point_info)
	local res_key_infos = point_info.res_key_infos
	local res = nil

	local layer_scale = self.map_layer:getScale()
	local point_scale = 0
	if layer_scale ~= 0 then
		point_scale = 1 / layer_scale
	end

	if self.worldmap_show and point_info.nav_type == EXPLORE_NAV_TYPE_WORLD_MISSION then
		point_scale = point_scale/2
	end

	if not self:isShowMax() and point_info.nav_type ~= EXPLORE_NAV_TYPE_RELIC then
		point_scale = point_scale * 0.75
	elseif point_info.nav_type == EXPLORE_NAV_TYPE_RELIC and not self.worldmap_show then
		point_scale = 1.4 / layer_scale
	end

	local point_is_visible = self.point_visible_dic[point_info.nav_type]
	if point_is_visible == nil then
		point_is_visible = true
	end
	local point_node = nil
	local point_pos = exploreMapUtil.cocosToTile(point_info.pos, self.map_height, self.map_tile_size)
	local point_pos_tmp = nil
	local point_node_first = nil
	local point_node_first_center_pos = ccp(0, 0)
	local point_nodes = {}
	local point_pos_off = ccp(0, 0)
	local point_scale_temp = nil
	for k,v in ipairs(res_key_infos) do
		if v.pos_off then
			point_pos_off.x = v.pos_off[1]
			point_pos_off.y = v.pos_off[2]
		else
			point_pos_off.x = 0
			point_pos_off.y = 0
		end
		point_scale_temp = point_scale

		if v.scale then
			point_scale_temp = v.scale
		else
			point_scale_temp = 1
		end

		local opacity = v.opacity or 255
		local tag = v.tag or 0
		res = self.POINT_RES[v.res]
		if point_info.nav_type == EXPLORE_NAV_TYPE_WORLD_MISSION then
			point_node = self:getSpriteById(point_info.id)
		else
			point_node = display.newSprite(res[1])
		end
		if not point_node_first then
			point_node:setScale(point_scale * point_scale_temp)
			point_node:setPosition(point_pos.x + point_pos_off.x, point_pos.y + point_pos_off.y)
			point_node:setVisible(point_is_visible)

			--if point_info.nav_type == EXPLORE_NAV_TYPE_SALVE_SHIP then
			self.point_name_layer:addChild(point_node)
			--end
			point_nodes[#point_nodes + 1] = point_node
			point_node_first = point_node
			point_node_first_center_pos.x = point_node_first:getContentSize().width / 2
			point_node_first_center_pos.y = point_node_first:getContentSize().height / 2
		else
			point_node:setPosition(point_node_first_center_pos.x + point_pos_off.x, point_node_first_center_pos.y + point_pos_off.y)
			point_node:setScale(point_scale_temp)
			point_node_first:addChild(point_node)
		end
		if #res > 1 then
			point_node = display.newSprite(res[2])
			point_node:setPosition(point_node_first_center_pos.x + point_pos_off.x, point_node_first_center_pos.y + point_pos_off.y)
			point_node:setScale(point_scale_temp)
			point_node_first:addChild(point_node)
		end
		point_node:setCascadeOpacityEnabled(false)
		point_node:setOpacity(opacity)
		point_node:setTag(tag)
	end

	if not point_node_first then
		return
	end

	local lbl_name_color = point_info.name_color or ccc3(dexToColor3B(COLOR_WHITE_STROKE))

	if point_info.name and point_info.name_off then
		local name_pos = ccp(point_node_first_center_pos.x + point_info.name_off[1], point_node_first_center_pos.y + point_info.name_off[2] - 32)
		point_node = createBMFont({text = point_info.name, size = 14, fontFile = FONT_CFG_1, color = lbl_name_color, x = name_pos.x, y = name_pos.y})

		local name_size = point_node:getContentSize()
		if point_info.name_ext_res and point_info.name_ext_res ~= "" then
			local name_ext = display.newSprite(self.POINT_RES[point_info.name_ext_res][1])
			name_ext:setAnchorPoint(ccp(0, 0.5))
			name_ext:setPosition(ccp(name_pos.x + name_size.width/2, name_pos.y))
			point_node_first:addChild(name_ext)
		end

		point_node_first:addChild(point_node)
		if point_info.level then
			point_node = createBMFont({text = "Lv."..(point_info.level), size = 12, fontFile = FONT_CFG_1, color = lbl_name_color,
				x = point_node_first_center_pos.x, y = point_node_first_center_pos.y - 19})
			point_node_first:addChild(point_node)
		end
		if point_info.owner_name and point_info.owner_name ~= "" then
			point_node = createBMFont({text = string.format(ui_word.NAME_BOX, (point_info.owner_name..ui_word.STR_GUILD_NAME)), size = 12, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_LIGHT_BLUE_STROKE)),
				x = name_pos.x, y = name_pos.y - 15})
			point_node_first:addChild(point_node)
		end

		if self:isShowMax() and point_info.turned_time and point_info.turned_time ~= 0 then
			local lbl_turned_time = createBMFont({text = dataTools:getTimeStrNormal(point_info.turned_time , false , true), size = 12, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_LIGHT_BLUE_STROKE))})
			point_node_first:addChild(lbl_turned_time)
			local y = name_pos.y - 30
			if not point_info.owner_name then
				y = name_pos.y - 15
			end
			lbl_turned_time:setPosition(ccp(name_pos.x, y))

			local arr_action = CCArray:create()
			arr_action:addObject(CCDelayTime:create(1))
			arr_action:addObject(CCCallFunc:create(function()
				point_info.turned_time = point_info.turned_time - 1
				lbl_turned_time:setString(dataTools:getTimeStrNormal(point_info.turned_time , false , true))
				if point_info.turned_time == 0 then
					lbl_turned_time:removeFromParentAndCleanup(true)
					lbl_turned_time:stopAllActions()
					return
				end
			end))
			lbl_turned_time:stopAllActions()
			lbl_turned_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
		end
	end

	if point_info.percent and point_info.percent_off then
		local per_bg_spr = display.newSprite("#map_hp_bar_bg.png")
		point_node_first:addChild(per_bg_spr)
		per_bg_spr:setAnchorPoint(ccp(0.5, 0.5))
		local per_bg_size = per_bg_spr:getContentSize()
		local hp_bar = CCProgressTimer:create(display.newSprite("#map_hp_bar.png"))
		hp_bar:setType(kCCProgressTimerTypeBar)
		hp_bar:setMidpoint(ccp(0,1))
		hp_bar:setBarChangeRate(ccp(1, 0))
		hp_bar:setPercentage(point_info.percent)
		hp_bar:setPosition(ccp(per_bg_size.width/2, per_bg_size.height/2))
		per_bg_spr:addChild(hp_bar)
		per_bg_spr:setPosition(point_info.percent_off.x, point_info.percent_off.y)
	end

	return point_nodes
end

ExploreMap.updatePoint = function(self, id, nav_type)
	local sub_point_dic = self.point_dic[nav_type]
	if sub_point_dic and sub_point_dic[id] then
		local point_nodes = sub_point_dic[id]
		for k,v in ipairs(point_nodes) do
			if not tolua.isnull(v) then
				v:removeFromParentAndCleanup(true)
			end
		end
	end
	if not sub_point_dic then
		self.point_dic[nav_type] = {}
	end
	self.point_dic[nav_type][id] = nil
	self.point_dic[nav_type][id] = self.NAVTYPE_TO_POINT_UPDATE[nav_type](self, id)
end

ExploreMap.updatePortPoint = function(self, id)
	local info = port_info[id]
	if not info then
		return
	end
	local port_type = info.type --港口类型

	local explore_map_data = getGameData():getExploreMapData()
	local mapAttrs = getGameData():getWorldMapAttrsData()
	if mapAttrs:isNewPort(id) then--or info.areaId ~= explore_map_data:getCurPointAreaId() then
		return
	end

	local taskPort = explore_map_data:getTaskPort()
	if not mapAttrs:isMapOpenPort(id) then
		if not taskPort[id] then
			return --不是任务并且没进过的，就不显示
		end
	end

	local port_battle_data = getGameData():getPortBattleData()
	local explore_occupy_info = port_battle_data:getExploreOccupyInfo(id)

	local port_status = nil
	local port_data = getGameData():getPortData()

	local power_info = port_data:getPortPowerInfoById(id)
	local diff_power_info = port_data:getExploreDiffPowerInfo()
	if power_info then
		port_status = power_info.port_status
	end
	local pos = ccp(info.port_pos[1], info.port_pos[2])
	local port_type_flag = nil
	local port_pve_data = getGameData():getPortPveData()
	local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_PORT,res_key_infos = {}, pos = pos, name_ext_res = ""}

	if port_status and self.bigPortLayer:tileGIDAt(pos) ~= 0 or self.smallPortLayer:tileGIDAt(pos) ~= 0 then
		if port_type == "pub" then
			port_type_flag = "culture"
		elseif port_type == "ship" then
			port_type_flag = "industry"
		elseif port_type == "market" then
			port_type_flag = "business"
		end


		--商品存量
		local market_data = getGameData():getMarketData()
		local cur_invest_step = market_data:getInvestStepByPortId(id)
		local cur_market_goods_num_rate = 0
		local cur_market_goods_num, max_market_goods_num = market_data:getStoreGoodNumByPortId(id)
		local goods_rest_num = 0
		local max_rate_sp = 8
		if max_market_goods_num > 0 then
			cur_market_goods_num_rate = Math.floor(100 * cur_market_goods_num / max_market_goods_num)
		end
		goods_rest_num = Math.ceil(cur_market_goods_num_rate / 12.5)
		if goods_rest_num > max_rate_sp then
			goods_rest_num = max_rate_sp
		end

		local old_port_data = port_status
		if not table.is_empty(diff_power_info) and diff_power_info[id] and diff_power_info[id][1] then
			old_port_data = diff_power_info[id][1].port_status
		end
		if goods_rest_num >= 0 and goods_rest_num <= max_rate_sp then
			cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = string.format("%d_goods_%d", old_port_data, goods_rest_num)}
		end
		
		if taskPort[id] then
			cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "task_effect", pos_off = {25, -20}}
		else
			local is_port_demand_good = market_data:isPortDemandCargoGood(id)
			if is_port_demand_good then --推荐贸易港口
				cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "good_port", pos_off = {25, -20}}
			end

			if market_data:isHotSellPort(id) then
				local x = 25
				if is_port_demand_good then
					x = 50
				end
				cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "hot_sell", pos_off = {0, 13}}
			end
		end

	
		local res = "empty"
		local power_id = power_info.power_id
		if not table.is_empty(diff_power_info) and diff_power_info[id] and diff_power_info[id][1] then
			power_id = diff_power_info[id][1].power_id
		end
		if port_power[power_id] then
			res = port_power[power_id].flagship_map_res
		end
		local force_node_tag = #cpoint_info.res_key_infos + 1
		cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = res, scale = 0.8, pos_off = {0, -2}, opacity = 204, tag = force_node_tag}
		cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = string.format("%d_%s", old_port_data, port_type_flag)}

		local investData = getGameData():getInvestData()
		local invest_info = investData:getInvestDataByPortId(id)
		if invest_info ~= nil then
			if invest_info.investSailor ~= 0 then
				-- cpoint_info.name_ext_res = "port_appoint" -- 去除地图小皇冠
				cpoint_info.turned_time = invest_info.remainTime
			end
		end

		cpoint_info.level = cur_invest_step
		cpoint_info.name = info.name
		cpoint_info.name_off = {info.name_off[1], info.name_off[2]}

		local port_power_info = port_data:getPortPowerInfo()
		if port_power_info[id].port_status == PORT_POWER_STATUS_HOSTILITY then
			 cpoint_info.name_color = ccc3(dexToColor3B(COLOR_RED_STROKE))
		end

		if mapAttrs:isPreTaskOpenPort(id) then
			cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "port_pre_task", scale = 1.6}
		end

		cpoint_info.owner_name = explore_occupy_info.group_name
	
		local point_node = self:createPoint(cpoint_info)

		local special_effects = port_power_info[id].special_effects
		local diff_power_info = port_data:getExploreDiffPowerInfo()
		if not table.is_empty(diff_power_info) and special_effects then
			point_node[1]:stopAllActions()
			local arr_action = CCArray:create()
			arr_action:addObject(CCDelayTime:create(1))
			arr_action:addObject(CCCallFunc:create(function()
				local port_data = getGameData():getPortData()
				port_data:setExploreDiffPowerInfo() --清除港口状态变化标志
				local pos_x = point_node[1]:getContentSize().width / 2
				local pos_y = point_node[1]:getContentSize().height / 2
				composite_effect.new(special_effects[1], pos_x, pos_y, point_node[1])
				composite_effect.new(special_effects[2], pos_x, pos_y, point_node[1])
			end))
			point_node[1]:runAction(CCSequence:create(arr_action))
		end

		local forceNode = nil
		for k, v in pairs(point_node) do
			forceNode = v:getChildByTag(force_node_tag)
			if not tolua.isnull(forceNode) then
				break
			end
		end
		if not tolua.isnull(forceNode) then
			
			if not table.is_empty(diff_power_info) and diff_power_info[id] and diff_power_info[id][1] then
				local new_power_id = diff_power_info[id][2].power_id
				if new_power_id ~= power_id then
					local arr_action = CCArray:create()
			
					arr_action:addObject(CCFadeOut:create(1))
					arr_action:addObject(CCCallFunc:create(function()
						if port_power[new_power_id] then
							local new_force_node = display.newSprite("#" .. port_power[new_power_id].flagship_map_res)
							new_force_node:setScale(0.8)
							local pos = ccp(forceNode:getPositionX(), forceNode:getPositionY())
							new_force_node:setPosition(pos)
							new_force_node:runAction(CCFadeIn:create(1))
							forceNode:getParent():addChild(new_force_node, -1)
						end
						forceNode:removeFromParent()
					end))
					forceNode:runAction(CCSequence:create(arr_action))
				end
			end
		end
		return point_node
	end
end

--更新悬赏任务沉船
ExploreMap.updateSalveShipPoint = function(self, id)
	local missionDataHandler = getGameData():getMissionData()
	local mission_info = missionDataHandler:getHotelRewardAccept()


	--沉船字段
	if mission_info and mission_info.json_info and mission_info.json_info.wreckInfo and mission_info.status ~= STATUS_FINISHED then
		local pos_x = mission_info.json_info["wreckInfo"]["map_positon_x"] --从任务的json里读
		local pos_y = mission_info.json_info["wreckInfo"]["map_positon_y"]

		local pos = ccp(pos_x, pos_y)

		local explore_map_data = getGameData():getExploreMapData()
		--转化坐标
		local salve_ship_pos = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
		local cur_area_info = self.area_map_dic[explore_map_data:getCurPointAreaId()]
		-- if not cur_area_info or not cur_area_info.mapRect:containsPoint(salve_ship_pos) then
		-- 	return
		-- end
		local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_SALVE_SHIP, res_key_infos = {}, pos = pos}

		cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "ship_wrecks"}

		local point = self:createPoint(cpoint_info)
		return point
	end

	--战斗字段
	if mission_info and mission_info.json_info and mission_info.json_info.battleInfo and mission_info.status ~= STATUS_FINISHED then
		local pos_x = mission_info.json_info["battleInfo"]["map_positon_x"] --从任务的json里读
		local pos_y = mission_info.json_info["battleInfo"]["map_positon_y"]

		local pos = ccp(pos_x, pos_y)

		local explore_map_data = getGameData():getExploreMapData()
		--转化坐标
		local salve_ship_pos = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
		local cur_area_info = self.area_map_dic[explore_map_data:getCurPointAreaId()]

		local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_SALVE_SHIP, res_key_infos = {}, pos = pos}

		cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "ship_wrecks"}


		local point = self:createPoint(cpoint_info)

		return point
	end
end

ExploreMap.updateStrongHoldPoint = function(self, id)
	local info = pve_stronghold_info[id]
	if not info then
		return
	end
	local portPveData = getGameData():getPortPveData()
	local pveInfo = portPveData:getStrongHoldPveInfo(id)
	if not pveInfo then
		return
	end
	local status = pveInfo.status
	local pos = ccp(info.point_pos[1], info.point_pos[2])
	local explore_map_data = getGameData():getExploreMapData()
	local sh_pos = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
	local cur_area_info = self.area_map_dic[explore_map_data:getCurPointAreaId()]
	if not cur_area_info or not cur_area_info.mapRect:containsPoint(sh_pos) then
		return
	end

	local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_SH, res_key_infos = {}, pos = pos}
	if self.strongHoldLayer:tileGIDAt(pos) ~= 0 then
		local isMeetLevel,_ = portPveData:isStrongHoldMeetLevel(id)
		if portPveData:isStrongHoldOpen(id) then
			cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "enemy_stronghold"}
			if portPveData:isStrongHoldLock(id) or not isMeetLevel then
				cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "forbidden_stronghold"}
			end
		elseif portPveData:isStrongHoldCool(id) then
			cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "enemy_stronghold"}
			cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "forbidden_stronghold"}
		end
		return self:createPoint(cpoint_info)
	end
end

ExploreMap.updateWhirlPoolPoint = function(self, id)
	local info = explore_whirlpool[id]
	if not info then
		return
	end
	local pos = ccp(info.map_pos[1], info.map_pos[2])
	local explore_map_data = getGameData():getExploreMapData()
	local wp_pos = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
	local cur_area_info = self.area_map_dic[explore_map_data:getCurPointAreaId()]
	if not cur_area_info or not cur_area_info.mapRect:containsPoint(wp_pos) then
		return
	end
	local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_WHIRLPOOL, res_key_infos = {}, pos = pos}
	if self.whirlPoolLayer:tileGIDAt(pos) ~= 0 then
		cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "goal_whirlpool"}
		cpoint_info.name = info.name
		cpoint_info.name_off = {info.map_name_pos[1], info.map_name_pos[2]}
		return self:createPoint(cpoint_info)
	end
end

--组装遗迹信息
ExploreMap.assembRelicInfo = function(self, id, relic_info, info)
	local status_n = relic_info.status
	if not status_n then
		return
	else
		local pos = ccp(info.coord[1], info.coord[2])
		local cpoint_info = {}
		cpoint_info.nav_type = EXPLORE_NAV_TYPE_RELIC
		cpoint_info.res_key_infos = {}
		cpoint_info.pos = pos
		cpoint_info.id = id
		cpoint_info.insertPoint = function(self, point_obj)
			if not point_obj then return end
			table.insert(self.res_key_infos, point_obj)
		end

		local point_obj = nil
		local collect_data = getGameData():getCollectData()
		if collect_data:isCanDigOrExplore(id) then
			point_obj = {res = "finish_relic", scale = 1}
		else
			point_obj = {res = "unfinish_relic", scale = 1}
		end
		cpoint_info:insertPoint(point_obj)
		return self:createPoint(cpoint_info)
	end
end

local cd_time = 3600
--组装探索事件信息
ExploreMap.assembEventInfo = function(self, id, info)
	local cpoint_info = {}
	local pos = ccp(info.coord[1], info.coord[2])
	cpoint_info.nav_type = EXPLORE_NAV_TYPE_RELIC
	cpoint_info.pos = pos
	cpoint_info.res_key_infos = {}
	cpoint_info.id = id
	cpoint_info.insertPoint = function(self, point_obj)
		if not point_obj then return end
		table.insert(self.res_key_infos, point_obj)
	end

	local point_obj = nil
	point_obj = {res = "map_boss", scale = 0.65}
	cpoint_info:insertPoint(point_obj)
	--利用通用的接口创建好点
	local point_tab = self:createPoint(cpoint_info)
	local boss_spr = point_tab[1]

	--特殊的要求在对应的模块写
	boss_spr.closeScheduler = function(self)
		if self.update_scheduler then
			scheduler:unscheduleScriptEntry(self.update_scheduler)
			self.update_scheduler = nil
		end
	end

	boss_spr.openScheduler = function(self)
		local reset_map = false
		local updateCount
		updateCount = function()
			if tolua.isnull(self) then
				self:closeScheduler()
				return
			end

			self:closeScheduler()
			local collect_data = getGameData():getCollectData()
			collect_data:removeRelicPirateEvent(id)
		end
		self:closeScheduler()
		self.update_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
	end

	local txt_parameter = {
		text = "00:00:00",
		size = 12,
		fontFile = FONT_CFG_1,
		color = ccc3(dexToColor3B(COLOR_RED_STROKE)),
		x = 20,
		y = -5,
	}
	local time_lab = createBMFont(txt_parameter)
	time_lab:setScale(1.5)
	boss_spr.time = time_lab
	boss_spr:addChild(time_lab)
	boss_spr:openScheduler()
	return point_tab
end

--更新单个遗迹显示call
ExploreMap.updateRelicPlacePoint = function(self, id)
	local info = relic_info[id]
	if not info then
		return
	else
		local collect_handle = getGameData():getCollectData()
		local relic_info = collect_handle:getRelicInfoById(id)
		if relic_info == nil then 
			return
		else
			return self:assembRelicInfo(id, relic_info, info)
		end
	end
end

-- 运镖
ExploreMap.updateConvoyMissionPoint = function(self, id)
	-- 如果还没开启世界任务开关 则不显示地图上的任务图标
	local status = getGameData():getOnOffData():isOpen(on_off_info.WORLD_MISSION.value)
	if not status then return end

	local cfg = require("game_config/loot/time_plunder_info")[id]
	if not cfg then return end
		local data = {}
	data.nav_type = EXPLORE_NAV_TYPE_CONVOY_MISSION
	data.pos = ccp(cfg.position_map[1],cfg.position_map[2])
	data.id = id
	data.name = cfg.name
	data.res_key_infos = {}
	data.res_key_infos[1] = {res = "convoy_mission",scale = 1}

	return self:createPoint(data)
end

-- 世界随机任务
ExploreMap.updateWorldMissionPoint = function(self, id)
	local cfg = world_mission_total_cfg[id]
	if not cfg then
		print("error ExploreMap updateWorldMissionPoint no cfg id",id)
		return
	end
	local pos = ccp(cfg.position_map[1],cfg.position_map[2])
	local wm_pos = exploreMapUtil.cocosToTile(pos,self.map_height,self.map_tile_size)
	local cur_area_info = self.area_map_dic[getGameData():getExploreMapData():getCurPointAreaId()]
	if not cur_area_info or not
		cur_area_info.mapRect:containsPoint(wm_pos) then
		-- 其他海域存在 世界随机任务 ---------
		-- self:setVisibleOfNotice(true)
		-- return
	end

	local cpoint_info = { nav_type = EXPLORE_NAV_TYPE_WORLD_MISSION,res_key_infos = {},pos = pos,id=id}
	cpoint_info.name = cfg.name
	cpoint_info.res_key_infos[#cpoint_info.res_key_infos+1] = {res = "world_mission", pos_off = {0,0} }
	-- create point succeed
	local point = self:createPoint(cpoint_info)

	local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
	ClsGuideMgr:tryGuide("PortMap")
	return point
end

ExploreMap.updateTimePiratePoint = function(self, id)
	local pirateEventDataHnader = getGameData():getExplorePirateEventData()
	local info = pirateEventDataHnader:getTimePirateConfig()[id]
	if not info then
		return
	end
	local pirate_data = pirateEventDataHnader:getPirateByCfgId(id, true)
	if not pirate_data then
		return
	end
	local cfg_item = pirate_data.cfg_item
	local pos = ccp(cfg_item.map_pos[1], cfg_item.map_pos[2])
	local explore_map_data = getGameData():getExploreMapData()
	local pirate_pos = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
	local cur_area_info = self.area_map_dic[explore_map_data:getCurPointAreaId()]
	if not cur_area_info or not cur_area_info.mapRect:containsPoint(pirate_pos) then
		if info.area_id ~= explore_map_data:getCurPointAreaId() then
			return
		end
	end

	local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_TIME_PIRATE, res_key_infos = {}, pos = pos}
	local res_str = "time_pirate_boss"
	cpoint_info.percent_off = {x = 24, y = 45}
	cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = res_str}
	cpoint_info.percent = pirateEventDataHnader:getPirateHpPercentByCfgId(id)

	local points = self:createPoint(cpoint_info)
	local base_spr = points[1]
	local cd_time = pirateEventDataHnader:getPirateCd(id)
	if base_spr and cd_time > 0 then
		local time_lab = createBMFont({text = "", size = 12, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
		time_lab:setPosition(ccp(cpoint_info.percent_off.x, 0))
		base_spr:addChild(time_lab)
		local repeat_act = UiCommon:getRepeatAction(1, function()
				if (not tolua.isnull(time_lab)) and (not tolua.isnull(time_lab)) then
					local cd_time = pirateEventDataHnader:getPirateCd(id)
					if cd_time > 0 then
						time_lab:setString(string.format("%ds",cd_time))
					else
						time_lab:removeFromParentAndCleanup(true)
						base_spr:stopAllActions()
					end
				end
			end)
		base_spr:runAction(repeat_act)
	end
	return points
end

ExploreMap.updateMineralPoint = function(self, id)
	local area_competition_data = getGameData():getAreaCompetitionData()
	local cfg_item = area_competition_data:getMineralPointConfig()[id]

	if not cfg_item then
		return
	end
	local pos = ccp(cfg_item.map_pos[1], cfg_item.map_pos[2])
	local explore_map_data = getGameData():getExploreMapData()
	local mineral_pos = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
	local cur_area_info = self.area_map_dic[explore_map_data:getCurPointAreaId()]
	if not cur_area_info or not cur_area_info.mapRect:containsPoint(mineral_pos) then
		if cfg_item.areaId ~= explore_map_data:getCurPointAreaId() then
			return
		end
	end

	local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_MINERAL_POINT, res_key_infos = {{res = "mineral_point_me"}}, pos = pos}

	local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
	local port = area_competition_data:getMineralPortInfoByCfgId(id)

	if my_guild_port_id and my_guild_port_id ~= port then
		cpoint_info.res_key_infos = {{res = "mineral_point_enemy"}}
	end

	if port == 0 then
		cpoint_info.res_key_infos = {{res = "mineral_point_neutral"}}
	end

	if area_competition_data:isOpen() then
		cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "hot_sell", pos_off = {0, 10},scale = 0.6}
	end

	--休战期满足等级才会显示图标，开战期则是不管等级
	if area_competition_data:isOpen() or area_competition_data:tryToMineralInteractive() then
		return self:createPoint(cpoint_info)
	end
end

ExploreMap.updataRewardPiratePoint = function(self, id)
	local pos = getGameData():getExploreRewardPirateEventData():getMapPos()
	if pos then
		local explore_map_data = getGameData():getExploreMapData()
		local pirate_pos = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
		local cur_area_info = self.area_map_dic[explore_map_data:getCurPointAreaId()]
		if not cur_area_info or not cur_area_info.mapRect:containsPoint(pirate_pos) then
			if cur_area_info.area_id ~= explore_map_data:getCurPointAreaId() then
				return
			end
		end
		local cpoint_info = {nav_type = EXPLORE_NAV_TYPE_REWARD_PIRATE, res_key_infos = {}, pos = pos}
		cpoint_info.res_key_infos[#cpoint_info.res_key_infos + 1] = {res = "reward_pirate"}
		return self:createPoint(cpoint_info)
	end
end

-- 海域奖励
ExploreMap.updateAreaReward = function(self, info)
	local cfg = area_info[info.areaId]

	local max = #cfg.port_invest_points

	local step = info.investStar + 1 
	step = step > max and max or step

	local str = string.format(ui_word.AREA_REWARD_CONDITION, info.investSum, cfg.port_invest_points[step])
	self.widget_panel.port_amount_num:setText(str)

	str = string.format(ui_word.AREA_REWARD_CONDITION, info.relicSum, cfg.relic_discover_points[step])
	self.widget_panel.relic_amount_num:setText(str)

	str = string.format(ui_word.AREA_REWARD_TIP, cfg.name, step, max)
	self.widget_panel.present_area:setText(str)

	self.widget_panel.btn_award.invest_finished = info.investSum >= cfg.port_invest_points[step]
	self.widget_panel.btn_award.relic_finished = info.relicSum >= cfg.relic_discover_points[step]

	local is_reward_ready = self.widget_panel.btn_award.invest_finished and self.widget_panel.btn_award.relic_finished
	if info.investStar >= max then
		is_reward_ready = false

		self.widget_panel.award_have_get:setVisible(true)
		self.widget_panel.btn_award:setTouchEnabled(false)
	else
		self.widget_panel.btn_award:setTouchEnabled(true)
	end

	self.widget_panel.red_point:setVisible(is_reward_ready)
	self.widget_panel.award_available:setVisible(is_reward_ready)
	if is_reward_ready then
		local reserve = 1

		local actions = {}
		actions[#actions + 1] = CCDelayTime:create(0.01)
		actions[#actions + 1] = CCCallFunc:create(function()
			local opacity = self.widget_panel.award_available:getOpacity()
			if opacity - 255/20*reserve < 0 then
				reserve = -1
			elseif opacity - 255/20*reserve > 255 then
				reserve = 1
			end
			self.widget_panel.award_available:setOpacity(opacity - 255/20*reserve)
		end)
		self.widget_panel.award_available:stopAllActions()
		self.widget_panel.award_available:setOpacity(255)
		self.widget_panel.award_available:runAction(CCRepeatForever:create(transition.sequence(actions)))
	end

	local areaRewardData = getGameData():getAreaRewardData()
	local area_reward_info = areaRewardData:getAreaReward(info.areaId)
	self.widget_panel.diamond_num:setVisible(true)
	self.widget_panel.diamond_num:setText(area_reward_info.port[step].gold + area_reward_info.relic[step].gold)
end

ExploreMap.resetPoint = function(self, nav_type)
	local sub_point_dic = self.point_dic[nav_type]
	if sub_point_dic then
		for k,v in pairs(sub_point_dic) do
			for i,j in pairs(v) do
				if not tolua.isnull(j) then
					j:removeFromParentAndCleanup(true)
				end
			end
		end
	end
	self.point_dic[nav_type] = {}
	return self.NAVTYPE_TO_POINT_RESET[nav_type](self)
end

ExploreMap.resetPortPoint = function(self)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local portList = mapAttrs:getPortList() --已开放港口
	local market_data = getGameData():getMarketData()
	local exploreMapData = getGameData():getExploreMapData()
	local need_update_ports = {}
	local need_invest_step = {}
	if portList then
		local cur_area_info = self.area_map_dic[exploreMapData:getCurPointAreaId()]
		for id , portInfo in pairs(portList) do
			local need_port = false
			local pos = ccp(port_info[id].port_pos[1], port_info[id].port_pos[2])
			if port_info[id].areaId == exploreMapData:getCurPointAreaId() then
				need_port = true
			else--判断是否相邻海域有衔接港口
				local _p = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
				if cur_area_info.mapRect:containsPoint(ccp(_p.x, _p.y)) then
					need_port = true
				end
			end
			if need_port then
				local sp = nil
				if self.bigPortLayer:tileGIDAt(pos) ~= 0 then
					sp = self.bigPortLayer:tileAt(pos)
				elseif self.smallPortLayer:tileGIDAt(pos) ~= 0 then
					sp = self.smallPortLayer:tileAt(pos)
				end
				if sp then
					self:updatePoint(id, EXPLORE_NAV_TYPE_PORT)
					need_update_ports[#need_update_ports + 1] = id
					if not market_data:getStoreGoodInfoByPortId(id) then
						need_invest_step[#need_invest_step + 1] = id
					end
				end
			end
		end
	end

	--这里临时处理在探索上重登后，小地图的点信息不完整问题
	if #need_invest_step > 0 then
		exploreMapData:askMapPortInfos(need_invest_step)
	end
	return need_update_ports
end

ExploreMap.resetStrongHoldPoint = function(self)
	local portPveData = getGameData():getPortPveData()
	local allInfos =  portPveData:getStrongHoldAllPveInfo()
	for k,v in pairs(allInfos) do
		self:updatePoint(k, EXPLORE_NAV_TYPE_SH)
	end
end

ExploreMap.resetWhirlPoolPoint = function(self)
	for i,v in pairs(explore_whirlpool) do
		--------------------------------------------------------
		-- modify By hal 2015-09-02, Type(BUG) - redmine 19518
		-- 漩涡的出现时机交给系统开关控制
		local open_sys_switch
		open_sys_switch = function( isOpen )
			-- body
			local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
			if isOpen and not tolua.isnull(explore_map) then
				explore_map:updatePoint( i, EXPLORE_NAV_TYPE_WHIRLPOOL );
			end
		end

		local onOffData = getGameData():getOnOffData();
		if onOffData ~= nil then
			local on_off_item = on_off_info[v.switch_key]
			onOffData:pushOpenBtn( on_off_item.value, { name = string.format( "Whirlpool_2d%0.2d", i ), callBack = open_sys_switch } );
		else
			assert( false, "getGameData():getOnOffData() == nil?????" );
		end
	end
end

ExploreMap.resetRelicPlacePoint = function(self)
	local exploreMapData = getGameData():getExploreMapData()
	local sp = nil
	local sp_done = nil
	local pos = nil
	local sp_new_pos_x, sp_new_pos_y = 0, 0
	local sp_new_pos_offset = (self.map_tile_size - self.map_tile_size * self.worldmap_relic_sp_scale) / 2
	for k, info in pairs(relic_info) do
		pos = ccp(info.coord[1], info.coord[2])
		if self.relicPlaceLayer:tileGIDAt(pos) ~= 0 then
			sp = self.relicPlaceLayer:tileAt(pos)
		end
		if self.relicDoneLayer:tileGIDAt(pos) ~= 0 then
			sp_done = self.relicDoneLayer:tileAt(pos)
		end
		if not tolua.isnull(sp) then
			if not self.has_init_worldmap_relic_scale then
				sp:setScale(self.worldmap_relic_sp_scale)
				--sp_new_pos = exploreMapUtil.cocosToTile(ccp(pos.x, pos.y), self.map_height, self.map_tile_size)
				sp_new_pos_x, sp_new_pos_y = sp:getPosition()
				sp:setPosition(sp_new_pos_x + sp_new_pos_offset, sp_new_pos_y + sp_new_pos_offset)
				if not tolua.isnull(sp_done) then
					sp_done:setScale(self.worldmap_relic_sp_scale)
					sp_new_pos_x, sp_new_pos_y = sp_done:getPosition()
					sp_done:setPosition(sp_new_pos_x + sp_new_pos_offset, sp_new_pos_y + sp_new_pos_offset)
				end
			end
			sp:setVisible(false)
			sp_done:setVisible(false)
			self:updatePoint(k, EXPLORE_NAV_TYPE_RELIC)
		end
	end
	self.has_init_worldmap_relic_scale = true
end

ExploreMap.resetTimePiratePoint = function(self)
	local infos =  getGameData():getExplorePirateEventData():getAllPirateInfo(true)
	for k, info in pairs(infos) do
		self:updatePoint(k, EXPLORE_NAV_TYPE_TIME_PIRATE)
	end
end

ExploreMap.resetMineralPoint = function(self)
	local infos = getGameData():getAreaCompetitionData():getMineralPointConfig()
	for k, _ in pairs(infos) do
		self:updatePoint(k, EXPLORE_NAV_TYPE_MINERAL_POINT)
	end
end

ExploreMap.resetRewardPiratePoint = function(self)
	self:updatePoint(1, EXPLORE_NAV_TYPE_REWARD_PIRATE)
end

-- 重置运镖点
ExploreMap.resetConvoyMissionPoint = function(self)
	-- 重置时候 删除已选择点
	if not tolua.isnull(self.goal_point_effect) then
		self.goal_point_effect:removeFromParentAndCleanup(true)
		self.goal_point_effect = nil
	end
	local list = getGameData():getConvoyMissionData():getShowList()
	for k,v in pairs(list) do
		self:updatePoint(v.id,EXPLORE_NAV_TYPE_CONVOY_MISSION)
	end
end

ExploreMap.resetWorldMissionPoint = function(self)
	-- 重置时候 删除已选择点
	if not tolua.isnull(self.goal_point_effect) then
		self.goal_point_effect:removeFromParentAndCleanup(true)
		self.goal_point_effect = nil
	end

	local data = getGameData():getWorldMissionData()
	local list = data:getShowInMapAndSeaList()
	for k,v in pairs(list) do
		if v.cfg then
			self:updatePoint(v.id, EXPLORE_NAV_TYPE_WORLD_MISSION)
		else
			print("error no cfg ExploreMap resetWorldMissionPoint")
		end
	end
end

ExploreMap.resetSalveShipPoint = function(self)
	self:updatePoint(1, EXPLORE_NAV_TYPE_SALVE_SHIP)
end

ExploreMap.setPointVisible = function(self, nav_type, is_visible)
	if self.point_visible_dic[nav_type] ~= nil and self.point_visible_dic[nav_type] == is_visible then return end
	self.point_visible_dic[nav_type] = is_visible
	local sub_point_dic = self.point_dic[nav_type]
	if sub_point_dic then
		for k,v in pairs(sub_point_dic) do
			for i,j in pairs(v) do
				if not tolua.isnull(j) then
					j:setVisible(is_visible)
				end
			end
		end
	end
end

ExploreMap.showPointInfo = function(self, id, nav_type, has_show)
	if not nav_type then return end

	local explore_map_data = getGameData():getExploreMapData()
	local nav_info = self.NAVTYPE_TO_CONFIG[nav_type]
	local point_name = ""
	if nav_info then
		local point_info = nav_info[id]
		if point_info then
			point_name = point_info.name
		end
	end

	self.widget_panel.purpose_name:setText(point_name)

	local port_data = getGameData():getPortData()
	if nav_type == EXPLORE_NAV_TYPE_PORT then
		local power_info = port_data:getPortPowerInfo()
		local port_status = power_info[id].port_status
		local color = ccc3(dexToColor3B(COLOR_GRASS_STROKE))
		if port_status == PORT_POWER_STATUS_HOSTILITY then
			color = ccc3(dexToColor3B(COLOR_RED_STROKE))
		end
		setUILabelColor(self.widget_panel.purpose_name, color)
	end

	self.widget_panel.cost_num:setText(0)
	self.widget_panel.distance_num:setText(0)
	setUILabelColor(self.widget_panel.cost_num, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))
	setUILabelColor(self.widget_panel.distance_num, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))

	self.go_now = false

	--立即出航
	local btn_sailing_str = nil
	if nav_type == EXPLORE_NAV_TYPE_OTHER or (not isExplore and nav_type == EXPLORE_NAV_TYPE_PORT and port_data:getPortId() == id) then
		self.go_now = true
		btn_sailing_str = ui_word.GO_SAILING
		self.widget_panel.btn_go:loadTextures("common_btn_orange3.png", "common_btn_orange4.png", "common_btn_orange3.png", UI_TEX_TYPE_PLIST)
	else
		btn_sailing_str = ui_word.NAVIGATE_NOW
		self.widget_panel.btn_go:loadTextures("common_btn_blue1.png", "common_btn_blue2.png", "common_btn_blue1.png", UI_TEX_TYPE_PLIST)
	end
	self.widget_panel.btn_go.btn_go_text:setText(btn_sailing_str)

	--预计距离
	local distance = explore_map_data:calcExploreExpectDis(id, nav_type)
	self.widget_panel.distance_num:setText(distance)
	--水手和补给
	local cur_food = getGameData():getSupplyData():getCurFood()
	--预计补给消耗
	local expect_food = explore_map_data:calcExploreExpectFood(id, nav_type, distance)
	self.widget_panel.cost_num:setText(expect_food)
	--可航行距离
	self.widget_panel.supply_num:setText(cur_food)
	--当前补给
	local can_go_distance = explore_map_data:calcExploreCanGoDis()
	self.widget_panel.capacity_num:setText(can_go_distance)

	if distance > can_go_distance then
		setUILabelColor(self.widget_panel.distance_num, ccc3(dexToColor3B(COLOR_RED_STROKE)))
	end
	if expect_food > cur_food then
		setUILabelColor(self.widget_panel.cost_num, ccc3(dexToColor3B(COLOR_RED_STROKE)))
	end

	if GameUtil.getRunningSceneType() == SCENE_TYPE_PORT then
		if nav_type == EXPLORE_NAV_TYPE_PORT then
			if not self.widget_panel.btn_go.has_clicked then
				self.widget_panel.btn_go:active()
			end
		elseif not self.widget_panel.btn_go.has_clicked then
			self.widget_panel.btn_go:active()
		end
	else
		if nav_type == EXPLORE_NAV_TYPE_OTHER then
			self.widget_panel.btn_go:disable()
		else
			self.widget_panel.btn_go:active()
		end
	end
	
	if (nav_type == EXPLORE_NAV_TYPE_PORT) and (getGameData():getPortData():getPortId() == id) and getGameData():getSceneDataHandler():isInPortScene() then
		self.widget_panel.btn_transfer:disable()
	elseif (not getGameData():getConvoyMissionData():isDoingMission()) 
		and (nav_type == EXPLORE_NAV_TYPE_PORT or nav_type == EXPLORE_NAV_TYPE_RELIC or nav_type == EXPLORE_NAV_TYPE_WHIRLPOOL) then
		self.widget_panel.btn_transfer:active()
		self.widget_panel.btn_transfer.last_time = 0
	else
		self.widget_panel.btn_transfer:disable()
	end
	getGameData():getExploreData():handleTansferBtn(self.widget_panel.btn_transfer, self:getViewName(), "#common_btn_orange3.png", 0.6)
	self.point_info_panel:updateUI(id, nav_type)
end

ExploreMap.setMapLayerScale = function(self, scale)
	if not ExploreMap.super.setMapLayerScale(self, scale) then
		return false
	end

	local pointScale = 0
	if scale ~= 0 then
		pointScale = 1 / scale
	end
	local shipScale = 0
	local goal_point_effect_scale = pointScale
	if self.show_max then
		if self.worldmap_show then
			shipScale = pointScale*0.3
		else
			shipScale = pointScale*0.7
		end
	else
		if self.is_cross_unknow_area then
			shipScale = pointScale*0.3
		else
			shipScale = pointScale*0.7
		end
	end
	self.ship:setScale(shipScale)
	self.ship:setScaleX(self.ship.angle_flag*shipScale)
	self.trace_obj:setScale(shipScale * 1.5)

	if self.worldmap_show then
		goal_point_effect_scale = self.worldmap_point_effect_scale
	end

	if not tolua.isnull(self.goal_point_effect) then
		self.goal_point_effect:setScale(goal_point_effect_scale)
	end

	for k1,v1 in pairs(self.point_dic) do
		for k2,v2 in pairs(v1) do
			for k3,v3 in pairs(v2) do
				if not tolua.isnull(v3) then
					v3:setScale(pointScale * (v3.scale_rate or 1))
				end
			end
		end
	end

	self.mission_pirate_layer:setIconScale(scale)
end

ExploreMap.btnGoSailingListener = function(self)
	self:showMin()
end

--立即起航
ExploreMap.btnGoNowListener = function(self, id, nav_type)
	getGameData():getExploreMapData():goMayChangeWhirlHandler(id, nav_type, params, function(whirl_id) --go_callback
		self:goMapChangeTarget(whirl_id, EXPLORE_NAV_TYPE_WHIRLPOOL)
	end, function() --no_change_callback
		self:goMapChangeTarget(id, nav_type)
	end, function() self.widget_panel.btn_go.has_clicked = false end)
end

ExploreMap.goMapChangeTarget = function(self, id, nav_type)
	local go_callback = function ()
		local exploreData = getGameData():getExploreData()
		if nav_type == EXPLORE_NAV_TYPE_SH then
			exploreData:setPortType(EX_PVE_TYPE_STRONGHOLD)
		elseif nav_type == EXPLORE_NAV_TYPE_PORT then
			exploreData:setPortType(EX_PVE_TYPE_PORT)
		end
		self.cur_goal_place = {id = id, navType = nav_type}

		self:showMin()
		EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = id, navType = nav_type})
	end
	local explore_map_data = getGameData():getExploreMapData()
	local distance = explore_map_data:calcExploreExpectDis(sid, nav_type)
	local can_go_distance = explore_map_data:calcExploreCanGoDis()
	if distance > 0.7*can_go_distance then
		local cancel_callback = function()
			self.widget_panel.btn_go.has_clicked = false
		end
		ClsAlert:showAttention(ui_word.TOO_FAR_TOAST, cancel_callback, cancel_callback, function()
			go_callback()
		end, {ok_text = ui_word.EXPLORE_SELECT_AGAIN, cancel_text = ui_word.GO_SAILING, use_orange_btn = true})
		return
	end
	go_callback()
end

ExploreMap.isCanMutilTouch = function(self)
	return not self:isShowWorldMax()
end

ExploreMap.clickMap = function(self, click_x, click_y)
	local click_pos = self.map_layer:convertToNodeSpace(ccp(click_x, click_y))
	local explore_map_data = getGameData():getExploreMapData()
	if self.worldmap_show then
		-- 检测是否点击到世界随机任务的图标 矩形框是否包含触摸点
		local points = self.point_dic[EXPLORE_NAV_TYPE_WORLD_MISSION]
		if points then
			local CCRectMake = CCRectMake

			for id,point in pairs(points) do
				point = point[1]
				local world_pos = point:convertToWorldSpace(ccp(0,0))
				local size = point:getContentSize()
				local scale = point:getScale()/4

				local rect = CCRectMake(0, 0, size.width*scale, size.height*scale)
				local x = click_x - world_pos.x
				local y = click_y - world_pos.y

				local is_touched = rect:containsPoint(ccp(x,y))
				if is_touched then

					local data = {}
					data.type = EXPLORE_NAV_TYPE_WORLD_MISSION
					data.id = id
					getUIManager():create("gameobj/explore/clsMissionTipUI", nil, data,nil,true)
					-- plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
					-- self:selectPoint(cm_id,EXPLORE_NAV_TYPE_CONVOY_MISSION)
					return true
				end
			end
		end

		local mapAttrs = getGameData():getWorldMapAttrsData()
		local relic_rect_info = mapAttrs:getRelicRectInfoByPixPos(click_pos)
		if relic_rect_info then
			local collectData = getGameData():getCollectData()
			local relic_id = relic_rect_info.id
			if collectData:isDiscoveryRelic(relic_id) then
				local area_id = relic_rect_info.area_id
				if area_id and area_id < 8  then
					self:turnToAreaExt(relic_rect_info.area_id, ccp(relic_rect_info.rect.origin.x, relic_rect_info.rect.origin.y))
				else
					self:setCurShowViewPortRect(self.show_areamap_viewport_rect)
					self:alignMapLayerToXY(relic_rect_info.rect.origin.x, relic_rect_info.rect.origin.y)
					self.widget_panel.info_panel:setVisible(true)
					self.point_info_panel:setVisible(true)
					if not tolua.isnull(self.world_mission_percent_panel) then
						self.world_mission_percent_panel:setVisible(false)
					end
				end
				if self.worldmap_show and not tolua.isnull(self.effect_layer) then
					self.effect_layer:setVisible(true)
				end
				self:selectPoint(relic_id, EXPLORE_NAV_TYPE_RELIC, true)
				return true
			end
		end

		if explore_map_data:isClickOpenArea(click_pos) then
			local cur_click_area_id = self:turnToCliArea(click_pos)
			self:selectPoint(cur_click_area_id, EXPLORE_NAV_TYPE_OTHER)
			return true
		end
	else
		if self:clickPoint(click_x, click_y) then
			return true
		end
		if self.cur_show_viewport_rect:containsPoint(ccp(click_x, click_y)) then
			local area_id = explore_map_data:getCurAreaId()
			local cur_click_area_id = explore_map_data:getCurClickAreaId()
			if cur_click_area_id and cur_click_area_id > 0 then
				area_id = cur_click_area_id
			end
			self:selectPoint(area_id, EXPLORE_NAV_TYPE_OTHER)

			if not isExplore then
				self.widget_panel.btn_go:loadTextures("common_btn_orange3.png", "common_btn_orange4.png", "common_btn_orange3.png", UI_TEX_TYPE_PLIST)
				self.widget_panel.btn_go.btn_go_text:setText(ui_word.GO_SAILING)

				self.go_now = true
			end
			return true
		end
	end
	return false
end

--点击地图上的点
ExploreMap.clickPoint = function(self, click_x, click_y)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local pos = self.map:convertToNodeSpace(ccp(click_x, click_y))
	local p = exploreMapUtil.tileToCocos(pos, self.map_height, self.map_tile_size)
	local point_nodes = nil
	if self.point_layer:isVisible() then
		if self.point_dic[EXPLORE_NAV_TYPE_PORT] and self.point_visible_dic[EXPLORE_NAV_TYPE_PORT] and mapAttrs:isPortPos(p) then
			--点击港口
			local port_id = mapAttrs:getIDByPos(p)
			point_nodes = self.point_dic[EXPLORE_NAV_TYPE_PORT][port_id]
			if point_nodes then
				plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
				return self:selectPoint(port_id, EXPLORE_NAV_TYPE_PORT, true)
			end
		end
		local sh_ids = mapAttrs:getShIdsByPos(p)
		if self.point_dic[EXPLORE_NAV_TYPE_SH] and self.point_visible_dic[EXPLORE_NAV_TYPE_SH] and sh_ids then
			--点击海上据点
			local portPveData = getGameData():getPortPveData()
			for k,v in ipairs(sh_ids) do
				if portPveData:isStrongHoldOpen(v) or portPveData:isStrongHoldCool(v) then
					point_nodes = self.point_dic[EXPLORE_NAV_TYPE_SH][v]
					if point_nodes then
						plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
						return self:selectPoint(v, EXPLORE_NAV_TYPE_SH, true)
					end
				end
			end
		end
		local relic_id = mapAttrs:getRelicIdByPos(p)
		if self.point_dic[EXPLORE_NAV_TYPE_RELIC] and self.point_visible_dic[EXPLORE_NAV_TYPE_RELIC] and relic_id then
			--点击遗迹
			local collectData = getGameData():getCollectData()
			point_nodes = self.point_dic[EXPLORE_NAV_TYPE_RELIC][relic_id]
			if point_nodes and collectData:isDiscoveryRelic(relic_id) then
				plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
				return self:selectPoint(relic_id, EXPLORE_NAV_TYPE_RELIC, true)
			end
		end
		local wm_id = mapAttrs:getWmIdByPos(p)
		if self.point_dic[EXPLORE_NAV_TYPE_WORLD_MISSION] and self.point_visible_dic[EXPLORE_NAV_TYPE_WORLD_MISSION] and wm_id then
			self:setVisibleOfWorldMissionPanel(true,wm_id)
			-- local data = {}
			-- data.type = EXPLORE_NAV_TYPE_WORLD_MISSION
			-- data.id = wm_id
			-- getUIManager():create("gameobj/explore/clsMissionTipUI", nil, data)
			plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
			-- self:selectPoint(wm_id,EXPLORE_NAV_TYPE_WORLD_MISSION)
			return true
		end
		local cm_id = mapAttrs:getCMIdByPos(p) -- 运镖
		if self.point_dic[EXPLORE_NAV_TYPE_CONVOY_MISSION] and self.point_visible_dic[EXPLORE_NAV_TYPE_CONVOY_MISSION] and cm_id then
			-- 如果还没开启世界任务开关 则不显示地图上的任务图标,也屏蔽点击后的tips显示
			local status = getGameData():getOnOffData():isOpen(on_off_info.WORLD_MISSION.value)
			if not status then return false end

			local data = {}
			data.type = EXPLORE_NAV_TYPE_CONVOY_MISSION
			data.id = cm_id
			getUIManager():create("gameobj/explore/clsMissionTipUI", nil, data,nil,true)
			-- plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
			self:selectPoint(cm_id,EXPLORE_NAV_TYPE_CONVOY_MISSION, true)
			return true
		end
		local wp_id = mapAttrs:getWpIdByPos(p)
		if self.point_dic[EXPLORE_NAV_TYPE_WHIRLPOOL] and self.point_visible_dic[EXPLORE_NAV_TYPE_WHIRLPOOL] and wp_id then
			--点击漩涡
			point_nodes = self.point_dic[EXPLORE_NAV_TYPE_WHIRLPOOL][wp_id]
			if point_nodes then
				plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
				return self:selectPoint(wp_id, EXPLORE_NAV_TYPE_WHIRLPOOL, true)
			end
		end
		local time_private_id = mapAttrs:getTimePirvateByPos(p)
		if self.point_dic[EXPLORE_NAV_TYPE_TIME_PIRATE] and self.point_visible_dic[EXPLORE_NAV_TYPE_TIME_PIRATE] and time_private_id then
			--时段海盗
			point_nodes = self.point_dic[EXPLORE_NAV_TYPE_TIME_PIRATE][time_private_id]
			if point_nodes then
				plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
				return self:selectPoint(time_private_id, EXPLORE_NAV_TYPE_TIME_PIRATE, true)
			end
		end
		-- local mineral_id = mapAttrs:getMineralPointByPos(p)
		-- if self.point_dic[EXPLORE_NAV_TYPE_MINERAL_POINT] and self.point_visible_dic[EXPLORE_NAV_TYPE_MINERAL_POINT] and mineral_id then
		-- 	point_nodes = self.point_dic[EXPLORE_NAV_TYPE_MINERAL_POINT][mineral_id]
		-- 	if point_nodes then
		-- 		plotVoiceAudio.playVoiceEffect("COMMON_BUTTON")
		-- 		return self:selectPoint(mineral_id, EXPLORE_NAV_TYPE_MINERAL_POINT)
		-- 	end
		-- end
	end
	return false
end

ExploreMap.selectPoint = function(self, id, nav_type, is_player_selected)
	if nav_type == EXPLORE_NAV_TYPE_OTHER then return end

	if isExplore and self.cur_select_point_info and not is_player_selected then
		id = self.cur_select_point_info.id
		nav_type = self.cur_select_point_info.navType
	end

	if not tolua.isnull(self.goal_point_effect) then
		self.goal_point_effect:removeFromParentAndCleanup(true)
		self.goal_point_effect = nil
	end

	if not (nav_type == EXPLORE_NAV_TYPE_WORLD_MISSION or nav_type == EXPLORE_NAV_TYPE_CONVOY_MISSION) then
		self:showPointInfo(id, nav_type, self.cur_select_point_info and self.cur_select_point_info.id == id)
		self.cur_select_point_info = nil
	end

	if not id or not nav_type then
		return false
	end

	local config = self.NAVTYPE_TO_CONFIG[nav_type]
	if not config then
		return false
	end
	local info = config[id]
	if not info then
		return false
	end

	self.cur_select_point_info = {id = id, navType = nav_type, goalPointX = 0, goalPointY = 0}
	self.last_select_point_info = self.cur_select_point_info

	local explore_map_data = getGameData():getExploreMapData()
	explore_map_data:setCurSelectPointInfo(self.cur_select_point_info)

	local port_pve_data = getGameData():getPortPveData()
	if nav_type == EXPLORE_NAV_TYPE_SH and not port_pve_data:isStrongHoldOpen(id) and not port_pve_data:isStrongHoldCool(id) then
		return false
	end
	if nav_type == EXPLORE_NAV_TYPE_RELIC and (not getGameData():getCollectData():isDiscoveryRelic(id)) then
		return false
	end
	if nav_type == EXPLORE_NAV_TYPE_TIME_PIRATE and (not getGameData():getExplorePirateEventData():hasPirateByCfgId(id)) then
		return false
	end

	local _pos = self.NAVTYPE_TO_CONFIG_POS[nav_type](self, id)
	local _p = nil
	if not _pos then
		return false
	end
	_p = exploreMapUtil.cocosToTile(ccp(_pos[1], _pos[2]), self.map_height, self.map_tile_size)

	self.cur_select_point_info.goalPointX = _p.x
	self.cur_select_point_info.goalPointY = _p.y

	self.goal_point_effect = CCArmature:create("tx_0052")
	local armatureAnimation = self.goal_point_effect:getAnimation()
	armatureAnimation:playByIndex(0)
	local goalEffectScale = 0
	if not self.worldmap_show then
		local layerScale = self.map_layer:getScale()
		if layerScale ~= 0 then
			goalEffectScale = 1/layerScale
		end
		if not self:isShowMax() then
			goalEffectScale = goalEffectScale*0.8
		end
	else
		goalEffectScale = self.worldmap_point_effect_scale
		if nav_type == EXPLORE_NAV_TYPE_RELIC then
			goalEffectScale = self.relic_worldmap_effect_scale
		end
	end
	self.goal_point_effect:setScale(goalEffectScale)
	self.goal_point_effect:setPosition(ccp(_p.x, _p.y))
	self.effect_layer:addChild(self.goal_point_effect, -1)

	return true
end

ExploreMap.reSelectPoint = function(self, id, nav_type)
	if self.cur_select_point_info and
		self.cur_select_point_info.navType and nav_type and self.cur_select_point_info.navType == nav_type and
		self.cur_select_point_info.id and id and self.cur_select_point_info.id == id then
		self:selectPoint(self.cur_select_point_info.id, self.cur_select_point_info.navType)
	end
end

ExploreMap.isShipPosChange = function(self, ship_next_x, ship_next_y)
	if Math.abs(self.last_ship_pos.x - ship_next_x) > 20 or Math.abs(self.last_ship_pos.y - ship_next_y) > 20 then
		self.last_ship_pos.x = ship_next_x
		self.last_ship_pos.y = ship_next_y
		return true
	end
	return false
end

ExploreMap.ajustMapLayerPos = function(self, map_next_x, map_next_y, map_next_scale, border_offsets)
	local old_map_next_x, old_map_next_y = map_next_x, map_next_y
	local map_next_x, map_next_y,
	map_layer_to_top_border_dis,
	map_layer_to_bottom_border_dis,
	map_layer_to_left_border_dis,
	map_layer_to_right_border_dis = ExploreMap.super.ajustMapLayerPos(self, map_next_x, map_next_y, map_next_scale, border_offsets)

	if not self.show_max or self.worldmap_show then
		return map_next_x, map_next_y, map_layer_to_top_border_dis, map_layer_to_bottom_border_dis, map_layer_to_left_border_dis, map_layer_to_right_border_dis
	end

	local mapAttrs = getGameData():getWorldMapAttrsData()
	local explore_map_data = getGameData():getExploreMapData()

	local cur_area_info = self.area_map_dic[explore_map_data:getCurClickAreaId()]
	local top_area_id, bottom_area_id, left_area_id, right_area_id = 0, 0, 0, 0
	if cur_area_info then
		top_area_id = cur_area_info.base.around_areas[1] or 0
		bottom_area_id = cur_area_info.base.around_areas[2] or 0
		left_area_id = cur_area_info.base.around_areas[3] or 0
		right_area_id = cur_area_info.base.around_areas[4] or 0
	end
	local open_area = mapAttrs:getSeaArea()

	local cur_drag_area_id = 0
	local cur_drag_dis = 0
	local cur_border_offset = 0
	local border_normal_offset = 100
	local scale_x, scale_y = 0, 0
	local is_horizontal = true

	local top_border_offset = border_normal_offset
	local bottom_border_offset = border_normal_offset
	local left_border_offset = border_normal_offset
	local right_border_offset = border_normal_offset

	local map_layer_scale = map_next_scale or self.map_layer:getScale()
	local map_area_width = self.map_area_show_rect.size.width * map_layer_scale
	local map_area_height = self.map_area_show_rect.size.height * map_layer_scale
	local view_port_width = self.cur_show_viewport_rect.size.width
	local view_port_height = self.cur_show_viewport_rect.size.height

	local width, height = math.ceil(map_area_width), math.ceil(map_area_height)
	local scale_x = (math.abs(map_layer_to_left_border_dis) + view_port_width)/width
	local scale_y = (math.abs(map_layer_to_bottom_border_dis) + view_port_height)/height

	if border_offsets then
		if map_layer_to_top_border_dis < 0 and border_offsets[1] > 0 then
			top_border_offset = border_offsets[1]
			cur_drag_area_id = top_area_id
			cur_drag_dis = Math.abs(map_layer_to_top_border_dis)
			cur_border_offset = border_offsets[1]

			scale_y = 0
			is_horizontal = false
		elseif map_layer_to_bottom_border_dis > 0 and border_offsets[2] > 0 then
			bottom_border_offset = border_offsets[2]
			cur_drag_area_id = bottom_area_id
			cur_drag_dis = map_layer_to_bottom_border_dis
			cur_border_offset = border_offsets[2]

			scale_y = 1
			is_horizontal = false
		elseif map_layer_to_left_border_dis > 0 and border_offsets[3] > 0 then
			left_border_offset = border_offsets[3]
			cur_drag_area_id = left_area_id
			cur_drag_dis = map_layer_to_left_border_dis
			cur_border_offset = border_offsets[3]

			scale_x = 1
		elseif map_layer_to_right_border_dis < 0 and border_offsets[4] > 0 then
			right_border_offset = border_offsets[4]
			cur_drag_area_id = right_area_id
			cur_drag_dis = Math.abs(map_layer_to_right_border_dis)
			cur_border_offset = border_offsets[4]

			scale_x = 0
		end
	end

	if cur_drag_dis < cur_border_offset then
		self.drag_out_area_id = 0
	elseif open_area[cur_drag_area_id] then
		self.drag_out_area_id = cur_drag_area_id
		self.drag_out_area_x = scale_x
		self.drag_out_area_y = scale_y
		self.is_horizontal = is_horizontal
	end

	local setBorderNodesOpacity
	setBorderNodesOpacity = function(area_id, nodes, reverse_nodes, map_layer_to_border_dis, border_offset)
		for k,v in ipairs(nodes) do
			v:setVisible(not not open_area[area_id])
		end

		if not open_area[area_id] then
			for k,v in ipairs(reverse_nodes) do
				v:setVisible(false)
			end
			return
		end

		local map_layer_to_border_dis_abs = Math.abs(map_layer_to_border_dis)
		if map_layer_to_border_dis_abs > border_offset then
			map_layer_to_border_dis_abs = border_offset
		end
		local opacity = Math.floor(255 * Math.abs(border_offset - map_layer_to_border_dis_abs) / border_offset)
		local reverse_opacity = 0
		if border_offset ~= border_normal_offset then
			reverse_opacity = 255 - opacity
		end
		for k,v in ipairs(reverse_nodes) do
			v:setOpacity(reverse_opacity)
			v:setVisible(reverse_opacity > 0)
		end
	end
	setBorderNodesOpacity(top_area_id, {self.top_border_btn}, {self.top_area_name}, map_layer_to_top_border_dis, top_border_offset)
	setBorderNodesOpacity(bottom_area_id, {self.bottom_border_btn}, {self.bottom_area_name}, map_layer_to_bottom_border_dis, bottom_border_offset)
	setBorderNodesOpacity(left_area_id, {self.left_border_btn}, {self.left_area_name}, map_layer_to_left_border_dis, left_border_offset)
	setBorderNodesOpacity(right_area_id, {self.right_border_btn}, {self.right_area_name}, map_layer_to_right_border_dis, right_border_offset)
	return map_next_x, map_next_y, map_layer_to_top_border_dis, map_layer_to_bottom_border_dis, map_layer_to_left_border_dis, map_layer_to_right_border_dis
end

ExploreMap.getMapLayerMinScale = function(self)
	local exploreMapData = getGameData():getExploreMapData()
	local curClickAreaId = exploreMapData:getCurClickAreaId()
	local arenaInfo = self.area_map_dic[curClickAreaId]
	if arenaInfo then
		self.map_layer_min_scale = arenaInfo.minScale
		self.map_layer_max_scale = self.map_layer_min_scale + 2
	else
		self.map_layer_min_scale = self.show_worldmap_map_layer_scale
		self.map_layer_max_scale = self.map_layer_min_scale
	end
	return self.map_layer_min_scale
end

ExploreMap.showWorldMap = function(self)
	self.top_area_name:setVisible(false)
	self.bottom_area_name:setVisible(false)
	self.left_area_name:setVisible(false)
	self.right_area_name:setVisible(false)

	if not self.is_cross_unknow_area then
		self:setSwallowTouch(true)
		self:setViewTouchEnabled(true)
	end
	if not tolua.isnull(self.force_layer) then
		self.force_layer:removeFromParentAndCleanup(true)
		self.force_layer = nil
	end
	self.worldmap_show = true
	local worldMapBgSize = nil
	if tolua.isnull(self.worldMapBg) then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
		self.worldMapBg = display.newSprite(self.worldmap_bg_res)
		CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
		worldMapBgSize = self.worldMapBg:getContentSize()
		local world_map_scale_x = self.map_width / worldMapBgSize.width
		local world_map_scale_y = self.map_height / worldMapBgSize.height
		self.worldMapBg:setScaleX(world_map_scale_x)
		self.worldMapBg:setScaleY(world_map_scale_y)
		self.worldMapBg:setAnchorPoint(ccp(0, 0))
		self.map:addChild(self.worldMapBg,-1)
	else
		worldMapBgSize = self.worldMapBg:getContentSize()
		self.worldMapBg:setVisible(true)
	end
	self:setMapAreaShowRect(0, 0, self.map_width, self.map_height)
	local scale = self.show_worldmap_map_layer_scale
	self:setMapLayerScale(scale)
end

ExploreMap.hideWorldMap = function(self)
	self.worldmap_show = false
	if not tolua.isnull(self.worldMapBg) then
		self.worldMapBg:removeFromParentAndCleanup(true)
		self.worldMapBg = nil
		RemoveTextureForKey(self.worldmap_bg_res)
	end
end

ExploreMap.showAreaMap = function(self, areaId)
	local curAreaInfo = self.area_map_dic[areaId]
	if not curAreaInfo then
		return
	end

	self:hideAreaMap()

	if tolua.isnull(curAreaInfo.map) then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
		curAreaInfo.map = display.newSprite(curAreaInfo.mapRes)
		curAreaInfo.map:setScaleX(curAreaInfo.mapRect.size.width/curAreaInfo.map:getContentSize().width)
		curAreaInfo.map:setScaleY(curAreaInfo.mapRect.size.height/curAreaInfo.map:getContentSize().height)
		CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
		curAreaInfo.map:setPosition(curAreaInfo.mapPos)
		self.map:addChild(curAreaInfo.map, -1)
	else
		curAreaInfo.map:setVisible(true)
	end
	self:setMapAreaShowRect(curAreaInfo.base.lbPos[1], curAreaInfo.base.lbPos[2], curAreaInfo.base.width, curAreaInfo.base.height)

	self:setMapLayerScale(self:isShowMax() and curAreaInfo.showScale or curAreaInfo.showScale/2)

	local need_ask_good_info_ports = self:resetPoint(EXPLORE_NAV_TYPE_PORT)
	self:resetPoint(EXPLORE_NAV_TYPE_RELIC)
	self:resetPoint(EXPLORE_NAV_TYPE_SH)
	self:resetPoint(EXPLORE_NAV_TYPE_WHIRLPOOL)
	self:resetPoint(EXPLORE_NAV_TYPE_TIME_PIRATE)
	-- self:resetPoint(EXPLORE_NAV_TYPE_MINERAL_POINT)
	self:resetPoint(EXPLORE_NAV_TYPE_WORLD_MISSION)
	self:resetPoint(EXPLORE_NAV_TYPE_CONVOY_MISSION) -- 运镖

	local explore_map_data = getGameData():getExploreMapData()
	if #need_ask_good_info_ports > 0 then
		explore_map_data:askMapPortInfos(need_ask_good_info_ports)
	end

	if not self.force_layer or tolua.isnull(self.force_layer) or self.force_layer.area_id ~= areaId then
		self:tryUpdatePortPowerUI(areaId)
	end
end

ExploreMap.hideAreaMap = function(self)
	for k,v in pairs(self.area_map_dic) do
		if not tolua.isnull(v.map) then
			v.map:removeFromParentAndCleanup(true)
			v.map = nil
			RemoveTextureForKey(v.mapRes)
		end
	end
	self.border_offsets = nil
end
--[[
@api
	@desc
		对 世界任务图标进行缩放,根据是否是放大. 运镖也是
]]
ExploreMap.setScaleOfWorldMissionPoint = function(self, isMax)
	local scale = isMax and 2 or 1

	local points = self.point_dic[EXPLORE_NAV_TYPE_WORLD_MISSION]
	if points then
		for k,nodes in pairs(points) do
			for k,v in pairs(nodes) do
				if not tolua.isnull(v) then
					v:setScale(scale)
				end
			end
		end
	end

	local points = self.point_dic[EXPLORE_NAV_TYPE_CONVOY_MISSION]
	if points then
		for k,nodes in pairs(points) do
			for k,v in pairs(nodes) do
				if not tolua.isnull(v) then
					v:setScale(scale)
				end
			end
		end
	end

	local points = self.point_dic[EXPLORE_NAV_TYPE_RELIC]
	if points then
		for k,nodes in pairs(points) do
			for _,v in pairs(nodes) do
				if not tolua.isnull(v) then
					v:setScale(scale * 1.7)
				end
			end
		end
	end

end
--[[
@api
	@desc
		当在区域地图和世界地图之间切换时候要设置的各种设置,(可见属性和缩放属性)
]]
ExploreMap.switchBetweenAreaAndWorld = function(self, is_world)
	local world_show = {
		-- EXPLORE_NAV_TYPE_WORLD_MISSION,
		-- EXPLORE_NAV_TYPE_RELIC,
	}
	for k,v in pairs(world_show) do
		self:setPointVisible(v,is_world)
	end
	local world_hide = {
		EXPLORE_NAV_TYPE_NONE, -- = 0 --直接出海
		EXPLORE_NAV_TYPE_PORT, -- = 1 --港口
		EXPLORE_NAV_TYPE_SH, -- = 2 --海上据点
		EXPLORE_NAV_TYPE_LOOT, -- = 3 --掠夺
		EXPLORE_NAV_TYPE_POS, -- = 4 --某个位置
		EXPLORE_NAV_TYPE_WHIRLPOOL, -- = 5 --漩涡
		-- EXPLORE_NAV_TYPE_RELIC, -- = 6  --遗迹
		EXPLORE_NAV_TYPE_OTHER, -- = 7  --其它
		EXPLORE_NAV_TYPE_PVE_PORT, -- = 8  --港口(pve)
		EXPLORE_NAV_TYPE_TIME_PIRATE, -- = 9  --时段海盗
		EXPLORE_NAV_TYPE_REWARD_PIRATE, -- = 10 --悬赏海盗
		-- EXPLORE_NAV_TYPE_MINERAL_POINT, -- = 11 --海上矿产
		EXPLORE_NAV_TYPE_SALVE_SHIP, -- = 12   --悬赏打捞沉船
		-- EXPLORE_NAV_TYPE_WORLD_MISSION, -- = 13 -- 世界随机任务
	}

	for k,v in pairs(world_hide) do
		self:setPointVisible(v,not is_world)
	end
	self:setScaleOfWorldMissionPoint(is_world)

end

ExploreMap.turnToWorld = function(self, viewPortRect)
	local exploreMapData = getGameData():getExploreMapData()
	exploreMapData:clearCurClickAreaId()
	transition.stopTarget(self.map_layer)

	self:hideAreaMap()
	self.point_layer:setVisible(false)
	self.point_name_layer:setVisible(true)
	self.relicPlaceLayer:setVisible(false)
	self.relicDoneLayer:setVisible(false)
	self:showWorldMap()

	if not viewPortRect then
		viewPortRect = self.show_worldmap_viewport_rect
	end

	local sx, sy = self.ship:getPosition()
	self:setCurShowViewPortRect(viewPortRect)
	self:alignMapLayerToXY(sx, sy)
	self:switchBetweenAreaAndWorld(true)
	return true
end

local point_offsets = {
	[4] = {x = 0, y = -80},
	[6] = {x = -90, y = 0},
}
ExploreMap.turnToWorldExt = function(self)
	if not self:turnToWorld(self.show_worldmap_viewport_rect) then
		return false
	end
	local mapAttrs = getGameData():getWorldMapAttrsData()

	for k,v in ipairs(self.show_worldmap_hide_nodes) do
		v:setVisible(false)
	end
	for k,v in ipairs(self.show_worldmap_show_nodes) do
		v:setVisible(true)
	end

	self.arena_name_layer:removeAllChildrenWithCleanup(true)
	local opeanArea = mapAttrs:getSeaArea()
	local area_ids = getGameData():getExplorePirateEventData():getActiveAreaIds()
	for k,v in pairs(area_info) do
		if opeanArea[k] then
			local is_in_active = false
			local color_n = COLOR_WHITE_STROKE
			if area_ids[k] then
				is_in_active = true
				color_n = COLOR_WHITE_STROKE_RED
			end
			if not getGameData():getPortData():getIsProtectArea(k) then
				color_n = COLOR_RED_STROKE
			end
			local point_offset = point_offsets[k] or {x = 0, y = 0}
			local arenaNameLb = createBMFont({text = v.name, size = 20, fontFile = FONT_CFG_1, align=ui.TEXT_ALIGN_CENTER,color = ccc3(dexToColor3B(color_n))})
			arenaNameLb:setPosition(ccp((v.lbPos[1]+v.width/2) + point_offset.x, (v.lbPos[2]+v.height/2) + point_offset.y))
			arenaNameLb:setScale(4)
			self.arena_name_layer:addChild(arenaNameLb)
			if is_in_active then
				local pirate_tips_spr = display.newSprite(self.POINT_RES["time_pirate_boss"][1])
				pirate_tips_spr:setAnchorPoint(ccp(1, 0.5))
				pirate_tips_spr:setPosition(ccp(-0.5*arenaNameLb:getContentSize().width, 0))
				pirate_tips_spr:setScale(0.7)
				arenaNameLb:addChild(pirate_tips_spr)
			end
		end
	end
	--缩放海盗图标
	for _, icon in pairs(self.pirate_boss_icons) do
		icon:setWorldIconScale()
	end

	for _, icon in pairs(self.pirate_icons) do
		icon:setWorldIconScale()
	end
	
	if getGameData():getExplorePirateEventData():getRemainTime() > 0 then
		self.widget_panel.red_tips_bg:setVisible(false)
	end
	getGameData():getWorldMissionData():askTeamWorldMissionList()

	return true
end

ExploreMap.turnToArea = function(self, areaId, areaPos, viewPortRect)
	local curAreaInfo = self.area_map_dic[areaId]
	if not curAreaInfo then
		return false
	end

	getGameData():getAreaRewardData():askAreaRewardInfo(areaId)

	local exploreMapData = getGameData():getExploreMapData()
	exploreMapData:setCurClickAreaId(areaId)
	transition.stopTarget(self.map_layer)

	self:switchBetweenAreaAndWorld(false)

	self:hideWorldMap()
	self.relicPlaceLayer:setVisible(false)
	self.relicDoneLayer:setVisible(false)
	self.point_layer:setVisible(true)
	self.point_name_layer:setVisible(true)
	self:showAreaMap(areaId)

	if not viewPortRect then
		viewPortRect = self.show_areamap_viewport_rect
	end

	local area_default_pos = {
		[1] = {1748,1500}, -- 地中海
		[2] = {1850,1640}, -- 北海
		[3] = {1746,1064}, -- 非洲
		[4] = {2350,1262}, -- 印度洋
		[5] = {2800,1012}, -- 东南亚 y大 上移 x小 左移
		[6] = {3200,1200}, -- 东亚
		[7] = {1000,1200}, -- 新大陆
		[8] = {0,0}, -- 北极
		[9] = {0,0}, -- 南极
		[10] = {0,0}, -- 无人区
	}

	if not areaPos then
		if areaId == getGameData():getExploreMapData():getCurAreaId() then
			local sx, sy = self.ship:getPosition()
			areaPos = ccp(sx, sy)
		else
			if not self.drag_out_area_x or not self.drag_out_area_y then
				areaPos = ccp(area_default_pos[areaId][1], area_default_pos[areaId][2])
			else
				local x = self.drag_out_area_x*(curAreaInfo.base.lbPos[1] + curAreaInfo.base.width)
				local y = self.drag_out_area_y*(curAreaInfo.base.lbPos[2] + curAreaInfo.base.height)
				areaPos = ccp(x,y)
			end
		end
	end
	self:setCurShowViewPortRect(viewPortRect)
	self:alignMapLayerToXY(areaPos.x, areaPos.y)
	return true
end

ExploreMap.turnToAreaExt = function(self, areaId, areaPos)
	if not self:turnToArea(areaId, areaPos, self.show_areamap_viewport_rect) then
		return false
	end
	for k,v in ipairs(self.show_areamap_hide_nodes) do
		v:setVisible(false)
	end
	for k,v in ipairs(self.show_areamap_show_nodes) do
		v:setVisible(true)
	end

	local mapAttrs = getGameData():getWorldMapAttrsData()
	local open_area = mapAttrs:getSeaArea()
	local cur_area_info = self.area_map_dic[areaId]
	local top_area_id, bottom_area_id, left_area_id, right_area_id = 0, 0, 0, 0
	top_area_id = cur_area_info.base.around_areas[1] or 0
	bottom_area_id = cur_area_info.base.around_areas[2] or 0
	left_area_id = cur_area_info.base.around_areas[3] or 0
	right_area_id = cur_area_info.base.around_areas[4] or 0
	self.border_offsets = {0, 0, 0, 0}
	if top_area_id > 0 and open_area[top_area_id] then
		self.border_offsets[1] = self.border_max_offset
		self.top_area_name:setString(area_info[top_area_id].name)
	end
	if bottom_area_id > 0 and open_area[bottom_area_id] then
		self.border_offsets[2] = self.border_max_offset
		self.bottom_area_name:setString(area_info[bottom_area_id].name)
	end
	if left_area_id > 0 and open_area[left_area_id] then
		self.border_offsets[3] = self.border_max_offset
		self.left_area_name:setString(area_info[left_area_id].name)
	end
	if right_area_id > 0 and open_area[right_area_id] then
		self.border_offsets[4] = self.border_max_offset
		self.right_area_name:setString(area_info[right_area_id].name)
	end

	if self.cur_select_point_info and not tolua.isnull(self.goal_point_effect) then
		local goal_point_effect_x, goal_point_effect_y = self.goal_point_effect:getPosition()
		local is_effect_visible = true
		if cur_area_info.mapRect:containsPoint(ccp(goal_point_effect_x, goal_point_effect_y)) then
			if self.cur_select_point_info.id and self.cur_select_point_info.navType then
				local nav_info = self.NAVTYPE_TO_CONFIG[self.cur_select_point_info.navType]
				if nav_info then
					local point_info = nav_info[self.cur_select_point_info.id]
					if point_info and point_info.areaId and point_info.areaId ~= areaId then
						is_effect_visible = false
					end
				end
			end
		else
			is_effect_visible = false
		end
		self.goal_point_effect:setVisible(is_effect_visible)
	end
	return true
end

ExploreMap.turnToCurArea = function(self)
	local curAreaId = 0
	local curAreaPos = nil
	local exploreMapData = getGameData():getExploreMapData()
	local sx, sy = self.ship:getPosition()
	curAreaPos = ccp(sx, sy)
	curAreaId = exploreMapData:getCurAreaId()
	if not exploreMapData:isLegalAreaId(curAreaId) then
		curAreaId = exploreMapData:getCurAreaId()
	end
	self:turnToAreaExt(curAreaId, curAreaPos)
end

ExploreMap.turnToCliArea = function(self, pos, first_area_id)
	local exploreMapData = getGameData():getExploreMapData()
	local curClickAreaId = exploreMapData:getClickOpenAreaId(pos, first_area_id)
	self:turnToAreaExt(curClickAreaId, pos)
	return curClickAreaId
end

ExploreMap.turnToPointArea = function(self, id, nav_type, is_use_area)
	local config = self.NAVTYPE_TO_CONFIG[nav_type]
	if not config then
		return
	end
	local info = config[id]
	if not info then
		return
	end
	local pos = self.NAVTYPE_TO_CONFIG_POS[nav_type](self, id)
	if not pos then
		return
	end
	local p = exploreMapUtil.cocosToTile(ccp(pos[1], pos[2]), self.map_height, self.map_tile_size)
	local first_area_id = nil
	if is_use_area then
		first_area_id = getGameData():getExploreMapData():getCurAreaId()
	end
	local area_id = self:turnToCliArea(p, first_area_id)
	if area_id and area_id > 0 then
		self:selectPoint(id, nav_type)
	end
end

ExploreMap.turnToDragArea = function(self, areaId)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local opeanArea = mapAttrs:getSeaArea()
	if opeanArea[areaId] then
		self:turnToAreaExt(areaId)
		if self.cur_select_point_info and self.cur_select_point_info.navType and self.cur_select_point_info.navType == EXPLORE_NAV_TYPE_OTHER then
			self:selectPoint(areaId, EXPLORE_NAV_TYPE_OTHER)
		end
	end
end

-----------------最大化---------------------
ExploreMap.showMax = function(self)
	self:setHideBeforeView(true)

	ExploreMap.super.showMax(self)
	self:setViewTouchEnabled(true)
	self:setSwallowTouch(true)
	self.point_info_panel:setTouch(true)

	local explore_local_ui = getUIManager():get("clsExploreLocalUI")
	if not tolua.isnull(explore_local_ui) then
		explore_local_ui:setVisible(false)
	end

	-- local explore_layer = getExploreLayer()
	-- if not tolua.isnull(explore_layer) then
	-- 	explore_layer:getShipsLayer():setStopShipReason("ExploreMap_show")
	-- end

	if not tolua.isnull(self.force_layer) then
		local area_id = getGameData():getExploreMapData():getCurAreaId()
		self:tryUpdatePortPowerUI(area_id)
	end

	-- self.crown_layer:setVisible(true)
	local onOffData = getGameData():getOnOffData()
	-- if not onOffData:isOpen(on_off_info.PEERAGES.value) then
	-- 	self.crown_layer.btn_help:disable()
	-- else
	-- 	self.crown_layer.btn_help:active()
	-- end

	local sailorUpLevelData = getGameData():getSailorUpLevelData()
	sailorUpLevelData:stopShow()  --清楚水手升级显示

	self.widget_panel.btn_go.has_clicked = false

	EventTrigger(EVENT_EXPLORE_BOX_HIDE)

	EventTrigger(EVENT_EXPLORE_PAUSE)  --暂停探索，一定得放在 self.show_max = true 后面


	if self.is_cross_unknow_area then
		self:turnToWorldExt()
	else
		local explore_map_data = getGameData():getExploreMapData()
		local market_data = getGameData():getMarketData()
		local cur_area_id = explore_map_data:getCurAreaId()
		local select_point_id = nil
		local select_point_nav_type = nil
		if self.cur_goal_place then
			select_point_id = self.cur_goal_place.id
			select_point_nav_type = self.cur_goal_place.navType
			if select_point_nav_type == EXPLORE_NAV_TYPE_POS then
				select_point_id = cur_area_id
				select_point_nav_type = EXPLORE_NAV_TYPE_OTHER
			end
		else
			select_point_id = explore_map_data:getTaskMapSelectPortId()
			select_point_nav_type = EXPLORE_NAV_TYPE_PORT
			if not select_point_id then
				local need_good_port_id = market_data:getMinDistancePortId()
				if need_good_port_id then
					select_point_id = need_good_port_id
					select_point_nav_type = EXPLORE_NAV_TYPE_PORT
				else
					if GameUtil.getRunningSceneType() == SCENE_TYPE_PORT then
						local port_data = getGameData():getPortData()
						select_point_id = port_data:getPortId()
						select_point_nav_type = EXPLORE_NAV_TYPE_PORT
					else
						select_point_id = cur_area_id
						select_point_nav_type = EXPLORE_NAV_TYPE_OTHER
					end
				end
			end
		end
		self:turnToCurArea()
		self:selectPoint(select_point_id, select_point_nav_type)
		if select_point_nav_type and select_point_nav_type == EXPLORE_NAV_TYPE_PORT and
			select_point_id and port_info[select_point_id].areaId ~= cur_area_id then
			explore_map_data:askMapPortInfos({select_point_id})
		end
	end

	self:helpBtnCallBack(false, true)
	self:setVisibleOfWorldMissionPanel(false)
end

-------------------最小化---------------------
ExploreMap.showMin = function(self)
	self:setHideBeforeView(false)

	ExploreMap.super.showMin(self)
	self:setViewTouchEnabled(false)
	self:setSwallowTouch(false)

	local explore_local_ui = getUIManager():get("clsExploreLocalUI")
	if not tolua.isnull(explore_local_ui) then
		explore_local_ui:setVisible(true)
	end

	-- local explore_layer = getExploreLayer()
	-- if not tolua.isnull(explore_layer) and explore_layer:getShipsLayer() then
	-- 	explore_layer:getShipsLayer():releaseStopShipReason("ExploreMap_show")
	-- end
	self.point_info_panel:setTouch(false)

	-- self.crown_layer:setVisible(false)
	-- self.crown_layer.btn_help:setTouchEnabled(false)

	if not tolua.isnull(self.force_layer) then
		self.force_layer:setVisible(false)
		self.force_layer:setTouchEnabled(false)
	end
	
	local exploreMapData = getGameData():getExploreMapData()
	if self.is_cross_unknow_area then
		self:turnToWorld(self.show_min_viewport_rect)
	else
		local curAreaId = exploreMapData:getCurAreaId()
		self:turnToArea(curAreaId, nil, self.show_min_viewport_rect)
		if self.cur_goal_place then
			self:selectPoint(self.cur_goal_place.id, self.cur_goal_place.navType, true)
		end
	end

	self:helpBtnCallBack(false, true)
	self:setVisibleOfWorldMissionPanel(false)
end

ExploreMap.onExit = function(self)
	ExploreMap.super.onExit(self)
	--移除资源
	UnLoadPlist(self.plist_res_2)
	UnLoadArmature(self.armature_res_2)
	RemoveTextureForKey(self.worldmap_bg_res)
	for k,v in pairs(area_info) do
		RemoveTextureForKey(v.map_res)
	end
	self.show_worldmap_show_nodes = nil
	self.show_worldmap_hide_nodes = nil
	self.show_areamap_show_nodes = nil
	self.show_areamap_hide_nodes = nil
	local port_data = getGameData():getPortData()
	port_data:setExploreDiffPowerInfo() --清除港口状态变化标志
	self.AStar = nil
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
	
	UnRegTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT)
	UnRegTrigger(EVENT_EXPLORE_HIDE_GOAL_PORT)
	UnRegTrigger(EVENT_EXPLORE_CANCEL_GOAL_PORT)
	UnRegTrigger(EVENT_MISSION_UPDATE)
	UnRegTrigger(EVENT_PORT_LIST_UPDATE)
	UnRegTrigger(EVENT_PORT_PVE_CPDATA_ALL_UPDATE)
	UnRegTrigger(EVENT_PORT_PVE_CPDATA_PORT_UPDATE)
	UnRegTrigger(EVENT_PORT_PVE_CPDATA_SH_UPDATE)
	UnRegTrigger(EVENT_PORT_SAILOR_FOOD)
	UnRegTrigger(EVENT_PORT_MARKET_PORT_STORE2)
	UnRegTrigger(EVENT_PORT_MARKET_PORT_CARGO2)
	UnRegTrigger(EVENT_PORT_PVE_CPDATA_RELIC_UPDATE)
	UnRegTrigger(EVENT_PORT_PVE_CPDATA_RELIC_OPEN)
	UnRegTrigger(EVENT_PORT_GOOD_INFO_UPDATE)
	UnRegTrigger(EVENT_PORT_OWNER_INFO_UPDATE)
end

ExploreMap.initFinish = function(self)
	getGameData():getChatData():setCurAreaID(getGameData():getExploreMapData():getCurAreaId())
	self:setShipPosChangeCb(function(ship_next_x, ship_next_y)
		local explore_map_data = getGameData():getExploreMapData()
		local cur_area_id = explore_map_data:getCurAreaId()
		local next_area_id = explore_map_data:getSeaArea(ccp(ship_next_x, ship_next_y), self.first_area_id)
		self.first_area_id = nil
		local view_port_rect = nil
		if self.show_max then
			view_port_rect = self.show_worldmap_viewport_rect

			if not self.worldmap_show then
				view_port_rect = self.show_areamap_viewport_rect
			end
		else
			view_port_rect = self.show_min_viewport_rect
		end

		-- 聊天记录当前区域ID
		getGameData():getChatData():setCurAreaID(self.area_map_dic[next_area_id] and next_area_id or 10000)

		if self.area_map_dic[next_area_id] then
			if self.is_cross_unknow_area or cur_area_id ~= next_area_id then
				self.is_cross_unknow_area = false
				explore_map_data:setCurAreaId(next_area_id)
				if self.show_max then
					self:turnToAreaExt(next_area_id, nil)
				else
					self:turnToArea(next_area_id, nil, view_port_rect)
				end
				EventTrigger(EVENT_EXPLORE_SEAAREA_CHANGE, explore_map_data:getCurAreaId())
				-- 换海域音乐
				if area_info[next_area_id] then
					local key = area_info[next_area_id].music
					audioExt.playMusic(music_info[key].res, true)
				else
					audioExt.playMusic(music_info["EX_BGM"].res, true)
				end

				--换海域时，如果海域有boss， 弹出界面
				local explore_layer = getExploreLayer()
				if not tolua.isnull(explore_layer) then
					explore_layer.pirate_layer:showBossView(explore_map_data:getCurAreaId())
				end
			end

			EventTrigger(EVENT_EXPLORE_CROSS_KNOW_AREA)
		else
			if not self.is_cross_unknow_area then
				self.is_cross_unknow_area = true

				if self.show_max then
					self:turnToWorldExt()
				else
					self:turnToWorld(view_port_rect)
				end
			end
			EventTrigger(EVENT_EXPLORE_CROSS_UNKNOW_AREA)

			local explore_layer = getUIManager():get("ExploreLayer")
			local player_ship = explore_layer:getPlayerShip()
			local x, y = player_ship:getPos()
			local pos = explore_layer:getLand():tileToCocos(ccp(x, y))
			getGameData():getExplorePlayerShipsData():askEnterArea(NO_PEOPLE_AREA, pos.x, pos.y, true)

			local explore_layer = getExploreLayer()
			if not tolua.isnull(explore_layer) then
				explore_layer.pirate_layer:showBossViewAction(nil, nil, true)
			end
		end
	end)
end

ExploreMap.setChangeFirstAreaId = function(self, area_id)
	self.first_area_id = area_id
end

ExploreMap.setUnSelectDescVisible = function(self, is_enable)
	self.widget_panel.purpose_info:setVisible(is_enable)
	self.widget_panel.supply_info:setVisible(is_enable)
	self.widget_panel.line_1:setVisible(is_enable)
	self.widget_panel.line_2:setVisible(is_enable)
	self.widget_panel.line_3:setVisible(is_enable)
end

ExploreMap.getTimePanel = function(self)
	return self.widget_panel.time_panel
end

ExploreMap.resetSupplyInfo = function(self, isVisible)
	self.widget_panel.supply_info:setVisible(isVisible)
	self.widget_panel.line_1:setVisible(isVisible)
	self.widget_panel.line_2:setVisible(isVisible)
	self.widget_panel.line_3:setVisible(isVisible)
	self.widget_panel.btn_go:setVisible(isVisible)
	self.widget_panel.purpose_name:setVisible(isVisible)
end

ExploreMap.getWidgetPanel = function(self)
	return self.widget_panel
end

ExploreMap.isShowWorldMax = function(self)
	return self.worldmap_show
end

--[[
@api
	@desc
		设置世界任务tips界面的可见属性和刷新逻辑
]]
ExploreMap.setVisibleOfWorldMissionPanel = function(self, visible, wm_id)
	-- 处理世界任务tips出现和消失时候要变化的其他UI逻辑
	-- 包括是否可见属性 和 是否可触摸属性
	local SPECIAL_MISSION_ID = 1000
	self.visible_of_wmt_panel = visible
	local not_visible = not visible
	local on_off_data = getGameData():getOnOffData()

	self.widget_panel.btn_go:setTouchEnabled(not_visible)
	self.widget_panel.btn_worldmap:setTouchEnabled(not_visible)

	self.world_mission_tip_panel.tips_panel:setTouchEnabled(not_visible)
	self.widget_panel.touch_sceen:setTouchEnabled(visible)
	self.widget_panel.port_panel:setTouchEnabled(visible)
	self.world_mission_tip_panel:setTouchEnabled(visible)
	self.widget_panel.port_panel:setVisible(visible)
	self.world_mission_tip_panel:setVisible(visible)

	-- if not_visible then
	-- 	if not on_off_data:isOpen(on_off_info.PEERAGES.value) then
	-- 		self.crown_layer.btn_help:disable()
	-- 	else
	-- 		self.crown_layer.btn_help:active()
	-- 	end
	-- else
	-- 	self.crown_layer.btn_help:disable()
	-- end

	-- 关闭任务倒计时定时器
	local closeTimer
	closeTimer = function()
		if self.timer then
			scheduler:unscheduleScriptEntry(self.timer)
			self.timer = nil
		end
	end

	-- 世界任务tips面板内的ui刷新机制
	local updateWorldMissionTipUI
	updateWorldMissionTipUI = function()
		-- 类型对应的文本
		local type_to_txt_table = {
				["explore_event"] = ui_word.WORLDMISSION_TYPE_EXPLORE,
				["business"] = ui_word.WORLDMISSION_TYPE_BUSINESS,
				["battle"] = ui_word.WORLDMISSION_TYPE_BATTLE,
				["teambattle"] = ui_word.WORLDMISSION_TYPE_TEAM,
		}
		-- 该tips对应的数据结构
		local data = getGameData():getWorldMissionData()
		local item = data:getWorldMissionList()[wm_id]
		-- 保护性检测
		if item == nil or item.cfg == nil then
			return
		end
		-- 界面控件逻辑
		local panel_json = self.world_mission_tip_json_panel
		local ClsTips = require("ui/tools/Tips")
		ClsTips:runAction(panel_json)
		-- 星级图片
		local star = nil
		for i = 1,5 do
			star = getConvertChildByName(panel_json,"star_"..i)
			star:setVisible(item.cfg.star >= i)
		end
		-- 事件名称
		local name = getConvertChildByName(panel_json,"event_text")
		name:setText(item.cfg.name.." "..type_to_txt_table[item.cfg.type])
		-- 事件内容
		local content = getConvertChildByName(panel_json,"event_info")
		content:setText(item.cfg.mission_txt)
		-- 目前写死 星级的10倍 为体力值
		-- 体力消耗数量
		local strength_num = getConvertChildByName(panel_json, "tili_num")
		strength_num:setText(item.cfg.star * 10)
		-- 体力图标
		local strength_icon = getConvertChildByName(panel_json, "tili_icon")
		-- 体力文字
		local strength_text = getConvertChildByName(panel_json, "tili_text")
		strength_icon:setVisible(true)
		strength_text:setVisible(true)
		strength_num:setVisible(true)
		-- 奖励内容
		local reward_cfg = item.cfg.reward_text
		local icon_data = {}
		local num_data = {}
		local icon_ui = {}
		local num_ui = {}
		local icon_json = {"coin_icon","diamond_icon"}
		local num_json = {"coin_num","diamond_num"}

		local new_table = {}
		for k,v in pairs(reward_cfg) do
			local new_item = {}
			new_item.id = k
			new_item.num = v
			new_table[#new_table+1] = new_item
		end

		table.sort(new_table,function ( a,b )
			return a.id>b.id
		end)

		local item_info = require("game_config/propItem/item_info")

		for i = 1,2 do
			-- icon_data[i],num_data[i] = getCommonRewardIcon(getCommonRewardData(reward_cfg[""..i]))
			icon_ui[i] = getConvertChildByName(panel_json,icon_json[i])
			num_ui[i] = getConvertChildByName(panel_json,num_json[i])
			if new_table[i].id ~= 0 then
				local res_str = item_info[new_table[i].id].res
				res_str = string.gsub(res_str,"#","")
				icon_ui[i]:changeTexture(res_str,UI_TEX_TYPE_PLIST)
				num_ui[i]:setText(new_table[i].num)
			else
				icon_ui[i]:setVisible(false)
				num_ui[i]:setText(new_table[i].num)
				num_ui[i]:setPosition(ccp(-46-35,-80))
				num_ui[i]:setColor(ccc3(dexToColor3B(COLOR_WHITE_STROKE_RED)))
			end
		end


		-- reward_cfg = item.rewards -- 奖励由服务器发放
		-- local icon_data = {}
		-- local num_data = {}
		-- local icon_ui = {}
		-- local num_ui = {}
		-- local icon_json = {"coin_icon","diamond_icon"}
		-- local num_json = {"coin_num","diamond_num"}
		-- for i=1,2 do
		-- 	icon_data[i],num_data[i] = getCommonRewardIcon(item.rewards[i])
		-- 	-- icon_data[i],num_data[i] = getCommonRewardIcon(getCommonRewardData(reward_cfg[""..i]))
		-- 	icon_ui[i] = getConvertChildByName(panel_json,icon_json[i])
		-- 	icon_ui[i]:changeTexture(convertResources(icon_data[i]),UI_TEX_TYPE_PLIST)
		-- 	num_ui[i] = getConvertChildByName(panel_json,num_json[i])
		-- 	num_ui[i]:setText(num_data[i])
		-- end
		-- 目标文本拼接
		local target = getConvertChildByName(panel_json,"mission_text")
		target:setText(data:getParseStrById(item.id,false))
		-- 是否组队tip显示状态
		local tip = getConvertChildByName(panel_json,"advice_text")
		tip:setVisible(item.cfg.goto_team == 1)
		-- 倒计时
		local time = getConvertChildByName(panel_json,"time_num")
		-- 战斗类特殊处理
		if item.status == 1 and (item.cfg.type == data:getType().battle or item.cfg.type == data:getType().teambattle) then
			local time_text = getConvertChildByName(panel_json,"time_text")
			time_text:setText( ui_word.WORLD_MISSION_TIP_MISSION_STATUS)
			time:setText(ui_word.WORLDMISSION_DEAL_TIPS_ACCEPTED)
			-- 已经接受的战斗任务不显示消耗体力相关的ui
			strength_icon:setVisible(false)
			strength_text:setVisible(false)
			strength_num:setVisible(false)
			if self.timer then
				scheduler:unscheduleScriptEntry(self.timer)
				self.timer = nil
			end
		-- 正常情况处理
		else
			if wm_id == SPECIAL_MISSION_ID then 
				time:setVisible(false)
			else
				local updateTimeUI
				updateTimeUI = function( )
					local cur_time = os.time() + getGameData():getPlayerData():getTimeDelta()
					local end_time = item.startTime + item.remainTime
					if cur_time < end_time then
						if time then
							time:setText(require("module/dataHandle/dataTools"):getTimeStrNormal(end_time - cur_time))
						end
					elseif item.cfg.type == "teambattle" then
						time:setVisible(false)
					else
						closeTimer()
						self:setVisibleOfWorldMissionPanel(false)
					end
				end
				updateTimeUI()
				self.timer = scheduler:scheduleScriptFunc(updateTimeUI, 1, false)
			end
		end

		-- 前往按钮
		local btn_navi = getConvertChildByName(panel_json,"btn_go")
		btn_navi:addEventListener(function( )
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local str = ""
			str = item.cfg.name
			local pos_x,pos_y = item.cfg.position_explore[1]+2,item.cfg.position_explore[2]+2
			-- 导航去某个点.
			self:naviToPoint(pos_x,pos_y,str,{is_world_mission = wm_id, area_id = item.cfg.area})
		end,TOUCH_EVENT_ENDED)

		-- 导航按钮可见属性
		local is_visible_btn_navi = true -- 默认可见
		if item.status == 1 then
			if item.cfg.type == data:getType().battle or item.cfg.type == data:getType().teambattle then
				is_visible_btn_navi = true -- 战斗类接受了依然可见
			else
				is_visible_btn_navi = false -- 普通类型接受后不可见
			end
		end
		btn_navi:setVisible(is_visible_btn_navi)
		
		local btn_transfer = getConvertChildByName(panel_json,"btn_transfer")
		btn_transfer:setPressedActionEnabled(true)
		local last_time = 0
		btn_transfer:addEventListener(function()
				if CCTime:getmillistimeofCocos2d() - last_time >= 1000 then
					audioExt.playEffect(music_info.COMMON_BUTTON.res)
					getGameData():getExploreData():askExploreTransfer(EXPLORE_TRANSFER_TYPE.WORDLD_MISSION, wm_id, function()
							last_time = CCTime:getmillistimeofCocos2d()
							self:setVisibleOfWorldMissionPanel(false)
						end)
				end
			end, TOUCH_EVENT_ENDED)
		if getGameData():getConvoyMissionData():isDoingMission() then
			btn_transfer:disable()
		else
			btn_transfer:active()
		end
	end

	if self.wm_effect then
		self.wm_effect:removeFromParentAndCleanup(true)
		self.wm_effect = nil
	end

	-- 如果可见 更新UI 不可见的话,记得关闭定时器
	if visible then
		updateWorldMissionTipUI()

		local _pos = self.NAVTYPE_TO_CONFIG_POS[EXPLORE_NAV_TYPE_WORLD_MISSION](self, wm_id)
		if _pos then
			local _p = exploreMapUtil.cocosToTile(ccp(_pos[1], _pos[2]), self.map_height, self.map_tile_size)

			self.wm_effect = CCArmature:create("tx_0052")
			local armatureAnimation = self.wm_effect :getAnimation()
			armatureAnimation:playByIndex(0)
			local effect_Scale = 0
			if not self.worldmap_show then
				local layerScale = self.map_layer:getScale()
				if layerScale ~= 0 then
					effect_Scale = 1/layerScale
				end
			else
				effect_Scale = self.worldmap_point_effect_scale
			end
			self.wm_effect:setScale(effect_Scale)
			self.wm_effect:setPosition(ccp(_p.x, _p.y))
			self.effect_layer:addChild(self.wm_effect, -1)
		end
	else
		closeTimer()
	end
end

ExploreMap.naviToPoint = function(self, pos_x,pos_y,str, _params)
	if isExplore then
		self:showMin()
	end

	local mapAttrs = getGameData():getWorldMapAttrsData()
	local port_id = getGameData():getPortData():getPortId()
	local params = {navType = EXPLORE_NAV_TYPE_POS, pos = {pos_x,pos_y}, name = str}
	if _params and type(_params) == "table" then
		for k, v in pairs(_params) do
			params[k] = v
		end
	end
	mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_POS , nil,nil,params)
end

ExploreMap.helpBtnCallBack = function(self, isShow, is_no_action)
	if self.help_layer.sAcHandler ~= nil then
		self.help_layer.tips_panel:stopAction(self.help_layer.sAcHandler)
		self.help_layer.sAcHandler = nil
	end
	local scale = nil
	local pos = nil
	local action1

	local is_visible = not isShow

	self.help_layer.tips_panel:setTouchEnabled(is_visible)
	self.widget_panel.btn_go:setTouchEnabled(is_visible)
	self.widget_panel.btn_worldmap:setTouchEnabled(is_visible)
	-- self.crown_layer.btn_help:setTouchEnabled(is_visible)

	self.widget_panel.touch_sceen:setTouchEnabled(isShow)

	if isShow then
		audioExt.playEffect(music_info.TOWN_CARD.res)
		self.help_layer.isShow = true
		scale = 1
		action1 = CCEaseBackOut:create(CCScaleTo:create(0.2, scale, scale))
	else
		self.help_layer.isShow = false
		scale = 0
		action1 = CCEaseBackIn:create(CCScaleTo:create(0.2, scale, scale))
	end
	local action2 = CCCallFunc:create(function()
		end)
	if is_no_action then
		self.help_layer.tips_panel:setScale(0)
	else
		self.help_layer.sAcHandler = CCSequence:createWithTwoActions(action1, action2)
		self.help_layer.tips_panel:runAction(self.help_layer.sAcHandler)
	end
end

ExploreMap.setVisibleOfNotice = function(self, visible)

end

ExploreMap.getBtnGo = function(self)
	if self.widget_panel then
		return self.widget_panel.btn_go
	end
end

ExploreMap.getSpriteById = function(self, id)
	local data = getGameData():getWorldMissionData():getWorldMissionList()[id]
	local star = display.newSprite("#map_task_"..data.cfg.star..".png")
	local type_to_res_table = {
		["explore_event"] = "explore",
		["business"] = "trade",
		["battle"] = "battle",
		["teambattle"] = "battle",
		["mission_world_mission"] = "battle",
	}
	local _type = display.newSprite("#map_task_"..type_to_res_table[data.cfg.type]..".png")
	_type:setScale(0.8)
	_type:setAnchorPoint(ccp(0.0,0.0))
	_type:setPosition(ccp(_type:getContentSize().width*0.08,_type:getContentSize().height*0.2))
	star:addChild(_type)

	if getGameData():getSceneDataHandler():isInPortScene() then
		self.guide_icon = _type
	end

	return star
end

------------------------------------------------------------------------------------------------------------------------

ExploreMap.updatePortUnderCurArea = function(self, ports)
	if type(ports) ~= "table" then return end

	local exploreMapData = getGameData():getExploreMapData()
	local cur_area_info = self.area_map_dic[exploreMapData:getCurPointAreaId()]
	for k, id in pairs(ports) do
		local need_port = false
		if port_info[id].areaId == exploreMapData:getCurPointAreaId() then
			need_port = true
		else -- 判断是否相邻海域有衔接港口
			local pos = ccp(port_info[id].port_pos[1], port_info[id].port_pos[2])
			local _p = exploreMapUtil.cocosToTile(pos, self.map_height, self.map_tile_size)
			if cur_area_info.mapRect:containsPoint(ccp(_p.x, _p.y)) then
				need_port = true
			end
		end
		if need_port then
			self:updatePoint(id, EXPLORE_NAV_TYPE_PORT, true)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------

return ExploreMap
