--探索视野对象
local ExploreObject  = class("ExploreObject")

ExploreObject.VALID_DISTANCE = 2 * display.width    -- 离船的最远有效距离

function ExploreObject:ctor()
	self.key = "none"
	self.is_active = true
	self.is_pause = false
	self.is_in_field = false
	self.pos = ccp(0, 0)
	self.dead_call_back = nil

	self.node = CCNode:create()
	self.node:setPosition(self.pos)
	
	local off_distance = 200
	self.in_field_distance = self.VALID_DISTANCE - off_distance
	self.out_field_distance = self.VALID_DISTANCE + off_distance

	self.node:registerScriptHandler(function(event)
		if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
	end)
end

function ExploreObject:getInFieldDistance()
	return self.in_field_distance
end 

function ExploreObject:getOutFieldDistance()
	return self.out_field_distance
end 

function ExploreObject:getNode()
	return self.node
end

--是否可以进入视野
function ExploreObject:canInField(ship_distance)
	return true
end

--进入视野
function ExploreObject:onInField()
	if not self.is_in_field then
		self.is_in_field = true
		self:inFieldInit()
	end
end

--进入视野初始化
function ExploreObject:inFieldInit()
	
end

--是否可以离开视野
function ExploreObject:canOutField(ship_distance)
	return true
end

--离开视野
function ExploreObject:onOutField()
	if self.is_in_field then
		self.is_in_field = false
		self:outFieldClear()
	end
end

--离开视野清除
function ExploreObject:outFieldClear()
	
end

--是否可以帧更新
function ExploreObject:canUpdate()
	if not self.is_active or self.is_pause or not self.is_in_field then
		return false
	end
	return true
end

--帧更新
function ExploreObject:onUpdate(dt)
	
end

--是否可以更新UI
function ExploreObject:canUpdateUI()
	if not self.is_active or not self.is_in_field then
		return false
	end
	return true
end

--更新UI
function ExploreObject:updateUI()
	
end

function ExploreObject:setPause(is_pause)
	self.is_pause = is_pause
end

function ExploreObject:setDeadCallBack(call_back)
	self.dead_call_back = call_back
end

function ExploreObject:isInField()
	return self.is_in_field
end

function ExploreObject:isPause()
	return self.is_pause
end

function ExploreObject:isActive()
	return self.is_active
end

--将要激活的对象，默认都为true。需要的在子类实现
function ExploreObject:isWillActive()
	return true
end 

function ExploreObject:onEnter()

end

function ExploreObject:onExit()
	self.is_active = false
	self.node = nil
	if self.dead_call_back ~= nil then
		self.dead_call_back(self.key)
	end
end

return ExploreObject
