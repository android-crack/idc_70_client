----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk45004 = class("cls_sk45004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk45004.get_skill_id = function(self)
	return "sk45004";
end


-- 技能名 
cls_sk45004.get_skill_name = function(self)
	return T("乘胜追击");
end

-- 精简版技能描述 
cls_sk45004.get_skill_short_desc = function(self)
	return T("战斗中提升施法者远程攻击，施法者免疫减攻效果。");
end

-- 获取技能的描述
cls_sk45004.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("战斗中提升施法者远程攻击%0.1f%%，普通攻击提升15%%"), (15+2*lv))
end

-- 获取技能的富文本描述
cls_sk45004.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)战斗中提升施法者远程攻击$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), (15+2*lv))
end

-- 公共CD 
cls_sk45004.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk45004._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk45004.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk45004.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk45004.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加远攻_2]
local sk45004_pre_action_add_att_far_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻_2]
local sk45004_select_cnt_add_att_far_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加远攻_2]
local sk45004_unselect_status_add_att_far_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加远攻_2]
local sk45004_status_time_add_att_far_2_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加远攻_2]
local sk45004_status_break_add_att_far_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻_2]
local sk45004_status_rate_add_att_far_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加远攻_2]
local sk45004_calc_status_add_att_far_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=A远程攻击*(0.15+0.02*技能等级)
	tbResult.add_att_far = iAAtt*(0.15+0.02*lv);

	return tbResult
end

-- 前置动作[加近攻_2]
local sk45004_pre_action_add_att_near_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻_2]
local sk45004_select_cnt_add_att_near_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加近攻_2]
local sk45004_unselect_status_add_att_near_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加近攻_2]
local sk45004_status_time_add_att_near_2_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加近攻_2]
local sk45004_status_break_add_att_near_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻_2]
local sk45004_status_rate_add_att_near_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加近攻_2]
local sk45004_calc_status_add_att_near_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=A近战攻击*(0.15+0.02*技能等级)
	tbResult.add_att_near = iANear*(0.15+0.02*lv);

	return tbResult
end

-- 前置动作[普通攻击提升]
local sk45004_pre_action_putonggongjitishen_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[普通攻击提升]
local sk45004_select_cnt_putonggongjitishen_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[普通攻击提升]
local sk45004_unselect_status_putonggongjitishen_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[普通攻击提升]
local sk45004_status_time_putonggongjitishen_2 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[普通攻击提升]
local sk45004_status_break_putonggongjitishen_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[普通攻击提升]
local sk45004_status_rate_putonggongjitishen_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[普通攻击提升]
local sk45004_calc_status_putonggongjitishen_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:普通攻击提升百分比=150
	tbResult.putonggongjitishen_rate = 150;

	return tbResult
end

-- 前置动作[自由射击]
local sk45004_pre_action_ziyousheji_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[自由射击]
local sk45004_select_cnt_ziyousheji_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[自由射击]
local sk45004_unselect_status_ziyousheji_3 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[自由射击]
local sk45004_status_time_ziyousheji_3 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[自由射击]
local sk45004_status_break_ziyousheji_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[自由射击]
local sk45004_status_rate_ziyousheji_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk45004_SkillLv/sk45004_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk45004")/attacker:getSkillLv("sk45004_MAX"));

	return result
end

-- 处理过程[自由射击]
local sk45004_calc_status_ziyousheji_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk45004.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk45004_calc_status_add_att_far_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45004_pre_action_add_att_far_2_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk45004_select_cnt_add_att_far_2_0, 
		["sort_method"]="", 
		["status"]="add_att_far_2", 
		["status_break"]=sk45004_status_break_add_att_far_2_0, 
		["status_rate"]=sk45004_status_rate_add_att_far_2_0, 
		["status_time"]=sk45004_status_time_add_att_far_2_0, 
		["unselect_status"]=sk45004_unselect_status_add_att_far_2_0, 
	}, 
	{
		["calc_status"]=sk45004_calc_status_add_att_near_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45004_pre_action_add_att_near_2_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk45004_select_cnt_add_att_near_2_1, 
		["sort_method"]="", 
		["status"]="add_att_near_2", 
		["status_break"]=sk45004_status_break_add_att_near_2_1, 
		["status_rate"]=sk45004_status_rate_add_att_near_2_1, 
		["status_time"]=sk45004_status_time_add_att_near_2_1, 
		["unselect_status"]=sk45004_unselect_status_add_att_near_2_1, 
	}, 
	{
		["calc_status"]=sk45004_calc_status_putonggongjitishen_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45004_pre_action_putonggongjitishen_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk45004_select_cnt_putonggongjitishen_2, 
		["sort_method"]="", 
		["status"]="putonggongjitishen", 
		["status_break"]=sk45004_status_break_putonggongjitishen_2, 
		["status_rate"]=sk45004_status_rate_putonggongjitishen_2, 
		["status_time"]=sk45004_status_time_putonggongjitishen_2, 
		["unselect_status"]=sk45004_unselect_status_putonggongjitishen_2, 
	}, 
	{
		["calc_status"]=sk45004_calc_status_ziyousheji_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45004_pre_action_ziyousheji_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk45004_select_cnt_ziyousheji_3, 
		["sort_method"]="", 
		["status"]="ziyousheji", 
		["status_break"]=sk45004_status_break_ziyousheji_3, 
		["status_rate"]=sk45004_status_rate_ziyousheji_3, 
		["status_time"]=sk45004_status_time_ziyousheji_3, 
		["unselect_status"]=sk45004_unselect_status_ziyousheji_3, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
