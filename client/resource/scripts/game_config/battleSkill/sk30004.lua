----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk30004 = class("cls_sk30004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk30004.get_skill_id = function(self)
	return "sk30004";
end


-- 技能名 
cls_sk30004.get_skill_name = function(self)
	return T("无敌");
end

-- 获取技能的描述
cls_sk30004.get_skill_desc = function(self, skill_data, lv)
	return T("无法受到伤害。")
end

-- 获取技能的富文本描述
cls_sk30004.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)无法受到伤害。")
end

-- 公共CD 
cls_sk30004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk30004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk30004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk30004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=500
	result = 500;

	return result
end

-- SP消耗公式
cls_sk30004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[无敌]
local sk30004_pre_action_wudi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无敌]
local sk30004_select_cnt_wudi_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[无敌]
local sk30004_unselect_status_wudi_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无敌]
local sk30004_status_time_wudi_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[无敌]
local sk30004_status_break_wudi_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无敌]
local sk30004_status_rate_wudi_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无敌]
local sk30004_calc_status_wudi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[无敌_2]
local sk30004_pre_action_wudi_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无敌_2]
local sk30004_select_cnt_wudi_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无敌_2]
local sk30004_unselect_status_wudi_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无敌_2]
local sk30004_status_time_wudi_2_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[无敌_2]
local sk30004_status_break_wudi_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无敌_2]
local sk30004_status_rate_wudi_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无敌_2]
local sk30004_calc_status_wudi_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk30004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk30004_calc_status_wudi_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk30004_pre_action_wudi_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk30004_select_cnt_wudi_0, 
		["sort_method"]="", 
		["status"]="wudi", 
		["status_break"]=sk30004_status_break_wudi_0, 
		["status_rate"]=sk30004_status_rate_wudi_0, 
		["status_time"]=sk30004_status_time_wudi_0, 
		["unselect_status"]=sk30004_unselect_status_wudi_0, 
	}, 
	{
		["calc_status"]=sk30004_calc_status_wudi_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk30004_pre_action_wudi_2_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk30004_select_cnt_wudi_2_1, 
		["sort_method"]="", 
		["status"]="wudi_2", 
		["status_break"]=sk30004_status_break_wudi_2_1, 
		["status_rate"]=sk30004_status_rate_wudi_2_1, 
		["status_time"]=sk30004_status_time_wudi_2_1, 
		["unselect_status"]=sk30004_unselect_status_wudi_2_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------