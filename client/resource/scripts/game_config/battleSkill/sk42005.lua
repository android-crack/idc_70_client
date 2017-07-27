----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk42005 = class("cls_sk42005", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk42005.get_skill_id = function(self)
	return "sk42005";
end


-- 技能名 
cls_sk42005.get_skill_name = function(self)
	return T("戒备");
end

-- 精简版技能描述 
cls_sk42005.get_skill_short_desc = function(self)
	return T("每5秒恢复射程内冒险家耐久，耐久低于50%时，恢复效果提升2倍。");
end

-- 获取技能的描述
cls_sk42005.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("每5秒恢复射程内冒险家耐久上限%0.1f%%耐久。耐久低于50%%时，恢复效果提升2倍。"), (3.5+lv*0.3))
end

-- 获取技能的富文本描述
cls_sk42005.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)每5秒恢复射程内冒险家$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)施法者耐久上限。耐久低于50%%时，恢复效果提升2倍。"), (3.5+lv*0.3))
end

-- 公共CD 
cls_sk42005.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk42005._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk42005.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk42005.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk42005.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[步步为营]
local sk42005_pre_action_bubuweiying_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[步步为营]
local sk42005_select_cnt_bubuweiying_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[步步为营]
local sk42005_unselect_status_bubuweiying_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[步步为营]
local sk42005_status_time_bubuweiying_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[步步为营]
local sk42005_status_break_bubuweiying_0 = function(attacker, lv)
	return 
5
end

-- 命中率公式[步步为营]
local sk42005_status_rate_bubuweiying_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[步步为营]
local sk42005_calc_status_bubuweiying_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:步步为营触发技能="sk90011a"
	tbResult.bbwy_skill_id = "sk90011a";

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk42005.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk42005_calc_status_bubuweiying_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk42005_pre_action_bubuweiying_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk42005_select_cnt_bubuweiying_0, 
		["sort_method"]="", 
		["status"]="bubuweiying", 
		["status_break"]=sk42005_status_break_bubuweiying_0, 
		["status_rate"]=sk42005_status_rate_bubuweiying_0, 
		["status_time"]=sk42005_status_time_bubuweiying_0, 
		["unselect_status"]=sk42005_unselect_status_bubuweiying_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
