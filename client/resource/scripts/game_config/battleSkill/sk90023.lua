----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90023 = class("cls_sk90023", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90023.get_skill_id = function(self)
	return "sk90023";
end


-- 技能名 
cls_sk90023.get_skill_name = function(self)
	return T("主角援助技能2:贯通");
end

-- 获取技能的描述
cls_sk90023.get_skill_desc = function(self, skill_data, lv)
	return T("满级后该船只拥有贯通技能")
end

-- 获取技能的富文本描述
cls_sk90023.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)$(c:COLOR_GREEN)满级后该船只拥有葡萄弹技能")
end

-- 公共CD 
cls_sk90023.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk90023._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=999
	result = 999;

	return result
end

-- 技能施法范围 
cls_sk90023.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk90023.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk90023.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk90023_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk90023_select_cnt_attack_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[攻击]
local sk90023_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk90023_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk90023_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk90023_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk90023_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础远程伤害*1.5
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*1.5;

	return tbResult
end

-- 前置动作[眩晕]
local sk90023_pre_action_stun_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[眩晕]
local sk90023_select_cnt_stun_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[眩晕]
local sk90023_unselect_status_stun_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[眩晕]
local sk90023_status_time_stun_1 = function(attacker, lv)
	return 
3
end

-- 状态心跳[眩晕]
local sk90023_status_break_stun_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[眩晕]
local sk90023_status_rate_stun_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[眩晕]
local sk90023_calc_status_stun_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90023.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90023_calc_status_attack_0, 
		["effect_name"]="guantong", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk90023_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk90023_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk90023_status_break_attack_0, 
		["status_rate"]=sk90023_status_rate_attack_0, 
		["status_time"]=sk90023_status_time_attack_0, 
		["unselect_status"]=sk90023_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk90023_calc_status_stun_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90023_pre_action_stun_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90023_select_cnt_stun_1, 
		["sort_method"]="", 
		["status"]="stun", 
		["status_break"]=sk90023_status_break_stun_1, 
		["status_rate"]=sk90023_status_rate_stun_1, 
		["status_time"]=sk90023_status_time_stun_1, 
		["unselect_status"]=sk90023_unselect_status_stun_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------