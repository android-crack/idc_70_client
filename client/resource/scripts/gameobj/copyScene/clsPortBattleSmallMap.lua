--
-- Function: 港口争夺战的小地图
-- Author: lzg0496
-- Date: 2017-02-07 17:30:30

local ClsSmallMap = require("gameobj/explore/smallMap")
local UiCommon= require("ui/tools/UiCommon")
local music_info = require("game_config/music_info")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local cfg_port_battle_objects = require("game_config/copyScene/port_battle_objects")
local ClsAlert = require("ui/tools/alert")
local cfg_ui_word = require("game_config/ui_word")

local SMALL_TITLE_SIZE = 32
local SMALL_LAND_HEIGHT = 416

local SMALL_TITLE_WIDTH = 24
local SMALL_TITLE_HEIGHT = 13

local NO_NEED_SHOW_HP = {10, 11, 12, 13} --事件ID

local NEED_SHOW_GUILD_NAME = 9 --事件ID

local CHECK_WARP_EVENT = {7, 8}


local ClsPortBattleSmallMap = class("ClsPortBattleSmallMap", ClsSmallMap)

function ClsPortBattleSmallMap:onEnter(scene_layer)
	self.resPlist ={
	}
	LoadPlist(self.resPlist)
	self.armature_res_2 = {
		"effects/tx_0052.ExportJson",
	}
	LoadArmature(self.armature_res_2)

	self.map_res_url = "world_map/battle_guild.tmx"
	self.map_res_type = ClsPortBattleSmallMap.MAP_RES_TYPE_TMX
	self.m_scene_layer = scene_layer
	self.ship3d = self.m_scene_layer:getPlayerShip()
	self.m_ships_layer = self.m_scene_layer:getShipsLayer()
	ClsPortBattleSmallMap.super.onEnter(self, self.map_res_url, self.map_res_type)
	self.select_stronghold_id = 0
	self.select_nav_id = 0
	self.show_areamap_viewport_rect = CCRect(0, 61, 655, 460)
	self.show_max_viewport_rect = self.show_areamap_viewport_rect
	self.ship3d:setShipUpdateForwardCallback(function()
			self:setShipPosInfo(true)
		end)
	self:initUI()
end

