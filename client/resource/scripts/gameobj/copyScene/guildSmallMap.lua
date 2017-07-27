----------- 公会战的 small map ----------------------

local music_info = require("game_config/music_info")
local tips = require("game_config/tips")
local missionGuide = require("gameobj/mission/missionGuide")
local boat_info = require("game_config/boat/boat_info")
local exploreUtil = require("module/explore/exploreUtils")
local UI_WORD = require("game_config/ui_word")
local guild_stronghold_config = require("game_config/guildExplore/group_battle_objects")
local plotVoiceAudio = require("gameobj/plotVoiceAudio")
local voice_info = getLangVoiceInfo()
local ClsSmallMap = require("gameobj/explore/smallMap")
local ClsDynSwitchView = require("ui/tools/DynSwitchView")
local UiCommon= require("ui/tools/UiCommon")

local SMALL_TITLE_SIZE = 32
local SMALL_LAND_HEIGHT = 416

local SMALL_TITLE_WIDTH = 24
local SMALL_TITLE_HEIGHT = 13

local ClsListView = require("ui/tools/ListView")

local ClsSceneManage = require("gameobj/copyScene/copySceneManage")

-------------------------------------------------------------------------

local ClsGuildSmallMap = class("GuildSmallMap", ClsSmallMap)

function ClsGuildSmallMap:onEnter(scene_layer)
	self.resPlist ={
		["ui/guild_ui.plist"] = 1,
		["ui/map.plist"] = 1,
	}
	LoadPlist(self.resPlist)
	self.armature_res_2 = {
		"effects/tx_0052.ExportJson",
	}
	LoadArmature(self.armature_res_2)

	self.map_res_url = "world_map/stronghold_map.tmx"
	self.map_res_type = ClsGuildSmallMap.MAP_RES_TYPE_TMX
	self.m_scene_layer = scene_layer
	self.ship3d = self.m_scene_layer:getPlayerShip()
	self.m_ships_layer = self.m_scene_layer:getShipsLayer()
	ClsGuildSmallMap.super.onEnter(self, self.map_res_url, self.map_res_type)
	self.bg_map_width = 784
	self.bg_map_height = 416
	self.select_stronghold_id = 0
	self.select_nav_id = 0
	self.show_areamap_viewport_rect = CCRect(0, 61, 655, 460)
	self.show_max_viewport_rect = self.show_areamap_viewport_rect
	
	self.m_strong_points = {}
	
	self.ship3d:setShipUpdateForwardCallback(function()
			self:setShipPosInfo(true)
		end)
	self:initUI()
end

function ClsGuildSmallMap:initUI()

	local init_result = true

	local function initBg()
		local border = display.newSpriteFrame("map_frame.png")
		self.map_border = CCScale9Sprite:createWithSpriteFrame(border)
		self.map_border:setContentSize(CCSizeMake(682, 453))
		self.map_border:setPosition(ccp(266, 13))
		self.map_border:setAnchorPoint(ccp(0, 0))
		self:addChild(self.map_border, 10)
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.map_border
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.map_border

		---
		self.color_bg = CCLayerColor:create(ccc4(0, 0, 0, 230))
		self:addChild(self.color_bg, -1)
		
		self.widget_panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_stronghold_battlemap.json")
		self:addWidget(self.widget_panel)
	  
		self.btn_enemy = getConvertChildByName(self.widget_panel, "btn_enemy")
		self.btn_sailing = getConvertChildByName(self.widget_panel, "btn_go")
		self.btn_ourside = getConvertChildByName(self.widget_panel, "btn_ourside")
		self.my_progress = getConvertChildByName(self.widget_panel, "my_progress")
		self.enemy_progress = getConvertChildByName(self.widget_panel, "enemy_progress")
		self.our_score = getConvertChildByName(self.widget_panel, "our_score")
		self.our_name = getConvertChildByName(self.widget_panel, "our_side")
		self.enemy_score = getConvertChildByName(self.widget_panel, "enemy_score")
		self.enemy_name = getConvertChildByName(self.widget_panel, "enemy_side")
		self.stronghold_list_view = getConvertChildByName(self.widget_panel, "stronghold_list")
		self.target_name = getConvertChildByName(self.widget_panel, "target_name")
		self.stronghold_hp_ui = getConvertChildByName(self.widget_panel, "stronghold_hp")
		self.stronghold_hp_ui.my_hp_bar = getConvertChildByName(self.stronghold_hp_ui, "my_hp_progress")
		self.stronghold_hp_ui.enemy_hp_bar = getConvertChildByName(self.stronghold_hp_ui, "enemy_hp_progress")
		self.stronghold_hp_ui.hp_lab = getConvertChildByName(self.stronghold_hp_ui, "strong_hp_lab")
		self.stronghold_hp_ui.tip_lab = getConvertChildByName(self.widget_panel, "stronghold_info_text")
		self.btn_close = getConvertChildByName(self.widget_panel, "btn_close")

		
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.color_bg
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.widget_panel
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.color_bg
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.widget_panel
		
		self.m_timer_spr = display.newSprite()
		self:addChild(self.m_timer_spr)
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

		--
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
		self.map_bg_res = "ui/bg/bg_guild_battle_map.jpg"
		local guild_bg = display.newSprite(self.map_bg_res, -25, -9)
		CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
		guild_bg:setAnchorPoint(ccp(0, 0))
		self.map:addChild(guild_bg, -1)

		self.map_layer:setScale(self.show_max_map_layer_scale)

		--
		local friend_map_layer = self.map:layerNamed("friendly")
		local enemy_map_layer = self.map:layerNamed("enemy")
		friend_map_layer:setVisible(false)
		enemy_map_layer:setVisible(false)

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

	-- local function initBtn()
	-- 	self.btn_close = self:createButton({image = "#common_btn_close1.png", x =932, y =500,sound = music_info.COMMON_CLOSE.res})
	-- 	self:addChild(self.btn_close, 12)
	-- 	self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.btn_close
	-- 	self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.btn_close
	-- end

	initBg()
	initMap()
	initMapBox()
	-- initBtn()
	self:initBtnCall()
	self:initEvent()
	self:initMapUI()
	return true
