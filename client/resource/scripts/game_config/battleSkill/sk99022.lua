----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk99022 = class("cls_sk99022", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99022.get_skill_id = function(self)
	return "sk99022";
end


-- 技能名 
cls_sk99022.get_skill_name = function(self)
	return T("boss愤怒");
end

-- 精简版技能描述 
cls_sk99022.get_skill_short_desc = function(self)
	return T("施法者耐久小于50%时，提升暴击率。");
end

-- 获取技能的描述
cls_sk99022.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("施法者耐久小于50%%时，提升%0.1f%%暴击率。"), (10*lv))
end

-- 获取技能的富文本描述
cls_sk99022.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，技能效果加成10%")
end

-- 公共CD 
cls_sk99022.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk99022._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk99022.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk99022.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk99022.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[暴击]
local sk99022_pre_action_baoji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[暴击]
local sk99022_select_cnt_baoji_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[暴击]
local sk99022_unselect_status_baoji_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[暴击]
local sk99022_status_time_baoji_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[暴击]
local sk99022_status_break_baoji_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[暴击]
local sk99022_status_rate_baoji_0 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iARemainHP = attacker:getHp();

	-- 公式原文:结果=2000*取整((A耐久上限-A剩余耐久)*2/A耐久上限)
	result = 2000*math.floor((iAHpLimit-iARemainHP)*2/iAHpLimit);

	return result
end

-- 处理过程[暴击]
local sk99022_calc_status_baoji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:暴击概率=(100*技能等级)
	tbResult.custom_baoji_rate=(100*lv);

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99022.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99022_calc_status_baoji_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99022_pre_action_baoji_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk99022_select_cnt_baoji_0, 
		["sort_method"]="", 
		["status"]="baoji", 
		["status_break"]=sk99022_status_break_baoji_0, 
		["status_rate"]=sk99022_status_rate_baoji_0, 
		["status_time"]=sk99022_status_time_baoji_0, 
		["unselect_status"]=sk99022_unselect_status_baoji_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------