function ClsPortBattleSmallMap:initUI()
	local function initBg()
		local border = display.newSpriteFrame("map_frame.png")
		self.map_border = CCScale9Sprite:createWithSpriteFrame(border)
		self.map_border:setContentSize(CCSizeMake(682, 453))
		self.map_border:setPosition(ccp(266, 13))
		self.map_border:setAnchorPoint(ccp(0, 0))
		self:addChild(self.map_border, 10)
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.map_border
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.map_border

	   
		self.widget_panel = GUIReader:shareReader():widgetFromJsonFile("json/portfight_battlemap.json")
		self:addWidget(self.widget_panel)

		local need_widget_name = {
			btn_close = "btn_close",
			btn_sailing = "btn_go",
			lbl_guild_name_1 = "guild_name_1",
			lbl_guild_percent_1 = "guild_percent_1",
			lbl_guild_name_2 = "guild_name_2",
			lbl_guild_percent_2 = "guild_percent_2",
			pro_event_guild_hp_1 = "enemy_hp_progress",
			pro_event_guild_hp_2 = "my_hp_progress",
			lbl_event_hp = "strong_hp_lab",
			lbl_event_name = "stronghold_info_text",
			spr_event_hp = "stronghold_hp",
			pal_sculpture = "statue_panel",
			pal_battly = "fortress_panel",
			pal_supply = "subsidy_panel",
			pal_warship = "ship_panel",
		}
		for k, v in pairs(need_widget_name) do
			self[k] = getConvertChildByName(self.widget_panel, v)
		end

		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.widget_panel 
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.widget_panel 
	end
	
	local function initMap()
		self.map = CCTMXTiledMap:create(self.map_res_url)
		self.map_tile_size = self.map:getTileSize().width
	
		self.map_width = self.map:getContentSize().width
		self.map_height = self.map:getContentSize().height


		local map_layer_scale_x = self.show_max_viewport_rect.size.width / self.map_width
		local map_layer_scale_y = self.show_max_viewport_rect.size.height / self.map_height
		self.map_layer_min_scale = math.min(map_layer_scale_x, map_layer_scale_y)
		self.map_layer_max_scale = math.max(map_layer_scale_x, map_layer_scale_y)

		self.show_max_map_layer_scale = self.map_layer_max_scale

		------------- tilemap的图层,子类可重写initUI函数进行操作---------------

		local ship_effect = CCArmature:create("tx_0053")
		local armature_animation = ship_effect:getAnimation()
		armature_animation:playByIndex(0)
		self.ship = CCNode:create()
		self.ship:setScale(0.7)
		self.ship.angle_flag = 1
		self.ship:addChild(ship_effect)
		self.map:addChild(self.ship,20)

		self.viewport = display.newClippingRegionNode(self.show_max_viewport_rect)
		self.map_layer = display.newLayer()
		self.map_layer:ignoreAnchorPointForPosition(false)
		self.map_layer:setAnchorPoint(ccp(0,0))
		self.map_layer:addChild(self.map)
		self.viewport:addChild(self.map_layer)
		self:addChild(self.viewport, 5)

		self.map_layer:setScale(self.show_max_map_layer_scale)

		self.effect_layer = display.newLayer()
		self.map:addChild(self.effect_layer)
	end

	local function initMapBox()
		local size = self.show_min_viewport_rect.size
		-- 小地图显示框
		self.map_box = CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame("map_frame.png"))
		self.map_box:setAnchorPoint(ccp(1,1))
		self.map_box:setContentSize(size)
		self.map_box:setPosition(ccp(display.width + 1, display.height + 1))
		self.map_box_x = self.map_box:getPositionX()
		self.map_box_y = self.map_box:getPositionY()
		self.map_box_centerx = self.map_box_x - size.width/2   --显示框的中心位置
		self.map_box_centery = self.map_box_y - size.height/2
		self:addChild(self.map_box, 6)
		self.show_min_map_layer_scale = 1
		self.show_max_hide_nodes[#self.show_max_hide_nodes + 1] = self.map_box
		self.show_min_show_nodes[#self.show_min_show_nodes + 1] = self.map_box
	end

	initBg()
	initMap()
	initMapBox()

	self:initEvent()
	self:initMapUI()
	return true
end

function ClsPortBattleSmallMap:titleToCocos(position)
	return ccp(position.x * SMALL_TITLE_SIZE, SMALL_LAND_HEIGHT - position.y * SMALL_TITLE_SIZE)
end

function ClsPortBattleSmallMap:titleToCocos2(position)
	return ccp(position.x * SMALL_TITLE_SIZE + SMALL_TITLE_SIZE / 2, SMALL_LAND_HEIGHT - position.y * SMALL_TITLE_SIZE - SMALL_TITLE_SIZE / 2)
end

function ClsPortBattleSmallMap:cocosToTitle(position)
	local x = math.floor(position.x / SMALL_TITLE_SIZE)
	local y = math.floor((SMALL_LAND_HEIGHT - position.y) / SMALL_TITLE_SIZE)
	return ccp(x, y)
end

function ClsPortBattleSmallMap:onMutilTouchMoved(curPos, lastPos) -- 多点触摸移动
	self.touchLastPoint = nil
	self.touchSecondPoint = nil
end

function ClsPortBattleSmallMap:clickMap(click_x, click_y)
	local click_pos = self.map_layer:convertToNodeSpace(ccp(click_x, click_y))  
	if self:clickPoint(click_x, click_y) then
		return true
	end
	return false
end

function ClsPortBattleSmallMap:clickPoint(click_x, click_y)
	local pos = self.map:convertToNodeSpace(ccp(click_x, click_y))
	local p = self:cocosToTitle(pos)
	
	local event_index_id = self:isClickEvent(p)
	if event_index_id then
		self:selectCurrentStrongHold(event_index_id, p)
	end
	return false
end

function ClsPortBattleSmallMap:isClickEvent(pos)
	for k, v in pairs(cfg_port_battle_objects) do
		local map_pos = v.map_pos
		if map_pos then
			if map_pos[1] == pos.x and map_pos[2] == pos.y then
				return k
			end
		end
	end

	for k, v in pairs(CHECK_WARP_EVENT) do
		local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
		local event_item = port_battle_datas[v]
		if event_item and event_item.event_obj then
			local x, y = event_item.event_obj:getPos()
			local max_map = self.m_scene_layer:getLand()
			local _pos = max_map:cocosToTileSize(ccp(x,y))
			_pos.x = math.floor(_pos.x * (SMALL_TITLE_WIDTH / (max_map:getTileWidth())))
			_pos.y = math.floor(_pos.y * (SMALL_TITLE_HEIGHT / (max_map:getTileHeight())))
			if _pos.x == pos.x and _pos.y == pos.y then
				return v
			end
		end
	end
end

function ClsPortBattleSmallMap:initEvent()
	local mult_touch = require("ui/tools/mult_touch_layer")
	self.map_layer.onTouchBegan = function(x,y,isMutilTouchMode) self:onTouchBegan(x,y,isMutilTouchMode) end
	self.map_layer.onTouchMoved = function(x,y,isMutilTouchMode) self:onTouchMoved(x,y,isMutilTouchMode) end
	self.map_layer.onTouchEnded = function(x,y,isMutilTouchMode) self:onTouchEnded(x,y,isMutilTouchMode) end
	self.map_layer.onMutilTouchMoved = function(curPos, lastPos)
		self:onMutilTouchMoved(curPos, lastPos) end
	mult_touch:initTouchLayer(self.map_layer)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self:btnCloseListener()
	end, TOUCH_EVENT_ENDED)

	self.btn_sailing:setPressedActionEnabled(true)
	self.btn_sailing:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if getGameData():getTeamData():isLock(true) then
			return false
		end

		if ClsSceneManage:doLogic("isNotCanSailing") then
			ClsAlert:warning({msg = cfg_ui_word.STR_NOT_SAILING_TIP})
			return
		end

		if self.select_stronghold_id <=0 then
			return
		end

		local copy_scene_ui = ClsSceneManage:getSceneUILayer()
		if not tolua.isnull(copy_scene_ui) then
			copy_scene_ui:setIsDropAnchor(false)
		end
		
		self:showMin()
		self:navToStronghold(self.select_stronghold_id)
	end,TOUCH_EVENT_ENDED)
