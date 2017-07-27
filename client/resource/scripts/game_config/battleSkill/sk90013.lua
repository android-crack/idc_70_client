----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90013 = class("cls_sk90013", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90013.get_skill_id = function(self)
	return "sk90013";
end


-- 技能名 
cls_sk90013.get_skill_name = function(self)
	return T("链弹舰");
end

-- 精简版技能描述 
cls_sk90013.get_skill_short_desc = function(self)
	return T("对射程内3个敌方造成远程伤害，使其减速4秒，并清除正面状态。");
end

-- 获取技能的描述
cls_sk90013.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内3个敌方造成%0.1f%%远程伤害，并降低其50速度4秒，并清除正面状态。"), (175+lv*10))
end

-- 获取技能的富文本描述
cls_sk90013.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对射程内3个敌方造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)远程伤害，并降低其50速度8秒，并清除正面状态。"), (175+lv*10))
end

-- 公共CD 
cls_sk90013.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk90013._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=2
	result = 2;

	return result
end

-- 技能触发概率
cls_sk90013.get_skill_rate = function(self, attacker)
	local result
	
	-- 公式原文:结果=100
	result = 100;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk90013.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk90013.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk90013.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk90013.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击音效 
cls_sk90013.get_hit_music = function(self)
	return "BT_CHAIN_HIT";
end


-- 受击特效预加载 
cls_sk90013.get_preload_hit_effect = function(self)
	return "tx_yanhua_boom";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk90013_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk90013_select_cnt_attack_0 = function(attacker, lv)
	return 
3
end

-- 目标选择忽视状态[攻击]
local sk90013_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk90013_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk90013_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk90013_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk90013_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_yanhua_boom"
	tbResult.hit_effect = "tx_yanhua_boom";
	-- 公式原文:扣血=基础远程伤害*(1.75+技能等级*0.1)/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1.75+lv*0.1)/3;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=1
	tbResult.shake_range = 1;

	return tbResult
end

-- 前置动作[减速]
local sk90013_pre_action_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减速]
local sk90013_select_cnt_slow_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减速]
local sk90013_unselect_status_slow_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减速]
local sk90013_status_time_slow_1 = function(attacker, lv)
	return 
4
end

-- 状态心跳[减速]
local sk90013_status_break_slow_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减速]
local sk90013_status_rate_slow_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减速]
local sk90013_calc_status_slow_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:减速=50
	tbResult.sub_speed = 50;

	return tbResult
end

-- 前置动作[清除增益状态]
local sk90013_pre_action_clear_buff_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除增益状态]
local sk90013_select_cnt_clear_buff_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[清除增益状态]
local sk90013_unselect_status_clear_buff_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[清除增益状态]
local sk90013_status_time_clear_buff_2 = function(attacker, lv)
	return 
0
end

-- 状态心跳[清除增益状态]
local sk90013_status_break_clear_buff_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除增益状态]
local sk90013_status_rate_clear_buff_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[清除增益状态]
local sk90013_calc_status_clear_buff_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90013.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90013_calc_status_attack_0, 
		["effect_name"]="liandan", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk90013_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk90013_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk90013_status_break_attack_0, 
		["status_rate"]=sk90013_status_rate_attack_0, 
		["status_time"]=sk90013_status_time_attack_0, 
		["unselect_status"]=sk90013_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk90013_calc_status_slow_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90013_pre_action_slow_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90013_select_cnt_slow_1, 
		["sort_method"]="", 
		["status"]="slow", 
		["status_break"]=sk90013_status_break_slow_1, 
		["status_rate"]=sk90013_status_rate_slow_1, 
		["status_time"]=sk90013_status_time_slow_1, 
		["unselect_status"]=sk90013_unselect_status_slow_1, 
	}, 
	{
		["calc_status"]=sk90013_calc_status_clear_buff_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90013_pre_action_clear_buff_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90013_select_cnt_clear_buff_2, 
		["sort_method"]="", 
		["status"]="clear_buff", 
		["status_break"]=sk90013_status_break_clear_buff_2, 
		["status_rate"]=sk90013_status_rate_clear_buff_2, 
		["status_time"]=sk90013_status_time_clear_buff_2, 
		["unselect_status"]=sk90013_unselect_status_clear_buff_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
