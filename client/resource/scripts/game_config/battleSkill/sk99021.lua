----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99021 = class("cls_sk99021", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99021.get_skill_id = function(self)
	return "sk99021";
end


-- 技能名 
cls_sk99021.get_skill_name = function(self)
	return T("boss群体贯通射击");
end

-- 精简版技能描述 
cls_sk99021.get_skill_short_desc = function(self)
	return T("对射程内3个单位敌方造成一定远程伤害，100%几率使其眩晕3秒");
end

-- 获取技能的描述
cls_sk99021.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内单体敌方造成%0.1f%%的远程伤害，100%%几率使其眩晕3秒"), (100*lv))
end

-- 获取技能的富文本描述
cls_sk99021.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，技能效果加成100%")
end

-- 公共CD 
cls_sk99021.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk99021._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=10
	result = 10;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk99021.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99021.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk99021.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk99021.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"sf_0164", }

cls_sk99021.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk99021.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk99021.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk99021.get_effect_music = function(self)
	return "BT_SALVO_CASTING";
end


-- 开火音效 
cls_sk99021.get_fire_music = function(self)
	return "BT_GUANTONG_SHOT";
end


-- 受击特效预加载 
cls_sk99021.get_preload_hit_effect = function(self)
	return "tx_guanchuan_hit";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk99021_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk99021_select_cnt_attack_0 = function(attacker, lv)
	return 
3
end

-- 目标选择忽视状态[攻击]
local sk99021_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk99021_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk99021_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk99021_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk99021_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_guanchuan_hit"
	tbResult.hit_effect = "tx_guanchuan_hit";
	-- 公式原文:扣血=基础远程伤害*(技能等级+0.14*sk3012_SkillLv+0.06*sk3013_SkillLv)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(lv+0.14*attacker:getSkillLv("sk3012")+0.06*attacker:getSkillLv("sk3013"));
	-- 公式原文:震屏次数=3
	tbResult.shake_time = 3;
	-- 公式原文:震屏幅度=2
	tbResult.shake_range = 2;

	return tbResult
end

-- 前置动作[眩晕]
local sk99021_pre_action_stun_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[眩晕]
local sk99021_select_cnt_stun_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[眩晕]
local sk99021_unselect_status_stun_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[眩晕]
local sk99021_status_time_stun_1 = function(attacker, lv)
	return 
3+3*math.floor(attacker:getSkillLv("sk3012")/attacker:getSkillLv("sk3012_MAX"))
end

-- 状态心跳[眩晕]
local sk99021_status_break_stun_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[眩晕]
local sk99021_status_rate_stun_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[眩晕]
local sk99021_calc_status_stun_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99021.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99021_calc_status_attack_0, 
		["effect_name"]="guantong", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk99021_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99021_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk99021_status_break_attack_0, 
		["status_rate"]=sk99021_status_rate_attack_0, 
		["status_time"]=sk99021_status_time_attack_0, 
		["unselect_status"]=sk99021_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk99021_calc_status_stun_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99021_pre_action_stun_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99021_select_cnt_stun_1, 
		["sort_method"]="", 
		["status"]="stun", 
		["status_break"]=sk99021_status_break_stun_1, 
		["status_rate"]=sk99021_status_rate_stun_1, 
		["status_time"]=sk99021_status_time_stun_1, 
		["unselect_status"]=sk99021_unselect_status_stun_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------