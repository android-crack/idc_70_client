---- 副本陆地
local math_abs = math.abs
local commonBase  = require("gameobj/commonFuns")
local UI_WORD = require("game_config/ui_word")
local tips = require("game_config/tips")
local on_off_info=require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsAstar = require("gameobj/explore/qAstar")
local ClsModCommonBase = require("gameobj/commonFuns")

local ClsBaseLand = require("gameobj/explore/baseLand")

local TIPS_POS = ccp(display.cx, 0.9 * display.cy)


local ClsCopySceneLand = class("ClsCopySceneLand", function() return CCLayer:create() end)

function ClsCopySceneLand:ctor(param)
	self.tile_size = MAP_TILE_SIZE --一块地图的像素点
	self.bit_res = param.bit_res 
	self.map_res = param.map_res --地图资源
	self.tile_height = param.tile_height --地图高度，格子数目
	self.tile_width = param.tile_width -- 地图宽度，格子数目
	self.block_width_count = param.block_width_count --地图宽度遮挡
	self.block_height_count = param.block_height_count --地图高度挡住
	self.block_count = {}
	self.block_count.up = param.block_up_count 
	self.block_count.down = param.block_down_count 
	self.block_count.left = param.block_left_count 
	self.block_count.right = param.block_right_count 
	self.land_width = self.tile_width * self.tile_size --地图的总宽度，像素单位
	self.land_height = self.tile_height * self.tile_size --地图的总高度，像素单位
	self.edge_size =  self.tile_size * 2
	self.draw_width = display.width + self.edge_size * 2 -- 绘制宽
	self.draw_height = display.height + self.edge_size * 2 -- 绘制

	self:createLand()
	self:registerScriptHandler(function(event)
		if event == "enter" then
			self:onEnter()
		elseif event == "exit" then
			self:onExit()
		end
	end)
end

function ClsCopySceneLand:initLandField(parent) --这个在外部调用，避免，在创建地图的时候杂乱
	self.parent = self.parent or parent
	self.ship = self.parent:getPlayerShip()
	local x, y = self.ship:getPos()
	
	self.last_px, self.last_py = -x, -y
	self.start_x = x - self:getEdgeSizeWidth()  --  扩大外围一圈
	self.start_y = y - self:getEdgeSizeWidth()
	self.land:UpdateBlock(CCRect(self.start_x - display.cx, self.start_y - display.cy, self:getDrawWidth() , self:getDrawHeight()))
end

function ClsCopySceneLand:createLand()
	self.land = QTZTMXTiledMapBlock:create(self.map_res)
	self.land:setAntiAliasTexParameters(true)  --抗锯齿
	self.AStar = ClsAstar.new()
	self.AStar:initByBit(self.bit_res, self:getTileWidth() , self:getTileHeight())
	if self.block_count.left > 0 then
		self.AStar:fixMap(0,0, self.block_count.left, self.tile_height, MAP_LAND)
	end
	if self.block_count.up > 0 then
		self.AStar:fixMap(0,0, self.tile_width, self.block_count.up, MAP_LAND)
	end
	if self.block_count.right > 0 then
		self.AStar:fixMap(self.tile_width - self.block_count.right, 0, self.block_count.right, self.tile_height, MAP_LAND)
	end
	if self.block_count.down > 0 then
		self.AStar:fixMap(0, self.tile_height - self.block_count.down, self.tile_width, self.block_count.down, MAP_LAND)
	end
	self:addChild(self.land)
end

function ClsCopySceneLand:setLockWallConfig(wall_config_name)
	self.copy_wall_angle = 0
	self.line_res = "explorer/map/land/area_piece_wall3.png"
	self.copy_wall_config = require("game_config/copyScene/" .. wall_config_name)
	if "copy_treasure_wall_config" == wall_config_name then
		self.copy_wall_angle = 270
		self.line_res = "explorer/map/land/area_piece_wall4.png"
	elseif "copy_port_battle_wall_config" == wall_config_name then
		self.copy_wall_angle = 90
		self.line_res = "explorer/map/land/area_piece_wall2.png"
	end
