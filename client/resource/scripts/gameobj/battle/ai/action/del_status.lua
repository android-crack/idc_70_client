local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDelStatus = class("ClsAIActionDelStatus", ClsAIActionBase) 

function ClsAIActionDelStatus:getId()
	return "del_status"
end

function ClsAIActionDelStatus:initAction(status_id)
	self.status_id = status_id
end

function ClsAIActionDelStatus:__dealAction(target_id, delta_time)
	if not self.status_id then return end

	local target = nil
	if target_id then
		local battle_data = getGameData():getBattleDataMt()
		target = battle_data:getShipByGenID(target_id)
	end

	if not target then
		local ai_obj = self:getOwnerAI()
		if not ai_obj then return end

		target = ai_obj:getOwner()
	end
	
	if target and not target:is_deaded() then
		local buff = target:hasBuff(self.status_id)
		if buff then
			buff:del()
		end
	end
end

return ClsAIActionDelStatus
