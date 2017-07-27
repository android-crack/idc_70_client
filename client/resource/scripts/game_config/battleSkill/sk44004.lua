----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk44004 = class("cls_sk44004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk44004.get_skill_id = function(self)
	return "sk44004";
end


-- 技能名 
cls_sk44004.get_skill_name = function(self)
	return T("雷厉");
end

-- 精简版技能描述 
cls_sk44004.get_skill_short_desc = function(self)
	return T("全体我方速度提升，施法者受到普通攻击时，一定几率额外提升速度。");
end

-- 获取技能的描述
cls_sk44004.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("全体我方速度提升%0.1f，施法者受到普通攻击时，5%%几率额外提升18速度6秒。"), (5+1*lv))
end

-- 获取技能的富文本描述
cls_sk44004.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)全体我方速度提升$(c:COLOR_GREEN)%0.1f$(c:COLOR_CAMEL)，施法者受到普通攻击时，5%%几率额外提升18速度6秒。"), (5+1*lv))
end

-- 公共CD 
cls_sk44004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk44004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk44004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk44004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk44004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加速_2]
local sk44004_pre_action_fast_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加速_2]
local sk44004_select_cnt_fast_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加速_2]
local sk44004_unselect_status_fast_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加速_2]
local sk44004_status_time_fast_2_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加速_2]
local sk44004_status_break_fast_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加速_2]
local sk44004_status_rate_fast_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加速_2]
local sk44004_calc_status_fast_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:加速=5+1*技能等级
	tbResult.add_speed = 5+1*lv;

	return tbResult
end

-- 前置动作[扬帆起航]
local sk44004_pre_action_yangfanqihang_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扬帆起航]
local sk44004_select_cnt_yangfanqihang_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扬帆起航]
local sk44004_unselect_status_yangfanqihang_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扬帆起航]
local sk44004_status_time_yangfanqihang_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[扬帆起航]
local sk44004_status_break_yangfanqihang_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[扬帆起航]
local sk44004_status_rate_yangfanqihang_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[扬帆起航]
local sk44004_calc_status_yangfanqihang_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扬帆几率=50
	tbResult.yf_rate = 50;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk44004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk44004_calc_status_fast_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk44004_pre_action_fast_2_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk44004_select_cnt_fast_2_0, 
		["sort_method"]="", 
		["status"]="fast_2", 
		["status_break"]=sk44004_status_break_fast_2_0, 
		["status_rate"]=sk44004_status_rate_fast_2_0, 
		["status_time"]=sk44004_status_time_fast_2_0, 
		["unselect_status"]=sk44004_unselect_status_fast_2_0, 
	}, 
	{
		["calc_status"]=sk44004_calc_status_yangfanqihang_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk44004_pre_action_yangfanqihang_1, 
		["scope"]="SELF", 
		["select_cnt"]=sk44004_select_cnt_yangfanqihang_1, 
		["sort_method"]="", 
		["status"]="yangfanqihang", 
		["status_break"]=sk44004_status_break_yangfanqihang_1, 
		["status_rate"]=sk44004_status_rate_yangfanqihang_1, 
		["status_time"]=sk44004_status_time_yangfanqihang_1, 
		["unselect_status"]=sk44004_unselect_status_yangfanqihang_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
