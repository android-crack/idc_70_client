-- 点击探索小地图上面的点后左边显示的信息面板统一在这里创建
local goods_type_info=require('game_config/port/goods_type_info')
local ui_word = require("game_config/ui_word")
local explore_whirlpool = require("game_config/explore/explore_whirlpool")
local area_info = require("game_config/port/area_info")
local relic_info = require("game_config/collect/relic_info")
local port_info = require("game_config/port/port_info")

local goods_info = require("game_config/port/goods_info")
local port_area=require("game_config/port/port_area")
local relic_star_info = require("game_config/collect/relic_star_info")
local ui_utils = require("gameobj/ui_utils")
local music_info = require("game_config/music_info")
local base_info = require("game_config/base_info")

local random_loot_info = require("game_config/random/random_loot_info")
local equip_material_info = require("game_config/boat/equip_material_info")
local area_monster_reward = require("game_config/explore/area_monster_reward")

local ClsDataTools = require("module/dataHandle/dataTools")
local UiCommon = require("ui/tools/UiCommon")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local alert = require("ui/tools/alert")
local nobility_config = require("game_config/nobility_data")
local sailor_info = require("game_config/sailor/sailor_info")
local invest_cell = require('gameobj/port/clsInvestCell')
local port_lock = require('game_config/port/port_lock')
local ClsScrollView = require("ui/view/clsScrollView")

local RELIC_MAX_STAR = 7

local PointInfoPanel = class("PointInfoPanel", function() return UIWidget:create() end)

PointInfoPanel.NAVTYPE_TO_INIT_EVENT = {
	[EXPLORE_NAV_TYPE_PORT] = function(self, widget_panel) return self:initPortPointEvent(widget_panel) end,
	[EXPLORE_NAV_TYPE_SH] = function(self, widget_panel) return self:initStrongHoldPointEvent(widget_panel) end,
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = function(self, widget_panel) return self:initWhirlPoolPointEvent(widget_panel) end,
	[EXPLORE_NAV_TYPE_RELIC] = function(self, widget_panel) return self:initRelicPlacePointEvent(widget_panel) end,
	[EXPLORE_NAV_TYPE_OTHER] = function(self, widget_panel, id) return self:initOtherPointEvent(widget_panel, id) end,
	[EXPLORE_NAV_TYPE_PVE_PORT] = function(self, widget_panel) return self:initPvePortPointEvent(widget_panel) end,
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = function(self, widget_panel) return self:initTimePiratePointEvent(widget_panel) end,
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = function(self, widget_panel) return self:initMineralPointEvent(widget_panel) end,
}

--直接调用updateUI，切勿调用具体的updateXXXPointUI函数
PointInfoPanel.NAVTYPE_TO_UPDATE_UI = {
	[EXPLORE_NAV_TYPE_PORT] = function(self, id) return self:updatePortPointUI(id) end,
	[EXPLORE_NAV_TYPE_SH] = function(self, id) return self:updateStrongHoldPointUI(id) end,
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = function(self, id) return self:updateWhirlPoolPointUI(id) end,
	[EXPLORE_NAV_TYPE_RELIC] = function(self, id) return self:updateRelicPlacePointUI(id) end,
	[EXPLORE_NAV_TYPE_OTHER] = function(self, id) return self:updateOtherPointUI(id) end,
	[EXPLORE_NAV_TYPE_PVE_PORT] = function(self, id) return self:updatePvePortPointUI(id) end,
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = function(self, id) return self:updateTimePiratePointUI(id) end,
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = function(self, id) return self:updateMineralPointUI(id) end,
	[EXPLORE_NAV_TYPE_WORLD_MISSION] = function(self,id)
		return self:updateWorldMissionPointUI(id) end,
}

PointInfoPanel.NAVTYPE_TO_UI_JSON = {
	[EXPLORE_NAV_TYPE_PORT] = "json/worldmap_port_info.json",
	[EXPLORE_NAV_TYPE_SH] = "json/worldmap_pve_stronghold.json",
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = "json/worldmap_reverse_info.json",
	[EXPLORE_NAV_TYPE_RELIC] = "json/worldmap_relic_info.json",
	[EXPLORE_NAV_TYPE_OTHER] = "json/worldmap_area_info.json",
	[EXPLORE_NAV_TYPE_PVE_PORT] = "json/worldmap_pve_port.json",
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = "json/worldmap_rank.json",
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = "json/worldmap_ore.json",
}

PointInfoPanel.NAVTYPE_TO_NEED_WIDGET_NAME = {
	[EXPLORE_NAV_TYPE_PORT] = {
		{name = "target_port_info"}, -- 港口名字
		{name = "invest_stage_num"}, -- 投资阶段
		{name = "port_task"}, -- 港口任务
		{name = "port_task_name"}, -- 任务内容
		{name = "goods_need_type"}, -- 需求商品名字
		{name = "goods_num"}, -- 商品当前数/总数
		{name = "sell_goods"}, -- 投资阶段奖励 for定位
		{name = "area_name"},

	},
	[EXPLORE_NAV_TYPE_SH] = {
		{name = "stronghold_power_num"},
		{name = "stronghold_power"},
		{name = "need_level_num"},
		{name = "material_icon_1"},
		{name = "material_amount_1"},
		{name = "material_icon_2"},
		{name = "material_amount_2"},
	},
	[EXPLORE_NAV_TYPE_WHIRLPOOL] = {
		{name = "reverse_other_1", children = {"reverse_unlock"}},
		{name = "reverse_other_2", children = {"reverse_unlock"}},
		{name = "reverse_other_3", children = {"reverse_unlock"}},
		{name = "reverse_other_4", children = {"reverse_unlock"}},
		{name = "reverse_other_5", children = {"reverse_unlock"}},
		{name = "reverse_other_6", children = {"reverse_unlock"}},
		{name = "reverse_other_7", children = {"reverse_unlock"}},
		{name = "area_name"},
	},
	[EXPLORE_NAV_TYPE_RELIC] = {
		{name = "explore_progress_percent"},
		{name = "bar"},
		{name = "star_bg_1", children = {"star_1"}},
		{name = "star_bg_2", children = {"star_2"}},
		{name = "star_bg_3", children = {"star_3"}},
		{name = "star_bg_4", children = {"star_4"}},
		{name = "star_bg_5", children = {"star_5"}},
		{name = "star_bg_6", children = {"star_6"}},
		{name = "star_bg_7", children = {"star_7"}},
		{name = "baowu_icon"},
		{name = "baowu_amount"},
		{name = "tips_available"},
		{name = "tips_finished"},
		{name = "unlock_tips"},
		{name = "share_panel"},
		{name = "area_name"},
	},
	[EXPLORE_NAV_TYPE_OTHER] = {
		{name = "area_info"},
	},
	[EXPLORE_NAV_TYPE_PVE_PORT] = {
		{name = "task"},
		{name = "task_name"},
		{name = "port_power_num"},
		{name = "need_level_num"},
	},
	[EXPLORE_NAV_TYPE_TIME_PIRATE] = {
		{name = "rank_panel"},
	},
	-- [EXPLORE_NAV_TYPE_MINERAL_POINT] = {
	-- 	{name = "rule_panel"},
	-- 	{name = "rank_panel"},
	-- },
}

