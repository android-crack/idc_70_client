local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionNormalMode = class("ClsAIActionNormalMode", ClsAIActionBase) 

function ClsAIActionNormalMode:getId()
	return "normal_mode"
end
 
function ClsAIActionNormalMode:initAction()
end

function ClsAIActionNormalMode:__beginAction(target, delta_time)
	local fight_ui = getUIManager():get("FightUI")
	if not tolua.isnull(fight_ui) then
		fight_ui:normalMode()

		require("gameobj/battle/battleRecording"):recordVarArgs("battle_story_mode", FV_BOOL_FALSE)
	end
end

return ClsAIActionNormalMode