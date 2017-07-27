----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90017 = class("cls_sk90017", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90017.get_skill_id = function(self)
	return "sk90017";
end


-- 技能名 
cls_sk90017.get_skill_name = function(self)
	return T("突击释放");
end

-- 获取技能的描述
cls_sk90017.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90017.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 技能施法范围 
cls_sk90017.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk90017.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=150
	result = 150;

	return result
end

-- 受击特效预加载 
cls_sk90017.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian03";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[突击]
local sk90017_pre_action_tuji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=110
	tbResult.translate = 110;

	return tbResult
end

-- 目标选择基础数量[突击]
local sk90017_select_cnt_tuji_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[突击]
local sk90017_unselect_status_tuji_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[突击]
local sk90017_status_time_tuji_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[突击]
local sk90017_status_break_tuji_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[突击]
local sk90017_status_rate_tuji_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[突击]
local sk90017_calc_status_tuji_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian03"
	tbResult.hit_effect = "tx_shoujisuipian03";
	-- 公式原文:扣血=基础近战伤害*(2.5+技能等级*0.2)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(2.5+lv*0.2);
	-- 公式原文:震屏幅度=4
	tbResult.shake_range = 4;
	-- 公式原文:震屏次数=7
	tbResult.shake_time = 7;
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end

-- 前置动作[减远攻]
local sk90017_pre_action_sub_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减远攻]
local sk90017_select_cnt_sub_att_far_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减远攻]
local sk90017_unselect_status_sub_att_far_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减远攻]
local sk90017_status_time_sub_att_far_1 = function(attacker, lv)
	return 
6
end

-- 状态心跳[减远攻]
local sk90017_status_break_sub_att_far_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减远攻]
local sk90017_status_rate_sub_att_far_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减远攻]
local sk90017_calc_status_sub_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iTAtt = target:getAttFar();

	-- 公式原文:减远攻=T远程攻击*0.5
	tbResult.sub_att_far = iTAtt*0.5;

	return tbResult
end

-- 前置动作[减近攻]
local sk90017_pre_action_sub_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减近攻]
local sk90017_select_cnt_sub_att_near_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减近攻]
local sk90017_unselect_status_sub_att_near_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减近攻]
local sk90017_status_time_sub_att_near_2 = function(attacker, lv)
	return 
6
end

-- 状态心跳[减近攻]
local sk90017_status_break_sub_att_near_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减近攻]
local sk90017_status_rate_sub_att_near_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减近攻]
local sk90017_calc_status_sub_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iTNear = target:getAttNear();

	-- 公式原文:减近攻=T近战攻击*0.5
	tbResult.sub_att_near = iTNear*0.5;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90017.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90017_calc_status_tuji_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90017_pre_action_tuji_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk90017_select_cnt_tuji_0, 
		["sort_method"]="", 
		["status"]="tuji", 
		["status_break"]=sk90017_status_break_tuji_0, 
		["status_rate"]=sk90017_status_rate_tuji_0, 
		["status_time"]=sk90017_status_time_tuji_0, 
		["unselect_status"]=sk90017_unselect_status_tuji_0, 
	}, 
	{
		["calc_status"]=sk90017_calc_status_sub_att_far_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90017_pre_action_sub_att_far_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90017_select_cnt_sub_att_far_1, 
		["sort_method"]="", 
		["status"]="sub_att_far", 
		["status_break"]=sk90017_status_break_sub_att_far_1, 
		["status_rate"]=sk90017_status_rate_sub_att_far_1, 
		["status_time"]=sk90017_status_time_sub_att_far_1, 
		["unselect_status"]=sk90017_unselect_status_sub_att_far_1, 
	}, 
	{
		["calc_status"]=sk90017_calc_status_sub_att_near_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90017_pre_action_sub_att_near_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk90017_select_cnt_sub_att_near_2, 
		["sort_method"]="", 
		["status"]="sub_att_near", 
		["status_break"]=sk90017_status_break_sub_att_near_2, 
		["status_rate"]=sk90017_status_rate_sub_att_near_2, 
		["status_time"]=sk90017_status_time_sub_att_near_2, 
		["unselect_status"]=sk90017_unselect_status_sub_att_near_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90017.get_skill_type = function(self)
    return "auto"
end

cls_sk90017.get_skill_lv = function(self, attacker)
	return cls_sk21002:get_skill_lv( attacker )
end

-- 施放目标拓展距离
cls_sk90017._get_limit_distance_max = function(self, attacker, lv)
	local near_attack_range = self:get_limit_distance_max(attacker, lv)
	local buff_obj = attacker:hasBuff("near_attack_range_up")
	if buff_obj then
		near_attack_range = near_attack_range + buff_obj.tbResult.add_near_att_range
	end
	return near_attack_range
end