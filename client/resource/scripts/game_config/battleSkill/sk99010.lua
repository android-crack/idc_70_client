----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99010 = class("cls_sk99010", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99010.get_skill_id = function(self)
	return "sk99010";
end


-- 技能名 
cls_sk99010.get_skill_name = function(self)
	return T("BOSS船体修补");
end

-- 精简版技能描述 
cls_sk99010.get_skill_short_desc = function(self)
	return T("所有友军恢复一定耐久，持续4秒");
end

-- 获取技能的描述
cls_sk99010.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("所有友军恢复施法者耐久上限%0.1f%%的耐久，持续4秒。"), (5*lv))
end

-- 获取技能的富文本描述
cls_sk99010.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，耐久恢复共加成20%")
end

-- 公共CD 
cls_sk99010.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk99010._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=40-15*取整(sk3053_SkillLv/sk3053_MAX_SkillLv)
	result = 40-15*math.floor(attacker:getSkillLv("sk3053")/attacker:getSkillLv("sk3053_MAX"));

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk99010.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99010.get_select_scope = function(self)
	return "FRIEND";
end


-- 最大施法限制距离
cls_sk99010.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=999999
	result = 999999;

	return result
end

-- SP消耗公式
cls_sk99010.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"sf_jiagu", "screen_chuantixiubu", }

cls_sk99010.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_scene", "armature_scene", }

cls_sk99010.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk99010.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk99010.get_effect_music = function(self)
	return "BT_REINFORCE";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血]
local sk99010_pre_action_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血]
local sk99010_select_cnt_add_hp_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加血]
local sk99010_unselect_status_add_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加血]
local sk99010_status_time_add_hp_0 = function(attacker, lv)
	return 
4
end

-- 状态心跳[加血]
local sk99010_status_break_add_hp_0 = function(attacker, lv)
	return 
1
end

-- 命中率公式[加血]
local sk99010_status_rate_add_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加血]
local sk99010_calc_status_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=A耐久上限*(0.05*技能等级+0.012*sk3052_SkillLv+0.012*sk3053_SkillLv)
	tbResult.add_hp = iAHpLimit*(0.05*lv+0.012*attacker:getSkillLv("sk3052")+0.012*attacker:getSkillLv("sk3053"));

	return tbResult
end

-- 前置动作[清除减益状态]
local sk99010_pre_action_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk99010_select_cnt_clear_debuff_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[清除减益状态]
local sk99010_unselect_status_clear_debuff_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[清除减益状态]
local sk99010_status_time_clear_debuff_1 = function(attacker, lv)
	return 
1
end

-- 状态心跳[清除减益状态]
local sk99010_status_break_clear_debuff_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk99010_status_rate_clear_debuff_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk3052_SkillLv/sk3052_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk3052")/attacker:getSkillLv("sk3052_MAX"));

	return result
end

-- 处理过程[清除减益状态]
local sk99010_calc_status_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99010.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99010_calc_status_add_hp_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99010_pre_action_add_hp_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk99010_select_cnt_add_hp_0, 
		["sort_method"]="", 
		["status"]="add_hp", 
		["status_break"]=sk99010_status_break_add_hp_0, 
		["status_rate"]=sk99010_status_rate_add_hp_0, 
		["status_time"]=sk99010_status_time_add_hp_0, 
		["unselect_status"]=sk99010_unselect_status_add_hp_0, 
	}, 
	{
		["calc_status"]=sk99010_calc_status_clear_debuff_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99010_pre_action_clear_debuff_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99010_select_cnt_clear_debuff_1, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk99010_status_break_clear_debuff_1, 
		["status_rate"]=sk99010_status_rate_clear_debuff_1, 
		["status_time"]=sk99010_status_time_clear_debuff_1, 
		["unselect_status"]=sk99010_unselect_status_clear_debuff_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------