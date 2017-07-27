local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local area_info = require("game_config/port/area_info")
local port_info = require("game_config/port/port_info")
local port_fight_info = require("game_config/port/port_fight_info")
local on_off_info = require("game_config/on_off_info")
local composite_effect = require("gameobj/composite_effect")
local guild_badge = require("game_config/guild/guild_badge")
local clsBaseView = require("ui/view/clsBaseView")
local ClsPortBattleSignUI = class("ClsPortBattleSignUI", clsBaseView)

local CHALLENGE_WIDGET_NUM = 2
local desc_txt = {
	["pub"] = ui_word.PUB_PORT_DESC,
	["ship"] = ui_word.SHIP_PORT_DESC,
	["market"] = ui_word.MARKET_PORT_DESC,
}
local port_icon_res = {
	["market"] = "#common_port_business_neutrality.png",
	["pub"] = "#common_port_culture_neutrality.png",
	["ship"] = "#common_port_industry_neutrality.png",
}
local widget = {
	"btn_enroll",
	"btn_close",
	"manage_port",
	"purpose_port",
	"enroll_tips",
	"portfight_enroll",
	"reward_content",
	"area_name",
	"btn_help",
}
local right_panel_widget = {
	"manager_name",
	"manager_prestige_num",
	"manager_rank",
	"manager_icon",
	"manager_empty",

	"challenger_name_1",
	"challenger_prestige_num_1",
	"challenger_rank_1",
	"challenger_icon_1",
	"challenger_empty_1",

	"challenger_name_2",
	"challenger_prestige_num_2",
	"challenger_rank_2",
	"challenger_icon_2",
	"challenger_empty_2",
}

ClsPortBattleSignUI.getViewConfig = function(self)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

ClsPortBattleSignUI.onEnter = function(self)
	self.map_tile_size = 32
	self.view_rect_width = 569
	self.view_rect_height = 384
	self.is_enable = true
	self.show_max = true
	self.areaId = 1
	self.cur_select_port = nil
	self.OFF_CENTER = 20
	self.DRAG_THRESHOLD = 140
	self.area_map_dic = {}
	self.port_point_dic = {}
	self.map_size = {}
	self.plistTab = {
		["ui/guild_ui.plist"] = 1,
		["ui/map.plist"] = 1,
	}
	LoadPlist(self.plistTab)
	self.area_res = {
		"world_map/wm_arena_1.jpg",
		"world_map/wm_arena_2.jpg",
		"world_map/wm_arena_3.jpg",
		"world_map/wm_arena_4.jpg",
		"world_map/wm_arena_5.jpg",
		"world_map/wm_arena_6.jpg",
		"world_map/wm_arena_7.jpg",
	}
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
			self.area_map_dic[k] = {mapRes = self.area_res[k], map = nil, lootMap = nil, base = v,
				minScale = v.zoom / 100, showScale = show_scale, mapPos = ccp(v.lbPos[1] + v.width/2,v.lbPos[2] + v.height/2),
				mapRect = CCRect(v.lbPos[1], v.lbPos[2], v.width, v.height)}
		end
	end
	self.show_areamap_viewport_rect = CCRect(0, 0, self.view_rect_width, self.view_rect_height)
	self.my_guild_rank = getGameData():getGuildInfoData():getMyGuildRank() or 10000

	self:mkUI()
	self:initUI()
	self:regEvent()
	self:askBaseData()
end

ClsPortBattleSignUI.askBaseData = function(self)
	local my_guild_id = getGameData():getGuildInfoData():getGuildId()
	getGameData():getPortBattleData():askCurPortsInfo(my_guild_id)
end

ClsPortBattleSignUI.askPortsOccupyData = function(self)
	getGameData():getPortBattleData():askPortsOccupyInfo(self.areaId)
end

ClsPortBattleSignUI.mkUI = function(self)
	local panel = createPanelByJson("json/portfight_enroll.json")
	self:addWidget(panel)
	for _, v in pairs(widget) do
		self[v] = getConvertChildByName(panel, v)
	end
	for _,v in pairs(right_panel_widget) do
		self[v] = getConvertChildByName(panel, v)
	end

	local task_data = getGameData():getTaskData()
	local task_keys = {on_off_info.GUILD_ACTIVITY_PORTFIGHT_ENROLL.value}
	task_data:regTask(self.btn_enroll, task_keys, KIND_RECTANGLE, on_off_info.GUILD_ACTIVITY_PORTFIGHT_ENROLL.value, 50, 18, true)
