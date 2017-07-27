-- 自动委任经商遮挡层
-- Author: chenlurong
-- Date: 2016-06-14 19:59:43
--
local music_info=require("game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsAppointTradeLayer = class("clsAppointTradeLayer", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsAppointTradeLayer:getViewConfig()
    return {
        name = "ClsAppointTradeLayer",       --(选填）默认 class的名字
        type = UI_TYPE.TOP,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        -- effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
    }
end

function ClsAppointTradeLayer:onEnter()
	self.res_plist = {
        ["ui/auto_trade.plist"] = 1,
    }
    LoadPlist(self.res_plist)
	self:init()
	self:addEvent()

    local battle_data = getGameData():getBattleDataMt()
    if not battle_data:IsBattleStart() then
        getUIManager():create("gameobj/chat/clsChatComponent", {layer_pos = UI_TYPE.TOP}, {panel_pos = ccp(0, 10)})
    end
end

function ClsAppointTradeLayer:init()	
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/auto_trade_explore.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    self.time_info = getConvertChildByName(self.panel, "time_info")
    self.btn_end_trade = getConvertChildByName(self.panel, "btn_end")

    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    self:updateTime(auto_trade_data:getTradeRemainTime())
end

function ClsAppointTradeLayer:addEvent()
	self.btn_end_trade:setPressedActionEnabled(true)
    self.btn_end_trade:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local Alert = require("ui/tools/alert")
        local ui_word = require("scripts/game_config/ui_word")
        local team_data = getGameData():getTeamData() 
        if team_data:isInTeam() and not team_data:isTeamLeader() then
            Alert:showAttention(ui_word.IS_TEAM_LEAVE, function()
                team_data:askLeaveTeam()
            end, nil, nil, {ok_text = ui_word.YES, cancel_text = ui_word.NO, is_notification = true})
        else
            Alert:showAttention(ui_word.APPOINT_TRADE_END_ALERT, function()
                local auto_trade_data = getGameData():getAutoTradeAIHandler()
                auto_trade_data:askStopTrade()
            end, nil, nil, {ok_text = ui_word.YES, cancel_text = ui_word.NO, is_notification = true})
        end
    end,TOUCH_EVENT_ENDED)
end

function ClsAppointTradeLayer:updateTime(time)
	local time_str = ClsDataTools:getTimeStr1(time)
	if time_str == "" then
		time_str = "0m"
	end
	self.time_info:setText(time_str)
	-- if time_str == "" then --没有时间了，主动停止
	-- 	local auto_trade_data = getGameData():getAutoTradeAIHandler()
 --        auto_trade_data:askStopTrade()
	-- end
end

function ClsAppointTradeLayer:onExit()
    UnLoadPlist(self.res_plist)
    ReleaseTexture()
end

return ClsAppointTradeLayer