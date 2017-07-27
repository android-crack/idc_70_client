--以下这些值，依据不同的地图来定义，在初始化时赋值
local TILE_SIZE = 64
local TILE_HEIGHT = 960
local TILE_WIDTH  = 1695
local LAND_HEIGHT = TILE_SIZE * TILE_HEIGHT
local LAND_WIDTH  = TILE_SIZE * TILE_WIDTH
local EDGE_SIZE   = TILE_SIZE * 2   -- 扩大外围一圈
local DRAW_WIDTH  = display.width + EDGE_SIZE*2  -- 绘制宽
local DRAW_HEIGHT = display.height + EDGE_SIZE*2  -- 绘制高

local ClsAstar = require("gameobj/explore/qAstar")
local ClsModCommonBase = require("gameobj/commonFuns")

local ClsExploreBaseLand = class("BaseLand", function() return CCLayer:create() end)

function ClsExploreBaseLand:ctor(param)
	self.map_res = param.map_res
	self.bit_res = param.bit_res
	self.parent = param.parent
	self.is_map_block = param.block
	self:initMapInfo(param)
	self.ship = param.parent.player_ship
	self:createLand()
	self:regFuns()
end

function ClsExploreBaseLand:regFuns()

end

function ClsExploreBaseLand:initMapInfo(param)
	TILE_HEIGHT = param.map_height
	TILE_WIDTH  = param.map_width
	LAND_HEIGHT = TILE_SIZE * TILE_HEIGHT
	LAND_WIDTH  = TILE_SIZE * TILE_WIDTH
	EDGE_SIZE   = TILE_SIZE * 2   -- 扩大外围一圈
	DRAW_WIDTH  = display.width + EDGE_SIZE * 2  -- 绘制宽
	DRAW_HEIGHT = display.height + EDGE_SIZE * 2  -- 绘制高
end

function ClsExploreBaseLand:createLand()
	-- todo --explorer/map/land/land.tmx --self.map_res 地图的路径
	self.land = QTZTMXTiledMapBlock:create(self.map_res)
	self.land:setAntiAliasTexParameters(true)  --抗锯齿
	self.AStar = ClsAstar.new()
	self.AStar:initByBit(self.bit_res, TILE_WIDTH, TILE_HEIGHT)
	self:initLandField()
	self:addChild(self.land)
end

function ClsExploreBaseLand:initLandField()
	local x, y = self.ship:getPos()
	self.last_px, self.last_py = -x, -y
	self.start_x = x - EDGE_SIZE  --  扩大外围一圈
	self.start_y = y - EDGE_SIZE

	self.land:UpdateBlock(CCRect(self.start_x - display.cx, self.start_y - display.cy, DRAW_WIDTH , DRAW_HEIGHT))
end

function ClsExploreBaseLand:isUpdate(px, py)
	-- 避免每帧调用
	if Math.abs(px - self.last_px) > TILE_SIZE or Math.abs(py - self.last_py) > TILE_SIZE then
		self.start_x = self.start_x - (px - self.last_px)
		self.start_y = self.start_y - (py - self.last_py)
		self.land:UpdateBlock(CCRect(self.start_x, self.start_y, DRAW_WIDTH, DRAW_HEIGHT))
		self.last_px = px
		self.last_py = py
		return true
	else
		return false
	end
end

function ClsExploreBaseLand:eachBolckUpdate(dt) --

end


function ClsExploreBaseLand:update(dt)
	-- 避免每帧调用
	--self:updateBegin()
	local cam = self.parent:getCamera()
	local x, y, z = cam:getEyeXYZ(0,0,0)
	if self:isUpdate(-x, -y) then
		--先把他加回来，保证有更新先
		self:eachBolckUpdate(dt)
	end
end

------从Tilemap坐标转换为cocos2d-x坐标
function ClsExploreBaseLand:cocosToTile(position)
	return ccp(position.x*TILE_SIZE, LAND_HEIGHT-position.y*TILE_SIZE)
end

--加了偏移量
function ClsExploreBaseLand:cocosToTile2(position)
	return ccp(position.x*TILE_SIZE+TILE_SIZE/2, LAND_HEIGHT-position.y*TILE_SIZE-TILE_SIZE/2)
end

-------从cocos2d-x坐标转换为Tilemap坐标
function ClsExploreBaseLand:tileToCocos(position)
	local x = Math.floor(position.x/TILE_SIZE)
	local y = Math.floor((LAND_HEIGHT - position.y)/TILE_SIZE)
	return ccp(x, y)
end

--地图大小的常量
function ClsExploreBaseLand:getTitleHeight()
	return  TILE_HEIGHT
end

function ClsExploreBaseLand:getTitleWidth()
	return  TILE_WIDTH
end

function ClsExploreBaseLand:getTitleSize()
	return  TILE_SIZE
end

--地图大小的常量
function ClsExploreBaseLand:getLandHeight()
	return  LAND_HEIGHT
end

function ClsExploreBaseLand:getLandWidth()
	return  LAND_WIDTH
end

