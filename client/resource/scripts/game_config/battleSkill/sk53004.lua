----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk53004 = class("cls_sk53004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk53004.get_skill_id = function(self)
	return "sk53004";
end


-- 技能名 
cls_sk53004.get_skill_name = function(self)
	return T("辅助船A级");
end

-- 获取技能的描述
cls_sk53004.get_skill_desc = function(self, skill_data, lv)
	return T("每隔10秒，清除射程内所有我方船只负面状态和敌方船只正面状态。")
end

-- 获取技能的富文本描述
cls_sk53004.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)每隔10秒，清除射程内所有我方船只负面状态和敌方船只正面状态。")
end

-- 公共CD 
cls_sk53004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk53004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 最小施法限制距离
cls_sk53004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk53004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk53004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk53004.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk53004.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk53004.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1500
	result = 1500;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[清除减益状态]
local sk53004_pre_action_clear_debuff_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk53004_select_cnt_clear_debuff_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[清除减益状态]
local sk53004_unselect_status_clear_debuff_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[清除减益状态]
local sk53004_status_time_clear_debuff_0 = function(attacker, lv)
	return 
1
end

-- 状态心跳[清除减益状态]
local sk53004_status_break_clear_debuff_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk53004_status_rate_clear_debuff_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[清除减益状态]
local sk53004_calc_status_clear_debuff_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[清除增益状态]
local sk53004_pre_action_clear_buff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除增益状态]
local sk53004_select_cnt_clear_buff_1 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[清除增益状态]
local sk53004_unselect_status_clear_buff_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[清除增益状态]
local sk53004_status_time_clear_buff_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[清除增益状态]
local sk53004_status_break_clear_buff_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除增益状态]
local sk53004_status_rate_clear_buff_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[清除增益状态]
local sk53004_calc_status_clear_buff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk53004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk53004_calc_status_clear_debuff_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk53004_pre_action_clear_debuff_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk53004_select_cnt_clear_debuff_0, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk53004_status_break_clear_debuff_0, 
		["status_rate"]=sk53004_status_rate_clear_debuff_0, 
		["status_time"]=sk53004_status_time_clear_debuff_0, 
		["unselect_status"]=sk53004_unselect_status_clear_debuff_0, 
	}, 
	{
		["calc_status"]=sk53004_calc_status_clear_buff_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk53004_pre_action_clear_buff_1, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk53004_select_cnt_clear_buff_1, 
		["sort_method"]="", 
		["status"]="clear_buff", 
		["status_break"]=sk53004_status_break_clear_buff_1, 
		["status_rate"]=sk53004_status_rate_clear_buff_1, 
		["status_time"]=sk53004_status_time_clear_buff_1, 
		["unselect_status"]=sk53004_unselect_status_clear_buff_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------