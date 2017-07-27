----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99008 = class("cls_sk99008", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99008.get_skill_id = function(self)
	return "sk99008";
end


-- 技能名 
cls_sk99008.get_skill_name = function(self)
	return T("BOSS链弹(1)");
end

-- 获取技能的描述
cls_sk99008.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内敌方造成%0.1f%%远程伤害，并击退对方"), (100+lv*100))
end

-- 获取技能的富文本描述
cls_sk99008.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，技能效果加成100%")
end

-- 公共CD 
cls_sk99008.get_common_cd = function(self)
	return 0;
end


-- SP消耗公式
cls_sk99008.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk99008.get_preload_hit_effect = function(self)
	return "tx_newliandan_hit";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk99008_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=50
	tbResult.translate = 50;

	return tbResult
end

-- 目标选择基础数量[攻击]
local sk99008_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk99008_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk99008_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk99008_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk99008_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk99008_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_newliandan_hit"
	tbResult.hit_effect = "tx_newliandan_hit";
	-- 公式原文:扣血=基础远程伤害*(1+技能等级)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1+lv);
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=1
	tbResult.shake_range = 1;

	return tbResult
end

-- 前置动作[减速]
local sk99008_pre_action_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减速]
local sk99008_select_cnt_slow_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减速]
local sk99008_unselect_status_slow_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减速]
local sk99008_status_time_slow_1 = function(attacker, lv)
	return 
5
end

-- 状态心跳[减速]
local sk99008_status_break_slow_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减速]
local sk99008_status_rate_slow_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减速]
local sk99008_calc_status_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:减速=50
	tbResult.sub_speed = 50;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99008.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99008_calc_status_attack_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99008_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99008_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk99008_status_break_attack_0, 
		["status_rate"]=sk99008_status_rate_attack_0, 
		["status_time"]=sk99008_status_time_attack_0, 
		["unselect_status"]=sk99008_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk99008_calc_status_slow_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99008_pre_action_slow_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99008_select_cnt_slow_1, 
		["sort_method"]="", 
		["status"]="slow", 
		["status_break"]=sk99008_status_break_slow_1, 
		["status_rate"]=sk99008_status_rate_slow_1, 
		["status_time"]=sk99008_status_time_slow_1, 
		["unselect_status"]=sk99008_unselect_status_slow_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------