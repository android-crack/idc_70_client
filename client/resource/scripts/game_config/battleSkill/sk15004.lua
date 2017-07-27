----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk15004 = class("cls_sk15004", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk15004.get_skill_id = function(self)
	return "sk15004";
end


-- 技能名 
cls_sk15004.get_skill_name = function(self)
	return T("船体加固（抢修）");
end

-- 精简版技能描述 
cls_sk15004.get_skill_short_desc = function(self)
	return T("给当前舰队内气血百分比最低的2个单位回血。");
end

-- 获取技能的描述
cls_sk15004.get_skill_desc = function(self, skill_data, lv)
	return T("给当前舰队内气血百分比最低的2个单位回血。")
end

-- 获取技能的富文本描述
cls_sk15004.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)给当前舰队内气血百分比最低的2个单位回血。")
end

-- 公共CD 
cls_sk15004.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk15004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=15
	result = 15;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk15004.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk15004.get_select_scope = function(self)
	return "ALL_FRIEND";
end


-- SP消耗公式
cls_sk15004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法音效 
cls_sk15004.get_effect_music = function(self)
	return "BT_REINFORCE_1";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血]
local sk15004_pre_action_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血]
local sk15004_select_cnt_add_hp_0 = function(attacker, lv)
	return 
2
end

-- 目标选择忽视状态[加血]
local sk15004_unselect_status_add_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加血]
local sk15004_status_time_add_hp_0 = function(attacker, lv)
	return 
6
end

-- 状态心跳[加血]
local sk15004_status_break_add_hp_0 = function(attacker, lv)
	return 
1
end

-- 命中率公式[加血]
local sk15004_status_rate_add_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加血]
local sk15004_calc_status_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=A耐久上限*(0.03+0.005*技能等级)
	tbResult.add_hp = iAHpLimit*(0.03+0.005*lv);

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk15004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk15004_calc_status_add_hp_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk15004_pre_action_add_hp_0, 
		["scope"]="ALL_FRIEND", 
		["select_cnt"]=sk15004_select_cnt_add_hp_0, 
		["sort_method"]="HP_RATE_ASEC", 
		["status"]="add_hp", 
		["status_break"]=sk15004_status_break_add_hp_0, 
		["status_rate"]=sk15004_status_rate_add_hp_0, 
		["status_time"]=sk15004_status_time_add_hp_0, 
		["unselect_status"]=sk15004_unselect_status_add_hp_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
