local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionUseSkill = class("ClsAIActionUseSkill", ClsAIActionBase) 

function ClsAIActionUseSkill:getId()
	return "use_skill"
end

function ClsAIActionUseSkill:initAction(skill_id)
	self.skill_id = skill_id
end

function ClsAIActionUseSkill:__dealAction(target_id, delta_time)
	if not self.skill_id then return false end

	local ai_obj = self:getOwnerAI()
	if not ai_obj then return false end

	local battleData = getGameData():getBattleDataMt()

	local target_obj = battleData:getShipByGenID(target_id) 

	if not target_obj or target_obj:is_deaded() then return false end

	-- 施放技能
	local owner_obj = ai_obj:getOwner()
	if owner_obj then
		-- 施放技能
		owner_obj:UseSkill(self.skill_id, target_obj)
	end
end

return ClsAIActionUseSkill
