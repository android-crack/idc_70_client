local map_partition = require("scripts/game_config/explore/explore_map_partition")
local TILE_HEIGHT = 960	
local TILE_WIDTH  = 1695
local TILE_SIZE = 64
local LAND_HEIGHT = TILE_SIZE * TILE_HEIGHT
local astar = require("gameobj/explore/qAstar")
local res = "res/explorer/map.bit"
local AStar = astar.new()
AStar:initByBit(res, TILE_WIDTH, TILE_HEIGHT)

local util = {}

-- 根据位置返回关键点id
local function getPartitionId(pos) 	
	for k, v in ipairs(map_partition) do
		local rect = CCRect(v.start_pos[1], v.start_pos[2], v.width, v.height)
		if rect:containsPoint(pos) then 
			return k
		end 
	end 
end

local function findKeyPoint(pos_st, pos_end)
	local par_st = getPartitionId(pos_st)
	local par_end = getPartitionId(pos_end)
	if not par_st or not par_end then return end 
	
	local is_inverse = false
	local map_key_point = require("game_config/explore/map_key_point")
	local key_tab = nil
	if map_key_point[par_st][par_end] then 
		key_tab = map_key_point[par_st][par_end]
	elseif map_key_point[par_end][par_st] then 
		key_tab = map_key_point[par_end][par_st]
		is_inverse = true
	else 
		return 
	end
	
	local key_tab_st = {}
	local key_tab_end = {} 
	
	local index_st = nil 
	local index_end = nil
	
	-- 找最佳关键点 （起始点和终点）
	if is_inverse then 
		for k, pos in ipairs(key_tab) do
			local point = ccp(pos[1], pos[2])
			local par_id = getPartitionId(point)
			if par_id == par_st then 
				if index_st == nil or index_st > k then 
					index_st = k
				end 
			elseif par_id == par_end then 
				if index_end == nil or index_end < k then 
					index_end = k
				end 
			end 	
		end 
		if index_st == nil or index_end == nil then return end 
		index_st = index_st - 1
		index_end = index_end + 1
		if index_st < index_end then return end 
		
	else 
		for k, pos in ipairs(key_tab) do
			local point = ccp(pos[1], pos[2])
			local par_id = getPartitionId(point)
			if par_id == par_st then 
				if index_st == nil or index_st < k then 
					index_st = k
				end 
			elseif par_id == par_end then 
				if index_end == nil or index_end > k then 
					index_end = k
				end 
			end 	
		end 
		if index_st == nil or index_end == nil then return end 
		index_st = index_st + 1
		index_end = index_end - 1
		if index_st > index_end then return end 
	end
	
	local key_path = {} 
	
	if not is_inverse then 
		for k = index_st, index_end, 1 do 
			local pos = key_tab[k]
			table.insert(key_path, pos)
		end 
	else 
		for k = index_st, index_end, -1 do 
			local pos = key_tab[k]
			table.insert(key_path, pos)
		end
	end 
	
	return key_path
end 


--计算两个格子坐标之间的像素距离（已计算关键点）
--start_pos：开始点的格子坐标，例如start_pos = {10, 10}
--end_pos：结束点的格子坐标，例如end_pos = {100, 100}
function util.calculatePosToPosDistance(start_pos, end_pos)
	if not start_pos or not end_pos then return 0 end
	if #start_pos ~= 2 or #end_pos ~= 2 then return 0 end

	local cocosToTile2 = function(position)  
		return ccp(position.x*TILE_SIZE+TILE_SIZE/2, LAND_HEIGHT-position.y*TILE_SIZE-TILE_SIZE/2)
	end

	local calculateDistance = function(pos1, pos2)  
		local path_index = 1
		local distance = 0
		local path = AStar:searchPath(pos1[1], pos1[2], pos2[1], pos2[2], 1)  --路径
		local path_len = #path
		local tmp_pos1 = nil
		local tmp_pos2 = nil

		for k=1,path_len do
			if (path_index + 3) > path_len then
				break
			end
			tmp_pos1 = cocosToTile2(ccp(path[path_index], path[path_index + 1]))
			tmp_pos2 = cocosToTile2(ccp(path[path_index + 2], path[path_index + 3]))
			distance = distance + Math.distance(tmp_pos1.x, tmp_pos1.y, tmp_pos2.x, tmp_pos2.y)
			path_index = path_index + 2
		end
		return distance
	end

	local all_distance = 0
	local pos_st = ccp(start_pos[1], start_pos[2]) 
	local pos_end = ccp(end_pos[1], end_pos[2])
	local key_path = findKeyPoint(pos_st, pos_end)
	
	local cur_pos = start_pos
	local next_pos = end_pos
	
	if key_path and #key_path > 0 then 
		for index = 1 , #key_path do
			next_pos = key_path[index]
			all_distance = all_distance + calculateDistance(cur_pos, next_pos)
			cur_pos = next_pos
		end 
		all_distance = all_distance + calculateDistance(cur_pos, end_pos)
	else
		all_distance = calculateDistance(start_pos, end_pos)
	end 	

	return all_distance
end

return util