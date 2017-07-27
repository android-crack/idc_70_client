-- 出海后进入进港
-- Author: chenlurong
-- Date: 2016-05-25 17:04:36
--

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeEnterPort = class("ClsAIActionTradeEnterPort", ClsAIActionBase) 

function ClsAIActionTradeEnterPort:getId()
	return "trade_enter_port"
end


-- 初始化action
function ClsAIActionTradeEnterPort:initAction()
	self.duration = 50000
	local market_data = getGameData():getMarketData()
	self.port_id = market_data:getAutoTradePordId()
	self.wait_to_port = true
end

local function exploreToPort(self, port_id)
		
end

function ClsAIActionTradeEnterPort:__beginAction( target, delta_time )
	EventTrigger(EVENT_EXPLORE_QUICK_ENTER_PORT, self.port_id)

	RegTrigger(EVENT_ENTER_PORT, function()
		self.wait_to_port = false
		UnRegTrigger(EVENT_ENTER_PORT, EVNET_TAG_TRADE_ENTER_PORT)
	end, EVNET_TAG_TRADE_ENTER_PORT)

	-- print("ClsAIActionTradeEnterPort:__beginAction: to EnterPort ", self.port_id)
end

function ClsAIActionTradeEnterPort:__dealAction( target, delta_time )
	return self.wait_to_port
end

function ClsAIActionTradeEnterPort:dispos()
	UnRegTrigger(EVENT_ENTER_PORT, EVNET_TAG_TRADE_ENTER_PORT)
end

return ClsAIActionTradeEnterPort
