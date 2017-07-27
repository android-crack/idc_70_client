----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMarket_goods_more = class("ClsAIMarket_goods_more", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMarket_goods_more:getId()
	return "market_goods_more";
end


-- AI时机
function ClsAIMarket_goods_more:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndMarket_goods_more(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 港口存货>0
	if ( not (getGameData():getAutoTradeAIHandler():getPortGoodsNum()>0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIMarket_goods_more:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndMarket_goods_more(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"trade_open_market", "", {}, }, 
	{"delay", "", {500, }, }, 
	{"trade_market_one_key", "", {}, }, 
	{"trade_market_buy", "", {}, }, 
	{"run_ai", "", {{"market_set_port", }, }, }, 
}

function ClsAIMarket_goods_more:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMarket_goods_more:getAllTargetMethod()
	return all_target_method
end

return ClsAIMarket_goods_more

----------------------- Auto Genrate End   --------------------
