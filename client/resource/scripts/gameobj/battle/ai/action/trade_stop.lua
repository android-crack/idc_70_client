-- 停止自动经商
-- Author: chenlurong
-- Date: 2016-05-25 19:04:16
--

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeStop = class("ClsAIActionTradeStop", ClsAIActionBase) 

function ClsAIActionTradeStop:getId()
	return "trade_stop"
end


-- 初始化action
function ClsAIActionTradeStop:initAction()
	
end

function ClsAIActionTradeStop:__beginAction( target, delta_time )
	local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, SYS_CLEAR)
    local ClsAI = require(clazz_name)

    local obj = getGameData():getAutoTradeAIHandler()

    local aiObj = ClsAI.new({}, obj) 
    aiObj:tryRun(AI_OPPORTUNITY.RUN)

    obj:stopTradeAI()
end

function ClsAIActionTradeStop:__dealAction( target, delta_time )
	return (self.wait_rpc_store or self.wait_rpc_cargo)
end


return ClsAIActionTradeStop
