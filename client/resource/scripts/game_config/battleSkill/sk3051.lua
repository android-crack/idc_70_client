----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk3051 = class("cls_sk3051", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk3051.get_skill_id = function(self)
	return "sk3051";
end


-- 技能名 
cls_sk3051.get_skill_name = function(self)
	return T("海神祝福");
end

-- 精简版技能描述 
cls_sk3051.get_skill_short_desc = function(self)
	return T("射程内友军恢复一定耐久，敌人受到伤害，持续6秒");
end

-- 获取技能的描述
cls_sk3051.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("射程内友军每秒恢复施法者耐久上限%0.1f%%的耐久，敌人受到耐久上限%0.1f%%的伤害，持续6秒。"), (4+0.1*lv), (2+0.05*lv))
end

-- 获取技能的富文本描述
cls_sk3051.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)射程内恢复施法者耐久上限$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的耐久，敌人受到耐久上限%0.1f%%的伤害，持续6秒。"), (4+0.1*lv), (2+0.05*lv))
end

-- 公共CD 
cls_sk3051.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk3051._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=40-15*取整(sk3053_SkillLv/sk3053_MAX_SkillLv)
	result = 40-15*math.floor(attacker:getSkillLv("sk3053")/attacker:getSkillLv("sk3053_MAX"));

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk3051.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk3051.get_select_scope = function(self)
	return "SELF";
end


-- SP消耗公式
cls_sk3051.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"sf_jiagu", "screen_chuantixiubu", }

cls_sk3051.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_scene", "armature_scene", }

cls_sk3051.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk3051.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk3051.get_effect_music = function(self)
	return "BT_REINFORCE";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[通用触发技能]
local sk3051_pre_action_tongyongchufajineng_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[通用触发技能]
local sk3051_select_cnt_tongyongchufajineng_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[通用触发技能]
local sk3051_unselect_status_tongyongchufajineng_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[通用触发技能]
local sk3051_status_time_tongyongchufajineng_0 = function(attacker, lv)
	return 
6
end

-- 状态心跳[通用触发技能]
local sk3051_status_break_tongyongchufajineng_0 = function(attacker, lv)
	return 
1
end

-- 命中率公式[通用触发技能]
local sk3051_status_rate_tongyongchufajineng_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[通用触发技能]
local sk3051_calc_status_tongyongchufajineng_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:通用触发技能="sk90025"
	tbResult.ty_skill_id = "sk90025";

	return tbResult
end

-- 前置动作[海之祝福]
local sk3051_pre_action_haizhizhufu_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[海之祝福]
local sk3051_select_cnt_haizhizhufu_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[海之祝福]
local sk3051_unselect_status_haizhizhufu_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[海之祝福]
local sk3051_status_time_haizhizhufu_1 = function(attacker, lv)
	return 
6
end

-- 状态心跳[海之祝福]
local sk3051_status_break_haizhizhufu_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[海之祝福]
local sk3051_status_rate_haizhizhufu_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[海之祝福]
local sk3051_calc_status_haizhizhufu_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[清除减益状态]
local sk3051_pre_action_clear_debuff_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk3051_select_cnt_clear_debuff_2 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[清除减益状态]
local sk3051_unselect_status_clear_debuff_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[清除减益状态]
local sk3051_status_time_clear_debuff_2 = function(attacker, lv)
	return 
0
end

-- 状态心跳[清除减益状态]
local sk3051_status_break_clear_debuff_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk3051_status_rate_clear_debuff_2 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHit = attacker:getHitRate();

	-- 公式原文:结果=1000*取整(sk3052_SkillLv/sk3052_MAX_SkillLv)-A命中
	result = 1000*math.floor(attacker:getSkillLv("sk3052")/attacker:getSkillLv("sk3052_MAX"))-iAHit;

	return result
end

-- 处理过程[清除减益状态]
local sk3051_calc_status_clear_debuff_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk3051.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk3051_calc_status_tongyongchufajineng_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk3051_pre_action_tongyongchufajineng_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk3051_select_cnt_tongyongchufajineng_0, 
		["sort_method"]="", 
		["status"]="tongyongchufajineng", 
		["status_break"]=sk3051_status_break_tongyongchufajineng_0, 
		["status_rate"]=sk3051_status_rate_tongyongchufajineng_0, 
		["status_time"]=sk3051_status_time_tongyongchufajineng_0, 
		["unselect_status"]=sk3051_unselect_status_tongyongchufajineng_0, 
	}, 
	{
		["calc_status"]=sk3051_calc_status_haizhizhufu_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk3051_pre_action_haizhizhufu_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk3051_select_cnt_haizhizhufu_1, 
		["sort_method"]="", 
		["status"]="haizhizhufu", 
		["status_break"]=sk3051_status_break_haizhizhufu_1, 
		["status_rate"]=sk3051_status_rate_haizhizhufu_1, 
		["status_time"]=sk3051_status_time_haizhizhufu_1, 
		["unselect_status"]=sk3051_unselect_status_haizhizhufu_1, 
	}, 
	{
		["calc_status"]=sk3051_calc_status_clear_debuff_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk3051_pre_action_clear_debuff_2, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk3051_select_cnt_clear_debuff_2, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk3051_status_break_clear_debuff_2, 
		["status_rate"]=sk3051_status_rate_clear_debuff_2, 
		["status_time"]=sk3051_status_time_clear_debuff_2, 
		["unselect_status"]=sk3051_unselect_status_clear_debuff_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------