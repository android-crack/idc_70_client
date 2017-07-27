--2016/11/09
--create by wmh0497
--提示基类

local TOUCH_BG_ORDER = -1000

local ClsBaseTipsView = class("ClsBaseTipsView", require("ui/view/clsBaseView"))

function ClsBaseTipsView:getViewConfig(name_str, params, panel_ui, is_add_touch_close_bg)
    params = params or {}
    local tips_params = {
        is_back_bg = true,
        type = UI_TYPE.TIP,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        effect = UI_EFFECT.SCALE,    --(选填) ui出现时的播放特效
    }
    for k, v in pairs(params) do
        tips_params[k] = v
    end
    tips_params.name = name_str
    return tips_params
end

function ClsBaseTipsView:onEnter(name_str, params, panel_ui, is_add_touch_close_bg)
    params = params or {}
    self.m_is_add_touch_close_bg = is_add_touch_close_bg or false
    self.m_ignore_close_panel = nil
    self:addWidget(panel_ui)
    self.m_panel_ui = panel_ui
    self.m_is_touch_close_forbin = params.is_touch_close_forbin
    if is_add_touch_close_bg then
        self:addBgTouchCloseBg()
    end
end

function ClsBaseTipsView:addBgTouchCloseBg()
    self:setIsWidgetTouchFirst(true)
    self.m_bg_spr = display.newSprite()
    self:addChild(self.m_bg_spr, TOUCH_BG_ORDER)
    self:regTouchEvent(self.m_bg_spr, function(...) return self:bgOnTouch(...) end, TOUCH_BG_ORDER)
end

function ClsBaseTipsView:bgOnTouch(event, x, y)
    if event == "began" then
        return self:getIsTouchBg(x, y)
    elseif event == "ended" then
        if self.m_is_touch_close_forbin then
            return
        end
        self:close()
        if self.m_panel_ui then
            if self.m_panel_ui.close and type(self.m_panel_ui.close) == "function" then
                self.m_panel_ui:close()
            end
        end
    end
end

function ClsBaseTipsView:getIsTouchBg(world_x, world_y)
    if tolua.isnull(self.m_ignore_close_panel) then return true end
    
    local layer_pos = nil
    if self.m_ignore_close_panel.addCCNode then
        layer_pos = self.m_ignore_close_panel:getWorldPosition()
    else
        layer_pos = self.m_ignore_close_panel:convertToWorldSpace(ccp(0,0))
    end
    
    local touch_x = world_x - layer_pos.x
    local touch_y = world_y - layer_pos.y
    
    local size = nil
    if self.m_ignore_close_panel.getSize then
        size = self.m_ignore_close_panel:getSize()
    else
        size = self.m_ignore_close_panel:getContentSize()
    end

    if 0 <= touch_x and touch_x <= size.width
        and 0 <= touch_y and touch_y <= size.height then
        
        return false
    end
    return true
end

function ClsBaseTipsView:setIgnoreClosePanel(panel)
    self.m_ignore_close_panel = panel
end

function ClsBaseTipsView:onExit()
    if self.m_panel_ui and not tolua.isnull(self.m_panel_ui) then
        if self.m_panel_ui.onTipsExit and type(self.m_panel_ui.onTipsExit) == "function" then
            self.m_panel_ui:onTipsExit()
        end
    end
end

return ClsBaseTipsView