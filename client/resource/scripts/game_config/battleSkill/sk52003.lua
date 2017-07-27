----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk52003 = class("cls_sk52003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk52003.get_skill_id = function(self)
	return "sk52003";
end


-- 技能名 
cls_sk52003.get_skill_name = function(self)
	return T("近战船B级");
end

-- 获取技能的描述
cls_sk52003.get_skill_desc = function(self, skill_data, lv)
	return T("每10秒触发，近战攻击提高60%,持续8秒")
end

-- 获取技能的富文本描述
cls_sk52003.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)每10秒触发，近战攻击提高60%,持续8秒")
end

-- 公共CD 
cls_sk52003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk52003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 最小施法限制距离
cls_sk52003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk52003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk52003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk52003.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk52003.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk52003.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1500
	result = 1500;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加近攻]
local sk52003_pre_action_add_att_near_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻]
local sk52003_select_cnt_add_att_near_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加近攻]
local sk52003_unselect_status_add_att_near_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加近攻]
local sk52003_status_time_add_att_near_0 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加近攻]
local sk52003_status_break_add_att_near_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻]
local sk52003_status_rate_add_att_near_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[加近攻]
local sk52003_calc_status_add_att_near_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=A近战攻击*0.6
	tbResult.add_att_near = iANear*0.6;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk52003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk52003_calc_status_add_att_near_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk52003_pre_action_add_att_near_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk52003_select_cnt_add_att_near_0, 
		["sort_method"]="", 
		["status"]="add_att_near", 
		["status_break"]=sk52003_status_break_add_att_near_0, 
		["status_rate"]=sk52003_status_rate_add_att_near_0, 
		["status_time"]=sk52003_status_time_add_att_near_0, 
		["unselect_status"]=sk52003_unselect_status_add_att_near_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------