end

function ClsPortBattleSmallMap:navToStronghold(select_stronghold_id)
	ClsSceneManage:doLogic("touchEnd")
	self.select_nav_id = select_stronghold_id
	local port_battle_item = cfg_port_battle_objects[self.select_nav_id]

	for k, v in pairs(CHECK_WARP_EVENT) do
		local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
		if v == select_stronghold_id then
			local event_item = port_battle_datas[v]
			if event_item and event_item.event_obj then
				local x, y = event_item.event_obj:getPos()
				local max_map = self.m_scene_layer:getLand()
				local _pos = max_map:cocosToTileSize(ccp(x,y))
				self.m_scene_layer:getLand():moveToTPos(_pos, function() end)
				return
			end
		end
	end

	local item_pos = ccp(port_battle_item.sea_pos[1], port_battle_item.sea_pos[2])
	self.m_scene_layer:getLand():moveToTPos(item_pos, function() end)
end

function ClsPortBattleSmallMap:showMin()
	self:setViewTouchEnabled(false)
	self:setSwallowTouch(false)

	self.show_max = false

	transition.stopTarget(self.map_layer)

	for k,v in ipairs(self.show_min_hide_nodes) do
		if not tolua.isnull(v) then
			v:setVisible(false)
		end
	end
	for k,v in ipairs(self.show_min_show_nodes) do
		if not tolua.isnull(v) then
			v:setVisible(true)
		end
	end

	self:setCurShowViewPortRect(self.show_min_viewport_rect)

	self:setShipPosInfo()