------------------------- 检测 -----------------------
 --检测是否合法的坐标
function ClsExploreBaseLand:checkPoint(pos)
	if pos.x >=0 and pos.x < LAND_WIDTH and pos.y >= 0 and pos.y < LAND_HEIGHT then
		return true
	end
	return false
end

 --检测是x合法的坐标
function ClsExploreBaseLand:checkPosXCollision(pos)
	if pos.x >= 0 and pos.x < LAND_WIDTH then
		return true
	end
	return false
end

--检测是Y合法的坐标
function ClsExploreBaseLand:checkPosYCollision(pos)
	if pos.y >= 0 and pos.y < LAND_HEIGHT then
		return true
	end
	return false
end

-- 检测碰撞 ：true 不能通过， false 能通过
function ClsExploreBaseLand:checkHit(pos, d_pos)
	--todo 一定要继承
	local pos = self.land:convertToNodeSpace(pos)
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	pos.x = pos.x + ex
	pos.y = pos.y + ey

	local p = self:tileToCocos(pos)
	assert(self.AStar ~= nil, "AStart Is Null")
	local blockWeight = self.AStar:getWeight(p.x, p.y)
	if blockWeight == MAP_LAND then  -- 陆地
		pos.x = pos.x + d_pos.x
		pos.y = pos.y + d_pos.y
		if not self:checkPoint(pos) then -- 边缘
			return true
		end
		local p = self:tileToCocos(pos)
		if self.AStar:getWeight(p.x, p.y) == MAP_LAND then
			return true
		end
	end
	return false
end

function ClsExploreBaseLand:convertToCameraPos(pos)
	local pos = self.land:convertToNodeSpace(pos)
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	pos.x = pos.x + ex
	pos.y = pos.y + ey

	return pos
end

-- true 不能通过， false 能通过
function ClsExploreBaseLand:checkHitPosX(pos, d_pos)
	--todo 一定要继承
	local hit_pos = self:convertToCameraPos(pos)
	if not self:checkPosXCollision(hit_pos) then --X 边缘
		return true
	end
	return false
end

--true 不能通过， false 能通过
function ClsExploreBaseLand:checkHitPosY(pos, d_pos)
	--todo 一定要继承
	local hit_pos = self:convertToCameraPos(pos)

	if not self:checkPosYCollision(hit_pos) then -- Y边缘
		return true
	end
	return false
end

function ClsExploreBaseLand:checkCollisionPos(pos)
	local hit_pos = self:convertToCameraPos(pos)

	local dy = display.cy
	local dx = display.cx
	local coll_pos = nil
	if (hit_pos.y < dy) and hit_pos.x < dx  then --左下角
		coll_pos = ccp(dx, dy)
	elseif hit_pos.x < dx and hit_pos.y > (self:getLandHeight() - dy) then --左上角
		coll_pos = ccp(dx, self:getLandHeight() - dy)
	elseif hit_pos.x > (self:getLandWidth() - dx) and hit_pos.y < dy then --右下角
		coll_pos = ccp(self:getLandWidth() - dx, dy)
	elseif hit_pos.x > (self:getLandWidth() - dx) and hit_pos.y > (self:getLandHeight() - dy) then --右上角
		coll_pos = ccp(self:getLandWidth() - dx, self:getLandHeight() - dy)
	end
	return coll_pos
end

function ClsExploreBaseLand:keyPosMoveToPos()  
	--todo 不同地图的寻路关键点不同，在配置表中
	--子类要实现
end

-- 自动跑到某个点
-- goal_pos目标点坐标（已经是land的坐标，无需转） --这个要根据关键点寻路
function ClsExploreBaseLand:moveToPos(goal_pos, call_back, param, searchPathStartCall, searchPathEndCall)  
	local p = ccp(self.ship:getPos())
	local pos_st = self:tileToCocos(p) -- 开始坐标
	local pos_end = goal_pos           -- 目标点
	if searchPathStartCall and type(searchPathStartCall) == "function" then
		searchPathStartCall()
	end
	-- wmh todo 要去掉兼容
	local path = self.AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1) or {}  --路径
	if searchPathEndCall and type(searchPathEndCall) == "function" then
		searchPathEndCall()
	end
	local path_len = #path
	local index = 3

	local auto
	auto = function()
		if index > path_len then
			if call_back then
				call_back(param)
			else
				self:breakAuto()
			end
			return
		end
		local x = path[index]
		local y = path[index + 1]
		index = index + 2
		local pos = self:cocosToTile2(ccp(x, y))
		self:autoMoveToNext(pos, auto)
	end
	auto()
end

function ClsExploreBaseLand:getSearchPath(pos_st, pos_end)
	local path = self.AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1)
	return path
end

