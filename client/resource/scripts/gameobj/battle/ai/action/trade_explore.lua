-- 出海
-- Author: chenlurong
-- Date: 2016-05-25 16:02:32
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeExplore = class("ClsAIActionTradeExplore", ClsAIActionBase) 

function ClsAIActionTradeExplore:getId()
	return "trade_explore"
end


-- 初始化action
function ClsAIActionTradeExplore:initAction()
	self.duration = 99999999
end

function ClsAIActionTradeExplore:__beginAction( target, delta_time )
	if isExplore then
	else
		local mapAttrs = getGameData():getWorldMapAttrsData()
		mapAttrs:goOutPort(nil, EXPLORE_NAV_TYPE_NONE)
	end
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeExplore:__beginAction: to explore")
	-- print("ClsAIActionTradeExplore:__beginAction: to explore ", goal_port_id)
end

function ClsAIActionTradeExplore:__dealAction( target, delta_time )
	-- print("============== ClsAIActionTradeExplore:__beginAction: to explore ", delta_time )
	if isExplore then
		-- if not IS_AUTO then
		-- 	local market_data = getGameData():getMarketData()
		-- 	local goal_port_id = market_data:getAutoTradePordId()
		-- 	if goal_port_id then
		-- 		EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = goal_port_id, navType = EXPLORE_NAV_TYPE_PORT})
		-- 	end
		-- end
		return false
	end
	return true
end


return ClsAIActionTradeExplore