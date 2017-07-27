----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_diff_area = class("ClsAIMarket_diff_area", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_diff_area:getId()
	return "market_diff_area";
end


-- AI时机
function ClsAIMarket_diff_area:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndMarket_diff_area(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 目标海域ID~=当前海域ID
	if ( not (getGameData():getAutoTradeAIHandler():getTargetArea()~=getGameData():getAutoTradeAIHandler():getCurArea()) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIMarket_diff_area:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndMarket_diff_area(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[变量值=变量值*(-1)]
local function market_diff_area_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local change_value = getGameData():getAutoTradeAIHandler():getData("_change_value") or 1;

	-- 公式原文:变量值=变量值*(-1)
	getGameData():getAutoTradeAIHandler():setData("_change_value", change_value*(-1));

end

-- [备注]设置-[目标港口ID=当前港口ID+变量值]
local function market_diff_area_act_1( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {market_diff_area_act_0, }, }, 
	{"op", "", {market_diff_area_act_1, }, }, 
	{"run_ai", "", {{"market_sail", }, }, }, 
}

function ClsAIMarket_diff_area:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_diff_area:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_diff_area

----------------------- Auto Genrate End   --------------------
