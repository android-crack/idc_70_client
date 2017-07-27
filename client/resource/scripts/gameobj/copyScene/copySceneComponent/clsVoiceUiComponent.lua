--
-- Author: lzg0496
-- Date: 2016-08-22 20:41:22
-- Function: 语音组件

local ui_word = require("scripts/game_config/ui_word")
local ClsComponentBase = require("ui/view/clsComponentBase")
local ClsVoiceUIComponent = class("ClsVoiceUIComponent", ClsComponentBase)
local ClsChatBase = require("gameobj/chat/clsChatBase")--界面有录音的功能

function ClsVoiceUIComponent:onStart()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_my_name = getGameData():getSceneDataHandler():getMyName()
    self:initVoiceUI()
end

function ClsVoiceUIComponent:initVoiceUI()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_copy_chat.json")
    convertUIType(panel)
    self.m_parent:addWidget(panel)
    local chat_data_hander = getGameData():getChatData()
    local btn_chat = getConvertChildByName(panel, "btn_chat")
    btn_chat:setPosition(ccp(55, 160))

    btn_chat:setPressedActionEnabled(true)
    btn_chat:setTouchEnabled(true)
    btn_chat:addEventListener(function()
        chat_data_hander:stopRecord()
    end, TOUCH_EVENT_ENDED) --结束录音
    btn_chat:addEventListener(function()
        chat_data_hander:recordMessage(KIND_NOW)
    end, TOUCH_EVENT_BEGAN)--开始录音

    btn_chat:addEventListener(function()
        chat_data_hander:cancelRecord()
    end, TOUCH_EVENT_CANCELED)--取消录音
end

function ClsVoiceUIComponent:cancelRecord()
    local chat_data_hander = getGameData():getChatData()
    chat_data_hander:cancelRecord()
end

return ClsVoiceUIComponent
