----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk1021 = class("cls_sk1021", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk1021.get_skill_id = function(self)
	return "sk1021";
end


-- 技能名 
cls_sk1021.get_skill_name = function(self)
	return T("瞄准齐射");
end

-- 精简版技能描述 
cls_sk1021.get_skill_short_desc = function(self)
	return T("对射程内所有敌方目标造成一定远程伤害，并持续4秒禁疗");
end

-- 获取技能的描述
cls_sk1021.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内所有敌方目标造成%0.1f%%的远程伤害，并禁疗4秒"), (190+lv*6))
end

-- 获取技能的富文本描述
cls_sk1021.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对射程内所有敌方目标造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的远程伤害，并禁疗4秒"), (190+lv*6))
end

-- 公共CD 
cls_sk1021.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk1021._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=15-6*取整(sk1022_SkillLv/sk1022_MAX_SkillLv)
	result = 15-6*math.floor(attacker:getSkillLv("sk1022")/attacker:getSkillLv("sk1022_MAX"));

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk1021.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk1021.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk1021.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk1021.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"sf_qishe", "tx_skillready", }

cls_sk1021.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", "particle_scene", }

cls_sk1021.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk1021.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk1021.get_effect_music = function(self)
	return "BT_SALVO_CASTING";
end


-- 开火音效 
cls_sk1021.get_fire_music = function(self)
	return "BT_SALVO_SHOT_1";
end


-- 受击音效 
cls_sk1021.get_hit_music = function(self)
	return "BT_SALVO_HIT_1";
end


-- 受击特效预加载 
cls_sk1021.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk1021_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk1021_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk1021_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk1021_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk1021_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk1021_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk1021_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=基础远程伤害*(1.9+技能等级*0.06+sk1022_SkillLv*0.09+sk1023_SkillLv*0.12)/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1.9+lv*0.06+attacker:getSkillLv("sk1022")*0.09+attacker:getSkillLv("sk1023")*0.12)/3;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=1
	tbResult.shake_range = 1;

	return tbResult
end

-- 前置动作[减速]
local sk1021_pre_action_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减速]
local sk1021_select_cnt_slow_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减速]
local sk1021_unselect_status_slow_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[减速]
local sk1021_status_time_slow_1 = function(attacker, lv)
	return 
4
end

-- 状态心跳[减速]
local sk1021_status_break_slow_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减速]
local sk1021_status_rate_slow_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk1023_SkillLv/sk1023_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk1023")/attacker:getSkillLv("sk1023_MAX"));

	return result
end

-- 处理过程[减速]
local sk1021_calc_status_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的速度
	local iTSpeed = target:getSpeed();

	-- 公式原文:减速=T速度
	tbResult.sub_speed = iTSpeed;

	return tbResult
end

-- 前置动作[无法治疗]
local sk1021_pre_action_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk1021_select_cnt_never_heal_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk1021_unselect_status_never_heal_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk1021_status_time_never_heal_2 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=4
	result = 4;

	return result
end

-- 状态心跳[无法治疗]
local sk1021_status_break_never_heal_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk1021_status_rate_never_heal_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk1021_calc_status_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk1021.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk1021_calc_status_attack_0, 
		["effect_name"]="putaodan_2", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk1021_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk1021_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk1021_status_break_attack_0, 
		["status_rate"]=sk1021_status_rate_attack_0, 
		["status_time"]=sk1021_status_time_attack_0, 
		["unselect_status"]=sk1021_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk1021_calc_status_slow_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1021_pre_action_slow_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1021_select_cnt_slow_1, 
		["sort_method"]="", 
		["status"]="slow", 
		["status_break"]=sk1021_status_break_slow_1, 
		["status_rate"]=sk1021_status_rate_slow_1, 
		["status_time"]=sk1021_status_time_slow_1, 
		["unselect_status"]=sk1021_unselect_status_slow_1, 
	}, 
	{
		["calc_status"]=sk1021_calc_status_never_heal_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1021_pre_action_never_heal_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1021_select_cnt_never_heal_2, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk1021_status_break_never_heal_2, 
		["status_rate"]=sk1021_status_rate_never_heal_2, 
		["status_time"]=sk1021_status_time_never_heal_2, 
		["unselect_status"]=sk1021_unselect_status_never_heal_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------