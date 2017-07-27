--
-- 购买结算，关闭界面
-- Author: chenlurong
-- Date: 2016-05-25 11:17:53
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeMarketBuy = class("ClsAIActionTradeMarketBuy", ClsAIActionBase) 

function ClsAIActionTradeMarketBuy:getId()
	return "trade_market_buy"
end


-- 初始化action
function ClsAIActionTradeMarketBuy:initAction()
	self.duration = 3000
	self.wait_rpc_store = true
	self.wait_rpc_cargo = true
end

function ClsAIActionTradeMarketBuy:__beginAction( target, delta_time )
	local port_market_ui = getUIManager():get("ClsPortMarket")
	if not tolua.isnull(port_market_ui) then
   		port_market_ui:okFunc()
    end
    
    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    auto_trade_data:askTeamMemeberTrade()

    RegTrigger(EVENT_PORT_MARKET_PORT_STORE,function(stores)
        self.wait_rpc_store = false
        UnRegTrigger(EVENT_PORT_MARKET_PORT_STORE)
    end)

    RegTrigger(EVENT_PORT_MARKET_PORT_CARGO,function(cargos)
        self.wait_rpc_cargo = false
        UnRegTrigger(EVENT_PORT_MARKET_PORT_CARGO)
    end)
    auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeMarketBuy:__beginAction")
	-- print("ClsAIActionTradeMarketBuy:__beginAction: to close market ")
end

function ClsAIActionTradeMarketBuy:__dealAction( target, delta_time )
	-- print("ClsAIActionTradeMarketBuy:__beginAction: to close market ", delta_time)
	return (self.wait_rpc_store or self.wait_rpc_cargo)
end

function ClsAIActionTradeMarketBuy:dispos()
	UnRegTrigger(EVENT_PORT_MARKET_PORT_CARGO)
	UnRegTrigger(EVENT_PORT_MARKET_PORT_STORE)
end

return ClsAIActionTradeMarketBuy