--
-- 主页活动开放时间tip
--

local ClsBaseView  = require("ui/view/clsBaseView")

local ClsFestivalPortUITips = class("ClsFestivalPortUITips", ClsBaseView)

local JSON_URL              = "json/main_activity_dw.json"

local TIP_POS				= ccp(228, 430)

function ClsFestivalPortUITips:getViewConfig()
	return {
		["is_swallow"] = false
	}
end

function ClsFestivalPortUITips:onEnter()
	local txt_panel = GUIReader:shareReader():widgetFromJsonFile(JSON_URL);
	convertUIType(txt_panel);
	self:addWidget(txt_panel)

	self:regTouchEvent(self, function(event, x, y)
		if event =="began" then 
			self:close()
		end
	end)

	self:setPosition(TIP_POS)
end

return ClsFestivalPortUITips