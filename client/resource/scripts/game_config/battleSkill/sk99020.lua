----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99020 = class("cls_sk99020", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99020.get_skill_id = function(self)
	return "sk99020";
end


-- 技能名 
cls_sk99020.get_skill_name = function(self)
	return T("boss烟雾弹");
end

-- 精简版技能描述 
cls_sk99020.get_skill_short_desc = function(self)
	return T("近战攻击提升，且增加闪避率和速度，持续8秒");
end

-- 获取技能的描述
cls_sk99020.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("近战攻击提升%0.1f%%，且增加闪避率和速度，持续8秒"), (20*lv))
end

-- 获取技能的富文本描述
cls_sk99020.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，技能效果加成20%")
end

-- 公共CD 
cls_sk99020.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk99020._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=30-10*取整(sk2052_SkillLv/sk2052_MAX_SkillLv)
	result = 30-10*math.floor(attacker:getSkillLv("sk2052")/attacker:getSkillLv("sk2052_MAX"));

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk99020.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99020.get_select_scope = function(self)
	return "SELF";
end


-- SP消耗公式
cls_sk99020.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_0171", "screen_yanwudan", }

cls_sk99020.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", "cocos_scene", }

cls_sk99020.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk99020.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk99020.get_effect_music = function(self)
	return "BT_HOOK_CASTING";
end


-- 开火音效 
cls_sk99020.get_fire_music = function(self)
	return "BT_YANWUDAN_SHOT";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加近攻]
local sk99020_pre_action_add_att_near_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻]
local sk99020_select_cnt_add_att_near_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加近攻]
local sk99020_unselect_status_add_att_near_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加近攻]
local sk99020_status_time_add_att_near_0 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加近攻]
local sk99020_status_break_add_att_near_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻]
local sk99020_status_rate_add_att_near_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加近攻]
local sk99020_calc_status_add_att_near_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=(0.2*技能等级+0.05*sk2052_SkillLv+0.03*sk2053_SkillLv)*A近战攻击
	tbResult.add_att_near = (0.2*lv+0.05*attacker:getSkillLv("sk2052")+0.03*attacker:getSkillLv("sk2053"))*iANear;

	return tbResult
end

-- 前置动作[闪避]
local sk99020_pre_action_dodge_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[闪避]
local sk99020_select_cnt_dodge_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[闪避]
local sk99020_unselect_status_dodge_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[闪避]
local sk99020_status_time_dodge_1 = function(attacker, lv)
	return 
8
end

-- 状态心跳[闪避]
local sk99020_status_break_dodge_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[闪避]
local sk99020_status_rate_dodge_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[闪避]
local sk99020_calc_status_dodge_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:提升闪避=700+取整(sk2053_SkillLv/sk2053_MAX_SkillLv)*300
	tbResult.dodge= 700+math.floor(attacker:getSkillLv("sk2053")/attacker:getSkillLv("sk2053_MAX"))*300;

	return tbResult
end

-- 前置动作[加速]
local sk99020_pre_action_fast_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加速]
local sk99020_select_cnt_fast_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加速]
local sk99020_unselect_status_fast_2 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加速]
local sk99020_status_time_fast_2 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加速]
local sk99020_status_break_fast_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加速]
local sk99020_status_rate_fast_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加速]
local sk99020_calc_status_fast_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:加速=80
	tbResult.add_speed = 80;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99020.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99020_calc_status_add_att_near_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99020_pre_action_add_att_near_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk99020_select_cnt_add_att_near_0, 
		["sort_method"]="", 
		["status"]="add_att_near", 
		["status_break"]=sk99020_status_break_add_att_near_0, 
		["status_rate"]=sk99020_status_rate_add_att_near_0, 
		["status_time"]=sk99020_status_time_add_att_near_0, 
		["unselect_status"]=sk99020_unselect_status_add_att_near_0, 
	}, 
	{
		["calc_status"]=sk99020_calc_status_dodge_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99020_pre_action_dodge_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99020_select_cnt_dodge_1, 
		["sort_method"]="", 
		["status"]="dodge", 
		["status_break"]=sk99020_status_break_dodge_1, 
		["status_rate"]=sk99020_status_rate_dodge_1, 
		["status_time"]=sk99020_status_time_dodge_1, 
		["unselect_status"]=sk99020_unselect_status_dodge_1, 
	}, 
	{
		["calc_status"]=sk99020_calc_status_fast_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99020_pre_action_fast_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99020_select_cnt_fast_2, 
		["sort_method"]="", 
		["status"]="fast", 
		["status_break"]=sk99020_status_break_fast_2, 
		["status_rate"]=sk99020_status_rate_fast_2, 
		["status_time"]=sk99020_status_time_fast_2, 
		["unselect_status"]=sk99020_unselect_status_fast_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------