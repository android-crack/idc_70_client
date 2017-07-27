----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk12003 = class("cls_sk12003", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk12003.get_skill_id = function(self)
	return "sk12003";
end


-- 技能名 
cls_sk12003.get_skill_name = function(self)
	return T("链弹（燃火）");
end

-- 精简版技能描述 
cls_sk12003.get_skill_short_desc = function(self)
	return T("对射程内所有敌方造成远程伤害，使其减速、无法被治疗并持续受到伤害。");
end

-- 获取技能的描述
cls_sk12003.get_skill_desc = function(self, skill_data, lv)
	return T("对射程内所有敌方造成远程伤害，使其减速、无法被治疗并持续受到伤害。")
end

-- 获取技能的富文本描述
cls_sk12003.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)对射程内所有敌方造成远程伤害，使其减速、无法被治疗并持续受到伤害。")
end

-- 公共CD 
cls_sk12003.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk12003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=15
	result = 15;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk12003.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk12003.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk12003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk12003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击音效 
cls_sk12003.get_hit_music = function(self)
	return "BT_CHAIN_HIT";
end


-- 受击特效预加载 
cls_sk12003.get_preload_hit_effect = function(self)
	return "tx_yanhua_boom";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk12003_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk12003_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk12003_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk12003_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk12003_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk12003_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk12003_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_yanhua_boom"
	tbResult.hit_effect = "tx_yanhua_boom";
	-- 公式原文:扣血=基础远程伤害*(1+技能等级*0.1)/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1+lv*0.1)/3;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=1
	tbResult.shake_range = 1;

	return tbResult
end

-- 前置动作[减速]
local sk12003_pre_action_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减速]
local sk12003_select_cnt_slow_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减速]
local sk12003_unselect_status_slow_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减速]
local sk12003_status_time_slow_1 = function(attacker, lv)
	return 
6
end

-- 状态心跳[减速]
local sk12003_status_break_slow_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减速]
local sk12003_status_rate_slow_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减速]
local sk12003_calc_status_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的速度
	local iTSpeed = target:getSpeed();

	-- 公式原文:减速=T速度*(0.3+技能等级*0.05)
	tbResult.sub_speed = iTSpeed*(0.3+lv*0.05);

	return tbResult
end

-- 前置动作[扣血]
local sk12003_pre_action_sub_hp_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk12003_select_cnt_sub_hp_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血]
local sk12003_unselect_status_sub_hp_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血]
local sk12003_status_time_sub_hp_2 = function(attacker, lv)
	return 
6
end

-- 状态心跳[扣血]
local sk12003_status_break_sub_hp_2 = function(attacker, lv)
	return 
1
end

-- 命中率公式[扣血]
local sk12003_status_rate_sub_hp_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[扣血]
local sk12003_calc_status_sub_hp_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础远程伤害*(0.25+技能等级*0.05)/6
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(0.25+lv*0.05)/6;

	return tbResult
end

-- 前置动作[无法治疗]
local sk12003_pre_action_never_heal_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk12003_select_cnt_never_heal_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk12003_unselect_status_never_heal_3 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk12003_status_time_never_heal_3 = function(attacker, lv)
	return 
6
end

-- 状态心跳[无法治疗]
local sk12003_status_break_never_heal_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk12003_status_rate_never_heal_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk12003_calc_status_never_heal_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk12003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk12003_calc_status_attack_0, 
		["effect_name"]="liandan", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk12003_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk12003_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk12003_status_break_attack_0, 
		["status_rate"]=sk12003_status_rate_attack_0, 
		["status_time"]=sk12003_status_time_attack_0, 
		["unselect_status"]=sk12003_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk12003_calc_status_slow_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12003_pre_action_slow_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk12003_select_cnt_slow_1, 
		["sort_method"]="", 
		["status"]="slow", 
		["status_break"]=sk12003_status_break_slow_1, 
		["status_rate"]=sk12003_status_rate_slow_1, 
		["status_time"]=sk12003_status_time_slow_1, 
		["unselect_status"]=sk12003_unselect_status_slow_1, 
	}, 
	{
		["calc_status"]=sk12003_calc_status_sub_hp_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12003_pre_action_sub_hp_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk12003_select_cnt_sub_hp_2, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk12003_status_break_sub_hp_2, 
		["status_rate"]=sk12003_status_rate_sub_hp_2, 
		["status_time"]=sk12003_status_time_sub_hp_2, 
		["unselect_status"]=sk12003_unselect_status_sub_hp_2, 
	}, 
	{
		["calc_status"]=sk12003_calc_status_never_heal_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12003_pre_action_never_heal_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk12003_select_cnt_never_heal_3, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk12003_status_break_never_heal_3, 
		["status_rate"]=sk12003_status_rate_never_heal_3, 
		["status_time"]=sk12003_status_time_never_heal_3, 
		["unselect_status"]=sk12003_unselect_status_never_heal_3, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
