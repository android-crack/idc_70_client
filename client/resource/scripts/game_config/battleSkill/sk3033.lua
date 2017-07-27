----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillPassive = require("module/battleAttrs/skill_passive")

cls_sk3033 = class("cls_sk3033", clsSkillPassive);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk3033.get_skill_id = function(self)
	return "sk3033";
end


-- 技能名 
cls_sk3033.get_skill_name = function(self)
	return T("桅杆破坏");
end

-- 精简版技能描述 
cls_sk3033.get_skill_short_desc = function(self)
	return T("提升技能伤害，技能满级时眩晕目标4秒");
end

-- 获取技能的描述
cls_sk3033.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("提升%0.1f%%技能伤害，技能满级时眩晕目标4秒"), (6*lv))
end

-- 获取技能的富文本描述
cls_sk3033.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)提升【链弹】$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)技能伤害"), (6*lv))
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk3033.get_status_limit = function(self)
	return status_limit
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk3033.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------