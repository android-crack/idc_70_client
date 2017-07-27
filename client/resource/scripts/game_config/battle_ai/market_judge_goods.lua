----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_judge_goods = class("ClsAIMarket_judge_goods", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_judge_goods:getId()
	return "market_judge_goods";
end


-- AI时机
function ClsAIMarket_judge_goods:getOpportunity()
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
	{"run_ai", "", {{"market_goods_more", }, }, }, 
	{"run_ai", "", {{"market_goods_less", }, }, }, 
}

function ClsAIMarket_judge_goods:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_judge_goods:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_judge_goods

----------------------- Auto Genrate End   --------------------
