----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk42004 = class("cls_sk42004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk42004.get_skill_id = function(self)
	return "sk42004";
end


-- 技能名 
cls_sk42004.get_skill_name = function(self)
	return T("背水一战");
end

-- 精简版技能描述 
cls_sk42004.get_skill_short_desc = function(self)
	return T("全体我方每秒恢复耐久，耐久低于50%时，恢复效果提升1.5倍。");
end

-- 获取技能的描述
cls_sk42004.get_skill_desc = function(self, skill_data, lv)
	return T("全体我方每6秒恢复7%耐久，耐久低于50%时，恢复效果提升1.5倍。")
end

-- 获取技能的富文本描述
cls_sk42004.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)全体我方每6秒恢复施法者耐久上限7%耐久，耐久低于50%时，恢复效果提升1.5倍。")
end

-- 公共CD 
cls_sk42004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk42004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk42004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk42004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk42004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[步步为营]
local sk42004_pre_action_bubuweiying_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[步步为营]
local sk42004_select_cnt_bubuweiying_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[步步为营]
local sk42004_unselect_status_bubuweiying_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[步步为营]
local sk42004_status_time_bubuweiying_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[步步为营]
local sk42004_status_break_bubuweiying_0 = function(attacker, lv)
	return 
6
end

-- 命中率公式[步步为营]
local sk42004_status_rate_bubuweiying_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[步步为营]
local sk42004_calc_status_bubuweiying_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:步步为营触发技能="sk90011"
	tbResult.bbwy_skill_id = "sk90011";

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk42004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk42004_calc_status_bubuweiying_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk42004_pre_action_bubuweiying_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk42004_select_cnt_bubuweiying_0, 
		["sort_method"]="", 
		["status"]="bubuweiying", 
		["status_break"]=sk42004_status_break_bubuweiying_0, 
		["status_rate"]=sk42004_status_rate_bubuweiying_0, 
		["status_time"]=sk42004_status_time_bubuweiying_0, 
		["unselect_status"]=sk42004_unselect_status_bubuweiying_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
