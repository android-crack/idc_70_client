----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90011a = class("cls_sk90011a", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90011a.get_skill_id = function(self)
	return "sk90011a";
end


-- 技能名 
cls_sk90011a.get_skill_name = function(self)
	return T("步步为营释放倍击3");
end

-- 获取技能的描述
cls_sk90011a.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90011a.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 技能CD
cls_sk90011a._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 最小施法限制距离
cls_sk90011a.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk90011a.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血_2]
local sk90011a_pre_action_add_hp_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血_2]
local sk90011a_select_cnt_add_hp_2_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加血_2]
local sk90011a_unselect_status_add_hp_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加血_2]
local sk90011a_status_time_add_hp_2_0 = function(attacker, lv)
	return 
5
end

-- 状态心跳[加血_2]
local sk90011a_status_break_add_hp_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加血_2]
local sk90011a_status_rate_add_hp_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加血_2]
local sk90011a_calc_status_add_hp_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iTHpLimit = target:getMaxHp();
	-- 
	local iTRemainHP = target:getHp();

	-- 公式原文:加血=((3.5+技能等级*0.3)*A耐久上限*0.01)*(1+1*取整((T耐久上限-T剩余耐久)*2/T耐久上限))
	tbResult.add_hp = ((3.5+lv*0.3)*iAHpLimit*0.01)*(1+1*math.floor((iTHpLimit-iTRemainHP)*2/iTHpLimit));

	return tbResult
end

-- 前置动作[清除减益状态]
local sk90011a_pre_action_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk90011a_select_cnt_clear_debuff_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[清除减益状态]
local sk90011a_unselect_status_clear_debuff_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[清除减益状态]
local sk90011a_status_time_clear_debuff_1 = function(attacker, lv)
	return 
1
end

-- 状态心跳[清除减益状态]
local sk90011a_status_break_clear_debuff_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk90011a_status_rate_clear_debuff_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk42005_SkillLv/sk42005_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk42005")/attacker:getSkillLv("sk42005_MAX"));

	return result
end

-- 处理过程[清除减益状态]
local sk90011a_calc_status_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90011a.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90011a_calc_status_add_hp_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90011a_pre_action_add_hp_2_0, 
		["scope"]="FRIEND_EXPLORE", 
		["select_cnt"]=sk90011a_select_cnt_add_hp_2_0, 
		["sort_method"]="", 
		["status"]="add_hp_2", 
		["status_break"]=sk90011a_status_break_add_hp_2_0, 
		["status_rate"]=sk90011a_status_rate_add_hp_2_0, 
		["status_time"]=sk90011a_status_time_add_hp_2_0, 
		["unselect_status"]=sk90011a_unselect_status_add_hp_2_0, 
	}, 
	{
		["calc_status"]=sk90011a_calc_status_clear_debuff_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90011a_pre_action_clear_debuff_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90011a_select_cnt_clear_debuff_1, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk90011a_status_break_clear_debuff_1, 
		["status_rate"]=sk90011a_status_rate_clear_debuff_1, 
		["status_time"]=sk90011a_status_time_clear_debuff_1, 
		["unselect_status"]=sk90011a_unselect_status_clear_debuff_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90011a.get_skill_type = function(self)
    return "auto"
end

cls_sk90011a.get_skill_lv = function(self, attacker)
	return cls_sk42005:get_skill_lv( attacker )
end