end

function ClsGuildSmallMap:titleToCocos(position)
	return ccp(position.x * SMALL_TITLE_SIZE, SMALL_LAND_HEIGHT - position.y * SMALL_TITLE_SIZE)
end

function ClsGuildSmallMap:titleToCocos2(position)
	return ccp(position.x * SMALL_TITLE_SIZE + SMALL_TITLE_SIZE / 2, SMALL_LAND_HEIGHT - position.y * SMALL_TITLE_SIZE - SMALL_TITLE_SIZE / 2)
end

function ClsGuildSmallMap:cocosToTitle(position)
	local x = math.floor(position.x / SMALL_TITLE_SIZE)
	local y = math.floor((SMALL_LAND_HEIGHT - position.y) / SMALL_TITLE_SIZE)
	return ccp(x, y)
end

function ClsGuildSmallMap:onMutilTouchMoved(curPos, lastPos) -- 多点触摸移动
	self.touchLastPoint = nil
	self.touchSecondPoint = nil
end

function ClsGuildSmallMap:initBtnCall()
	self.btn_enemy:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if not tolua.isnull(self.enemy_icon_layer) then
			self.enemy_icon_layer:setVisible(true)
		end
	end, CHECKBOX_STATE_EVENT_SELECTED)

	self.btn_enemy:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if not tolua.isnull(self.enemy_icon_layer) then
			self.enemy_icon_layer:setVisible(false)
		end
	end, CHECKBOX_STATE_EVENT_UNSELECTED)

	self.btn_ourside:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if not tolua.isnull(self.friend_icon_layer) then
			self.friend_icon_layer:setVisible(true)
		end
	end, CHECKBOX_STATE_EVENT_SELECTED)

	self.btn_ourside:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if not tolua.isnull(self.friend_icon_layer) then
			self.friend_icon_layer:setVisible(false)
		end
	end, CHECKBOX_STATE_EVENT_UNSELECTED)

	self.btn_sailing:setPressedActionEnabled(true)
	self.btn_sailing:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if getGameData():getTeamData():isLock(true) then
			return false
		end
		if self.select_stronghold_id <=0 then
			return
		end
		local judian_datas = ClsSceneManage:getSceneAttr("judian_datas")
		local judian_data = judian_datas[self.select_stronghold_id]
		if not judian_data then
			return
		end
		local is_same = getGameData():getExplorePlayerShipsData():isSameCampByValue(judian_data.attr.camp)
		if is_same and (not self.friend_icon_layer:isVisible()) then
			return
		end
		if (not is_same) and (not self.enemy_icon_layer:isVisible()) then
			return
		end
		
		local copy_scene_ui = ClsSceneManage:getSceneUILayer()
		if not tolua.isnull(copy_scene_ui) then
			copy_scene_ui:setIsDropAnchor(false)
		end
		self:showMin()
		self:navToStronghold(self.select_stronghold_id)
	end,TOUCH_EVENT_ENDED)

	self.btn_enemy:executeEvent(CHECKBOX_STATE_EVENT_SELECTED)
	self.btn_enemy:setSelectedState(true)
	self.btn_ourside:executeEvent(CHECKBOX_STATE_EVENT_SELECTED)
	self.btn_ourside:setSelectedState(true)
