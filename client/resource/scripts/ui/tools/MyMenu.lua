--  重写menu,实现按钮效果

MyMenu = class("MyMenu", function()
	return CCLayer:create()
end)

MyMenu.ctor = function(self, item, touch_priority, touch_rect)
	self.m_bEnabled = true
	self.m_eState = 0  --闲态
	self.m_pSelectedItem = nil
	self.touch_rect = touch_rect
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
	
	local touch_priority = touch_priority or TOUCH_PRIORITY_BTN
	self:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, touch_priority, true)
	self:setTouchEnabled(true)
end

MyMenu.setMenuPriority = function(self, touch_priority)
	self:setTouchEnabled(false)
	self:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, touch_priority, true)
	self:setTouchEnabled(true)
end

MyMenu.addItem = function(self, item)
	if item then
		if type(item) == "table" then
			for k, v in pairs(item) do
				self:addChild(v, 0, v:getTag())
			end
		else
			self:addChild(item, 0, item:getTag())
		end
	end
end 

MyMenu.isEnabled = function(self)
	return self.m_bEnabled
end

MyMenu.setEnabled = function(self, value)
	self.m_bEnabled = value
end

MyMenu.setCheckCanGetTouchFunc = function(self, can_touch_func)
    self.can_touch_func = can_touch_func
end

MyMenu.onTouch = function(self, event, x, y)
    if self.can_touch_func then
        local result_b = self.can_touch_func(x, y)
        if not result_b then
            return false
        end
    end

    if self.touch_rect then
		if not self.touch_rect:containsPoint(ccp(x, y)) then
			return false
		end
	end

	if not tolua.isnull(self.cameraProvider) then
		local cx, cy, cz = self.cameraProvider:getCamera():getEyeXYZ(0,0,0)
		x = x + cx*self.cameraProvider:getScale()
		y = y + cy*self.cameraProvider:getScale()
	elseif self.camera ~= nil then
		local cx, cy, cz = self.camera:getEyeXYZ(0,0,0)
		x = x + cx
		y = y + cy
	end

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

MyMenu.clickItemIsRunMostFuncTouchEvent = function(self, obj)
	return (type(obj.getNotRunMostFuncEvent) == "function" and obj:getNotRunMostFuncEvent())
end

MyMenu.onTouchBegan = function(self, x, y)
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
		if not self:clickItemIsRunMostFuncTouchEvent(self.m_pSelectedItem) then
			self.m_pSelectedItem:selected()
		end
		self.m_eState = 1
		return true
	end
	return false
end

MyMenu.onTouchMoved = function(self, x, y)
	local currentItem = self:itemForTouch(x, y)
	if currentItem ~= self.m_pSelectedItem then
		if self.m_pSelectedItem and not self:clickItemIsRunMostFuncTouchEvent(self.m_pSelectedItem) then
			self.m_pSelectedItem:unselected()
			self.m_pSelectedItem = nil
		end
	end
end

MyMenu.onTouchEnded = function(self, x, y)
	if self.m_pSelectedItem then
		if not self:clickItemIsRunMostFuncTouchEvent(self.m_pSelectedItem) then
			self.m_pSelectedItem:unselected()
			self.m_pSelectedItem:activate()
		else
			self.m_pSelectedItem:activeNonAcceptTouchEventCallBack()
		end
	end
	self.m_eState = 0
end

MyMenu.onTouchCancelled = function(self, x, y)
	if self.m_pSelectedItem then
		self.m_pSelectedItem:unselected()
	end
	self.m_eState = 0
end

local function judgeIsEnter(pChild)
	if pChild and type(pChild.isVisible) == "function" and pChild:isVisible() and type(pChild.isEnabled) == "function" and pChild:isEnabled() then
		return true
	end
	return false
end

MyMenu.itemForTouch = function(self, x, y)
	local children = self:getChildren()
	if not children then
		return
	end
	if children:count() > 0 then
		for i = 0, children:count() - 1 do
			local pChild = children:objectAtIndex(i)
			if judgeIsEnter(pChild) then
				if type(pChild.touchRect)=="function" then
					local tf = pChild:touchRect()
					if pChild:touchRect():containsPoint(ccp(x,y)) then
						if self.touchUnEffectScope then
							local worldPos = self:convertToWorldSpace(ccp(x,y))
							if not self.touchUnEffectScope:containsPoint(worldPos) then
								return pChild
							end
						else
							return pChild
						end
					end
				end
			end
		end
	end
end

MyMenu.setTouchUnEffectScope = function(self,rect)
	self.touchUnEffectScope = rect
end

MyMenu.getTouchUnEffectScope = function(self)
	return self.touchUnEffectScope
end

MyMenu.onExit = function(self)
	self.cameraProvider = nil
	self.camera = nil
end


















