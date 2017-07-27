--
-- Author: lzg0496
-- Date: 2016-08-23 20:17:27
-- Function: 探索聊天气泡

local ClsViewBase = require("ui/ClsViewBase")
local ClsCommonFuns = require("gameobj/commonFuns")
local ClsTips = require("ui/tools/Tips")

local ClsExploreChatBubble = class("ClsExploreChatBubble", ClsViewBase)

local AUTO_KILL_TIME = 5 --自动消失时间
local AUTO_TURN_TIME = 3 --自动翻页时间

local ONE_PAGE_FONT_COUNT = 29 --一页的字符数

--params = {direction 方向 0 or 1 , show_msg 要显示的内容}
--return UI 需要调用者自己设置位置
function ClsExploreChatBubble:ctor(params)
    local parameter = {
        json_res = "explore_sea_chat.json",
    }
    ClsExploreChatBubble.super.ctor(self, parameter)
    self.ui_layer:setTouchEnabled(false)
    self.direction = params.direction or DIRECTION_RIGHT
    self.show_msg = params.show_msg
    self.sender = params.sender
    self.sum_count = ClsCommonFuns:utfstrlen(self.show_msg)
    self:initUI()
    self:doAction()
end

function ClsExploreChatBubble:initUI()
    local needWidgetName = {
        ["spr_char_bg"] = "chat_bg",
        ["lbl_team"] = "text_team",
        ["lbl_ship"] = "text_ship",
    }

    for k, v in pairs(needWidgetName) do
        self[k] = getConvertChildByName(self.panel, v)
    end
    
    self.set_lbl = self.lbl_ship
    if self.direction == DIRECTION_LEFT then
        self.spr_char_bg:setFlipX(true)
        self.set_lbl = self.lbl_team
        self.lbl_ship:setVisible(false)
        self.lbl_team:setVisible(true)
    end
    self.set_lbl:setText("")
end

function ClsExploreChatBubble:doAction()
    local arr_action = CCArray:create()
    ClsTips:runAction(self.spr_char_bg,true) --不要音效
    local page = math.ceil(self.sum_count / ONE_PAGE_FONT_COUNT)

    if page == 1 then
        arr_action:addObject(CCCallFunc:create(function()
            self.set_lbl:setText(self.show_msg)
        end))
        arr_action:addObject(CCDelayTime:create(AUTO_KILL_TIME))
        arr_action:addObject(CCCallFunc:create(function()
            self:removeFromParentAndCleanup(true)
        end))
    else
        for i = 1, page do
            arr_action:addObject(CCCallFunc:create(function()
                local str = ClsCommonFuns:utf8sub(self.show_msg, 
                                (i - 1) * ONE_PAGE_FONT_COUNT + 1, ONE_PAGE_FONT_COUNT)
                self.set_lbl:setText(str)
            end))

            arr_action:addObject(CCDelayTime:create(AUTO_TURN_TIME))
            if i == page then
                arr_action:addObject(CCCallFunc:create(function()
                    self:removeFromParentAndCleanup(true)
                end))
            end
        end
    end

    local action = CCSequence:create(arr_action)
    self.spr_char_bg:runAction(action)
end

return ClsExploreChatBubble
