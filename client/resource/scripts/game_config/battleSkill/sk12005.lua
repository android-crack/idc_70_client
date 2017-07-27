----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk12005 = class("cls_sk12005", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk12005.get_skill_id = function(self)
	return "sk12005";
end


-- 技能名 
cls_sk12005.get_skill_name = function(self)
	return T("链弹（虚弱）");
end

-- 精简版技能描述 
cls_sk12005.get_skill_short_desc = function(self)
	return T("对射程内3个敌方造成远程伤害，并提升冒险家攻击和防御持续8秒");
end

-- 获取技能的描述
cls_sk12005.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内3个敌方造成%0.1f%%远程伤害，并提升冒险家%0.1f%%攻击和防御持续8秒"), (200+lv*20), (25+1*lv))
end

-- 获取技能的富文本描述
cls_sk12005.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对射程内3个敌方造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)远程伤害，并提升冒险家$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)攻击和防御持续8秒"), (200+lv*20), (25+1*lv))
end

-- 公共CD 
cls_sk12005.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk12005._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk12005.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk12005.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk12005.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk12005.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击音效 
cls_sk12005.get_hit_music = function(self)
	return "BT_CHAIN_HIT";
end


-- 受击特效预加载 
cls_sk12005.get_preload_hit_effect = function(self)
	return "tx_yanhua_boom";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk12005_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[攻击]
local sk12005_select_cnt_attack_0 = function(attacker, lv)
	return 
3
end

-- 目标选择忽视状态[攻击]
local sk12005_unselect_status_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[攻击]
local sk12005_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk12005_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk12005_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk12005_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_yanhua_boom"
	tbResult.hit_effect = "tx_yanhua_boom";
	-- 公式原文:扣血=基础远程伤害*(2+技能等级*0.2)/3
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(2+lv*0.2)/3;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=1
	tbResult.shake_range = 1;

	return tbResult
end

-- 前置动作[清除增益状态]
local sk12005_pre_action_clear_buff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除增益状态]
local sk12005_select_cnt_clear_buff_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[清除增益状态]
local sk12005_unselect_status_clear_buff_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[清除增益状态]
local sk12005_status_time_clear_buff_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[清除增益状态]
local sk12005_status_break_clear_buff_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除增益状态]
local sk12005_status_rate_clear_buff_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk12005_SkillLv/sk12005_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk12005")/attacker:getSkillLv("sk12005_MAX"));

	return result
end

-- 处理过程[清除增益状态]
local sk12005_calc_status_clear_buff_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[眩晕]
local sk12005_pre_action_stun_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[眩晕]
local sk12005_select_cnt_stun_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[眩晕]
local sk12005_unselect_status_stun_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[眩晕]
local sk12005_status_time_stun_2 = function(attacker, lv)
	return 
4
end

-- 状态心跳[眩晕]
local sk12005_status_break_stun_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[眩晕]
local sk12005_status_rate_stun_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=(100+技能等级*20)*取整(sk12005_SkillLv/sk12005_MAX_SkillLv)
	result = (100+lv*20)*math.floor(attacker:getSkillLv("sk12005")/attacker:getSkillLv("sk12005_MAX"));

	return result
end

-- 处理过程[眩晕]
local sk12005_calc_status_stun_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[加防]
local sk12005_pre_action_add_def_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防]
local sk12005_select_cnt_add_def_3 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加防]
local sk12005_unselect_status_add_def_3 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加防]
local sk12005_status_time_add_def_3 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加防]
local sk12005_status_break_add_def_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防]
local sk12005_status_rate_add_def_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加防]
local sk12005_calc_status_add_def_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- target的防御，不能设置，需要申明
	local iTDefense = target:getDefense();

	-- 公式原文:加防=T防御*(0.25+0.1*技能等级)
	tbResult.add_defend = iTDefense*(0.25+0.1*lv);

	return tbResult
end

