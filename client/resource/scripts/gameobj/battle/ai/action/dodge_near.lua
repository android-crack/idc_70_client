local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDodgeNear = class("ClsAIActionDodgeNear", ClsAIActionBase)

local NEAR_WALK = 1

function ClsAIActionDodgeNear:getId()
	return "dodge_near"
end

function ClsAIActionDodgeNear:initAction(range)
end

function ClsAIActionDodgeNear:__dealAction(target, delta_time)
	local battleData = getGameData():getBattleDataMt()

	local ship = battleData:getShipByGenID(target)

	if not ship or ship:is_deaded() then return end

	if ship:hasBuff("tuji_self") then return end

	local targets = ship:getCollisionObj()

	if not targets then return end

	local dodge_obj

	for k, v in pairs(targets) do
		if not v:is_deaded() and v:getWalkId() == NEAR_WALK then 
			local ship_point = ship:getCollisionPoint(v:getId())

			if ship_point then
				dodge_obj = v
				break
			end
		end
	end

	if not dodge_obj then return end

	local x1, y1 = ship:getPosition()
	local x2, y2 = dodge_obj:getPosition()

	local function compare(num_1, num_2)
		return num_1 <= num_2 and -50 or 50
	end

	x1 = x1 + compare(x1, x2)
	y1 = y1 + compare(y1, y2)

	ship:moveTo(cocosToGameplayWorld({x = x1, y = y1}), FV_MOVE_DODGE)

	return true
end

return ClsAIActionDodgeNear
