local ClsShip = require("gameobj/battle/ship")

local ShipEntity = {}

ShipEntity.createShipEntity = function(shipData)
	local entity = ClsShip.new(shipData)
	
	return entity
end

ShipEntity.createShips = function(ship_table)
	for k, shipData in pairs(ship_table) do
		if shipData.is_enter then
			ShipEntity.createShipEntity(shipData)	
		end
	end
end


-- 玩家船改变攻击目标
ShipEntity.playerChangeTarget = function(ship_data)
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if not ship or not ship_data then
		return 
	end

	ship:changeTarget(ship_data:getId(), true)
end

-- 玩家选择攻击目标
ShipEntity.selectTarget = function(x, y) 
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if not ship or ship:isAutoFighting() or ship:is_deaded() then return false end
	local node = BattleInit3D:clickObject(x, y)
	if node then 
		local gen_id = tonumber(node:getId())
		local ship_data = battle_data:getShipByGenID(gen_id)
		if ship_data and not ship_data.isDeaded then
			if ship_data.teamId == battle_config.neutral_team_id or 
				ship_data.teamId == battle_config.default_team_id then 
				return false
			else
				local dist = GetDistanceFor3D(ship.body.node, node)
				ShipEntity.playerChangeTarget(ship_data)
				if dist <= ship:getFarRange() then
					return true
				else
					return false
				end
			end
		end 
		return true 
	end 
	return false
end

--重新寻找攻击目标
ShipEntity.searchTarget = function(dt)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:BattleIsRunning() then return end

	local SHIPS = battle_data:GetShips()
	for _, ship_obj in pairs(SHIPS) do
		ship_obj:searchTarget(true)
	end
end

ShipEntity.releaseAllShips = function()
	local battle_data = getGameData():getBattleDataMt()

	battle_data:removeAllDrownShips()
	
	local SHIPS = battle_data:GetShips()
	for k, ship_data in pairs(SHIPS) do
		ship_data:release()
	end
end 

return ShipEntity
