----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk3021 = class("cls_sk3021", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk3021.get_skill_id = function(self)
	return "sk3021";
end


-- 技能名 
cls_sk3021.get_skill_name = function(self)
	return T("分身");
end

-- 精简版技能描述 
cls_sk3021.get_skill_short_desc = function(self)
	return T("召唤一艘占施法者攻击属性一定强度的舰船协助战斗，施法者无敌1秒，脱离异常状态");
end

-- 获取技能的描述
cls_sk3021.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("召唤一艘占施法者攻击属性%0.1f%%强度的舰船协助战斗，施法者无敌1秒，脱离异常状态"), (80+2*lv))
end

-- 获取技能的富文本描述
cls_sk3021.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)召唤一艘占施法者攻击属性$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)强度的舰船协助战斗，施法者无敌1秒，脱离异常状态"), (80+2*lv))
end

-- 公共CD 
cls_sk3021.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk3021._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 技能施法范围 
cls_sk3021.get_select_scope = function(self)
	return "SELF";
end


-- SP消耗公式
cls_sk3021.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_skillready03blue", }

cls_sk3021.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_scene", }

cls_sk3021.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk3021.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk3021.get_effect_music = function(self)
	return "BT_AVOID";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[分身]
local sk3021_pre_action_fenshen_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[分身]
local sk3021_select_cnt_fenshen_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[分身]
local sk3021_unselect_status_fenshen_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[分身]
local sk3021_status_time_fenshen_0 = function(attacker, lv)
	return 
12
end

-- 状态心跳[分身]
local sk3021_status_break_fenshen_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[分身]
local sk3021_status_rate_fenshen_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[分身]
local sk3021_calc_status_fenshen_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:分身强度=(0.8+0.02*技能等级+0.03*sk3022_SkillLv+0.04*sk3023_SkillLv)*1000
	tbResult.fenshen_strength = (0.8+0.02*lv+0.03*attacker:getSkillLv("sk3022")+0.04*attacker:getSkillLv("sk3023"))*1000;
	-- 公式原文:分身数量=1
	tbResult.fenshen_cnt = 1;
	-- 公式原文:分身造型=3
	tbResult.fenshen_ship_id = 3;
	-- 公式原文: 分身技能1 = if_else(sk3022_SkillLv==sk3022_MAX_SkillLv, "1904", nil)
	tbResult.fenshen_skill_1 =  if_else(attacker:getSkillLv("sk3022")==attacker:getSkillLv("sk3022_MAX"), "1904", nil);
	-- 公式原文:分身技能2 = if_else(sk3023_SkillLv==sk3023_MAX_SkillLv, "1905", nil)
	tbResult.fenshen_skill_2 =  if_else(attacker:getSkillLv("sk3023")==attacker:getSkillLv("sk3023_MAX"), "1905", nil);

	return tbResult
end

-- 前置动作[清除减益状态]
local sk3021_pre_action_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk3021_select_cnt_clear_debuff_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[清除减益状态]
local sk3021_unselect_status_clear_debuff_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[清除减益状态]
local sk3021_status_time_clear_debuff_1 = function(attacker, lv)
	return 
1
end

-- 状态心跳[清除减益状态]
local sk3021_status_break_clear_debuff_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk3021_status_rate_clear_debuff_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[清除减益状态]
local sk3021_calc_status_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[无敌]
local sk3021_pre_action_wudi_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无敌]
local sk3021_select_cnt_wudi_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无敌]
local sk3021_unselect_status_wudi_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无敌]
local sk3021_status_time_wudi_2 = function(attacker, lv)
	return 
1
end

-- 状态心跳[无敌]
local sk3021_status_break_wudi_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无敌]
local sk3021_status_rate_wudi_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无敌]
local sk3021_calc_status_wudi_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk3021.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk3021_calc_status_fenshen_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk3021_pre_action_fenshen_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk3021_select_cnt_fenshen_0, 
		["sort_method"]="", 
		["status"]="fenshen", 
		["status_break"]=sk3021_status_break_fenshen_0, 
		["status_rate"]=sk3021_status_rate_fenshen_0, 
		["status_time"]=sk3021_status_time_fenshen_0, 
		["unselect_status"]=sk3021_unselect_status_fenshen_0, 
	}, 
	{
		["calc_status"]=sk3021_calc_status_clear_debuff_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk3021_pre_action_clear_debuff_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk3021_select_cnt_clear_debuff_1, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk3021_status_break_clear_debuff_1, 
		["status_rate"]=sk3021_status_rate_clear_debuff_1, 
		["status_time"]=sk3021_status_time_clear_debuff_1, 
		["unselect_status"]=sk3021_unselect_status_clear_debuff_1, 
	}, 
	{
		["calc_status"]=sk3021_calc_status_wudi_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk3021_pre_action_wudi_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk3021_select_cnt_wudi_2, 
		["sort_method"]="", 
		["status"]="wudi", 
		["status_break"]=sk3021_status_break_wudi_2, 
		["status_rate"]=sk3021_status_rate_wudi_2, 
		["status_time"]=sk3021_status_time_wudi_2, 
		["unselect_status"]=sk3021_unselect_status_wudi_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk3021.end_display_call_back = function(self, attacker, target, idx, dir, is_bullet)
	local battle_data = getGameData():getBattleDataMt()
	dir = battle_data:fenshenPosition(attacker)

	self.super.end_display_call_back(self, attacker, target, idx, dir, is_bullet)
end