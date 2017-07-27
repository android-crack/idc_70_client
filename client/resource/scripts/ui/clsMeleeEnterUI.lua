--
-- Author: lzg0946
-- Date: 2016-09-05 17:13:15
-- Function: 大乱斗报名UI

local clsDataTools = require("module/dataHandle/dataTools")
local clsUiWord = require("game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")

local clsMeleeEnterUI = class("clsMeleeEnterUI", ClsBaseView)

function clsMeleeEnterUI:onEnter()
    local copySceneData = getGameData():getCopySceneData()
    copySceneData:askMeleeStatus()

    self.panel = createPanelByJson("json/explore_copy_melee.json")
    self:addWidget(self.panel)

    self:initUI()
    self:configEvent()
end

function clsMeleeEnterUI:updateUI()
    self.lbl_end_time:stopAllActions()
    local copySceneData = getGameData():getCopySceneData()
    local melee_time = copySceneData:getMeleeTime()
    self.lbl_count_tips:setVisible(melee_time >= 0)
    self.lbl_end_time:setVisible(melee_time >= 0)

    local arr_action = nil

    if melee_time >= 0 then
        arr_action = CCArray:create()
        arr_action:addObject(CCCallFunc:create(function()
            melee_time = melee_time - 1
            if melee_time <= 0 then
                self.lbl_count_tips:setVisible(false)
                self.lbl_end_time:setVisible(false)
                self.btn_enter:disable()
                self.lbl_end_time:stopAllActions()
                return
            end
            self.btn_enter:setVisible(true)
            self.btn_enter:setEnabled(true)
            self.btn_enter:active()
            self.lbl_end_time:setText(clsDataTools:getTimeStrNormal(melee_time))
        end))
        arr_action:addObject(CCDelayTime:create(1))
    end

    if arr_action then
        self.lbl_end_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
    end
end

function clsMeleeEnterUI:initUI()
    local need_widget_name = {
        btn_close = "btn_close",
        btn_enter = "btn_enter",
        lbl_enter = "btn_enter_text",
        lbl_count_tips = "count_down_text",
        lbl_end_time = "count_down_num",
    }

    for k, v in pairs(need_widget_name) do
        self[k] = getConvertChildByName(self.panel, v)
    end

    self.lbl_count_tips:setVisible(false)
    self.lbl_end_time:setVisible(false)
    self.btn_enter:setEnabled(false)
    self.btn_enter:setVisible(false)
end

function clsMeleeEnterUI:configEvent()
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
        self:close()
    end, TOUCH_EVENT_ENDED)

    self.btn_enter:setPressedActionEnabled(true)
    self.btn_enter:addEventListener(function()
        self.btn_enter:disable()
        local copySceneData = getGameData():getCopySceneData()
        copySceneData:askfight()
    end, TOUCH_EVENT_ENDED)
end

function clsMeleeEnterUI:setTouch()
end

return clsMeleeEnterUI
