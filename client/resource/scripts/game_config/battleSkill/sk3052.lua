----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillPassive = require("module/battleAttrs/skill_passive")

cls_sk3052 = class("cls_sk3052", clsSkillPassive);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk3052.get_skill_id = function(self)
	return "sk3052";
end


-- 技能名 
cls_sk3052.get_skill_name = function(self)
	return T("快速维修");
end

-- 精简版技能描述 
cls_sk3052.get_skill_short_desc = function(self)
	return T("提升治疗效果，技能满级对所有友军持续清除不良状态");
end

-- 获取技能的描述
cls_sk3052.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("提升%0.1f%%治疗效果，技能满级对所有友军持续清除不良状态"), (0.15*lv))
end

-- 获取技能的富文本描述
cls_sk3052.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)提升【船体修补】$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)治疗效果"), (0.15*lv))
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk3052.get_status_limit = function(self)
	return status_limit
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk3052.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------