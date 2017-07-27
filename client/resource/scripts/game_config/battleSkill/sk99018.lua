----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99018 = class("cls_sk99018", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99018.get_skill_id = function(self)
	return "sk99018";
end


-- 技能名 
cls_sk99018.get_skill_name = function(self)
	return T("boss突击（自爆）释放");
end

-- 获取技能的描述
cls_sk99018.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk99018.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最小施法限制距离
cls_sk99018.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk99018.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- 
	local iANearRange = attacker:getNearRange();

	-- 公式原文:结果=A近战攻击距离*1.3
	result = iANearRange*1.3;

	return result
end

-- 受击特效预加载 
cls_sk99018.get_preload_hit_effect = function(self)
	return "tx_judian_boom";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[突击]
local sk99018_pre_action_tuji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=110
	tbResult.translate = 110;

	return tbResult
end

-- 目标选择基础数量[突击]
local sk99018_select_cnt_tuji_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[突击]
local sk99018_unselect_status_tuji_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[突击]
local sk99018_status_time_tuji_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[突击]
local sk99018_status_break_tuji_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[突击]
local sk99018_status_rate_tuji_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[突击]
local sk99018_calc_status_tuji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_judian_boom"
	tbResult.hit_effect = "tx_judian_boom";
	-- 公式原文:扣血=基础近战伤害*(技能等级)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(lv);
	-- 公式原文:震屏幅度=4
	tbResult.shake_range = 4;
	-- 公式原文:震屏次数=7
	tbResult.shake_time = 7;
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end

-- 前置动作[扣血]
local sk99018_pre_action_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk99018_select_cnt_sub_hp_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血]
local sk99018_unselect_status_sub_hp_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血]
local sk99018_status_time_sub_hp_1 = function(attacker, lv)
	return 
6
end

-- 状态心跳[扣血]
local sk99018_status_break_sub_hp_1 = function(attacker, lv)
	return 
1
end

-- 命中率公式[扣血]
local sk99018_status_rate_sub_hp_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[扣血]
local sk99018_calc_status_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础近战伤害*(1+技能等级*0.1)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1+lv*0.1);
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end

-- 前置动作[扣血_2]
local sk99018_pre_action_sub_hp_2_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血_2]
local sk99018_select_cnt_sub_hp_2_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血_2]
local sk99018_unselect_status_sub_hp_2_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血_2]
local sk99018_status_time_sub_hp_2_2 = function(attacker, lv)
	return 
0
end

-- 状态心跳[扣血_2]
local sk99018_status_break_sub_hp_2_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[扣血_2]
local sk99018_status_rate_sub_hp_2_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[扣血_2]
local sk99018_calc_status_sub_hp_2_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:受击特效="tx_judian_boom"
	tbResult.hit_effect = "tx_judian_boom";
	-- 公式原文:扣血=A耐久上限*0.1
	tbResult.sub_hp = iAHpLimit*0.1;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99018.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99018_calc_status_tuji_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99018_pre_action_tuji_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99018_select_cnt_tuji_0, 
		["sort_method"]="", 
		["status"]="tuji", 
		["status_break"]=sk99018_status_break_tuji_0, 
		["status_rate"]=sk99018_status_rate_tuji_0, 
		["status_time"]=sk99018_status_time_tuji_0, 
		["unselect_status"]=sk99018_unselect_status_tuji_0, 
	}, 
	{
		["calc_status"]=sk99018_calc_status_sub_hp_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99018_pre_action_sub_hp_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99018_select_cnt_sub_hp_1, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk99018_status_break_sub_hp_1, 
		["status_rate"]=sk99018_status_rate_sub_hp_1, 
		["status_time"]=sk99018_status_time_sub_hp_1, 
		["unselect_status"]=sk99018_unselect_status_sub_hp_1, 
	}, 
	{
		["calc_status"]=sk99018_calc_status_sub_hp_2_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99018_pre_action_sub_hp_2_2, 
		["scope"]="SELF", 
		["select_cnt"]=sk99018_select_cnt_sub_hp_2_2, 
		["sort_method"]="", 
		["status"]="sub_hp_2", 
		["status_break"]=sk99018_status_break_sub_hp_2_2, 
		["status_rate"]=sk99018_status_rate_sub_hp_2_2, 
		["status_time"]=sk99018_status_time_sub_hp_2_2, 
		["unselect_status"]=sk99018_unselect_status_sub_hp_2_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------