end

--设置阻挡墙
function ClsCopySceneLand:setIsShowLockWall(is_show_b)
	if not is_show_b then
		if self.lock_wall_batchnode then
			if self.lock_wall_batchnode.lock_before_bit_tab then
				--取消原来不可点的区域
				for k, v in ipairs(self.lock_wall_batchnode.lock_before_bit_tab) do
					self.AStar:fixMap(v.width, v.height, 1, 1, v.before_block)
				end
			end
			self.lock_wall_batchnode:removeFromParentAndCleanup(true)
			self.lock_wall_batchnode = nil
		end
		return
	end
	if self.AStar then
		if not tolua.isnull(self.lock_wall_batchnode) then return end
		
		local wall_batchnode = display.newBatchNode(self.line_res)
		self:addChild(wall_batchnode)
		self.lock_wall_batchnode = wall_batchnode
		
		local lock_before_bit_tab = {}
		
		--填上空缺端，防止船卡下就漏出来
		if self.copy_wall_config[1] then
			local map_width = self.copy_wall_config[1].width
			local map_height = self.copy_wall_config[1].height
			for i = 1, 2 do
				for j = -1, 1 do
					local block_n = self.AStar:getWeight(map_width + j, map_height - i)
					lock_before_bit_tab[#lock_before_bit_tab + 1] = {["width"] = map_width + j, ["height"] = map_height - i, ["before_block"] = block_n}
				end
			end
		end
		
		for k, v in ipairs(self.copy_wall_config) do
			local line_spr = display.newSprite(self.line_res)
			local map_width = v.width
			local map_height = v.height
			local co_pos = self:tileSizeToCocos(ccp(map_width, map_height))
			line_spr:setPosition(co_pos.x, co_pos.y)
			line_spr:runAction(CCRotateTo:create(0, self.copy_wall_angle))
			wall_batchnode:addChild(line_spr)
			for i = -1, 1 do
				local block_n = self.AStar:getWeight(map_width + i, map_height)
				lock_before_bit_tab[#lock_before_bit_tab + 1] = {["width"] = map_width + i, ["height"] = map_height, ["before_block"] = block_n}
			end
		end

		--开闸锁住先
		for k, v in ipairs(lock_before_bit_tab) do
			self.AStar:fixMap(v.width, v.height, 1, 1, MAP_LAND)
		end
		self.lock_wall_batchnode.lock_before_bit_tab = lock_before_bit_tab
	end
end

function ClsCopySceneLand:addToEffectLayer(node)
	local effect_layer = getUIManager():get("ClsCopyEffectLayer")
	if not tolua.isnull(effect_layer) then
		effect_layer:getAutoTipsLayer():addChild(node)
	end
end

function ClsCopySceneLand:showDropAnchorTips(isCancle, isTreasure) --抛锚中字体
	local tipStr = tips[63].msg
	if tolua.isnull(self.dropShowLable) then
		self.dropShowLable = createBMFont({text = tipStr, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),fontFile = FONT_CFG_1, size = 16, x = TIPS_POS.x, y = TIPS_POS.y})
		self:addToEffectLayer(self.dropShowLable)
	else
		self.dropShowLable:setString(tipStr)
	end
	self.dropShowLable:setVisible(false)
	if isCancle then
		if not tolua.isnull(self.dropShowLable) then
			self.dropShowLable:setVisible(false)
		end
	else
		if not tolua.isnull(self.dropShowLable) then
			self.dropShowLable:setVisible(true)
		end
	end
end

function ClsCopySceneLand:getTileHeight() --高度格子数目
	return  self.tile_height
end

function ClsCopySceneLand:getTileWidth() --宽度格子数目
	return  self.tile_width
end

function ClsCopySceneLand:getTitleSize() --格子大小
	return  self.tile_size
end

function ClsCopySceneLand:getBlockWidth()
	return self.block_width_count*self.tile_width
end

function ClsCopySceneLand:getBlockHeight()
	return self.block_height_count*self.tile_height
end

function ClsCopySceneLand:getLandHeight() --高度，像素单位
	return  self.land_height
end

function ClsCopySceneLand:getLandWidth() --宽度，像素单位
	return  self.land_width
end

function ClsCopySceneLand:getDrawHeight() --绘制高度，像素单位
	return  self.draw_height
end

function ClsCopySceneLand:getDrawWidth() --绘制宽度，像素单位
	return  self.draw_width
end

function ClsCopySceneLand:getEdgeSizeWidth() --扩大边缘
	return  self.edge_size
end

function ClsCopySceneLand:isUpdate(px, py)
	if math_abs(px - self.last_px) > self:getTitleSize() or math_abs(py - self.last_py) > self:getTitleSize() then
		self.start_x = self.start_x - (px - self.last_px)
		self.start_y = self.start_y - (py - self.last_py)
		self.land:UpdateBlock(CCRect(self.start_x, self.start_y, self:getDrawWidth(), self:getDrawHeight()))
		self.last_px = px
		self.last_py = py
		return true
	else
		return false
	end
end

function ClsCopySceneLand:updateBegin() --这个函数要继承

end

function ClsCopySceneLand:eachBolckUpdate(dt) --

end

function ClsCopySceneLand:eachFrameUpdate(dt) --

end

function ClsCopySceneLand:update(dt)
	self:updateBegin()
	local cam = self.parent:getCamera()
	local x, y, z = cam:getEyeXYZ(0,0,0)
	local px = -x
	local py = -y
	if self:isUpdate(px, py) then
		self:eachBolckUpdate(dt)
	else
		self:eachFrameUpdate(dt)
	end
end

------从Tilemap坐标转换为cocos2d-x坐标
function ClsCopySceneLand:tileSizeToCocos(position)
	return ccp(position.x * self:getTitleSize(), self:getLandHeight() - position.y * self:getTitleSize())
end

--加了偏移量
function ClsCopySceneLand:tileSizeToCocos2(position)
	return ccp(position.x * self:getTitleSize() + self:getTitleSize() / 2, self:getLandHeight() - position.y * self:getTitleSize() - self:getTitleSize()/2)
end

-------从cocos2d-x坐标转换为Tilemap坐标
function ClsCopySceneLand:cocosToTileSize(position)
	local x = math.floor(position.x / self:getTitleSize())
	local y = math.floor((self:getLandHeight() - position.y) / self:getTitleSize())
	return ccp(x, y)
end

--这个函数兼容以前的代码，记得不要用
function ClsCopySceneLand:tileToCocos(position)
	return self:cocosToTileSize(position)
end

--这个函数兼容以前的代码，记得不要用
function ClsCopySceneLand:cocosToTile2(position)
	return self:tileSizeToCocos2(position)
end
--这个函数兼容以前的代码，记得不要用
function ClsCopySceneLand:cocosToTile(position)
	return self:tileSizeToCocos(position)
end

function ClsCopySceneLand:onEnter()
	
end

function ClsCopySceneLand:checkIsBlock(pos)
	if pos.x < self.block_count.left then
		return true
	end
	if pos.x >= (self.tile_width - self.block_count.right ) then
		return true
	end
	if pos.y < self.block_count.up then
		return true
	end
	if pos.y >= (self.tile_height - self.block_count.down ) then
		return true
	end
	return false
end

function ClsCopySceneLand:getPosInLand(x, y)
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	x = x + ex
	y = y + ey
	local pos = self.land:convertToNodeSpace(ccp(x, y))  --把世界坐标转当前坐标系
	return pos.x, pos.y
end

------------------------- 检测 -----------------------
 --检测是否合法的坐标
function ClsCopySceneLand:checkPoint(pos)
	if pos.x >=0 and pos.x < self:getLandWidth() and pos.y >= 0 and pos.y < self:getLandHeight() then
		return true
	end
	return false
end



 --检测是x合法的坐标
function ClsCopySceneLand:checkPosXCollision(pos)
	local dx = display.cx
	if pos.x >= 0 and  (pos.x > dx and pos.x < self:getLandWidth() - dx) then 
		return true
	end
	return false
end

--检测是Y合法的坐标
function ClsCopySceneLand:checkPosYCollision(pos)
	local dy = display.cy
	if pos.y >= 0 and (pos.y > dy and pos.y < self:getLandHeight() - dy ) then
		return true
	end
	return false
end

-- 检测碰撞 ：true 不能通过， false 能通过
function ClsCopySceneLand:checkHit(pos, d_pos)
	--todo 一定要继承
	local pos = self.land:convertToNodeSpace(pos)
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	pos.x = pos.x + ex
	pos.y = pos.y + ey

	if not self:checkPoint(pos) then -- 边缘
		return true
	end

	local p = self:cocosToTileSize(pos)
	assert(self.AStar ~= nil, "AStart Is Null")
	local blockWeight = self.AStar:getWeight(p.x, p.y)
	if blockWeight == MAP_LAND then  -- 陆地
		pos.x = pos.x + d_pos.x
		pos.y = pos.y + d_pos.y
		if not self:checkPoint(pos) then -- 边缘
			return true
		end
		local p = self:cocosToTileSize(pos)
		if self.AStar:getWeight(p.x, p.y) == MAP_LAND then
			return true
		end
	end
	return false
end

function ClsCopySceneLand:convertToCameraPos(pos)
	local pos = self.land:convertToNodeSpace(pos)
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	pos.x = pos.x + ex
	pos.y = pos.y + ey

	return pos
end

-- true 不能通过， false 能通过
function ClsCopySceneLand:checkHitPosX(pos, d_pos)
	--todo 一定要继承
	local hit_pos = self:convertToCameraPos(pos)
	if not self:checkPosXCollision(hit_pos) then --X 边缘
		return true
	end
	return false
end

--true 不能通过， false 能通过
function ClsCopySceneLand:checkHitPosY(pos, d_pos)
	--todo 一定要继承
	local hit_pos = self:convertToCameraPos(pos)

	if not self:checkPosYCollision(hit_pos) then -- Y边缘
		return true
	end
	return false
end

function ClsCopySceneLand:checkCollisionPos(pos)
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

function ClsCopySceneLand:checkBoundPos(pos)
	local hit_pos = self:convertToCameraPos(pos)

	local dy = display.cy
	local dx = display.cx
	local x = nil
	local y = nil
	if hit_pos.x < dx  then
		x = dx
	end
	if  hit_pos.x > (self:getLandWidth() - dx) then
		x = self:getLandWidth() - dx
	end
	if (hit_pos.y < dy) then
		y = dy
	end
	if hit_pos.y > (self:getLandHeight() - dy) then
		y = self:getLandHeight() - dy
	end
	return x, y
end

function ClsCopySceneLand:getSearchPath(pos_st, pos_end)
	local path = self.AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1)
	return path
