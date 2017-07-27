local ClsAstar = require("gameobj/explore/qAstar")
local battle_scene_cfg = require("game_config/battle/battle_scene_cfg")

local DIRECTION_HORIZONTAL = 0
local DIRECTION_VERTICAL = 1
local DIRECTION_SLANT = 2

local function newLayer()
	return CCLayer:create()
end

local SceneCfg = class("SceneCfg", newLayer)

function SceneCfg:ctor(scene_id)
	self.scene_id = scene_id
	local cfg = battle_scene_cfg[self.scene_id]
	if type(cfg) ~= "table" then
		self.scene_id = 1
		cfg = battle_scene_cfg[self.scene_id]
	end
	
	self.width = cfg.scene_width or TILE_WIDTH
	self.height = cfg.scene_height or TILE_HEIGHT
	self.sea_cfg = cfg.sea_cfg

	local width, height = self.width * TILESIZE, self.height * TILESIZE
	
	self:setContentSize(CCSize(width, height))
	self:createTmx(cfg.tmx_map, cfg.scene_width, cfg.scene_height)
	self:createBitMap(cfg)
end

function SceneCfg:getMapSize()
	return CCSize(self.width, self.height)
end 

function SceneCfg:getTileSize()
	return CCSize(TILESIZE, TILESIZE)
end

function SceneCfg:getSeaCfg()
	return self.sea_cfg
end

function SceneCfg:createBitMap(cfg)
	if cfg.bit_map == "" then return end

	self.AStar = ClsAstar.new()
	self.AStar:initByBit(cfg.bit_map, cfg.width, cfg.height)

	if not TEST_FLG then return end

	for y = 0, cfg.height - 1 do
		for x = 0, cfg.width - 1 do
			local color, label_color, origin_color = ccc4(0,0,0,255), ccc4(255,255,255,255), ccc3(0,0,0)
			if (x + y)%2 == 0 then
				color, label_color, origin_color = ccc4(255,255,255,255), ccc4(0,0,0,255), ccc3(255,255,255)
			end
			local layer = CCLayerColor:create(color)
			layer.color = origin_color

			local pos_x = x*64
			local pos_y = self.map_height - (y + 1)*64
			layer:setPosition(ccp(pos_x, pos_y))

			local label = createBMFont({text = x.."-"..y, size = 14, color = label_color})
			label:setPosition(ccp(32, 52))
			layer:addChild(label)

			layer:setContentSize(CCSize(64, 64))
			self.land:addChild(layer, 999)

			if not self.test_layer then
				self.test_layer = {}
			end
			self.test_layer[x.."_"..y] = layer
		end
	end
end

function SceneCfg:createTmx(tmx_map)
	if not tmx_map then return end

	local res = tmx_map.res
	self.land = CCTMXTiledMap:create(res)
	self:addChild(self.land)
	self.land:setAnchorPoint(ccp(0.5, 0.5))

	local size = self:getContentSize()
	self.land:setPosition(size.width/2, size.height/2)

	self.map_width = self.land:getContentSize().width
	self.map_height = self.land:getContentSize().height
	self.map_tile_size = self.land:getTileSize().width

	local tiles_width = self.land:getMapSize().width
	local tiles_height = self.land:getMapSize().height

	self.offset_x = tiles_width - size.width/self.map_tile_size
	self.offset_y = tiles_height - size.height/self.map_tile_size

	--阻挡层
	local blockLayer = self.land:layerNamed("block")
	if blockLayer ~= nil and not tolua.isnull(blockLayer) then
		blockLayer:setVisible(false)

		local function isLand(i, j) -- 0非阻挡, 1阻挡
			if blockLayer:tileGIDAt(ccp(i, j))~= 0 then
				return 1
			end
			return 0
		end

		for y = 0, tiles_height - 1 do
			for x = 0, tiles_width - 1 do
				if not self.blockArr then
					self.blockArr = {}
				end 

				if not self.blockArr[x.."_"..y] then
					local tmp = isLand(x, y)
					self.blockArr[x.."_"..y] = tmp
				end
			end
		end
	end
end


