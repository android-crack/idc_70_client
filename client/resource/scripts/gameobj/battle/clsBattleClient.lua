-- 战斗UI刷新与逻辑分离

local ClsBattleClient = class("ClsBattleClient")

function ClsBattleClient.updatePositon(ship_body, dt)
	if not ship_body then return end

	local ship_node = ship_body:getNode()

	if not ship_node then return end

	if not ship_body.target_pos then return end

	local boat_pos = ship_node:getTranslationWorld()

	-- 船只到目标点向量
	local vec_dir = Vector3.new()
	Vector3.subtract(ship_body.target_pos, boat_pos, vec_dir)

	-- dt时间位移增量
	local dist = ship_body:calcSpeed(ship_body.speed, dt, ship_body.speed_rate)

	if dist*dist > vec_dir:x()*vec_dir:x() + vec_dir:z()*vec_dir:z() then
		ship_node:setTranslation(ship_body.target_pos)

		return true
	else
		vec_dir:normalize()
		vec_dir:scale(dist)

		ship_node:translate(vec_dir)
	end
end

function ClsBattleClient.updataAngle(ship_body, dt)
	if not ship_body then return end

	local ship_node = ship_body:getNode()

	if not ship_node then return end

	local delta_angle = dt * ship_body.turn_speed

	if delta_angle > math.abs(ship_body.rotate_angle) then
		delta_angle = math.abs(ship_body.rotate_angle)
	end
	
	if ship_body.rotate_angle < 0 then
		delta_angle = - delta_angle
	end

	ship_body.rotate_angle = ship_body.rotate_angle - delta_angle

	ship_node:rotateY(math.rad(- delta_angle))
end

------------------------------------------------------------------------------------------------------------------------

function ClsBattleClient.moveTo(ship_body, pos, reason, move_type)
	if not ship_body or not ship_body.node or not pos then return end

	if ship_body:getBanTurn() then return end

	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(ship_body.gen_id)

	if not ship_obj or ship_obj:is_deaded() then return end

	local scale_tx, scale_ty = math.floor(pos:x()*FIGHT_SCALE + 0.5), math.floor(pos:z()*FIGHT_SCALE + 0.5)
	local tx, ty = scale_tx/FIGHT_SCALE, scale_ty/FIGHT_SCALE

	local target_pos

	if ship_body.move_path and ship_body.move_path[#ship_body.move_path] then
		target_pos = ship_body.move_path[#ship_body.move_path]
		if target_pos:x() == tx and target_pos:z() == ty then return end
	end
	
	target_pos = Vector3.new(tx, 0, ty)

	move_type = move_type or DYNAMIC_REFRESH

	local path
	if move_type == DYNAMIC_REFRESH then
		ship_body.move_type = DYNAMIC_REFRESH
		path = {target_pos}

		-- 测试用
		-- ship_body:addPathEffect(target_pos)
	elseif move_type == ASTAR_FIND_PATH then
		ship_body.move_type = ASTAR_FIND_PATH

		local boat_pos = ship_body.node:getTranslationWorld()

		local map_layer = battle_data:GetLayer("map_layer")
		path = map_layer:searchPath(boat_pos, target_pos)
	end

	if not path or #path == 0 then return end

	ClsBattleClient.moveToByPath(ship_body, path, reason or "unkown")
end

function ClsBattleClient.moveToByPath(ship_body, path, reason)
	if type(path) ~= "table" or #path == 0 then return end

	ship_body.move_path = path
	ship_body.path_index = 1
	ship_body.path_reason = reason
	ship_body.target_pos = ship_body.move_path[ship_body.path_index]
	ship_body.check_dist = CHECK_DIST + ship_body.gen_id	

	ship_body:setRotateAngle(GetAngleBetweenNodeAndPoint(ship_body.node, ship_body.target_pos))

	if reason == FV_MOVE_SERVER then return end

	local boat_pos = ship_body.node:getTranslationWorld()
	local x, y = math.floor(boat_pos:x()*FIGHT_SCALE + 0.5), math.floor(boat_pos:z()*FIGHT_SCALE + 0.5)

	local tmp_table = {} 
	tmp_table[#tmp_table + 1] = x
	tmp_table[#tmp_table + 1] = y
	for i, v in ipairs(ship_body.move_path) do
		tmp_table[#tmp_table + 1] = math.floor(v:x()*FIGHT_SCALE + 0.5)
		tmp_table[#tmp_table + 1] = math.floor(v:z()*FIGHT_SCALE + 0.5)
	end

	local battle_data = getGameData():getBattleDataMt()
	GameUtil.callRpcVarArgs("rpc_server_fight_move_to_points", battle_data:getSession(), ship_body.gen_id, tmp_table)
end

return ClsBattleClient