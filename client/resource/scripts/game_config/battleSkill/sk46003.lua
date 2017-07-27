----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk46003 = class("cls_sk46003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk46003.get_skill_id = function(self)
	return "sk46003";
end


-- 技能名 
cls_sk46003.get_skill_name = function(self)
	return T("自由射击");
end

-- 精简版技能描述 
cls_sk46003.get_skill_short_desc = function(self)
	return T("战斗中提升船只射程和命中。");
end

-- 获取技能的描述
cls_sk46003.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("战斗中提升船只射程%0.1f，命中提升%0.1f%%。"), (30+4*lv), (25+5*lv))
end

-- 获取技能的富文本描述
cls_sk46003.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)战斗中提升船只射程$(c:COLOR_GREEN)%0.1f$(c:COLOR_CAMEL)，命中提升$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), (30+4*lv), (25+5*lv))
end

-- 公共CD 
cls_sk46003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk46003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk46003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk46003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk46003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[远程攻击距离提升]
local sk46003_pre_action_far_attack_range_up_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远程攻击距离提升]
local sk46003_select_cnt_far_attack_range_up_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[远程攻击距离提升]
local sk46003_unselect_status_far_attack_range_up_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[远程攻击距离提升]
local sk46003_status_time_far_attack_range_up_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[远程攻击距离提升]
local sk46003_status_break_far_attack_range_up_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远程攻击距离提升]
local sk46003_status_rate_far_attack_range_up_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[远程攻击距离提升]
local sk46003_calc_status_far_attack_range_up_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:远程攻击距离提升=20+4*技能等级
	tbResult.add_far_att_range = 20+4*lv;

	return tbResult
end

-- 前置动作[命中_2]
local sk46003_pre_action_mingzhong_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[命中_2]
local sk46003_select_cnt_mingzhong_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[命中_2]
local sk46003_unselect_status_mingzhong_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[命中_2]
local sk46003_status_time_mingzhong_2_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[命中_2]
local sk46003_status_break_mingzhong_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[命中_2]
local sk46003_status_rate_mingzhong_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[命中_2]
local sk46003_calc_status_mingzhong_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:命中概率=250+50*技能等级
	tbResult.custom_mingzhong_rate=250+50*lv;

	return tbResult
end

-- 前置动作[自由射击_2]
local sk46003_pre_action_ziyousheji_2_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[自由射击_2]
local sk46003_select_cnt_ziyousheji_2_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[自由射击_2]
local sk46003_unselect_status_ziyousheji_2_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[自由射击_2]
local sk46003_status_time_ziyousheji_2_2 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[自由射击_2]
local sk46003_status_break_ziyousheji_2_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[自由射击_2]
local sk46003_status_rate_ziyousheji_2_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk46003_SkillLv/sk46003_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk46003")/attacker:getSkillLv("sk46003_MAX"));

	return result
end

-- 处理过程[自由射击_2]
local sk46003_calc_status_ziyousheji_2_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:通用触发状态="slow"
	tbResult.ty_status_id = "slow";
	-- 公式原文:通用触发概率=200
	tbResult.ty_rate = 200;
	-- 公式原文:通用触发状态时间=2
	tbResult.ty_status_time = 2;
	-- 公式原文:减速数值=50
	tbResult.jiansu_value = 50;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk46003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk46003_calc_status_far_attack_range_up_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk46003_pre_action_far_attack_range_up_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk46003_select_cnt_far_attack_range_up_0, 
		["sort_method"]="", 
		["status"]="far_attack_range_up", 
		["status_break"]=sk46003_status_break_far_attack_range_up_0, 
		["status_rate"]=sk46003_status_rate_far_attack_range_up_0, 
		["status_time"]=sk46003_status_time_far_attack_range_up_0, 
		["unselect_status"]=sk46003_unselect_status_far_attack_range_up_0, 
	}, 
	{
		["calc_status"]=sk46003_calc_status_mingzhong_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk46003_pre_action_mingzhong_2_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk46003_select_cnt_mingzhong_2_1, 
		["sort_method"]="", 
		["status"]="mingzhong_2", 
		["status_break"]=sk46003_status_break_mingzhong_2_1, 
		["status_rate"]=sk46003_status_rate_mingzhong_2_1, 
		["status_time"]=sk46003_status_time_mingzhong_2_1, 
		["unselect_status"]=sk46003_unselect_status_mingzhong_2_1, 
	}, 
	{
		["calc_status"]=sk46003_calc_status_ziyousheji_2_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk46003_pre_action_ziyousheji_2_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk46003_select_cnt_ziyousheji_2_2, 
		["sort_method"]="", 
		["status"]="ziyousheji_2", 
		["status_break"]=sk46003_status_break_ziyousheji_2_2, 
		["status_rate"]=sk46003_status_rate_ziyousheji_2_2, 
		["status_time"]=sk46003_status_time_ziyousheji_2_2, 
		["unselect_status"]=sk46003_unselect_status_ziyousheji_2_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
