----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk43004 = class("cls_sk43004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk43004.get_skill_id = function(self)
	return "sk43004";
end


-- 技能名 
cls_sk43004.get_skill_name = function(self)
	return T("坚如磐石");
end

-- 精简版技能描述 
cls_sk43004.get_skill_short_desc = function(self)
	return T("战斗中提升施法者防御，增加抗暴几率。");
end

-- 获取技能的描述
cls_sk43004.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("战斗中提升施法者防御%0.1f%%，增加抗暴几率50%%。"), (15+2*lv))
end

-- 获取技能的富文本描述
cls_sk43004.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)战斗中提升施法者防御$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)，增加抗暴几率50%%。"), (15+2*lv))
end

-- 公共CD 
cls_sk43004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk43004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk43004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk43004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk43004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加防_2]
local sk43004_pre_action_add_def_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防_2]
local sk43004_select_cnt_add_def_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加防_2]
local sk43004_unselect_status_add_def_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加防_2]
local sk43004_status_time_add_def_2_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加防_2]
local sk43004_status_break_add_def_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防_2]
local sk43004_status_rate_add_def_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加防_2]
local sk43004_calc_status_add_def_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=A防御*(0.15+0.02*技能等级)
	tbResult.add_defend = iADefense*(0.15+0.02*lv);

	return tbResult
end

-- 前置动作[抗暴击_2]
local sk43004_pre_action_kangbaoji_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[抗暴击_2]
local sk43004_select_cnt_kangbaoji_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[抗暴击_2]
local sk43004_unselect_status_kangbaoji_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[抗暴击_2]
local sk43004_status_time_kangbaoji_2_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[抗暴击_2]
local sk43004_status_break_kangbaoji_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[抗暴击_2]
local sk43004_status_rate_kangbaoji_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[抗暴击_2]
local sk43004_calc_status_kangbaoji_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:抗暴概率=500
	tbResult.kangbaogailv_rate = 500;

	return tbResult
end

-- 前置动作[坚如磐石]
local sk43004_pre_action_jianrupanshi_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[坚如磐石]
local sk43004_select_cnt_jianrupanshi_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[坚如磐石]
local sk43004_unselect_status_jianrupanshi_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[坚如磐石]
local sk43004_status_time_jianrupanshi_2 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[坚如磐石]
local sk43004_status_break_jianrupanshi_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[坚如磐石]
local sk43004_status_rate_jianrupanshi_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk43004_SkillLv/sk43004_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk43004")/attacker:getSkillLv("sk43004_MAX"));

	return result
end

-- 处理过程[坚如磐石]
local sk43004_calc_status_jianrupanshi_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk43004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk43004_calc_status_add_def_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43004_pre_action_add_def_2_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk43004_select_cnt_add_def_2_0, 
		["sort_method"]="", 
		["status"]="add_def_2", 
		["status_break"]=sk43004_status_break_add_def_2_0, 
		["status_rate"]=sk43004_status_rate_add_def_2_0, 
		["status_time"]=sk43004_status_time_add_def_2_0, 
		["unselect_status"]=sk43004_unselect_status_add_def_2_0, 
	}, 
	{
		["calc_status"]=sk43004_calc_status_kangbaoji_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43004_pre_action_kangbaoji_2_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk43004_select_cnt_kangbaoji_2_1, 
		["sort_method"]="", 
		["status"]="kangbaoji_2", 
		["status_break"]=sk43004_status_break_kangbaoji_2_1, 
		["status_rate"]=sk43004_status_rate_kangbaoji_2_1, 
		["status_time"]=sk43004_status_time_kangbaoji_2_1, 
		["unselect_status"]=sk43004_unselect_status_kangbaoji_2_1, 
	}, 
	{
		["calc_status"]=sk43004_calc_status_jianrupanshi_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43004_pre_action_jianrupanshi_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk43004_select_cnt_jianrupanshi_2, 
		["sort_method"]="DISTANCE_ASEC", 
		["status"]="jianrupanshi", 
		["status_break"]=sk43004_status_break_jianrupanshi_2, 
		["status_rate"]=sk43004_status_rate_jianrupanshi_2, 
		["status_time"]=sk43004_status_time_jianrupanshi_2, 
		["unselect_status"]=sk43004_unselect_status_jianrupanshi_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
