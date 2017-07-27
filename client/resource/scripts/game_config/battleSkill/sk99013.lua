----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99013 = class("cls_sk99013", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99013.get_skill_id = function(self)
	return "sk99013";
end


-- 技能名 
cls_sk99013.get_skill_name = function(self)
	return T("boss火焰喷射");
end

-- 精简版技能描述 
cls_sk99013.get_skill_short_desc = function(self)
	return T("从船头喷射火焰，造成一定持续伤害，且无法治疗，持续3秒，施法者速度降为0");
end

-- 获取技能的描述
cls_sk99013.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("从船头喷射火焰，每秒造成%0.1f%%的持续伤害并无法治疗，持续3秒，施法者速度降为0"), (60*lv))
end

-- 获取技能的富文本描述
cls_sk99013.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk99013.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk99013._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=40
	result = 40;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk99013.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99013.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk99013.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=575
	result = 575;

	return result
end

-- SP消耗公式
cls_sk99013.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_skillready", "screen_huoyandan", }

cls_sk99013.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_scene", "armature_scene", }

cls_sk99013.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk99013.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk99013.get_effect_music = function(self)
	return "BT_CHAIN_CASTING";
end


-- 开火音效 
cls_sk99013.get_fire_music = function(self)
	return "BT_CHAIN_SHOT";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[减速_3]
local sk99013_pre_action_slow_3_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减速_3]
local sk99013_select_cnt_slow_3_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减速_3]
local sk99013_unselect_status_slow_3_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减速_3]
local sk99013_status_time_slow_3_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=3+1.5*取整(sk1052_SkillLv/sk1052_MAX_SkillLv)
	result = 3+1.5*math.floor(attacker:getSkillLv("sk1052")/attacker:getSkillLv("sk1052_MAX"));

	return result
end

-- 状态心跳[减速_3]
local sk99013_status_break_slow_3_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减速_3]
local sk99013_status_rate_slow_3_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[减速_3]
local sk99013_calc_status_slow_3_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的速度
	local iASpeed = attacker:getSpeed();

	-- 公式原文:减速=A速度
	tbResult.sub_speed = iASpeed;

	return tbResult
end

-- 前置动作[免疫速度改变]
local sk99013_pre_action_unspeedable_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=20
	tbResult.translate = 20;

	return tbResult
end

-- 目标选择基础数量[免疫速度改变]
local sk99013_select_cnt_unspeedable_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[免疫速度改变]
local sk99013_unselect_status_unspeedable_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[免疫速度改变]
local sk99013_status_time_unspeedable_1 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=3+1.5*取整(sk1052_SkillLv/sk1052_MAX_SkillLv)
	result = 3+1.5*math.floor(attacker:getSkillLv("sk1052")/attacker:getSkillLv("sk1052_MAX"));

	return result
end

-- 状态心跳[免疫速度改变]
local sk99013_status_break_unspeedable_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[免疫速度改变]
local sk99013_status_rate_unspeedable_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[免疫速度改变]
local sk99013_calc_status_unspeedable_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[火焰喷射]
local sk99013_pre_action_jet_flame_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[火焰喷射]
local sk99013_select_cnt_jet_flame_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[火焰喷射]
local sk99013_unselect_status_jet_flame_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[火焰喷射]
local sk99013_status_time_jet_flame_2 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=3+1.5*取整(sk1052_SkillLv/sk1052_MAX_SkillLv)
	result = 3+1.5*math.floor(attacker:getSkillLv("sk1052")/attacker:getSkillLv("sk1052_MAX"));

	return result
end

-- 状态心跳[火焰喷射]
local sk99013_status_break_jet_flame_2 = function(attacker, lv)
	return 
1/2
end

-- 命中率公式[火焰喷射]
local sk99013_status_rate_jet_flame_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[火焰喷射]
local sk99013_calc_status_jet_flame_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:场景技能长度=575
	tbResult.BossSkill_Length = 575;
	-- 公式原文:场景技能宽度=100
	tbResult.BossSkill_Width = 100;
	-- 公式原文:关联技能="sk99014"
	tbResult.BossSkill = "sk99014";

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99013.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99013_calc_status_slow_3_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99013_pre_action_slow_3_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk99013_select_cnt_slow_3_0, 
		["sort_method"]="", 
		["status"]="slow_3", 
		["status_break"]=sk99013_status_break_slow_3_0, 
		["status_rate"]=sk99013_status_rate_slow_3_0, 
		["status_time"]=sk99013_status_time_slow_3_0, 
		["unselect_status"]=sk99013_unselect_status_slow_3_0, 
	}, 
	{
		["calc_status"]=sk99013_calc_status_unspeedable_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99013_pre_action_unspeedable_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99013_select_cnt_unspeedable_1, 
		["sort_method"]="", 
		["status"]="unspeedable", 
		["status_break"]=sk99013_status_break_unspeedable_1, 
		["status_rate"]=sk99013_status_rate_unspeedable_1, 
		["status_time"]=sk99013_status_time_unspeedable_1, 
		["unselect_status"]=sk99013_unselect_status_unspeedable_1, 
	}, 
	{
		["calc_status"]=sk99013_calc_status_jet_flame_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99013_pre_action_jet_flame_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99013_select_cnt_jet_flame_2, 
		["sort_method"]="", 
		["status"]="jet_flame", 
		["status_break"]=sk99013_status_break_jet_flame_2, 
		["status_rate"]=sk99013_status_rate_jet_flame_2, 
		["status_time"]=sk99013_status_time_jet_flame_2, 
		["unselect_status"]=sk99013_unselect_status_jet_flame_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------