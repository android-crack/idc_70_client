local ExploreMapUtil = {}

ExploreMapUtil.tileToCocos = function(position, mapHeight, tileSize)
	local x = math.floor(position.x/tileSize)
	local y = math.floor((mapHeight - position.y)/tileSize)
	return ccp(x, y)
end

ExploreMapUtil.cocosToTile = function(position, mapHeight, tileSize)  --加了偏移量
	return ccp(position.x*tileSize+tileSize/2, mapHeight-position.y*tileSize-tileSize/2)
end

ExploreMapUtil.cocosToTileByLand = function(position)
	local TILE_SIZE = 64
	local TILE_HEIGHT = 960
	local TILE_WIDTH  = 1695
	local LAND_HEIGHT = TILE_SIZE * TILE_HEIGHT

	return ExploreMapUtil.cocosToTile(position, LAND_HEIGHT, TILE_SIZE)
end

ExploreMapUtil.landTileToThumbTile = function(position)
	local THUMB_TILE_SIZE = 15 --小地图的格子大小
	local THUMB_MULTIPLE = 32 --缩略图和大图的倍数关系
	local THUMB_TILE_MAX = 63 --小地图的最大列格子数
	
	local pos_point = ccp(math.floor(position.x/THUMB_TILE_SIZE*THUMB_MULTIPLE),math.floor((THUMB_TILE_MAX-position.y/THUMB_TILE_SIZE)*THUMB_MULTIPLE)) --转成ccp
	return pos_point
end

local SMALL_MAP_TILE_SIZE = 32
local SMALL_MAP_WIDTH = 113
local SMALL_MAP_HEIGHT = 64
local SMALL_MAP_HEIGHT_COCOS = SMALL_MAP_HEIGHT * SMALL_MAP_TILE_SIZE
ExploreMapUtil.mapTileToCosos = function(x, y)
	return x*SMALL_MAP_TILE_SIZE, (SMALL_MAP_HEIGHT_COCOS - y * SMALL_MAP_TILE_SIZE)
end

return ExploreMapUtil