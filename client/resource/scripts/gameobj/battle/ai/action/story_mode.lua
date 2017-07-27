local ui_word = require("game_config/ui_word")

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionStoryMode = class("ClsAIActionStoryMode", ClsAIActionBase) 

function ClsAIActionStoryMode:getId()
	return "story_mode"
end
 
function ClsAIActionStoryMode:initAction()
end

function ClsAIActionStoryMode:__beginAction(target, delta_time)
	local fight_ui = getUIManager():get("FightUI")
	if not tolua.isnull(fight_ui) then
		fight_ui:storyMode()

		require("gameobj/battle/battleRecording"):recordVarArgs("battle_story_mode", FV_BOOL_TRUE)
	end
end

return ClsAIActionStoryMode