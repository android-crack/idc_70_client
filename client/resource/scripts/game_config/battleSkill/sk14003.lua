----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk14003 = class("cls_sk14003", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk14003.get_skill_id = function(self)
	return "sk14003";
end


-- 技能名 
cls_sk14003.get_skill_name = function(self)
	return T("防御（伺机）");
end

-- 精简版技能描述 
cls_sk14003.get_skill_short_desc = function(self)
	return T("嘲讽射程内所有敌方，6秒内提升施法者防御并额外获得怒气。");
end

-- 获取技能的描述
cls_sk14003.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("嘲讽射程内所有敌方%0.1f秒，6秒内增加施法者%0.1f%%防御。"), (3+lv), (50+10*lv))
end

-- 获取技能的富文本描述
cls_sk14003.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)嘲讽射程内所有敌方$(c:COLOR_GREEN)%0.1f$(c:COLOR_CAMEL)秒，6秒内增加施法者$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)防御。"), (3+lv), (50+10*lv))
end

-- 公共CD 
cls_sk14003.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk14003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=15
	result = 15;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk14003.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk14003.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk14003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk14003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法音效 
cls_sk14003.get_effect_music = function(self)
	return "BT_DEFENSE";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加防]
local sk14003_pre_action_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防]
local sk14003_select_cnt_add_def_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加防]
local sk14003_unselect_status_add_def_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加防]
local sk14003_status_time_add_def_0 = function(attacker, lv)
	return 
9
end

-- 状态心跳[加防]
local sk14003_status_break_add_def_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防]
local sk14003_status_rate_add_def_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加防]
local sk14003_calc_status_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=A防御*(0.5+0.1*技能等级)
	tbResult.add_defend = iADefense*(0.5+0.1*lv);

	return tbResult
end

-- 前置动作[嘲讽]
local sk14003_pre_action_chaofeng_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[嘲讽]
local sk14003_select_cnt_chaofeng_1 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[嘲讽]
local sk14003_unselect_status_chaofeng_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[嘲讽]
local sk14003_status_time_chaofeng_1 = function(attacker, lv)
	return 
3+lv
end

-- 状态心跳[嘲讽]
local sk14003_status_break_chaofeng_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[嘲讽]
local sk14003_status_rate_chaofeng_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[嘲讽]
local sk14003_calc_status_chaofeng_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk14003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk14003_calc_status_add_def_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk14003_pre_action_add_def_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk14003_select_cnt_add_def_0, 
		["sort_method"]="", 
		["status"]="add_def", 
		["status_break"]=sk14003_status_break_add_def_0, 
		["status_rate"]=sk14003_status_rate_add_def_0, 
		["status_time"]=sk14003_status_time_add_def_0, 
		["unselect_status"]=sk14003_unselect_status_add_def_0, 
	}, 
	{
		["calc_status"]=sk14003_calc_status_chaofeng_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk14003_pre_action_chaofeng_1, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk14003_select_cnt_chaofeng_1, 
		["sort_method"]="DISTANCE_ASEC", 
		["status"]="chaofeng", 
		["status_break"]=sk14003_status_break_chaofeng_1, 
		["status_rate"]=sk14003_status_rate_chaofeng_1, 
		["status_time"]=sk14003_status_time_chaofeng_1, 
		["unselect_status"]=sk14003_unselect_status_chaofeng_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
