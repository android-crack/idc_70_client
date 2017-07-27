local ClsRichlabelElementCallbackText = class("RichlabelElementCallbackText", function(param)
	return display.newSprite()
end)

function ClsRichlabelElementCallbackText:ctor(param)
	self.text = param.text
	self.params = param.params
	self.type = param.type
	self.key = param.key
	self.font = param.font or FONT_CFG_1
	self.font_size = param.size or 14
	self.color = param.color
	self.touch_callback = nil
	self.show_lab = param.label_node
	self.m_richlabel = param.richlabel
	self:init()
end

function ClsRichlabelElementCallbackText:init()
	if nil == self.show_lab then
		local label = createBMFont({text = self.text, size = self.font_size, fontFile = self.font, color = ccc3(dexToColor3B(self.color))})
		self.show_lab = label
	end
	local label_size = self.show_lab:getContentSize()
	local item = require("ui/view/clsViewButton").new({labelNode = self.show_lab, x = label_size.width/2, y = label_size.height/2 + self.show_lab:getStrokeSize()/2})
	item:regCallBack(function()
		if self.touch_callback then
			self.touch_callback()
		end
	end)
	self:addChild(item)
	self.m_richlabel:regTouchEvent(item, function(...) return item:onTouch(...) end)
end

function ClsRichlabelElementCallbackText:getContentSize()
	return self.show_lab:getContentSize()
end

function ClsRichlabelElementCallbackText:setCallback(callback)
	self.touch_callback = callback
end

function ClsRichlabelElementCallbackText:touchCallback()
end

function ClsRichlabelElementCallbackText:getText()
	return self.text
end

function ClsRichlabelElementCallbackText:getType()
	return self.type
end

function ClsRichlabelElementCallbackText:getKey()
	return self.key
end

function ClsRichlabelElementCallbackText:getTextColor()
	return self.color
end

function ClsRichlabelElementCallbackText:setTextColor(new_color)
	if new_color and self.show_lab then
		local parseString = require("ui/tools/richlabel/parse_string")
		new_color = parseString.getColorNum(new_color)
		self.color = new_color
		self.show_lab:setColor(ccc3(dexToColor3B(new_color)))
	end
end
	
return ClsRichlabelElementCallbackText