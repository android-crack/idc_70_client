
local ClsAIBase = require("gameobj/battle/ai/ai_base")
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionRunAI = class("ClsAIActionRunAI", ClsAIActionBase)

function ClsAIActionRunAI:getId()
	return "run_ai"
end

--
function ClsAIActionRunAI:initAction(ai_ids)
	self.ai_ids = ai_ids
end

function ClsAIActionRunAI:__dealAction(target, delta_time)

    local battleData = getGameData():getBattleDataMt()

    local target_obj = battleData:getShipByGenID(target)
    local target_type = AI_OWNER_TYPE.FIGHT_SHIP

    if ( target == -1) then
        target_obj =  getGameData():getAutoTradeAIHandler()
        target_type = AI_OWNER_TYPE.AUTO_TRADE
    end
    if ( target == -2) then
        target_obj = battleData
        target_type = AI_OWNER_TYPE.SCENE
    end

    if ( not target_obj ) then return false end

    for _, ai_id in pairs(self.ai_ids) do
        local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, ai_id )
        local ClsAI = require(clazz_name)
        local aiObj = ClsAI.new({}, target_obj, target_type)

        local res = aiObj:tryRun(AI_OPPORTUNITY.RUN)
    end

    return true
end

return ClsAIActionRunAI
