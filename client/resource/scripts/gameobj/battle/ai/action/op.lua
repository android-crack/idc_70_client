
-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionOp = class("ClsAIActionOp", ClsAIActionBase) 

function ClsAIActionOp:getId()
	return "op"
end

-- 
function ClsAIActionOp:initAction(func)
	self.func = func 
end

function ClsAIActionOp:__dealAction(target, delta_time)
	local ai_obj = self:getOwnerAI()
	self.func(ai_obj, self, target, delta_time )
end

return ClsAIActionOp