end

function ClsPortBattleSmallMap:showMax()
	self:setViewTouchEnabled(true)
	self:setSwallowTouch(true)

	self.show_max = true
	transition.stopTarget(self.map_layer)
	
	for k,v in ipairs(self.show_max_hide_nodes) do
		if not tolua.isnull(v) then
			v:setVisible(false)
		end
	end

	for k,v in ipairs(self.show_max_show_nodes) do
		if not tolua.isnull(v) then
			v:setVisible(true)
		end
	end

	self:setCurShowViewPortRect(self.show_max_viewport_rect)

	self:setShipPosInfo()
	local last_id = self.select_stronghold_id
	self:updateEventUI(last_id)
	local nav_id = 0
	if IS_AUTO then
		nav_id = self.select_nav_id
	end

	--导航中就选中导航的，否则 选中默认的最近的
	local min_hold_id, min_pos
	if nav_id > 0 then
		min_hold_id = nav_id
		if cfg_port_battle_objects[nav_id] and cfg_port_battle_objects[nav_id].map_pos then
			min_pos = ccp(cfg_port_battle_objects[nav_id].map_pos[1], cfg_port_battle_objects[nav_id].map_pos[2])
		end
	end
	if not min_pos then
		min_hold_id, min_pos = self:selectNearestHold()
	end

	if min_hold_id and min_pos then
		self:selectCurrentStrongHold(min_hold_id, min_pos)
	end
end

function ClsPortBattleSmallMap:selectNearestHold()
	local px, py = self.ship3d:getPos()
	local minDistance = 0
	local min_hold_id = 0
	local min_pos = ccp(0, 0)

	local has_min_distance = 0
	local has_hold_id = 0
	local has_min_pos = ccp(0, 0)

	local count = 0
	local has_count = 0
	for key, value in ipairs(cfg_port_battle_objects) do
		if value.map_pos then
			local map_pos = self.m_scene_layer:getLand():cocosToTile2(ccp(value.map_pos[1], value.map_pos[2]))
			local dis = Math.distance(px, py, map_pos.x, map_pos.y)
			local is_same = true--ClsGuildSceneData:isFriendOrEnemy(key)
			if not is_same then
				if count == 0 then
					minDistance = dis
				end
				count = count + 1
				if  dis <= minDistance then
					minDistance = dis
					min_hold_id = key
					min_pos = ccp(value.map_pos[1], value.map_pos[2])
				end
			else
				if has_count == 0 then
					has_min_distance = dis
				end
				has_count = has_count + 1
				if  dis <= has_min_distance then
					has_min_distance = dis
					has_hold_id = key
					has_min_pos = ccp(value.map_pos[1], value.map_pos[2])
				end
			end
		end
	end
	print("min_hold_id------------", min_hold_id)
	if min_hold_id <= 0 then
		min_hold_id = has_hold_id
		min_pos = has_min_pos
	end
	return min_hold_id, min_pos
end

