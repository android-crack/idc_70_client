--聊天左下角面板和聊天主界面的基类
local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsChatSystemPanel = require("gameobj/chat/clsChatSystemPanel")
local ClsChatSystemMainUI = require("gameobj/chat/clsChatSystemMainUI")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsChatComponent = class("ClsChatComponent", ClsBaseView)
function ClsChatComponent:getViewConfig()
    return {
        name = "ClsChatComponent",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = false,     --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsChatComponent:onEnter(paramter)
    paramter = paramter or {}
    if paramter.not_need_panel == nil then
        self.not_need_panel = false
    else
        self.not_need_panel = paramter.not_need_panel
    end

    if paramter.not_need_main == nil then
        self.not_need_main = false
    else
        self.not_need_main = paramter.not_need_main
    end

	self.panels = {}
	self.is_show = true

    if not self.not_need_panel then
        local panel_ui = ClsChatSystemPanel.new()
        if paramter.panel_pos then
            panel_ui:setPosition(paramter.panel_pos)
        end
        self:insertPanelByName("ClsChatSystemPanel", panel_ui)
        self:addWidget(panel_ui)
    end

    if not self.not_need_main then
        local main_ui = ClsChatSystemMainUI.new()
        self:insertPanelByName("ClsChatSystemMainUI", main_ui)
        self:addWidget(main_ui)
        main_ui:setVisible(false)
    end
    self:configEvent()
end

function ClsChatComponent:setIsShow(is_show)
	if self.is_show == is_show then return end
	self.is_show = is_show
	self:setViewTouchEnabled(is_show)
	self:stopAllActions()
	
	local move_act = nil
	local move_time_n = 0.3
	if self.is_show then
		move_act = CCEaseBackOut:create(CCMoveTo:create(move_time_n, ccp(0,  0)))
	else
		move_act = CCEaseBackIn:create(CCMoveTo:create(move_time_n, ccp(-1 * display.cx,  0)))
	end
	self:runAction(move_act)
end

function ClsChatComponent:configEvent()
    local main_ui = self:getPanelByName("ClsChatSystemMainUI")
end

function ClsChatComponent:getPanelByName(name)
	return self.panels[name]
end

function ClsChatComponent:insertPanelByName(name, panel)
	self.panels[name] = panel
end

function ClsChatComponent:onTouchChange(is_touch)
    local main_ui = self.panels["ClsChatSystemMainUI"]
    if not tolua.isnull(main_ui) then
        local cur_panel = main_ui:getCurPanel()
        if not tolua.isnull(cur_panel) then
            local edit_box = nil
            if type(cur_panel.getEidtBox) == "function" then
                edit_box = cur_panel:getEidtBox()
                if not tolua.isnull(edit_box) then
                    edit_box:setTouchEnabled(is_touch)
                end
            else
                if type(cur_panel.getCurPanel) == "function" then
                    local sub_panel = cur_panel:getCurPanel()
                    if type(sub_panel.getEidtBox) == "function" then
                        edit_box = sub_panel:getEidtBox()
                        if not tolua.isnull(edit_box) then
                            edit_box:setTouchEnabled(is_touch)
                        end
                    end
                end
            end

            if type(cur_panel.getChannelBox) == "function" then
                local channel_box = cur_panel:getChannelBox()
                if not tolua.isnull(channel_box) then
                    channel_box:setTouchEnabled(is_touch)
                end
            end
        end
    end
end

return ClsChatComponent