end

function ClsCopySceneLand:breakAuto()
	if IS_AUTO then
		self.ship:stopAutoHandler()
		IS_AUTO = false
	end
end

-- 自动跑到某个点
function ClsCopySceneLand:moveToTPos(goal_tpos, call_back)  
	self:breakAuto()
	IS_AUTO = true
	self.parent:getShipsLayer():setIsWaitingTouch(false)
	local end_callback = function()
		IS_AUTO = false
		self.parent:getShipsLayer():setIsWaitingTouch(true)
		self.ship:setPause(true)
		if call_back then
			call_back()
		end
	end
	self.ship:setPause(false)
	self.ship:moveToTPos(goal_tpos.x, goal_tpos.y, false, self.tile_size, end_callback)
end

function ClsCopySceneLand:pause(is_pause)
	self.is_pause = is_pause
end

function ClsCopySceneLand:removeItem3D()
	
end

-- 检测此点是否在海面上/港口
function ClsCopySceneLand:checkPos(x, y, is_world) --这个要在子类重写
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
		p = self:cocosToTileSize(pos)
		blockWeight = self.AStar:getWeight(p.x, p.y)
	end
	return blockWeight, p
end

function ClsCopySceneLand:onExit()
	if self.hander_time then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
	self.AStar = nil
	self.land = nil
end

return ClsCopySceneLand
