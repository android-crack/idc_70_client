----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk45005 = class("cls_sk45005", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk45005.get_skill_id = function(self)
	return "sk45005";
end


-- 技能名 
cls_sk45005.get_skill_name = function(self)
	return T("愤怒");
end

-- 精简版技能描述 
cls_sk45005.get_skill_short_desc = function(self)
	return T("施法者耐久大于50%时，射程内友军远程、近战攻击提升。");
end

-- 获取技能的描述
cls_sk45005.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("施法者耐久大于50%%时，射程内友军远程、近战攻击提升%0.1f%%。"), (20+2*lv))
end

-- 获取技能的富文本描述
cls_sk45005.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)施法者耐久大于50%%时，射程内友军攻击提升$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), (20+2*lv))
end

-- 公共CD 
cls_sk45005.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk45005._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk45005.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk45005.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk45005.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加远攻_2]
local sk45005_pre_action_add_att_far_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻_2]
local sk45005_select_cnt_add_att_far_2_0 = function(attacker, lv)
	local result
		-- 
	local iARemainHP = attacker:getHp();
	-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:结果=1+999*取整((A剩余耐久*2)/A耐久上限)
	result = 1+999*math.floor((iARemainHP*2)/iAHpLimit);

	return result
end

-- 目标选择忽视状态[加远攻_2]
local sk45005_unselect_status_add_att_far_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加远攻_2]
local sk45005_status_time_add_att_far_2_0 = function(attacker, lv)
	return 
2
end

-- 状态心跳[加远攻_2]
local sk45005_status_break_add_att_far_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻_2]
local sk45005_status_rate_add_att_far_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加远攻_2]
local sk45005_calc_status_add_att_far_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=A远程攻击*0.2+A远程攻击*0.2*(取整(sk45005_SkillLv/sk45005_MAX_SkillLv))
	tbResult.add_att_far = iAAtt*0.2+iAAtt*0.2*(math.floor(attacker:getSkillLv("sk45005")/attacker:getSkillLv("sk45005_MAX")));

	return tbResult
end

-- 前置动作[加近攻_2]
local sk45005_pre_action_add_att_near_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻_2]
local sk45005_select_cnt_add_att_near_2_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加近攻_2]
local sk45005_unselect_status_add_att_near_2_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加近攻_2]
local sk45005_status_time_add_att_near_2_1 = function(attacker, lv)
	return 
2
end

-- 状态心跳[加近攻_2]
local sk45005_status_break_add_att_near_2_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻_2]
local sk45005_status_rate_add_att_near_2_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加近攻_2]
local sk45005_calc_status_add_att_near_2_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=A近战攻击*0.2+A近战攻击*0.2*(取整(sk45005_SkillLv/sk45005_MAX_SkillLv))
	tbResult.add_att_near = iANear*0.2+iANear*0.2*(math.floor(attacker:getSkillLv("sk45005")/attacker:getSkillLv("sk45005_MAX")));

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk45005.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk45005_calc_status_add_att_far_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45005_pre_action_add_att_far_2_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk45005_select_cnt_add_att_far_2_0, 
		["sort_method"]="", 
		["status"]="add_att_far_2", 
		["status_break"]=sk45005_status_break_add_att_far_2_0, 
		["status_rate"]=sk45005_status_rate_add_att_far_2_0, 
		["status_time"]=sk45005_status_time_add_att_far_2_0, 
		["unselect_status"]=sk45005_unselect_status_add_att_far_2_0, 
	}, 
	{
		["calc_status"]=sk45005_calc_status_add_att_near_2_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk45005_pre_action_add_att_near_2_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk45005_select_cnt_add_att_near_2_1, 
		["sort_method"]="", 
		["status"]="add_att_near_2", 
		["status_break"]=sk45005_status_break_add_att_near_2_1, 
		["status_rate"]=sk45005_status_rate_add_att_near_2_1, 
		["status_time"]=sk45005_status_time_add_att_near_2_1, 
		["unselect_status"]=sk45005_unselect_status_add_att_near_2_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
