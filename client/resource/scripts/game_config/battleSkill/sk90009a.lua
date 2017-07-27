----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90009a = class("cls_sk90009a", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90009a.get_skill_id = function(self)
	return "sk90009a";
end


-- 技能名 
cls_sk90009a.get_skill_name = function(self)
	return T("步步为营释放全屏");
end

-- 获取技能的描述
cls_sk90009a.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90009a.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 技能CD
cls_sk90009a._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 最小施法限制距离
cls_sk90009a.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk90009a.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血_2]
local sk90009a_pre_action_add_hp_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血_2]
local sk90009a_select_cnt_add_hp_2_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加血_2]
local sk90009a_unselect_status_add_hp_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加血_2]
local sk90009a_status_time_add_hp_2_0 = function(attacker, lv)
	return 
5
end

-- 状态心跳[加血_2]
local sk90009a_status_break_add_hp_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加血_2]
local sk90009a_status_rate_add_hp_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加血_2]
local sk90009a_calc_status_add_hp_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=(5+技能等级*0.5)*A耐久上限*0.01
	tbResult.add_hp = (5+lv*0.5)*iAHpLimit*0.01;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90009a.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90009a_calc_status_add_hp_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90009a_pre_action_add_hp_2_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk90009a_select_cnt_add_hp_2_0, 
		["sort_method"]="", 
		["status"]="add_hp_2", 
		["status_break"]=sk90009a_status_break_add_hp_2_0, 
		["status_rate"]=sk90009a_status_rate_add_hp_2_0, 
		["status_time"]=sk90009a_status_time_add_hp_2_0, 
		["unselect_status"]=sk90009a_unselect_status_add_hp_2_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90009a.get_skill_type = function(self)
    return "auto"
end

cls_sk90009a.get_skill_lv = function(self, attacker)
	return cls_sk42006:get_skill_lv( attacker )
end