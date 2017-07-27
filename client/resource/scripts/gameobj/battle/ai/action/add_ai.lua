local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionAddAI = class("ClsAIActionAddAI", ClsAIActionBase)

function ClsAIActionAddAI:getId()
	return "add_ai"
end

function ClsAIActionAddAI:initAction(ai_ids)
	self.ai_ids = ai_ids
end

function ClsAIActionAddAI:__dealAction(target_id, delta_time)
	if not self.ai_ids then return false end

	local battle_data = getGameData():getBattleDataMt()
	local target_obj = battle_data:getShipByGenID(target_id)

	if target_id == -1 then
		target_obj = getGameData():getAutoTradeAIHandler()
	end
	if target_id == -2 then
		target_obj = battle_data
	end


	if not target_obj then return false end

	for _, ai_id in pairs(self.ai_ids) do
		target_obj:addAI(ai_id, {})
	end

	if battle_data:GetBattleSwitch() then
		battle_data:uploadAI(true, target_id, self.ai_ids)
	end
end

return ClsAIActionAddAI
