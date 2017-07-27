local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDelSkill = class("ClsAIActionDelSkill", ClsAIActionBase) 

function ClsAIActionDelSkill:getId()
	return "del_skill"
end

function ClsAIActionDelSkill:initAction(skill_id)
	self.skill_id = skill_id
end

function ClsAIActionDelSkill:__dealAction(target_id, delta_time)
	if not self.skill_id then return end

	local ai_obj = self:getOwnerAI()
	if not ai_obj then return end

	-- 删除技能
	local owner_obj = ai_obj:getOwner()
	if owner_obj and not owner_obj:is_deaded() and owner_obj.skills[self.skill_id] then
		owner_obj.skills[self.skill_id] = nil
	end
end

return ClsAIActionDelSkill
