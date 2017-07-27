local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDelAI = class("ClsAIActionDelAI", ClsAIActionBase)

function ClsAIActionDelAI:getId()
	return "delete_ai"
end

function ClsAIActionDelAI:initAction(ai_ids)
	self.ai_ids = ai_ids
end

function ClsAIActionDelAI:__dealAction(target_id, delta_time)
    if not self.ai_ids then return false end

    local battle_data = getGameData():getBattleDataMt()
    local target_obj = battle_data:getShipByGenID(target_id)

    if target_id == -1 then
        target_obj =  getGameData():getAutoTradeAIHandler()
    end
    if target_id == -2 then
        target_obj = battle_data
    end

    if not target_obj then return false end

    for _, ai_id in pairs(self.ai_ids) do
        target_obj:deleteAI(ai_id)
    end

    if battle_data:GetBattleSwitch() then
        battle_data:uploadAI(false, target_id, self.ai_ids)
    end
end

return ClsAIActionDelAI
