--
-- Author: lzg0496
-- Date: 2017-04-28 11:02:46
-- Function: 副本特效层

local ClsCopyEffectLayer = class("ClsCopyEffectLayer", require("ui/view/clsBaseView"))

--页面参数配置方法，注意，是静态方法
function ClsCopyEffectLayer:getViewConfig()
	return {
		is_swallow = false,
	}
end
--页面创建时调用
function ClsCopyEffectLayer:onEnter()
	self.m_event_layer_ui_effect_layer = display.newLayer()
	self:addChild(self.m_event_layer_ui_effect_layer, 0)
	
	self.m_auto_tips_layer = display.newLayer()
	self:addChild(self.m_auto_tips_layer, 1)
end

function ClsCopyEffectLayer:getEventLayerUIEffectLayer()
	return self.m_event_layer_ui_effect_layer
end

function ClsCopyEffectLayer:getAutoTipsLayer()
	return self.m_auto_tips_layer
end

return ClsCopyEffectLayer