local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local Alert = require("ui/tools/alert")
local scheduler = CCDirector:sharedDirector():getScheduler()
local TAKE_HORN_NUM = 1

local ClsChatPanelBase = require("gameobj/chat/clsChatPanelBase")
local ClsWorldChatPanelUI = class("ClsWorldChatPanelUI", ClsChatPanelBase)
function ClsWorldChatPanelUI:ctor()
    local parameter = {
        json_res = "chat_world.json",
        channel = KIND_WORLD,
        data = DATA_WORLD,
    }
    self.super.ctor(self, parameter)
    self:configUI()
    self:initEvent()
    self:configEvent()
    self:createEditBox()
end

function ClsWorldChatPanelUI:configUI()
    self.btn_record = getConvertChildByName(self.panel, "btn_record")
    self.txt_channel_now = getConvertChildByName(self.panel, "txt_channel_now")
    local func = self.btn_record.setVisible
    function self.btn_record:setVisible(enable)
        func(self, enable)
        self:setTouchEnabled(enable)
    end
    self.btn_record:setPressedActionEnabled(true)

    local sprite = CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame("chat_channle_9.png"))
    self.channel_box = CCEditBox:create(CCSize(338, 32), sprite)
    self.channel_box:setPosition(293, 443)
    self.channel_box:setFont(font_tab[FONT_COMMON], 16)
    self.channel_box:setFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    self.channel_box:setInputFlag(kEditBoxInputFlagSensitive)

    self.channel_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    self.channel_box:setZOrder(1)
    self.panel:addCCNode(self.channel_box)
    local component_ui = getUIManager():get("ClsChatComponent")
    self.channel_box:setTouchPriority(component_ui:getTouchPriority() - 2)
    local chat_data = getGameData():getChatData()
    self.channel_box:registerScriptEditBoxHandler(function(eventType, target)
        if eventType == "began" then
            target:setText("")
        elseif eventType == "ended" then
            local txt = target:getText()
            if txt then
                local _, _, match = string.find(txt, "([^%d]+)")
                if not match then
                    local num = tonumber(txt)
                    if num >= 1 and num <= 999 then
                        target:setText(string.format(ui_word.WORLD_SELECT_CHANEL, num))
                        chat_data:askConvertChannel(num)
                    else
                        self:setChannelTips()
                        Alert:warning({msg = ui_word.PLEASE_INPUT_NUM, color = ccc3(dexToColor3B(COLOR_RED))})
                    end
                else
                    self:setChannelTips()
                    Alert:warning({msg = ui_word.PLEASE_INPUT_NUM, color = ccc3(dexToColor3B(COLOR_RED))})
                end
            else
                self:setChannelTips()
            end
        end
    end)
    self:setChannelTips()
end

function ClsWorldChatPanelUI:setChannelTips()
    local chat_data = getGameData():getChatData()
    local cur_channel_info = chat_data:getCurWorldInfo()
    if not cur_channel_info or not cur_channel_info.channel then return end
    self.channel_box:setText(string.format(ui_word.WORLD_SELECT_CHANEL, cur_channel_info.channel))
end

function ClsWorldChatPanelUI:getChannelBox()
    return self.channel_box
end

function ClsWorldChatPanelUI:configEvent()
    local chat_data = getGameData():getChatData()
end

function ClsWorldChatPanelUI:enterCall()
    self:createList(self.data_kind)
end

return ClsWorldChatPanelUI