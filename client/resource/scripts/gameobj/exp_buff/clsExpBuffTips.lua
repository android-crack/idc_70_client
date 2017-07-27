--
-- Author: Ltian
-- Date: 2016-12-23 16:11:11
--
local ClsBaseView = require("ui/view/clsBaseView")
local expbuff_data = require("game_config/exp_buff/expbuff_data")
local ui_word = require("game_config/ui_word")
local ClsExpBuffTips = class("ClsExpBuffTips", ClsBaseView)

function ClsExpBuffTips:getViewConfig()
    return {
        name = "ClsExpBuffTips",
        type = UI_TYPE.TIP,    
        effect = UI_EFFECT.SCALE,  
    }
end

function ClsExpBuffTips:onEnter(is_power)
	self.is_power = is_power
	self:mkUI()
end

local widget_name = {
	"buff_tips",
	"buff_name"
}
function ClsExpBuffTips:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/main_buff.json")
	self:setPosition(ccp(display.cx, display.cy - 78))

	local pos = ccp(-260, 200)
	if self.is_power then
		pos = ccp(-100, 200)
	end
	self.m_view_root_spr:setPosition(pos)

	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:regTouchEvent(self, function(eventType, x, y)	
		self:close()
	end)
	local status = getGameData():getPlayerData():getExpBuffStatus()
	local status_info = expbuff_data[status]
	local tips = ""
	local name = ""
	if self.is_power then
		tips = ui_word.MAIN_PORT_POWER_TIPS
		name = ui_word.GET_TILI_TIPS
	else
		tips = status_info.tips
		name = status_info.name	
	end

	self.buff_tips:setText(tips)
	self.buff_name:setText(name)

end


function ClsExpBuffTips:onExit()
end

return ClsExpBuffTips