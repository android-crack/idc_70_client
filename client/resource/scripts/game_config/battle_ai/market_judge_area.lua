----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_judge_area = class("ClsAIMarket_judge_area", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_judge_area:getId()
	return "market_judge_area";
end


-- AI时机
function ClsAIMarket_judge_area:getOpportunity()
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
	{"run_ai", "", {{"market_same_area", }, }, }, 
	{"run_ai", "", {{"market_diff_area", }, }, }, 
}

function ClsAIMarket_judge_area:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_judge_area:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_judge_area

----------------------- Auto Genrate End   --------------------
