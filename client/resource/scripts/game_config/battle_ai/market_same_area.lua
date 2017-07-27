----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_same_area = class("ClsAIMarket_same_area", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_same_area:getId()
	return "market_same_area";
end


-- AI时机
function ClsAIMarket_same_area:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndMarket_same_area(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 目标海域ID==当前海域ID
	if ( not (getGameData():getAutoTradeAIHandler():getTargetArea()==getGameData():getAutoTradeAIHandler():getCurArea()) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIMarket_same_area:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndMarket_same_area(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"market_sail", }, }, }, 
}

function ClsAIMarket_same_area:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_same_area:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_same_area

----------------------- Auto Genrate End   --------------------
