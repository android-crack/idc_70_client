--
-- Author: Ltian
-- Date: 2016-12-23 17:03:42
--
--
-- Author: Ltian
-- Date: 2016-12-23 16:11:11
--
local ClsBaseView = require("ui/view/clsBaseView")
local expbuff_data = require("game_config/exp_buff/expbuff_data")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")

local ClsExpBuffAlert = class("ClsExpBuffAlert", ClsBaseView)

function ClsExpBuffAlert:getViewConfig()
    return {
        name = "ClsExpBuffAlert",
        is_back_bg = true,
        type = UI_TYPE.TIP,   
        effect = UI_EFFECT.SCALE, 
    }
end

function ClsExpBuffAlert:onEnter()
	self:mkUI()
end

local widget_name = {
	"buff_txt_1",
	"btn_middle",
	"btn_close",
	"buff_end",
	"buff_begin"
}
touch_rect = CCRect(display.cx - 210, display.cy - 130, 420, 260)
function ClsExpBuffAlert:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_buff.json")
	self.panel:setPosition(ccp(display.cx - 210, display.cy - 130))
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:regTouchEvent(self, function(eventType, x, y)	
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if is_in then return end
		self:close()
	end)
	local status = getGameData():getPlayerData():getExpBuffStatus()
	status = status or 0
	getGameData():getPlayerData():setOldExpBuff(status)
	if status and status > 0 then --有海神buff
		local status_info = expbuff_data[status]
		self.buff_txt_1:setText(status_info.tips)
		self.buff_end:setVisible(false)
		self.buff_begin:setVisible(true)
	
	else
		self.buff_end:setVisible(true)
		self.buff_begin:setVisible(false)
	end
	
	self.btn_middle:setPressedActionEnabled(true)
	self.btn_middle:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
	
end


function ClsExpBuffAlert:onExit()
end

return ClsExpBuffAlert