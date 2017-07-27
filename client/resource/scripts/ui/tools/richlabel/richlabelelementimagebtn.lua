local ClsRichLabelElementImageBtn = class("ClsRichLabelElementImageBtn", function(param)
	return display.newSprite()
end)

function ClsRichLabelElementImageBtn:ctor(param)
	self.type = param.type
	self.btn_scale = param.btn_scale or 1
	self.params = param.params
	self.touch_callback = nil
	self.menu_item_btn = param.btn
	self.m_richlabel = param.richlabel
    self:init()
end

function ClsRichLabelElementImageBtn:init()
    self.menu_item_btn:regCallBack(function()
		if self.touch_callback then
			self.touch_callback(self.params)
		end
	end)
	self:addChild(self.menu_item_btn)
	local size = self.menu_item_btn:getContentSize()
	self.menu_item_btn:setPosition(ccp(size.width * 0.5, size.height * 0.5))
	self:setScale(self.btn_scale)
	
	self.m_richlabel:regTouchEvent(self.menu_item_btn, function(...) return self.menu_item_btn:onTouch(...) end)
end

function ClsRichLabelElementImageBtn:getType()
	return self.type
end

function ClsRichLabelElementImageBtn:setCallback(callback)
	self.touch_callback = callback
end

return ClsRichLabelElementImageBtn