----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk45001 = class("cls_sk45001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk45001.get_skill_id = function(self)
	return "sk45001";
end


-- 技能名 
cls_sk45001.get_skill_name = function(self)
	return T("勇猛");
end

-- 精简版技能描述 
cls_sk45001.get_skill_short_desc = function(self)
	return T("战斗中提升施法者远程和近战攻击。");
end

-- 获取技能的描述
cls_sk45001.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("战斗中提升施法者远程和近战攻击%0.1f%%。"), (10+1*lv))
end

-- 获取技能的富文本描述
cls_sk45001.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)战斗中提升施法者远程和近战攻击$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), (10+1*lv))
end

-- 公共CD 
cls_sk45001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk45001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk45001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk45001.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk45001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加远攻_2]
local sk45001_pre_action_add_att_far_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻_2]
local sk45001_select_cnt_add_att_far_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加远攻_2]
local sk45001_unselect_status_add_att_far_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加远攻_2]
local sk45001_status_time_add_att_far_2_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加远攻_2]
local sk45001_status_break_add_att_far_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻_2]
local sk45001_status_rate_add_att_far_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加远攻_2]
local sk45001_calc_status_add_att_far_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=A远程攻击*(0.1+0.01*技能等级)
	tbResult.add_att_far = iAAtt*(0.1+0.01*lv);

	return tbResult
end

-- 前置动作[加近攻_2]
local sk45001_pre_action_add_att_near_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻_2]
local sk45001_select_cnt_add_att_near_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加近攻_2]
local sk45001_unselect_status_add_att_near_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加近攻_2]
local sk45001_status_time_add_att_near_2_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加近攻_2]
local sk45001_status_break_add_att_near_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻_2]
local sk45001_status_rate_add_att_near_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加近攻_2]
local sk45001_calc_status_add_att_near_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=A近战攻击*(0.1+0.01*技能等级)
	tbResult.add_att_near = iANear*(0.1+0.01*lv);

	return tbResult
end

-- 前置动作[普通攻击提升]
local sk45001_pre_action_putonggongjitishen_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[普通攻击提升]
local sk45001_select_cnt_putonggongjitishen_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[普通攻击提升]
local sk45001_unselect_status_putonggongjitishen_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[普通攻击提升]
local sk45001_status_time_putonggongjitishen_2 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[普通攻击提升]
local sk45001_status_break_putonggongjitishen_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[普通攻击提升]
local sk45001_status_rate_putonggongjitishen_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000*取整(sk45001_SkillLv/sk45001_MAX_SkillLv)
	result = 2000*math.floor(attacker:getSkillLv("sk45001")/attacker:getSkillLv("sk45001_MAX"));

	return result
end

-- 处理过程[普通攻击提升]
local sk45001_calc_status_putonggongjitishen_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:普通攻击提升百分比=150
	tbResult.putonggongjitishen_rate = 150;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk45001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk45001_calc_status_add_att_far_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45001_pre_action_add_att_far_2_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk45001_select_cnt_add_att_far_2_0, 
		["sort_method"]="", 
		["status"]="add_att_far_2", 
		["status_break"]=sk45001_status_break_add_att_far_2_0, 
		["status_rate"]=sk45001_status_rate_add_att_far_2_0, 
		["status_time"]=sk45001_status_time_add_att_far_2_0, 
		["unselect_status"]=sk45001_unselect_status_add_att_far_2_0, 
	}, 
	{
		["calc_status"]=sk45001_calc_status_add_att_near_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45001_pre_action_add_att_near_2_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk45001_select_cnt_add_att_near_2_1, 
		["sort_method"]="", 
		["status"]="add_att_near_2", 
		["status_break"]=sk45001_status_break_add_att_near_2_1, 
		["status_rate"]=sk45001_status_rate_add_att_near_2_1, 
		["status_time"]=sk45001_status_time_add_att_near_2_1, 
		["unselect_status"]=sk45001_unselect_status_add_att_near_2_1, 
	}, 
	{
		["calc_status"]=sk45001_calc_status_putonggongjitishen_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45001_pre_action_putonggongjitishen_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk45001_select_cnt_putonggongjitishen_2, 
		["sort_method"]="", 
		["status"]="putonggongjitishen", 
		["status_break"]=sk45001_status_break_putonggongjitishen_2, 
		["status_rate"]=sk45001_status_rate_putonggongjitishen_2, 
		["status_time"]=sk45001_status_time_putonggongjitishen_2, 
		["unselect_status"]=sk45001_unselect_status_putonggongjitishen_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
