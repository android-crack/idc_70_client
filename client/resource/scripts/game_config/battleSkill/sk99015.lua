----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99015 = class("cls_sk99015", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99015.get_skill_id = function(self)
	return "sk99015";
end


-- 技能名 
cls_sk99015.get_skill_name = function(self)
	return T("boss齐射（散射）");
end

-- 精简版技能描述 
cls_sk99015.get_skill_short_desc = function(self)
	return T("对射程内所有敌方造成大量远程伤害，并增加燃烧状态。");
end

-- 获取技能的描述
cls_sk99015.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内所有敌方造成%0.1f%%远程伤害。"), (250+lv*100))
end

-- 获取技能的富文本描述
cls_sk99015.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，技能效果加成100%")
end

-- 公共CD 
cls_sk99015.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk99015._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk99015.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99015.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk99015.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk99015.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk99015.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk99015_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk99015_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk99015_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk99015_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk99015_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk99015_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk99015_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=基础远程伤害*(2.5+技能等级*0.3)/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(2.5+lv*0.3)/3;

	return tbResult
end

-- 前置动作[火焰喷射特效]
local sk99015_pre_action_jet_flame_effect_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[火焰喷射特效]
local sk99015_select_cnt_jet_flame_effect_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[火焰喷射特效]
local sk99015_unselect_status_jet_flame_effect_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[火焰喷射特效]
local sk99015_status_time_jet_flame_effect_1 = function(attacker, lv)
	return 
1
end

-- 状态心跳[火焰喷射特效]
local sk99015_status_break_jet_flame_effect_1 = function(attacker, lv)
	return 
1
end

-- 命中率公式[火焰喷射特效]
local sk99015_status_rate_jet_flame_effect_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[火焰喷射特效]
local sk99015_calc_status_jet_flame_effect_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[无法治疗]
local sk99015_pre_action_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk99015_select_cnt_never_heal_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk99015_unselect_status_never_heal_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk99015_status_time_never_heal_2 = function(attacker, lv)
	return 
1
end

-- 状态心跳[无法治疗]
local sk99015_status_break_never_heal_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk99015_status_rate_never_heal_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk99015_calc_status_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99015.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99015_calc_status_attack_0, 
		["effect_name"]="qishe_3", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk99015_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99015_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk99015_status_break_attack_0, 
		["status_rate"]=sk99015_status_rate_attack_0, 
		["status_time"]=sk99015_status_time_attack_0, 
		["unselect_status"]=sk99015_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk99015_calc_status_jet_flame_effect_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99015_pre_action_jet_flame_effect_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99015_select_cnt_jet_flame_effect_1, 
		["sort_method"]="", 
		["status"]="jet_flame_effect", 
		["status_break"]=sk99015_status_break_jet_flame_effect_1, 
		["status_rate"]=sk99015_status_rate_jet_flame_effect_1, 
		["status_time"]=sk99015_status_time_jet_flame_effect_1, 
		["unselect_status"]=sk99015_unselect_status_jet_flame_effect_1, 
	}, 
	{
		["calc_status"]=sk99015_calc_status_never_heal_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99015_pre_action_never_heal_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99015_select_cnt_never_heal_2, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk99015_status_break_never_heal_2, 
		["status_rate"]=sk99015_status_rate_never_heal_2, 
		["status_time"]=sk99015_status_time_never_heal_2, 
		["unselect_status"]=sk99015_unselect_status_never_heal_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------