--
-- Author: lzg0946
-- Date: 2016-11-23 19:40:47
-- Function 组队的聊天气泡

local ClsViewBase = require("ui/ClsViewBase")
local ClsCommonFuns = require("gameobj/commonFuns")
local ClsTips = require("ui/tools/Tips")

local clsTeamChatBubble = class("clsTeamChatBubble", ClsViewBase)

local AUTO_KILL_TIME = 5 --自动消失时间
local AUTO_TURN_TIME = 3 --自动翻页时间

local ONE_PAGE_FONT_COUNT = 20 --一页的字符数

--params = {sender 谁uid要气泡 show_msg 要显示的内容}
--return UI 需要调用者自己设置位置
function clsTeamChatBubble:ctor(params)
    local parameter = {
        json_res = "main_team_dialog.json",
    }
    clsTeamChatBubble.super.ctor(self, parameter)
    self.ui_layer:setTouchEnabled(false)
    self.show_msg = params.show_msg
    self.sender = params.sender
    self.sum_count = ClsCommonFuns:utfstrlen(self.show_msg)
    self:initUI()
    self:doAction()
end

function clsTeamChatBubble:initUI()
    local needWidgetName = {
        ["spr_char_bg"] = "bg",
        ["lbl_team"] = "task_info",
    }

    for k, v in pairs(needWidgetName) do
        self[k] = getConvertChildByName(self.panel, v)
    end
    
    self.set_lbl = self.lbl_team
    self.set_lbl:setText("")
end

function clsTeamChatBubble:doAction()
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

return clsTeamChatBubble

