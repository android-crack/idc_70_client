local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionCruise = class("ClsAIActionCruise", ClsAIActionBase) 

function ClsAIActionCruise:getId()
	return "cruise"
end

function ClsAIActionCruise:initAction()
end

-- 绕着目标游弋
function ClsAIActionCruise:__dealAction(target, delta_time)
	local battle_data = getGameData():getBattleDataMt()

	local cruise_obj = battle_data:getShipByGenID(target)

	if not cruise_obj or not cruise_obj.target or cruise_obj.target:is_deaded() then 
		return false 
	end

	if cruise_obj:hasBuff("tuji_self") then return false end

	if not cruise_obj:checkMoveAction(FV_MOVE_CRUISE) then return true end

	cruise_obj:cruise()

	return true
end

return ClsAIActionCruise
