--
-- Author: Ltian
-- Date: 2017-01-10 14:25:11
--
--
-- Author: Ltian
-- Date: 2017-01-09 15:35:07
--
--
local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")

local ClsNotRenameTips = class("ClsNotRenameTips", ClsBaseView)

function ClsNotRenameTips:getViewConfig()
    return {
        type = UI_TYPE.TIP,   
        effect = UI_EFFECT.SCALE,
        is_back_bg =  true, 
    }
end

function ClsNotRenameTips:onEnter(remain_time)

	self.remain_time = remain_time or 0
	self:mkUI()
end

local widget_name = {
	"btn_close",
	"panel_cannot",
	"panel_rename",
	"cd_num",	
}
local touch_rect = CCRect(display.cx - 210, display.cy - 130, 420, 260)
function ClsNotRenameTips:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_rename.json")
	self.panel:setPosition(ccp(display.cx - 210, display.cy - 130))
	self:addWidget(self.panel)
	
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	local _, time_tab = ClsDataTools:getMostCnTimeStr(self.remain_time)
	table.print(time_tab)
	local show_time_str = ""
	if time_tab.d >0 then
		show_time_str = time_tab.d.."d"
	elseif time_tab.h > 0 then
		show_time_str = string.format("%2dh%2dm", time_tab.h, time_tab.m)
	else
		show_time_str = string.format("%2dm%2ds", time_tab.m, time_tab.s)
	end
	self.cd_num:setText(show_time_str)
	self.panel_cannot:setVisible(true)
	self.panel_rename:setVisible(false)
	self:regTouchEvent(self, function(eventType, x, y)	
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if is_in then return end
		self:close()
	end)
	
	--关闭
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		self:close()
	end, TOUCH_EVENT_ENDED)



end


function ClsNotRenameTips:onExit()
end



return ClsNotRenameTips