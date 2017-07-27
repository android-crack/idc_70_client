----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillPassive = require("module/battleAttrs/skill_passive")

cls_sk1023 = class("cls_sk1023", clsSkillPassive);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk1023.get_skill_id = function(self)
	return "sk1023";
end


-- 技能名 
cls_sk1023.get_skill_name = function(self)
	return T("火力配置");
end

-- 精简版技能描述 
cls_sk1023.get_skill_short_desc = function(self)
	return T("增加技能伤害，技能满级时使敌方无法移动4秒");
end

-- 获取技能的描述
cls_sk1023.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("增加%0.1f%%技能伤害，技能满级时使敌方无法移动4秒"), (lv*12))
end

-- 获取技能的富文本描述
cls_sk1023.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)增加【瞄准齐射】$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)技能伤害"), (lv*12))
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk1023.get_status_limit = function(self)
	return status_limit
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk1023.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------