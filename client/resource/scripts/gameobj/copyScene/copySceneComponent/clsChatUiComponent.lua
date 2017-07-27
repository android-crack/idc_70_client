--2016/07/23
--create by wmh0497
--组件基类
local ui_word = require("scripts/game_config/ui_word")

local ClsComponentBase = require("ui/view/clsComponentBase")
local ClsChatSystemPanel = require("gameobj/chat/clsChatSystemPanel")
local ClsChatComponent = require("gameobj/chat/clsChatComponent")
local ClsChatSystemMainUI = require("gameobj/chat/clsChatSystemMainUI")


local ClsChatUiComponent = class("ClsChatUiComponent", ClsComponentBase)

function ClsChatUiComponent:onStart()
    -- self:createChatComponent()
end

function ClsChatUiComponent:createChatComponent()
    -- --聊天框
    -- self.chat_component = ClsChatComponent.new(self.m_parent, TOUCH_PRIORITY_MORE_HIGHT, {zorder = 9})
    -- local chat_panel = self.chat_component:getPanelUI()
    -- chat_panel:setTouch(true)
    -- chat_panel:sethidePreCallBack(function()
    --     chat_panel:setTouch(false)
    -- end)
    -- chat_panel:setShowBehindCallBack(function() 
    --     chat_panel:setTouch(true)
    -- end)

    -- local chat_main = self.chat_component:getMainUI()
    -- local chat_bg = chat_main:getChatBg()
    -- chat_bg:setScaleX(0)
    -- chat_main:setShowBehindCallBack(function()
    --     chat_main:setTouch(true)
    -- end)

    -- chat_main:setHideBehindCallBack(function()
    --     chat_panel:show()
    -- end)
end

function ClsChatUiComponent:removeChatComponent()
    -- if tolua.isnull(self.chat_component) then return end
    -- self.chat_component:removeFromParentAndCleanup(true)
end

function ClsChatUiComponent:setTouch(enable)
    -- local chat_panel = self.chat_component:getPanelUI()
    -- local chat_main = self.chat_component:getMainUI()
    -- chat_panel:setTouch(enable)
    -- chat_main:setTouch(enable)
end

return ClsChatUiComponent