function ClsPortBattleSmallMap:updateEventUI()
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	local port_battle_data = port_battle_datas[self.select_stronghold_id]

	self.pal_battly:setVisible(false)
	self.pal_sculpture:setVisible(false)
	self.pal_supply:setVisible(false)
	self.pal_warship:setVisible(false)

	local cfg_event_item = cfg_port_battle_objects[self.select_stronghold_id]
	if not cfg_event_item then return end
	self.lbl_event_name:setText(cfg_event_item.name)

	self.pal_battly:setVisible(true)

	local is_show_hp = true
	for k, v in pairs(NO_NEED_SHOW_HP) do
		self.spr_event_hp:setVisible(true)
		if v == self.select_stronghold_id then
			is_show_hp = false
			self.spr_event_hp:setVisible(false)
			self.pal_battly:setVisible(false)
			self.pal_supply:setVisible(true)
			break
		end
	end

	for k, v in pairs(CHECK_WARP_EVENT) do
		if v == self.select_stronghold_id then
			self.pal_battly:setVisible(false)
			self.pal_warship:setVisible(true)
			break
		end
	end

	local is_need_show_guild_name = (NEED_SHOW_GUILD_NAME == self.select_stronghold_id)
	self.lbl_guild_name_1:setVisible(is_need_show_guild_name)
	self.lbl_guild_name_2:setVisible(is_need_show_guild_name)
	self.lbl_guild_percent_1:setVisible(is_need_show_guild_name)
	self.lbl_guild_percent_2:setVisible(is_need_show_guild_name)

	if not port_battle_data then
		if is_show_hp then
			self.lbl_event_hp:setText(0)
			self.pro_event_guild_hp_2:setPercent(0)
		end

		return
	end

	if is_need_show_guild_name then
		self.pal_battly:setVisible(false)
		self.pal_sculpture:setVisible(true)
		local attack_camp = port_battle_data.attack_camp
		if not attack_camp then
			self.lbl_guild_name_1:setVisible(false)
			self.lbl_guild_name_2:setVisible(false)
			self.lbl_guild_percent_1:setVisible(false)
			self.lbl_guild_percent_2:setVisible(false)
		else
			attack_camp = string.gsub(attack_camp, "{", "")
			attack_camp = string.gsub(attack_camp, "}", "")
			attack_camp = string.split(attack_camp, ",")
			attack_camp[1] = string.split(attack_camp[1], ":")
			attack_camp[2] = string.split(attack_camp[2], ":")
			-- attack_camp = {[1] = {[1] = 2, [2] = 0}, [2] = {[1] = 3, [2] = 0}}
			local sum_attack = (attack_camp[1][2] + attack_camp[2][2])
			if sum_attack == 0 then
			   sum_attack = 1 
			end
			local percent_1 = tonumber(attack_camp[1][2]) / sum_attack  * 100
			local percent_2 = tonumber(attack_camp[2][2]) / sum_attack * 100
			self.lbl_guild_name_1:setText(ClsSceneManage:getSceneAttr("camp_name_2") or "")
			self.lbl_guild_name_2:setText(ClsSceneManage:getSceneAttr("camp_name_3") or "")
			self.lbl_guild_name_1:setColor(ccc3(dexToColor3B(COLOR_BLUE)))
			self.lbl_guild_name_2:setColor(ccc3(dexToColor3B(COLOR_GREEN)))

			self.lbl_guild_percent_1:setText(string.format("%.2f%%", percent_1))
			self.lbl_guild_percent_1:setColor(ccc3(dexToColor3B(COLOR_BLUE)))
			self.lbl_guild_percent_2:setText(string.format("%.2f%%", percent_2))
			self.lbl_guild_percent_2:setColor(ccc3(dexToColor3B(COLOR_GREEN)))
		end
	end
	if is_show_hp and port_battle_data.hp then
		self.lbl_event_hp:setText(port_battle_data.hp .. "/" .. port_battle_data.max_hp)
		self.pro_event_guild_hp_2:setPercent(port_battle_data.hp / port_battle_data.max_hp * 100)
	end

	if is_show_hp and port_battle_data.hp then
		self.lbl_event_hp:setText(port_battle_data.hp .. "/" .. port_battle_data.max_hp)
		self.pro_event_guild_hp_2:setPercent(port_battle_data.hp / port_battle_data.max_hp * 100)
	end
end