end

ClsPortBattleSignUI.initUI = function(self)

	local initMap = function()
		local map_root_wid = UIWidget:create()
		self.portfight_enroll:addChild(map_root_wid)
		self.map_root_wid = map_root_wid
		self.map_root_wid:setPosition(ccp(98,90))

		self.viewport = display.newClippingRegionNode(self.show_areamap_viewport_rect)
		self.map_root_wid:addCCNode(self.viewport)
		self.viewport:setClippingRegion(self.show_areamap_viewport_rect)

		self.map_layer = display.newLayer()
		self.map_layer:ignoreAnchorPointForPosition(false)
		self.map_layer:setAnchorPoint(ccp(0,0))
		self.viewport:addChild(self.map_layer)

		self:showAreaById(self.areaId)
	end

	self:initRightPanelUI()
	self:hideAreaMap()
	initMap()
end

ClsPortBattleSignUI.initRightPanelUI = function(self)
	for _,v in pairs(right_panel_widget) do
		self[v]:setVisible(false)
	end
	self.manager_empty:setVisible(true)
	self.challenger_empty_1:setVisible(true)
	self.challenger_empty_2:setVisible(true)

	self.btn_enroll:setTouchEnabled(false)
	self.enroll_tips:setVisible(false)
end

ClsPortBattleSignUI.regEvent = function(self)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_help:setPressedActionEnabled(true)
	self.btn_help:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/port/clsPortBattleExplainUI")
	end, TOUCH_EVENT_ENDED)

	self.btn_enroll:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		if not self.cur_select_port then return end
		getGameData():getPortBattleData():askBattleApply(self.cur_select_port)
		getGameData():getTaskData():setTask(on_off_info.GUILD_ACTIVITY_PORTFIGHT_ENROLL.value, false)
	end, TOUCH_EVENT_ENDED)

	if not tolua.isnull(self.map_layer) then
		local mult_touch = require("ui/tools/mult_touch_layer")
		self.map_layer.onTouchBegan = function(x,y,isMutilTouchMode) self:onTouchBegan(x,y,isMutilTouchMode) end
		self.map_layer.onTouchMoved = function(x,y,isMutilTouchMode) self:onTouchMoved(x,y,isMutilTouchMode) end
		self.map_layer.onTouchEnded = function(x,y,isMutilTouchMode) self:onTouchEnded(x,y,isMutilTouchMode) end
		-- self.map_layer.onMutilTouchMoved = function(curPos, lastPos)
		-- 	self:onMutilTouchMoved(curPos, lastPos) end
		mult_touch:initTouchLayer(self.map_layer)
	end
end

--------------------数据返回更新-------------------
ClsPortBattleSignUI.updateCurOccupyList = function(self)
	local port_battle_data = getGameData():getPortBattleData()
	local challenge_list = port_battle_data:getChallegeList()
	local occupy_list = port_battle_data:getOccupyList()
	local purpose_port_str = ui_word.NO_TIPS
	local manage_port_str = ui_word.NO_TIPS
	if occupy_list and #occupy_list > 0 then
		for k, v in ipairs(occupy_list) do
			if k == 1 then
				manage_port_str = port_info[v].name
			else
				manage_port_str = manage_port_str..","..port_info[v].name
			end
		end
	end
	if challenge_list and challenge_list[1] then
		purpose_port_str = port_info[challenge_list[1]].name
	end
	self.purpose_port:setText(purpose_port_str)
	self.manage_port:setText(manage_port_str)
end

ClsPortBattleSignUI.updateMapPortUI = function(self)
	local occupy_infos = getGameData():getPortBattleData():getAllPortsOccupyInfo()
	for portId, info in pairs(self.port_point_dic) do
		local point_node = info.obj
		local name_pos = info.name_pos
		if occupy_infos[portId] and occupy_infos[portId].group_name then
			if not tolua.isnull(point_node) then
				local group_name_node = createBMFont({text = string.format(ui_word.NAME_BOX, (occupy_infos[portId].group_name..ui_word.STR_GUILD_NAME)), 
					size = 12, fontFile = FONT_CFG_1, color = ccc3(dexToColor3B(COLOR_LIGHT_BLUE_STROKE)), x = name_pos.x, y = name_pos.y - 15})
				point_node:addChild(group_name_node)
			end
		end
	end