PointInfoPanel.ctor = function(self)
	self.plist_res = {
		["ui/baowu.plist"] = 1,
		["ui/box.plist"] = 1,
		["ui/equip_icon.plist"] =1,
		["ui/material_icon.plist"] =1,
	}

	LoadPlist(self.plist_res)

	self.m_exit_layer = display.newLayer()
	self.m_exit_layer:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
	self:addCCNode(self.m_exit_layer)

	self.cocostudio_ui_layer = nil
	self.cur_point_id = -1
	self.cur_nav_type = -1

	self.widget_panel_dic = {}
	self.cur_widget_panel = nil
	self.time_panel = nil

	self.is_enable = true
end

--------------

PointInfoPanel.setVisible = function(self, is_show)
	self:setEnabled(is_show)
end

PointInfoPanel.initUI = function(self)
	self.cocostudio_ui_layer = UIWidget:create()
	self:addChild(self.cocostudio_ui_layer)
end

--------------

PointInfoPanel.initEvent = function(self)

end

PointInfoPanel.initPortPointEvent = function(self, widget_panel)

end

PointInfoPanel.initStrongHoldPointEvent = function(self, widget_panel)

end

PointInfoPanel.initWhirlPoolPointEvent = function(self, widget_panel)

end

PointInfoPanel.initRelicPlacePointEvent = function(self, widget_panel)

end

PointInfoPanel.initOtherPointEvent = function(self, widget_panel, area_id)
	local area_info = widget_panel.area_info
	local port_panel = getConvertChildByName(area_info, "port_panel")
	port_panel.port_amount_lab = getConvertChildByName(port_panel, "port_amount_num")
	widget_panel.port_panel = port_panel
	
	local relic_panel = getConvertChildByName(area_info, "relic_panel")
	relic_panel.relic_amount_lab = getConvertChildByName(relic_panel, "relic_amount_num")
	widget_panel.relic_panel = relic_panel
	
	port_panel:setTouchEnabled(true)
	port_panel:addEventListener(function()
			self:updateAreaBoxShow(widget_panel, "port")
		end, TOUCH_EVENT_ENDED)
	relic_panel:setTouchEnabled(true)
	relic_panel:addEventListener(function()
			self:updateAreaBoxShow(widget_panel, "relic")
		end, TOUCH_EVENT_ENDED)
	
	local stars_panel = getConvertChildByName(area_info, "box_star_panel")
	local pos = stars_panel:getPosition()
	local size = stars_panel:getSize()
	stars_panel.pos_info = {x = pos.x, y = pos.y, width = size.width, height = size.height, star_len = size.width/4}
	local star_sprs = {}
	for i = 1, 4 do
		star_sprs[i] = getConvertChildByName(stars_panel, "box_star_"..i)
	end
	stars_panel.star_sprs = star_sprs
	widget_panel.stars_panel = stars_panel
	
	local box_info = {}
	box_info.port_box_lab = getConvertChildByName(area_info, "box_txt_port")
	box_info.relic_box_lab = getConvertChildByName(area_info, "box_txt_relic")
	box_info.box_close_btn = getConvertChildByName(area_info, "btn_box_closed")
	box_info.box_empty_btn = getConvertChildByName(area_info, "btn_box_empty")
	box_info.box_full_btn = getConvertChildByName(area_info, "btn_box_full")
	widget_panel.box_info = box_info
	
	box_info.box_close_btn:setEnabled(true)
	box_info.box_close_btn:addEventListener(function()
			widget_panel.reward_tips_panel:setOpacity(255)
			widget_panel.reward_tips_panel:stopAllActions()
			widget_panel.reward_tips_panel:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2),
				CCFadeOut:create(0.5)))
		end, TOUCH_EVENT_BEGAN)
	
	box_info.box_full_btn:setPressedActionEnabled(true)
	box_info.box_full_btn:setEnabled(true)
	box_info.box_full_btn:addEventListener(function()
			local areaRewardData = getGameData():getAreaRewardData()
			local area_id = widget_panel.area_id
			if widget_panel.show_tag_str == "port" then
				areaRewardData:askGetAreaPortReward(area_id)
			else
				areaRewardData:askGetAreaRelicReward(area_id)
			end
			areaRewardData:askAreaRewardInfo(area_id)
		end, TOUCH_EVENT_ENDED)
	box_info.box_empty_btn:setEnabled(true)
	
	local reward_tips_panel = getConvertChildByName(area_info, "reward_tips")
	reward_tips_panel.icon_spr = getConvertChildByName(reward_tips_panel, "diamond_icon")
	reward_tips_panel.num_lab = getConvertChildByName(reward_tips_panel, "diamond_num")
	widget_panel.reward_tips_panel = reward_tips_panel
	
	reward_tips_panel:setVisible(true)
	reward_tips_panel:setOpacity(0)
	
	widget_panel.area_reverse_name_lab = getConvertChildByName(area_info, "area_reverse_name")
end

PointInfoPanel.initPvePortPointEvent = function(self, widget_panel)

end

PointInfoPanel.initTimePiratePointEvent = function(self, widget_panel)
	local rank_panel = widget_panel.rank_panel
	rank_panel.my_info = {}
	rank_panel.my_info.rank_lab = getConvertChildByName(rank_panel, "my_rank")
	rank_panel.my_info.hurt_lab = getConvertChildByName(rank_panel, "my_hurt")
	rank_panel.my_info.name_lab = getConvertChildByName(rank_panel, "my_name")
	rank_panel.my_info.title_lab = getConvertChildByName(rank_panel, "person_rank_title") 
	rank_panel.my_info.title_str = rank_panel.my_info.title_lab:getStringValue()
end

