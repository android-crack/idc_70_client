--任务绿字事件
local ui_word = require("game_config/ui_word")
local touchEventForMis = require("gameobj/mission/touchEventForMis")
local RichlabelElementCallbackMis = class("RichlabelElementCallbackMis", function(param)
	return display.newSprite()
end)

local EVENT_TYPE = 1--事件类型的index,其余的是参数
function RichlabelElementCallbackMis:ctor(param)
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

function RichlabelElementCallbackMis:init()
	if nil == self.show_lab then
		local label = createBMFont({text = self.text, size = self.font_size, fontFile = self.font, color = ccc3(dexToColor3B(self.color))})
		self.show_lab = label
	end

	local label_size = self.show_lab:getContentSize()
	local x = label_size.width / 2
	local y = label_size.height / 2
	local item = require("ui/view/clsViewButton").new({labelNode = self.show_lab, x = x, y = y + self.show_lab:getStrokeSize() / 2})
	item.last_time = 0
	item:regCallBack(function()
		if CCTime:getmillistimeofCocos2d() - item.last_time < 500 then return end
		item.last_time = CCTime:getmillistimeofCocos2d()
		
		local event_type = self.key[EVENT_TYPE]
		local temp = {}
		for k, v in ipairs(self.key) do
			if k ~= EVENT_TYPE then
				table.insert(temp, v)
			end
		end
		touchEventForMis.touchEvent[event_type](unpack(temp))
	end)
	self:addChild(item)
	
	self.m_richlabel:regTouchEvent(item, function(...) return item:onTouch(...) end)
end

function RichlabelElementCallbackMis:getContentSize()
	return self.show_lab:getContentSize()
end

function RichlabelElementCallbackMis:getText()
	return self.text
end

function RichlabelElementCallbackMis:getTextColor()
	return self.color
end

function RichlabelElementCallbackMis:setTextColor(new_color)
	if new_color and self.show_lab then
		local parseString = require("ui/tools/richlabel/parse_string")
		new_color = parseString.getColorNum(new_color)
		self.color = new_color
		self.show_lab:setColor(ccc3(dexToColor3B(new_color)))
	end
end
	
return RichlabelElementCallbackMis