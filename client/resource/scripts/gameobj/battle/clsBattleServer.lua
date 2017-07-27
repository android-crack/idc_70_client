-- 战斗UI刷新与逻辑分离

local WalkManager = require("gameobj/battle/walkManager")

local ClsBattleServer = class("ClsBattleServer")

function ClsBattleServer.updatePosition(ship_body, dt)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isUpdateShip(ship_body.gen_id) then return end

	local ship_obj = battle_data:getShipByGenID(ship_body.gen_id)

	if not ship_obj or ship_obj:is_deaded() then return end

	if not ship_obj:hasBuff("tuji_self") then return end
	
	-- 校验船体碰撞
	local isCollisionShip, collision_ship_obj = WalkManager.isCollisionShip(ship_obj)

	if isCollisionShip and collision_ship_obj:getTeamId() ~= ship_obj:getTeamId() then 
		ship_obj:check_skill_hit(collision_ship_obj) 
	end
end

function ClsBattleServer.dynamicRefresh(ship_body, dt)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isUpdateShip(ship_body.gen_id) then return end
	
	if not ship_body or not ship_body.target_pos then return end

	local ship_node = ship_body.node

	if not ship_node then return end

	local dist = ship_body:calcSpeed(ship_body.speed, dt, ship_body.speed_rate)

	ship_body.check_dist = (ship_body.check_dist or 0) + dist

	-- 逐段检测
	if ship_body.check_dist < CHECK_DIST then return end

	ship_body.check_dist = ship_body.check_dist - CHECK_DIST

	local boat_pos = ship_node:getTranslationWorld()

	local vec_dir = Vector3.new()
	Vector3.subtract(ship_body.target_pos, boat_pos, vec_dir)
	vec_dir:normalize()

	local tmp_vec = Vector3.new(vec_dir)
	tmp_vec:scale(CHECK_DIST)
	tmp_vec:add(boat_pos)

	local map_layer = battle_data:GetLayer("map_layer")

	local cocos_pos = gameplayToCocosWorld(tmp_vec)
	if map_layer:checkLand(ccp(cocos_pos.x*BATTLE_SCALE_RATE, cocos_pos.y*BATTLE_SCALE_RATE)) then
		ship_body:resetPath()
		ClsBattleServer.hitLand(ship_body, vec_dir)
		return true
	end
end

function ClsBattleServer.hitLand(ship_body, forward)
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(ship_body.gen_id)

	ship:check_skill_hit(nil)

	if ship_body.path_reason == FV_MOVE_CRUISE then
		if ship.target and not ship.target:is_deaded() then 
			ship_body:setAngle(ship_body:getAngle() + 180)

			ship:cruise()
		end
	elseif ship:isAutoFighting() then
		ship:awayFromLand(forward)
		ship:resetMoveStatus(FV_MOVE_DODGE, 1)
	else
		local battleRecording = require("gameobj/battle/battleRecording")
		battleRecording:recordVarArgs("battle_stop_ship", ship:getId())
	end
end

return ClsBattleServer