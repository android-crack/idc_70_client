local ClsBaseView = require("ui/view/clsBaseView")
local ClsBattleLayer = class("ClsBattleLayer", ClsBaseView)

function ClsBattleLayer:getViewConfig(name)
    return {
        name = "battle_layer",
        is_swallow = false,
    }
end

function ClsBattleLayer:onTouchChange(enable)
	if tolua.isnull(self.touch_layer) then
		self.touch_layer_disable = true
		return
	end

	self.touch_layer:setTouchEnabled(enable)
end

return ClsBattleLayer