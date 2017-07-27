----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99003 = class("cls_sk99003", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99003.get_skill_id = function(self)
	return "sk99003";
end


-- 技能名 
cls_sk99003.get_skill_name = function(self)
	return T("玩家链弹");
end

-- 获取技能的描述
cls_sk99003.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk99003.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)通用技能，增加50速度")
end

-- 公共CD 
cls_sk99003.get_common_cd = function(self)
	return 0;
end


-- SP消耗公式
cls_sk99003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk99003.get_preload_hit_effect = function(self)
	return "tx_newliandan_hit";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk99003_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk99003_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk99003_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk99003_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk99003_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk99003_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk99003_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_newliandan_hit"
	tbResult.hit_effect = "tx_newliandan_hit";
	-- 公式原文:扣血=基础远程伤害*(1.2+技能等级*0.03+0.045*sk3032_SkillLv+0.06*sk3033_SkillLv)*2/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1.2+lv*0.03+0.045*attacker:getSkillLv("sk3032")+0.06*attacker:getSkillLv("sk3033"))*2/3;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=2
	tbResult.shake_range = 2;

	return tbResult
end

-- 前置动作[清除增益状态]
local sk99003_pre_action_clear_buff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除增益状态]
local sk99003_select_cnt_clear_buff_1 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[清除增益状态]
local sk99003_unselect_status_clear_buff_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[清除增益状态]
local sk99003_status_time_clear_buff_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[清除增益状态]
local sk99003_status_break_clear_buff_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除增益状态]
local sk99003_status_rate_clear_buff_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[清除增益状态]
local sk99003_calc_status_clear_buff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[减速]
local sk99003_pre_action_slow_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减速]
local sk99003_select_cnt_slow_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减速]
local sk99003_unselect_status_slow_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减速]
local sk99003_status_time_slow_2 = function(attacker, lv)
	return 
5
end

-- 状态心跳[减速]
local sk99003_status_break_slow_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减速]
local sk99003_status_rate_slow_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[减速]
local sk99003_calc_status_slow_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:减速=50
	tbResult.sub_speed = 50;

	return tbResult
end

-- 前置动作[减远攻]
local sk99003_pre_action_sub_att_far_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减远攻]
local sk99003_select_cnt_sub_att_far_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减远攻]
local sk99003_unselect_status_sub_att_far_3 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[减远攻]
local sk99003_status_time_sub_att_far_3 = function(attacker, lv)
	return 
5
end

-- 状态心跳[减远攻]
local sk99003_status_break_sub_att_far_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减远攻]
local sk99003_status_rate_sub_att_far_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk3032_SkillLv/sk3032_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk3032")/attacker:getSkillLv("sk3032_MAX"));

	return result
end

-- 处理过程[减远攻]
local sk99003_calc_status_sub_att_far_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iTAtt = target:getAttFar();

	-- 公式原文:减远攻=T远程攻击*0.4
	tbResult.sub_att_far = iTAtt*0.4;

	return tbResult
end

-- 前置动作[减近攻]
local sk99003_pre_action_sub_att_near_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[减近攻]
local sk99003_select_cnt_sub_att_near_4 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[减近攻]
local sk99003_unselect_status_sub_att_near_4 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[减近攻]
local sk99003_status_time_sub_att_near_4 = function(attacker, lv)
	return 
5
end

-- 状态心跳[减近攻]
local sk99003_status_break_sub_att_near_4 = function(attacker, lv)
	return 
0
end

-- 命中率公式[减近攻]
local sk99003_status_rate_sub_att_near_4 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk3032_SkillLv/sk3032_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk3032")/attacker:getSkillLv("sk3032_MAX"));

	return result
end

-- 处理过程[减近攻]
local sk99003_calc_status_sub_att_near_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iTNear = target:getAttNear();

	-- 公式原文:减近攻=T近战攻击*0.4
	tbResult.sub_att_near = iTNear*0.4;

	return tbResult
end

-- 前置动作[眩晕]
local sk99003_pre_action_stun_5 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[眩晕]
local sk99003_select_cnt_stun_5 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[眩晕]
local sk99003_unselect_status_stun_5 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[眩晕]
local sk99003_status_time_stun_5 = function(attacker, lv)
	return 
4
end

-- 状态心跳[眩晕]
local sk99003_status_break_stun_5 = function(attacker, lv)
	return 
0
end

-- 命中率公式[眩晕]
local sk99003_status_rate_stun_5 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk3033_SkillLv/sk3033_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk3033")/attacker:getSkillLv("sk3033_MAX"));

	return result
end

-- 处理过程[眩晕]
local sk99003_calc_status_stun_5 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99003_calc_status_attack_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99003_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99003_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk99003_status_break_attack_0, 
		["status_rate"]=sk99003_status_rate_attack_0, 
		["status_time"]=sk99003_status_time_attack_0, 
		["unselect_status"]=sk99003_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk99003_calc_status_clear_buff_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99003_pre_action_clear_buff_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99003_select_cnt_clear_buff_1, 
		["sort_method"]="", 
		["status"]="clear_buff", 
		["status_break"]=sk99003_status_break_clear_buff_1, 
		["status_rate"]=sk99003_status_rate_clear_buff_1, 
		["status_time"]=sk99003_status_time_clear_buff_1, 
		["unselect_status"]=sk99003_unselect_status_clear_buff_1, 
	}, 
	{
		["calc_status"]=sk99003_calc_status_slow_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99003_pre_action_slow_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99003_select_cnt_slow_2, 
		["sort_method"]="", 
		["status"]="slow", 
		["status_break"]=sk99003_status_break_slow_2, 
		["status_rate"]=sk99003_status_rate_slow_2, 
		["status_time"]=sk99003_status_time_slow_2, 
		["unselect_status"]=sk99003_unselect_status_slow_2, 
	}, 
	{
		["calc_status"]=sk99003_calc_status_sub_att_far_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99003_pre_action_sub_att_far_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99003_select_cnt_sub_att_far_3, 
		["sort_method"]="", 
		["status"]="sub_att_far", 
		["status_break"]=sk99003_status_break_sub_att_far_3, 
		["status_rate"]=sk99003_status_rate_sub_att_far_3, 
		["status_time"]=sk99003_status_time_sub_att_far_3, 
		["unselect_status"]=sk99003_unselect_status_sub_att_far_3, 
	}, 
	{
		["calc_status"]=sk99003_calc_status_sub_att_near_4, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99003_pre_action_sub_att_near_4, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99003_select_cnt_sub_att_near_4, 
		["sort_method"]="", 
		["status"]="sub_att_near", 
		["status_break"]=sk99003_status_break_sub_att_near_4, 
		["status_rate"]=sk99003_status_rate_sub_att_near_4, 
		["status_time"]=sk99003_status_time_sub_att_near_4, 
		["unselect_status"]=sk99003_unselect_status_sub_att_near_4, 
	}, 
	{
		["calc_status"]=sk99003_calc_status_stun_5, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99003_pre_action_stun_5, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99003_select_cnt_stun_5, 
		["sort_method"]="", 
		["status"]="stun", 
		["status_break"]=sk99003_status_break_stun_5, 
		["status_rate"]=sk99003_status_rate_stun_5, 
		["status_time"]=sk99003_status_time_stun_5, 
		["unselect_status"]=sk99003_unselect_status_stun_5, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------