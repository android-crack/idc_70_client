----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99016 = class("cls_sk99016", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99016.get_skill_id = function(self)
	return "sk99016";
end


-- 技能名 
cls_sk99016.get_skill_name = function(self)
	return T("boss突进（冲刺）");
end

-- 精简版技能描述 
cls_sk99016.get_skill_short_desc = function(self)
	return T("给射程内所有我方增加速度、暴击率12秒，并清除不良状态。");
end

-- 获取技能的描述
cls_sk99016.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("增加射程内所有我方%0.1f%%速度，%0.1f%%暴击几率，持续6秒，并清除不良状态。"), (15+3*lv), (10*lv))
end

-- 获取技能的富文本描述
cls_sk99016.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，速度加成3，暴击率加成10%")
end

-- 公共CD 
cls_sk99016.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk99016._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 技能施法范围 
cls_sk99016.get_select_scope = function(self)
	return "FRIEND";
end


-- 最大施法限制距离
cls_sk99016.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk99016.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加速]
local sk99016_pre_action_fast_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加速]
local sk99016_select_cnt_fast_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加速]
local sk99016_unselect_status_fast_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加速]
local sk99016_status_time_fast_0 = function(attacker, lv)
	return 
12
end

-- 状态心跳[加速]
local sk99016_status_break_fast_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加速]
local sk99016_status_rate_fast_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加速]
local sk99016_calc_status_fast_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:加速=50
	tbResult.add_speed = 50;

	return tbResult
end

-- 前置动作[暴击]
local sk99016_pre_action_baoji_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[暴击]
local sk99016_select_cnt_baoji_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[暴击]
local sk99016_unselect_status_baoji_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[暴击]
local sk99016_status_time_baoji_1 = function(attacker, lv)
	return 
12
end

-- 状态心跳[暴击]
local sk99016_status_break_baoji_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[暴击]
local sk99016_status_rate_baoji_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[暴击]
local sk99016_calc_status_baoji_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:暴击概率=(100*技能等级)
	tbResult.custom_baoji_rate=(100*lv);

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99016.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99016_calc_status_fast_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99016_pre_action_fast_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk99016_select_cnt_fast_0, 
		["sort_method"]="", 
		["status"]="fast", 
		["status_break"]=sk99016_status_break_fast_0, 
		["status_rate"]=sk99016_status_rate_fast_0, 
		["status_time"]=sk99016_status_time_fast_0, 
		["unselect_status"]=sk99016_unselect_status_fast_0, 
	}, 
	{
		["calc_status"]=sk99016_calc_status_baoji_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99016_pre_action_baoji_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99016_select_cnt_baoji_1, 
		["sort_method"]="", 
		["status"]="baoji", 
		["status_break"]=sk99016_status_break_baoji_1, 
		["status_rate"]=sk99016_status_rate_baoji_1, 
		["status_time"]=sk99016_status_time_baoji_1, 
		["unselect_status"]=sk99016_unselect_status_baoji_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------