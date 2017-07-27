-- 小地图
local music_info = require("game_config/music_info")

local ClsPirateIcon =  require("gameobj/explore/explorePirateIcon")

local scheduler = CCDirector:sharedDirector():getScheduler()

local SmallMap = class("SmallMap", require("ui/view/clsBaseView"))

SmallMap.MAP_RES_TYPE_TMX = 1 --tmx
SmallMap.MAP_RES_TYPE_TEX = 2 --图片
SmallMap.OFF_CENTER = 20

function SmallMap:getViewConfig()
    return {}
end

function SmallMap:onEnter(map_res_url, map_res_type)
	
	self.plist_res_1 = {
	}
	self.armature_res_1 = {
        "effects/tx_0053.ExportJson",
	}

	LoadPlist(self.plist_res_1)
	LoadArmature(self.armature_res_1)

	self.show_max_viewport_rect = CCRect(12, 13, 938, 453)
	self.show_min_viewport_rect = CCRect(display.width - 200 + 3, display.height - 150 + 3, 200, 150)
	self.cur_show_viewport_rect = self.show_max_viewport_rect

	self.map_area_show_rect = CCRect(0, 0, 0, 0) --子类记得根据自己的情况设置对应的地图可见区域

	self.map_layer_min_scale = nil
	self.map_layer_max_scale = nil
	self.show_max_map_layer_scale = nil
	self.show_min_map_layer_scale = nil

	self.show_max_show_nodes = {}
	self.show_max_hide_nodes = {}
	self.show_min_show_nodes = {}
	self.show_min_hide_nodes = {}

	self.ship_pos_rate = 1 --子类记得根据自己的情况设置对应的比率
	self.last_ship_pos = ccp(0, 0)
	self.border_offsets = nil

	self.pirate_boss_icons = {}
    self.pirate_icons = {}

	self.show_max = nil       --是否最大化
	self.is_enable = true      --是否可点击
	
end

