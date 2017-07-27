--普通文本
local ClsRichLabelElementText = class("ClsRichLabelElementText", function(param)
	return display.newSprite()
end)

function ClsRichLabelElementText:ctor(param)
	self.text = param.text
	self.type = param.type
	self.color = param.color
	
	self.show_lab = param.label_node
	if nil == self.show_lab then
		self.show_lab = createBMFont({text = param.text, color = color, fontFile = param.font, size = param.size, color = ccc3(dexToColor3B(param.color))})
	end
	self.show_lab:setPosition(ccp(0, self.show_lab:getStrokeSize()/2))
	self.show_lab:setAnchorPoint(ccp(0,0))
	self:addChild(self.show_lab)
end

function ClsRichLabelElementText:getText()
	return self.text
end

function ClsRichLabelElementText:getType()
	return self.type
end

function ClsRichLabelElementText:getTrueWidth()
	return self.show_lab:getContentSize().width
end

function ClsRichLabelElementText:getContentSize()
	return self.show_lab:getContentSize()
end

function ClsRichLabelElementText:getTextColor()
	return self.color
end

function ClsRichLabelElementText:setTextColor(new_color)
	if new_color then
		local parseString = require("ui/tools/richlabel/parse_string")
		new_color = parseString.getColorNum(new_color)
		self.color = new_color
		self.show_lab:setColor(ccc3(dexToColor3B(new_color)))
	end
end

return ClsRichLabelElementText