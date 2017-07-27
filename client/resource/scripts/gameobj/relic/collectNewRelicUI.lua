 -- 遗迹系统
require("gameobj/mission/missionInfo")
local UiCommon = require("ui/tools/UiCommon")
local UI_WORD = require("game_config/ui_word")
local relic_info = require("game_config/collect/relic_info")
local Alert = require("ui/tools/alert")
local mult_touch = require("ui/tools/mult_touch_layer")
local CompositeEffect= require("gameobj/composite_effect")
local music_info = require("game_config/music_info")
local tips = require("game_config/tips")

local OFF_CENTER = 5
local ZEODERBASE = 2
local player_id = nil
local RATE = EXPLORE_RATE     -- 地图与探索的比例
local order = {BG = 1, EFFECT = 2, MASK = 3, FONT = 4 }
local typeCollection ={ TYPE_FRIEND = 1, TYPE_SELF = 0, type = 0}

local collectNewRelicUI = class("collectNewRelicUI", require('ui/view/clsBaseView'))
collectNewRelicUI.onEnter = function(self, data)
	data = data or {}
	local call_back, isClose, newRelicData = data.call_back, data.isClose, data.newRelicData
	self.call_back = call_back
	self:registerScriptHandler(function(event)
		if event == "exit" then
			UnLoadPlist(self.resList)
			RemoveTextureForKey("effects/tx_30050.png")
			RemoveTextureForKey("relic_map/yiji_03.jpg")
			RemoveTextureForKey("relic_map/yiji_02.jpg")
			RemoveTextureForKey("relic_map/yiji_01.jpg")
			RemoveTextureForKey("ui/relic/co_relic_bg.png")
			RemoveTextureForKey("ui/yiji/co_yiji_7.jpg")
			RemoveTextureForKey("relic_map/lock.png")
			RemoveTextureForKey("relic_map/open.png")
		end
	end)
	-- self.parent = parent
	self.isClose = isClose
	self.newRelicData = newRelicData
	self.m_is_create_name_b = false
	self.resList = {
		["ui/relic/relic.plist"] = 1,
	}
	LoadPlist(self.resList)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	--得到地图(是个node)对象
	self.map = CCTMXTiledMap:create("relic_map/yiji_map.tmx")
	CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])

	self.map_width = self.map:getContentSize().width --地图的像素宽度
	self.map_height = self.map:getContentSize().height --地图的像素高度
	self.map_tile_size = self.map:getTileSize().width --每个格子的尺寸(这里只要得到宽度的尺寸即可)
	self.tile_off = self.map_tile_size/2
	self.map_tiles_width = self.map:getMapSize().width    --格子数(地图宽的总格子数)
	self.map_tiles_height = self.map:getMapSize().height  --格子数(地图高的总格子数)

	self.scaleMax = 1  --最大缩放
	self.scaleMinX = display.width / self.map_width
	self.scaleMinY = display.height / self.map_height
	------------- tilemap图层 ---------------
	self.lockLayer = self.map:layerNamed("open") --陆地
	self.lockLayer:setVisible(false)

	self.openLayer = self.map:layerNamed("lock")
	self.openLayer:setVisible(false)

	self.layer = display.newLayer()
	self.layer:ignoreAnchorPointForPosition(false)
	self.layer:setAnchorPoint(ccp(0,0))
	self.layer:addChild(self.map)

	self.layerSize = CCSizeMake(display.width, display.height)
	self.mapScaleX = self.layerSize.width / self.map_width
	self.mapScaleY = self.layerSize.height / self.map_height
	self.layer:setScaleX(self.mapScaleX)
	self.layer:setScaleY(self.mapScaleY)

	self.layer:setPosition(ccp(0, 0))
	local relicHandel = getGameData():getRelicData()
	self.can_check_relics = {}
	if typeCollection.type == typeCollection.TYPE_SELF then
		self.can_check_relics = relicHandel:getOpenRelics()
	else
		self.can_check_relics = relicHandel:getCurrentVisitFriendInfo()
	end

	if #self.can_check_relics == 0 then
		return
	end

	self.names = {}
	self.eventSprites = {}
	self:addChild(self.layer)
	self:initCommonUI()
	self:initEvent()
	self:initRelics()
	relicHandel:initEditRelicHash(self.can_check_relics)
