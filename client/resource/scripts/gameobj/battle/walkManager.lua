-- 行走管理

local WalkManager = {}

local BOUND_OFFW = 0
local BOUND_OFFH = 0

local bound_left_vec 
local bound_right_vec
local bound_top_vec
local bound_bottom_vec

local UP_ANGLE = 0
local RIGHT_ANGLE = 90
local DOWN_ANGLE = 180
local LEFT_ANGLE = 270

local OFFSET_ANGLE = 2

function WalkManager.init()
	bound_left_vec = Vector3.new(0,0,-1)
	bound_right_vec = Vector3.new(0,0,1)
	bound_top_vec = Vector3.new(1,0,0)
	bound_bottom_vec = Vector3.new(-1,0,0)
end

local function getRotateAngle(rotate_angle, angle)
	local d_rotate_angle = math.deg(rotate_angle)
	if d_rotate_angle >= 90 then
		angle = angle + 180 - OFFSET_ANGLE*2
	end

	angle = angle >= 360 and angle - 360 or angle

	return angle
end

function WalkManager.isOutBound(ship, vec3)
	local x, z = vec3:x(), vec3:z()
	
	local width, height = CameraFollow:GetSceneBound()
	local rotate_angle = 0
	
	local forward = ship.node:getForwardVectorWorld()

	local angle

	if x < BOUND_OFFW then
		rotate_angle = Vector3.angle(forward, bound_left_vec)

		angle = UP_ANGLE
	elseif z < BOUND_OFFH - height then
		rotate_angle = Vector3.angle(forward, bound_top_vec)

		angle = RIGHT_ANGLE
	elseif x > width-BOUND_OFFW then
		rotate_angle = Vector3.angle(forward, bound_right_vec)

		angle = DOWN_ANGLE
	elseif z > -BOUND_OFFH then 
		rotate_angle = Vector3.angle(forward, bound_bottom_vec)

		angle = LEFT_ANGLE
	end

	if angle then
		angle = getRotateAngle(rotate_angle, angle) + OFFSET_ANGLE
	end

	-- print("WalkManager.isOutBound:", math.deg(rotate_angle))

	return rotate_angle, angle
end

function WalkManager.inLand(screen_pos)
	local battleData = getGameData():getBattleDataMt()
	local map_layer = battleData:GetLayer("map_layer")
	if not map_layer then return true end
	
	local x, y = screen_pos:x(), screen_pos:y()	
	
	if not map_layer:checkSail(ccp(x, y), true) then 
		return true 
	end 

	return false 
end 

local tuji_dis = 30
function WalkManager.isCollisionShip(ship_data)
	local targets = ship_data:getCollisionObj()
	if not targets then return false, nil end

	for k, v in pairs(targets) do
		if not v:is_deaded() then 
			local ship_point = ship_data:getCollisionPoint(v:getId())
			
			if ship_point and IsPointAtForward(ship_data.body.node, ship_point) then 
				return true, v
			end

			local pos_1, pos_2 = ship_data:getPosition3D(), v:getPosition3D()
			local x = pos_1:x() - pos_2:x()
			local y = pos_1:y() - pos_2:y()
			if x*x + y*y <= tuji_dis*tuji_dis then
				return true, v
			end
		end
	end

	return false, nil
end

function WalkManager.addCollisionObj(nodeA, nodeB, is_collision, vec1, vec2)
	-- 使用getId来区别船舶，有潜在问题?
	local gen_id = tonumber(nodeA:getId())
	local battle_data = getGameData():getBattleDataMt()
	local ship_data = battle_data:getShipByGenID(gen_id)

	if not ship_data then return end

	local id = tonumber(nodeB:getId())
	local target = battle_data:getShipByGenID(id)
	if target then 
		if is_collision then 
			ship_data:setCollisionObj(id, target, Vector3.new(vec1))
			target:setCollisionObj(gen_id, ship_data, Vector3.new(vec2))
		else
			ship_data:setCollisionObj(id)
			target:setCollisionObj(gen_id)
		end
	end
end

return WalkManager
