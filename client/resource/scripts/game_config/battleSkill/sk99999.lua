----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk99999 = class("cls_sk99999", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99999.get_skill_id = function(self)
	return "sk99999";
end


-- 技能名 
cls_sk99999.get_skill_name = function(self)
	return T("BOSS快死亡时隐身技能");
end

-- 精简版技能描述 
cls_sk99999.get_skill_short_desc = function(self)
	return T("全体我方每秒恢复耐久，施法者受到致死伤害时，免疫该伤害并进入隐身状态。");
end

-- 获取技能的描述
cls_sk99999.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("全体我方每6秒恢复施法者耐久上限%0.1f%%耐久，施法者受到致死伤害时，免疫该伤害并进入隐身6秒，30秒冷却。"), (5+lv*1))
end

-- 获取技能的富文本描述
cls_sk99999.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)全体我方每6秒恢复施法者耐久上限$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的耐久，施法者受到致死伤害时，免疫伤害并隐身6秒，30秒冷却。"), (5+lv*1))
end

-- 公共CD 
cls_sk99999.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk99999._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk99999.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk99999.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk99999.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[坚不可摧]
local sk99999_pre_action_jianbukecui_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[坚不可摧]
local sk99999_select_cnt_jianbukecui_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[坚不可摧]
local sk99999_unselect_status_jianbukecui_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[坚不可摧]
local sk99999_status_time_jianbukecui_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[坚不可摧]
local sk99999_status_break_jianbukecui_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[坚不可摧]
local sk99999_status_rate_jianbukecui_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[坚不可摧]
local sk99999_calc_status_jianbukecui_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:坚不可催几率=1000
	tbResult.jbkc_rate = 1000;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99999.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99999_calc_status_jianbukecui_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99999_pre_action_jianbukecui_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk99999_select_cnt_jianbukecui_0, 
		["sort_method"]="DISTANCE_ASEC", 
		["status"]="jianbukecui", 
		["status_break"]=sk99999_status_break_jianbukecui_0, 
		["status_rate"]=sk99999_status_rate_jianbukecui_0, 
		["status_time"]=sk99999_status_time_jianbukecui_0, 
		["unselect_status"]=sk99999_unselect_status_jianbukecui_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------