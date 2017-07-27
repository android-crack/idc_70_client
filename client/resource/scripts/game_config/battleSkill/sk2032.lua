----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillPassive = require("module/battleAttrs/skill_passive")

cls_sk2032 = class("cls_sk2032", clsSkillPassive);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk2032.get_skill_id = function(self)
	return "sk2032";
end


-- 技能名 
cls_sk2032.get_skill_name = function(self)
	return T("锚击");
end

-- 精简版技能描述 
cls_sk2032.get_skill_short_desc = function(self)
	return T("提升技能伤害，技能满级时将限制对方移动5秒");
end

-- 获取技能的描述
cls_sk2032.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("提升%0.1f%%技能伤害，技能满级时将限制对方移动5秒"), (7*lv))
end

-- 获取技能的富文本描述
cls_sk2032.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)提升【钩锁】$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)技能伤害"), (7*lv))
end

-- 公共CD 
cls_sk2032.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk2032._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk2032.get_status_limit = function(self)
	return status_limit
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk2032.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------