----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk51003 = class("cls_sk51003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk51003.get_skill_id = function(self)
	return "sk51003";
end


-- 技能名 
cls_sk51003.get_skill_name = function(self)
	return T("远程船B级");
end

-- 获取技能的描述
cls_sk51003.get_skill_desc = function(self, skill_data, lv)
	return T("远程普通攻击可攻击2个目标")
end

-- 获取技能的富文本描述
cls_sk51003.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)远程普通攻击可攻击2个目标")
end

-- 公共CD 
cls_sk51003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk51003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=99999
	result = 99999;

	return result
end

-- 最小施法限制距离
cls_sk51003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk51003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk51003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk51003.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk51003.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk51003.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1500
	result = 1500;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[远程攻击多目标]
local sk51003_pre_action_far_attack_select_cnt_add_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远程攻击多目标]
local sk51003_select_cnt_far_attack_select_cnt_add_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[远程攻击多目标]
local sk51003_unselect_status_far_attack_select_cnt_add_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[远程攻击多目标]
local sk51003_status_time_far_attack_select_cnt_add_0 = function(attacker, lv)
	return 
99999
end

-- 状态心跳[远程攻击多目标]
local sk51003_status_break_far_attack_select_cnt_add_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远程攻击多目标]
local sk51003_status_rate_far_attack_select_cnt_add_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[远程攻击多目标]
local sk51003_calc_status_far_attack_select_cnt_add_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:远程攻击增加目标数量=1
	tbResult.far_att_cnt = 1;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk51003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk51003_calc_status_far_attack_select_cnt_add_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk51003_pre_action_far_attack_select_cnt_add_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk51003_select_cnt_far_attack_select_cnt_add_0, 
		["sort_method"]="", 
		["status"]="far_attack_select_cnt_add", 
		["status_break"]=sk51003_status_break_far_attack_select_cnt_add_0, 
		["status_rate"]=sk51003_status_rate_far_attack_select_cnt_add_0, 
		["status_time"]=sk51003_status_time_far_attack_select_cnt_add_0, 
		["unselect_status"]=sk51003_unselect_status_far_attack_select_cnt_add_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------