----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk64003 = class("cls_sk64003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk64003.get_skill_id = function(self)
	return "sk64003";
end


-- 技能名 
cls_sk64003.get_skill_name = function(self)
	return T("荡索III");
end

-- 获取技能的描述
cls_sk64003.get_skill_desc = function(self, skill_data, lv)
	return T("近战攻击距离+100")
end

-- 获取技能的富文本描述
cls_sk64003.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk64003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk64003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk64003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- SP消耗公式
cls_sk64003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[近战攻击距离提升]
local sk64003_pre_action_near_attack_range_up_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[近战攻击距离提升]
local sk64003_select_cnt_near_attack_range_up_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[近战攻击距离提升]
local sk64003_unselect_status_near_attack_range_up_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[近战攻击距离提升]
local sk64003_status_time_near_attack_range_up_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[近战攻击距离提升]
local sk64003_status_break_near_attack_range_up_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[近战攻击距离提升]
local sk64003_status_rate_near_attack_range_up_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[近战攻击距离提升]
local sk64003_calc_status_near_attack_range_up_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:近战攻击距离提升=100
	tbResult.add_near_att_range = 100;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk64003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk64003_calc_status_near_attack_range_up_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk64003_pre_action_near_attack_range_up_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk64003_select_cnt_near_attack_range_up_0, 
		["sort_method"]="", 
		["status"]="near_attack_range_up", 
		["status_break"]=sk64003_status_break_near_attack_range_up_0, 
		["status_rate"]=sk64003_status_rate_near_attack_range_up_0, 
		["status_time"]=sk64003_status_time_near_attack_range_up_0, 
		["unselect_status"]=sk64003_unselect_status_near_attack_range_up_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------