----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk51004 = class("cls_sk51004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk51004.get_skill_id = function(self)
	return "sk51004";
end


-- 技能名 
cls_sk51004.get_skill_name = function(self)
	return T("远程船A级");
end

-- 获取技能的描述
cls_sk51004.get_skill_desc = function(self, skill_data, lv)
	return T("每10秒触发，远程攻击提高50%，持续8秒")
end

-- 获取技能的富文本描述
cls_sk51004.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)每10秒触发，远程攻击提高50%，持续8秒")
end

-- 公共CD 
cls_sk51004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk51004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 最小施法限制距离
cls_sk51004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk51004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk51004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk51004.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk51004.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk51004.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1500
	result = 1500;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加远攻]
local sk51004_pre_action_add_att_far_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻]
local sk51004_select_cnt_add_att_far_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加远攻]
local sk51004_unselect_status_add_att_far_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加远攻]
local sk51004_status_time_add_att_far_0 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加远攻]
local sk51004_status_break_add_att_far_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻]
local sk51004_status_rate_add_att_far_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[加远攻]
local sk51004_calc_status_add_att_far_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=A远程攻击*0.5
	tbResult.add_att_far = iAAtt*0.5;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk51004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk51004_calc_status_add_att_far_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk51004_pre_action_add_att_far_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk51004_select_cnt_add_att_far_0, 
		["sort_method"]="", 
		["status"]="add_att_far", 
		["status_break"]=sk51004_status_break_add_att_far_0, 
		["status_rate"]=sk51004_status_rate_add_att_far_0, 
		["status_time"]=sk51004_status_time_add_att_far_0, 
		["unselect_status"]=sk51004_unselect_status_add_att_far_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------