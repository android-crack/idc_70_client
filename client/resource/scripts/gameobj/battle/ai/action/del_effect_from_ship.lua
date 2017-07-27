local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDelEffectFromShip = class("ClsAIActionDelEffectFromShip", ClsAIActionBase) 

function ClsAIActionDelEffectFromShip:getId()
	return "del_effect_from_ship"
end

function ClsAIActionDelEffectFromShip:initAction(id, filename, dx, dy, time)
	self.id = id	
end

function ClsAIActionDelEffectFromShip:__dealAction(target_id, delta_time)
	local battleData = getGameData():getBattleDataMt()
	local target_obj = battleData:getShipByGenID(target_id)

	if not target_obj or target_obj:is_deaded() then
		return false 
	end

	target_obj:delEffect(self.id)

	require("gameobj/battle/battleRecording"):recordVarArgs("del_ship_effect", target_id, self.id)

	return true
end

return ClsAIActionDelEffectFromShip