end

ClsPortBattleSignUI.updatePortOccupyUI = function(self)
	self:initRightPanelUI()
	local is_has_result = false --是否有胜负
	local port_battle_data = getGameData():getPortBattleData()
	local challenge_info_list = port_battle_data:getChallengeInfoList(self.cur_select_port)
	local single_occupy_info = port_battle_data:getOccupyInfo(self.cur_select_port)
	--更新占领者数据显示
	local is_has_occupyer = single_occupy_info.group_name ~= "" or false --是否有占领者
	self.manager_name:setText(single_occupy_info.group_name or "")
	self.manager_name:setVisible(is_has_occupyer)
	self.manager_empty:setVisible(not is_has_occupyer)
	self.manager_icon:setVisible(is_has_occupyer)
	self.manager_rank:setVisible(is_has_occupyer)
	self.manager_rank:setText(single_occupy_info.group_rank or "")
	self.manager_prestige_num:setVisible(is_has_occupyer)
	self.manager_prestige_num:setText(single_occupy_info.group_prestige or "")
	if is_has_occupyer and single_occupy_info.group_icon then
		self.manager_icon:changeTexture(guild_badge[tonumber(single_occupy_info.group_icon)].explore, UI_TEX_TYPE_PLIST)
	end
	is_has_result = single_occupy_info.isWin ~= 0 or false
	--更新挑战者数据显示
	if not is_has_result then
		for i = 1, CHALLENGE_WIDGET_NUM do
			if challenge_info_list[i] then
				local data = challenge_info_list[i]
				local is_has_challenger = data.group_name ~= "" or false --是否有挑战者
				self["challenger_name_"..i]:setText(data.group_name or "")
				self["challenger_name_"..i]:setVisible(is_has_challenger)
				self["challenger_empty_"..i]:setVisible(not is_has_challenger)
				self["challenger_icon_"..i]:setVisible(is_has_challenger)
				self["challenger_rank_"..i]:setVisible(is_has_challenger)
				self["challenger_rank_"..i]:setText(data.group_rank or "")
				self["challenger_prestige_num_"..i]:setVisible(is_has_challenger)
				self["challenger_prestige_num_"..i]:setText(data.group_prestige or "")
				if is_has_challenger and data.group_icon then
					self["challenger_icon_"..i]:changeTexture(guild_badge[tonumber(data.group_icon)].explore, UI_TEX_TYPE_PLIST)
				end
				is_has_result = data.isWin ~= 0 or false
				if is_has_result then break end
			end
		end
	end
	self.btn_enroll:setTouchEnabled(true)
	self.enroll_tips:setVisible(true)
	local cur_port_fight_info = port_fight_info[self.cur_select_port]
	if cur_port_fight_info then
		local enroll_tip_txt = ""
		if cur_port_fight_info.rank_min and cur_port_fight_info.rank_min > 0 then
			enroll_tip_txt = string.format(ui_word.STR_PORT_BATTLE_RANK_TIP_2, cur_port_fight_info.rank_min, cur_port_fight_info.rank_max)
		else
			enroll_tip_txt = string.format(ui_word.STR_PORT_BATTLE_RANK_TIP_1, cur_port_fight_info.rank_max)
		end
		self.enroll_tips:setText(enroll_tip_txt)

		local show_txt = desc_txt[port_fight_info[self.cur_select_port].type]
		show_txt = string.format(show_txt, port_fight_info[self.cur_select_port].privilege)
		self.reward_content:setText(show_txt)
	end
end

-------------------------触摸事件-----------------------------
ClsPortBattleSignUI.getRealTouchRect = function(self)
	local start_pos = self.map_root_wid:convertToWorldSpace(ccp(0,0))
	return CCRect(start_pos.x, start_pos.y, self.view_rect_width, self.view_rect_height)
end

ClsPortBattleSignUI.onTouchBegan = function(self, x, y, isMutilTouchMode)
	self.touchBeginPoint= nil
	self.touchLastPoint = nil
	self.touchSecondPoint = nil

	local real_touch_rect = self:getRealTouchRect()
	if not self.is_enable or self.touch_delay then
		return false
	end
	if self.show_max and not real_touch_rect:containsPoint(ccp(x, y)) then
		return false
	end

	if isMutilTouchMode then --多点触摸
		return true
	end
	if self.show_max then
		self.touchBeginPoint= {x = x, y = y}
		return true
	end
	return false