end

function ClsGuildSmallMap:navToStronghold(select_stronghold_id)
	ClsSceneManage:doLogic("touchEnd")
	self.select_nav_id = select_stronghold_id
	local guild_stronghold_item = guild_stronghold_config[self.select_nav_id]
	local stronghold_pos = ccp(guild_stronghold_item.ship_pos[1], guild_stronghold_item.ship_pos[2])
	self.m_scene_layer:getLand():moveToTPos(stronghold_pos, function() end)
end

function ClsGuildSmallMap:getJudianData(stronghold_id)
	local judian_datas = ClsSceneManage:getSceneAttr("judian_datas") or {}
	return judian_datas[stronghold_id]
end

function ClsGuildSmallMap:showSelectEffect(stronghold_id, pos)
	if not tolua.isnull(self.goal_point_effect) then
		self.goal_point_effect:removeFromParentAndCleanup(true)
		self.goal_point_effect = nil
	end
	
	local is_same = true
	local judian_data = self:getJudianData(stronghold_id)
	if judian_data then
		is_same = getGameData():getExplorePlayerShipsData():isSameCampByValue(judian_data.attr.camp)
	end
	local color = self.m_ships_layer:getCampColor(is_same)
	if is_same then
		self.target_name:setText(ClsSceneManage:getSceneAttr("blue_name"))
	else
		self.target_name:setText(ClsSceneManage:getSceneAttr("red_name"))
	end
	setUILabelColor(self.target_name, ccc3(dexToColor3B(color)))
	--
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

function ClsGuildSmallMap:selectCurrentStrongHold(stronghold_id, pos, last_id)
	local is_same = true
	local judian_data = self:getJudianData(stronghold_id)
	local name_str = ""
	local hp_n = 0
	local max_hp_n = 1
	if judian_data then
		is_same = getGameData():getExplorePlayerShipsData():isSameCampByValue(judian_data.attr.camp)
		name_str = judian_data.attr.short_name
		hp_n = judian_data.attr.hp or 0
		max_hp_n = judian_data.attr.max_hp or 1
	end
	local color = self.m_ships_layer:getCampColor(is_same)
	local friend_visible = nil
	local enemy_visible = nil 
	if is_same and (not tolua.isnull(self.friend_icon_layer) and not self.friend_icon_layer:isVisible()) then
		friend_visible = true
	end
	if (not is_same) and (not tolua.isnull(self.enemy_icon_layer) and not self.enemy_icon_layer:isVisible()) then
		enemy_visible = true
	end
	if friend_visible or enemy_visible then
		if last_id and last_id > 0 then
			self.select_stronghold_id = last_id
		end
		return
	else
		self.select_stronghold_id = stronghold_id
	end
	self:showSelectEffect(stronghold_id, pos)
	
	self.stronghold_hp_ui.tip_lab:setText(name_str)
	setUILabelColor(self.stronghold_hp_ui.tip_lab, ccc3(dexToColor3B(color)))
	self.stronghold_hp_ui.hp_lab:setText(string.format("%d/%d", hp_n, max_hp_n))
	local per_n = math.floor(100*hp_n/max_hp_n)
	if is_same then
		self.stronghold_hp_ui.my_hp_bar:setPercent(per_n)
		self.stronghold_hp_ui.enemy_hp_bar:setPercent(0)
	else
		self.stronghold_hp_ui.my_hp_bar:setPercent(0)
		self.stronghold_hp_ui.enemy_hp_bar:setPercent(per_n)
	end
end

function ClsGuildSmallMap:clickMap(click_x, click_y)
	local click_pos = self.map_layer:convertToNodeSpace(ccp(click_x, click_y))	
	if self:clickPoint(click_x, click_y) then
		return true
	end
	return false
end

function ClsGuildSmallMap:clickPoint(click_x, click_y)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local pos = self.map:convertToNodeSpace(ccp(click_x, click_y))
	local p = self:cocosToTitle(pos)
	local guild_fight_data = getGameData():getGuildFightData()
	local point = guild_fight_data:isGuildStrongHoldPos(p)
	if point then
		local stronghold_id = point[1]
		self:selectCurrentStrongHold(stronghold_id, p)
	end
	return false
