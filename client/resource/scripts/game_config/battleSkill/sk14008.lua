----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk14008 = class("cls_sk14008", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk14008.get_skill_id = function(self)
	return "sk14008";
end


-- 技能名 
cls_sk14008.get_skill_name = function(self)
	return T("反击触发技能");
end

-- 获取技能的描述
cls_sk14008.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk14008.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最大施法限制距离
cls_sk14008.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999
	result = 99999;

	return result
end

-- SP消耗公式
cls_sk14008.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk14008.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk14008.get_before_effect_type = function(self)
	return before_effect_type
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[扣血]
local sk14008_pre_action_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk14008_select_cnt_sub_hp_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[扣血]
local sk14008_unselect_status_sub_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[扣血]
local sk14008_status_time_sub_hp_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[扣血]
local sk14008_status_break_sub_hp_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[扣血]
local sk14008_status_rate_sub_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[扣血]
local sk14008_calc_status_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础近战伤害*(0.8+技能等级*0.1+0.3*取整(sk14007_SkillLv/sk14007_MAX_SkillLv))
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(0.8+lv*0.1+0.3*math.floor(attacker:getSkillLv("sk14007")/attacker:getSkillLv("sk14007_MAX")));
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk14008.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk14008_calc_status_sub_hp_0, 
		["effect_name"]="attack_yellow", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk14008_pre_action_sub_hp_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk14008_select_cnt_sub_hp_0, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk14008_status_break_sub_hp_0, 
		["status_rate"]=sk14008_status_rate_sub_hp_0, 
		["status_time"]=sk14008_status_time_sub_hp_0, 
		["unselect_status"]=sk14008_unselect_status_sub_hp_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk14008.get_skill_type = function(self)
    return "auto"
end

cls_sk14008.get_skill_lv = function(self, attacker)
	return cls_sk14007:get_skill_lv( attacker )
end