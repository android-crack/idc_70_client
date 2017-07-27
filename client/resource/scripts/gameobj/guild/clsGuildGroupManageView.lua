--
-- Author: Ltian
-- Date: 2017-01-04 14:32:22
--

local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local music_info = require("scripts/game_config/music_info")

local ClsGuildGroupManageView = class("ClsGuildGroupManageView", ClsBaseView)

function ClsGuildGroupManageView:getViewConfig()
    return {
        name = "ClsGuildGroupManageView",
        type = UI_TYPE.TIPS,   
        effect = UI_EFFECT.SCALE, 
        is_back_bg = true,
    }
end

function ClsGuildGroupManageView:onEnter(funs)
	self:mkUI()
	self:initEvent()
end

local widget_name = {
	"btn_close",
	"btn_join",
	"btn_remove",
}
local touch_rect = CCRect(display.cx - 210, display.cy - 130, 420, 260)
function ClsGuildGroupManageView:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_group.json")
	self.panel:setPosition(ccp(display.cx - 210, display.cy - 130))
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
		self[v]:setTouchEnabled(true)
		self[v]:setPressedActionEnabled(true)
	end
	self:regTouchEvent(self, function(eventType, x, y)	
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if is_in then return end
		self:close()
	end)
end

function ClsGuildGroupManageView:initEvent()
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_join:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:joinGroup()
		self:close()
	end, TOUCH_EVENT_ENDED)
	self.btn_remove:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:unbindGroup()
		self:close()
	end, TOUCH_EVENT_ENDED)
end

function ClsGuildGroupManageView:onExit()
end

function ClsGuildGroupManageView:unbindGroup()
    local guild_data = getGameData():getGuildInfoData()
    guild_data:askUnbindGroup()
end

function ClsGuildGroupManageView:joinGroup()
    local guild_data = getGameData():getGuildInfoData()
    guild_data:askJoinGroup()
end

return ClsGuildGroupManageView