PointInfoPanel.initMineralPointEvent = function(self, widget_panel)
	local attack_panel = getConvertChildByName(widget_panel, "ore_progress")
	local wait_panel = getConvertChildByName(widget_panel, "ore_cd")
	attack_panel:setVisible(true)
	wait_panel:setVisible(true)

	widget_panel.port_name_lab = getConvertChildByName(widget_panel, "port_name")

	attack_panel.hp_lab = getConvertChildByName(attack_panel, "last_amount")
	local bar_uis = {}
	for i = 1, 5 do
		local item = {}
		item.per_ui = getConvertChildByName(attack_panel, string.format("progress_%d", i))
		item.per_bar = getConvertChildByName(item.per_ui, string.format("progress_bar_%d", i))
		item.per_lab = getConvertChildByName(item.per_ui, string.format("percent_%d", i))
		item.name_lab = getConvertChildByName(item.per_ui, string.format("text_%d", i))
		item.per_ui:setVisible(false)
		bar_uis[i] = item
	end
	attack_panel.bar_uis = bar_uis

	widget_panel.attack_panel = attack_panel
	widget_panel.wait_panel = wait_panel
end

--------------

PointInfoPanel.updateViewIsEnabled = function(self, nav_type)
	if self.widget_panel_dic then
		for k, v in pairs(self.widget_panel_dic) do
			if not tolua.isnull(v) then
				if k == nav_type then
					v:setEnabled(self:isEnabled())
				else
					v:setEnabled(false)
				end
			end
		end
	end
end

PointInfoPanel.updateUI = function(self, id, nav_type)
	if not nav_type then return false end
	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map) then
		explore_map:setUnSelectDescVisible(true)
		-- explore_map:resetSupplyInfo(nav_type ~= EXPLORE_NAV_TYPE_PORT)
		self.time_panel = explore_map:getTimePanel()
		self.time_panel:stopAllActions()
		self.time_panel:setEnabled(false)
	end

	if self.cur_nav_type == nav_type then
		if not self.NAVTYPE_TO_UI_JSON[nav_type] then
			local explore_map_data = getGameData():getExploreMapData()
			local area_id = explore_map_data:getCurAreaId()
			local cur_click_area_id = explore_map_data:getCurClickAreaId()
			if cur_click_area_id and cur_click_area_id > 0 then
				area_id = cur_click_area_id
			end
			explore_map:selectPoint(area_id, EXPLORE_NAV_TYPE_OTHER)
			return
		end
		if not tolua.isnull(self.cur_widget_panel) then
			if not tolua.isnull(self.cur_widget_panel.level_num) then
				self.cur_widget_panel.level_num:stopAllActions()
			end
			self.cur_widget_panel:stopAllActions()
		end
		local result = self.NAVTYPE_TO_UPDATE_UI[nav_type](self, id)
		self:updateViewIsEnabled(nav_type)
		return result
	end

	if not tolua.isnull(self.cur_widget_panel) then
		if not tolua.isnull(self.cur_widget_panel.level_num) then
			self.cur_widget_panel.level_num:stopAllActions()
		end
		self.cur_widget_panel:setEnabled(false)
		self.cur_widget_panel:setVisible(false)
		self.cur_widget_panel:setTouchEnabled(false)
		self.cur_widget_panel:stopAllActions()
	end
	self.cur_point_id = id
	self.cur_nav_type = nav_type
	if tolua.isnull(self.widget_panel_dic[nav_type]) then
		if not self.NAVTYPE_TO_UI_JSON[nav_type] then
			EventTrigger(EVENT_EXPLORE_HIDE_GOAL_PORT)
			return
		end
		local widget_panel = GUIReader:shareReader():widgetFromJsonFile(self.NAVTYPE_TO_UI_JSON[nav_type])
		self.widget_panel_dic[nav_type] = widget_panel
		self.cocostudio_ui_layer:addChild(widget_panel)
		for k1,v1 in pairs(self.NAVTYPE_TO_NEED_WIDGET_NAME[nav_type]) do
			widget_panel[v1.name] = getConvertChildByName(widget_panel, v1.name)
			if v1.children then
				for k2, v2 in pairs(v1.children) do
					widget_panel[v1.name][v2] = getConvertChildByName(widget_panel[v1.name], v2)
				end
			end
		end

		self.NAVTYPE_TO_INIT_EVENT[nav_type](self, widget_panel, id)
	end
	self.cur_widget_panel = self.widget_panel_dic[nav_type]
	self.cur_widget_panel:setVisible(true)
	self.cur_widget_panel:setTouchEnabled(true)
	
	missionGuide:pushGuideBtn(on_off_info.PORT_TOWN_APPOINT.value,
	 {rect = CCRect(70, 168, 100, 40), guideLayer = self})
	local result = self.NAVTYPE_TO_UPDATE_UI[nav_type](self, id)
	self:updateViewIsEnabled(nav_type)
	return result
end

PointInfoPanel.createGoodCell = function ( self,id )
	-- body
end



