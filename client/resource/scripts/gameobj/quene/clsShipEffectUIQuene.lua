--
-- Author: Ltian
-- Date: 2017-02-13 15:57:25
--



local ClsShipEffectUIQuene = class("ClsShipEffectUIQuene", require("gameobj/quene/clsQueneBase"))

function ClsShipEffectUIQuene:ctor(data)
	self.data = data
end

function ClsShipEffectUIQuene:getQueneType()
	return self:getDialogType().ship_effect_ui
end

function ClsShipEffectUIQuene:excTask()
	local layer =getUIManager():create("gameobj/mission/clsNewShipEffectUI", nil, function() self:TaskEnd() end)
	if tolua.isnull(layer) then
		self:TaskEnd()
	end
end

return ClsShipEffectUIQuene