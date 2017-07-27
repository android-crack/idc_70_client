----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90001 = class("cls_sk90001", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90001.get_skill_id = function(self)
	return "sk90001";
end


-- 技能名 
cls_sk90001.get_skill_name = function(self)
	return T("应变加防");
end

-- 获取技能的描述
cls_sk90001.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90001.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加防]
local sk90001_pre_action_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防]
local sk90001_select_cnt_add_def_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加防]
local sk90001_unselect_status_add_def_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加防]
local sk90001_status_time_add_def_0 = function(attacker, lv)
	return 
6
end

-- 状态心跳[加防]
local sk90001_status_break_add_def_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防]
local sk90001_status_rate_add_def_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加防]
local sk90001_calc_status_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=A防御*(50+10*技能等级)
	tbResult.add_defend = iADefense*(50+10*lv);

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90001_calc_status_add_def_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90001_pre_action_add_def_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk90001_select_cnt_add_def_0, 
		["sort_method"]="", 
		["status"]="add_def", 
		["status_break"]=sk90001_status_break_add_def_0, 
		["status_rate"]=sk90001_status_rate_add_def_0, 
		["status_time"]=sk90001_status_time_add_def_0, 
		["unselect_status"]=sk90001_unselect_status_add_def_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk90001.get_skill_type = function(self)
	return "auto"
end

cls_sk90001.get_skill_lv = function(self, attacker)
	return 1
end
