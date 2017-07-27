local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionMoveTo3D = class("ClsAIActionMoveTo3D", ClsAIActionBase) 

function ClsAIActionMoveTo3D:getId()
	return "move_to_3d"
end

function ClsAIActionMoveTo3D:initAction()
	self.duration = 99999999 
end

function ClsAIActionMoveTo3D:__dealAction(target, delta_time)
	local battle_data = getGameData():getBattleDataMt()

	local target_obj = battle_data:getShipByGenID(target)

	if not target_obj or target_obj:is_deaded() then return false end

	local ai_obj = self:getOwnerAI()
	local pos = ai_obj:getData("__move_to_pos")
	
	if not pos then return false end

	target_obj:moveTo(pos, "move_to_3d")

	self.range = 50

	if GetVectorDistance(pos, target_obj.body.node:getTranslationWorld()) <= self.range then
		return false
	end

	return true
end

return ClsAIActionMoveTo3D