--港口信息
PointInfoPanel.updatePortPointUI = function(self, id)
	-- 投资信息 根据港口id
	local invest_info = getGameData():getInvestData():getInvestDataByPortId(id)

	-- 港口投资级别
	local main_pnl = self.cur_widget_panel
	if not invest_info then
		-- print(' 没有该港口的投资信息 重新发协议请求该港口投资信息 港口id为: ',id)
		getGameData():getInvestData():sendPortInvest(id)
		main_pnl:setVisible(false)
		return
	end

	main_pnl:setVisible(true)

	local market_data = getGameData():getMarketData()
	-- 市场信息中投资级别?
	local lv_market = market_data:getInvestStepByPortId(id)

	main_pnl.invest_stage_num:setText(lv_market)

	main_pnl.target_port_info:setText(port_info[id].name)

	main_pnl.area_name:setText(area_info[port_info[id].areaId].name)

	-- 需求商品名字
	getGameData():getWorldMapAttrsData():getPortNeed(id,function(good_class_ids)
		if not tolua.isnull(self) and good_class_ids then
			local good_class_str = ""
			for k,v in ipairs(good_class_ids) do
				if goods_type_info[v] then
					good_class_str = good_class_str..(goods_type_info[v].name).."  "
				end
			end
			main_pnl.goods_need_type:setText(good_class_str)
		end
	end)
	-- 商品 当前数/总数
	local cur, max = getGameData():getMarketData():getStoreGoodNumByPortId(id)
	-- print(cur,max)
	main_pnl.goods_num:setText(string.format('%d / %d',tonumber(cur),tonumber(max)))

	--任务
	local task_port_dic = getGameData():getExploreMapData():getTaskPort()
	if task_port_dic[id] and task_port_dic[id][1] then
		local mission_info = getMissionInfo()
		main_pnl.port_task:setVisible(true)
		main_pnl.port_task_name:setText(string.format(ui_word.NAME_BOX, mission_info[task_port_dic[id][1]].name))
	else
		main_pnl.port_task:setVisible(false)
		main_pnl.port_task_name:setText("")
	end

	-- 获得的投资阶段奖励列表
	local index = 0
	main_pnl.sell_goods:removeAllChildren()
	local new_data = table.clone(port_lock[id])
	local length = #new_data
	table.sort(new_data,function ( a,b )
		return a.step < b.step
	end)
	for k,v in pairs(new_data) do
		local item = invest_cell.new(v,id,2)
		item.spr_item_icon:setGray(v.step > lv_market)
		item.spr_item_icon:setScale(item.spr_item_icon:getScale()*1.5)

		local btn_item_res = v.step <= lv_market and "common_item_bg2.png" or "common_item_bg5.png"
		item.btn_item:changeTexture(btn_item_res, btn_item_res, btn_item_res, UI_TEX_TYPE_PLIST)

		local pos = item.spr_item_icon:getPosition()
		item.spr_item_icon:setPosition(ccp(pos.x, pos.y - 10))

		item.lbl_step:setVisible(false)
		item.lbl_goods_type:setVisible(false)
		item.spr_goods_type_bg:setVisible(false)

		item:setScale(0.6)
		local row, col = (v.step-1)%4, (v.step-1)/4
		col = math.floor(col)

		-- print(v.step,row,col)
		local spacing = 5
		local x = row * 60
		local y = - col * 60
		item:setPosition(ccp(x, y))
		local ui_wgt = UIWidget:create()
		ui_wgt:addChild(item)
		ui_wgt:setPosition(ccp(0,-75))
		main_pnl.sell_goods:addChild(ui_wgt)
	end
	return true
end

--海上据点信息
PointInfoPanel.updateStrongHoldPointUI = function(self, id)

	return true
end

PointInfoPanel.updateWorldMissionPointUI = function ( self,id )
	return true
end

--漩涡信息
PointInfoPanel.updateWhirlPoolPointUI = function(self, id)
	local onOffData = getGameData():getOnOffData()
	local explore_map_data = getGameData():getExploreMapData()
	local reverse_item = nil
	local reverse_item_color = nil
	local reverse_item_text = nil
	local reverse_num = #explore_whirlpool
	local reverse_item_index = 1
	for i = 1, reverse_num do
		if i ~= id then
			reverse_item = self.cur_widget_panel["reverse_other_"..reverse_item_index]
			reverse_item_text = (explore_whirlpool[i].name).."["..(area_info[i].name).."]"
			reverse_item_index = reverse_item_index + 1

			local switch_num = on_off_info[explore_whirlpool[i].switch_key].value
			if not onOffData:isOpen(switch_num) then
				setUILabelColor(reverse_item.reverse_unlock, ccc3(dexToColor3B(COLOR_STOOL)))
			end

			local open_sys_switch
			open_sys_switch = function( isOpen )
				-- body
				if not tolua.isnull(reverse_item) then
					reverse_item.reverse_unlock:setText(reverse_item_text)
				end
			end
			onOffData:pushOpenBtn( switch_num,
				{ name = string.format( "map_info_panel_whirlpool_2d%0.2d", i ), callBack = open_sys_switch } )
		end
	end

	self.cur_widget_panel.area_name:setText(area_info[explore_whirlpool[id].sea_index].name)

	return true
end

