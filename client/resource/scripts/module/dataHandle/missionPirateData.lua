--
-- Author: lzg0496
-- Date: 2016-11-16 11:30:03
-- Function: 任务巡逻海盗
--

local seaforce_boat_config = require("game_config/mission/seaforce_boat_config")

local missionPirateData = class("missionPirateData")

function missionPirateData:ctor()
	self.m_npc_data = {}
	self.m_map_pos = {}
	self:initPos()
	self.fight_pirate_id = nil
end

function missionPirateData:initPos()
	local exploreMapUtil = require("module/explore/exploreMapUtil")
	self.m_map_pos = {}
	for id, item in pairs(seaforce_boat_config) do
	
		self.m_map_pos[id] = {pos_info = {map = {}, land = {}}, is_change = true, start_time = os.clock(), is_lock = false, lock_time = 0, during_time = 100}
		local info = self.m_map_pos[id].pos_info
		for k, v in ipairs(item.walk_pos_list) do
			local map_tab = {}
			local map_pos = item.map_pos[k]
			map_tab.x, map_tab.y = exploreMapUtil.mapTileToCosos(map_pos[1], map_pos[2])
			info.map[k] = map_tab
			
			local land_tab = {}
			local pos = exploreMapUtil.cocosToTileByLand(ccp(v[1], v[2]))
			land_tab.x = pos.x
			land_tab.y = pos.y
			info.land[k] = land_tab
			
			if k <= 1 then
				info.map_len = 0
				info.land_len = 0
				info.map[k].len_n = 0
				info.land[k].len_n = 0
			else
				local before_map_item = info.map[k - 1]
				local before_land_item = info.land[k - 1]
				info.map[k].len_n = Math.distance(before_map_item.x, before_map_item.y, map_tab.x, map_tab.y)
				info.land[k].len_n = Math.distance(before_land_item.x, before_land_item.y, land_tab.x, land_tab.y)
				info.map_len = info.map_len + info.map[k].len_n
				info.land_len = info.land_len + info.land[k].len_n
			end
		end
		
		if #info.map <= 1 then
			self.m_map_pos[id].is_change = false
		end
	end
	
	for id, map_pos in pairs(self.m_map_pos) do
		if map_pos.is_change then
			map_pos.during_time = map_pos.pos_info.map_len
			self:makeRangeInfo(map_pos.pos_info.map, map_pos.pos_info.map_len)
			self:makeRangeInfo(map_pos.pos_info.land, map_pos.pos_info.land_len)
		end
	end
end

function missionPirateData:makeRangeInfo(points, dis_n)
	local len_n = #points
	local cur_dis_n = 0
	for i, point in ipairs(points) do
		cur_dis_n = cur_dis_n + point.len_n
		if i <= 1 then
			point.rate = 0
		elseif i >= len_n then
			point.rate = 1
		else
			point.rate = cur_dis_n/dis_n
		end
	end
end

function missionPirateData:getPosData(cfg_id)
	return self.m_map_pos[cfg_id]
end

function missionPirateData:setIslockTimeById(cfg_id, is_lock)
	local npc_data = self.m_npc_data[cfg_id]
	local map_pos = self.m_map_pos[cfg_id]
	if npc_data and map_pos then
		if map_pos.is_lock ~= is_lock then
			map_pos.is_lock = is_lock
			if is_lock then
				map_pos.lock_time = os.clock()
			else
				if map_pos.lock_time > 0 then
					map_pos.start_time = map_pos.start_time + (os.clock() - map_pos.lock_time)
				end
				map_pos.lock_time = 0
			end
		end
	end
end

function missionPirateData:getPirateByCfgId(cfg_id)
	return self.m_npc_data[cfg_id]
end

function missionPirateData:getPosInLand(cfg_id)
	return self:getMissionPiratePos(cfg_id, "land")
end

function missionPirateData:getPosInMap(cfg_id)
	return self:getMissionPiratePos(cfg_id, "map")
end

