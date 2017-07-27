----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90029 = class("cls_sk90029", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90029.get_skill_id = function(self)
	return "sk90029";
end


-- 技能名 
cls_sk90029.get_skill_name = function(self)
	return T("S分身自爆释放");
end

-- 获取技能的描述
cls_sk90029.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90029.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 技能CD
cls_sk90029._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk90029.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk90029.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk90029.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=200
	result = 200;

	return result
end

-- SP消耗公式
cls_sk90029.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk90029.get_preload_hit_effect = function(self)
	return "tx_judian_boom";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk90029_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk90029_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk90029_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk90029_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk90029_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk90029_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk90029_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:受击特效="tx_judian_boom"
	tbResult.hit_effect = "tx_judian_boom";
	-- 公式原文:扣血=A耐久上限*0.4
	tbResult.sub_hp = iAHpLimit*0.4;
	-- 公式原文:震屏幅度=4
	tbResult.shake_range = 4;
	-- 公式原文:震屏次数=7
	tbResult.shake_time = 7;
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end

-- 前置动作[扣血_2]
local sk90029_pre_action_sub_hp_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血_2]
local sk90029_select_cnt_sub_hp_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血_2]
local sk90029_unselect_status_sub_hp_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血_2]
local sk90029_status_time_sub_hp_2_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[扣血_2]
local sk90029_status_break_sub_hp_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[扣血_2]
local sk90029_status_rate_sub_hp_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[扣血_2]
local sk90029_calc_status_sub_hp_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:受击特效="tx_judian_boom"
	tbResult.hit_effect = "tx_judian_boom";
	-- 公式原文:扣血=A耐久上限
	tbResult.sub_hp = iAHpLimit;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90029.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90029_calc_status_attack_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90029_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk90029_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk90029_status_break_attack_0, 
		["status_rate"]=sk90029_status_rate_attack_0, 
		["status_time"]=sk90029_status_time_attack_0, 
		["unselect_status"]=sk90029_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk90029_calc_status_sub_hp_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90029_pre_action_sub_hp_2_1, 
		["scope"]="SELF", 
		["select_cnt"]=sk90029_select_cnt_sub_hp_2_1, 
		["sort_method"]="", 
		["status"]="sub_hp_2", 
		["status_break"]=sk90029_status_break_sub_hp_2_1, 
		["status_rate"]=sk90029_status_rate_sub_hp_2_1, 
		["status_time"]=sk90029_status_time_sub_hp_2_1, 
		["unselect_status"]=sk90029_unselect_status_sub_hp_2_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------