--
-- Author: lzg0496
-- Date: 2016-12-07 20:48:02
--

local clsCopySceneEffectLayer = class("clsCopySceneEffectLayer", require("ui/view/clsBaseView"))

--页面参数配置方法，注意，是静态方法
function clsCopySceneEffectLayer:getViewConfig()
    return {
        is_swallow = false,
    }
end
--页面创建时调用
function clsCopySceneEffectLayer:onEnter()
    self.m_event_layer_ui_effect_layer = display.newLayer()
    self:addChild(self.m_event_layer_ui_effect_layer, 0)
    
    self.m_auto_tips_layer = display.newLayer()
    self:addChild(self.m_auto_tips_layer, 1)
end

function clsCopySceneEffectLayer:getEventLayerUIEffectLayer()
    return self.m_event_layer_ui_effect_layer
end

function clsCopySceneEffectLayer:getAutoTipsLayer()
    return self.m_auto_tips_layer
end

return clsCopySceneEffectLayer