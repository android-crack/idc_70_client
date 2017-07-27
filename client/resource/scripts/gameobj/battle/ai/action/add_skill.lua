local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionAddSkill = class("ClsAIActionAddSkill", ClsAIActionBase) 

function ClsAIActionAddSkill:getId()
	return "add_skill"
end

function ClsAIActionAddSkill:initAction(skill_id, level, passive, ord, show_effect)
	self.skill_id = skill_id				-- 技能ID
	self.level = level or 1					-- 技能等级
	self.passive = passive					-- 是否主动技能
	self.ord = ord                          -- 技能位置
	self.show_effect = show_effect
end

function ClsAIActionAddSkill:__dealAction( target_id, delta_time )
	if not self.skill_id then return end

	local ai_obj = self:getOwnerAI()
	if not ai_obj then return end

	-- 施放技能
	local owner_obj = ai_obj:getOwner()
	if owner_obj then
		-- 设定技能
		owner_obj:addSkill(self.skill_id, self.level, self.passive, nil, true, self.ord, self.show_effect)

		local battleRecording = require("gameobj/battle/battleRecording")
		battleRecording:recordVarArgs("battle_add_skill", owner_obj:getId(), self.skill_id, self.level, self.passive or "", 
			self.ord, self.show_effect)
	end
end

return ClsAIActionAddSkill