function missionPirateData:getMissionPiratePos(cfg_id, type_str)
	local npc_data = self.m_npc_data[cfg_id]
	local map_pos = self.m_map_pos[cfg_id]
	if npc_data and map_pos then
		if map_pos.is_change then
			return self:getMapPointInClock(map_pos, type_str)
		end
		local pos = map_pos.pos_info[type_str][1]
		return pos.x, pos.y
	end
end

function  missionPirateData:getMapPointInClock(map_pos, type_str)
	local time_n = 0
	if map_pos.is_lock then
		time_n = map_pos.lock_time - map_pos.start_time
	else
		time_n = os.clock() - map_pos.start_time
	end
	
	time_n = time_n % map_pos.during_time
	
	local rate_n = time_n/map_pos.during_time*2
	if rate_n > 1 then
		rate_n = 2 - rate_n
	end
	if rate_n < 0 then rate_n = 0 end
	
	return self:getPosFromRate(map_pos.pos_info[type_str], rate_n)
end

function missionPirateData:getPosFromRate(pos_list, rate_n)
	if rate_n < 0 then rate = 0 end
	if rate_n > 1 then rate = 1 end
	local bigger_key = 1
	for i, pos_item in ipairs(pos_list) do
		bigger_key = i
		if rate_n <= pos_item.rate then
			break
		end
	end
	
	if bigger_key <= 1 then
		local pos = pos_list[bigger_key]
		return pos.x, pos.y
	end
	
	local after_pos = pos_list[bigger_key]
	local before_pos = pos_list[bigger_key - 1]
	local new_rate = (rate_n - before_pos.rate)/(after_pos.rate - before_pos.rate)
	local x = before_pos.x + (after_pos.x  - before_pos.x)*new_rate
	local y = before_pos.y + (after_pos.y  - before_pos.y)*new_rate
	return x, y
end

function missionPirateData:getMapPathPointPos(cfg_id)
	local map_pos = self.m_map_pos[cfg_id]
	local pos_list = {}
	if map_pos then
		local point_count = math.floor(map_pos.pos_info.map_len/12)
		for i = 0, point_count do
			local x, y = self:getPosFromRate(map_pos.pos_info.map, i/point_count)
			local pos_tab = {}
			pos_tab.x = x
			pos_tab.y = y
			table.insert(pos_list, pos_tab)
		end
	end
	return pos_list
end

function missionPirateData:addPirate(data)
	self.m_npc_data[data.cfg_id] = data
	self:setIslockTimeById(data.cfg_id, false)
end

function missionPirateData:updateAttr(attr_key, data)
	self.m_npc_data[data.cfg_id] = data
end

function missionPirateData:removePirate(data)
	self.m_npc_data[data.cfg_id] = nil
end

function missionPirateData:removeAllPirates()
	local ids_tab = {}
	for k, v in pairs(self.m_npc_data) do
		if v then
			table.insert(ids_tab, v.id)
		end
	end
	
	local exploreNpcData = getGameData():getExploreNpcData()
	for _, id in ipairs(ids_tab) do
		exploreNpcData:removeNpc(id)
	end
end

-- pirate_info = {missionId, pirateId}
function missionPirateData:refreshAllPirate(pirates)
	self:removeAllPirates()
	
	local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")
	for k, pirate_info in pairs(pirates) do
		local pirate_id = pirate_info.pirateId
		local npc_id = exploreNpcType.MISSION_PIRATE .. "_" .. pirate_id
		getGameData():getExploreNpcData():addStandardNpc(npc_id, pirate_id, exploreNpcType.MISSION_PIRATE, pirate_info, pirate_id, seaforce_boat_config[pirate_id])
	end
end

function missionPirateData:setFightPirateId(cfg_pirate_id)
	self.fight_pirate_id = cfg_pirate_id
end

function missionPirateData:getFightPirateId()
	return self.fight_pirate_id
end

function missionPirateData:askFightPirate(fight_id, cfg_id)
    local attr_str = json.encode({["pirateId"] = cfg_id})
    GameUtil.callRpc("rpc_server_fight_pve",{fight_id, battle_config.fight_type_pve_seaforce, attr_str})
end

function missionPirateData:askPirateMeet(cfg_id)
	GameUtil.callRpc("rpc_server_seaforce_pirate_info", {cfg_id})
end

return missionPirateData
