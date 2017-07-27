--港口投资奖励
-- Author: Ltian
-- Date: 2015-08-03 18:44:40
--
local Alert = require("ui/tools/alert")
local ui_word=require("scripts/game_config/ui_word")
local scheduler = CCDirector:sharedDirector():getScheduler()
local music_info=require("game_config/music_info")
local uiCommon = require("ui/tools/UiCommon")

local ClsInvestRewardView = class("ClsInvestRewardView",require("ui/view/clsBaseView"))

function ClsInvestRewardView:getViewConfig()
    return {
        is_swallow = false,
    }
end

local REWARD_CAN_RECEIVE = 1
local REWARD_NOT_CAN_RECEIVE = 0

local widget_name = {
	"invest_lv",
	"cash_num",
	"get_btn",

}
function ClsInvestRewardView:onEnter()
	self.plist = {
		--["ui/checkin_ui.plist"] = 1,
	}
	self.invest_reward_price = 0 --投资奖励
	LoadPlist(self.plist)
	self:initView()
end

function ClsInvestRewardView:initView()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_bonus.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)
    self:mkUI()
end

function ClsInvestRewardView:mkUI()
	self:handleData()
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self.invest_lv:setText(self.noiblity_info.title)
	self.cash_num:setText(self.invest_reward_price)
	self:regCB()

	self.get_btn:setPressedActionEnabled(true)
    self.get_btn:addEventListener(function()
    	audioExt.playEffect(music_info.COMMON_BUTTON.res)
    	self.get_btn:setTouchEnabled(false)
    	self.get_btn:disable()
		local daily_activity_data = getGameData():getDailyActivityData()
		local reward_status = daily_activity_data:getInvestRewardStatus()
		if reward_status ~= REWARD_CAN_RECEIVE then --不到任务时间
			Alert:warning({msg = ui_word.INVEST_NOT_IN_TIME, size = 26})
		else
			daily_activity_data:receiveReward()		
		end
    end,TOUCH_EVENT_ENDED)
end

--按钮回调
function ClsInvestRewardView:regCB()
	self.get_btn:setTouchEnabled(true)

	local daily_activity_data = getGameData():getDailyActivityData()
	local reward_status = daily_activity_data:getInvestRewardStatus()
	
	if reward_status == REWARD_NOT_CAN_RECEIVE then
		self.get_btn:disable()
	else
		self.get_btn:active()
	end

    RegTrigger(POWER_UPDATE_EVENT, function()
        local port_layer = getUIManager():get("ClsPortLayer")
        if tolua.isnull(port_layer) then
            return
        end
        local wefare_main_ui = getUIManager():get("ClsWefareMain")
        if not tolua.isnull(wefare_main_ui) then
            Alert:goMunicipalWork(wefare_main_ui)
        end
    end)  
end

function ClsInvestRewardView:handleView()
	self:regCB()
end

--数据处理
function ClsInvestRewardView:handleData()
	local nobility_data = getGameData():getNobilityData()
  	--投资等级
  	self.noiblity_info = nobility_data:getCurrentNobilityData()
  	
  	--投资银币奖励
	self.invest_reward_price = self.noiblity_info.invest_cash
end

function ClsInvestRewardView:setTouch(enable)
	local daily_activity_data = getGameData():getDailyActivityData()
	local reward_status = daily_activity_data:getInvestRewardStatus()
	if enable == true and reward_status == REWARD_CAN_RECEIVE then
		self.get_btn:active()
	else
		self.get_btn:disable()
	end
end

function ClsInvestRewardView:updateView()
	self:mkUI()
end

function ClsInvestRewardView:onExit()
	UnLoadPlist(self.plist)
    UnRegTrigger(POWER_UPDATE_EVENT)
end

return ClsInvestRewardView