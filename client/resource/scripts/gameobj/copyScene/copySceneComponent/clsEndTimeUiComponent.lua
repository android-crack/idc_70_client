--
-- Author: lzg0946
-- Date: 2016-09-05 16:14:31
-- Function: 倒计时

local ui_word = require("scripts/game_config/ui_word")
local ClsComponentBase = require("ui/view/clsComponentBase")

local ClsEndTimeUiComponent = class("ClsEndTimeUiComponent", ClsComponentBase)

function ClsEndTimeUiComponent:onStart()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_my_name = getGameData():getSceneDataHandler():getMyName()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initUI()
end

function ClsEndTimeUiComponent:initUI()
    local melee_panel = getConvertChildByName(self.m_explore_sea_ui, "copy_melee")
    melee_panel:setVisible(true)
    self.end_time_panel = getConvertChildByName(self.m_explore_sea_ui, "melee_text_frame")
    self.end_time_panel:setVisible(true)

    self.lbl_end_time = getConvertChildByName(self.end_time_panel, "end_time_num")
    self.lbl_end_time:setText("")
end

function ClsEndTimeUiComponent:updateTimeUI(time)
    self.lbl_end_time:setText(time)
end

return ClsEndTimeUiComponent
