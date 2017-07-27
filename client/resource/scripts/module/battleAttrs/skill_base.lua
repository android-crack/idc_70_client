local clsSkillBase = class("clsSkillBase")

-- 被动技能
local SKILL_TYPE_PASSIVE = "passive"
-- 主动技能
local SKILL_TYPE_INITIATIVE = "initiative"

-- 属性技能(这部分估计由服务器实现了，备注在这里)
--local SKILL_TYPE_ATTRIBUTE = "attribute"

function clsSkillBase:ctor(params)
	self.attackerId = params.attackerId
	self.id = params.id
end

function clsSkillBase:get_skill_lv()
	self.attacker:get_skill_lv(self.id)
end

-- 技能类型
function clsSkillBase:get_skill_type()
	return "base"
end

-- 技能简介
function clsSkillBase:get_skill_brief()
	return ""
end

-- 技能系列
function clsSkillBase:get_skill_series()
	return 0
end

-- 技能名字
function clsSkillBase:get_skill_name()
	return T("技能基类")
end

-- 技能id
function clsSkillBase:get_skill_id()
	return "skill_base"
end

function clsSkillBase:heart_break()
end

function clsSkillBase:get_preload_hit_effect()
	return ""
end

function clsSkillBase:get_common_cd()
	return 0
end

return clsSkillBase
