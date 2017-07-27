----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk41004 = class("cls_sk41004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk41004.get_skill_id = function(self)
	return "sk41004";
end


-- 技能名 
cls_sk41004.get_skill_name = function(self)
	return T("备战");
end

-- 精简版技能描述 
cls_sk41004.get_skill_short_desc = function(self)
	return T("全体我方每秒恢复怒气，受击时额外恢复。");
end

-- 获取技能的描述
cls_sk41004.get_skill_desc = function(self, skill_data, lv)
	return T("范围增加至全屏，进入战斗后立刻增加50点怒气。")
end

-- 获取技能的富文本描述
cls_sk41004.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)范围增加至全屏，进入战斗后立刻增加50点怒气。")
end

-- 公共CD 
cls_sk41004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk41004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=999999
	result = 999999;

	return result
end

-- 最小施法限制距离
cls_sk41004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk41004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk41004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[鼓舞士气]
local sk41004_pre_action_guwushiqi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[鼓舞士气]
local sk41004_select_cnt_guwushiqi_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[鼓舞士气]
local sk41004_unselect_status_guwushiqi_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[鼓舞士气]
local sk41004_status_time_guwushiqi_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[鼓舞士气]
local sk41004_status_break_guwushiqi_0 = function(attacker, lv)
	return 
6
end

-- 命中率公式[鼓舞士气]
local sk41004_status_rate_guwushiqi_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[鼓舞士气]
local sk41004_calc_status_guwushiqi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:鼓舞士气触发技能="sk90007b"
	tbResult.gwsq_skill_id = "sk90007b";

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk41004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk41004_calc_status_guwushiqi_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk41004_pre_action_guwushiqi_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk41004_select_cnt_guwushiqi_0, 
		["sort_method"]="", 
		["status"]="guwushiqi", 
		["status_break"]=sk41004_status_break_guwushiqi_0, 
		["status_rate"]=sk41004_status_rate_guwushiqi_0, 
		["status_time"]=sk41004_status_time_guwushiqi_0, 
		["unselect_status"]=sk41004_unselect_status_guwushiqi_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
