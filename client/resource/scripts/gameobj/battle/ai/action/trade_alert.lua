--
-- Author: Your Name
-- Date: 2016-05-24 19:16:09
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAITradeAlert = class("ClsAITradeAlert", ClsAIActionBase) 

function ClsAITradeAlert:getId()
	return "trade_alert"
end

-- 
function ClsAITradeAlert:initAction( msg )
	self.msg = msg;						-- AIID
end

function ClsAITradeAlert:__dealAction( target_id, delta_time )
	local Alert = require("ui/tools/alert")
	Alert:warning({msg =self.msg})
	
	--print("ClsAITradeAlert:__dealAction:", self.msg)

	return false
end

return ClsAITradeAlert