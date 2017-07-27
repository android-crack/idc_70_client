-- 长按钮

ButtonPressLong = class("ButtonPressLong", function()
	 return CCLayer:create()
end)

ButtonPressLong.ctor = function(self, item, touch_priority, touchTime, intervalTime, params)

	self.m_bEnabled = true
	self.m_eState = 0  --闲态
	self.m_pSelectedItem = nil
	self.touchContinuTime = touchTime or 0.05
	self.touchIntervalTime = intervalTime or 0.2
	if params then
		self.touchBeganScale = params.beganScale
		self.touchEndScale = params.endScale
	else
		self.touchBeganScale = 0.9
		self.touchEndScale = 1.0
	end
	if item then
		if type(item) == "table" then
			for k, v in pairs(item) do
				self:addChild(v, 0, v:getTag())
			end
		else
			self:addChild(item, 0, item:getTag())
		end
	end

	self:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
	self.hander_time = nil

	local touch_priority = touch_priority or -128
	self:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, touch_priority, true)
	self:setTouchEnabled(true)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.deltaTime = 0
	local function cdTime(dt)
		if self.maybeLongTouch then
			local currntTime = os.time()
			if (currntTime - self.beganTouchTime) > self.touchContinuTime then
				self.deltaTime = self.deltaTime + dt
				if self.deltaTime > self.touchIntervalTime then
					self.deltaTime = 0
					if self.selEvent then
						self.selEvent(self.m_pSelectedItem)
					end
				end
			end
		end
	end
	self.hander_time = scheduler:scheduleScriptFunc(cdTime, 0, false)
end

ButtonPressLong.onTouch = function(self, event, x, y)

	local pos = self:convertToNodeSpace(ccp(x,y))

	if event == "began" then
		return self:onTouchBegan(pos.x, pos.y)
	elseif event == "moved" then
		self:onTouchMoved(pos.x, pos.y)
	elseif event == "ended" then
		self:onTouchEnded(pos.x, pos.y)
	else -- cancelled
		self:onTouchCancelled(pos.x, pos.y)
	end
end

ButtonPressLong.setEnabled = function(self, value)
	if tolua.isnull(self) then return end
	self.m_bEnabled = value
end

ButtonPressLong.onTouchBegan = function(self, x, y)
	
	if self.m_eState ~= 0 or not self.m_bEnabled or not self:isVisible() then
		return false
	end
	local parent = self:getParent()
	while parent do
		if not parent:isVisible() then
			return false
		end
		parent = parent:getParent()
	end
	self.m_pSelectedItem = self:itemForTouch(x,y)
	if self.m_pSelectedItem then
		self.maybeLongTouch = true
		self.beganTouchTime = os.time()
		self.m_eState = 1
		self.m_pSelectedItem:setScale(self.touchBeganScale)
		if self.selEvent then
			self.selEvent(self.m_pSelectedItem)
		end
		
		return true
	end
	return false
end

ButtonPressLong.addSeletedEvent = function(self, func)
	self.selEvent = func
end

ButtonPressLong.addUnSeletedEvent = function(self, func)
	self.unSelectFunc = func
end

ButtonPressLong.addLongTouchEvent = function(self, func)
	self.longTouchEvent = func
end

ButtonPressLong.onTouchMoved = function(self, x, y)
	local currentItem = self:itemForTouch(x, y)
	if currentItem ~= self.m_pSelectedItem then
		if self.m_pSelectedItem then
			if self.unSelectFunc then
				self.unSelectFunc()
			end
			self.m_pSelectedItem:setScale(self.touchEndScale)
			self.m_pSelectedItem = nil
			self.maybeLongTouch = nil
		end
	end
end

ButtonPressLong.onTouchEnded = function(self, x, y)
	if self.m_pSelectedItem then
		if self.unSelectFunc then
			self.unSelectFunc()
		end
		self.m_pSelectedItem:setScale(self.touchEndScale)
		self.m_pSelectedItem = nil
	end
	self.beganTouchTime = 0
	self.maybeLongTouch = nil
	self.m_eState = 0
end

ButtonPressLong.onTouchCancelled = function(self, x, y)
	if self.m_pSelectedItem then
		
	end
	self.m_eState = 0
end

ButtonPressLong.itemForTouch = function(self, x, y)
	if tolua.isnull(self) then
		return
	end
	local children = self:getChildren()
	if tolua.isnull(children) then
		return
	end
	if children:count() > 0 then
		for i = 0, children:count() - 1 do
			local pChild = children:objectAtIndex(i)
			if not tolua.isnull(pChild) then
				pChild = tolua.cast(pChild, "CCNode")
				local size = pChild:getContentSize()
				local pChildX, pChildY = pChild:getPosition()
				local anChorPoint = pChild:getAnchorPoint()
				
				local touchRect = CCRectMake( pChildX - size.width * anChorPoint.x, pChildY - size.height * anChorPoint.y,
                      size.width, size.height)
				if touchRect:containsPoint(ccp(x,y)) then
					return pChild
				end
			end
		end
	end
end

ButtonPressLong.onExit = function(self)
	if self.hander_time then 
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
end


return ButtonPressLong


















