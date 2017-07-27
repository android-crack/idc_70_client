----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk43003 = class("cls_sk43003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk43003.get_skill_id = function(self)
	return "sk43003";
end


-- 技能名 
cls_sk43003.get_skill_name = function(self)
	return T("无懈可击");
end

-- 精简版技能描述 
cls_sk43003.get_skill_short_desc = function(self)
	return T("全体我方防御大量提升。");
end

-- 获取技能的描述
cls_sk43003.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("全体我方防御提升%0.1f%%。"), (5+1*lv))
end

-- 获取技能的富文本描述
cls_sk43003.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)全体我方防御提升$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), (5+1*lv))
end

-- 公共CD 
cls_sk43003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk43003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk43003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk43003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk43003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加防_2]
local sk43003_pre_action_add_def_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防_2]
local sk43003_select_cnt_add_def_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加防_2]
local sk43003_unselect_status_add_def_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加防_2]
local sk43003_status_time_add_def_2_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加防_2]
local sk43003_status_break_add_def_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防_2]
local sk43003_status_rate_add_def_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加防_2]
local sk43003_calc_status_add_def_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=(A防御*(0.05+0.01*技能等级))*1.5
	tbResult.add_defend = (iADefense*(0.05+0.01*lv))*1.5;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk43003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk43003_calc_status_add_def_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43003_pre_action_add_def_2_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk43003_select_cnt_add_def_2_0, 
		["sort_method"]="", 
		["status"]="add_def_2", 
		["status_break"]=sk43003_status_break_add_def_2_0, 
		["status_rate"]=sk43003_status_rate_add_def_2_0, 
		["status_time"]=sk43003_status_time_add_def_2_0, 
		["unselect_status"]=sk43003_unselect_status_add_def_2_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