--右边面板遗迹信息
PointInfoPanel.updateRelicPlacePointUI = function(self, id)
	local collect_data_handle = getGameData():getCollectData()
	if not collect_data_handle:isDiscoveryRelic(id) then
		self.cur_widget_panel:setVisible(false)
		return false
	else
		self.cur_widget_panel:setVisible(true)
		local relic_data = collect_data_handle:getRelicInfoById(id)
		local relic_base = relic_data.relicInfo
		local active = collect_data_handle:isCanDigOrExplore(id)
		self.cur_widget_panel.tips_available:setVisible(active)
		self.cur_widget_panel.tips_finished:setVisible(not active)

		self.cur_widget_panel.area_name:setText(area_info[relic_info[id].areaId].name)

		for i = 1, RELIC_MAX_STAR do
			local star_bg_name = string.format("star_bg_%d", i)
			local star_name = string.format("star_%d", i)
			self.cur_widget_panel[star_bg_name]:setVisible(false)
			self.cur_widget_panel[star_bg_name][star_name]:setVisible(false)
		end
		self.cur_widget_panel["baowu_icon"]:setVisible(true)
		self.cur_widget_panel["baowu_amount"]:setVisible(true)

		--探索度
		for i = 1, relic_base.max_star do
			local star_bg_name = string.format("star_bg_%d", i)
			local star_name = string.format("star_%d", i)
			self.cur_widget_panel[star_bg_name]:setVisible(true)
			if i <= relic_data.star then
				self.cur_widget_panel[star_bg_name][star_name]:setVisible(true)
			end
		end

		local max_explore_point_n = relic_star_info[relic_base.max_star or 1].explorePoint
		local now_explore_point_n = relic_data.explorePoint
		local progress = Math.floor(now_explore_point_n / max_explore_point_n * 100 + 0.5)

		self.cur_widget_panel.explore_progress_percent:setText(string.format("%d%s", progress, "%"))
		self.cur_widget_panel.bar:setPercent(progress)

		local path = string.format("game_config/relic/relic_%s_info", id)
		local relic_reward = require(path)

		local show_reward = {}
		for k, v in ipairs(relic_reward) do
			if v.type ~= "prosper" then
				show_reward[#show_reward + 1] = v
			end
		end

		local next_star = (relic_data.star or 0) + 1
		if next_star > relic_base.max_star then
			next_star = relic_base.max_star
		end
		
		local next_reward = show_reward[next_star]
		local res_info = getRewardRes(next_reward.type)
		local res = nil
		if type(res_info.res) == "function" then
			res = res_info.res(next_reward.id)
		else
			res = res_info.res
		end

		self.cur_widget_panel["baowu_icon"]:changeTexture(convertResources(res), UI_TEX_TYPE_PLIST)
		local amount = string.format("x%d  [%d%s]", next_reward.cnt, next_star, ui_word.MAIN_STAR)
		self.cur_widget_panel["baowu_amount"]:setText(amount)

		--解锁条件面板
		local unlock_manager = {}
		local unlock_tips = self.cur_widget_panel["unlock_tips"]
		unlock_tips.unlock_manager = unlock_manager
		unlock_manager.title = getConvertChildByName(unlock_tips, "unlock_txt")
		unlock_manager.objs = {}

		unlock_manager.getObjByIndex = function(self, index)
			return self.objs[index]
		end

		unlock_manager.insertObj = function(self, obj)
			table.insert(self.objs, obj)
		end

		local UNLOCK_NUM = 3
		for k = 1, UNLOCK_NUM do
			local obj = getConvertChildByName(unlock_tips, string.format("unlock_tips_%d", k))
			obj:setVisible(false)
			unlock_manager:insertObj(obj)
		end
		
		--分享面板
		local share_manager = {}
		local share_panel = self.cur_widget_panel["share_panel"]
		share_panel.share_manager = share_manager

		share_manager.setVisible = function(self, enable)
			self.btn:setVisible(enable)
			self.btn:setTouchEnabled(enable)
		end

		share_manager.num = getConvertChildByName(share_panel, "share_num")
		local btn_share = getConvertChildByName(share_panel, "btn_share")
		btn_share:setPressedActionEnabled(true)
		btn_share:addEventListener(function()
			local guild_info_data = getGameData():getGuildInfoData()
		    local guild_id = guild_info_data:getGuildId()
		    local is_add_guild = (guild_id ~= nil and guild_id ~= 0 and true or false) 
		    if not is_add_guild then
		    	alert:warning({msg = ui_word.STR_GUILD_ADD_TIPS})
		    	return
		    end

			local share_times = collect_data_handle:getShareTimes()
			if share_times < 1 then
				alert:warning({msg = ui_word.RELIC_SHARE_TIME_OVER})
				return
			else
				local ui_word = require("game_config/ui_word")
				local show_txt = string.format(ui_word.RELIC_SHARE_TIP, relic_data.relicInfo.name)
				alert:showAttention(show_txt, function() 
					collect_data_handle:askShareRelic(relic_data.id)
				end)
			end
		end, TOUCH_EVENT_ENDED)
		share_manager.btn = btn_share
		local share_panel_visible_func = share_panel.setVisible
		share_panel.setVisible = function(self, enable)
			share_panel_visible_func(self, enable)
			self.share_manager:setVisible(enable)
		end
		
		local is_diged_relic = collect_data_handle:isDigedRelic(id)
		if is_diged_relic then
			share_panel:setVisible(true)
			unlock_tips:setVisible(false)
			share_manager.num:setText(string.format("%d/%d", collect_data_handle:getShareTimes(), collect_data_handle:getMaxShareTimes()))
		else
			share_panel:setVisible(false)
			local relic_data = getGameData():getRelicData()
			local is_have_cond = relic_data:isHaveUnlockConds(id)
			if is_have_cond then
				local is_ok = true
				local relic_cfg_item = relic_info[id]
				for k, v in ipairs(relic_cfg_item.active_conds) do
					local obj = unlock_tips.unlock_manager:getObjByIndex(k)
					if not tolua.isnull(obj) then
						obj:setVisible(true)
						local show_txt = collect_data_handle:getShowText(v)
						obj:setText(show_txt)
						local color = COLOR_GREEN
						if not relic_data:isUnlockOk(id, v) then
							is_ok = false
							color = COLOR_RED
						end
						obj:setUILabelColor(color)
					end
				end
				unlock_tips:setVisible(not is_ok)
			else
				unlock_tips:setVisible(false)
			end
		end
		return true
	end
end

local getCurStar
getCurStar = function(step_n, rewards_info)
	local star_n = step_n
	if step_n < #rewards_info then
		star_n = step_n + 1
	end
	return star_n
end

local getIsFinish
getIsFinish = function(step_n, rewards_info)
	if step_n >= #rewards_info then
		return true
	end
	return false
end

local checkAeraBoxShow
checkAeraBoxShow = function(area_id)
	local areaRewardData = getGameData():getAreaRewardData()
	local area_status_info = areaRewardData:getAreaRewardStatus(area_id)
	local area_reward_info = areaRewardData:getAreaReward(area_id)
	if area_status_info then
		local port_rewards = area_reward_info.port
		local relic_rewards = area_reward_info.relic
		local cur_port_step = area_status_info.investStar
		local cur_relic_step = area_status_info.relicStar
		local cur_port_sum = area_status_info.investSum
		local cur_relic_sum = area_status_info.relicSum
		local port_star_num = getCurStar(cur_port_step, port_rewards)
		local relic_star_num = getCurStar(cur_relic_step, relic_rewards)
		if not getIsFinish(cur_port_step, port_rewards) and cur_port_sum >= port_rewards[port_star_num].point then
			return true, "port"
		elseif not getIsFinish(cur_relic_step, relic_rewards) and cur_relic_sum >= relic_rewards[relic_star_num].point then
			return true, "relic"
		end
	end
end

--其它信息
PointInfoPanel.updateOtherPointUI = function(self, id)
	self.cur_widget_panel.port_panel.port_amount_lab:setText("")
	self.cur_widget_panel.relic_panel.relic_amount_lab:setText("")
	if self.cur_widget_panel.area_id ~= id then
		self.cur_widget_panel.area_id = id
		getGameData():getAreaRewardData():askAreaRewardInfo(id)
	end

	local explore_map_data = getGameData():getExploreMapData()

	self.cur_widget_panel.area_reverse_name_lab:setText(explore_map_data:getWhirlByAreaId(id).name)
	
	self:updateAreaBoxShow(self.cur_widget_panel, self.cur_widget_panel.show_tag_str or "port")

	local has_rewarded, _type = checkAeraBoxShow(id)
	if has_rewarded then
		self:updateAreaBoxShow(self.cur_widget_panel, _type)
	end
	return true
end

PointInfoPanel.updateAreaBoxShow = function(self, widget_panel, show_tag_str)
	if not widget_panel.box_info then return end
	self.cur_widget_panel.show_tag_str = show_tag_str
	local is_port_show = false
	local is_relic_show = false
	if show_tag_str == "port" then
		is_port_show = true
	elseif show_tag_str == "relic" then
		is_relic_show = true
	end
	widget_panel.box_info.port_box_lab:setVisible(is_port_show)
	widget_panel.box_info.relic_box_lab:setVisible(is_relic_show)
	
	self.cur_widget_panel.box_info.box_close_btn:setEnabled(false)
	self.cur_widget_panel.box_info.box_close_btn:setVisible(false)
	self.cur_widget_panel.box_info.box_empty_btn:setEnabled(false)
	self.cur_widget_panel.box_info.box_empty_btn:setVisible(false)
	self.cur_widget_panel.box_info.box_full_btn:setEnabled(false)
	self.cur_widget_panel.box_info.box_full_btn:setVisible(false)
	
	local area_id = widget_panel.area_id
	local star_num = 0
	local areaRewardData = getGameData():getAreaRewardData()
	local area_status_info = areaRewardData:getAreaRewardStatus(area_id)
	local area_reward_info = areaRewardData:getAreaReward(area_id)
	
	if area_status_info then
		
		local rewards = nil
		local port_rewards = area_reward_info.port
		local relic_rewards = area_reward_info.relic
		
		local cur_step = nil
		local cur_port_step = area_status_info.investStar
		local cur_relic_step = area_status_info.relicStar
		
		local cur_sum = nil
		local cur_port_sum = area_status_info.investSum
		local cur_relic_sum = area_status_info.relicSum
		
		if is_port_show then
			rewards = port_rewards
			cur_step = cur_port_step
			cur_sum = cur_port_sum
		else
			rewards = relic_rewards
			cur_step = cur_relic_step
			cur_sum = cur_relic_sum
		end
		star_num = getCurStar(cur_step, rewards)
		local cur_reward = rewards[star_num]
		
		if getIsFinish(cur_step, rewards) then
			self.cur_widget_panel.box_info.box_empty_btn:setEnabled(true)
			self.cur_widget_panel.box_info.box_empty_btn:setVisible(true)
		elseif cur_sum >= cur_reward.point then
			self.cur_widget_panel.box_info.box_full_btn:setEnabled(true)
			self.cur_widget_panel.box_info.box_full_btn:setVisible(true)
		else
			self.cur_widget_panel.box_info.box_close_btn:setEnabled(true)
			self.cur_widget_panel.box_info.box_close_btn:setVisible(true)
		end

		widget_panel.reward_tips_panel.num_lab:setText(tostring(cur_reward.gold))
		local port_star_num = getCurStar(cur_port_step, port_rewards)
		local relic_star_num = getCurStar(cur_relic_step, relic_rewards)
		
		self.cur_widget_panel.port_panel.port_amount_lab:setText(cur_port_sum .. "/" .. port_rewards[port_star_num].point)
		self.cur_widget_panel.relic_panel.relic_amount_lab:setText(cur_relic_sum .. "/" .. relic_rewards[relic_star_num].point)
	end
	
	local stars_panel = self.cur_widget_panel.stars_panel
	local star_pos_info = stars_panel.pos_info
	local pos_x = star_pos_info.x + star_pos_info.width/2 - star_num*0.5*star_pos_info.star_len
	stars_panel:setPosition(ccp(pos_x, star_pos_info.y))
	for i, star_spr in ipairs(stars_panel.star_sprs) do
		if i <= star_num then
			star_spr:setVisible(true)
		else
			star_spr:setVisible(false)
		end
	end
end

--港口信息(pve)
PointInfoPanel.updatePvePortPointUI = function(self, id)
	local explore_map_data = getGameData():getExploreMapData()
	local port_pve_data = getGameData():getPortPveData()
	local pve_info = port_pve_data:getPortPveInfo(id)
	if not pve_info then return end
	local pve_cp_info = port_pve_data:getPortCpInfo(pve_info.checkpointId)
	local is_meet_level, need_level = port_pve_data:isPortMeetLevel(id)
	local diff_info = port_pve_data:getPortDiffInfo(id)
	local step_info = pve_cp_info.stepInfos[pve_info.step + 1]

	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	setUILabelColor(explore_map.widget_panel.purpose_name, ccc3(dexToColor3B(COLOR_RED_STROKE)))

	--任务
	local task_port_dic = explore_map_data:getTaskPort()
	if task_port_dic[id] and task_port_dic[id][1] then
		local mission_info = getMissionInfo()
		self.cur_widget_panel.task:setVisible(true)
		self.cur_widget_panel.task_name:setText(string.format(ui_word.NAME_BOX, mission_info[task_port_dic[id][1]].name))
	else
		self.cur_widget_panel.task:setVisible(false)
		self.cur_widget_panel.task_name:setText("")
	end
	self.cur_widget_panel.port_power_num:setText(pve_info.enemy_power .. string.format(ui_word.NAME_BOX_2,diff_info.diffStr))
	setUILabelColor(self.cur_widget_panel.port_power_num, ccc3(dexToColor3B(diff_info.diffColor)))

	self.cur_widget_panel.need_level_num:setText("Lv."..need_level)
	if is_meet_level then
		setUILabelColor(self.cur_widget_panel.need_level_num, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))
	else
		setUILabelColor(self.cur_widget_panel.need_level_num, ccc3(dexToColor3B(COLOR_RED_STROKE)))
	end
