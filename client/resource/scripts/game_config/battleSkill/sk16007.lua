----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk16007 = class("cls_sk16007", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk16007.get_skill_id = function(self)
	return "sk16007";
end


-- 技能名 
cls_sk16007.get_skill_name = function(self)
	return T("突进（先锋）");
end

-- 精简版技能描述 
cls_sk16007.get_skill_short_desc = function(self)
	return T("提升自身远程攻击/防御,持续8秒");
end

-- 获取技能的描述
cls_sk16007.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("提升施法者%0.1f%%远程攻击和防御，持续8秒。"), (60+3*lv))
end

-- 获取技能的富文本描述
cls_sk16007.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)增加施法者$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)远程攻击及防御，持续8秒。"), (60+3*lv))
end

-- 公共CD 
cls_sk16007.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk16007._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 技能施法范围 
cls_sk16007.get_select_scope = function(self)
	return "SELF";
end


-- 最大施法限制距离
cls_sk16007.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk16007.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加防]
local sk16007_pre_action_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防]
local sk16007_select_cnt_add_def_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加防]
local sk16007_unselect_status_add_def_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加防]
local sk16007_status_time_add_def_0 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加防]
local sk16007_status_break_add_def_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防]
local sk16007_status_rate_add_def_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=250
	result = 250;

	return result
end

-- 处理过程[加防]
local sk16007_calc_status_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=(0.6+0.03*技能等级)*A防御
	tbResult.add_defend = (0.6+0.03*lv)*iADefense;

	return tbResult
end

-- 前置动作[加远攻]
local sk16007_pre_action_add_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻]
local sk16007_select_cnt_add_att_far_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加远攻]
local sk16007_unselect_status_add_att_far_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加远攻]
local sk16007_status_time_add_att_far_1 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加远攻]
local sk16007_status_break_add_att_far_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻]
local sk16007_status_rate_add_att_far_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加远攻]
local sk16007_calc_status_add_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=(0.6+0.03*技能等级)*A远程攻击
	tbResult.add_att_far = (0.6+0.03*lv)*iAAtt;

	return tbResult
end

-- 前置动作[暴击_3]
local sk16007_pre_action_baoji_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[暴击_3]
local sk16007_select_cnt_baoji_3_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[暴击_3]
local sk16007_unselect_status_baoji_3_2 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[暴击_3]
local sk16007_status_time_baoji_3_2 = function(attacker, lv)
	return 
8
end

-- 状态心跳[暴击_3]
local sk16007_status_break_baoji_3_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[暴击_3]
local sk16007_status_rate_baoji_3_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk16007_SkillLv/sk16007_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk16007")/attacker:getSkillLv("sk16007_MAX"));

	return result
end

-- 处理过程[暴击_3]
local sk16007_calc_status_baoji_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:暴击概率=500
	tbResult.custom_baoji_rate=500;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk16007.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk16007_calc_status_add_def_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk16007_pre_action_add_def_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk16007_select_cnt_add_def_0, 
		["sort_method"]="", 
		["status"]="add_def", 
		["status_break"]=sk16007_status_break_add_def_0, 
		["status_rate"]=sk16007_status_rate_add_def_0, 
		["status_time"]=sk16007_status_time_add_def_0, 
		["unselect_status"]=sk16007_unselect_status_add_def_0, 
	}, 
	{
		["calc_status"]=sk16007_calc_status_add_att_far_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk16007_pre_action_add_att_far_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk16007_select_cnt_add_att_far_1, 
		["sort_method"]="", 
		["status"]="add_att_far", 
		["status_break"]=sk16007_status_break_add_att_far_1, 
		["status_rate"]=sk16007_status_rate_add_att_far_1, 
		["status_time"]=sk16007_status_time_add_att_far_1, 
		["unselect_status"]=sk16007_unselect_status_add_att_far_1, 
	}, 
	{
		["calc_status"]=sk16007_calc_status_baoji_3_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk16007_pre_action_baoji_3_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk16007_select_cnt_baoji_3_2, 
		["sort_method"]="", 
		["status"]="baoji_3", 
		["status_break"]=sk16007_status_break_baoji_3_2, 
		["status_rate"]=sk16007_status_rate_baoji_3_2, 
		["status_time"]=sk16007_status_time_baoji_3_2, 
		["unselect_status"]=sk16007_unselect_status_baoji_3_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------