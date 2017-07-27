----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk62002 = class("cls_sk62002", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk62002.get_skill_id = function(self)
	return "sk62002";
end


-- 技能名 
cls_sk62002.get_skill_name = function(self)
	return T("上膛II");
end

-- 获取技能的描述
cls_sk62002.get_skill_desc = function(self, skill_data, lv)
	return T("远程普攻目标+1")
end

-- 获取技能的富文本描述
cls_sk62002.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk62002.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk62002._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk62002.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- SP消耗公式
cls_sk62002.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[远程攻击多目标]
local sk62002_pre_action_far_attack_select_cnt_add_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远程攻击多目标]
local sk62002_select_cnt_far_attack_select_cnt_add_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[远程攻击多目标]
local sk62002_unselect_status_far_attack_select_cnt_add_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[远程攻击多目标]
local sk62002_status_time_far_attack_select_cnt_add_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[远程攻击多目标]
local sk62002_status_break_far_attack_select_cnt_add_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远程攻击多目标]
local sk62002_status_rate_far_attack_select_cnt_add_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[远程攻击多目标]
local sk62002_calc_status_far_attack_select_cnt_add_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:远程攻击增加目标数量=1
	tbResult.far_att_cnt = 1;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk62002.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk62002_calc_status_far_attack_select_cnt_add_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk62002_pre_action_far_attack_select_cnt_add_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk62002_select_cnt_far_attack_select_cnt_add_0, 
		["sort_method"]="", 
		["status"]="far_attack_select_cnt_add", 
		["status_break"]=sk62002_status_break_far_attack_select_cnt_add_0, 
		["status_rate"]=sk62002_status_rate_far_attack_select_cnt_add_0, 
		["status_time"]=sk62002_status_time_far_attack_select_cnt_add_0, 
		["unselect_status"]=sk62002_unselect_status_far_attack_select_cnt_add_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------