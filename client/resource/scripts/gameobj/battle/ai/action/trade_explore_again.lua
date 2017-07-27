-- 重新出海
-- Author: chenlurong
-- Date: 2016-09-08 17:32:32
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeExploreAgain = class("ClsAIActionTradeExploreAgain", ClsAIActionBase) 

function ClsAIActionTradeExploreAgain:getId()
	return "trade_explore_again"
end


-- 初始化action
function ClsAIActionTradeExploreAgain:initAction()
	self.duration = 99999999
end

local function requireExploreAgain()
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:goOutPort(nil, EXPLORE_NAV_TYPE_NONE)
end

function ClsAIActionTradeExploreAgain:__beginAction( target, delta_time )
	RegTrigger(EVENT_ENTER_PORT, function()
		UnRegTrigger(EVENT_ENTER_PORT, EVNET_TAG_TRADE_ENTER_PORT)
		requireExploreAgain()
	end, EVNET_TAG_TRADE_ENTER_PORT)

	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeExploreAgain:__beginAction: re explore")
	-- print("ClsAIActionTradeExploreAgain:__beginAction: to explore ")
end

function ClsAIActionTradeExploreAgain:__dealAction( target, delta_time )
	-- print("============== ClsAIActionTradeExploreAgain:__beginAction: to explore ", delta_time )
	local explore_ui = getUIManager():get("ExploreLayer")
	if not tolua.isnull(explore_ui) then
		-- if not IS_AUTO then
		-- 	local auto_trade_data = getGameData():getAutoTradeAIHandler()
		-- 	goal_port_id = auto_trade_data:getTargetPort()
		-- 	if goal_port_id then
		-- 		-- print("============== ClsAIActionTradeExploreAgain:__beginAction: to explore 是在海上哦", goal_port_id)
		-- 		EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = goal_port_id, navType = EXPLORE_NAV_TYPE_PORT})
		-- 	end
		-- end
		return false
	end
	return true
end


return ClsAIActionTradeExploreAgain