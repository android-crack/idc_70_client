local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionFollowLeader = class("ClsAIActionFollowLeader", ClsAIActionBase) 

function ClsAIActionFollowLeader:getId()
	return "follow_leader"
end

function ClsAIActionFollowLeader:initAction( range )
	self.range = range or 100

	-- 设置持续时间无限长
	self.duration = 99999999 
end

function ClsAIActionFollowLeader:__dealAction( target, delta_time )
	local battle_data = getGameData():getBattleDataMt()

	local target_obj = battle_data:getShipByGenID(target)

	if not target_obj then return false end

	local control_ship = battle_data:getControlShip(target_obj:getUid())

	if not control_ship or control_ship:is_deaded() or control_ship == target_obj then return false end

	if not control_ship:getBody().target_pos then return false end
	
	local angle = control_ship.body:getAngle()
	angle = angle + control_ship.body.rotate_angle
	angle = math.rad(angle)

	local distance = 200
	local tX, tY = target_obj:getPosition()

	local x, y = tX + distance * math.sin(angle), tY + distance * math.cos(angle)

	target_obj:moveTo( cocosToGameplayWorld(ccp(x,y)), "follow_leader" )

	return true
end

return ClsAIActionFollowLeader
