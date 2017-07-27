
-- 会计师操作，一键操作，自动购买
-- Author: chenlurong
-- Date: 2016-05-24 18:16:32
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeMarketOneKey = class("ClsAIActionTradeMarketOneKey", ClsAIActionBase) 

function ClsAIActionTradeMarketOneKey:getId()
	return "trade_market_one_key"
end


-- 初始化action
function ClsAIActionTradeMarketOneKey:initAction()
	self.duration = 4000
end

function ClsAIActionTradeMarketOneKey:__beginAction( target, delta_time )
	local market_data = getGameData():getMarketData()
    market_data:oneKeySell(true)
    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeMarketOneKey:__beginAction")
	-- print("ClsAIActionTradeMarketOneKey:__beginAction: to one Key Sell")
end

function ClsAIActionTradeMarketOneKey:__dealAction( target, delta_time )
	-- print("ClsAIActionTradeMarketOneKey:__dealAction", delta_time)
	return true
end


return ClsAIActionTradeMarketOneKey