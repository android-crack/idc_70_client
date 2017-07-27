
-- 延时动作，啥也不做型
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDelay = class("ClsAIActionDelay", ClsAIActionBase) 

function ClsAIActionDelay:getId()
	return "delay"
end


-- 初始化action
function ClsAIActionDelay:initAction(delay_time)
	self.duration = delay_time
end

return ClsAIActionDelay
