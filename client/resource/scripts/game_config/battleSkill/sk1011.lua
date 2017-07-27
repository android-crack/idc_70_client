----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk1011 = class("cls_sk1011", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk1011.get_skill_id = function(self)
	return "sk1011";
end


-- 技能名 
cls_sk1011.get_skill_name = function(self)
	return T("葡萄弹");
end

-- 精简版技能描述 
cls_sk1011.get_skill_short_desc = function(self)
	return T("对射程内单体敌方造成一定远程伤害，并击退对方");
end

-- 获取技能的描述
cls_sk1011.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内单体敌方造成%0.1f%%远程伤害，并击退对方"), (250+lv*8))
end

-- 获取技能的富文本描述
cls_sk1011.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对射程内单体敌方造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)远程伤害，并击退对方"), (250+lv*8))
end

-- 公共CD 
cls_sk1011.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk1011._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk1011.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk1011.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk1011.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk1011.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_skillready", }

cls_sk1011.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_scene", }

cls_sk1011.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk1011.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk1011.get_effect_music = function(self)
	return "BT_CHAIN_CASTING";
end


-- 开火音效 
cls_sk1011.get_fire_music = function(self)
	return "BT_PUTAODAN_SHOT";
end


-- 受击音效 
cls_sk1011.get_hit_music = function(self)
	return "BT_PUTAODAN_HIT";
end


-- 受击特效预加载 
cls_sk1011.get_preload_hit_effect = function(self)
	return "tx_0174_boom";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk1011_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=32
	tbResult.translate = 32;

	return tbResult
end

-- 目标选择基础数量[攻击]
local sk1011_select_cnt_attack_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=1+取整(sk1013_SkillLv/sk1013_MAX_SkillLv)
	result = 1+math.floor(attacker:getSkillLv("sk1013")/attacker:getSkillLv("sk1013_MAX"));

	return result
end

-- 目标选择忽视状态[攻击]
local sk1011_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk1011_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk1011_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk1011_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk1011_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_0174_boom"
	tbResult.hit_effect = "tx_0174_boom";
	-- 公式原文:扣血=基础远程伤害*(2.5+技能等级*0.08+sk1012_SkillLv*0.12+sk1013_SkillLv*0.15)/6
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(2.5+lv*0.08+attacker:getSkillLv("sk1012")*0.12+attacker:getSkillLv("sk1013")*0.15)/6;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=1
	tbResult.shake_range = 1;

	return tbResult
end

-- 前置动作[加远攻]
local sk1011_pre_action_add_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻]
local sk1011_select_cnt_add_att_far_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加远攻]
local sk1011_unselect_status_add_att_far_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加远攻]
local sk1011_status_time_add_att_far_1 = function(attacker, lv)
	return 
4
end

-- 状态心跳[加远攻]
local sk1011_status_break_add_att_far_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻]
local sk1011_status_rate_add_att_far_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk1012_SkillLv/sk1012_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk1012")/attacker:getSkillLv("sk1012_MAX"));

	return result
end

-- 处理过程[加远攻]
local sk1011_calc_status_add_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=A远程攻击*0.5
	tbResult.add_att_far = iAAtt*0.5;

	return tbResult
end

-- 前置动作[加近攻]
local sk1011_pre_action_add_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻]
local sk1011_select_cnt_add_att_near_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加近攻]
local sk1011_unselect_status_add_att_near_2 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加近攻]
local sk1011_status_time_add_att_near_2 = function(attacker, lv)
	return 
4
end

-- 状态心跳[加近攻]
local sk1011_status_break_add_att_near_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻]
local sk1011_status_rate_add_att_near_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk1012_SkillLv/sk1012_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk1012")/attacker:getSkillLv("sk1012_MAX"));

	return result
end

-- 处理过程[加近攻]
local sk1011_calc_status_add_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=A近战攻击*0.5
	tbResult.add_att_near = iANear*0.5;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk1011.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk1011_calc_status_attack_0, 
		["effect_name"]="putaodan", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk1011_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk1011_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk1011_status_break_attack_0, 
		["status_rate"]=sk1011_status_rate_attack_0, 
		["status_time"]=sk1011_status_time_attack_0, 
		["unselect_status"]=sk1011_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk1011_calc_status_add_att_far_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1011_pre_action_add_att_far_1, 
		["scope"]="SELF", 
		["select_cnt"]=sk1011_select_cnt_add_att_far_1, 
		["sort_method"]="", 
		["status"]="add_att_far", 
		["status_break"]=sk1011_status_break_add_att_far_1, 
		["status_rate"]=sk1011_status_rate_add_att_far_1, 
		["status_time"]=sk1011_status_time_add_att_far_1, 
		["unselect_status"]=sk1011_unselect_status_add_att_far_1, 
	}, 
	{
		["calc_status"]=sk1011_calc_status_add_att_near_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1011_pre_action_add_att_near_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1011_select_cnt_add_att_near_2, 
		["sort_method"]="", 
		["status"]="add_att_near", 
		["status_break"]=sk1011_status_break_add_att_near_2, 
		["status_rate"]=sk1011_status_rate_add_att_near_2, 
		["status_time"]=sk1011_status_time_add_att_near_2, 
		["unselect_status"]=sk1011_unselect_status_add_att_near_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------