function SmallMap:initUI(map_res_url, map_res_type)
	self.map_res_url = map_res_url
	self.map_res_type = map_res_type
	local init_result = true
	
	local map_root_wid = UIWidget:create()
	map_root_wid:setZOrder(5)
	self:addWidget(map_root_wid)
	self.map_root_wid = map_root_wid

	local function initBg()
		local border = display.newSpriteFrame("map_frame.png")
		self.map_border = CCScale9Sprite:createWithSpriteFrame(border)
		self.map_border:setContentSize(CCSizeMake(682, 453))
		self.map_border:setPosition(ccp(266, 13))
		self.map_border:setAnchorPoint(ccp(0, 0))
		self.map_root_wid:addCCNode(self.map_border)
		self.map_border:setZOrder(1)
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.map_border
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.map_border
	end
	
	local function initMap()
		if self.map_res_type == self.MAP_RES_TYPE_TMX then
			self.map = CCTMXTiledMap:create(self.map_res_url)
			self.map_tile_size = self.map:getTileSize().width
		else
			self.map = display.newSprite(self.map_res_url, 0, 0)
			self.map:setAnchorPoint(ccp(0,0))
			self.map_tile_size = 32
		end
		self.map_width = self.map:getContentSize().width
		self.map_height = self.map:getContentSize().height

		local map_layer_scale_x = self.show_max_viewport_rect.size.width / self.map_width
		local map_layer_scale_y = self.show_max_viewport_rect.size.height / self.map_height
		self.map_layer_min_scale = Math.max(map_layer_scale_x, map_layer_scale_y)
		self.map_layer_max_scale = self.map_layer_min_scale + 2

		self.show_max_map_layer_scale = self.show_max_viewport_rect.size.width / self.map_width

		------------- tilemap的图层,子类可重写initUI函数进行操作---------------

		local ship_effect = CCArmature:create("tx_0053")
		local armature_animation = ship_effect:getAnimation()
		armature_animation:playByIndex(0)
		self.ship = CCNode:create()
		self.ship:setScale(0.7)
		self.ship.angle_flag = 1
		self.ship:addChild(ship_effect)
		self.map:addChild(self.ship,20)
		
		self.trace_obj = display.newSprite()
		self.map:addChild(self.trace_obj, 20)

		local pirate_spr = display.newSprite("#map_boss.png")
		self.trace_obj:addChild(pirate_spr)
		
		local name_parameter = {
			text = "",
			size = 20,
			fontFile = FONT_CFG_1,
			align = ui.TEXT_ALIGN_CENTER,
			color = ccc3(dexToColor3B(COLOR_WHITE_STROKE_RED)),
		}
		local player_name = createBMFont(name_parameter)
		self.trace_obj.name = player_name
		self.trace_obj:addChild(player_name)
		local spr_size = pirate_spr:getContentSize()
		local spr_pos_x, spr_pos_y = pirate_spr:getPosition()
		player_name:setPosition(ccp(spr_pos_x, spr_pos_y - spr_size.height / 2 - 5))
		self.trace_obj:setVisible(false)

		self.viewport = display.newClippingRegionNode(self.show_max_viewport_rect)
		self.map_root_wid:addCCNode(self.viewport)

		self.viewport_color_bg = CCLayerColor:create(ccc4(0,0,0,250))
		self.viewport:addChild(self.viewport_color_bg, -1)

		self.map_layer = display.newLayer()
		self.map_layer:ignoreAnchorPointForPosition(false)
		self.map_layer:setAnchorPoint(ccp(0,0))
		self.map_layer:addChild(self.map)
		self.viewport:addChild(self.map_layer)
	end

	local function initMapBox()
		local size = self.show_min_viewport_rect.size
		-- 小地图显示框
    	self.map_box = CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame("explore_map_frame.png"))
		self.map_box:setAnchorPoint(ccp(1,1))
		self.map_box:setContentSize(CCSizeMake(134, 134))
		self.map_box:setPosition(ccp(display.width, display.height))
		self.map_box_x = self.map_box:getPositionX()
		self.map_box_y = self.map_box:getPositionY()
		self.map_box_centerx = self.map_box_x - size.width/2   --显示框的中心位置
		self.map_box_centery = self.map_box_y - size.height/2
		self.map_root_wid:addCCNode(self.map_box)
		self.map_box:setZOrder(-1)
		self.show_min_map_layer_scale = 1
		self.show_max_hide_nodes[#self.show_max_hide_nodes + 1] = self.map_box
		self.show_min_show_nodes[#self.show_min_show_nodes + 1] = self.map_box
	end

	local function initBtn()
		self.btn_close = self:createButton({image = "#common_btn_close1.png", x =920, y =510,sound = music_info.COMMON_CLOSE.res})
		map_root_wid:addCCNode(self.btn_close)
		self.btn_close:setZOrder(2)
		self.show_max_show_nodes[#self.show_max_show_nodes + 1] = self.btn_close
		self.show_min_hide_nodes[#self.show_min_hide_nodes + 1] = self.btn_close
	end

	local function initShipPos()
		--子类需要重写该方法，否则初始化不了船在地图上的位置
		self:setMapAreaShowRect(0, 0, self.map_width, self.map_height)
	end

	initMap()
	initBg()
	initMapBox()
	initBtn()
	initShipPos()
	
	return init_result
end

function SmallMap:initEvent()
	local mult_touch = require("ui/tools/mult_touch_layer")
	self.map_layer.onTouchBegan = function(x,y,isMutilTouchMode) self:onTouchBegan(x,y,isMutilTouchMode) end
	self.map_layer.onTouchMoved = function(x,y,isMutilTouchMode) self:onTouchMoved(x,y,isMutilTouchMode) end
	self.map_layer.onTouchEnded = function(x,y,isMutilTouchMode) self:onTouchEnded(x,y,isMutilTouchMode) end
	self.map_layer.onMutilTouchMoved = function(curPos, lastPos)
		self:onMutilTouchMoved(curPos, lastPos) end
	mult_touch:initTouchLayer(self.map_layer)

	self.btn_close:regCallBack(function()
		self:btnCloseListener()
	end)
end

function SmallMap:onTouchChange(is_touch)
	self.map_layer:setTouchEnabled(is_touch)
end

function SmallMap:getShowMax()
	return self.show_max
end

function SmallMap:btnCloseListener()
	self:showMin()
	self.touch_delay = true  -- 触摸延迟
	require("framework.scheduler").performWithDelayGlobal(function() self.touch_delay = false end, 0.5)
end

-------------触摸事件---------------
function SmallMap:onTouchBegan(x, y, isMutilTouchMode)
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
		return true
	end

	if self.show_max then
		self.touchBeginPoint= {x = x, y = y}
		return true
	end
	return false
end

function SmallMap:onTouchMoved(x, y, isMutilTouchMode)
	if self.show_max and self.is_enable and self.cur_show_viewport_rect:containsPoint(ccp(x,y)) then
		local cx = self.map_layer:getPositionX()
		local cy = self.map_layer:getPositionY()
		if self.touchLastPoint then
			local curX = cx
			local curY = cy

			curX = cx + x - self.touchLastPoint.x
			curY = cy + y - self.touchLastPoint.y
			curX, curY = self:ajustMapLayerPos(curX, curY, nil, self.border_offsets)
			self.map_layer:setPosition(curX, curY)
		end
		self.touchSecondPoint = self.touchLastPoint
		self.touchLastPoint = {x = x, y = y}
	end
end

function SmallMap:isCanMutilTouch()
	return true
end

function SmallMap:onMutilTouchMoved(curPos, lastPos) -- 多点触摸移动
	if self.show_max and self:isCanMutilTouch() and self.is_enable and self.cur_show_viewport_rect:containsPoint(ccp(curPos.x, curPos.y)) 
		and self.cur_show_viewport_rect:containsPoint(ccp(lastPos.x, lastPos.y)) then
		local scale = self.map_layer:getScale()
		local x, y = curPos.x, curPos.y
		local cur_scale = curPos.dis/lastPos.dis * scale

		local map_layer_max_scale = self:getMapLayerMaxScale()
		local map_layer_min_scale = self:getMapLayerMinScale()
		if cur_scale > map_layer_max_scale then
			cur_scale = map_layer_max_scale
		end
		if cur_scale < map_layer_min_scale then
			cur_scale = map_layer_min_scale
		end

		local pos = self.map_layer:convertToNodeSpace(ccp(x, y))  --把世界坐标转当前坐标系
		local curX = (x-lastPos.x)+(x-pos.x*cur_scale)
		local curY = (y-lastPos.y)+(y-pos.y*cur_scale)

		self:setMapLayerScale(cur_scale)
		curX, curY = self:ajustMapLayerPos(curX, curY, nil, self.border_offsets)
		self.map_layer:setPosition(curX, curY)
	end
	self.touchLastPoint = nil
	self.touchSecondPoint = nil
end

function SmallMap:onTouchEnded(x, y, isMutilTouchMode)
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
			if not self:clickMap(x, y) then
				self:clickPoint(x, y)
			end
		elseif self.touchSecondPoint then -- 拖动惯性
			local dx = (self.touchLastPoint.x - self.touchSecondPoint.x)
			local dy = (self.touchLastPoint.y - self.touchSecondPoint.y)
			local curX = cx + dx*3
			local curY = cy + dy*3
			curX, curY = self:ajustMapLayerPos(curX, curY)

			local params = {
				time = 1,
				x = curX,
				y = curY,
				easing ="CCEaseExponentialOut"
			}
			transition.stopTarget(self.map_layer)
			local action = transition.moveTo(self.map_layer, params)

			self:onTouchEndedDrag(x, y, isMutilTouchMode)
		end
	end
	self.touchLastPoint = nil
	self.touchBeginPoint = nil
	self.touchSecondPoint = nil
end

function SmallMap:onTouchEndedDrag(x, y, isMutilTouchMode)
	
end

function SmallMap:clickMap(click_x, click_y)
	return false
end

function SmallMap:clickPoint(click_x, click_y)
	return false
end

function SmallMap:ajustMapLayerPos(map_next_x, map_next_y, map_next_scale, border_offsets)
	local map_layer_scale = map_next_scale or self.map_layer:getScale()
	local view_port_rect = self.cur_show_viewport_rect
	local view_port_x = view_port_rect.origin.x
	local view_port_y = view_port_rect.origin.y
	local view_port_width = view_port_rect.size.width
	local view_port_height = view_port_rect.size.height

	local top_border_offset = 0
	local bottom_border_offset = 0
	local left_border_offset = 0
	local right_border_offset = 0
	if border_offsets then
		top_border_offset = border_offsets[1]
		bottom_border_offset = border_offsets[2]
		left_border_offset = border_offsets[3]
		right_border_offset = border_offsets[4]
	end

	local map_area_x = self.map_area_show_rect.origin.x * map_layer_scale
	local map_area_y = self.map_area_show_rect.origin.y * map_layer_scale
	local map_area_width = self.map_area_show_rect.size.width * map_layer_scale
	local map_area_height = self.map_area_show_rect.size.height * map_layer_scale

	local minX = view_port_width - map_area_width - map_area_x + view_port_x
	local maxX = view_port_x - map_area_x

	local minY = view_port_height - map_area_height - map_area_y + view_port_y
	local maxY = view_port_y - map_area_y

	local map_layer_to_top_border_dis = Math.min(minY - map_next_y, top_border_offset)
	local map_layer_to_bottom_border_dis = Math.min(map_next_y - maxY, bottom_border_offset)
	local map_layer_to_left_border_dis = Math.min(map_next_x - maxX, left_border_offset)
	local map_layer_to_right_border_dis = Math.min(minX - map_next_x, right_border_offset)

	local max_border_dis = 0
	local max_border_name = ""

	if map_layer_to_top_border_dis > max_border_dis then
		max_border_dis = map_layer_to_top_border_dis
		max_border_name = "top"
	end
	if map_layer_to_bottom_border_dis > max_border_dis then
		max_border_dis = map_layer_to_bottom_border_dis
		max_border_name = "bottom"
	end
	if map_layer_to_left_border_dis > max_border_dis then
		max_border_dis = map_layer_to_left_border_dis
		max_border_name = "left"
	end
	if map_layer_to_right_border_dis > max_border_dis then
		max_border_dis = map_layer_to_right_border_dis
		max_border_name = "right"
	end

	if max_border_name == "top" then
		bottom_border_offset = 0
		left_border_offset = 0
		right_border_offset = 0
	elseif max_border_name == "bottom" then
		top_border_offset = 0
		left_border_offset = 0
		right_border_offset = 0
	elseif max_border_name == "left" then
		top_border_offset = 0
		bottom_border_offset = 0
		right_border_offset = 0
	elseif max_border_name == "right" then
		top_border_offset = 0
		bottom_border_offset = 0
		left_border_offset = 0
	end

	if view_port_width <= map_area_width then
		if map_next_x < minX - right_border_offset then
			map_next_x = minX - right_border_offset
		elseif map_next_x > maxX + left_border_offset then
			map_next_x = maxX + left_border_offset
		end
	else
		if map_next_x < maxX + left_border_offset then
			map_next_x = maxX + left_border_offset
		elseif map_next_x > minX - right_border_offset then
			map_next_x = minX - right_border_offset
		end
	end
	map_layer_to_left_border_dis = map_next_x - maxX
	map_layer_to_right_border_dis = map_next_x - minX

	if view_port_height <= map_area_height then
		if map_next_y < minY - top_border_offset then
			map_next_y = minY - top_border_offset
		elseif map_next_y > maxY + bottom_border_offset then
			map_next_y = maxY + bottom_border_offset
		end
	else
		if map_next_y < maxY + bottom_border_offset then
			map_next_y = maxY + bottom_border_offset
		elseif map_next_y > minY - top_border_offset then
			map_next_y = minY - top_border_offset
		end
	end
	map_layer_to_top_border_dis = map_next_y - minY
	map_layer_to_bottom_border_dis = map_next_y - maxY

	return map_next_x, map_next_y, map_layer_to_top_border_dis, map_layer_to_bottom_border_dis, map_layer_to_left_border_dis, map_layer_to_right_border_dis
end

function SmallMap:setCurShowViewPortRect(rect)
	self.cur_show_viewport_rect = rect
	self.map_border:setContentSize(CCSizeMake(self.cur_show_viewport_rect.size.width, self.cur_show_viewport_rect.size.height))
	self.map_border:setPosition(ccp(self.cur_show_viewport_rect.origin.x, self.cur_show_viewport_rect.origin.y))
	self.viewport:setClippingRegion(self.cur_show_viewport_rect)
end

function SmallMap:setMapAreaShowRect(x, y, width, height)
	self.map_area_show_rect.origin.x = x
	self.map_area_show_rect.origin.y = y
	self.map_area_show_rect.size.width = width
	self.map_area_show_rect.size.height = height

	self:setShipPosInfo({is_add_value = true, x = 0, y = 0, angle = self.ship.ship_angle})
end

function SmallMap:setMapLayerScale(scale)
	if self.map_layer:getScale() == scale then
		return false
	end
	self.map_layer:setScale(scale)
	return true
end

function SmallMap:getMapLayerMinScale()
    --子类可以重写该方法
	return self.map_layer_min_scale
end

function SmallMap:getMapLayerMaxScale()
    --子类可以重写该方法
	return self.map_layer_max_scale
end

function SmallMap:setMapLayerPos(target_x, target_y, child_x, child_y)
	child_x = child_x or 0
	child_y = child_y or 0
	local map_layer_scale = self.map_layer:getScale()
	local map_next_x = target_x - child_x * map_layer_scale
	local map_next_y = target_y - child_y * map_layer_scale
	map_next_x, map_next_y = self:ajustMapLayerPos(map_next_x, map_next_y)
	self.map_layer:setPosition(ccp(map_next_x, map_next_y))
end

function SmallMap:alignMapLayerToXY(child_x, child_y)
	child_x = child_x or 0
	child_y = child_y or 0
	local map_layer_target_x = self.cur_show_viewport_rect.origin.x + self.cur_show_viewport_rect.size.width/2
	local map_layer_target_y = self.cur_show_viewport_rect.origin.y + self.cur_show_viewport_rect.size.height/2
	self:setMapLayerPos(map_layer_target_x, map_layer_target_y, child_x, child_y)
end

function SmallMap:mapLayerScaleTo(child_x, child_y, target_scale, scale_time)
	local map_layer_target_x = self.cur_show_viewport_rect.origin.x + self.cur_show_viewport_rect.size.width/2
	local map_layer_target_y = self.cur_show_viewport_rect.origin.y + self.cur_show_viewport_rect.size.height/2

	local map_layer_child_x = child_x * target_scale
	local map_layer_child_y = child_y * target_scale

	local map_layer_action_pos = ccp(map_layer_target_x - map_layer_child_x, map_layer_target_y - map_layer_child_y)
	map_layer_action_pos.x, map_layer_action_pos.y = self:ajustMapLayerPos(map_layer_action_pos.x, map_layer_action_pos.y, target_scale)
	
	transition.stopTarget(self.map_layer)

    local action_arr = CCArray:create()
    local scale_move_action = CCSpawn:createWithTwoActions(CCScaleTo:create(scale_time, target_scale), CCMoveTo:create(scale_time, map_layer_action_pos))
    action_arr:addObject(scale_move_action)

    self.map_layer:runAction(CCSequence:create(action_arr))
end

function SmallMap:isShipPosChange(ship_next_x, ship_next_y)
	return false
end

function SmallMap:setShipPosChangeCb(call_back)
	self.ship_pos_change_call_back = call_back
end

function SmallMap:setShipPosInfo(pos_info)
	if not pos_info then return end
	local angle = Math.floor((pos_info.angle or 0) + 0.5)
	local dx = pos_info.x or 0
	local dy = pos_info.y or 0
	local pos_rate = pos_info.pos_rate or self.ship_pos_rate
	local is_add_value = pos_info.is_add_value
	local ship_x = self.ship:getPositionX()
	local ship_y = self.ship:getPositionY()
	
	dx = dx / pos_rate
	dy = dy / pos_rate
	
	local ship_next_x = dx
	local ship_next_y = dy
	if is_add_value then
		ship_next_x = ship_x + dx
		ship_next_y = ship_y + dy
	end

	self.ship:setPosition(ccp(ship_next_x, ship_next_y))

	if angle >= 0 and angle < 180 then
		self.ship.angle_flag = -1
	else
		self.ship.angle_flag = 1
	end
	self.ship:setScaleX(self.ship.angle_flag * Math.abs(self.ship:getScaleX()))
	self.ship.ship_angle = angle

	if self:isShipPosChange(ship_next_x, ship_next_y) and self.ship_pos_change_call_back ~= nil then
		self.ship_pos_change_call_back(ship_next_x, ship_next_y)
	end
	if not self.show_max then
		self:setMapLayerPos(self.map_box_centerx, self.map_box_centery, ship_next_x, ship_next_y)
	end
end

function SmallMap:isShowMax()
	return self.show_max
end

function SmallMap:isInShowViewPortRect(x, y)
    -- print("x = "..x..", y = "..y)
    -- print("1111   x = "..self.cur_show_viewport_rect.origin.x..", y = "..self.cur_show_viewport_rect.origin.y..", width = "..self.cur_show_viewport_rect.size.width..", height = "..self.cur_show_viewport_rect.size.height)
    if self.cur_show_viewport_rect:containsPoint(ccp(x,y)) then
        return true
	end
	return false
end

-----------------最大化---------------------
function SmallMap:showMax()
	self.show_max = true

	transition.stopTarget(self.map_layer)
	self:setMapLayerScale(self.show_max_map_layer_scale)

	for k,v in ipairs(self.show_max_hide_nodes) do
		v:setVisible(false)
	end
	for k,v in ipairs(self.show_max_show_nodes) do
		v:setVisible(true)
	end

	self:setCurShowViewPortRect(self.show_max_viewport_rect)

	self:setShipPosInfo({is_add_value = true, x = 0, y = 0, angle = self.ship.ship_angle})
end

-------------------最小化---------------------
function SmallMap:showMin()
	self.show_max = false

	transition.stopTarget(self.map_layer)
	self:setMapLayerScale(self.show_min_map_layer_scale)

	for k,v in ipairs(self.show_min_hide_nodes) do
		v:setVisible(false)
	end
	for k,v in ipairs(self.show_min_show_nodes) do
		v:setVisible(true)
	end

	self:setCurShowViewPortRect(self.show_min_viewport_rect)

	self:setShipPosInfo({is_add_value = true, x = 0, y = 0, angle = self.ship.ship_angle})
end


function SmallMap:onExit()
	--移除资源
	UnLoadPlist(self.plist_res_1)
	UnLoadArmature(self.armature_res_1)
	ReleaseTexture(self)
	--
	self.show_max_show_nodes = nil
	self.show_max_hide_nodes = nil
	self.show_min_show_nodes = nil
	self.show_min_hide_nodes = nil

	self:releaseAllPirateIcon()

	self.pirate_boss_icons = nil
	self.pirate_icons = nil

	require("ui/tools/mult_touch_layer"):clear()
end

--探索主线boss，海盗图标，港口和出海地图界面，公用
function SmallMap:setPirateIconScale(scale)
	for _, icon in pairs(self.pirate_boss_icons) do
		icon:setIconScale()
	end

	for _, icon in pairs(self.pirate_icons) do
		icon:setIconScale()
	end
end

function SmallMap:releaseAllPirateIcon()
	for _, icon in pairs(self.pirate_boss_icons) do
		icon:release()
	end

	for _, icon in pairs(self.pirate_icons) do
		icon:release()
	end
	self.pirate_boss_icons = {}
	self.pirate_icons = {}
end

function SmallMap:createHeadIcon(x, y)
	local CompositeEffect= require("gameobj/composite_effect")
	--local icon = CompositeEffect.new("tx_0103", x, y, self.map, -1, nil)
	local icon = CompositeEffect.bollow("tx_0103", x, y, self.map, -1)
	icon:setZOrder(20)
	local label = createBMFont({text = "BOSS", size = 16, fontFile = FONT_CFG_1, 
	    	color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 10})
	--label:setScale(-1)
	icon:addChild(label, 50)
	icon.boss_label = label
	return icon
end

function SmallMap:getBossHeadIcon(boss_id)
	return self.pirate_boss_icons[boss_id]
end

function SmallMap:getPirateHeadIcon(pirate_id)
	return self.pirate_icons[pirate_id]
end

--港口界面地图的主线战boss和小怪
function SmallMap:createExplorePirateUI()
	
	self:releaseAllPirateIcon()

	local playerData = getGameData():getPlayerData()
	local explore_pirate_ids = playerData:getExplorePirates()
	local pirate_boss = explore_pirate_ids.boss_pirate
	local pirates =  explore_pirate_ids.pirate

	if pirate_boss then
		for _, item in pairs(pirate_boss) do
			local icon = ClsPirateIcon.new(self, item.id, item.start_time, true)
			self.pirate_boss_icons[item.id] = icon
		end
	end

	if pirates then
		for _, item in pairs(pirates) do
			local icon = ClsPirateIcon.new(self, item.id, item.start_time, false)
			self.pirate_icons[item.id] = icon
		end
	end
	self:setPirateIconScale()
end

return SmallMap
