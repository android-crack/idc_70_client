----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90028 = class("cls_sk90028", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90028.get_skill_id = function(self)
	return "sk90028";
end


-- 技能名 
cls_sk90028.get_skill_name = function(self)
	return T("血量同享");
end

-- 获取技能的描述
cls_sk90028.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90028.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk90028.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk90028._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk90028.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk90028.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[血量共享]
local sk90028_pre_action_xuelianggongxiang_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[血量共享]
local sk90028_select_cnt_xuelianggongxiang_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[血量共享]
local sk90028_unselect_status_xuelianggongxiang_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[血量共享]
local sk90028_status_time_xuelianggongxiang_0 = function(attacker, lv)
	return 
99999
end

-- 状态心跳[血量共享]
local sk90028_status_break_xuelianggongxiang_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[血量共享]
local sk90028_status_rate_xuelianggongxiang_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[血量共享]
local sk90028_calc_status_xuelianggongxiang_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90028.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90028_calc_status_xuelianggongxiang_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90028_pre_action_xuelianggongxiang_0, 
		["scope"]="FRIEND_OTHER", 
		["select_cnt"]=sk90028_select_cnt_xuelianggongxiang_0, 
		["sort_method"]="", 
		["status"]="xuelianggongxiang", 
		["status_break"]=sk90028_status_break_xuelianggongxiang_0, 
		["status_rate"]=sk90028_status_rate_xuelianggongxiang_0, 
		["status_time"]=sk90028_status_time_xuelianggongxiang_0, 
		["unselect_status"]=sk90028_unselect_status_xuelianggongxiang_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------