
--红点提示系统
local on_off_info=require("game_config/on_off_info")

KIND_CIRCLE = 1  --主界面的圆形
KIND_RECTANGLE = 2  --普通的长方形
KIND_LONG_RECTANGLE = 3 --长 普通的长方形
KIND_ROOM_NAME = 4 --任命的名字上

local TaskData = class("TaskData")

function TaskData:ctor()
	self.tasks = {}      --玩家可以做的事情
end 

function TaskData:regTask(button, taskKeys, buttonKind, buttonKey, tEffectX, tEffectY, isUIWidget)  --按钮,按钮所属开关,按钮形状,按钮开关
	--    print("注册玩家做的东西的按钮特效------------->",buttonKey)
	button.tasks = button.tasks or {} --按钮的任务是累加的
	for k,taskKey in pairs(taskKeys) do
		self.tasks[taskKey] = self.tasks[taskKey] or {
			state = false,
			buttons = {},
		} --表示taskKey这个任务没有开启，它控制着buttons的所有按钮
		self.tasks[taskKey].buttons[buttonKey] = button
		button.tasks[taskKey] = taskKey
	end

	if tolua.isnull(button.taskEffect) then
		if buttonKind == KIND_RECTANGLE then
			tEffectX = tEffectX or 50
			tEffectY = tEffectY or 17
			button.taskEffect = display.newSprite("#common_red_dot.png",tEffectX,tEffectY)
		elseif buttonKind == KIND_LONG_RECTANGLE then
			tEffectX = tEffectX or 72
			tEffectY = tEffectY or 24
			button.taskEffect = display.newSprite("#common_red_dot.png",tEffectX,tEffectY)
		elseif buttonKind == KIND_CIRCLE then
			tEffectX = tEffectX or 19
			tEffectY = tEffectY or 19
			button.taskEffect = display.newSprite("#common_red_dot.png",tEffectX,tEffectY)
		elseif buttonKind == KIND_ROOM_NAME then
			tEffectX = tEffectX or 158
			tEffectY = tEffectY or 78
			button.taskEffect = display.newSprite("#common_red_dot.png",tEffectX,tEffectY)
		end

		if isUIWidget then
			button:addRenderer(button.taskEffect,TOPEST_ZORDER+1)
		else
			button:addChild(button.taskEffect,TOPEST_ZORDER+1)
		end
	end

	--港口主界面的东西而添加的判断
	-- local enabled = true
	-- if type(button.isEnabled) == "function" then
	--     if type(button.isTouchEnabled) == "function" then
	--         enabled = button:isEnabled() and button:isTouchEnabled()
	--     else
	--         enabled = button:isEnabled()
	--     end
	-- end
	local onOffData = getGameData():getOnOffData()
	if onOffData:isOpen(buttonKey) then
		button.taskEffect:setVisible(self:judgeOpenAllTask(button.tasks))
	else
		button.taskEffect:setVisible(false)
	end
end

RED_POINT_KEY = on_off_info.RED_POINT.value
function TaskData:judgeOpenTask(taskKey)
	local sailorData = getGameData():getSailorData()
	local onOffData = getGameData():getOnOffData()
	if onOffData:isOpen(RED_POINT_KEY) and self.tasks[taskKey] and self.tasks[taskKey].state and onOffData:isOpen(taskKey) then
		return true
	end

	return false
end

--判断某些任务中是否有开启的
function TaskData:judgeOpenAllTask(taskKeys)
	for k, taskKey in pairs(taskKeys) do
		if self:judgeOpenTask(taskKey) then
			return true
		end
	end
	return false
end

function TaskData:setTask(taskKey, state, is_from_svr) --设置某个能做的事情
	if not is_from_svr and not state then
		if self.tasks[taskKey] and self.tasks[taskKey].state then
			GameUtil.callRpc("rpc_server_red_point_clear", {taskKey})
		end
	end
	if not self.tasks[taskKey] then --界面还没有创建的时候，该任务Key已经有所改变
		self.tasks[taskKey] = {
			state = state,
			buttons = {},
		}
	elseif self.tasks[taskKey].state == state then
		return
	else
		self.tasks[taskKey].state = state
	end

	local onOffData = getGameData():getOnOffData()
	if not onOffData:isOpen(taskKey) then
		return
	end

	self:onOffEffect(taskKey)
end

function TaskData:getTaskState(taskKey)
	if self.tasks[taskKey] then
		return self.tasks[taskKey].state
	end
	return false
end

function TaskData:onOffEffect(taskKey)
	-- if taskKey == test_key then
	--     print(debug.traceback())
	-- end
	if not self.tasks[taskKey] then return end
	local sailorData = getGameData():getSailorData()
	local onOffData = getGameData():getOnOffData()
	if self:judgeOpenTask(taskKey) then
		--if taskKey == test_key then
			--print("=========================TaskData:onOffEffect  1111")
		--end
		for k, button in pairs(self.tasks[taskKey].buttons) do
			--if taskKey == test_key then
				--print("=========================TaskData:onOffEffect  button", tostring(button))
			--end
			if not tolua.isnull(button) and not tolua.isnull(button.taskEffect) then
				button.taskEffect:setVisible(onOffData:isOpen(k))
				--if taskKey == test_key then
					--print("=========================TaskData:onOffEffect  22222", onOffData:isOpen(k))
				--end
			end
		end
	else
		--if taskKey == test_key then
			--print("=========================TaskData:onOffEffect  5555")
		--end
		for k, button in pairs(self.tasks[taskKey].buttons) do
			if not tolua.isnull(button) and not tolua.isnull(button.taskEffect) and button.taskEffect:isVisible() then
				if not onOffData:isOpen(k) then
					button.taskEffect:setVisible(false)
				elseif not self:judgeOpenAllTask(button.tasks) then --判断按钮的所有任务中是否有开启的，如果全部没有则不可见
					button.taskEffect:setVisible(false)
				end
			end
		end
	end
end

function TaskData:onOffAllEffect()
	for taskKey, task in pairs(self.tasks) do
		self:onOffEffect(taskKey)
	end
end

return TaskData