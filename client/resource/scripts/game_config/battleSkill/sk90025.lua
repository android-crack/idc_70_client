----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90025 = class("cls_sk90025", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90025.get_skill_id = function(self)
	return "sk90025";
end


-- 技能名 
cls_sk90025.get_skill_name = function(self)
	return T("海神祝福");
end

-- 获取技能的描述
cls_sk90025.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90025.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最大施法限制距离
cls_sk90025.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=400
	result = 400;

	return result
end

-- SP消耗公式
cls_sk90025.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk90025.get_preload_hit_effect = function(self)
	return "tx_haizizhufu_shouji";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[扣血]
local sk90025_pre_action_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk90025_select_cnt_sub_hp_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[扣血]
local sk90025_unselect_status_sub_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[扣血]
local sk90025_status_time_sub_hp_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[扣血]
local sk90025_status_break_sub_hp_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[扣血]
local sk90025_status_rate_sub_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[扣血]
local sk90025_calc_status_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:受击特效="tx_haizizhufu_shouji"
	tbResult.hit_effect = "tx_haizizhufu_shouji";
	-- 公式原文:扣血=((4+技能等级*0.1)*A耐久上限*0.01)/2
	tbResult.sub_hp = ((4+lv*0.1)*iAHpLimit*0.01)/2;

	return tbResult
end

-- 前置动作[加血]
local sk90025_pre_action_add_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血]
local sk90025_select_cnt_add_hp_1 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加血]
local sk90025_unselect_status_add_hp_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加血]
local sk90025_status_time_add_hp_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[加血]
local sk90025_status_break_add_hp_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加血]
local sk90025_status_rate_add_hp_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加血]
local sk90025_calc_status_add_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=(4+技能等级*0.1+sk3052_SkillLv*0.15+sk3053_SkillLv*0.2)*A耐久上限*0.01
	tbResult.add_hp = (4+lv*0.1+attacker:getSkillLv("sk3052")*0.15+attacker:getSkillLv("sk3053")*0.2)*iAHpLimit*0.01;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90025.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90025_calc_status_sub_hp_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90025_pre_action_sub_hp_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk90025_select_cnt_sub_hp_0, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk90025_status_break_sub_hp_0, 
		["status_rate"]=sk90025_status_rate_sub_hp_0, 
		["status_time"]=sk90025_status_time_sub_hp_0, 
		["unselect_status"]=sk90025_unselect_status_sub_hp_0, 
	}, 
	{
		["calc_status"]=sk90025_calc_status_add_hp_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90025_pre_action_add_hp_1, 
		["scope"]="ALL_FRIEND", 
		["select_cnt"]=sk90025_select_cnt_add_hp_1, 
		["sort_method"]="", 
		["status"]="add_hp", 
		["status_break"]=sk90025_status_break_add_hp_1, 
		["status_rate"]=sk90025_status_rate_add_hp_1, 
		["status_time"]=sk90025_status_time_add_hp_1, 
		["unselect_status"]=sk90025_unselect_status_add_hp_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90025.get_skill_type = function(self)
    return "auto"
end

cls_sk90025.get_skill_lv = function(self, attacker)
	return cls_sk3051:get_skill_lv( attacker )
end

cls_sk90025.end_display_call_back = function(self, attacker, target, tbIdx, dir, is_bullet)
	cls_sk90025.super.end_display_call_back(self, attacker, target, tbIdx, dir, true)
end