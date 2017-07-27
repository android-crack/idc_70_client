local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionBeginTutorials = class("ClsAIActionBeginTutorials", ClsAIActionBase) 

function ClsAIActionBeginTutorials:getId()
	return "begin_tutorials"
end
 
function ClsAIActionBeginTutorials:initAction()
	self.duration = 9999999
end

function ClsAIActionBeginTutorials:__beginAction(target, delta_time)
	local fight_ui = getUIManager():get("FightUI")
	if not tolua.isnull(fight_ui) then
		local battle_data = getGameData():getBattleDataMt()
		local battleLayer = battle_data:GetTable("battle_layer")
		battleLayer.setBattlePaused(true)

		LoadPlist({
	        ["ui/battle_guide.plist"] = 1,
	    })

	    self.tutor_layer = UILayer:create()
		local battle_guide = GUIReader:shareReader():widgetFromJsonFile("json/battle_guide.json")
		convertUIType(battle_guide)
		self.tutor_layer:addWidget(battle_guide)

		local layer = CCLayerColor:create(ccc4(0, 0, 0, 200))
		self.tutor_layer:addChild(layer, -1)
		layer:registerScriptTouchHandler(function(eventType, x, y) 
			if eventType =="began" then
				battleLayer.setBattlePaused(false)
				self.duration = 0.1
				return true
			end
		end, false, TOUCH_PRIORITY_MISSION, true)
		layer:setTouchEnabled(true)

		fight_ui:addChild(self.tutor_layer, 999)
	end
end

function ClsAIActionBeginTutorials:__endAction(target)
	self.tutor_layer:removeFromParentAndCleanup(true)

	UnLoadPlist({
        ["ui/battle_guide.plist"] = 1,
    })
end

return ClsAIActionBeginTutorials