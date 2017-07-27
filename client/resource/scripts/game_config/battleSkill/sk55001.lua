----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk55001 = class("cls_sk55001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk55001.get_skill_id = function(self)
	return "sk55001";
end


-- 技能名 
cls_sk55001.get_skill_name = function(self)
	return T("装甲船D级");
end

-- 获取技能的描述
cls_sk55001.get_skill_desc = function(self, skill_data, lv)
	return T("每隔10秒，嘲讽1个射程内目标，持续6秒")
end

-- 获取技能的富文本描述
cls_sk55001.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)每隔10秒，嘲讽1个射程内目标，持续6秒")
end

-- 公共CD 
cls_sk55001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk55001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 技能施法范围 
cls_sk55001.get_select_scope = function(self)
	return "ENEMY";
end


-- 最小施法限制距离
cls_sk55001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk55001.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk55001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk55001.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk55001.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk55001.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1500
	result = 1500;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[嘲讽]
local sk55001_pre_action_chaofeng_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[嘲讽]
local sk55001_select_cnt_chaofeng_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[嘲讽]
local sk55001_unselect_status_chaofeng_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[嘲讽]
local sk55001_status_time_chaofeng_0 = function(attacker, lv)
	return 
6
end

-- 状态心跳[嘲讽]
local sk55001_status_break_chaofeng_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[嘲讽]
local sk55001_status_rate_chaofeng_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[嘲讽]
local sk55001_calc_status_chaofeng_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk55001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk55001_calc_status_chaofeng_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk55001_pre_action_chaofeng_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk55001_select_cnt_chaofeng_0, 
		["sort_method"]="DISTANCE_ASEC", 
		["status"]="chaofeng", 
		["status_break"]=sk55001_status_break_chaofeng_0, 
		["status_rate"]=sk55001_status_rate_chaofeng_0, 
		["status_time"]=sk55001_status_time_chaofeng_0, 
		["unselect_status"]=sk55001_unselect_status_chaofeng_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------