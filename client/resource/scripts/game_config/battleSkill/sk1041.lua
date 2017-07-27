----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk1041 = class("cls_sk1041", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk1041.get_skill_id = function(self)
	return "sk1041";
end


-- 技能名 
cls_sk1041.get_skill_name = function(self)
	return T("炮术");
end

-- 精简版技能描述 
cls_sk1041.get_skill_short_desc = function(self)
	return T("增加远程攻击力");
end

-- 获取技能的描述
cls_sk1041.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("增加%0.1f远程攻击力"), (math.floor((100+(1+math.floor((lv+15)/10))*(100*math.pow(1.07,((lv+15)-1))))*0.15)))
end

-- 获取技能的富文本描述
cls_sk1041.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)增加$(c:COLOR_GREEN)%0.1f$(c:COLOR_CAMEL)远程攻击力"), (math.floor((100+(1+math.floor((lv+15)/10))*(100*math.pow(1.07,((lv+15)-1))))*0.15)))
end

-- SP消耗公式
cls_sk1041.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数




-- 操作区

-- 添加状态数据
cls_sk1041.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------