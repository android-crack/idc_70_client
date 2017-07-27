-- 新舰队数据
local fleet_info = require("game_config/boat/fleet_info")

local ClsFleetData = class("ClsFleetData")
function ClsFleetData:ctor()
end


--船舶改造保存操作
function ClsFleetData:askSaveLegendBoat( type, boat_key )
    GameUtil.callRpc("rpc_server_boat_save_mjms_huodong", {type, boat_key},"rpc_client_boat_save_mjms_huodong")
end
-- 根据阵形id 、阵形位置、阵形方向，计算船在战斗的偏移位置
function ClsFleetData:getShipBattlePosByAnger(fleet_id, pos, dangle)
	local off_x, off_y = 0, 0
	local dx = 150
	local dy = 150
	local c_posx = 3 -- 中心
	local c_posy = 2

	local seat = nil

	if (not fleet_info[fleet_id]) then return 0, 0 end

	local detail_info = fleet_info[fleet_id].detail_info
	if pos < 6 and detail_info and detail_info[pos] then
		seat = detail_info[pos].seat
	elseif pos == 6 then
		seat = fleet_info[fleet_id].aidSeat
	end
	
	x = (seat[2] - c_posx)*dx
	y = -(seat[1] - c_posy)*dy
	local angle = Math.getAngle(0, 0, x, y)
	local dis = Math.distance(0, 0, x, y)
	off_x = math.cos(math.rad(angle - dangle))*dis
	off_y = math.sin(math.rad(angle - dangle))*dis
	
	return off_x, off_y
end

-- 根据阵形id 、阵形位置、阵形方向，计算船在战斗的偏移位置
function ClsFleetData:getShipBattlePos(fleet_id, pos, fleet_dir, isAidBoat)
	local dangle = (fleet_dir - 1) * 45
	return self:getShipBattlePosByAnger( fleet_id, pos, dangle)
end

return ClsFleetData