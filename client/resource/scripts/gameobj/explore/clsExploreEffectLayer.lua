--2016/11/18
--create by wmh0497


local ClsExploreEffectLayer = class("ClsExploreEffectLayer", require("ui/view/clsBaseView"))

--页面参数配置方法，注意，是静态方法
function ClsExploreEffectLayer:getViewConfig()
    return {
        is_swallow = false,
    }
end
--页面创建时调用
function ClsExploreEffectLayer:onEnter()
	self.m_event_layer_ui_effect_layer = display.newLayer()
	self:addChild(self.m_event_layer_ui_effect_layer, 0)
	
	self.m_auto_tips_layer = display.newLayer()
	self:addChild(self.m_auto_tips_layer, 1)
end

function ClsExploreEffectLayer:getEventLayerUIEffectLayer()
	return self.m_event_layer_ui_effect_layer
end

function ClsExploreEffectLayer:getAutoTipsLayer()
	return self.m_auto_tips_layer
end

return ClsExploreEffectLayer