end

ClsPortBattleSignUI.onTouchMoved = function(self, x, y, isMutilTouchMode)
	local real_touch_rect = self:getRealTouchRect()
	if self.show_max and self.is_enable and real_touch_rect:containsPoint(ccp(x,y)) then
		local cx = self.map_layer:getPositionX()
		local cy = self.map_layer:getPositionY()
		if self.touchLastPoint then
			local curX = cx
			local curY = cy

			curX = cx + x - self.touchLastPoint.x
			curY = cy + y - self.touchLastPoint.y
			local new_pos = self:checkAndGetSuitablePosition(curX, curY)
			self.map_layer:setPosition(new_pos)
		end
		self.touchSecondPoint = self.touchLastPoint
		self.touchLastPoint = {x = x, y = y}
	end
end

ClsPortBattleSignUI.onTouchEnded = function(self, x, y, isMutilTouchMode)
	if not self.touchBeginPoint then
		self.touchLastPoint = nil
		self.touchSecondPoint = nil
		return
	end

	if isMutilTouchMode or not self.is_enable then
		audioExt.playEffect(music_info.EX_DRAGMAP.res)
		self.touchLastPoint = nil
		self.touchSecondPoint = nil
		return
	end  -- 多点
	if self.show_max then
		local cx = self.map_layer:getPositionX()
		local cy = self.map_layer:getPositionY()
		if self.touchBeginPoint and Math.abs(self.touchBeginPoint.x-x) < self.OFF_CENTER
			and Math.abs(self.touchBeginPoint.y-y) < self.OFF_CENTER then  --点击响应
			self:clickPoint(x, y)
		elseif self.touchSecondPoint then -- 拖动惯性
			local is_attach_change = false
			local dx = (self.touchLastPoint.x - self.touchSecondPoint.x)
			local dy = (self.touchLastPoint.y - self.touchSecondPoint.y)
			local curX = cx + dx--*3
			local curY = cy + dy--*3
			local new_pos, drag_out_area_id = self:checkAndGetSuitablePosition(curX, curY)
			if self.touchBeginPoint then
				if (self.is_horizontal and Math.abs(self.touchBeginPoint.x - self.touchLastPoint.x) >= self.DRAG_THRESHOLD) 
					or (not self.is_horizontal and Math.abs(self.touchBeginPoint.y - self.touchLastPoint.y) >= self.DRAG_THRESHOLD) then
					is_attach_change = true
				end
			end

			if is_attach_change and drag_out_area_id then
				self:turnToArea(drag_out_area_id)
			else
				self.map_layer:setPosition(new_pos)
			end
			-- curX, curY = self:ajustMapLayerPos(curX, curY)

			-- local params = {
			-- 	time = 1,
			-- 	x = curX,
			-- 	y = curY,
			-- 	easing ="CCEaseExponentialOut"
			-- }
			-- transition.stopTarget(self.map_layer)
			-- local action = transition.moveTo(self.map_layer, params)

			-- self:onTouchEndedDrag(x, y, isMutilTouchMode)
		end
	end
	self.touchLastPoint = nil
	self.touchBeginPoint = nil
	self.touchSecondPoint = nil
end

ClsPortBattleSignUI.clickPoint = function(self, click_x, click_y)
	local click_pos = self.map_layer:convertToNodeSpace(ccp(click_x, click_y))
	for id, info in pairs(self.port_point_dic) do
		if info.touch_rect:containsPoint(click_pos) then
			-- print("点中的港口id ：",id)
			self:selectPoint(id)
		end
	end
end

ClsPortBattleSignUI.selectPoint = function(self, port_id)
	if not port_id or self.cur_select_port == port_id then return end
	self.cur_select_port = port_id
	if self.port_point_dic and self.port_point_dic[port_id] then
		local point_node = self.port_point_dic[port_id].obj
		if not tolua.isnull(point_node) then
			if not tolua.isnull(self.goal_point_effect) then
				self.goal_point_effect:removeFromParentAndCleanup(true)
				self.goal_point_effect = nil
			end
			local off_set = 16
			if port_info[port_id].type == "ship" then
				off_set = 14
			end
			self.goal_point_effect = composite_effect.new("tx_0052", off_set, 13, point_node)
		end
	end

	self.btn_enroll:setTouchEnabled(false)
	self.enroll_tips:setVisible(false)
	getGameData():getPortBattleData():askOccupyInfo(port_id)
