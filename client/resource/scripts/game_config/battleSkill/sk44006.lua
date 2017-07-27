----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk44006 = class("cls_sk44006", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk44006.get_skill_id = function(self)
	return "sk44006";
end


-- 技能名 
cls_sk44006.get_skill_name = function(self)
	return T("掌舵");
end

-- 精简版技能描述 
cls_sk44006.get_skill_short_desc = function(self)
	return T("战斗中提升施法者速度，耐久较低时增加攻击和闪避");
end

-- 获取技能的描述
cls_sk44006.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("战斗中提升施法者速度50，耐久低于50%%时增加%0.1f攻击和%0.1f%%闪避"), (35+3*lv), (35+3*lv))
end

-- 获取技能的富文本描述
cls_sk44006.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)战斗中提升施法者速度50，耐久低于50%%时增加$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)攻击和$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)闪避"), (35+3*lv), (35+3*lv))
end

-- 公共CD 
cls_sk44006.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk44006._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk44006.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk44006.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk44006.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加速_2]
local sk44006_pre_action_fast_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加速_2]
local sk44006_select_cnt_fast_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[加速_2]
local sk44006_unselect_status_fast_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加速_2]
local sk44006_status_time_fast_2_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加速_2]
local sk44006_status_break_fast_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加速_2]
local sk44006_status_rate_fast_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加速_2]
local sk44006_calc_status_fast_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:加速=50
	tbResult.add_speed = 50;

	return tbResult
end

-- 前置动作[清除减益状态]
local sk44006_pre_action_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk44006_select_cnt_clear_debuff_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[清除减益状态]
local sk44006_unselect_status_clear_debuff_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[清除减益状态]
local sk44006_status_time_clear_debuff_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[清除减益状态]
local sk44006_status_break_clear_debuff_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk44006_status_rate_clear_debuff_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk44006_SkillLv/sk44006_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk44006")/attacker:getSkillLv("sk44006_MAX"));

	return result
end

-- 处理过程[清除减益状态]
local sk44006_calc_status_clear_debuff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[闪避_2]
local sk44006_pre_action_dodge_2_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[闪避_2]
local sk44006_select_cnt_dodge_2_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[闪避_2]
local sk44006_unselect_status_dodge_2_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[闪避_2]
local sk44006_status_time_dodge_2_2 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[闪避_2]
local sk44006_status_break_dodge_2_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[闪避_2]
local sk44006_status_rate_dodge_2_2 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iARemainHP = attacker:getHp();

	-- 公式原文:结果=2000*取整((A耐久上限-A剩余耐久)*2/A耐久上限)
	result = 2000*math.floor((iAHpLimit-iARemainHP)*2/iAHpLimit);

	return result
end

-- 处理过程[闪避_2]
local sk44006_calc_status_dodge_2_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:提升闪避=(350+30*技能等级)
	tbResult.dodge= (350+30*lv);

	return tbResult
end

-- 前置动作[加远攻_2]
local sk44006_pre_action_add_att_far_2_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻_2]
local sk44006_select_cnt_add_att_far_2_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加远攻_2]
local sk44006_unselect_status_add_att_far_2_3 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加远攻_2]
local sk44006_status_time_add_att_far_2_3 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加远攻_2]
local sk44006_status_break_add_att_far_2_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻_2]
local sk44006_status_rate_add_att_far_2_3 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iARemainHP = attacker:getHp();

	-- 公式原文:结果=2000*取整((A耐久上限-A剩余耐久)*2/A耐久上限)
	result = 2000*math.floor((iAHpLimit-iARemainHP)*2/iAHpLimit);

	return result
end

-- 处理过程[加远攻_2]
local sk44006_calc_status_add_att_far_2_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=(0.35+0.03*技能等级)*A远程攻击
	tbResult.add_att_far = (0.35+0.03*lv)*iAAtt;

	return tbResult
end

-- 前置动作[加近攻_2]
local sk44006_pre_action_add_att_near_2_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻_2]
local sk44006_select_cnt_add_att_near_2_4 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加近攻_2]
local sk44006_unselect_status_add_att_near_2_4 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加近攻_2]
local sk44006_status_time_add_att_near_2_4 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加近攻_2]
local sk44006_status_break_add_att_near_2_4 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻_2]
local sk44006_status_rate_add_att_near_2_4 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iARemainHP = attacker:getHp();

	-- 公式原文:结果=2000*取整((A耐久上限-A剩余耐久)*2/A耐久上限)
	result = 2000*math.floor((iAHpLimit-iARemainHP)*2/iAHpLimit);

	return result
end

-- 处理过程[加近攻_2]
local sk44006_calc_status_add_att_near_2_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=(0.35+0.03*技能等级)*A近战攻击
	tbResult.add_att_near = (0.35+0.03*lv)*iANear;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk44006.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk44006_calc_status_fast_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk44006_pre_action_fast_2_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk44006_select_cnt_fast_2_0, 
		["sort_method"]="", 
		["status"]="fast_2", 
		["status_break"]=sk44006_status_break_fast_2_0, 
		["status_rate"]=sk44006_status_rate_fast_2_0, 
		["status_time"]=sk44006_status_time_fast_2_0, 
		["unselect_status"]=sk44006_unselect_status_fast_2_0, 
	}, 
	{
		["calc_status"]=sk44006_calc_status_clear_debuff_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk44006_pre_action_clear_debuff_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk44006_select_cnt_clear_debuff_1, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk44006_status_break_clear_debuff_1, 
		["status_rate"]=sk44006_status_rate_clear_debuff_1, 
		["status_time"]=sk44006_status_time_clear_debuff_1, 
		["unselect_status"]=sk44006_unselect_status_clear_debuff_1, 
	}, 
	{
		["calc_status"]=sk44006_calc_status_dodge_2_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk44006_pre_action_dodge_2_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk44006_select_cnt_dodge_2_2, 
		["sort_method"]="", 
		["status"]="dodge_2", 
		["status_break"]=sk44006_status_break_dodge_2_2, 
		["status_rate"]=sk44006_status_rate_dodge_2_2, 
		["status_time"]=sk44006_status_time_dodge_2_2, 
		["unselect_status"]=sk44006_unselect_status_dodge_2_2, 
	}, 
	{
		["calc_status"]=sk44006_calc_status_add_att_far_2_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk44006_pre_action_add_att_far_2_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk44006_select_cnt_add_att_far_2_3, 
		["sort_method"]="", 
		["status"]="add_att_far_2", 
		["status_break"]=sk44006_status_break_add_att_far_2_3, 
		["status_rate"]=sk44006_status_rate_add_att_far_2_3, 
		["status_time"]=sk44006_status_time_add_att_far_2_3, 
		["unselect_status"]=sk44006_unselect_status_add_att_far_2_3, 
	}, 
	{
		["calc_status"]=sk44006_calc_status_add_att_near_2_4, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk44006_pre_action_add_att_near_2_4, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk44006_select_cnt_add_att_near_2_4, 
		["sort_method"]="", 
		["status"]="add_att_near_2", 
		["status_break"]=sk44006_status_break_add_att_near_2_4, 
		["status_rate"]=sk44006_status_rate_add_att_near_2_4, 
		["status_time"]=sk44006_status_time_add_att_near_2_4, 
		["unselect_status"]=sk44006_unselect_status_add_att_near_2_4, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
