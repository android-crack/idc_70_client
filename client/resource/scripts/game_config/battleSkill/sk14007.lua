----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk14007 = class("cls_sk14007", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk14007.get_skill_id = function(self)
	return "sk14007";
end


-- 技能名 
cls_sk14007.get_skill_name = function(self)
	return T("反击");
end

-- 精简版技能描述 
cls_sk14007.get_skill_short_desc = function(self)
	return T("闪避敌方普通攻击时，反击敌方对其造成近战伤害");
end

-- 获取技能的描述
cls_sk14007.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("闪避敌方普通攻击时，反击敌方对其造成%0.1f%%的近战伤害"), (80+10*lv))
end

-- 获取技能的富文本描述
cls_sk14007.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)闪避敌方普通攻击时，反击敌方对其造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的近战伤害"), (80+10*lv))
end

-- 公共CD 
cls_sk14007.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk14007._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk14007.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk14007.get_select_scope = function(self)
	return "SELF";
end


-- 最大施法限制距离
cls_sk14007.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk14007.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[反击]
local sk14007_pre_action_fanji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[反击]
local sk14007_select_cnt_fanji_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[反击]
local sk14007_unselect_status_fanji_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[反击]
local sk14007_status_time_fanji_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=666666
	result = 666666;

	return result
end

-- 状态心跳[反击]
local sk14007_status_break_fanji_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[反击]
local sk14007_status_rate_fanji_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[反击]
local sk14007_calc_status_fanji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:通用触发技能="sk14008"
	tbResult.ty_skill_id = "sk14008";

	return tbResult
end

-- 前置动作[闪避_3]
local sk14007_pre_action_dodge_3_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[闪避_3]
local sk14007_select_cnt_dodge_3_1 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[闪避_3]
local sk14007_unselect_status_dodge_3_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[闪避_3]
local sk14007_status_time_dodge_3_1 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=666666
	result = 666666;

	return result
end

-- 状态心跳[闪避_3]
local sk14007_status_break_dodge_3_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[闪避_3]
local sk14007_status_rate_dodge_3_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk14007_SkillLv/sk14007_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk14007")/attacker:getSkillLv("sk14007_MAX"));

	return result
end

-- 处理过程[闪避_3]
local sk14007_calc_status_dodge_3_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:提升闪避=200
	tbResult.dodge= 200;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk14007.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk14007_calc_status_fanji_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk14007_pre_action_fanji_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk14007_select_cnt_fanji_0, 
		["sort_method"]="", 
		["status"]="fanji", 
		["status_break"]=sk14007_status_break_fanji_0, 
		["status_rate"]=sk14007_status_rate_fanji_0, 
		["status_time"]=sk14007_status_time_fanji_0, 
		["unselect_status"]=sk14007_unselect_status_fanji_0, 
	}, 
	{
		["calc_status"]=sk14007_calc_status_dodge_3_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk14007_pre_action_dodge_3_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk14007_select_cnt_dodge_3_1, 
		["sort_method"]="", 
		["status"]="dodge_3", 
		["status_break"]=sk14007_status_break_dodge_3_1, 
		["status_rate"]=sk14007_status_rate_dodge_3_1, 
		["status_time"]=sk14007_status_time_dodge_3_1, 
		["unselect_status"]=sk14007_unselect_status_dodge_3_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------