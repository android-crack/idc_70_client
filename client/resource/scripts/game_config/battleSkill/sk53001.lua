----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk53001 = class("cls_sk53001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk53001.get_skill_id = function(self)
	return "sk53001";
end


-- 技能名 
cls_sk53001.get_skill_name = function(self)
	return T("辅助船D级");
end

-- 获取技能的描述
cls_sk53001.get_skill_desc = function(self, skill_data, lv)
	return T("远程攻击射程内，我方目标怒气恢复每秒恢复2点")
end

-- 获取技能的富文本描述
cls_sk53001.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)远程攻击射程内，我方目标怒气恢复每秒恢复2点")
end

-- 公共CD 
cls_sk53001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk53001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk53001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk53001.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk53001.calc_sp_cost = function(self, attacker, lv, target)
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
cls_sk53001.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------