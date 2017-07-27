local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionClearCD = class("ClsAIActionClearCD", ClsAIActionBase) 

function ClsAIActionClearCD:getId()
	return "clear_cd"
end

function ClsAIActionClearCD:initAction(pos)
	self.pos = pos
end

function ClsAIActionClearCD:__dealAction(target_id, delta_time)
	if self.pos < 1 or self.pos > 4 then return end

	local battle_data = getGameData():getBattleDataMt()
	local target_obj = battle_data:getShipByGenID(target_id)

	if not target_obj or target_obj:is_deaded() then return false end

	local boat_key = target_obj.baseData.boat_key

	local sort_skill = battle_data:GetData(boat_key)

	local skill_id = sort_skill[self.pos]

	local skill_data = target_obj:getSkill(skill_id)

	if not skill_id or not skill_data then return end

	target_obj.common_skill_cd = getCurrentLogicTime()
	target_obj:set_skill_cd(skill_data.baseData.skill_ex_id, 0)

	local battleRecording = require("gameobj/battle/battleRecording")
	battleRecording:recordVarArgs("battle_clear_skill_cd", target_id, skill_data.baseData.skill_ex_id)

	local battle_ui = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		battle_ui:updateSkillUI(skill_data.baseData.skill_ex_id, true)
	end
end

return ClsAIActionClearCD
