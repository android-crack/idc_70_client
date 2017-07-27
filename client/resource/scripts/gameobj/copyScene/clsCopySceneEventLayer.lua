--
-- Author: lzg0496
-- Date: 2016-12-07 20:44:05
-- Function: 副本事件管理类

local clsEventLayerBase = require("gameobj/explore/clsEventLayerBase")

local clsCopySceneEventLayer = class("clsCopySceneEventLayer", clsEventLayerBase)

function clsCopySceneEventLayer:ctor()
    clsCopySceneEventLayer.super.ctor(self)

    --ui层东东的创建
    self.m_effect_layer = getUIManager():get("clsCopySceneEffectLayer")
    self.m_ui_view = self.m_effect_layer:getEventLayerUIEffectLayer()
end

return clsCopySceneEventLayer
