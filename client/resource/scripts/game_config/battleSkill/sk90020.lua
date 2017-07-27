----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90020 = class("cls_sk90020", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90020.get_skill_id = function(self)
	return "sk90020";
end


-- 技能名 
cls_sk90020.get_skill_name = function(self)
	return T("突击（希腊火）释放");
end

-- 获取技能的描述
cls_sk90020.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90020.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最大施法限制距离
cls_sk90020.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=320
	result = 320;

	return result
end

-- SP消耗公式
cls_sk90020.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk90020_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk90020_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk90020_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk90020_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk90020_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk90020_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk90020_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础近战伤害*(1.5+技能等级*0.1)/2
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1.5+lv*0.1)/2;
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end

-- 前置动作[无法治疗]
local sk90020_pre_action_never_heal_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk90020_select_cnt_never_heal_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk90020_unselect_status_never_heal_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk90020_status_time_never_heal_1 = function(attacker, lv)
	return 
6
end

-- 状态心跳[无法治疗]
local sk90020_status_break_never_heal_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk90020_status_rate_never_heal_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk90020_calc_status_never_heal_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90020.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90020_calc_status_attack_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90020_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk90020_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk90020_status_break_attack_0, 
		["status_rate"]=sk90020_status_rate_attack_0, 
		["status_time"]=sk90020_status_time_attack_0, 
		["unselect_status"]=sk90020_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk90020_calc_status_never_heal_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90020_pre_action_never_heal_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90020_select_cnt_never_heal_1, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk90020_status_break_never_heal_1, 
		["status_rate"]=sk90020_status_rate_never_heal_1, 
		["status_time"]=sk90020_status_time_never_heal_1, 
		["unselect_status"]=sk90020_unselect_status_never_heal_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90020.get_skill_type = function(self)
    return "auto"
end

cls_sk90020.get_skill_lv = function(self, attacker)
	return cls_sk24001:get_skill_lv( attacker )
end
