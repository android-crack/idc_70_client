----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_set_port = class("ClsAIMarket_set_port", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_set_port:getId()
	return "market_set_port";
end


-- AI时机
function ClsAIMarket_set_port:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[目标港口ID=当前港口ID+变量值]
local function market_set_port_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local change_value = getGameData():getAutoTradeAIHandler():getData("_change_value") or 1;

	-- 公式原文:目标港口ID=当前港口ID+变量值
	getGameData():getAutoTradeAIHandler().target_port = getGameData():getAutoTradeAIHandler():getCurPortId()+change_value;

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {market_set_port_act_0, }, }, 
	{"run_ai", "", {{"market_judge_area", }, }, }, 
}

function ClsAIMarket_set_port:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_set_port:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_set_port

----------------------- Auto Genrate End   --------------------
