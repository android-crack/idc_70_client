local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDelEffectFromScene = class("ClsAIActionDelEffectFromScene", ClsAIActionBase) 

function ClsAIActionDelEffectFromScene:getId()
	return "del_effect_from_scene"
end

function ClsAIActionDelEffectFromScene:initAction(id, filename, dx, dy, time)
	self.id = id	
end

function ClsAIActionDelEffectFromScene:__dealAction(target_id, delta_time)
	local battle_data = getGameData():getBattleDataMt()

	battle_data:delEffect(self.id)

	require("gameobj/battle/battleRecording"):recordVarArgs("del_scene_effect", self.id)

	return true
end

return ClsAIActionDelEffectFromScene