function ClsPortBattleSmallMap:initMapUI()
	self.friend_icon_layer = display.newLayer()
	self.map:addChild(self.friend_icon_layer, 7)
	
	self.friend_icon_layer.icons_info = {}
	
	self.friend_icon_layer.updateShineEffFunc = function(icon_layer)
		local now_time_n = os.clock()
		for key, icon_spr in pairs(icon_layer.icons_info) do
			local port_battle_data = self:getPortBattleData(key)
			local left_time_n = 0
			if port_battle_data then
				local hit_time = port_battle_data.hit_time or 0
				left_time_n = Math.ceil(hit_time + 5 - now_time_n)
			end
			local eff_icon_spr = icon_spr.eff_icon_spr
			if left_time_n <= 0 then
				if eff_icon_spr:isVisible() then
					eff_icon_spr:stopAllActions()
					eff_icon_spr:setVisible(false)
				end
			else
				if not eff_icon_spr:isVisible() then
					eff_icon_spr:setVisible(true)
					eff_icon_spr:stopAllActions()
					eff_icon_spr:setScale(1)
					local effect_arr = CCArray:create()
					effect_arr:addObject(CCCallFunc:create(function() 
							eff_icon_spr:setOpacity(125)
							eff_icon_spr:setScale(1)
							eff_icon_spr:runAction(CCFadeTo:create(0.6, 0))
							eff_icon_spr:runAction(CCScaleTo:create(0.6, 2, 2))
						end))
					effect_arr:addObject(CCDelayTime:create(1))
					eff_icon_spr:runAction(CCRepeatForever:create(CCSequence:create(effect_arr)))
				end
			end
		end
	end
	
	local repeat_act = UiCommon:getRepeatAction(0.5, function()
			self.friend_icon_layer.updateShineEffFunc(self.friend_icon_layer)
		end)
	self.friend_icon_layer:runAction(repeat_act)
	self:updateIcon()
end

function ClsPortBattleSmallMap:updateIcon()
	local add_layer = self.friend_icon_layer
	for key, value in pairs(cfg_port_battle_objects) do
		local is_same = true
		local port_battle_data = self:getPortBattleData(key)
		if port_battle_data then
			is_same = getGameData():getExplorePlayerShipsData():isSameCampByValue(port_battle_data.camp)
		else
			port_battle_data = {}
		end
		local icon_str = value.map_res
		local icon_spr = add_layer.icons_info[key]
		if not icon_spr then
			icon_spr = display.newSprite(icon_str)
			icon_spr:setScale(value.scale)
			icon_spr:setFlipX(value.flip == -1)
			local size = icon_spr:getContentSize()
			add_layer:addChild(icon_spr)
			
			local pos = ccp(0, 0)
			if value.map_pos then
				pos = self:titleToCocos2(ccp(value.map_pos[1], value.map_pos[2]))
			end
			icon_spr:setPosition(pos)
			
			local eff_icon_spr = display.newSprite(icon_str)
			eff_icon_spr:setPosition(size.width/2, size.height/2)
			icon_spr:addChild(eff_icon_spr)
			icon_spr.eff_icon_spr = eff_icon_spr
			
			icon_spr.name_lab = name_lab
			add_layer.icons_info[key] = icon_spr
		end
	end

end

function ClsPortBattleSmallMap:getPortBattleData(event_index_id)
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas") or {}
	return port_battle_datas[event_index_id]
end

