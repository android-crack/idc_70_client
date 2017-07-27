--
-- Author: lzg0946
-- Date: 2016-09-12 11:14:55
-- Function: 副本描述

local ClsComponentBase = require("ui/view/clsComponentBase")

local ClsManualDescComponent = class("ClsManualDescComponent", ClsComponentBase)

function ClsManualDescComponent:onStart()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_my_name = getGameData():getSceneDataHandler():getMyName()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initUI()
end

function ClsManualDescComponent:initUI()
    local copy_guide = getConvertChildByName(self.m_explore_sea_ui, "copy_guide")
    copy_guide:setVisible(true)
end

return ClsManualDescComponent