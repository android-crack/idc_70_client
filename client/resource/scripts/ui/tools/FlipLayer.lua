------翻牌效果层---------


FlipLayer = class("FlipLayer",function()
    return display.newLayer()
end)

FlipLayer.ctor = function(self,itemParams, noShowBtn)
	self.isMoved = false
	local x    = itemParams.x or 0
	local y    = itemParams.y or 0
	self.size  = itemParams.size or CCSize(0,0)
	self.flipY = itemParams.flipY or false  --是否Y轴翻转，默认X轴
	
	if itemParams.image then 
		self.bg = display.newSprite(string.format("#%s.png",itemParams.image))
		self.size = self.bg:getContentSize()
		self.bg:setPosition(ccp(self.size.width/2, self.size.height/2))
		self:addChild(self.bg)
	end
	if itemParams.image2 then 
		self.bg2 = display.newSprite(string.format("#%s.png",itemParams.image2))
		self.size = self.bg2:getContentSize()
		self.bg2:setPosition(ccp(self.size.width/2, self.size.height/2))
		self:addChild(self.bg2)
	end
	
	if itemParams.info then   --信息类东西，不会翻动
		self:addChild(itemParams.info)
	end
	
	if itemParams.info2 then
		self:addChild(itemParams.info2)
	end

	self.touchRect = CCRect(self:getPositionX(),self:getPositionY(),self.size.width, self.size.height)
	
	self.isface = true  --正面
	
	self.sprite1 = itemParams.node1
	self.sprite2 = itemParams.node2
	
	self.sprite1:setPosition(ccp(self.size.width/2, self.size.height/2))
	self.sprite2:setPosition(ccp(self.size.width/2, self.size.height/2))
	self:addChild(self.sprite1)
	self:addChild(self.sprite2)
	self.sprite2:setScaleX(0)

	local btnX = self.size.width - 10
	local btnY = self.size.height - 2
	
	self.btn = display.newSprite("#btn_info.png", btnX, btnY)
	self.btn:setAnchorPoint(ccp(1,1))
	self:addChild(self.btn)
	if noShowBtn == true then
		self.btn:setOpacity(0)
	end

	self:setContentSize(self.size)
	self:setPosition(ccp(x,y))
	
	self:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y)
    end, false, -1, true)
end

FlipLayer.callBack = function(self)
	local scale1 = CCScaleTo:create(0.2, 0, 1.0)
	if self.flipY then
		scale1 = CCScaleTo:create(0.2, 1.0, 0)
	end
	
	local function changeTexture()
		local scale2 = CCScaleTo:create(0.2, 1.0, 1.0)
		if self.isface then 
			self.sprite1:runAction(scale2)
			self.btn:setVisible(true)
		else 
			self.sprite2:runAction(scale2)
			self.btn:setVisible(false)
		end
	end
	
	local call_back= CCCallFunc:create(changeTexture)
	
	if self.isface then  --当前是正面
		self.isface = false
		self.sprite1:runAction(CCSequence:createWithTwoActions(scale1,call_back))	
	else
		self.isface = true
		self.sprite2:runAction(CCSequence:createWithTwoActions(scale1,call_back))	
	end
end

FlipLayer.isFace = function(self)  -- ture 为正面
	return self.isface
end

FlipLayer.onTouch = function(self, event, x, y)  -- 响应
	local touchPoint = self:convertToNodeSpace(ccp(x,y))
	if event == "began" then 
		if self.isface and self.btn:boundingBox():containsPoint(touchPoint) then
			self:callBack()
		elseif not self.isface and self.touchRect:containsPoint(touchPoint)  then
			self:callBack()
		end	
	end
	
end

FlipLayer.updateFace = function(self)
	if not self.isface then
		self:callBack()
	end
end

FlipLayer.setFaceback = function(self)
	if not self.isface then
		self:callBack()
	end
	self.isface = true
end