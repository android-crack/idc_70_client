-- 触摸遮罩层

local ClsTMLayer = class("ClsTMLayer", function() return CCLayer:create() end)

function ClsTMLayer:ctor(item)
	local item = item or {}
	self.touch_priority = item.touch_priority or -129
	self.touch_rect = item.touch_rect or nil  -- 可点击的范围
	self.mask_function = item.mask_function   -- 点击 touch_rect范围外的处理函数
	
	self:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y) 
	end, false, self.touch_priority, true)
	self:setTouchEnabled(true)
end 

function ClsTMLayer:onTouch(event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	end
end

function ClsTMLayer:onTouchBegan(x, y)
	if self.touch_rect and self.touch_rect:containsPoint(ccp(x, y))then 
		return false
	end 
	
	if self.mask_function then 
		self.mask_function()
	end 
	
	return true
end 

return ClsTMLayer