end

local getHurtW
getHurtW = function(hurt)
	hurt = hurt/10000
	return string.format("%.2f", hurt)
end

local ClsRankListCell = class("ClsRankListCell", require("ui/view/clsScrollViewItem"))

ClsRankListCell.updateUI = function(self, cell_date, cell_ui)
	local list_panel = getConvertChildByName(cell_ui, "list_panel")
	local rank_lab = getConvertChildByName(list_panel, "rank_num")
	local name_lab = getConvertChildByName(list_panel, "player_name")
	local hurt_lab = getConvertChildByName(list_panel, "hurt_text")
	rank_lab:setText(tostring(cell_date.rank))
	name_lab:setText(cell_date.name)
	hurt_lab:setText(getHurtW(cell_date.hurt))
end

--时段海盗
PointInfoPanel.updateTimePiratePointUI = function(self, id)
	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map) then
		explore_map:setUnSelectDescVisible(false)
	end

	local worldmap_rank_ui = self.cur_widget_panel
	local rank_panel = worldmap_rank_ui.rank_panel
	local list_view = self.cocostudio_ui_layer.list_view
	if not tolua.isnull(list_view) then
		list_view:removeFromParentAndCleanup(true)
	end
	rank_panel.my_info.rank_lab:setVisible(false)
	rank_panel.my_info.hurt_lab:setVisible(false)
	rank_panel.my_info.name_lab:setVisible(false)

	local pirate_data = getGameData():getExplorePirateEventData():getPirateByCfgId(id)
	if not pirate_data then
		EventTrigger(EVENT_EXPLORE_HIDE_GOAL_PORT)
		return
	end

	explorePirateEventData = getGameData():getExplorePirateEventData()
	explorePirateEventData:askPersonRank(pirate_data.cfg_item.area_id)

	local total_list = explorePirateEventData:getPersonRankList() or {}
	local info = total_list.ranks or {}
	local my_name = getGameData():getPlayerData():getName()

	-- 设置等级段
	local region = total_list.region or getGameData():getPlayerData():getGradeInterval()
	local title = rank_panel.my_info.title_str
	title = title.."("..string.format(ui_word.STR_LV_RANGE, region * 10 - 9, region * 10)..")"
	rank_panel.my_info.title_lab:setText(title)

	if #info > 0 then
		local list_view = ClsScrollView.new(230, 210, true, function()
				return GUIReader:shareReader():widgetFromJsonFile("json/worldmap_rank_list.json")
			end, {is_fit_bottom = true})
		rank_panel:addChild(list_view)

		rank_panel.rank_items = {}
		for k, data in ipairs(info) do
			if data.hurt >= 100 then
				local item = ClsRankListCell.new(CCSize(220, 30), data)
				rank_panel.rank_items[#rank_panel.rank_items + 1] = item
			end
		end
		list_view:addCells(rank_panel.rank_items)
		self.cocostudio_ui_layer.list_view = list_view
	end
	local my_rank = total_list.my_rank
	if my_rank then
		rank_panel.my_info.rank_lab:setVisible(true)
		rank_panel.my_info.hurt_lab:setVisible(true)
		rank_panel.my_info.name_lab:setVisible(true)

		if my_rank.rank <= 0 then
			rank_panel.my_info.rank_lab:setText("10+")
		else
			rank_panel.my_info.rank_lab:setText(tostring(my_rank.rank))
		end
		rank_panel.my_info.name_lab:setText(tostring(my_rank.name))
		rank_panel.my_info.hurt_lab:setText(getHurtW(my_rank.hurt))
	end
	if self.time_panel then
		local time_callback = function()
			local left_time = getGameData():getExplorePirateEventData():getRemainTime()
			if left_time <= 0 then
				self.time_panel:stopAllActions()
				self.time_panel:setEnabled(false)
			else
				self.time_panel.time_num:setText(ClsDataTools:getTimeStrNormal(left_time))
			end
		end
		self.time_panel:setEnabled(true)
		local time_act = UiCommon:getRepeatAction(1, time_callback)
		self.time_panel:runAction(time_act)
		time_callback()
	end
end

PointInfoPanel.updateMineralPointUI = function(self, id)
	local areaCompetitionHander = getGameData():getAreaCompetitionData()
	areaCompetitionHander:askMineralAttackData(id)
	areaCompetitionHander:askTryRobberyMineral()
	if areaCompetitionHander:isOpen() then
		self:updateMineralAttackUI(id)
	else
		self:updateMineralWaitUI(id)
	end
end

--海域争霸开战期
PointInfoPanel.updateMineralAttackUI = function(self, id)
	local areaCompetitionHander = getGameData():getAreaCompetitionData()
	local attack_panel = self.cur_widget_panel.attack_panel
	local wait_panel = self.cur_widget_panel.wait_panel
	attack_panel:setEnabled(true)
	attack_panel:setVisible(true)
	wait_panel:setEnabled(false)
	wait_panel:setVisible(false)
	local back_up_data = {attr = {}, port_hurt = {}}
	local attack_data = areaCompetitionHander:getMineralAttackData()
	if not attack_data then
		attack_data = back_up_data
	else
		local cfg_id = attack_data.attr.cfg_id or 0
		if cfg_id ~= id then
			attack_data = back_up_data
		end
	end
	local port_id = attack_data.attr.port or 0
	local total_hurt = attack_data.attr.total_hurt or 1
	local port_hurt = attack_data.port_hurt or {}
	local hp_n = attack_data.attr.hp or 0
	local mineral_config = areaCompetitionHander:getMineralPointConfig()[id]
	local max_hp_n = mineral_config.attr.enduring or 1

	local port_info_item = port_info[port_id]
	if port_info_item then
		self.cur_widget_panel.port_name_lab:setText(port_info_item.name)
	else
		self.cur_widget_panel.port_name_lab:setText(ui_word.NO_TIPS)
	end

	attack_panel.hp_lab:setText(string.format("%d/%d", hp_n, max_hp_n))

	if total_hurt <= 0 then total_hurt = 1 end
	for i, item in ipairs(attack_panel.bar_uis) do
		local info = port_hurt[i]
		if info then
			item.per_ui:setVisible(true)

			local port_name_str = port_info[info.portId].name
			item.name_lab:setText(port_name_str)
			local per_n = math.floor(info.hurt*100/total_hurt)
			item.per_bar:setPercent(per_n)
			item.per_lab:setText(string.format("%d%%", per_n))
		else
			item.per_ui:setVisible(false)
		end
	end

	local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	local widget_panel = explore_map:getWidgetPanel()
	local str_btn_txt = ui_word.STR_DEFEND_TIPS

	if my_guild_port_id ~= port_id or port_id == 0 then
		str_btn_txt = ui_word.STR_ATTACK_TIPS
	end

	if my_guild_port_id == 0 then
		str_btn_txt = ui_word.STR_ATTACK_TIPS
	end

	local explore_map_data = getGameData():getExploreMapData()
	if mineral_config.area_id ~= explore_map_data:getCurPointAreaId() then
		str_btn_txt = ui_word.NAVIGATE_NOW
	end

	widget_panel.btn_go.btn_go_text:setText(str_btn_txt)
end

--海域争霸休战期
PointInfoPanel.updateMineralWaitUI = function(self, id)
	local attack_panel = self.cur_widget_panel.attack_panel
	local wait_panel = self.cur_widget_panel.wait_panel
	attack_panel:setEnabled(false)
	attack_panel:setVisible(false)
	wait_panel:setEnabled(true)
	wait_panel:setVisible(true)
	local area_competition_data = getGameData():getAreaCompetitionData()
	local attack_data = area_competition_data:getMineralAttackData()

	if not attack_data then
		return
	end

	local port_id = attack_data.attr.port
	local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
	local port_info_item = port_info[port_id]
	if port_info_item then
		self.cur_widget_panel.port_name_lab:setText(port_info_item.name)
	else
		self.cur_widget_panel.port_name_lab:setText(ui_word.NO_TIPS)
	end

	local spr_player_icon = getConvertChildByName(self.cur_widget_panel, "head_pic")
	local lbl_player_name = getConvertChildByName(self.cur_widget_panel, "player_name")
	local lbl_player_level = getConvertChildByName(self.cur_widget_panel, "player_level")
	local lbl_player_job = getConvertChildByName(self.cur_widget_panel, "player_job")
	local spr_player_title = getConvertChildByName(self.cur_widget_panel, "player_title")
	local lbl_player_power = getConvertChildByName(self.cur_widget_panel, "power_num")
	local lbl_player_status_txt = getConvertChildByName(self.cur_widget_panel, "ore_cd_text")
	local lbl_player_status = getConvertChildByName(self.cur_widget_panel, "cd_time")
	local spr_head = getConvertChildByName(self.cur_widget_panel, "head_bg")

	local is_has_defend = attack_data.attr.name and true or false
	spr_head:setVisible(is_has_defend)
	getConvertChildByName(self.cur_widget_panel, "player_title"):setVisible(is_has_defend)
	getConvertChildByName(self.cur_widget_panel, "power_text"):setVisible(is_has_defend)
	lbl_player_name:setVisible(is_has_defend)
	lbl_player_level:setVisible(is_has_defend)
	lbl_player_job:setVisible(is_has_defend)
	spr_player_title:setVisible(is_has_defend)
	lbl_player_power:setVisible(is_has_defend)
	getConvertChildByName(self.cur_widget_panel, "no_garrison"):setVisible(not is_has_defend)

	local mineral_config = area_competition_data:getMineralPointConfig()[id]
	local explore_map_data = getGameData():getExploreMapData()
	local str_btn_txt = ui_word.NAVIGATE_NOW

	if port_id == my_guild_port_id then
		lbl_player_status_txt:setVisible(true)
		lbl_player_status:setVisible(true)
		lbl_player_status_txt:setText(ui_word.STR_HARVEST_STATUS_TIPS)
		lbl_player_status:setText(ui_word.STR_CAN_OBTAIN_TIPS)
		str_btn_txt = ui_word.STR_GO_OBTAIN_TIPS
		if not area_competition_data:isReceiveMineral(id) then
			lbl_player_status:setText(ui_word.STR_NOT_CAN_OBTAIN_TIPS)
			str_btn_txt = ui_word.NAVIGATE_NOW
		end
	elseif mineral_config.area_id ~= explore_map_data:getCurPointAreaId() or port_id == 0 then
		lbl_player_status_txt:setVisible(false)
		lbl_player_status:setVisible(false)
		str_btn_txt = ui_word.NAVIGATE_NOW
	else
		lbl_player_status_txt:setVisible(true)
		lbl_player_status:setVisible(true)
		lbl_player_status_txt:setText(ui_word.STR_ROBBERY_STATUS_TIPS)
		lbl_player_status:setText(ui_word.STR_CAN_ROBBERY_TIPS)
		str_btn_txt = ui_word.STR_GO_ROBBERY_TIPS
		if not area_competition_data:isRobberyMineral(id) then
			lbl_player_status:setText(ui_word.STR_NOT_CAN_ROBBERY_TIPS)
			str_btn_txt = ui_word.NAVIGATE_NOW
		end
	end

	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	local widget_panel = explore_map:getWidgetPanel()

	widget_panel.btn_go.btn_go_text:setText(str_btn_txt)

	if not is_has_defend then
		return
	end

	lbl_player_name:setText(attack_data.attr.name)
	spr_player_icon:changeTexture(sailor_info[tonumber(attack_data.attr.icon)].res)
	lbl_player_level:setText(string.format(ui_word.STR_LV, attack_data.attr.grade))
	lbl_player_job:setText(ROLE_OCCUP_NAME[attack_data.attr.profession])
	local str_title = nobility_config[attack_data.attr.nobility].peerage_before
	spr_player_title:changeTexture(convertResources(str_title))
	lbl_player_power:setText(attack_data.attr.prestige)

	local player_uid = attack_data.attr.owned
	local player_data = getGameData():getPlayerData()
	local my_uid = player_data:getUid()

	local info_bg = getConvertChildByName(self.cur_widget_panel, "bg")
	info_bg:setVisible(false)
	local btn_add = getConvertChildByName(self.cur_widget_panel, "btn_add")
	local btn_captain_info = getConvertChildByName(self.cur_widget_panel, "btn_captain_info")
	btn_captain_info:addEventListener(function()
		btn_captain_info:setTouchEnabled(false)
		btn_add:setTouchEnabled(false)
		info_bg:setVisible(false)
		local info_uid = player_uid
		if my_uid == info_uid then
			getUIManager():create("gameobj/playerRole/clsRoleInfoView")
		else
			getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil,info_uid)
		end
	end, TOUCH_EVENT_ENDED)

	btn_add:addEventListener(function()
		btn_captain_info:setTouchEnabled(false)
		btn_add:setTouchEnabled(false)
		info_bg:setVisible(false)
		if player_uid == my_uid then
			alert:warning({msg = ui_word.STR_NO_ADD_MYSELF_FRIEND})
			return
		end
		local firend_data = getGameData():getFriendDataHandler()
		firend_data:askRequestAddFriend(attack_data.attr.owned)
	end, TOUCH_EVENT_ENDED)

	spr_head:addEventListener(function()
		info_bg:setVisible(true)
		btn_captain_info:setTouchEnabled(true)
		btn_add:setTouchEnabled(true)
	end, TOUCH_EVENT_ENDED)
end


--------------

PointInfoPanel.setTouch = function(self, enable)
	self.is_enable = enable
	if true == enable then
		local cur_select_point_info = getGameData():getExploreMapData():getCurSelectPointInfo()
		for k, v in pairs(self.widget_panel_dic) do
			if not tolua.isnull(v) then
				if cur_select_point_info and cur_select_point_info.navType == k then
					v:setTouchEnabled(true)
					v:setEnabled(true)
				else
					v:setTouchEnabled(false)
					v:setEnabled(false)
				end
			end
		end
		return
	end

	if enable == false then
		for k, v in pairs(self.widget_panel_dic) do
			if not tolua.isnull(v) then
				v:setTouchEnabled(false)
				v:setEnabled(false)
			end
		end
	end
end

PointInfoPanel.onExit = function(self)
	--移除资源
	UnLoadPlist(self.plist_res)
	ReleaseTexture(self)

	local investData = getGameData():getInvestData()
	local port_data = getGameData():getPortData()
	investData:setInvestPortId(port_data:getPortId())
	investData:sendPortInvest()
end

PointInfoPanel.create = function()
	local object = PointInfoPanel.new()
	object:initUI()
	object:initEvent()
	return object
end

return PointInfoPanel