end

function ClsGuildSmallMap:initMapUI()
	self.friend_icon_layer = display.newLayer()
	self.enemy_icon_layer = display.newLayer()
	self.map:addChild(self.friend_icon_layer, 7)
	self.map:addChild(self.enemy_icon_layer, 7)
	
	self.friend_icon_layer.icons_info = {}
	self.enemy_icon_layer.icons_info = {}
	
	self.friend_icon_layer.updateShineEffFunc = function(icon_layer)
		local now_time_n = os.clock()
		for key, icon_spr in pairs(icon_layer.icons_info) do
			local judian_data = self:getJudianData(key)
			local left_time_n = 0
			if judian_data then
				local hit_time = judian_data.attr.hit_time or 0
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
	self.enemy_icon_layer.updateShineEffFunc = self.friend_icon_layer.updateShineEffFunc
	
	local repeat_act = UiCommon:getRepeatAction(0.5, function()
			self.friend_icon_layer.updateShineEffFunc(self.friend_icon_layer)
		end)
	self.friend_icon_layer:runAction(repeat_act)
	
	repeat_act = UiCommon:getRepeatAction(0.5, function()
			self.enemy_icon_layer.updateShineEffFunc(self.enemy_icon_layer)
		end)
	self.enemy_icon_layer:runAction(repeat_act)
	
	self:updateIcon()
end

function ClsGuildSmallMap:updateIcon()
	for key, value in pairs(guild_stronghold_config) do
		if value.map_pos then
			local is_same = true
			local judian_data = self:getJudianData(key)
			if judian_data then
				is_same = getGameData():getExplorePlayerShipsData():isSameCampByValue(judian_data.attr.camp)
			else
				judian_data = {attr = {}}
			end
			local lab_color = self.m_ships_layer:getCampColor(is_same)
			local add_layer = self.friend_icon_layer
			local remove_layer = self.enemy_icon_layer
			local icon_str = "#guild_point_friend.png"
			if not is_same then
				add_layer = self.enemy_icon_layer
				remove_layer = self.friend_icon_layer
				icon_str = "#guild_point_enemy.png"
			end
			if remove_layer.icons_info[key] then
				remove_layer.icons_info[key]:removeFromParentAndCleanup(true)
				remove_layer.icons_info[key] = nil
			end
			local name_str = judian_data.attr.short_name or ""
			local icon_spr = add_layer.icons_info[key]
			if not icon_spr then
				icon_spr = display.newSprite(icon_str)
				local size = icon_spr:getContentSize()
				add_layer:addChild(icon_spr)
				local name_lab = createBMFont({text = name_str, size = 14, color = ccc3(dexToColor3B(lab_color))})
				name_lab:setPosition(ccp(size.width / 2, 30))
				name_lab.strong_name_str = name_str
				icon_spr:addChild(name_lab)
				
				local pos = self:titleToCocos2(ccp(value.map_pos[1], value.map_pos[2]))
				icon_spr:setPosition(pos)
				
				local eff_icon_spr = display.newSprite(icon_str)
				eff_icon_spr:setPosition(size.width/2, size.height/2)
				icon_spr:addChild(eff_icon_spr)
				icon_spr.eff_icon_spr = eff_icon_spr
				
				icon_spr.name_lab = name_lab
				add_layer.icons_info[key] = icon_spr
			else
				if icon_spr.name_lab.strong_name_str ~= name_str then
					icon_spr.name_lab:setString(name_str)
					icon_spr.name_lab.strong_name_str = name_str
				end
			end
		end
	end
end

function ClsGuildSmallMap:setMapLayerPos(ship_next_x, ship_next_y)
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

function ClsGuildSmallMap:setShipPosInfo(is_check_max)
	if self.ship3d and tolua.isnull(self.ship3d.node) then
		return
	end
	local x, y = self.ship3d:getPos()
	local pos_info = {x = x, y = y, angle = self.ship3d:getAngle()}
	local angle = pos_info.angle
	local dx = pos_info.x or 0
	local dy = pos_info.y or 0
	local pos_rate = 8

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

function ClsGuildSmallMap:ajustMapLayerPos(curX, curY)
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

function ClsGuildSmallMap:onTouchBegan(x, y, isMutilTouchMode)
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

function ClsGuildSmallMap:onTouchMoved(x, y, isMutilTouchMode)
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