--===============================================================
-- 自动跑到下个点
function ClsExploreBaseLand:autoMoveToNext(next_pos, call_back)
	local pos = next_pos  -- 目标点
	local ver = cocosToGameplayWorld(pos)
	self.ship:setNextTranslation(ver)
	local boat_pos = self.ship.node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(ver, boat_pos, dir)
	LookForward(self.ship.node, dir)
	local lastx, lasty = self.ship:getPos()

	local function isArrive()
		local tx, ty = self.ship:getPos()
		local cur_dis = Math.distance(pos.x, pos.y, tx, ty)
		local last_dis = Math.distance(lastx, lasty, tx, ty)
		lastx, lasty = tx, ty

		if cur_dis < last_dis then
			local scheduler = CCDirector:sharedDirector():getScheduler()
			scheduler:unscheduleScriptEntry(self.hander_time)
			self.hander_time = nil
			call_back()
		end
	end

	if not self.hander_time then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		self.hander_time = scheduler:scheduleScriptFunc(isArrive, 0, false)
	end
end


function ClsExploreBaseLand:autoAfterUpdateUI(is_break)  --子类继承这个函数去更新界面

end

function ClsExploreBaseLand:autoAfterRemoveResource() 

end

--中断导航
function ClsExploreBaseLand:breakAuto(is_break) 
	IS_AUTO = false  -- 是否自动导航
	self.ship:rotateStop()
	self:autoAfterUpdateUI(is_break) --更新ui界面
	if self.hander_time then
		self:autoAfterRemoveResource()
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.hander_time) 
		self.hander_time = nil	
	end
end

-- 检测此点是否在海面上/港口
function ClsExploreBaseLand:checkPos(x, y, is_world) --这个要在子类重写
	if not is_world then
		local cam = self.parent:getCamera()
		local ex, ey, ez = cam:getEyeXYZ(0,0,0)
		x = x + ex
		y = y + ey
	end
	local pos = self.land:convertToNodeSpace(ccp(x, y))  --把世界坐标转当前坐标系
	local blockWeight = nil
	local p = nil
	if not self:checkPoint(pos) then -- 边缘
		blockWeight = MAP_SEA
	else
		p = self:tileToCocos(pos)
		blockWeight = self.AStar:getWeight(p.x, p.y)
	end
	return blockWeight, p
end

function ClsExploreBaseLand:getPosInLand(x, y)
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	x = x + ex
	y = y + ey
	local pos = self.land:convertToNodeSpace(ccp(x, y))  --把世界坐标转当前坐标系
	return pos.x, pos.y
end

function ClsExploreBaseLand:getLandPosInScreen(x, y)
	local pos = self.land:convertToWorldSpace(ccp(x, y)) 
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	pos.x = pos.x - ex
	pos.y = pos.y - ey
	return pos.x, pos.y
end

function ClsExploreBaseLand:remove2dResource()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end

	self.AStar = nil
	self.land = nil
end

function ClsExploreBaseLand:createEffectLabel(text_str, pos_x, pos_y, add_word_str)
	local str_len = ClsModCommonBase:utfstrlen(text_str)
	local word_ui_tab = {}
	local word_color = COLOR_YELLOW
	local word_x = 0
	local word_size_n = 20
	pos_x = pos_x or 0
	pos_y = pos_y or 0
	local words_total_spr = display.newSprite()
	words_total_spr:setPosition(pos_x, pos_y)
	local words_spr = display.newSprite()
	words_total_spr:addChild(words_spr)
	for i = 1, str_len do
		local word = ClsModCommonBase:utf8sub(text_str, i, 1)
		local word_lab = createBMFont({text = word ,fontFile = FONT_CFG_1, size = word_size_n,color = ccc3(dexToColor3B(word_color)), x = word_x, y = 0})
		word_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
		words_spr:addChild(word_lab)
		word_x = word_x + word_lab:getContentSize().width
		word_ui_tab[i] = word_lab
	end
	if add_word_str then
		local add_word_lab = createBMFont({text = add_word_str ,fontFile = FONT_CFG_1, size = word_size_n,color = ccc3(dexToColor3B(word_color)), x = word_x, y = 0})
		add_word_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
		words_spr:addChild(add_word_lab)
		word_x = word_x + add_word_lab:getContentSize().width
	end
	words_spr:setPosition(-1*word_x/2, 0)
	
	local word_eff_time_n = 0.2
	local word_eff_up_time_n = 0.15
	local len = #word_ui_tab
	local array = CCArray:create()
	for i = 1, len do
		local index_n = i
		array:addObject(CCCallFunc:create(function() 
				local word_lab = word_ui_tab[index_n]
				local x = word_lab:getPositionX()
				local move_arr = CCArray:create()
				move_arr:addObject(CCEaseSineInOut:create(CCMoveTo:create(word_eff_time_n/2, ccp(x, 12))))
				move_arr:addObject(CCEaseBackOut:create(CCMoveTo:create(word_eff_time_n/2, ccp(x, 0))))
				word_lab:runAction(CCSequence:create(move_arr))
			end))
		array:addObject(CCDelayTime:create(word_eff_time_n))
	end
	array:addObject(CCDelayTime:create(1))
	words_spr:runAction(CCRepeatForever:create(CCSequence:create(array)))
	
	return words_total_spr
end

return ClsExploreBaseLand
