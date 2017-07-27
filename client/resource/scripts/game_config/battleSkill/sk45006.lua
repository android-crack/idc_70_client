----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk45006 = class("cls_sk45006", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk45006.get_skill_id = function(self)
	return "sk45006";
end


-- 技能名 
cls_sk45006.get_skill_name = function(self)
	return T("一往无前");
end

-- 精简版技能描述 
cls_sk45006.get_skill_short_desc = function(self)
	return T("所有舰船普通攻击提升");
end

-- 获取技能的描述
cls_sk45006.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("所有舰船普通攻击提升%0.1f%%。"), (80+4*lv))
end

-- 获取技能的富文本描述
cls_sk45006.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)所有舰船普通攻击提升$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)"), (80+4*lv))
end

-- 公共CD 
cls_sk45006.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk45006._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk45006.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk45006.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk45006.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[普通攻击提升_一往无前]
local sk45006_pre_action_putonggongjitishen_ywwq_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[普通攻击提升_一往无前]
local sk45006_select_cnt_putonggongjitishen_ywwq_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[普通攻击提升_一往无前]
local sk45006_unselect_status_putonggongjitishen_ywwq_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[普通攻击提升_一往无前]
local sk45006_status_time_putonggongjitishen_ywwq_0 = function(attacker, lv)
	return 
2
end

-- 状态心跳[普通攻击提升_一往无前]
local sk45006_status_break_putonggongjitishen_ywwq_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[普通攻击提升_一往无前]
local sk45006_status_rate_putonggongjitishen_ywwq_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[普通攻击提升_一往无前]
local sk45006_calc_status_putonggongjitishen_ywwq_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:普通攻击提升百分比=800+40*技能等级
	tbResult.putonggongjitishen_rate = 800+40*lv;

	return tbResult
end

-- 前置动作[远程攻击多目标_2]
local sk45006_pre_action_far_attack_select_cnt_add_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远程攻击多目标_2]
local sk45006_select_cnt_far_attack_select_cnt_add_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[远程攻击多目标_2]
local sk45006_unselect_status_far_attack_select_cnt_add_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[远程攻击多目标_2]
local sk45006_status_time_far_attack_select_cnt_add_2_1 = function(attacker, lv)
	return 
2
end

-- 状态心跳[远程攻击多目标_2]
local sk45006_status_break_far_attack_select_cnt_add_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远程攻击多目标_2]
local sk45006_status_rate_far_attack_select_cnt_add_2_1 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHit = attacker:getHitRate();

	-- 公式原文:结果=1000*取整(sk45006_SkillLv/sk45006_MAX_SkillLv)-A命中
	result = 1000*math.floor(attacker:getSkillLv("sk45006")/attacker:getSkillLv("sk45006_MAX"))-iAHit;

	return result
end

-- 处理过程[远程攻击多目标_2]
local sk45006_calc_status_far_attack_select_cnt_add_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:远程攻击增加目标数量=1
	tbResult.far_att_cnt = 1;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk45006.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk45006_calc_status_putonggongjitishen_ywwq_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45006_pre_action_putonggongjitishen_ywwq_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk45006_select_cnt_putonggongjitishen_ywwq_0, 
		["sort_method"]="", 
		["status"]="putonggongjitishen_ywwq", 
		["status_break"]=sk45006_status_break_putonggongjitishen_ywwq_0, 
		["status_rate"]=sk45006_status_rate_putonggongjitishen_ywwq_0, 
		["status_time"]=sk45006_status_time_putonggongjitishen_ywwq_0, 
		["unselect_status"]=sk45006_unselect_status_putonggongjitishen_ywwq_0, 
	}, 
	{
		["calc_status"]=sk45006_calc_status_far_attack_select_cnt_add_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45006_pre_action_far_attack_select_cnt_add_2_1, 
		["scope"]="SELF", 
		["select_cnt"]=sk45006_select_cnt_far_attack_select_cnt_add_2_1, 
		["sort_method"]="", 
		["status"]="far_attack_select_cnt_add_2", 
		["status_break"]=sk45006_status_break_far_attack_select_cnt_add_2_1, 
		["status_rate"]=sk45006_status_rate_far_attack_select_cnt_add_2_1, 
		["status_time"]=sk45006_status_time_far_attack_select_cnt_add_2_1, 
		["unselect_status"]=sk45006_unselect_status_far_attack_select_cnt_add_2_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
