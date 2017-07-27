----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk62001 = class("cls_sk62001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk62001.get_skill_id = function(self)
	return "sk62001";
end


-- 技能名 
cls_sk62001.get_skill_name = function(self)
	return T("上膛I");
end

-- 获取技能的描述
cls_sk62001.get_skill_desc = function(self, skill_data, lv)
	return T("远程普攻速度+33%")
end

-- 获取技能的富文本描述
cls_sk62001.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk62001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk62001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk62001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- SP消耗公式
cls_sk62001.calc_sp_cost = function(self, attacker, lv, target)
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
cls_sk62001.get_add_status = function(self)
		return {
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------