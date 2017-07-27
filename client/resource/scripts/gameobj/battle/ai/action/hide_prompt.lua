local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionHidePrompt = class("ClsAIActionHidePrompt", ClsAIActionBase) 

function ClsAIActionHidePrompt:getId()
	return "hide_prompt"
end

function ClsAIActionHidePrompt:initAction()
end

function ClsAIActionHidePrompt:__dealAction(target_id, delta_time, call_back)
	local battle_data = getGameData():getBattleDataMt()

	local battle_ui = battle_data:GetLayer("battle_ui")

	if tolua.isnull(battle_ui) then return end

	battle_ui:hidePrompt()
end

return ClsAIActionHidePrompt
