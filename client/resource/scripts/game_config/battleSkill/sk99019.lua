----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99019 = class("cls_sk99019", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99019.get_skill_id = function(self)
	return "sk99019";
end


-- 技能名 
cls_sk99019.get_skill_name = function(self)
	return T("boss钩索（强力钩索）");
end

-- 精简版技能描述 
cls_sk99019.get_skill_short_desc = function(self)
	return T("抛出钩锁，对射程内3个敌方单位造成近战伤害，并将其勾至身边，降低攻击，持续4秒。");
end

-- 获取技能的描述
cls_sk99019.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("抛出钩索，对射程内3个敌方单位造成%0.1f%%近战伤害，并将其勾至身边，使其攻击降低75%%，持续4秒。"), (lv*50))
end

-- 获取技能的富文本描述
cls_sk99019.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，技能效果加成50%")
end

-- 公共CD 
cls_sk99019.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk99019._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk99019.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99019.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk99019.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk99019.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk99019.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[钩锁]
local sk99019_pre_action_gousuo_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=-1*MIN(T距离*0.8,300)
	tbResult.translate = -1*math.min(GetDistanceFor3D(attacker.body.node, target.body.node)*0.8,300);

	return tbResult
end

-- 目标选择基础数量[钩锁]
local sk99019_select_cnt_gousuo_0 = function(attacker, lv)
	return 
3
end

-- 目标选择忽视状态[钩锁]
local sk99019_unselect_status_gousuo_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[钩锁]
local sk99019_status_time_gousuo_0 = function(attacker, lv)
	return 
1/2
end

-- 状态心跳[钩锁]
local sk99019_status_break_gousuo_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[钩锁]
local sk99019_status_rate_gousuo_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[钩锁]
local sk99019_calc_status_gousuo_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=基础近战伤害*(技能等级*0.5)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(lv*0.5);
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end

-- 前置动作[减远攻]
local sk99019_pre_action_sub_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减远攻]
local sk99019_select_cnt_sub_att_far_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减远攻]
local sk99019_unselect_status_sub_att_far_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减远攻]
local sk99019_status_time_sub_att_far_1 = function(attacker, lv)
	return 
4
end

-- 状态心跳[减远攻]
local sk99019_status_break_sub_att_far_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减远攻]
local sk99019_status_rate_sub_att_far_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减远攻]
local sk99019_calc_status_sub_att_far_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iTAtt = target:getAttFar();

	-- 公式原文:减远攻=T远程攻击*0.75
	tbResult.sub_att_far = iTAtt*0.75;

	return tbResult
end

-- 前置动作[减近攻]
local sk99019_pre_action_sub_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减近攻]
local sk99019_select_cnt_sub_att_near_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减近攻]
local sk99019_unselect_status_sub_att_near_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减近攻]
local sk99019_status_time_sub_att_near_2 = function(attacker, lv)
	return 
4
end

-- 状态心跳[减近攻]
local sk99019_status_break_sub_att_near_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减近攻]
local sk99019_status_rate_sub_att_near_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减近攻]
local sk99019_calc_status_sub_att_near_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iTNear = target:getAttNear();

	-- 公式原文:减近攻=T近战攻击*0.75
	tbResult.sub_att_near = iTNear*0.75;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99019.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99019_calc_status_gousuo_0, 
		["effect_name"]="gousuo", 
		["effect_time"]=0, 
		["effect_type"]="gousuo", 
		["pre_action"]=sk99019_pre_action_gousuo_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99019_select_cnt_gousuo_0, 
		["sort_method"]="", 
		["status"]="gousuo", 
		["status_break"]=sk99019_status_break_gousuo_0, 
		["status_rate"]=sk99019_status_rate_gousuo_0, 
		["status_time"]=sk99019_status_time_gousuo_0, 
		["unselect_status"]=sk99019_unselect_status_gousuo_0, 
	}, 
	{
		["calc_status"]=sk99019_calc_status_sub_att_far_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99019_pre_action_sub_att_far_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99019_select_cnt_sub_att_far_1, 
		["sort_method"]="", 
		["status"]="sub_att_far", 
		["status_break"]=sk99019_status_break_sub_att_far_1, 
		["status_rate"]=sk99019_status_rate_sub_att_far_1, 
		["status_time"]=sk99019_status_time_sub_att_far_1, 
		["unselect_status"]=sk99019_unselect_status_sub_att_far_1, 
	}, 
	{
		["calc_status"]=sk99019_calc_status_sub_att_near_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99019_pre_action_sub_att_near_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99019_select_cnt_sub_att_near_2, 
		["sort_method"]="", 
		["status"]="sub_att_near", 
		["status_break"]=sk99019_status_break_sub_att_near_2, 
		["status_rate"]=sk99019_status_rate_sub_att_near_2, 
		["status_time"]=sk99019_status_time_sub_att_near_2, 
		["unselect_status"]=sk99019_unselect_status_sub_att_near_2, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------