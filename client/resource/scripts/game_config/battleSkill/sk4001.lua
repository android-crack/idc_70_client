----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk4001 = class("cls_sk4001", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk4001.get_skill_id = function(self)
	return "sk4001";
end


-- 技能名 
cls_sk4001.get_skill_name = function(self)
	return T("加速");
end

-- 精简版技能描述 
cls_sk4001.get_skill_short_desc = function(self)
	return T("通用技能，增加50速度");
end

-- 获取技能的描述
cls_sk4001.get_skill_desc = function(self, skill_data, lv)
	return T("通用技能，增加50速度")
end

-- 获取技能的富文本描述
cls_sk4001.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)通用技能，增加50速度")
end

-- 公共CD 
cls_sk4001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk4001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 技能施法范围 
cls_sk4001.get_select_scope = function(self)
	return "SELF";
end


-- SP消耗公式
cls_sk4001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"sf_tujin", }

cls_sk4001.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk4001.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk4001.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk4001.get_effect_music = function(self)
	return "BT_AVOID";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加速]
local sk4001_pre_action_fast_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加速]
local sk4001_select_cnt_fast_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加速]
local sk4001_unselect_status_fast_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加速]
local sk4001_status_time_fast_0 = function(attacker, lv)
	return 
6
end

-- 状态心跳[加速]
local sk4001_status_break_fast_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加速]
local sk4001_status_rate_fast_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加速]
local sk4001_calc_status_fast_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:加速=50
	tbResult.add_speed = 50;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk4001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk4001_calc_status_fast_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk4001_pre_action_fast_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk4001_select_cnt_fast_0, 
		["sort_method"]="", 
		["status"]="fast", 
		["status_break"]=sk4001_status_break_fast_0, 
		["status_rate"]=sk4001_status_rate_fast_0, 
		["status_time"]=sk4001_status_time_fast_0, 
		["unselect_status"]=sk4001_unselect_status_fast_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------