function ClsPortBattleSmallMap:setShipPosInfo(is_check_max)
	if self.ship3d and tolua.isnull(self.ship3d.node) then
		return
	end
	local x, y = self.ship3d:getPos()

	local pos_info = {x = x, y = y, angle = self.ship3d:getAngle()}
	local angle = pos_info.angle
	local dx = pos_info.x or 0
	local dy = pos_info.y or 0

	local max_map = self.m_scene_layer:getLand()
	dx = dx / ((max_map:getTileWidth() / SMALL_TITLE_WIDTH ) * 2)
	dy = dy / ((max_map:getTileHeight() / SMALL_TITLE_HEIGHT) * 2)
	
	local ship_next_x = dx
	local ship_next_y = dy

	self.ship.ship_angle = angle
	angle = angle % 360
	if angle >= 0 and angle < 180 then
		self.ship.angle_flag = -1
	else
		self.ship.angle_flag = 1
	end
	self.ship:setScaleX(self.ship.angle_flag * math.abs(self.ship:getScaleX()))
	local dx = 15
	if ship_next_x >= self.map_width - dx then
		ship_next_x = self.map_width - dx
	end

	if ship_next_y >= self.map_height - dx then
		ship_next_y = self.map_height - dx
	end
	self.ship:setPosition(ccp(ship_next_x, ship_next_y))
	if (not is_check_max) or (not self.show_max) then
		self:setMapLayerPos(ship_next_x, ship_next_y)
	end
end

function ClsPortBattleSmallMap:setMapLayerPos(ship_next_x, ship_next_y)
	local pos_x = 0
	local pos_y = 0
	local last_x, last_y = self.map_layer:getPosition()

	local cur_view_port = self.cur_show_viewport_rect
	local ship_world_pos = self.map_layer:convertToWorldSpace(ccp(ship_next_x, ship_next_y))
	local cur_view_port_center = ccp(cur_view_port.origin.x + cur_view_port.size.width / 2, cur_view_port.origin.y + cur_view_port.size.height / 2)
	--
	pos_x = last_x + (cur_view_port_center.x - ship_world_pos.x)
	pos_y = last_y + (cur_view_port_center.y - ship_world_pos.y)
	pos_x, pos_y = self:ajustMapLayerPos(pos_x, pos_y)
	self.map_layer:setPosition(ccp(pos_x, pos_y))
end

function ClsPortBattleSmallMap:ajustMapLayerPos(curX, curY)
	local h = 0
	local w = 0
	local cur_view_port = self.cur_show_viewport_rect
	
	local max_width = self.map_width * self.show_max_map_layer_scale
	local max_height = self.map_height * self.show_max_map_layer_scale
	w = cur_view_port.size.width - max_width
	h = cur_view_port.size.height - max_height
	
	if curX <= (w + cur_view_port.origin.x) then
		curX = (w + cur_view_port.origin.x)
	elseif curX >= cur_view_port.origin.x then
		curX = cur_view_port.origin.x
	end

	if curY <= (h + cur_view_port.origin.y) then
		curY = (h + cur_view_port.origin.y)
	elseif curY >= cur_view_port.origin.y then
		curY = cur_view_port.origin.y
	end
	
	return curX, curY
end

function ClsPortBattleSmallMap:onTouchBegan(x, y, isMutilTouchMode)
	self.touchBeginPoint= nil
	self.touchLastPoint = nil
	self.touchSecondPoint = nil

	if not self.is_enable or self.touch_delay then
		return false
	end

	if self.show_max and not self.cur_show_viewport_rect:containsPoint(ccp(x,y)) then
		return false
	end

	if isMutilTouchMode then --多点触摸
		return false
	end

	if self.show_max then
		self.touchBeginPoint= {x = x, y = y}
		return true
	end
	return false
end

function ClsPortBattleSmallMap:onTouchMoved(x, y, isMutilTouchMode)
	if self.show_max and self.is_enable and self.cur_show_viewport_rect:containsPoint(ccp(x,y)) then
		local cx, cy = self.map_layer:getPosition()
		if self.touchLastPoint then
			local curX = cx
			local curY = cy
			
			curX = cx + x - self.touchLastPoint.x
			curY = cy + y - self.touchLastPoint.y
			
			curX, curY = self:ajustMapLayerPos(curX, curY)
			self.map_layer:setPosition(curX, curY)
		end
		self.touchSecondPoint = self.touchLastPoint
		self.touchLastPoint = {x = x, y = y}
	end
