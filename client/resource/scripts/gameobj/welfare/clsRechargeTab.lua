-- 充值福利界面
-- Author: Ltian
-- Date: 2016-07-04 15:00:12
--

local clsRechargeTab = class("clsRechargeTab", function() return display.newLayer() end)
function clsRechargeTab:ctor()
	self:regFunc()
	self:mkUI()
end

function clsRechargeTab:mkUI()
	self.ui_layer = UILayer:create()
	self:addChild(self.ui_layer)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_recharge.json")
	convertUIType(self.panel)
	self.ui_layer:addWidget(self.panel)
end

function clsRechargeTab:regFunc()
	self:registerScriptHandler(function(event)
		if event == "exit" then self:onExit() end
	end)
end

function clsRechargeTab:onExit()
	-- body
end
return clsRechargeTab