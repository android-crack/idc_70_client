----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90022 = class("cls_sk90022", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90022.get_skill_id = function(self)
	return "sk90022";
end


-- 技能名 
cls_sk90022.get_skill_name = function(self)
	return T("主角援助技能1:治疗");
end

-- 获取技能的描述
cls_sk90022.get_skill_desc = function(self, skill_data, lv)
	return T("满级后该船只拥有单体治疗技能")
end

-- 获取技能的富文本描述
cls_sk90022.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)$(c:COLOR_GRASS)满级后该船只拥有单体治疗技能")
end

-- 公共CD 
cls_sk90022.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk90022._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=999
	result = 999;

	return result
end

-- 技能施法范围 
cls_sk90022.get_select_scope = function(self)
	return "FRIEND";
end


-- SP消耗公式
cls_sk90022.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血]
local sk90022_pre_action_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血]
local sk90022_select_cnt_add_hp_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加血]
local sk90022_unselect_status_add_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加血]
local sk90022_status_time_add_hp_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[加血]
local sk90022_status_break_add_hp_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加血]
local sk90022_status_rate_add_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加血]
local sk90022_calc_status_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=A耐久上限*0.2
	tbResult.add_hp = iAHpLimit*0.2;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90022.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90022_calc_status_add_hp_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90022_pre_action_add_hp_0, 
		["scope"]="FRIEND_OTHER", 
		["select_cnt"]=sk90022_select_cnt_add_hp_0, 
		["sort_method"]="", 
		["status"]="add_hp", 
		["status_break"]=sk90022_status_break_add_hp_0, 
		["status_rate"]=sk90022_status_rate_add_hp_0, 
		["status_time"]=sk90022_status_time_add_hp_0, 
		["unselect_status"]=sk90022_unselect_status_add_hp_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------