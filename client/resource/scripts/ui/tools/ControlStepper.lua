--  Stepper button

local ui = require "base.ui.ui"

local function newUILayer()
	local layer = CCLayer:create()
	 require("framework.api.EventProtocol").extend(layer)
	 return layer
end

local ControlStepper = class("ControlStepper", newUILayer)

ControlStepper.ctor = function(self, item)  
	
	local image_bg = item.image_bg
	self.bg = display.newSprite(image_bg)  --底座,显示数值
	self:addChild(self.bg)
	self.size = self.bg:getContentSize()
	local x = item.x or 0
	local y = item.y or 0
	self.bg:setPosition(ccp(x, y))
	
	if item.image_dec then
		self.btn_dec = display.newSprite(item.image_dec)
		self.btn_dec:setAnchorPoint(ccp(1,0.5))
		local x = item.decX or-5
		local y = item.decY or self.size.height/2
		self.btn_dec:setPosition(ccp(x,y))
		self.bg:addChild(self.btn_dec)
	end
	
	if item.image_add then
		self.btn_add = display.newSprite(item.image_add)
		self.btn_add:setAnchorPoint(ccp(0,0.5))
		local x = item.decX or self.size.width+5
		local y = item.decY or self.size.height/2
		self.btn_add:setPosition(ccp(x,y))
		self.bg:addChild(self.btn_add)
	end
	
	self.value = 0
	self.minValue = 0   --最小/大值 
	self.maxValue = 100
	self.step = 1
	self.autoRepeatOff = 12  --大于后快速自动
	
	self.scheduler=CCDirector:sharedDirector():getScheduler()
	
	self.label_value = ui.newTTFLabel({text = tostring(self.value), size = 20, color = ccc3(0,0,0),x = self.size.width/2, y = self.size.height/2 })
	self.bg:addChild(self.label_value)
	
	self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)

    self:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y) end)
	self:setTouchEnabled(true)
end

ControlStepper.setRange = function(self, minNum, maxNum, step)  --设置范围
	if minNum then 
		self.minValue = minNum
	end
	if maxNum then 
		self.maxValue = maxNum
	end
	if step and step > 0 then 
		self.step = step -- 步长 ，默认是1
	end 
end 

ControlStepper.updateText = function(self)  --更新
	self.label_value:setString(tostring(self.value))
	self:dispatchEvent({name = "TURN_CALL"})
end 

ControlStepper.setMinValue = function(self) --最大值
	self.value = self.minValue
	self:updateText()
end

ControlStepper.setMaxValue = function(self) --最小值
	self.value = self.maxValue
	self:updateText()
end 

ControlStepper.setValue = function(self, num)
	self.value = num
	self:updateText()
end 

ControlStepper.getValue = function(self)
	return self.value
end 

ControlStepper.addNum = function(self)
	local tmp = self.value + self.step
	if tmp <= self.maxValue then 
		self.value = tmp
		self:updateText()
	end
end

ControlStepper.decNum = function(self)
	local tmp = self.value - self.step
	if tmp >= self.minValue then 
		self.value = tmp
		self:updateText()
	end
end

ControlStepper.onTouch = function(self, event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
    elseif event == "moved" then
		self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    end
end

ControlStepper.doStep = function(self, dt)
	self.autoRepeatCount = self.autoRepeatCount + 1	
	if self.autoRepeatCount < self.autoRepeatOff and (math.mod(self.autoRepeatCount , 3) ~= 0) then
		return 
	end 
	if self.type == 1 then 
		self:decNum()
	elseif self.type == 2 then
		self:addNum()
	end
end

ControlStepper.onTouchBegan = function(self, x, y)
	local touchPoint = self.bg:convertToNodeSpace(ccp(x,y))  --把世界坐标转当前坐标系	
	self.autoRepeatCount = 0
	if self.btn_dec:boundingBox():containsPoint(touchPoint) then --减
		self.btn_dec:setColor(ccc3(200,200,200))
		self.type = 1
		self:decNum()
		self.hander_time = self.scheduler:scheduleScriptFunc(function() self:doStep() end, 0.1, false)
		return true
	elseif self.btn_add:boundingBox():containsPoint(touchPoint) then --加
		self.btn_add:setColor(ccc3(200,200,200))
		self.type = 2
		self:addNum()
		self.hander_time = self.scheduler:scheduleScriptFunc(function() self:doStep() end, 0.1, false)
		return true 
	end
	return false
end

ControlStepper.onTouchMoved = function(self, x, y)
	local touchPoint = self.bg:convertToNodeSpace(ccp(x,y))
	if not(self.btn_dec:boundingBox():containsPoint(touchPoint) and self.type == 1) and 
		not(self.btn_add:boundingBox():containsPoint(touchPoint) and self.type == 2) then
		self:onRecover()
	end 	
end

ControlStepper.onTouchEnded = function(self, x, y)
	self:onRecover()
end

ControlStepper.onRecover = function(self)
	if self.type == 1 then
		self.btn_dec:setColor(ccc3(255,255,255))
	elseif self.type == 2 then
		self.btn_add:setColor(ccc3(255,255,255))
	end
	if self.hander_time then
		self.scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
	self.type = nil
end

ControlStepper.regCallBack = function(self, listener)
	self:addEventListener("TURN_CALL", function() end)
end


ControlStepper.onExit = function(self)
	self:removeAllEventListeners()
	if self.hander_time then
		self.scheduler:unscheduleScriptEntry(self.hander_time)
	end
end

return ControlStepper