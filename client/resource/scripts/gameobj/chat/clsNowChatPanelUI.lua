local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsChatPanelBase = require("gameobj/chat/clsChatPanelBase")

local ClsNowChatPanelUI = class("ClsNowChatPanelUI", ClsChatPanelBase)
function ClsNowChatPanelUI:ctor()
    local parameter = {
        json_res = "chat_now.json",
        channel = KIND_NOW,
        data = DATA_NOW,
    }
    self.super.ctor(self, parameter)
    self:configUI()
    self:initEvent()
    self:createEditBox()
end

function ClsNowChatPanelUI:configUI()
    self.btn_record = getConvertChildByName(self.panel, "btn_record")
    local func = self.btn_record.setVisible
    function self.btn_record:setVisible(enable)
        func(self, enable)
        self:setTouchEnabled(enable)
    end
    self.btn_record:setPressedActionEnabled(true)
end

function ClsNowChatPanelUI:updateView()
    self:createList(self.data_kind)
end

function ClsNowChatPanelUI:enterCall()
    self:updateView()
end

return ClsNowChatPanelUI