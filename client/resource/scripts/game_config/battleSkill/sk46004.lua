----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk46004 = class("cls_sk46004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk46004.get_skill_id = function(self)
	return "sk46004";
end


-- 技能名 
cls_sk46004.get_skill_name = function(self)
	return T("越战越勇");
end

-- 精简版技能描述 
cls_sk46004.get_skill_short_desc = function(self)
	return T("全体我方近战攻击提升，施法者免疫怒气降低。");
end

-- 获取技能的描述
cls_sk46004.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("全体我方近战攻击提升%0.1f%%，施法者免疫怒气降低效果。"), (5+2*lv))
end

-- 获取技能的富文本描述
cls_sk46004.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)全体我方近战攻击提升$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)，施法者免疫怒气降低效果。"), (5+2*lv))
end

-- 公共CD 
cls_sk46004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk46004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk46004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk46004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk46004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加近攻_2]
local sk46004_pre_action_add_att_near_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻_2]
local sk46004_select_cnt_add_att_near_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加近攻_2]
local sk46004_unselect_status_add_att_near_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加近攻_2]
local sk46004_status_time_add_att_near_2_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加近攻_2]
local sk46004_status_break_add_att_near_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻_2]
local sk46004_status_rate_add_att_near_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加近攻_2]
local sk46004_calc_status_add_att_near_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=A近战攻击*(0.05+0.02*技能等级)
	tbResult.add_att_near = iANear*(0.05+0.02*lv);

	return tbResult
end

-- 前置动作[命中_2]
local sk46004_pre_action_mingzhong_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[命中_2]
local sk46004_select_cnt_mingzhong_2_1 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[命中_2]
local sk46004_unselect_status_mingzhong_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[命中_2]
local sk46004_status_time_mingzhong_2_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[命中_2]
local sk46004_status_break_mingzhong_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[命中_2]
local sk46004_status_rate_mingzhong_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[命中_2]
local sk46004_calc_status_mingzhong_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk46004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk46004_calc_status_add_att_near_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk46004_pre_action_add_att_near_2_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk46004_select_cnt_add_att_near_2_0, 
		["sort_method"]="", 
		["status"]="add_att_near_2", 
		["status_break"]=sk46004_status_break_add_att_near_2_0, 
		["status_rate"]=sk46004_status_rate_add_att_near_2_0, 
		["status_time"]=sk46004_status_time_add_att_near_2_0, 
		["unselect_status"]=sk46004_unselect_status_add_att_near_2_0, 
	}, 
	{
		["calc_status"]=sk46004_calc_status_mingzhong_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk46004_pre_action_mingzhong_2_1, 
		["scope"]="SELF", 
		["select_cnt"]=sk46004_select_cnt_mingzhong_2_1, 
		["sort_method"]="DISTANCE_ASEC", 
		["status"]="mingzhong_2", 
		["status_break"]=sk46004_status_break_mingzhong_2_1, 
		["status_rate"]=sk46004_status_rate_mingzhong_2_1, 
		["status_time"]=sk46004_status_time_mingzhong_2_1, 
		["unselect_status"]=sk46004_unselect_status_mingzhong_2_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
