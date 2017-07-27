local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionShowPrompt = class("ClsAIActionShowPrompt", ClsAIActionBase) 

function ClsAIActionShowPrompt:getId()
	return "show_prompt"
end

function ClsAIActionShowPrompt:initAction(txt)
	self.txt = txt
end

function ClsAIActionShowPrompt:__dealAction(target_id, delta_time, call_back)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:BattleIsRunning() then return end 

	require("gameobj/battle/battleRecording"):recordVarArgs("battle_create_goal", self.txt)

	local battle_ui = battle_data:GetLayer("battle_ui")

	if tolua.isnull(battle_ui) then return end

	battle_ui:showPrompt(self.txt)
end

return ClsAIActionShowPrompt