function ClsGuildSmallMap:isTouchMinRect(x, y)
	if (not self.show_max) and self.show_min_viewport_rect:containsPoint(ccp(x,y)) then
		local sound = music_info.EX_DRAGMAP   -- 音效
		audioExt.playEffect(sound.res, false)
		self:showMax()
		return true
	end
	return false
end

function ClsGuildSmallMap:setCurShowViewPortRect(rect)
	self.cur_show_viewport_rect = rect
	self.map_border:setContentSize(CCSizeMake(self.cur_show_viewport_rect.size.width, self.cur_show_viewport_rect.size.height))
	self.map_border:setPosition(ccp(self.cur_show_viewport_rect.origin.x, self.cur_show_viewport_rect.origin.y))
	self.viewport:setClippingRegion(self.cur_show_viewport_rect)
end

function ClsGuildSmallMap:initEvent()
	local mult_touch = require("ui/tools/mult_touch_layer")
	self.map_layer.onTouchBegan = function(x,y,isMutilTouchMode) self:onTouchBegan(x,y,isMutilTouchMode) end
	self.map_layer.onTouchMoved = function(x,y,isMutilTouchMode) self:onTouchMoved(x,y,isMutilTouchMode) end
	self.map_layer.onTouchEnded = function(x,y,isMutilTouchMode) self:onTouchEnded(x,y,isMutilTouchMode) end
	self.map_layer.onMutilTouchMoved = function(curPos, lastPos)
		self:onMutilTouchMoved(curPos, lastPos) end
	mult_touch:initTouchLayer(self.map_layer)

	self.btn_close:addEventListener(function()
		self:btnCloseListener()
	end, TOUCH_EVENT_ENDED)
end

function ClsGuildSmallMap:showMin()
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
	self.m_timer_spr:stopAllActions()
end

function ClsGuildSmallMap:showMax()
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
	self.select_stronghold_id = 0
	self:updateStrongScoreUI()
	local nav_id = 0
	if IS_AUTO then
		nav_id = self.select_nav_id
	end

	--导航中就选中导航的，否则 选中默认的最近的
	local min_hold_id, min_pos
	if nav_id > 0 then
		min_hold_id = nav_id
		min_pos = ccp(guild_stronghold_config[nav_id].map_pos[1], guild_stronghold_config[nav_id].map_pos[2])
	else
		min_hold_id, min_pos = self:selectNearestHold()
	end
	self:selectCurrentStrongHold(min_hold_id, min_pos, last_id)
	
	local repeat_act = UiCommon:getRepeatAction(5, function() self:askGuildPoint() end)
	self.m_timer_spr:stopAllActions()
	self.m_timer_spr:runAction(repeat_act)
	self:askGuildPoint()
end

function ClsGuildSmallMap:askGuildPoint()
	if not self.show_max then
		self.m_timer_spr:stopAllActions()
	end
end

function ClsGuildSmallMap:updateStrongScoreUI()
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local my_point = ClsSceneManage:getSceneAttr("blue_point") or 0
	local other_point = ClsSceneManage:getSceneAttr("red_point") or 0
	self.our_score:setText(tostring(my_point))
	self.our_name:setText(ClsSceneManage:getSceneAttr("blue_name"))
	self.enemy_score:setText(tostring(other_point))
	self.enemy_name:setText(ClsSceneManage:getSceneAttr("red_name"))
	local my_per_n = 50
	if my_point > 0 or other_point > 0 then
		my_per_n = math.ceil(my_point*100/(my_point + other_point))
	end
	local enemy_per_n = 100 - my_per_n
	self.my_progress:setPercent(my_per_n)
	self.enemy_progress:setPercent(enemy_per_n)
end

function ClsGuildSmallMap:selectNearestHold()
	local px, py = self.ship3d:getPos()
	local minDistance = 0
	local min_hold_id = 0
	local min_pos = ccp(0, 0)

	local has_min_distance = 0
	local has_hold_id = 0
	local has_min_pos = ccp(0, 0)

	local count = 0
	local has_count = 0
	for key, value in ipairs(guild_stronghold_config) do
		if value.ship_pos then
			local ship_pos = self.m_scene_layer:getLand():cocosToTile2(ccp(value.ship_pos[1], value.ship_pos[2]))
			local dis = Math.distance(px, py, ship_pos.x, ship_pos.y)
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

function ClsGuildSmallMap:onExit()
	ClsGuildSmallMap.super.onExit(self)
	--移除资源
	UnLoadPlist(self.resPlist)
	UnLoadArmature(self.armature_res_2)
	RemoveTextureForKey(self.map_bg_res)
end

return ClsGuildSmallMap  



