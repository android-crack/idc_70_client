----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_battle_end = class("ClsAIMarket_battle_end", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_battle_end:getId()
	return "market_battle_end";
end


-- AI时机
function ClsAIMarket_battle_end:getOpportunity()
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
	{"trade_explore_again", "", {}, }, 
	{"run_ai", "", {{"market_set_port", }, }, }, 
}

function ClsAIMarket_battle_end:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_battle_end:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_battle_end

----------------------- Auto Genrate End   --------------------
