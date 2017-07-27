-- 离线收益
-- Author: Ltian
-- Date: 2016-07-04 15:04:16
--
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsIdleAwardTab = class("ClsIdleAwardTab",require("ui/view/clsBaseView"))
local music_info = require("game_config/music_info")

function ClsIdleAwardTab:getViewConfig()
    return {
        is_swallow = false,
    }
end
local MAX_TIME = 24*60*60*7

function ClsIdleAwardTab:onEnter()
	self:mkUI()
end

local widget_name = {
	"time_num",
	"cash_num",
	"get_btn",
	"time_online",
}

function ClsIdleAwardTab:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_idle.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.get_btn:setPressedActionEnabled(true)
	self.get_btn:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.get_btn:setTouchEnabled(false)
		local login_award_data = getGameData():getLoginVipAwardData()
		login_award_data:askIdleReward()
	end, TOUCH_EVENT_ENDED)
	self:updateView()
end

function ClsIdleAwardTab:updateView()
	local login_award_data = getGameData():getLoginVipAwardData()
	local data = login_award_data:getIdleAwardInfo()
	if not data then
		self.time_num:setText("00:00:00")
		self.time_online:setVisible(true)
		self.cash_num:setText("0")
		self.get_btn:disable()
		self.get_btn:setTouchEnabled(false)
		return
	end
	if not data.cash or data.cash == 0 then
		self.time_num:setText("00:00:00")
		self.time_online:setVisible(true)
		self.cash_num:setText("0")
		self.get_btn:disable()
		self.get_btn:setTouchEnabled(false)
	else
		self.get_btn:active()
		self.get_btn:setTouchEnabled(true)
		self.time_online:setVisible(false)
		local time = ClsDataTools:getCnTimeStr(data.passTime)
		if data.passTime > MAX_TIME then
			local ui_word = require("game_config/ui_word")
			time = ui_word.MORE_THAN_SEVEN_DAY
		end
		self.time_num:setText(time)
		self.cash_num:setText(data.cash)
	end
end

function ClsIdleAwardTab:onExit()
end
return ClsIdleAwardTab