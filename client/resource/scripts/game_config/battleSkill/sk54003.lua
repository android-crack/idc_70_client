----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk54003 = class("cls_sk54003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk54003.get_skill_id = function(self)
	return "sk54003";
end


-- 技能名 
cls_sk54003.get_skill_name = function(self)
	return T("治疗船B级");
end

-- 获取技能的描述
cls_sk54003.get_skill_desc = function(self, skill_data, lv)
	return T("每10秒立刻恢复气血百分比最低船只，最大气血*30%")
end

-- 获取技能的富文本描述
cls_sk54003.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)每10秒立刻恢复气血百分比最低船只，最大气血*30%")
end

-- 公共CD 
cls_sk54003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk54003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 最小施法限制距离
cls_sk54003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk54003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk54003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk54003.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk54003.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk54003.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1500
	result = 1500;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血]
local sk54003_pre_action_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血]
local sk54003_select_cnt_add_hp_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加血]
local sk54003_unselect_status_add_hp_0 = function(attacker, lv)
	return {"die", }
end

-- 状态持续时间[加血]
local sk54003_status_time_add_hp_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[加血]
local sk54003_status_break_add_hp_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加血]
local sk54003_status_rate_add_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[加血]
local sk54003_calc_status_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=A耐久上限*0.3
	tbResult.add_hp = iAHpLimit*0.3;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk54003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk54003_calc_status_add_hp_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk54003_pre_action_add_hp_0, 
		["scope"]="ALL_FRIEND", 
		["select_cnt"]=sk54003_select_cnt_add_hp_0, 
		["sort_method"]="HP_RATE_ASEC", 
		["status"]="add_hp", 
		["status_break"]=sk54003_status_break_add_hp_0, 
		["status_rate"]=sk54003_status_rate_add_hp_0, 
		["status_time"]=sk54003_status_time_add_hp_0, 
		["unselect_status"]=sk54003_unselect_status_add_hp_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------