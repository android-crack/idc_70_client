----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90024 = class("cls_sk90024", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90024.get_skill_id = function(self)
	return "sk90024";
end


-- 技能名 
cls_sk90024.get_skill_name = function(self)
	return T("火焰弹施放技能");
end

-- 获取技能的描述
cls_sk90024.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90024.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最大施法限制距离
cls_sk90024.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=300
	result = 300;

	return result
end

-- 受击特效预加载 
cls_sk90024.get_preload_hit_effect = function(self)
	return "tx_judian_boom";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[扣血]
local sk90024_pre_action_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk90024_select_cnt_sub_hp_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[扣血]
local sk90024_unselect_status_sub_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[扣血]
local sk90024_status_time_sub_hp_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[扣血]
local sk90024_status_break_sub_hp_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[扣血]
local sk90024_status_rate_sub_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[扣血]
local sk90024_calc_status_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_judian_boom"
	tbResult.hit_effect = "tx_judian_boom";
	-- 公式原文:扣血=基础远程伤害*(0.025*sk1052_SkillLv+0.035*sk1053_SkillLv)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(0.025*attacker:getSkillLv("sk1052")+0.035*attacker:getSkillLv("sk1053"));

	return tbResult
end

-- 前置动作[扣血]
local sk90024_pre_action_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk90024_select_cnt_sub_hp_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血]
local sk90024_unselect_status_sub_hp_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血]
local sk90024_status_time_sub_hp_1 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 状态心跳[扣血]
local sk90024_status_break_sub_hp_1 = function(attacker, lv)
	return 
1
end

-- 命中率公式[扣血]
local sk90024_status_rate_sub_hp_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[扣血]
local sk90024_calc_status_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_judian_boom"
	tbResult.hit_effect = "tx_judian_boom";
	-- 公式原文:扣血=基础远程伤害*(0.4+0.01*技能等级+0.025*sk1052_SkillLv+0.035*sk1053_SkillLv)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(0.4+0.01*lv+0.025*attacker:getSkillLv("sk1052")+0.035*attacker:getSkillLv("sk1053"));

	return tbResult
end

-- 前置动作[无法治疗]
local sk90024_pre_action_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk90024_select_cnt_never_heal_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk90024_unselect_status_never_heal_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk90024_status_time_never_heal_2 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 状态心跳[无法治疗]
local sk90024_status_break_never_heal_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk90024_status_rate_never_heal_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk90024_calc_status_never_heal_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90024.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90024_calc_status_sub_hp_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90024_pre_action_sub_hp_0, 
		["scope"]="FRIEND_OTHER", 
		["select_cnt"]=sk90024_select_cnt_sub_hp_0, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk90024_status_break_sub_hp_0, 
		["status_rate"]=sk90024_status_rate_sub_hp_0, 
		["status_time"]=sk90024_status_time_sub_hp_0, 
		["unselect_status"]=sk90024_unselect_status_sub_hp_0, 
	}, 
	{
		["calc_status"]=sk90024_calc_status_sub_hp_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90024_pre_action_sub_hp_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90024_select_cnt_sub_hp_1, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk90024_status_break_sub_hp_1, 
		["status_rate"]=sk90024_status_rate_sub_hp_1, 
		["status_time"]=sk90024_status_time_sub_hp_1, 
		["unselect_status"]=sk90024_unselect_status_sub_hp_1, 
	}, 
	{
		["calc_status"]=sk90024_calc_status_never_heal_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90024_pre_action_never_heal_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90024_select_cnt_never_heal_2, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk90024_status_break_never_heal_2, 
		["status_rate"]=sk90024_status_rate_never_heal_2, 
		["status_time"]=sk90024_status_time_never_heal_2, 
		["unselect_status"]=sk90024_unselect_status_never_heal_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90024.get_skill_type = function(self)
    return "auto"
end

cls_sk90024.get_skill_lv = function(self, attacker)
	return cls_sk1051:get_skill_lv( attacker )
end

-- 目标选择函数
cls_sk90024.select_target = function(self, attacker, target, status)
	local battle_data = getGameData():getBattleDataMt()
	local target_ship = battle_data:getShipByGenID(target)

	local t_target = target_ship:getTarget()

	local targets = self:select_scope(target_ship, t_target, status)
	return targets
end