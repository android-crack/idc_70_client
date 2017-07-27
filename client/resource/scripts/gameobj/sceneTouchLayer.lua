require("module/gameBases")
require("module/eventHandlers")
require("base/cocos_common/event_trigger")

sceneTouchPos = ccp(-1, -1)

local SceneTouchLayer = class("SceneTouchLayer", function() return CCLayerColor:create(ccc4(0,0,0,0)) end)
function SceneTouchLayer:ctor()
	local function onTouch(eventType, x, y)
		sceneTouchPos.x = x
		sceneTouchPos.y = y
		if eventType == "began" then
			if HasRegTrigger(EVENT_SCENE_TOUCH_BEGIN) then
				EventTrigger(EVENT_SCENE_TOUCH_BEGIN, x, y)
			end
			--cclog("===========================SceneTouchLayer touchBegin x="..x.." y="..y)
			return true
		elseif eventType == "moved" then
			if HasRegTrigger(EVENT_SCENE_TOUCH_MOVE) then
				EventTrigger(EVENT_SCENE_TOUCH_MOVE, x, y)
			end
		elseif eventType == "ended" then
			if HasRegTrigger(EVENT_SCENE_TOUCH_END) then
				EventTrigger(EVENT_SCENE_TOUCH_END, x, y)
			end
			--cclog("===========================SceneTouchLayer touchEnd x="..x.." y="..y)
		else

		end
	end

	self:registerScriptTouchHandler(onTouch, false, TOUCH_PRIORITY_SCENETOUCH, false)
	self:setTouchEnabled(true)
end

return SceneTouchLayer