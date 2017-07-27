----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk46001 = class("cls_sk46001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk46001.get_skill_id = function(self)
	return "sk46001";
end


-- 技能名 
cls_sk46001.get_skill_name = function(self)
	return T("势如破竹");
end

-- 精简版技能描述 
cls_sk46001.get_skill_short_desc = function(self)
	return T("战斗中提升船只射程。");
end

-- 获取技能的描述
cls_sk46001.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("战斗中提升船只射程%0.1f。"), (20+2*lv))
end

-- 获取技能的富文本描述
cls_sk46001.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)战斗中提升船只射程$(c:COLOR_GREEN)%0.1f$(c:COLOR_CAMEL)。"), (20+2*lv))
end

-- 公共CD 
cls_sk46001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk46001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk46001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk46001.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk46001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[远程攻击距离提升]
local sk46001_pre_action_far_attack_range_up_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远程攻击距离提升]
local sk46001_select_cnt_far_attack_range_up_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[远程攻击距离提升]
local sk46001_unselect_status_far_attack_range_up_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[远程攻击距离提升]
local sk46001_status_time_far_attack_range_up_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[远程攻击距离提升]
local sk46001_status_break_far_attack_range_up_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远程攻击距离提升]
local sk46001_status_rate_far_attack_range_up_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[远程攻击距离提升]
local sk46001_calc_status_far_attack_range_up_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:远程攻击距离提升=20+2*技能等级
	tbResult.add_far_att_range = 20+2*lv;

	return tbResult
end

-- 前置动作[命中_2]
local sk46001_pre_action_mingzhong_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[命中_2]
local sk46001_select_cnt_mingzhong_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[命中_2]
local sk46001_unselect_status_mingzhong_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[命中_2]
local sk46001_status_time_mingzhong_2_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[命中_2]
local sk46001_status_break_mingzhong_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[命中_2]
local sk46001_status_rate_mingzhong_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000*取整(sk46001_SkillLv/sk46001_MAX_SkillLv)
	result = 2000*math.floor(attacker:getSkillLv("sk46001")/attacker:getSkillLv("sk46001_MAX"));

	return result
end

-- 处理过程[命中_2]
local sk46001_calc_status_mingzhong_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:命中概率=500
	tbResult.custom_mingzhong_rate=500;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk46001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk46001_calc_status_far_attack_range_up_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk46001_pre_action_far_attack_range_up_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk46001_select_cnt_far_attack_range_up_0, 
		["sort_method"]="", 
		["status"]="far_attack_range_up", 
		["status_break"]=sk46001_status_break_far_attack_range_up_0, 
		["status_rate"]=sk46001_status_rate_far_attack_range_up_0, 
		["status_time"]=sk46001_status_time_far_attack_range_up_0, 
		["unselect_status"]=sk46001_unselect_status_far_attack_range_up_0, 
	}, 
	{
		["calc_status"]=sk46001_calc_status_mingzhong_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk46001_pre_action_mingzhong_2_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk46001_select_cnt_mingzhong_2_1, 
		["sort_method"]="", 
		["status"]="mingzhong_2", 
		["status_break"]=sk46001_status_break_mingzhong_2_1, 
		["status_rate"]=sk46001_status_rate_mingzhong_2_1, 
		["status_time"]=sk46001_status_time_mingzhong_2_1, 
		["unselect_status"]=sk46001_unselect_status_mingzhong_2_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
