-- 进度条 按照编辑器那边的， 进度条有4种，ProgressBar, ProgressBarLabel 、ProgressBarMask、ProgressBarMaskLabel
-- 由于项目需要，目前只对  ProgressBar 进度条增加了扇形的支持

module("ui_ext", package.seeall)


---------------- ProgressBar------------------
ProgressBar = class("ProgressBar",function()
    return display.newNode()
end)

ProgressBar.ctor = function(self,itemParams) 
	
	local x = itemParams.x or 0
	local y = itemParams.y or 0
	if itemParams.imagebg then 
		self.bg = display.newSprite(itemParams.imagebg)
		self.bg:setAnchorPoint(ccp(0,1))  --适应搜神编辑器坐标从左上开始
		self:addChild(self.bg)
	end
	self.pross = ui.newProgressTimer(itemParams)
	self.pross:setAnchorPoint(ccp(0,1))
	self:addChild(self.pross)
	self:setPosition(ccp(x,y))
	
	if itemParams.width and itemParams.width > 0 then 
		local pwidth = self.pross:getContentSize().width
		self:setScaleX(itemParams.width/pwidth) 
	end
end

ProgressBar.setPercentage = function(self,fPercentage)
	self.pross:setPercentage(fPercentage)
end

ProgressBar.getPercentage = function(self)
	return self.pross:getPercentage()
end

--为了支持点击，给node加个背景的大小，然后重新调整子孩子的位置
ProgressBar.resetSize = function(self) 
	self:setContentSize(self.bg:getContentSize())
	self.bg:setPositionY(self:getContentSize().height)
	self.pross:setPositionY(self:getContentSize().height)	
end

ProgressBar.runAction = function(self,...)
	self.pross:runAction(...)
end


----------------------------------------------



---------------- ProgressBarLabel ------------------

ProgressBarLabel = class("ProgressBarLabel",function()
    return display.newNode()
end)

ProgressBarLabel.ctor = function(self,itemParams,labelParams) 
	
	local x = itemParams.x or 0
	local y = itemParams.y or 0
	if itemParams.imagebg then 
		self.bg = display.newSprite(itemParams.imagebg)
		self.bg:setAnchorPoint(ccp(0,1))  --适应搜神编辑器坐标从左上开始
		self:addChild(self.bg)
	end
	self.pross = ui.newProgressTimer(itemParams)
	self.pross:setAnchorPoint(ccp(0,1))
	self:addChild(self.pross) 
	self:setPosition(ccp(x,y))
	
	if itemParams.width and itemParams.width > 0 then 
		local pwidth = self.pross:getContentSize().width
		self.bg:setScaleX(itemParams.width/pwidth) 
		self.pross:setScaleX(itemParams.width/pwidth)
	end
	
	if labelParams then 
		self.label = ui_ext.Label.new(labelParams)
		self.label:setAnchorPoint(ccp(0,1))
		local ory = self.label:getPositionY()
		self.label:setPositionY(-ory)
		self:addChild(self.label)
	end
		
end

ProgressBarLabel.setPercentage = function(self,fPercentage)
	self.pross:setPercentage(fPercentage)
end

ProgressBarLabel.getPercentage = function(self)
	return self.pross:getPercentage()
end

ProgressBarLabel.setString = function(self, text)
	if self.label then
		self.label:setString(text)
	end
end

ProgressBarLabel.getString = function(self)
	if self.label then
		return self.label:getString()
	else 
		return ""
	end
end

ProgressBarLabel.runAction = function(self,...)
	self.pross:runAction(...)
end

---------------------------------------------------

---------------- ProgressBarMask ------------------
ProgressBarMask = class("ProgressBarMask",function()
    return display.newNode()
end)

ProgressBarMask.ctor = function(self,itemParams) 
	 
	local x = itemParams.x or 0
	local y = itemParams.y or 0
	if itemParams.imagebg then 
		self.bg = display.newSprite(itemParams.imagebg)
		self.bg:setAnchorPoint(ccp(0,1))  --适应搜神编辑器坐标从左上开始
		self:addChild(self.bg)
	end
	self.pross = ui.newProgressTimer(itemParams)
	self.pross:setAnchorPoint(ccp(0,1))
	self:addChild(self.pross)
	self:setPosition(ccp(x,y))
end

ProgressBarMask.setPercentage = function(self,fPercentage)
	self.pross:setPercentage(fPercentage)
end

ProgressBarMask.getPercentage = function(self)
	return self.pross:getPercentage()
end

ProgressBarMask.runAction = function(self,...)
	self.pross:runAction(...)
end
----------------------------------------------

---------------- ProgressBarMaskLabel ------------------
ProgressBarMaskLabel = class("ProgressBarMaskLabel",function()
    return display.newNode()
end)

ProgressBarMaskLabel.ctor = function(self, itemParams, labelParams) 
	
	local x = itemParams.x or 0
	local y = itemParams.y or 0
	if itemParams.imagebg then 
		self.bg = display.newSprite(itemParams.imagebg)
		self.bg:setAnchorPoint(ccp(0,1))  --适应搜神编辑器坐标从左上开始
		self:addChild(self.bg)
	end
	self.pross = ui.newProgressTimer(itemParams)
	self.pross:setAnchorPoint(ccp(0,1))
	self:addChild(self.pross)
	self:setPosition(ccp(x,y))
	
	if labelParams then 
		self.label = ui_ext.Label.new(labelParams)
		self.label:setAnchorPoint(ccp(0,1))
		self:addChild(self.label)
	end
end

ProgressBarMaskLabel.setPercentage = function(self,fPercentage)
	self.pross:setPercentage(fPercentage)
end

ProgressBarMaskLabel.getPercentage = function(self)
	return self.pross:getPercentage()
end

ProgressBarMaskLabel.setString = function(self, text)
	if self.label then
		self.label:setString(text)
	end
end

ProgressBarMaskLabel.getString = function(self)
	if self.label then
		return self.label:getString()
	else 
		return ""
	end
end

ProgressBarMaskLabel.runAction = function(self,...)
	self.pross:runAction(...)
end
----------------------------------------------

























