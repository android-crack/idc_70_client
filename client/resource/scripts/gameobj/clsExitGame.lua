-- phone  back btn exit game
local UI_WORD = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local element_mgr = require("base/element_mgr")

local ClsExitGame = class("ClsExitGame", function() return display.newLayer() end )

function ClsExitGame:ctor(parent)
    parent:addChild(self)
    self:registerScriptHandler(function(event)
        if event == "enter" then

        elseif event == "exit" then
            self:onExit()
        end
    end)

    local function KeypadCallBack(event)
        if event == "back" then
            self:alertExitView()
        elseif  event == "menu" then

        end
    end
    self:addKeypadEventListener(KeypadCallBack)
    self:setKeypadEnabled(true)
end

function ClsExitGame:isAlert()
    return self.is_alert
end

function ClsExitGame:alertExitView()
    if self.is_alert then
        return
    end
    self.is_alert = true

    local function callBack()
        -- local town_ui =  element_mgr:get_element("PortTownUI")
        -- if not tolua.isnull(town_ui) then
        --     local Tips = require("ui/tools/Tips")
        --     Tips:hideNode()
        -- end
        local is_exist = getUIManager():get('clsPortTownUI')

        CCDirector:sharedDirector():endToLua()
    end

    local function closeCallBack()
        self.is_alert = nil
    end
    local function exitCallBack()
        self.is_alert = nil
    end

    Alert:showAttention(UI_WORD.IS_OUT_GAME, callBack, closeCallBack, nil, {is_notification = true, name_str = "clsExitGameTips"})
end

function ClsExitGame:onExit()
    self.is_alert = nil
    self:removeKeypadEventListener()
end

return ClsExitGame
