-- cocos2d-x Button 扩展支持图片、文字同时存在
-- 为了方便操作，这里每一个button 都用一个CCMenu 来生成

module("ui_ext", package.seeall)

ui = require "base.ui.ui"

Button = class("Button",function()
    return CCMenu:create()
end)

Button.ctor = function(self,itemParams,labelParams) -- 第3个参数为文字信息
	
	local px = itemParams.x
	local py = itemParams.y
	self.item = ui.newImageMenuItem(itemParams)
	self.item:setAnchorPoint(ccp(0,1))
	self.item:setPosition(ccp(0,0))
	
	--按钮缩放
	local image_size = self.item:getContentSize()
	local xscale, yscale
	xscale = itemParams.width / image_size.width
	yscale = itemParams.height / image_size.height
	
	if 0~=xscale then -- 0 表示没有缩放
		self.item:setScaleX( xscale )
	end
	if 0~=yscale then
		self.item:setScaleY( yscale )
	end
	
	
	if labelParams then
		self.label= ui.newTTFLabel(labelParams)
		self.item:addChild(self.label)	
		local size = self.item:getContentSize()
		local x = size.width/2
		local y = size.height/2
		self.label:setPosition(ccp(x,y))
		
		--label会受到父节点的影响，但label实际不需要缩放，需要恢复到原来的缩放比率
		if 0~=xscale then 
			self.label:setScaleX( 1/xscale )
		end
		if 0~=yscale then
			self.label:setScaleY( 1/yscale )
		end		
	
	end
	self:addChild(self.item)
	self:setPosition(ccp(px,py))
end

Button.registerCallback = function(self,listener)
	if type(listener) == "function" then
        self.item:registerScriptTapHandler(function(tag)
            listener(tag)
        end)
    end
end

Button.setString = function(self, text)
	if self.label then
		self.label:setString(text)
	end
end

Button.getString = function(self)
	if self.label then
		return self.label:getString()
	else 
		return ""
	end
end

Button.setFontSize = function(self,fontSize)
	if self.label then
		self.label:setFontSize(fontSize)
	end
end

Button.getFontSize = function(self)
	if self.label then
		return self.label:getFontSize()
	else
		return nil
	end
end
    
Button.setEnabled = function(self, value)
	self.item:setEnabled(value)
end
	
Button.isEnabled = function(self)
	return self.item:isEnabled()
end
	