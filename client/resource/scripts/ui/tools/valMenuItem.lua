--valMenuItem是一个可以修改前置图片的菜单项，它本身具有一个背景图片。
local valMenuItem = class("valMenuItem", function(params)
		return ui.newImageMenuItem(params)		
	end)

valMenuItem.ctor = function (self, params)
	self.valImage = nil
	self.valImageRes = nil
end

valMenuItem.setValImage = function(self, res)
	if self.valImage ~= nil then 
		self.valImage:removeFromParentAndCleanup(true)
	end
	local containerVal
	if type(res) == "string" then
		containerVal = display.newSprite(res, self:getContentSize().width/2, self:getContentSize().height/2)
		self.valImageRes = res
	elseif type(res) == "userdata" then
		containerVal = display.newSpriteWithFrame(res, self:getContentSize().width/2, self:getContentSize().height/2)
	end
	self:addChild(containerVal)
	self.valImage = containerVal
end


valMenuItem.getValImageRes = function(self)
	return self.valImageRes
end

valMenuItem.getValImage = function(self)
	return self.valImage
end

return valMenuItem