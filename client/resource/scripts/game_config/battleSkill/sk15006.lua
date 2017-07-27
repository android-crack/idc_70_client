----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk15006 = class("cls_sk15006", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk15006.get_skill_id = function(self)
	return "sk15006";
end


-- 技能名 
cls_sk15006.get_skill_name = function(self)
	return T("船体加固（天匠）");
end

-- 精简版技能描述 
cls_sk15006.get_skill_short_desc = function(self)
	return T("每秒给全体所有我方恢复耐久，持续6秒，并清除不良状态。");
end

-- 获取技能的描述
cls_sk15006.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("每秒给全体我方单位恢复施法者耐久上限%0.1f%%的耐久，并持续清除不良状态，持续6秒。"), (2+0.2*lv))
end

-- 获取技能的富文本描述
cls_sk15006.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)每秒给全体恢复施法者耐久上限$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的耐久，并持续清除不良状态，持续6秒"), (2+0.2*lv))
end

-- 公共CD 
cls_sk15006.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk15006._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=2
	result = 2;

	return result
end

-- 技能触发概率
cls_sk15006.get_skill_rate = function(self, attacker)
	local result
	
	-- 公式原文:结果=100
	result = 100;

	return result
end

-- 技能施法范围 
cls_sk15006.get_select_scope = function(self)
	return "FRIEND";
end


-- SP消耗公式
cls_sk15006.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法音效 
cls_sk15006.get_effect_music = function(self)
	return "BT_REINFORCE_1";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[清除减益状态]
local sk15006_pre_action_clear_debuff_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk15006_select_cnt_clear_debuff_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[清除减益状态]
local sk15006_unselect_status_clear_debuff_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[清除减益状态]
local sk15006_status_time_clear_debuff_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=1+5*取整(sk15006_SkillLv/sk15006_MAX_SkillLv)
	result = 1+5*math.floor(attacker:getSkillLv("sk15006")/attacker:getSkillLv("sk15006_MAX"));

	return result
end

-- 状态心跳[清除减益状态]
local sk15006_status_break_clear_debuff_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk15006_status_rate_clear_debuff_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[清除减益状态]
local sk15006_calc_status_clear_debuff_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[加血]
local sk15006_pre_action_add_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血]
local sk15006_select_cnt_add_hp_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加血]
local sk15006_unselect_status_add_hp_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加血]
local sk15006_status_time_add_hp_1 = function(attacker, lv)
	return 
6
end

-- 状态心跳[加血]
local sk15006_status_break_add_hp_1 = function(attacker, lv)
	return 
1
end

-- 命中率公式[加血]
local sk15006_status_rate_add_hp_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加血]
local sk15006_calc_status_add_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=A耐久上限*(0.02+0.002*技能等级)
	tbResult.add_hp = iAHpLimit*(0.02+0.002*lv);

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk15006.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk15006_calc_status_clear_debuff_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk15006_pre_action_clear_debuff_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk15006_select_cnt_clear_debuff_0, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk15006_status_break_clear_debuff_0, 
		["status_rate"]=sk15006_status_rate_clear_debuff_0, 
		["status_time"]=sk15006_status_time_clear_debuff_0, 
		["unselect_status"]=sk15006_unselect_status_clear_debuff_0, 
	}, 
	{
		["calc_status"]=sk15006_calc_status_add_hp_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk15006_pre_action_add_hp_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk15006_select_cnt_add_hp_1, 
		["sort_method"]="", 
		["status"]="add_hp", 
		["status_break"]=sk15006_status_break_add_hp_1, 
		["status_rate"]=sk15006_status_rate_add_hp_1, 
		["status_time"]=sk15006_status_time_add_hp_1, 
		["unselect_status"]=sk15006_unselect_status_add_hp_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
