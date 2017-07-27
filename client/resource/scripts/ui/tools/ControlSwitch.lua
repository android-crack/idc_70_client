-- 开关按钮，不同于引擎提供
local ui_word = require("scripts/game_config/ui_word")
local function newUILayer()
	local layer = CCLayer:create()
	 require("framework.api.EventProtocol").extend(layer)
	 return layer
end

local ControlSwitch = class("ControlSwitch", newUILayer)

ControlSwitch.ctor = function(self, item)  
	local x = item.x or 0
	local y = item.y or 0
	local scale=item.scale or 1

	local image_bg = item.image_bg
	self.bg = display.newSprite(image_bg)  --底座
	self:addChild(self.bg)
	self.size = self.bg:getContentSize()
	self.bg:setPosition(ccp(x, y))
	
	self.onLabel = createBMFont({text = ui_word.SYS_OPEN,fontFile=FONT_COMMON,color = ccc3(dexToColor3B(COLOR_BROWN)), size = 16, x = self.size.width*0.28, y = self.size.height*0.5})
	self.bg:addChild(self.onLabel)
	
	self.offLabel = createBMFont({text =ui_word.SYS_CLOSE,fontFile=FONT_COMMON,color = ccc3(dexToColor3B(COLOR_BROWN)), size = 16, x = self.size.width*0.72, y = self.size.height*0.5})
	self.bg:addChild(self.offLabel)
	
	-- btn
	self.onButton = display.newSprite("#common_btn_blue1.png")
	self.onButton:setScale(SMALL_BUTTON_SCALE)
	self.btn_size = self.onButton:getContentSize()
	self.offButton=newQtzGraySprite("#common_btn_blue1.png",self.btn_size.width/2,self.btn_size.height/2)
	self.onButton:addChild(self.offButton)

	self.bg:addChild(self.onButton)
	local offX = item.offX or 40 --滑块偏移量
	local offY = item.offY or 0
	
	self.isON = true  --初始是开启状态
	self.isTouchEnable = true
	self.minX = offX + self.btn_size.width/2-3
	self.maxX = self.size.width - offX - self.btn_size.width/2 +3 --最大滑动位置
	self.minY = offY +9
	self.touchRect = CCRect(0, offY, self.size.width, self.size.height-2*offY)
	self.moveRect = CCRect(self.minX, self.minY, self.size.width - 2*offX - self.btn_size.width, self.size.height-2*offY )
	self.drog = (self.maxX - self.minX)/2
	self.touchMinX = offX
	self.touchMaxX = self.size.width-offX
	self.onButton:setPosition(ccp(self.maxX, self.minY))
	
	self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    self:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y) end)
	self:setTouchEnabled(true)
end

ControlSwitch.setContentOffset = function(self, offX)
	self.isTouchEnable = false
	if self.isON then  --开启状态
		local action = CCMoveTo:create(offX/self.size.width * 0.5, ccp(self.maxX, self.minY))
		local callFun = CCCallFuncN:create(function() 
			self.isTouchEnable = true
			self.offButton:setVisible(true)
	    end)
		local seq = CCSequence:createWithTwoActions(action, callFun)
		self.onButton:runAction(seq)
	else
		local action = CCMoveTo:create(offX/self.size.width * 0.5, ccp(self.minX, self.minY))
		local callFun = CCCallFuncN:create(function() 
			self.isTouchEnable = true 
			self.offButton:setVisible(false)
		end)
		local seq = CCSequence:createWithTwoActions(action, callFun)
		self.onButton:runAction(seq)
	end
	
end

ControlSwitch.isOn = function(self)
	return self.isON
end

ControlSwitch.setOn = function(self, isOn)
	if isOn ~= self.isON then	
		self.isON = isOn
		if isOn then  --开启
			self.onButton:setPosition(ccp(self.maxX, self.minY))
			self.offButton:setVisible(true)
		else
			self.onButton:setPosition(ccp(self.minX, self.minY))
			self.offButton:setVisible(false)
		end
		self:dispatchEvent({name = "TURN_CALL"})
	end
end

ControlSwitch.onTouch = function(self, event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
    elseif event == "moved" then
		self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    end
end

ControlSwitch.onTouchBegan = function(self, x, y)
	local touchPoint = self.bg:convertToNodeSpace(ccp(x,y))  --把世界坐标转当前坐标系
	if self.isTouchEnable and self.touchRect:containsPoint(touchPoint) then
		self.startPoint = touchPoint
		self.lastPoint = touchPoint 
		self.onButton:setColor(ccc3(200,200,200))
		self.isClick = true
		return true
	end
	return false
end

ControlSwitch.onTouchMoved = function(self, x, y)
	local touchPoint = self.bg:convertToNodeSpace(ccp(x,y))
	if touchPoint.x < self.touchMinX or touchPoint.x > self.touchMaxX then
		return 
	end
	if self.startPoint.x ~= touchPoint.x then self.isClick = false end
	local btnX = self.onButton:getPositionX()
	local dx = btnX + touchPoint.x - self.lastPoint.x
	
	if dx< self.minX then
		dx = self.minX
	elseif dx > self.maxX then
		dx = self.maxX
	else 
		self.lastPoint = touchPoint
	end	
	self.onButton:setPositionX(dx)
end

ControlSwitch.onTouchEnded = function(self, x, y)
	
	local touchPoint = self.lastPoint 
	self.onButton:setColor(ccc3(255,255,255))
	local offX = math.abs(touchPoint.x - self.startPoint.x)
	if self.isClick or math.abs(touchPoint.x - self.startPoint.x)>= self.drog then
		self.turn = true
	end
	
	if self.turn then
		self.turn = false	
		if self.isON then 
			self.isON = false
		else 
			self.isON = true 
		end
		offX = self.drog*2 - offX
		self:dispatchEvent({name = "TURN_CALL"})
	end
	self:setContentOffset(math.abs(offX))
end

ControlSwitch.checkPos = function(self, x)
	if x >= self.minX and x <= self.maxX then
		return true
	end
	return false
end

ControlSwitch.regCallBack = function(self, listener)
	self:addEventListener("TURN_CALL", listener)
end


ControlSwitch.onEnter = function(self)

end

ControlSwitch.onExit = function(self)
	self:removeAllEventListeners()
end

return ControlSwitch