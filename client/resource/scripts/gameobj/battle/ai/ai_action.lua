local ClsAIAction = class("ClsAIAction")

function ClsAIAction:ctor(ownerAI, targets, ...)
	self.ownerAI = ownerAI

	-- 构建Action运行时长,默认为0
	-- 持续时间为0的，会立即结束
	self.duration = 0

	self.data = {}

	self:initAction( ... )

	self.running_targets = {}

	self.targets = targets

	self:initRunningTargets()
end

function ClsAIAction:getId()
	return "ai_action_base"
end

-- 初始化action
function ClsAIAction:initAction(...)
end

-- 选择好目标
function ClsAIAction:initRunningTargets()
	-- 目标选择
	if not self.targets then return end
	if #self.targets < 1 then return end

	-- 初始化目标运行数据
	for _, target in ipairs(self.targets) do
		-- 目标在场
		self.running_targets[target] = {} 
		local tb_tmp = self.running_targets[target]

		tb_tmp.duration = 0

		-- 调用__beginAction
		self:__beginAction(target)
	end
end

function ClsAIAction:__beginAction(target)
end

-- 针对单个目标需要做的事情
function ClsAIAction:__dealAction(target, delta_time)
	-- 如果返回false表示，此目标执行本动作完毕
	return true
end

-- 针对单个目标动作
function ClsAIAction:dealAction(target, delta_time)
	local tb_tmp = self.running_targets[target]
	
	if not tb_tmp then return end

	tb_tmp.duration = tb_tmp.duration + delta_time

	-- 真实的处理
	local deal_result = self:__dealAction(target, delta_time)

	if not deal_result or tb_tmp.duration >= self.duration then
		self:__endAction(target)
		-- 清空运行
		self.running_targets[target] = nil
	end
end

function ClsAIAction:__endAction(target)
end

function ClsAIAction:getOwnerAI()
	return self.ownerAI
end

function ClsAIAction:getTargets()
	return self.targets
end

function ClsAIAction:setData(key, value)
	self.data[key] = value
end

function ClsAIAction:getData(key)
	return self.data[key]
end

function ClsAIAction:heartBeat(dt)
	local ownerAI = self:getOwnerAI()

	if not self.running_targets then
		ownerAI:completeAction(self)
		return
	end

	for target, _ in pairs(self.running_targets) do
		self:dealAction(target, dt)	
	end

	if table.nums(self.running_targets) <= 0 then
		ownerAI:completeAction(self)
	end
end

return ClsAIAction