end

collectNewRelicUI.onTouchChange = function(self, is_touch)
	self.layer:setTouchEnabled(is_touch)
end

collectNewRelicUI.initRelics = function(self)
	local relicHandel = getGameData():getRelicData()
	local dx = 0.2
	local scaleX = 1 / self.mapScaleX
	local scaleY = 1 / self.mapScaleY
	self.org_scale_n = scaleX
	self.images = {}
	for i, relic in ipairs(self.can_check_relics) do
		local relicInfo = relic.relicInfo
		local coord = ccp(relicInfo.coord[1], relicInfo.coord[2])
		local sprite = nil
		if false == getGameData():getCollectData():getRelicIsFinish(relic.id) then
			sprite = display.newSprite("#relic_lock.png")
			sprite:addChild(display.newSprite("#relic_event_open.png", 0, 25))
		else
			sprite = display.newSprite("#relic_open.png")
		end
		local size = sprite:getContentSize()
		self.images[#self.images + 1] = sprite
		sprite:setScaleX(scaleX)
		sprite:setScaleY(scaleY)
		local pos = self:cocosToTile2(coord)
		sprite:setPosition(ccp(pos.x, pos.y))
		if relicHandel:isSuddenlyEventByID(relic.id) then
			local eventSprite = display.newSprite("#relic_event_open.png")
			eventSprite:setPosition(ccp(pos.x - size.width - 20, pos.y + size.height + 30))
			eventSprite.pos = pos
			eventSprite:setScaleX(scaleX)
			eventSprite:setScaleY(scaleY)
			self.map:addChild(eventSprite, ZEODERBASE + 11)
			self.eventSprites[#self.eventSprites + 1] = eventSprite
		end
		self.map:addChild(sprite, ZEODERBASE + 10)
	end
end

collectNewRelicUI.setSpriteScale = function(self, scale)
	for i = 1, #self.images do
		local sp = self.images[i]
		if not tolua.isnull(sp) then
			sp:setScaleX(scale)
			sp:setScaleY(scale)
		end
	end
	for i = 1, #self.eventSprites do
		local sp = self.eventSprites[i]
		if not tolua.isnull(sp) then
			sp:setScaleX(scale)
			sp:setScaleY(scale)
		end
	end
end

collectNewRelicUI.createRelicName = function(self)
	local dx = 0.2
	local scaleX = 1 / self.mapScaleX
	local scaleY = 1 / self.mapScaleY
	self.names = {}
	for i, relic in ipairs(self.can_check_relics) do
		local relicInfo = relic.relicInfo
		local coord = ccp(relicInfo.coord[1], relicInfo.coord[2])
		local pos = self:cocosToTile2(coord)
		local nameLable = createBMFont({text = relicInfo.name, fontFile = FONT_CFG_1, size = 18, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
		nameLable:setPosition(ccp(pos.x, pos.y - 25))
		self.names[#self.names + 1] = nameLable
		self.map:addChild(nameLable, ZEODERBASE + 10)
	end
end

collectNewRelicUI.initCommonUI = function(self)
	UiCommon:createSecondUiTitle(self, UI_WORD.BOAT_RELIC_VIEW_TITLE, nil, nil,nil,20)
	if self.isClose == nil then
		local closeButton = MyMenuItem.new({sound = music_info.COMMON_CLOSE.res,image ="#common_btn_close1.png",
		x = FULL_SCREEN_CLOSEBTN_POS.x,
		y = FULL_SCREEN_CLOSEBTN_POS.y})

		closeButton:regCallBack( function()
			self:close()
		end)
		self.closeMenu = MyMenu.new({closeButton})
		self:addChild(self.closeMenu, ZEODERBASE)
		local now_num_n = #self.can_check_relics
		local relic_desc_lab = createBMFont({text = string.format(UI_WORD.RELIC_ALL_GET_TIPS, now_num_n, #relic_info), align = kCCTextAlignmentLeft, fontFile = FONT_CFG_1, size = 18,
			color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 10, y = FULL_SCREEN_CLOSEBTN_POS.y})
		relic_desc_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
		self:addChild(relic_desc_lab, ZEODERBASE)
	end
end

collectNewRelicUI.initEvent = function(self)
	self.layer.onTouchBegan = function(x, y, isMutilTouchMode) self:onTouchBegan(x, y, isMutilTouchMode) end
	self.layer.onTouchMoved = function(x, y, isMutilTouchMode) self:onTouchMoved(x, y, isMutilTouchMode) end
	self.layer.onTouchEnded = function(x, y, isMutilTouchMode) self:onTouchEnded(x, y, isMutilTouchMode) end
	self.layer.onMutilTouchMoved = function(curPos, lastPos) self:onMutilTouchMoved(curPos, lastPos) end
	mult_touch:initTouchLayer(self.layer)
end

collectNewRelicUI.setSpriteVisible = function(self, isVisible)
	 for i = 1, #self.images do
		local sp = self.images[i]
		if not tolua.isnull(sp) then
			sp:setVisible(isVisible)
		end
	end
	for i = 1, #self.eventSprites do
		local sp = self.eventSprites[i]
		if not tolua.isnull(sp) then
			sp:setVisible(isVisible)
		end
	end
	for i = 1, #self.names do
		local name = self.names[i]
		if not tolua.isnull(name) then
			name:setVisible(isVisible)
		end
	end
	self.closeMenu:setVisible(isVisible)
end

-------------触摸事件---------------
collectNewRelicUI.onTouchBegan = function(self, x, y, isMutilTouchMode)
	self.touchBeginPoint= nil
	self.touchLastPoint = nil
	self.touchSecondPoint = nil

	if isMutilTouchMode then --多点触摸
		return true
	end

	self.touchBeginPoint= {x = x, y = y}

	return true
end

collectNewRelicUI.onTouchMoved = function(self, x, y, isMutilTouchMode)
	local scaleX = self.layer:getScaleX()
	local scaleY = self.layer:getScaleY()
	if self.scaleMinX < scaleX and self.scaleMinY < scaleY then
		local cx, cy = self.layer:getPosition()
		local curWidth = self.map_width * scaleX
		local curHeight = self.map_height * scaleY

		if self.touchLastPoint then
			local curX = cx
			local curY = cy

			curX = cx + x - self.touchLastPoint.x
			curY = cy + y - self.touchLastPoint.y

			if curX < display.width - curWidth then
				curX = display.width - curWidth
			elseif curX > 0 then
				curX = 0
			end
			if curY < display.height - curHeight then
				curY = display.height - curHeight
			elseif curY > 0 then
				curY = 0
			end
			self.layer:setPosition(curX, curY)
		end
		self.touchSecondPoint = self.touchLastPoint
		self.touchLastPoint = {x = x, y = y}
	end
end

collectNewRelicUI.onMutilTouchMoved = function(self, curPos, lastPos) -- 多点触摸移动
	self.touchLastPoint = nil
	self.touchSecondPoint = nil
	if nil == self.multiTouchFirstPoint then
		self.multiTouchFirstPoint = lastPos
		self.multiTouchFirstPoint.x = (self.multiTouchFirstPoint.x + curPos.x)/2
		self.multiTouchFirstPoint.y = (self.multiTouchFirstPoint.y + curPos.y)/2
	end
	local rate = curPos.dis/lastPos.dis
	local scale_x = rate*self.layer:getScaleX()
	local scale_y = rate*self.layer:getScaleY()
	if scale_x < self.scaleMinX then
		scale_x = self.scaleMinX
	end
	if scale_y < self.scaleMinY then
		scale_y = self.scaleMinY
	end
	if scale_x > self.scaleMax then
		scale_x = self.scaleMax
		scale_y = self.scaleMinY * (1/self.scaleMinX)
	end
	self:touchScaleMap(ccp((curPos.x + lastPos.x)/2, (curPos.y + lastPos.y)/2), scale_x, scale_y)
end

collectNewRelicUI.onTouchEnded = function(self, x, y, isMutilTouchMode)
	if isMutilTouchMode then--多点
		self.touchLastPoint = nil
		self.touchSecondPoint = nil
		self.multiTouchFirstPoint = nil
		return
	end
	local cx, cy = self.layer:getPosition()
	local scaleX = self.layer:getScaleX()
	local scaleY = self.layer:getScaleY()
	local curWidth = self.map_width * scaleX
	local curHeight = self.map_height * scaleY
	if self.touchBeginPoint and math.abs(self.touchBeginPoint.x - x) < OFF_CENTER and math.abs(self.touchBeginPoint.y - y) < OFF_CENTER then  --点击响应
		local relicId = self:isRelicPos(ccp(x,y))
		if  relicId then
			self:showRelicInfoView(relicId)
		else
			if device.platform == "windows" then
				self.scale_ff = self.scale_ff or 0.8
				self:touchScaleMap(ccp(x, y), self.scale_ff, self.scale_ff)
			end
		end
	elseif self.touchSecondPoint then -- 拖动惯性
		local dx = (self.touchLastPoint.x - self.touchSecondPoint.x)
		local dy = (self.touchLastPoint.y - self.touchSecondPoint.y)
		local curX = cx + dx * 3
		local curY = cy + dy * 3
		if curX < display.width - curWidth then
			curX = display.width - curWidth
		elseif curX > 0 then
			curX = 0
		end
		if curY < display.height - curHeight then
			curY = display.height - curHeight
		elseif curY > 0 then
			curY = 0
		end
		self.layer:setPosition(ccp(curX, curY))
	end
	self.touchLastPoint = nil
	self.touchBeginPoint = nil
	self.touchSecondPoint = nil
end

collectNewRelicUI.isRelicPos = function(self, pos)
	local pos = self.map:convertToNodeSpace(pos)
	local p = self:tileToCocos(pos)
	local relicHandel = getGameData():getRelicData()
	local relicId = relicHandel:isEditRelicPos(p)
	return relicId
end

collectNewRelicUI.showRelicInfoView = function(self, relicId)
	local relicData = nil
	local collectData = getGameData():getCollectData()
	for i, relic in ipairs(self.can_check_relics) do
		local relicInfo = relic.relicInfo
		if relic.id == relicId then
			relicData = relic
			break
		end
	end
	if relicData == nil then
		return
	end
	self:setSpriteVisible(false)
	--防止重复包含
	getUIManager():create("gameobj/relic/RelicDiscoverUI", nil, relicData, function() 
		getUIManager():close("ClsRelicDiscoverUI")
		self:setSpriteVisible(true)
	end, true)
end

collectNewRelicUI.tileToCocos = function(self, position)
	local x = math.floor(position.x / self.map_tile_size)
	local y = math.floor((self.map_height - position.y) / self.map_tile_size)
	return ccp(x, y)
end

collectNewRelicUI.setSpritePos = function(self)
	for i = 1, #self.eventSprites do
		local sp = self.eventSprites[i]
		if not tolua.isnull(sp) then
			sp:setPosition(ccp(sp.pos.x - 15, sp.pos.y + 14))
		end
	end
end

--点击放大地图(现在不用点击，放弃)
collectNewRelicUI.clickMap = function(self, pos, notConvert)
	if not notConvert then
		pos = self.layer:convertToNodeSpace(pos)
	end
	local curX = display.width / 2 - pos.x * self.scaleMax
	local curY = display.height / 2 - pos.y * self.scaleMax
	--调整边界位置
	if curX < display.width - self.map_width * self.scaleMax then
		curX = display.width - self.map_width * self.scaleMax
	elseif curX > 0 then
		curX = 0
	end
	if curY < display.height - self.map_height * self.scaleMax then
		curY = display.height - self.map_height * self.scaleMax
	elseif curY > 0 then
		curY = 0
	end

	local action1 = CCScaleTo:create(0.1, self.scaleMax, self.scaleMax)
	local action2 = CCMoveTo:create(0.1, ccp(curX, curY))
	local callBack
	callBack = function()
		self:setSpriteScale(1)
		self:createRelicName()
		self:setSpritePos()
		self.isCilckMap = false
	end
	self:setSpriteScale(1)
	local actions = CCArray:create()

	local spawn = CCSpawn:createWithTwoActions(action1, action2)
	actions:addObject(spawn)

	local funcCallBack = CCCallFunc:create(callBack)
	actions:addObject(funcCallBack)

	local action = CCSequence:create(actions)
	self.layer:runAction(action)
end

--双指缩放时调用的回调
collectNewRelicUI.touchScaleMap = function(self, pos, scale_x, scale_y)
	pos = self.layer:convertToNodeSpace(pos)
	local org_scale_x = self.layer:getScaleX()
	local org_scale_y = self.layer:getScaleY()

	--如果没有多少的变化则返回
	local org_pos_x, org_pos_y = self.layer:getPosition()
	local center_pos_x = org_pos_x + pos.x * org_scale_x
	local center_pos_y = org_pos_y + pos.y * org_scale_y

	local cur_x = center_pos_x - pos.x * scale_x
	local cur_y = center_pos_y - pos.y * scale_y
	--调整边界位置
	if cur_x < (display.width - self.map_width * scale_x) then
		cur_x = display.width - self.map_width * scale_x
	elseif cur_x > 0 then
		cur_x = 0
	end
	if cur_y < (display.height - self.map_height * scale_y) then
		cur_y =  display.height - self.map_height * scale_y
	elseif cur_y > 0 then
		cur_y = 0
	end

	self.layer:setPosition(cur_x, cur_y)
	self.layer:setScaleX(scale_x)
	self.layer:setScaleY(scale_y)

	local is_show_name = false
	if (scale_x/self.scaleMinX) > 1.8 then
		is_show_name = true
	end

	if is_show_name and (not self.m_is_create_name_b) then
		self:createRelicName()
		self.m_is_create_name_b = true
	end

	local tips_scale_n =  self.mapScaleX / scale_x * self.org_scale_n
	self:setSpriteScale(tips_scale_n)

	if self.m_is_create_name_b then
		for i = 1, #self.names do
			local name = self.names[i]
			if not tolua.isnull(name) then
				name:setVisible(is_show_name)
				name:setScale(tips_scale_n)
			end
		end
	end
end

collectNewRelicUI.cocosToTile2 = function(self, position)  --加了偏移量
	return ccp(position.x * self.map_tile_size + self.map_tile_size/2, self.map_height-position.y*self.map_tile_size-self.map_tile_size/2)
end

local _parentLayer = nil
local _callBack = nil
local _callBackOne = nil
local fromCaptain = nil
setRelicUIParentLayer = function(layer, from)
	_parentLayer = layer
	if from then
		fromCaptain = from
	end
end

eventRelic = function()
	local relicHandel = getGameData():getRelicData()
	local relics = nil
	if typeCollection.type == typeCollection.TYPE_SELF then
		relics = relicHandel:getOpenRelics()
	else
		relics = relicHandel:getCurrentVisitFriendInfo()
	end
	if relics == nil or (relics and #relics == 0) then
		local str = nil
		if typeCollection.type == typeCollection.TYPE_SELF then
		   str = tips[128].msg
		else
		   str = tips[125].msg
		end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		Alert:warning({msg = str})
		return
	end
	if fromCaptain then
		-- 打开收藏室遗迹界面
		getUIManager():create('gameobj/relic/collectNewRelicUI')
	else
		_callBack()
		audioExt.playEffect(music_info.UI_GLOBE.res)
		local earthkEffect = CompositeEffect.new("tx_3005", 482, 270, _parentLayer, 0.5, function()
			-- 打开收藏室遗迹界面
			getUIManager():create('gameobj/relic/collectNewRelicUI')
		end,nil,nil,true)
		earthkEffect:setZOrder(order.EFFECT)
	end
	UnRegTrigger(EVENT_FRIEND_RELIC_INFO)
end

createRelicUI = function(player_uid,callBack,callBackOne)
	player_id = player_uid
	_callBack = callBack
	_callBackOne = callBackOne

	local playerData = getGameData():getPlayerData()
	local myUid = playerData:getUid()
	local collectData = getGameData():getCollectData()
	if player_uid == myUid then
		typeCollection.type = typeCollection.TYPE_SELF
		eventRelic()
	else
		typeCollection.type = typeCollection.TYPE_FRIEND
		RegTrigger(EVENT_FRIEND_RELIC_INFO, eventRelic)
		collectData:askForRelicData(player_uid)
	end
end

return collectNewRelicUI
