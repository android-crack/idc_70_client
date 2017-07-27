----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90007b = class("cls_sk90007b", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90007b.get_skill_id = function(self)
	return "sk90007b";
end


-- 技能名 
cls_sk90007b.get_skill_name = function(self)
	return T("鼓舞士气释放全屏");
end

-- 获取技能的描述
cls_sk90007b.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90007b.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最小施法限制距离
cls_sk90007b.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk90007b.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk90007b.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90007b.get_skill_type = function(self)
    return "auto"
end

cls_sk90007b.get_skill_lv = function(self, attacker)
	return cls_sk41004:get_skill_lv( attacker )
end