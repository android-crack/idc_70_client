----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99014 = class("cls_sk99014", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99014.get_skill_id = function(self)
	return "sk99014";
end


-- 技能名 
cls_sk99014.get_skill_name = function(self)
	return T("boss火焰喷射释放");
end

-- 获取技能的描述
cls_sk99014.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk99014.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，每秒伤害提升60%，持续3秒")
end

-- SP消耗公式
cls_sk99014.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk99014_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk99014_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk99014_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk99014_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk99014_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk99014_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk99014_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础远程伤害*(0.6*技能等级+0.06*sk1052_SkillLv+0.05*sk1053_SkillLv)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(0.6*lv+0.06*attacker:getSkillLv("sk1052")+0.05*attacker:getSkillLv("sk1053"));

	return tbResult
end

-- 前置动作[攻击]
local sk99014_pre_action_attack_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk99014_select_cnt_attack_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[攻击]
local sk99014_unselect_status_attack_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk99014_status_time_attack_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk99014_status_break_attack_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk99014_status_rate_attack_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk1053_SkillLv/sk1053_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk1053")/attacker:getSkillLv("sk1053_MAX"));

	return result
end

-- 处理过程[攻击]
local sk99014_calc_status_attack_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[火焰喷射特效]
local sk99014_pre_action_jet_flame_effect_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[火焰喷射特效]
local sk99014_select_cnt_jet_flame_effect_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[火焰喷射特效]
local sk99014_unselect_status_jet_flame_effect_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[火焰喷射特效]
local sk99014_status_time_jet_flame_effect_2 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=3+1.5*取整(sk1052_SkillLv/sk1052_MAX_SkillLv)
	result = 3+1.5*math.floor(attacker:getSkillLv("sk1052")/attacker:getSkillLv("sk1052_MAX"));

	return result
end

-- 状态心跳[火焰喷射特效]
local sk99014_status_break_jet_flame_effect_2 = function(attacker, lv)
	return 
1/2
end

-- 命中率公式[火焰喷射特效]
local sk99014_status_rate_jet_flame_effect_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[火焰喷射特效]
local sk99014_calc_status_jet_flame_effect_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[无法治疗]
local sk99014_pre_action_never_heal_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk99014_select_cnt_never_heal_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk99014_unselect_status_never_heal_3 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk99014_status_time_never_heal_3 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=3+1.5*取整(sk1052_SkillLv/sk1052_MAX_SkillLv)
	result = 3+1.5*math.floor(attacker:getSkillLv("sk1052")/attacker:getSkillLv("sk1052_MAX"));

	return result
end

-- 状态心跳[无法治疗]
local sk99014_status_break_never_heal_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk99014_status_rate_never_heal_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk99014_calc_status_never_heal_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99014.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99014_calc_status_attack_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99014_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99014_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk99014_status_break_attack_0, 
		["status_rate"]=sk99014_status_rate_attack_0, 
		["status_time"]=sk99014_status_time_attack_0, 
		["unselect_status"]=sk99014_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk99014_calc_status_attack_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99014_pre_action_attack_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99014_select_cnt_attack_1, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk99014_status_break_attack_1, 
		["status_rate"]=sk99014_status_rate_attack_1, 
		["status_time"]=sk99014_status_time_attack_1, 
		["unselect_status"]=sk99014_unselect_status_attack_1, 
	}, 
	{
		["calc_status"]=sk99014_calc_status_jet_flame_effect_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99014_pre_action_jet_flame_effect_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99014_select_cnt_jet_flame_effect_2, 
		["sort_method"]="", 
		["status"]="jet_flame_effect", 
		["status_break"]=sk99014_status_break_jet_flame_effect_2, 
		["status_rate"]=sk99014_status_rate_jet_flame_effect_2, 
		["status_time"]=sk99014_status_time_jet_flame_effect_2, 
		["unselect_status"]=sk99014_unselect_status_jet_flame_effect_2, 
	}, 
	{
		["calc_status"]=sk99014_calc_status_never_heal_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99014_pre_action_never_heal_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99014_select_cnt_never_heal_3, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk99014_status_break_never_heal_3, 
		["status_rate"]=sk99014_status_rate_never_heal_3, 
		["status_time"]=sk99014_status_time_never_heal_3, 
		["unselect_status"]=sk99014_unselect_status_never_heal_3, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------