--
-- Author: Ltian
-- Date: 2016-06-13 11:06:36
--
local ClsCreateTips = class("ClsCreateTips", function() return display.newLayer() end)

function ClsCreateTips:ctor()
	self:mkUi()
end
local btn_name = {
	"btn_team",
	"btn_set",
	"btn_cancel",
	"btn_bg_team",
	"btn_free",
}
function ClsCreateTips:mkUi()
	self.ui_layer = UILayer:create()
	self.ui_layer:setTouchPriority(TOUCH_PRIORITY_GOD - 1)

	self:addChild(self.ui_layer)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_team.json")
	self.ui_layer:addWidget(self.panel)
	self:registerScriptTouchHandler(function(eventType, x, y) 
		self:removeFromParentAndCleanup(true)
	end, false, TOUCH_PRIORITY_GOD, true)
	self:setTouchEnabled(true)
	self.btn_bg = getConvertChildByName(self.panel, "btn_bg")
	for i,v in ipairs(btn_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
end

function ClsCreateTips:regBtnCB()
	-- body
end
return ClsCreateTips