local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDodge = class("ClsAIActionDodge", ClsAIActionBase) 

function ClsAIActionDodge:getId()
	return "dodge"
end

function ClsAIActionDodge:initAction(range)
	self.range = range

	-- 设置持续时间无限长
	self.duration = 99999999 
end

function ClsAIActionDodge:__dealAction(target, delta_time)
	local battleData = getGameData():getBattleDataMt()

	local target_obj = battleData:getShipByGenID(target)

	if not target_obj or target_obj:is_deaded() then return false end

	if target_obj:hasBuff("tuji_self") then return false end

	local dodge_obj = target_obj.target 

	if not dodge_obj or dodge_obj:is_deaded() then 
		target_obj:setTarget(nil)
		return false 
	end

	if not target_obj:checkMoveAction(FV_MOVE_DODGE) then return true end
	
	local range = self.range or target_obj:getFarRange()

	local x1, y1 = target_obj:getPosition()
	local x2, y2 = dodge_obj:getPosition()

	if (x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1) > range*range then 
		return false 
	end

	local pos = ccp(x1*2 - x2, y1*2 - y2)

	if x1 == x2 and y1 == y2 then
		if pos.x > BATTLE_SCENE_WIDTD/2 then
			pos.x = pos.x - 200
		else
			pos.x = pos.x + 200
		end
	end

	target_obj:moveTo(cocosToGameplayWorld(pos), FV_MOVE_DODGE)

	return true
end

return ClsAIActionDodge
