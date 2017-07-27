local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionRefreshPlunderCash = class("ClsAIActionRefreshPlunderCash", ClsAIActionBase) 

function ClsAIActionRefreshPlunderCash:getId()
	return "refresh_plunder_cash"
end

function ClsAIActionRefreshPlunderCash:initAction()
end

function ClsAIActionRefreshPlunderCash:__dealAction( target_id, delta_time )
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:IsInBattle() then return end

	local battle_field_data = battle_data:GetData("battle_field_data")
	local battle_type = battle_field_data.fight_type

	if battle_type == battle_config.fight_type_plunder then
		local ai_obj = self:getOwnerAI()
		local owner_obj = ai_obj:getOwner()

		if owner_obj:getTeamId() ~= battle_config.target_team_id then
			local dead_num = battle_data:GetData("_progress_cnt_1")
		else
			local fight_ui = getUIManager():get("FightUI")
			if not tolua.isnull(fight_ui) then
				local dead_num = battle_data:GetData("_progress_cnt_2")
				fight_ui:setProgressBarPercent(dead_num)
			end
		end
	end
end

return ClsAIActionRefreshPlunderCash
