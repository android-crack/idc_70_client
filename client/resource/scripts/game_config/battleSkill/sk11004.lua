----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk11004 = class("cls_sk11004", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk11004.get_skill_id = function(self)
	return "sk11004";
end


-- 技能名 
cls_sk11004.get_skill_name = function(self)
	return T("齐射（贯穿）");
end

-- 精简版技能描述 
cls_sk11004.get_skill_short_desc = function(self)
	return T("对射程内单体敌方造成大量远程伤害。");
end

-- 获取技能的描述
cls_sk11004.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内单体敌方造成%0.1f%%远程伤害。"), (400+lv*40))
end

-- 获取技能的富文本描述
cls_sk11004.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对射程内3个敌方单位造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)远程伤害，并增加持续6秒%0.1f%%伤害的燃烧状态。"), (400+lv*40), (10+lv*2))
end

-- 公共CD 
cls_sk11004.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk11004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=15
	result = 15;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk11004.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk11004.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk11004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk11004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 开火音效 
cls_sk11004.get_fire_music = function(self)
	return "BT_SALVO_SHOT_1";
end


-- 受击音效 
cls_sk11004.get_hit_music = function(self)
	return "BT_SALVO_HIT_1";
end


-- 受击特效预加载 
cls_sk11004.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk11004_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk11004_select_cnt_attack_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[攻击]
local sk11004_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk11004_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk11004_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk11004_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk11004_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=基础远程伤害*(4+技能等级*0.4)/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(4+lv*0.4)/3;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk11004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk11004_calc_status_attack_0, 
		["effect_name"]="qishe_3", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk11004_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk11004_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk11004_status_break_attack_0, 
		["status_rate"]=sk11004_status_rate_attack_0, 
		["status_time"]=sk11004_status_time_attack_0, 
		["unselect_status"]=sk11004_unselect_status_attack_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
