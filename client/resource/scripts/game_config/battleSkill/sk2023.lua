----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillPassive = require("module/battleAttrs/skill_passive")

cls_sk2023 = class("cls_sk2023", clsSkillPassive);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk2023.get_skill_id = function(self)
	return "sk2023";
end


-- 技能名 
cls_sk2023.get_skill_name = function(self)
	return T("全员掩护");
end

-- 精简版技能描述 
cls_sk2023.get_skill_short_desc = function(self)
	return T("提高防御效果，技能满级时提升射程内所有友军防御");
end

-- 获取技能的描述
cls_sk2023.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("提高%0.1f%%防御效果，技能满级时提升射程内所有友军防御"), (8*lv))
end

-- 获取技能的富文本描述
cls_sk2023.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)提高【嘲讽】$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)防御效果"), (8*lv))
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk2023.get_status_limit = function(self)
	return status_limit
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk2023.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------