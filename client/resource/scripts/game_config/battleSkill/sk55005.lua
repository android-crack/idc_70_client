----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk55005 = class("cls_sk55005", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk55005.get_skill_id = function(self)
	return "sk55005";
end


-- 技能名 
cls_sk55005.get_skill_name = function(self)
	return T("装甲船S级");
end

-- 获取技能的描述
cls_sk55005.get_skill_desc = function(self, skill_data, lv)
	return T("每次受到攻击恢复施法者最大气血的2%")
end

-- 获取技能的富文本描述
cls_sk55005.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)每次受到攻击恢复施法者最大气血的2%")
end

-- 公共CD 
cls_sk55005.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk55005._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=99999
	result = 99999;

	return result
end

-- SP消耗公式
cls_sk55005.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk55005.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk55005.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk55005.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1500
	result = 1500;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[受击回血]
local sk55005_pre_action_beattack_heal_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[受击回血]
local sk55005_select_cnt_beattack_heal_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[受击回血]
local sk55005_unselect_status_beattack_heal_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[受击回血]
local sk55005_status_time_beattack_heal_0 = function(attacker, lv)
	return 
99999
end

-- 状态心跳[受击回血]
local sk55005_status_break_beattack_heal_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[受击回血]
local sk55005_status_rate_beattack_heal_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[受击回血]
local sk55005_calc_status_beattack_heal_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:强化治疗效果=A耐久上限*0.02
	tbResult.add_heal = iAHpLimit*0.02;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk55005.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk55005_calc_status_beattack_heal_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk55005_pre_action_beattack_heal_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk55005_select_cnt_beattack_heal_0, 
		["sort_method"]="", 
		["status"]="beattack_heal", 
		["status_break"]=sk55005_status_break_beattack_heal_0, 
		["status_rate"]=sk55005_status_rate_beattack_heal_0, 
		["status_time"]=sk55005_status_time_beattack_heal_0, 
		["unselect_status"]=sk55005_unselect_status_beattack_heal_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------