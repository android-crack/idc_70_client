----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk2051 = class("cls_sk2051", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk2051.get_skill_id = function(self)
	return "sk2051";
end


-- 技能名 
cls_sk2051.get_skill_name = function(self)
	return T("烟雾弹");
end

-- 精简版技能描述 
cls_sk2051.get_skill_short_desc = function(self)
	return T("增加闪避率和速度和暴击率，持续8秒");
end

-- 获取技能的描述
cls_sk2051.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("增加%0.1f%%闪避率和80点移动速度和%0.1f%%暴击率，持续8秒"), (100+1*lv), (40+1*lv))
end

-- 获取技能的富文本描述
cls_sk2051.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)暴击率提升$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)，且增加$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的闪避率和80点移动速度，持续8秒"), (40+1*lv), (100+1*lv))
end

-- 公共CD 
cls_sk2051.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk2051._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=30-10*取整(sk2052_SkillLv/sk2052_MAX_SkillLv)
	result = 30-10*math.floor(attacker:getSkillLv("sk2052")/attacker:getSkillLv("sk2052_MAX"));

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk2051.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk2051.get_select_scope = function(self)
	return "SELF";
end


-- 最大施法限制距离
cls_sk2051.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=320
	result = 320;

	return result
end

-- SP消耗公式
cls_sk2051.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_0171", "screen_yanwudan", }

cls_sk2051.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", "cocos_scene", }

cls_sk2051.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk2051.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk2051.get_effect_music = function(self)
	return "BT_HOOK_CASTING";
end


-- 开火音效 
cls_sk2051.get_fire_music = function(self)
	return "BT_YANWUDAN_SHOT";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[暴击_3]
local sk2051_pre_action_baoji_3_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[暴击_3]
local sk2051_select_cnt_baoji_3_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[暴击_3]
local sk2051_unselect_status_baoji_3_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[暴击_3]
local sk2051_status_time_baoji_3_0 = function(attacker, lv)
	return 
8
end

-- 状态心跳[暴击_3]
local sk2051_status_break_baoji_3_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[暴击_3]
local sk2051_status_rate_baoji_3_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[暴击_3]
local sk2051_calc_status_baoji_3_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:暴击概率=(400+10*技能等级+15*sk2053_SkillLv+20*sk2053_SkillLv)
	tbResult.custom_baoji_rate=(400+10*lv+15*attacker:getSkillLv("sk2053")+20*attacker:getSkillLv("sk2053"));

	return tbResult
end

-- 前置动作[闪避_3]
local sk2051_pre_action_dodge_3_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[闪避_3]
local sk2051_select_cnt_dodge_3_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[闪避_3]
local sk2051_unselect_status_dodge_3_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[闪避_3]
local sk2051_status_time_dodge_3_1 = function(attacker, lv)
	return 
8
end

-- 状态心跳[闪避_3]
local sk2051_status_break_dodge_3_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[闪避_3]
local sk2051_status_rate_dodge_3_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[闪避_3]
local sk2051_calc_status_dodge_3_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:提升闪避=1000+(10*技能等级+15*sk2052_SkillLv+20*sk2053_SkillLv)
	tbResult.dodge= 1000+(10*lv+15*attacker:getSkillLv("sk2052")+20*attacker:getSkillLv("sk2053"));

	return tbResult
end

-- 前置动作[加速_3]
local sk2051_pre_action_fast_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加速_3]
local sk2051_select_cnt_fast_3_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加速_3]
local sk2051_unselect_status_fast_3_2 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加速_3]
local sk2051_status_time_fast_3_2 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加速_3]
local sk2051_status_break_fast_3_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加速_3]
local sk2051_status_rate_fast_3_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加速_3]
local sk2051_calc_status_fast_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:加速=80
	tbResult.add_speed = 80;

	return tbResult
end

-- 前置动作[希腊火_2]
local sk2051_pre_action_xilahuo_self_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[希腊火_2]
local sk2051_select_cnt_xilahuo_self_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[希腊火_2]
local sk2051_unselect_status_xilahuo_self_3 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[希腊火_2]
local sk2051_status_time_xilahuo_self_3 = function(attacker, lv)
	return 
8
end

-- 状态心跳[希腊火_2]
local sk2051_status_break_xilahuo_self_3 = function(attacker, lv)
	return 
1/2
end

-- 命中率公式[希腊火_2]
local sk2051_status_rate_xilahuo_self_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk2053_SkillLv/sk2053_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk2053")/attacker:getSkillLv("sk2053_MAX"));

	return result
end

-- 处理过程[希腊火_2]
local sk2051_calc_status_xilahuo_self_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:突击触发技能="sk90027"
	tbResult.tj_skill_id = "sk90027";

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk2051.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk2051_calc_status_baoji_3_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2051_pre_action_baoji_3_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk2051_select_cnt_baoji_3_0, 
		["sort_method"]="", 
		["status"]="baoji_3", 
		["status_break"]=sk2051_status_break_baoji_3_0, 
		["status_rate"]=sk2051_status_rate_baoji_3_0, 
		["status_time"]=sk2051_status_time_baoji_3_0, 
		["unselect_status"]=sk2051_unselect_status_baoji_3_0, 
	}, 
	{
		["calc_status"]=sk2051_calc_status_dodge_3_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2051_pre_action_dodge_3_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk2051_select_cnt_dodge_3_1, 
		["sort_method"]="", 
		["status"]="dodge_3", 
		["status_break"]=sk2051_status_break_dodge_3_1, 
		["status_rate"]=sk2051_status_rate_dodge_3_1, 
		["status_time"]=sk2051_status_time_dodge_3_1, 
		["unselect_status"]=sk2051_unselect_status_dodge_3_1, 
	}, 
	{
		["calc_status"]=sk2051_calc_status_fast_3_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2051_pre_action_fast_3_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk2051_select_cnt_fast_3_2, 
		["sort_method"]="", 
		["status"]="fast_3", 
		["status_break"]=sk2051_status_break_fast_3_2, 
		["status_rate"]=sk2051_status_rate_fast_3_2, 
		["status_time"]=sk2051_status_time_fast_3_2, 
		["unselect_status"]=sk2051_unselect_status_fast_3_2, 
	}, 
	{
		["calc_status"]=sk2051_calc_status_xilahuo_self_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2051_pre_action_xilahuo_self_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk2051_select_cnt_xilahuo_self_3, 
		["sort_method"]="", 
		["status"]="xilahuo_self", 
		["status_break"]=sk2051_status_break_xilahuo_self_3, 
		["status_rate"]=sk2051_status_rate_xilahuo_self_3, 
		["status_time"]=sk2051_status_time_xilahuo_self_3, 
		["unselect_status"]=sk2051_unselect_status_xilahuo_self_3, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------