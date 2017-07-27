----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk2011_1 = class("cls_sk2011_1", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk2011_1.get_skill_id = function(self)
	return "sk2011_1";
end


-- 技能名 
cls_sk2011_1.get_skill_name = function(self)
	return T("突击释放1");
end

-- 获取技能的描述
cls_sk2011_1.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk2011_1.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 技能施法范围 
cls_sk2011_1.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk2011_1.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=300
	result = 300;

	return result
end

-- SP消耗公式
cls_sk2011_1.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk2011_1.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian03";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[突击]
local sk2011_1_pre_action_tuji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=110
	tbResult.translate = 110;

	return tbResult
end

-- 目标选择基础数量[突击]
local sk2011_1_select_cnt_tuji_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[突击]
local sk2011_1_unselect_status_tuji_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[突击]
local sk2011_1_status_time_tuji_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[突击]
local sk2011_1_status_break_tuji_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[突击]
local sk2011_1_status_rate_tuji_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[突击]
local sk2011_1_calc_status_tuji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian03"
	tbResult.hit_effect = "tx_shoujisuipian03";
	-- 公式原文:扣血=基础远程伤害*(1.2+技能等级*0.04+sk2012_SkillLv*0.06+sk2013_SkillLv*0.08)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1.2+lv*0.04+attacker:getSkillLv("sk2012")*0.06+attacker:getSkillLv("sk2013")*0.08);
	-- 公式原文:震屏幅度=4
	tbResult.shake_range = 4;
	-- 公式原文:震屏次数=7
	tbResult.shake_time = 7;
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;
	-- 公式原文:技能暴击几率=500
	tbResult.baoji_skill=500;

	return tbResult
end

-- 前置动作[减远攻]
local sk2011_1_pre_action_sub_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减远攻]
local sk2011_1_select_cnt_sub_att_far_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减远攻]
local sk2011_1_unselect_status_sub_att_far_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减远攻]
local sk2011_1_status_time_sub_att_far_1 = function(attacker, lv)
	return 
4
end

-- 状态心跳[减远攻]
local sk2011_1_status_break_sub_att_far_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减远攻]
local sk2011_1_status_rate_sub_att_far_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk2012_SkillLv/sk2012_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk2012")/attacker:getSkillLv("sk2012_MAX"));

	return result
end

-- 处理过程[减远攻]
local sk2011_1_calc_status_sub_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iTAtt = target:getAttFar();

	-- 公式原文:减远攻=T远程攻击*0.6
	tbResult.sub_att_far = iTAtt*0.6;

	return tbResult
end

-- 前置动作[减近攻]
local sk2011_1_pre_action_sub_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减近攻]
local sk2011_1_select_cnt_sub_att_near_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减近攻]
local sk2011_1_unselect_status_sub_att_near_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减近攻]
local sk2011_1_status_time_sub_att_near_2 = function(attacker, lv)
	return 
4
end

-- 状态心跳[减近攻]
local sk2011_1_status_break_sub_att_near_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减近攻]
local sk2011_1_status_rate_sub_att_near_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk2012_SkillLv/sk2012_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk2012")/attacker:getSkillLv("sk2012_MAX"));

	return result
end

-- 处理过程[减近攻]
local sk2011_1_calc_status_sub_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iTNear = target:getAttNear();

	-- 公式原文:减近攻=T近战攻击*0.6
	tbResult.sub_att_near = iTNear*0.6;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk2011_1.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk2011_1_calc_status_tuji_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2011_1_pre_action_tuji_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk2011_1_select_cnt_tuji_0, 
		["sort_method"]="", 
		["status"]="tuji", 
		["status_break"]=sk2011_1_status_break_tuji_0, 
		["status_rate"]=sk2011_1_status_rate_tuji_0, 
		["status_time"]=sk2011_1_status_time_tuji_0, 
		["unselect_status"]=sk2011_1_unselect_status_tuji_0, 
	}, 
	{
		["calc_status"]=sk2011_1_calc_status_sub_att_far_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2011_1_pre_action_sub_att_far_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk2011_1_select_cnt_sub_att_far_1, 
		["sort_method"]="", 
		["status"]="sub_att_far", 
		["status_break"]=sk2011_1_status_break_sub_att_far_1, 
		["status_rate"]=sk2011_1_status_rate_sub_att_far_1, 
		["status_time"]=sk2011_1_status_time_sub_att_far_1, 
		["unselect_status"]=sk2011_1_unselect_status_sub_att_far_1, 
	}, 
	{
		["calc_status"]=sk2011_1_calc_status_sub_att_near_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk2011_1_pre_action_sub_att_near_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk2011_1_select_cnt_sub_att_near_2, 
		["sort_method"]="", 
		["status"]="sub_att_near", 
		["status_break"]=sk2011_1_status_break_sub_att_near_2, 
		["status_rate"]=sk2011_1_status_rate_sub_att_near_2, 
		["status_time"]=sk2011_1_status_time_sub_att_near_2, 
		["unselect_status"]=sk2011_1_unselect_status_sub_att_near_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk2011_1.get_skill_type = function(self)
    return "auto"
end

cls_sk2011_1.get_skill_lv = function(self, attacker)
	return cls_sk2011:get_skill_lv( attacker )
end

cls_sk2011_1.end_display_call_back = function(self, attacker, target, tbIdx, dir, is_bullet)
	cls_sk2011_1.super.end_display_call_back(self, attacker, target, tbIdx, dir, true)
end

-- 施放目标拓展距离
cls_sk2011_1._get_limit_distance_max = function(self, attacker, lv)
	local near_attack_range = self:get_limit_distance_max(attacker, lv)
	local buff_obj = attacker:hasBuff("near_attack_range_up")
	if buff_obj then
		near_attack_range = near_attack_range + buff_obj.tbResult.add_near_att_range
	end
	return near_attack_range
end