----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk2021 = class("cls_sk2021", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk2021.get_skill_id = function(self)
	return "sk2021";
end


-- 技能名 
cls_sk2021.get_skill_name = function(self)
	return T("嘲讽");
end

-- 精简版技能描述 
cls_sk2021.get_skill_short_desc = function(self)
	return T("令射程内所有敌方攻击施法者，持续4秒，并提升施法者一定防御，持续12秒。");
end

-- 获取技能的描述
cls_sk2021.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("令射程内所有敌方攻击施法者，持续4秒，并提升施法者%0.1f%%的防御，持续12秒。"), (160+4*lv))
end

-- 获取技能的富文本描述
cls_sk2021.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)令射程内所有敌方攻击施法者，持续4秒，并提升施法者$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的防御，持续12秒。"), (160+4*lv))
end

-- 公共CD 
cls_sk2021.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk2021._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk2021.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk2021.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk2021.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk2021.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_0173", }

cls_sk2021.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk2021.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk2021.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk2021.get_effect_music = function(self)
	return "BT_DEFENSE";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加防]
local sk2021_pre_action_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防]
local sk2021_select_cnt_add_def_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加防]
local sk2021_unselect_status_add_def_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加防]
local sk2021_status_time_add_def_0 = function(attacker, lv)
	return 
12
end

-- 状态心跳[加防]
local sk2021_status_break_add_def_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防]
local sk2021_status_rate_add_def_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加防]
local sk2021_calc_status_add_def_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=A防御*(1.6+0.04*技能等级+0.06*sk2022_SkillLv+0.08*sk2023_SkillLv)
	tbResult.add_defend = iADefense*(1.6+0.04*lv+0.06*attacker:getSkillLv("sk2022")+0.08*attacker:getSkillLv("sk2023"));

	return tbResult
end

-- 前置动作[加近攻]
local sk2021_pre_action_add_att_near_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻]
local sk2021_select_cnt_add_att_near_1 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加近攻]
local sk2021_unselect_status_add_att_near_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加近攻]
local sk2021_status_time_add_att_near_1 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=12
	result = 12;

	return result
end

-- 状态心跳[加近攻]
local sk2021_status_break_add_att_near_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻]
local sk2021_status_rate_add_att_near_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk2022_SkillLv/sk2022_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk2022")/attacker:getSkillLv("sk2022_MAX"));

	return result
end

-- 处理过程[加近攻]
local sk2021_calc_status_add_att_near_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=0.5*A近战攻击
	tbResult.add_att_near = 0.5*iANear;

	return tbResult
end

-- 前置动作[嘲讽]
local sk2021_pre_action_chaofeng_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[嘲讽]
local sk2021_select_cnt_chaofeng_2 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[嘲讽]
local sk2021_unselect_status_chaofeng_2 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[嘲讽]
local sk2021_status_time_chaofeng_2 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=4
	result = 4;

	return result
end

-- 状态心跳[嘲讽]
local sk2021_status_break_chaofeng_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[嘲讽]
local sk2021_status_rate_chaofeng_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[嘲讽]
local sk2021_calc_status_chaofeng_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[加防]
local sk2021_pre_action_add_def_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防]
local sk2021_select_cnt_add_def_3 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加防]
local sk2021_unselect_status_add_def_3 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加防]
local sk2021_status_time_add_def_3 = function(attacker, lv)
	return 
12
end

-- 状态心跳[加防]
local sk2021_status_break_add_def_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防]
local sk2021_status_rate_add_def_3 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHit = attacker:getHitRate();

	-- 公式原文:结果=1000*取整(sk2023_SkillLv/sk2023_MAX_SkillLv)-A命中
	result = 1000*math.floor(attacker:getSkillLv("sk2023")/attacker:getSkillLv("sk2023_MAX"))-iAHit;

	return result
end

-- 处理过程[加防]
local sk2021_calc_status_add_def_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=A防御*(1.6+0.04*技能等级+0.06*sk2022_SkillLv+0.08*sk2023_SkillLv)
	tbResult.add_defend = iADefense*(1.6+0.04*lv+0.06*attacker:getSkillLv("sk2022")+0.08*attacker:getSkillLv("sk2023"));

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk2021.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk2021_calc_status_add_def_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2021_pre_action_add_def_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk2021_select_cnt_add_def_0, 
		["sort_method"]="", 
		["status"]="add_def", 
		["status_break"]=sk2021_status_break_add_def_0, 
		["status_rate"]=sk2021_status_rate_add_def_0, 
		["status_time"]=sk2021_status_time_add_def_0, 
		["unselect_status"]=sk2021_unselect_status_add_def_0, 
	}, 
	{
		["calc_status"]=sk2021_calc_status_add_att_near_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2021_pre_action_add_att_near_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk2021_select_cnt_add_att_near_1, 
		["sort_method"]="", 
		["status"]="add_att_near", 
		["status_break"]=sk2021_status_break_add_att_near_1, 
		["status_rate"]=sk2021_status_rate_add_att_near_1, 
		["status_time"]=sk2021_status_time_add_att_near_1, 
		["unselect_status"]=sk2021_unselect_status_add_att_near_1, 
	}, 
	{
		["calc_status"]=sk2021_calc_status_chaofeng_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2021_pre_action_chaofeng_2, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk2021_select_cnt_chaofeng_2, 
		["sort_method"]="DISTANCE_ASEC", 
		["status"]="chaofeng", 
		["status_break"]=sk2021_status_break_chaofeng_2, 
		["status_rate"]=sk2021_status_rate_chaofeng_2, 
		["status_time"]=sk2021_status_time_chaofeng_2, 
		["unselect_status"]=sk2021_unselect_status_chaofeng_2, 
	}, 
	{
		["calc_status"]=sk2021_calc_status_add_def_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2021_pre_action_add_def_3, 
		["scope"]="FRIEND_OTHER", 
		["select_cnt"]=sk2021_select_cnt_add_def_3, 
		["sort_method"]="", 
		["status"]="add_def", 
		["status_break"]=sk2021_status_break_add_def_3, 
		["status_rate"]=sk2021_status_rate_add_def_3, 
		["status_time"]=sk2021_status_time_add_def_3, 
		["unselect_status"]=sk2021_unselect_status_add_def_3, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------