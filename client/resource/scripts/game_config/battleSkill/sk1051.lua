----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk1051 = class("cls_sk1051", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk1051.get_skill_id = function(self)
	return "sk1051";
end


-- 技能名 
cls_sk1051.get_skill_name = function(self)
	return T("火焰弹");
end

-- 精简版技能描述 
cls_sk1051.get_skill_short_desc = function(self)
	return T("向目标发射火焰弹，对目标以及周围敌方单位造成伤害并附带燃烧效果（无法治疗）持续5秒。");
end

-- 获取技能的描述
cls_sk1051.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("向目标发射火焰弹，对目标主体造成%0.1f%%的伤害，并对主体周围造成每秒%0.1f%%的燃烧效果（无法治疗）,持续5秒。"), (450+10*lv), (40+1*lv))
end

-- 获取技能的富文本描述
cls_sk1051.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对目标主体造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的伤害，并对主体周围造成每秒$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的燃烧效果（无法治疗）,持续5秒"), (450+10*lv), (40+1*lv))
end

-- 公共CD 
cls_sk1051.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk1051._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=40-15*取整(sk1053_SkillLv/sk1053_MAX_SkillLv)
	result = 40-15*math.floor(attacker:getSkillLv("sk1053")/attacker:getSkillLv("sk1053_MAX"));

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk1051.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk1051.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk1051.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk1051.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", "screen_huoyandan", }

cls_sk1051.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_scene", "armature_scene", }

cls_sk1051.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk1051.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk1051.get_effect_music = function(self)
	return "BT_SORTIE";
end


-- 开火音效 
cls_sk1051.get_fire_music = function(self)
	return "BT_HUOYANDAN_SHOT";
end


-- 受击音效 
cls_sk1051.get_hit_music = function(self)
	return "BT_HUOYANDAN_HIT";
end


-- 受击特效预加载 
cls_sk1051.get_preload_hit_effect = function(self)
	return "tx_ranshaodan_hit";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[火焰弹]
local sk1051_pre_action_huoyandan_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[火焰弹]
local sk1051_select_cnt_huoyandan_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[火焰弹]
local sk1051_unselect_status_huoyandan_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[火焰弹]
local sk1051_status_time_huoyandan_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[火焰弹]
local sk1051_status_break_huoyandan_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[火焰弹]
local sk1051_status_rate_huoyandan_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[火焰弹]
local sk1051_calc_status_huoyandan_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_ranshaodan_hit"
	tbResult.hit_effect = "tx_ranshaodan_hit";
	-- 公式原文:通用触发技能="sk90024"
	tbResult.ty_skill_id = "sk90024";
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=10
	tbResult.shake_range = 10;

	return tbResult
end

-- 前置动作[扣血]
local sk1051_pre_action_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk1051_select_cnt_sub_hp_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血]
local sk1051_unselect_status_sub_hp_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血]
local sk1051_status_time_sub_hp_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[扣血]
local sk1051_status_break_sub_hp_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[扣血]
local sk1051_status_rate_sub_hp_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[扣血]
local sk1051_calc_status_sub_hp_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础远程伤害*(4.5+0.1*技能等级+0.025*sk1052_SkillLv+0.035*sk1053_SkillLv)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(4.5+0.1*lv+0.025*attacker:getSkillLv("sk1052")+0.035*attacker:getSkillLv("sk1053"));

	return tbResult
end

-- 前置动作[扣血]
local sk1051_pre_action_sub_hp_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk1051_select_cnt_sub_hp_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[扣血]
local sk1051_unselect_status_sub_hp_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[扣血]
local sk1051_status_time_sub_hp_2 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 状态心跳[扣血]
local sk1051_status_break_sub_hp_2 = function(attacker, lv)
	return 
1
end

-- 命中率公式[扣血]
local sk1051_status_rate_sub_hp_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[扣血]
local sk1051_calc_status_sub_hp_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础远程伤害*(0.4+0.01*技能等级+0.025*sk1052_SkillLv+0.035*sk1053_SkillLv)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(0.4+0.01*lv+0.025*attacker:getSkillLv("sk1052")+0.035*attacker:getSkillLv("sk1053"));

	return tbResult
