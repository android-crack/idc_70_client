----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk11006 = class("cls_sk11006", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk11006.get_skill_id = function(self)
	return "sk11006";
end


-- 技能名 
cls_sk11006.get_skill_name = function(self)
	return T("齐射（散射）");
end

-- 精简版技能描述 
cls_sk11006.get_skill_short_desc = function(self)
	return T("对射程内所有敌方造成大量远程伤害，并增加燃烧状态。");
end

-- 获取技能的描述
cls_sk11006.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内所有敌方造成%0.1f%%远程伤害，增加持续8秒的燃烧状态，每秒伤害%0.1f%%远程伤害。"), (350+lv*20), (10+lv*2))
end

-- 获取技能的富文本描述
cls_sk11006.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对所有敌方造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)伤害，增加持续8秒%0.1f%%伤害的燃烧状态。"), (350+lv*20), (lv*40))
end

-- 公共CD 
cls_sk11006.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk11006._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=3
	result = 3;

	return result
end

-- 技能触发概率
cls_sk11006.get_skill_rate = function(self, attacker)
	local result
	
	-- 公式原文:结果=200
	result = 200;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk11006.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk11006.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk11006.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk11006.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 开火音效 
cls_sk11006.get_fire_music = function(self)
	return "BT_SALVO_SHOT_1";
end


-- 受击音效 
cls_sk11006.get_hit_music = function(self)
	return "BT_SALVO_HIT_1";
end


-- 受击特效预加载 
cls_sk11006.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk11006_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk11006_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk11006_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk11006_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk11006_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk11006_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk11006_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=基础远程伤害*(3.5+技能等级*0.2)/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(3.5+lv*0.2)/3;
	-- 公式原文:击杀回血数值=250*取整(sk11006_SkillLv/sk11006_MAX_SkillLv)
	tbResult.kill_huixue_value = 250*math.floor(attacker:getSkillLv("sk11006")/attacker:getSkillLv("sk11006_MAX"));

	return tbResult
end

-- 前置动作[扣血]
local sk11006_pre_action_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk11006_select_cnt_sub_hp_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血]
local sk11006_unselect_status_sub_hp_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血]
local sk11006_status_time_sub_hp_1 = function(attacker, lv)
	return 
8
end

-- 状态心跳[扣血]
local sk11006_status_break_sub_hp_1 = function(attacker, lv)
	return 
1
end

-- 命中率公式[扣血]
local sk11006_status_rate_sub_hp_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[扣血]
local sk11006_calc_status_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础远程伤害*0.4/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*0.4/3;
	-- 公式原文:击杀回血数值=250*取整(sk11006_SkillLv/sk11006_MAX_SkillLv)
	tbResult.kill_huixue_value = 250*math.floor(attacker:getSkillLv("sk11006")/attacker:getSkillLv("sk11006_MAX"));

	return tbResult
end

-- 前置动作[无法治疗]
local sk11006_pre_action_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk11006_select_cnt_never_heal_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk11006_unselect_status_never_heal_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk11006_status_time_never_heal_2 = function(attacker, lv)
	return 
8
end

-- 状态心跳[无法治疗]
local sk11006_status_break_never_heal_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk11006_status_rate_never_heal_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk11006_calc_status_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk11006.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk11006_calc_status_attack_0, 
		["effect_name"]="qishe_3", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk11006_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk11006_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk11006_status_break_attack_0, 
		["status_rate"]=sk11006_status_rate_attack_0, 
		["status_time"]=sk11006_status_time_attack_0, 
		["unselect_status"]=sk11006_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk11006_calc_status_sub_hp_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk11006_pre_action_sub_hp_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk11006_select_cnt_sub_hp_1, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk11006_status_break_sub_hp_1, 
		["status_rate"]=sk11006_status_rate_sub_hp_1, 
		["status_time"]=sk11006_status_time_sub_hp_1, 
		["unselect_status"]=sk11006_unselect_status_sub_hp_1, 
	}, 
	{
		["calc_status"]=sk11006_calc_status_never_heal_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk11006_pre_action_never_heal_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk11006_select_cnt_never_heal_2, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk11006_status_break_never_heal_2, 
		["status_rate"]=sk11006_status_rate_never_heal_2, 
		["status_time"]=sk11006_status_time_never_heal_2, 
		["unselect_status"]=sk11006_unselect_status_never_heal_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
