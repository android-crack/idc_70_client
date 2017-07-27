----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillPassive = require("module/battleAttrs/skill_passive")

cls_sk3023 = class("cls_sk3023", clsSkillPassive);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk3023.get_skill_id = function(self)
	return "sk3023";
end


-- 技能名 
cls_sk3023.get_skill_name = function(self)
	return T("眩晕分身");
end

-- 精简版技能描述 
cls_sk3023.get_skill_short_desc = function(self)
	return T("提高召唤船只的属性，技能满级时召唤的船只拥有贯通射击技能");
end

-- 获取技能的描述
cls_sk3023.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("提高召唤船只%0.1f%%的属性，技能满级时召唤的船只拥有贯通射击技能"), (4*lv))
end

-- 获取技能的富文本描述
cls_sk3023.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)提高【分身】召唤船只$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的属性"), (4*lv))
end

-- 公共CD 
cls_sk3023.get_common_cd = function(self)
	return 1;
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk3023.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------