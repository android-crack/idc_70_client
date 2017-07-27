-- 文字图片

module("ui_ext", package.seeall)


ImageLabel = class("ImageLabel",function()
    return display.newNode()
end)

ImageLabel.ctor = function(self,itemParams,labelParams) 
	
	local x = itemParams.x
	local y = itemParams.y
	 
	self.bg = display.newSprite(itemParams.image)
	self.bg:setAnchorPoint(ccp(0,1))  --适应搜神编辑器坐标从左上开始
	self:addChild(self.bg)
	
	if itemParams.width then 
		local pwidth = self.bg:getContentSize().width
		self.bg:setScaleX(itemParams.width/pwidth) 
	end
	
	if itemParams.height then 
		local pheight = self.bg:getContentSize().height
		self.bg:setScaleY(itemParams.height/pheight) 
	end
	
	if labelParams then 
		self.label = ui_ext.Label.new(labelParams)
		
		if labelParams.align == "left" then
			self.label:setAnchorPoint(ccp(0,0.5))
		elseif labelParams.align == "center" then
			self.label:setAnchorPoint(ccp(0.5,0.5))
		elseif labelParams.align == "right" then
			self.label:setAnchorPoint(ccp(1,0.5))
        end			
				
		local ory = self.label:getPositionY()
		self.label:setPositionY(-ory)
		self:addChild(self.label)
	end
	
	self:setPosition(ccp(x,y))	
end

ImageLabel.setString = function(self, text)
	if self.label then
		self.label:setString(text)
	end
end

ImageLabel.getString = function(self)
	if self.label then
		return self.label:getString()
	else 
		return ""
	end
end