-- 前置动作[加远攻]
local sk12005_pre_action_add_att_far_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻]
local sk12005_select_cnt_add_att_far_4 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加远攻]
local sk12005_unselect_status_add_att_far_4 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加远攻]
local sk12005_status_time_add_att_far_4 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加远攻]
local sk12005_status_break_add_att_far_4 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻]
local sk12005_status_rate_add_att_far_4 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加远攻]
local sk12005_calc_status_add_att_far_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iTAtt = target:getAttFar();

	-- 公式原文:加远攻=(0.25+0.01*技能等级)*T远程攻击
	tbResult.add_att_far = (0.25+0.01*lv)*iTAtt;

	return tbResult
end

-- 前置动作[加近攻]
local sk12005_pre_action_add_att_near_5 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻]
local sk12005_select_cnt_add_att_near_5 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加近攻]
local sk12005_unselect_status_add_att_near_5 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加近攻]
local sk12005_status_time_add_att_near_5 = function(attacker, lv)
	return 
8
end

-- 状态心跳[加近攻]
local sk12005_status_break_add_att_near_5 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻]
local sk12005_status_rate_add_att_near_5 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加近攻]
local sk12005_calc_status_add_att_near_5 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iTNear = target:getAttNear();

	-- 公式原文:加近攻=(0.25+0.01*技能等级)*T近战攻击
	tbResult.add_att_near = (0.25+0.01*lv)*iTNear;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk12005.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk12005_calc_status_attack_0, 
		["effect_name"]="liandan", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk12005_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk12005_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk12005_status_break_attack_0, 
		["status_rate"]=sk12005_status_rate_attack_0, 
		["status_time"]=sk12005_status_time_attack_0, 
		["unselect_status"]=sk12005_unselect_status_attack_0, 
	}, 
	{
		["calc_status"]=sk12005_calc_status_clear_buff_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12005_pre_action_clear_buff_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk12005_select_cnt_clear_buff_1, 
		["sort_method"]="", 
		["status"]="clear_buff", 
		["status_break"]=sk12005_status_break_clear_buff_1, 
		["status_rate"]=sk12005_status_rate_clear_buff_1, 
		["status_time"]=sk12005_status_time_clear_buff_1, 
		["unselect_status"]=sk12005_unselect_status_clear_buff_1, 
	}, 
	{
		["calc_status"]=sk12005_calc_status_stun_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12005_pre_action_stun_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk12005_select_cnt_stun_2, 
		["sort_method"]="", 
		["status"]="stun", 
		["status_break"]=sk12005_status_break_stun_2, 
		["status_rate"]=sk12005_status_rate_stun_2, 
		["status_time"]=sk12005_status_time_stun_2, 
		["unselect_status"]=sk12005_unselect_status_stun_2, 
	}, 
	{
		["calc_status"]=sk12005_calc_status_add_def_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12005_pre_action_add_def_3, 
		["scope"]="FRIEND_EXPLORE", 
		["select_cnt"]=sk12005_select_cnt_add_def_3, 
		["sort_method"]="", 
		["status"]="add_def", 
		["status_break"]=sk12005_status_break_add_def_3, 
		["status_rate"]=sk12005_status_rate_add_def_3, 
		["status_time"]=sk12005_status_time_add_def_3, 
		["unselect_status"]=sk12005_unselect_status_add_def_3, 
	}, 
	{
		["calc_status"]=sk12005_calc_status_add_att_far_4, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12005_pre_action_add_att_far_4, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk12005_select_cnt_add_att_far_4, 
		["sort_method"]="", 
		["status"]="add_att_far", 
		["status_break"]=sk12005_status_break_add_att_far_4, 
		["status_rate"]=sk12005_status_rate_add_att_far_4, 
		["status_time"]=sk12005_status_time_add_att_far_4, 
		["unselect_status"]=sk12005_unselect_status_add_att_far_4, 
	}, 
	{
		["calc_status"]=sk12005_calc_status_add_att_near_5, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk12005_pre_action_add_att_near_5, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk12005_select_cnt_add_att_near_5, 
		["sort_method"]="", 
		["status"]="add_att_near", 
		["status_break"]=sk12005_status_break_add_att_near_5, 
		["status_rate"]=sk12005_status_rate_add_att_near_5, 
		["status_time"]=sk12005_status_time_add_att_near_5, 
		["unselect_status"]=sk12005_unselect_status_add_att_near_5, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
