--2016/07/23
--create by wmh0497
--组件基类
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local ClsExplorePlayerUI = require("gameobj/explore/explorePlayerUI")
local ClsComponentBase = require("ui/view/clsComponentBase")

local ClsTeamSelectUiComponent = class("ClsTeamSelectUiComponent", ClsComponentBase)

function ClsTeamSelectUiComponent:onStart()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initUi()
end

function ClsTeamSelectUiComponent:initUi()
    self.m_player_ui = ClsExplorePlayerUI.new(self.m_parent, true)
    self.m_parent:addWidget(self.m_player_ui)
end

return ClsTeamSelectUiComponent



