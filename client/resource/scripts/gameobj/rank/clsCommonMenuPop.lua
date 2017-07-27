local ClsCommonMenuPop = class("ClsCommonMenuPop", require("ui/view/clsBaseView"))
local music_info = require("game_config/music_info")

ClsCommonMenuPop.onEnter = function(self, params)
	self:setIsWidgetTouchFirst(true)

	self.params = params
	self:initUi()
	self:regTouch()
end

ClsCommonMenuPop.initUi = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile(self.params.json_path)
	self:addWidget(self.panel)

	for k, v in ipairs(self.params.widget_info or {}) do
		local item = getConvertChildByName(self.panel, v.name)
		item.name = v.name
		item:setPressedActionEnabled(true)
		item:setTouchEnabled(true)

		item:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:closeView()
			v.event(self, v.event_params)
		end, TOUCH_EVENT_ENDED)

		self[v.name] = item
	end
end

ClsCommonMenuPop.regTouch = function(self)
	self:regTouchEvent(self, function(event_type, x, y)
		if event_type == "began" then
			local pos_x, pos_y = self:getPosition()
			local size = self.panel:getContentSize()
			local touch_x = x - pos_x
			local touch_y = y - pos_y
			if touch_x > 0 and touch_y > 0 and touch_x < size.width and touch_y < size.height then
				return true
			else
				self:closeView()
				return false
			end
		end
	end)
end

ClsCommonMenuPop.closeView = function(self)
	self:close()
	if type(self.params.call_back) == "function" then
		self.params.call_back()
	end
end

return ClsCommonMenuPop