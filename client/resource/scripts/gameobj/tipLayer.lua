require("base/cocos_common/event_trigger")
require("module/eventHandlers")

local TIP_LAYER = nil
local TIP_POOL = nil

local function showTip(tip_msg)
	local tip_item = getTipItemFromPool()

	-- hard code
	local x, y = 100, 100
	tip_item.spItem:setVisible(true)
	tip_item.spItem:setPosition(x, y)
end

local function createTipLayer()
	if TIP_LAYER then return TIP_LAYER end

	TIP_LAYER = CCLayer:create()
	return TIP_LAYER
end

local tipLayer = {
	createTipLayer = createTipLayer,
	showTip = showTip,
}

return tipLayer