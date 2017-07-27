local skill_info = require("game_config/skill/skill_info")

local function createSkill(skill_id, level, passive)
	local scd = skill_info[skill_id]
	local sd_data = {
		skill_id = skill_id,
		baseData = scd,
		coolDown = 1,
		level = level or 1,
		info = {},
        passiveFlag = (passive == "passive")
	}

	return sd_data
end

local function getSkillBase(skill_id)
	return skill_info[skill_id]
end

local skillsBase = {
	createSkill = createSkill,
	getSkillBase = getSkillBase,
}

return skillsBase