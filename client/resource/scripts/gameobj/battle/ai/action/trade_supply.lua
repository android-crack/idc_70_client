-- 重新出海
-- Author: chenlurong
-- Date: 2016-09-08 17:32:32
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeSupply = class("ClsAIActionTradeSupply", ClsAIActionBase) 

function ClsAIActionTradeSupply:getId()
	return "trade_supply"
end


-- 初始化action
function ClsAIActionTradeSupply:initAction()
	self.duration = 500
end

function ClsAIActionTradeSupply:__beginAction( target, delta_time )
	-- print("ClsAIActionTradeSupply:__beginAction: to explore ")
	local supplyData = getGameData():getSupplyData()
	supplyData:askSupplyFull()

	local auto_trade_data = getGameData():getAutoTradeAIHandler()
    auto_trade_data:askTeamMemeberTrade()
    auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeSupply:__beginAction")
end

function ClsAIActionTradeSupply:__dealAction( target, delta_time )
	-- print("============== ClsAIActionTradeSupply:__beginAction: to explore ", delta_time )
	return true
end


return ClsAIActionTradeSupply