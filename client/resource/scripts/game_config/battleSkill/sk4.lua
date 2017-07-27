----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk4 = class("cls_sk4", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk4.get_skill_id = function(self)
	return "sk4";
end


-- 技能名 
cls_sk4.get_skill_name = function(self)
	return T("普通远程");
end

-- 获取技能的描述
cls_sk4.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk4.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk4.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk4._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 技能施法范围 
cls_sk4.get_select_scope = function(self)
	return "ENEMY";
end


-- 最小施法限制距离
cls_sk4.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk4.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk4.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前触发 
local skill_active_status = {"pugongbaoji", }

cls_sk4.get_skill_active_status = function(self)
	return skill_active_status
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[远程攻击]
local sk4_pre_action_far_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远程攻击]
local sk4_select_cnt_far_attack_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[远程攻击]
local sk4_unselect_status_far_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[远程攻击]
local sk4_status_time_far_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[远程攻击]
local sk4_status_break_far_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远程攻击]
local sk4_status_rate_far_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[远程攻击]
local sk4_calc_status_far_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iTHpLimit = target:getMaxHp();

	-- 公式原文:扣血=T耐久上限/10
	tbResult.sub_hp = iTHpLimit/10;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk4.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk4_calc_status_far_attack_0, 
		["effect_name"]="attack_yellow", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk4_pre_action_far_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk4_select_cnt_far_attack_0, 
		["sort_method"]="", 
		["status"]="far_attack", 
		["status_break"]=sk4_status_break_far_attack_0, 
		["status_rate"]=sk4_status_rate_far_attack_0, 
		["status_time"]=sk4_status_time_far_attack_0, 
		["unselect_status"]=sk4_unselect_status_far_attack_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk4.get_skill_type = function(self)
	return "auto"
end