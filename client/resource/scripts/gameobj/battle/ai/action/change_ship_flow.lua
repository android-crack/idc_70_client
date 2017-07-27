local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionChangeShipFlow = class("ClsAIActionChangeShipFlow", ClsAIActionBase) 

function ClsAIActionChangeShipFlow:getId()
	return "change_ship_flow"
end

function ClsAIActionChangeShipFlow:initAction(flow_name)
	self.flow_name = flow_name
end

function ClsAIActionChangeShipFlow:__dealAction(target_id, delta_time)
	local battle_data = getGameData():getBattleDataMt()
	local target_obj = battle_data:getShipByGenID(target_id)

	if not target_obj or target_obj:is_deaded() then return false end

	target_obj:getBody():setFlowState(self.flow_name)

	require("gameobj/battle/battleRecording"):recordVarArgs("battle_set_technique", target_id, self.flow_name)
end

return ClsAIActionChangeShipFlow
