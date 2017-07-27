----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90004 = class("cls_sk90004", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90004.get_skill_id = function(self)
	return "sk90004";
end


-- 技能名 
cls_sk90004.get_skill_name = function(self)
	return T("掌舵释放");
end

-- 获取技能的描述
cls_sk90004.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90004.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最小施法限制距离
cls_sk90004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk90004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加速_2]
local sk90004_pre_action_fast_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加速_2]
local sk90004_select_cnt_fast_2_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加速_2]
local sk90004_unselect_status_fast_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加速_2]
local sk90004_status_time_fast_2_0 = function(attacker, lv)
	return 
2
end

-- 状态心跳[加速_2]
local sk90004_status_break_fast_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加速_2]
local sk90004_status_rate_fast_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加速_2]
local sk90004_calc_status_fast_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:加速=5+1*技能等级
	tbResult.add_speed = 5+1*lv;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90004_calc_status_fast_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90004_pre_action_fast_2_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk90004_select_cnt_fast_2_0, 
		["sort_method"]="", 
		["status"]="fast_2", 
		["status_break"]=sk90004_status_break_fast_2_0, 
		["status_rate"]=sk90004_status_rate_fast_2_0, 
		["status_time"]=sk90004_status_time_fast_2_0, 
		["unselect_status"]=sk90004_unselect_status_fast_2_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90004.get_skill_type = function(self)
    return "auto"
end

cls_sk90004.get_skill_lv = function(self, attacker)
	return cls_sk44006:get_skill_lv( attacker )
end