end

function ClsPortBattleSmallMap:isTouchMinRect(x, y)
	if (not self.show_max) and self.show_min_viewport_rect:containsPoint(ccp(x,y)) then
		local sound = music_info.EX_DRAGMAP   -- 音效
		audioExt.playEffect(sound.res, false)
		self:showMax()
		return true
	end
	return false
end

function ClsPortBattleSmallMap:showSelectEffect(stronghold_id, pos)
	if not tolua.isnull(self.goal_point_effect) then
		self.goal_point_effect:removeFromParentAndCleanup(true)
		self.goal_point_effect = nil
	end
	
	self.goal_point_effect = CCArmature:create("tx_0052")
	local armatureAnimation = self.goal_point_effect:getAnimation()
	armatureAnimation:playByIndex(0)
	local goalEffectScale = 0
	
	local layerScale = self.map_layer:getScale()
	if layerScale ~= 0 then
		goalEffectScale = 1 / layerScale
	end
	
	local goal_pos = self:titleToCocos2(pos)
	self.goal_point_effect:setScale(goalEffectScale)
	self.goal_point_effect:setPosition(goal_pos)
	self.effect_layer:addChild(self.goal_point_effect, -1)
end

function ClsPortBattleSmallMap:selectCurrentStrongHold(stronghold_id, pos)
	self.select_stronghold_id = stronghold_id
	local is_same = true
	local port_battle_data = self:getPortBattleData(stronghold_id)
	local hp_n = 0
	local max_hp_n = 1
	if port_battle_data then
		is_same = getGameData():getExplorePlayerShipsData():isSameCampByValue(port_battle_data.camp)
		hp_n = port_battle_data.hp or 0
		max_hp_n = port_battle_data.max_hp or 1
	end

	self:showSelectEffect(stronghold_id, pos)
	self:updateEventUI()
end

function ClsPortBattleSmallMap:setCurShowViewPortRect(rect)
	self.cur_show_viewport_rect = rect
	self.map_border:setContentSize(CCSizeMake(self.cur_show_viewport_rect.size.width, self.cur_show_viewport_rect.size.height))
	self.map_border:setPosition(ccp(self.cur_show_viewport_rect.origin.x, self.cur_show_viewport_rect.origin.y))
	self.viewport:setClippingRegion(self.cur_show_viewport_rect)
end

function ClsPortBattleSmallMap:updataEventPos(event_obj)
	if not event_obj then return end
	local icon = self.friend_icon_layer.icons_info[event_obj.m_attr.index]
	if not icon then return  end


	local dx, dy = event_obj:getPos()

	local max_map = self.m_scene_layer:getLand()
	dx = dx / ((max_map:getTileWidth() / SMALL_TITLE_WIDTH ) * 2)
	dy = dy / ((max_map:getTileHeight() / SMALL_TITLE_HEIGHT) * 2)
	
	local ship_next_x = dx
	local ship_next_y = dy

	local dx = 15
	if ship_next_x >= self.map_width - dx then
		ship_next_x = self.map_width - dx
	end

	if ship_next_y >= self.map_height - dx then
		ship_next_y = self.map_height - dx
	end

	icon:setPosition(ccp(ship_next_x, ship_next_y))

end

function ClsPortBattleSmallMap:updataEventVisible(event_obj)
	if not event_obj then return end
	local icon = self.friend_icon_layer.icons_info[event_obj.m_attr.index]
	if tolua.isnull(icon) then return  end
	icon:setVisible(false)
end

function ClsPortBattleSmallMap:onExit()
	ClsPortBattleSmallMap.super.onExit(self)
	--移除资源
	UnLoadPlist(self.resPlist)
	UnLoadArmature(self.armature_res_2)
	RemoveTextureForKey(self.map_bg_res)
end


return ClsPortBattleSmallMap