----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_sail = class("ClsAIMarket_sail", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_sail:getId()
	return "market_sail";
end


-- AI时机
function ClsAIMarket_sail:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"trade_move", "", {}, }, 
	{"run_ai", "", {{"market_judge_goods", }, }, }, 
}

function ClsAIMarket_sail:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_sail:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_sail

----------------------- Auto Genrate End   --------------------