------------------------------------------------------------------
--  战斗陆地

--检测是否合法的坐标
function SceneCfg:checkPoint(pos) 
	if pos.x >=0 and pos.x < self.map_width and pos.y >= 0 and pos.y < self.map_height then
		return true
	end 
	return false 
end 

--从cocos2d-x坐标转换为Tilemap坐标
function SceneCfg:cocosToTile(position)
	return ccp(math.floor(position.x/self.map_tile_size), math.floor((self.map_height - position.y)/self.map_tile_size))
end

--从Tilemap坐标转换为cocos2d-x坐标
function SceneCfg:tileToCocos(position)
	local x = (position.x - self.offset_x/2)*self.map_tile_size + self.map_tile_size/2
	local y = self.map_height - (position.y + self.offset_y/2)*self.map_tile_size - self.map_tile_size/2
	return ccp(x, y)
end

-- 获取某坐标上下左右四个方向的非陆地格子坐标
function SceneCfg:getCanGoPoints(pos)
	local points = {}
	if self.land and self:checkPoint(pos) then
		local function canGo(i,j)
			local tileKey = i.."_"..j
			if self.blockArr~=nil and self.blockArr[tileKey]~=nil and self.blockArr[tileKey]==1 then
				return false
			end
			return true
		end 
		local tile_pos = self:cocosToTile(pos)
		local tile_pos_tmp = ccp(0,0)
		--上
		tile_pos_tmp.x = tile_pos.x
		tile_pos_tmp.y = tile_pos.y - 1
		if canGo(tile_pos_tmp.x,tile_pos_tmp.y)==true then
			points[#points+1] = {["x"]=tile_pos_tmp.x,["y"]=tile_pos_tmp.y,["angle"]=0}
		end
		--下
		tile_pos_tmp.x = tile_pos.x
		tile_pos_tmp.y = tile_pos.y + 1
		if canGo(tile_pos_tmp.x,tile_pos_tmp.y)==true then
			points[#points+1] = {["x"]=tile_pos_tmp.x,["y"]=tile_pos_tmp.y,["angle"]=180}
		end
		--左
		tile_pos_tmp.x = tile_pos.x - 1
		tile_pos_tmp.y = tile_pos.y
		if canGo(tile_pos_tmp.x,tile_pos_tmp.y)==true then
			points[#points+1] = {["x"]=tile_pos_tmp.x,["y"]=tile_pos_tmp.y,["angle"]=270}
		end
		--右
		tile_pos_tmp.x = tile_pos.x + 1
		tile_pos_tmp.y = tile_pos.y
		if canGo(tile_pos_tmp.x,tile_pos_tmp.y)==true then
			points[#points+1] = {["x"]=tile_pos_tmp.x,["y"]=tile_pos_tmp.y,["angle"]=90}
		end
	end
	return points
end 

-- 是否陆地碰撞 true 可以通过， false 碰撞
function SceneCfg:checkSail(pos, is_screen_pos) 
	if not self.land or not self.blockArr then return true end 
	
	if is_screen_pos then 
		local cam = self:getParent():getCamera()
		local x, y, z = cam:getEyeXYZ(0,0,0)
		local scale = self:getParent():getScale()
		pos.x = pos.x + x* scale 
		pos.y = pos.y + y* scale
		pos = self.land:convertToNodeSpace(pos)
	end 
	
	if self:checkPoint(pos) then 
		local tile_pos = self:cocosToTile(pos) 
		local tileKey = tile_pos.x.."_"..tile_pos.y
		if self.blockArr~=nil and self.blockArr[tileKey]==1 then
			return false
		else
			return true
		end
	else
		return false
	end 
	return true 	
end

-- 是否陆地碰撞 false 可以通过, true 碰撞
function SceneCfg:checkLand(pos) 
	pos = self.land:convertToNodeSpace(pos)

	local tile_pos = self:cocosToTile(pos)

	if tile_pos.x < 0 or tile_pos.y < 0 then
		print("===============checkLand error!!!")
		return true
	end

	-- 0为陆地阻挡
	if self.AStar:getWeight(tile_pos.x, tile_pos.y) == 0 then
		return true
	end

	return false
end

function SceneCfg:mark(x, y)
	if not TEST_FLG then return end

	local layer = self.test_layer[x.."_"..y]

	layer:setColor(ccc3(255, 0, 0))

	self.last_layer[x.."_"..y] = layer
end

function SceneCfg:searchPath(start_pos, end_pos)
	local pos_start = gameplayToCocosWorld(start_pos)
	pos_start = self.land:convertToNodeSpace(ccp(pos_start.x * BATTLE_SCALE_RATE, pos_start.y * BATTLE_SCALE_RATE))
	local tile_start = self:cocosToTile(pos_start)

	local pos_end = gameplayToCocosWorld(end_pos)
	pos_end = self.land:convertToNodeSpace(ccp(pos_end.x * BATTLE_SCALE_RATE, pos_end.y * BATTLE_SCALE_RATE))
	local tile_end = self:cocosToTile(pos_end)

	if tile_start.x == tile_end.x and tile_start.y == tile_end.y then
		return {end_pos}
	end

	tile_start.x = tile_start.x < 0 and 0 or tile_start.x
	tile_start.y = tile_start.y < 0 and 0 or tile_start.y
	tile_end.x = tile_end.x < 0 and 0 or tile_end.x
	tile_end.y = tile_end.y < 0 and 0 or tile_end.y

	local path = self.AStar:searchPath(tile_start.x, tile_start.y, tile_end.x, tile_end.y, 0)

	if not path then return end

	if not self.last_layer then
		self.last_layer = {}
	end
	for k, v in pairs(self.last_layer) do
		v:setColor(v.color)
	end

	local function tile_to_gameplay(x, y, offset_x, offset_y)
		local pos = self:tileToCocos(ccp(x, y))
		pos = ccp(pos.x + offset_x, pos.y + offset_y)
		return cocosToGameplayWorld(pos)
	end

	local world_pos = {}

	local last_x, last_y

	local offset_x, offset_y = 0, 0

	local direction
	local index = 1
	while true do
		local key_point

		if not path[index] then 
			key_point = tile_to_gameplay(path[index - 2], path[index - 1], 0, 0)
			world_pos[#world_pos + 1] = Vector3.new(math.floor(key_point:x() + 0.5), 0, math.floor(key_point:z() + 0.5))
			break 
		end

		local x, y = path[index], path[index + 1]

		self:mark(x, y)

		if last_x and last_y then
			local cur_direction = -1

			if math.abs(x - last_x) == 1 and math.abs(y - last_y) == 1 then
				offset_x = self.map_tile_size/2*(last_x > x and 1 or -1)
				offset_y = self.map_tile_size/2*(last_y > y and -1 or 1)

				cur_direction = DIRECTION_SLANT
			elseif math.abs(x - last_x) == 1 then
				cur_direction = DIRECTION_HORIZONTAL
			elseif math.abs(y - last_y) == 1 then
				cur_direction = DIRECTION_VERTICAL
			end

			-- print("=================", x, y, last_x, last_y, cur_direction, direction)

			if not direction then
				direction = cur_direction
			end

			if direction ~= cur_direction then
				if cur_direction == DIRECTION_SLANT then
					offset_x = self.map_tile_size/2*(last_x > x and -1 or 1)
					offset_y = self.map_tile_size/2*(last_y > y and 1 or -1)
				end

				key_point = tile_to_gameplay(last_x, last_y, offset_x, offset_y)
				-- print("================across path", last_x, last_y, offset_x, offset_y)

				offset_x, offset_y = 0, 0
				direction = cur_direction
			end
		end

		last_x, last_y = x, y

		if key_point then
			-- print("==================battle_scene_cfg", key_point:x(), key_point:z())
			world_pos[#world_pos + 1] = Vector3.new(math.floor(key_point:x() + 0.5), 0, math.floor(key_point:z() + 0.5))
		end

		index = index + 2

		if x == tile_end.x and y == tile_end.y then
			world_pos[#world_pos + 1] = end_pos
			break
		end
	end

	return world_pos
end

return SceneCfg