end

ClsPortBattleSignUI.getSelectPortId = function(self)
	return self.cur_select_port
end

-------------------地图相关-----------------------------
ClsPortBattleSignUI.showAreaById = function(self, areaId)
	self.map_layer:setPosition(0,0)
	self.area_name:setText(area_info[areaId].name)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	local area_map_info = self.area_map_dic[areaId]
	area_map_info.map = display.newSprite(area_map_info.mapRes)
	local scale_x = area_map_info.mapRect.size.width/area_map_info.map:getContentSize().width
	local scale_y = area_map_info.mapRect.size.height/area_map_info.map:getContentSize().height
	area_map_info.map:setScaleX(scale_x)
	area_map_info.map:setScaleY(scale_y)
	CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
	area_map_info.map:setAnchorPoint(ccp(0,0))
	self.map_layer:addChild(area_map_info.map)
	self.map_layer:setScale(area_map_info.showScale)

	local real_scale_x, real_scale_y = scale_x*area_map_info.showScale, scale_y*area_map_info.showScale
	self.map_size = {width = area_map_info.map:getContentSize().width * real_scale_x, height = area_map_info.map:getContentSize().height * real_scale_y}

	self:showAreaPort()
	self:moveToAutoPos()
end

ClsPortBattleSignUI.isCanEnroll = function(self, port_id)
	local cur_port_fight_info = port_fight_info[port_id]
	if cur_port_fight_info.rank_min then
		if cur_port_fight_info.rank_min <= self.my_guild_rank and cur_port_fight_info.rank_max >= self.my_guild_rank then
			return true
		end
	else
		if self.my_guild_rank <=  cur_port_fight_info.rank_max then
			return true
		end
	end
end

ClsPortBattleSignUI.moveToAutoPos = function(self)
	local cur_area_ports = getGameData():getPortBattleData():getAllPorts()[self.areaId]
	local default_select_port = cur_area_ports[1]

	local can_enroll_ports = {}
	for _, pid in ipairs(cur_area_ports) do
		if self:isCanEnroll(pid) then
			table.insert(can_enroll_ports, pid)
		end
	end
	if #can_enroll_ports > 0 then
		table.sort(can_enroll_ports, function(port_id1, port_id2)
			return port_id1 < port_id2
		end)
		default_select_port = can_enroll_ports[1]
	end

	if default_select_port then
		local scale = self.map_layer:getScale()
		local preX, preY = self:mapTile2Cocos(default_select_port)
		local center_pos = self.map_layer:convertToNodeSpace(ccp(self.view_rect_width/2 + 98, self.view_rect_height/2 + 90))
		local curX, curY = center_pos.x - preX, center_pos.y - preY
		local new_pos = self:checkAndGetSuitablePosition(curX, curY)
		self.map_layer:setPosition(new_pos)

		self:selectPoint(default_select_port)
	end
end

ClsPortBattleSignUI.showAreaPort = function(self)
	local explore_map_data = getGameData():getExploreMapData()
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local portsInAreas = getGameData():getPortBattleData():getAllPorts()
	for _, port_id in ipairs(portsInAreas[self.areaId] or {}) do
		local taskPort = explore_map_data:getTaskPort()
		if port_info[port_id].port_battle and port_info[port_id].port_battle > 0 then
			local touch_off_set = 2
			local lbl_name_color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))
			local port_name_node = createBMFont({text = port_info[port_id].name, size = 14, fontFile = FONT_CFG_1, color = lbl_name_color, x = 13, y = -6})
			local port_res = port_icon_res[port_info[port_id].type]
			local point_node = display.newSprite(port_res)
			point_node:setScale(1/self.map_layer:getScale())
			local posX, posY = self:mapTile2Cocos(port_id)
			point_node:setPosition(posX, posY)
			self.map_layer:addChild(point_node)
			point_node:addChild(port_name_node)

			if not self:isCanEnroll(port_id) then
				local forbid_node = display.newSprite("#map_forbidden.png")
				forbid_node:setPosition(16,13)
				point_node:addChild(forbid_node)
			end

			local sW, sH = point_node:getContentSize().width/self.map_layer:getScale(), point_node:getContentSize().height/self.map_layer:getScale()
			self.port_point_dic[port_id] = {}
			self.port_point_dic[port_id].obj = point_node
			self.port_point_dic[port_id].name_pos = ccp(port_name_node:getPositionX(), port_name_node:getPositionY())
			self.port_point_dic[port_id].touch_rect = CCRect(posX - sW/2 - touch_off_set, posY - sH/2 - touch_off_set, sW + touch_off_set, sH + touch_off_set)
		end
	end
	--请求刷新地图上港口的商会信息
	self:askPortsOccupyData()
