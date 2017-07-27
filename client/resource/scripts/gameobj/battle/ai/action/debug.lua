
-- 延时动作，啥也不做型
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDebug = class("ClsAIActionDebug", ClsAIActionBase) 

function ClsAIActionDebug:getId()
	return "debug"
end

-- 
function ClsAIActionDebug:initAction(msg)
	self.msg = msg
end

function ClsAIActionDebug:__dealAction(target, delta_time)
	print("ACTION_DEBUG:", self.msg)
end

return ClsAIActionDebug