end

-- 前置动作[无法治疗]
local sk1051_pre_action_never_heal_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[无法治疗]
local sk1051_select_cnt_never_heal_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[无法治疗]
local sk1051_unselect_status_never_heal_3 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[无法治疗]
local sk1051_status_time_never_heal_3 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 状态心跳[无法治疗]
local sk1051_status_break_never_heal_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[无法治疗]
local sk1051_status_rate_never_heal_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[无法治疗]
local sk1051_calc_status_never_heal_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[降防]
local sk1051_pre_action_sub_def_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[降防]
local sk1051_select_cnt_sub_def_4 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[降防]
local sk1051_unselect_status_sub_def_4 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[降防]
local sk1051_status_time_sub_def_4 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=5
	result = 5;

	return result
end

-- 状态心跳[降防]
local sk1051_status_break_sub_def_4 = function(attacker, lv)
	return 
0
end

-- 命中率公式[降防]
local sk1051_status_rate_sub_def_4 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk1052_SkillLv/sk1052_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk1052")/attacker:getSkillLv("sk1052_MAX"));

	return result
end

-- 处理过程[降防]
local sk1051_calc_status_sub_def_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- target的防御，不能设置，需要申明
	local iTDefense = target:getDefense();

	-- 公式原文:减防=T防御*0.3
	tbResult.sub_defend = iTDefense*0.3;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk1051.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk1051_calc_status_huoyandan_0, 
		["effect_name"]="ranshaodan", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk1051_pre_action_huoyandan_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk1051_select_cnt_huoyandan_0, 
		["sort_method"]="", 
		["status"]="huoyandan", 
		["status_break"]=sk1051_status_break_huoyandan_0, 
		["status_rate"]=sk1051_status_rate_huoyandan_0, 
		["status_time"]=sk1051_status_time_huoyandan_0, 
		["unselect_status"]=sk1051_unselect_status_huoyandan_0, 
	}, 
	{
		["calc_status"]=sk1051_calc_status_sub_hp_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1051_pre_action_sub_hp_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1051_select_cnt_sub_hp_1, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk1051_status_break_sub_hp_1, 
		["status_rate"]=sk1051_status_rate_sub_hp_1, 
		["status_time"]=sk1051_status_time_sub_hp_1, 
		["unselect_status"]=sk1051_unselect_status_sub_hp_1, 
	}, 
	{
		["calc_status"]=sk1051_calc_status_sub_hp_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1051_pre_action_sub_hp_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1051_select_cnt_sub_hp_2, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk1051_status_break_sub_hp_2, 
		["status_rate"]=sk1051_status_rate_sub_hp_2, 
		["status_time"]=sk1051_status_time_sub_hp_2, 
		["unselect_status"]=sk1051_unselect_status_sub_hp_2, 
	}, 
	{
		["calc_status"]=sk1051_calc_status_never_heal_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1051_pre_action_never_heal_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1051_select_cnt_never_heal_3, 
		["sort_method"]="", 
		["status"]="never_heal", 
		["status_break"]=sk1051_status_break_never_heal_3, 
		["status_rate"]=sk1051_status_rate_never_heal_3, 
		["status_time"]=sk1051_status_time_never_heal_3, 
		["unselect_status"]=sk1051_unselect_status_never_heal_3, 
	}, 
	{
		["calc_status"]=sk1051_calc_status_sub_def_4, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1051_pre_action_sub_def_4, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1051_select_cnt_sub_def_4, 
		["sort_method"]="", 
		["status"]="sub_def", 
		["status_break"]=sk1051_status_break_sub_def_4, 
		["status_rate"]=sk1051_status_rate_sub_def_4, 
		["status_time"]=sk1051_status_time_sub_def_4, 
		["unselect_status"]=sk1051_unselect_status_sub_def_4, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------