end

ClsPortBattleSignUI.turnToArea = function(self, areaId)
	if area_info[areaId] and area_info[areaId].port_battle and area_info[areaId].port_battle > 0 then
		self.areaId = areaId
		self:hideAreaMap()
		self:showAreaById(areaId)
	end
end

ClsPortBattleSignUI.hideAreaMap = function(self)
	if not tolua.isnull(self.goal_point_effect) then
		self.goal_point_effect:setVisible(false)
	end

	for k,v in pairs(self.area_map_dic) do
		if not tolua.isnull(v.map) then
			v.map:removeFromParentAndCleanup(true)
			v.map = nil
			RemoveTextureForKey(v.mapRes)
		end
	end
	
	for _,v in pairs(self.port_point_dic) do
		if not tolua.isnull(v.obj) then
			v.obj:removeFromParentAndCleanup(true)
		end
	end
end

--由瓦片坐标转化为cocos像素坐标
ClsPortBattleSignUI.mapTile2Cocos = function(self, port_id)
	local MAP_TILE_WIDTH = 112
	local MAP_TILE_HEIGHT = 63
	local TILE_SIZE = 32
	local OFF_SET = TILE_SIZE + TILE_SIZE/2
	local cur_area_start_pos = area_info[self.areaId].lbPos
	local cur_map_scale = self.map_layer:getScale()
	local cur_port_tile_pos = port_info[port_id].port_pos
	local lX, lY = cur_port_tile_pos[1]*TILE_SIZE - cur_area_start_pos[1], (MAP_TILE_HEIGHT - cur_port_tile_pos[2])*TILE_SIZE - cur_area_start_pos[2]
	return math.floor((lX*cur_map_scale+OFF_SET)/cur_map_scale), math.floor((lY*cur_map_scale+OFF_SET)/cur_map_scale)
end

ClsPortBattleSignUI.getCurrentPosScope = function(self)
	local posScope = {
		maxX = 0,
		minX = self.view_rect_width - self.map_size.width,
		maxY = 0,
		minY = self.view_rect_height - self.map_size.height
	}
	return posScope
end

ClsPortBattleSignUI.checkAndGetSuitablePosition = function(self, newX, newY)
	if not newX and not newY then return end

	local posScope = self:getCurrentPosScope()
	local cur_around_areas = area_info[self.areaId].around_areas
	local drag_out_area_id = nil
	local top_index, bottom_index, left_index, right_index = 1, 2, 3, 4
	self.is_horizontal = true
	if newX > posScope.maxX then
		if cur_around_areas[left_index] and cur_around_areas[left_index] > 0 then
			drag_out_area_id = cur_around_areas[left_index]
		end
		newX = posScope.maxX
	end
	if newX < posScope.minX then
		if cur_around_areas[right_index] and cur_around_areas[right_index] > 0 then
			drag_out_area_id = cur_around_areas[right_index]
		end
		newX = posScope.minX 
	end
	if newY > posScope.maxY then
		if cur_around_areas[bottom_index] and cur_around_areas[bottom_index] > 0 then
			drag_out_area_id = cur_around_areas[bottom_index]
		end
		newY = posScope.maxY
		self.is_horizontal = false
	end
	if newY < posScope.minY then 
		if cur_around_areas[top_index] and cur_around_areas[top_index] > 0 then
			drag_out_area_id = cur_around_areas[top_index]
		end
		newY = posScope.minY
		self.is_horizontal = false
	end
	return ccp(math.floor(newX), math.floor(newY)), drag_out_area_id
end

ClsPortBattleSignUI.onExit = function(self)
	UnLoadPlist(self.plistTab)
end

return ClsPortBattleSignUI