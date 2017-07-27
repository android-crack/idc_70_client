local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsChatSetUI = class("ClsChatSetUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsChatSetUI:getViewConfig()
    return {
        name = "ClsChatSetUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

--页面创建时调用
function ClsChatSetUI:onEnter()
    self:setIsWidgetTouchFirst(true)
    self:configUI()
    self:configEvent()
end

function ClsChatSetUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/chat_set.json")
    self:addWidget(self.panel)
    
    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_black_list = getConvertChildByName(self.panel, "btn_black_list")
    self.popup_bg = getConvertChildByName(self.panel, "popup_bg")

    local channel_info = {
        [1] = {name = "checkbox_world", key = "NO_SHOW_WORLD"},
        [2] = {name = "checkbox_present", key = "NO_SHOW_NOW"},
        [3] = {name = "checkbox_guild", key = "NO_SHOW_GUILD"},
        [4] = {name = "checkbox_team", key = "NO_SHOW_TEAM"},
        [5] = {name = "checkbox_friend", key = "NO_SHOW_PRIVATE"},
        [6] = {name = "checkbox_system", key = "NO_SHOW_SYSTEM"},
    }

    local user_set = CCUserDefault:sharedUserDefault()
    for k, v in ipairs(channel_info) do
        local item = getConvertChildByName(self.panel, v.name)
        local not_show = user_set:getBoolForKey(v.key)
        item:setSelectedState(not not_show)

        item:addEventListener(function() 
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:setValue(v.key, false)
        end, CHECKBOX_STATE_EVENT_SELECTED)

        item:addEventListener(function() 
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:setValue(v.key, true) 
        end, CHECKBOX_STATE_EVENT_UNSELECTED)

        item:setTouchEnabled(true)
        self[v.name] = item
    end

    local voice_info = {
        [1] = {name = "checkbox_world", key = "NO_PLAY_WORLD"},
        [2] = {name = "checkbox_present", key = "NO_PLAY_NOW"},
        [3] = {name = "checkbox_guild", key = "NO_PLAY_GUILD"},
        [4] = {name = "checkbox_team", key = "NO_PLAY_TEAM"},
        [5] = {name = "checkbox_friend", key = "NO_PLAY_PRIVATE"},
        [6] = {name = "checkbox_system", key = "NO_SHOW_AUDIO"},--这个控件特殊用来确定是否将语音以文本的形式显示出来
    }
    
    for k, v in ipairs(voice_info) do
        local name = string.format("%s_0", v.name)
        local item = getConvertChildByName(self.panel, name)

        local not_play = user_set:getBoolForKey(v.key)
        item:setSelectedState(not not_play)

        item:addEventListener(function() 
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:setValue(v.key, false)
        end, CHECKBOX_STATE_EVENT_SELECTED)

        item:addEventListener(function() 
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:setValue(v.key, true) 
        end, CHECKBOX_STATE_EVENT_UNSELECTED) 

        item:setTouchEnabled(true)
        self[v.name] = item
    end
end

function ClsChatSetUI:configEvent()
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:exitView()
    end, TOUCH_EVENT_ENDED)

    self.btn_black_list:setPressedActionEnabled(true)
    self.btn_black_list:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self:exitView()
        local component_ui = getUIManager():get("ClsChatComponent")
        local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
        main_ui:setPlayerBtnInfo(PLAYER_STATUS_BLACK)
        main_ui:executeSelectTabLogic(INDEX_PLAYER, true)
    end, TOUCH_EVENT_ENDED)

    local bg_size = self.popup_bg:getSize()
    local bg_pos = self.popup_bg:getPosition()
    local start_x = (display.width - bg_size.width) / 2
    local start_y = (display.height - bg_size.height) / 2
    local touch_rect = CCRect(start_x, start_y, bg_size.width, bg_size.height)

    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            return true
        elseif event_type == "ended" then
            if not touch_rect:containsPoint(ccp(x, y)) then
                self:exitView()
            end
        end
    end)
end

function ClsChatSetUI:exitView()
    self:close()
    local component_ui = getUIManager():get("ClsChatComponent")
    local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
    if not tolua.isnull(panel_ui) then
        panel_ui:updateShowMessage()
    end
end

function ClsChatSetUI:setValue(key, value)
    local user_set = CCUserDefault:sharedUserDefault()
    user_set:setBoolForKey(key, value)
    user_set:flush()
end

return ClsChatSetUI