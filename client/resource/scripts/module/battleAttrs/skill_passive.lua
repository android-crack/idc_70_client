local skill_base = require("module/battleAttrs/skill_base")
local clsSkillPassive = class("clsSkillPassive", skill_base)

-- 技能类型
function clsSkillPassive:get_skill_type()
	return "passive"
end

return clsSkillPassive
