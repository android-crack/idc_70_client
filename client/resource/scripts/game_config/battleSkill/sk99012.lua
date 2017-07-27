----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99012 = class("cls_sk99012", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99012.get_skill_id = function(self)
	return "sk99012";
end


-- 技能名 
cls_sk99012.get_skill_name = function(self)
	return T("BOSS指挥旗");
end

-- 精简版技能描述 
cls_sk99012.get_skill_short_desc = function(self)
	return T("提升施法者一定攻击和防御，持续8秒，施法者脱离不良状态");
end

-- 获取技能的描述
cls_sk99012.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("提升施法者%0.1f%%攻击和%0.1f%%的防御，持续8秒，施法者脱离不良状态"), (10*lv), (10*lv))
end

-- 获取技能的富文本描述
cls_sk99012.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，攻击防御提升10%")
end

-- 公共CD 
cls_sk99012.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk99012._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=30
	result = 30;

	return result
end

-- 技能施法范围 
cls_sk99012.get_select_scope = function(self)
	return "SELF";
end


-- 最大施法限制距离
cls_sk99012.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk99012.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"sf_0175", }

cls_sk99012.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk99012.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk99012.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk99012.get_effect_music = function(self)
	return "BT_SALVO_CASTING";
end


-- 受击音效 
cls_sk99012.get_hit_music = function(self)
	return "BT_SALVO_HIT";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加远攻]
local sk99012_pre_action_add_att_far_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加远攻]
local sk99012_select_cnt_add_att_far_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=1+取整(sk1033_SkillLv/sk1033_MAX_SkillLv)*998
	result = 1+math.floor(attacker:getSkillLv("sk1033")/attacker:getSkillLv("sk1033_MAX"))*998;

	return result
end

-- 目标选择忽视状态[加远攻]
local sk99012_unselect_status_add_att_far_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加远攻]
local sk99012_status_time_add_att_far_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=8+4*取整(sk1032_SkillLv/sk1032_MAX_SkillLv)
	result = 8+4*math.floor(attacker:getSkillLv("sk1032")/attacker:getSkillLv("sk1032_MAX"));

	return result
end

-- 状态心跳[加远攻]
local sk99012_status_break_add_att_far_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加远攻]
local sk99012_status_rate_add_att_far_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加远攻]
local sk99012_calc_status_add_att_far_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击，不能设置，需要申明
	local iAAtt = attacker:getAttFar();

	-- 公式原文:加远攻=(0.1*技能等级+0.02*sk1032_SkillLv+0.01*sk1033_SkillLv)*A远程攻击
	tbResult.add_att_far = (0.1*lv+0.02*attacker:getSkillLv("sk1032")+0.01*attacker:getSkillLv("sk1033"))*iAAtt;

	return tbResult
end

-- 前置动作[加近攻]
local sk99012_pre_action_add_att_near_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加近攻]
local sk99012_select_cnt_add_att_near_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加近攻]
local sk99012_unselect_status_add_att_near_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加近攻]
local sk99012_status_time_add_att_near_1 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=8+4*取整(sk1032_SkillLv/sk1032_MAX_SkillLv)
	result = 8+4*math.floor(attacker:getSkillLv("sk1032")/attacker:getSkillLv("sk1032_MAX"));

	return result
end

-- 状态心跳[加近攻]
local sk99012_status_break_add_att_near_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加近攻]
local sk99012_status_rate_add_att_near_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加近攻]
local sk99012_calc_status_add_att_near_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iANear = attacker:getAttNear();

	-- 公式原文:加近攻=(0.1*技能等级+0.02*sk1032_SkillLv+0.01*sk1033_SkillLv)*A近战攻击
	tbResult.add_att_near = (0.1*lv+0.02*attacker:getSkillLv("sk1032")+0.01*attacker:getSkillLv("sk1033"))*iANear;

	return tbResult
end

-- 前置动作[加防_3]
local sk99012_pre_action_add_def_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防_3]
local sk99012_select_cnt_add_def_3_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加防_3]
local sk99012_unselect_status_add_def_3_2 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加防_3]
local sk99012_status_time_add_def_3_2 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=8+4*取整(sk1032_SkillLv/sk1032_MAX_SkillLv)
	result = 8+4*math.floor(attacker:getSkillLv("sk1032")/attacker:getSkillLv("sk1032_MAX"));

	return result
end

-- 状态心跳[加防_3]
local sk99012_status_break_add_def_3_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防_3]
local sk99012_status_rate_add_def_3_2 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加防_3]
local sk99012_calc_status_add_def_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=(0.1*技能等级+0.02*sk1032_SkillLv+0.01*sk1033_SkillLv)*A防御
	tbResult.add_defend = (0.1*lv+0.02*attacker:getSkillLv("sk1032")+0.01*attacker:getSkillLv("sk1033"))*iADefense;

	return tbResult
end

-- 前置动作[清除减益状态]
local sk99012_pre_action_clear_debuff_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[清除减益状态]
local sk99012_select_cnt_clear_debuff_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[清除减益状态]
local sk99012_unselect_status_clear_debuff_3 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[清除减益状态]
local sk99012_status_time_clear_debuff_3 = function(attacker, lv)
	return 
1
end

-- 状态心跳[清除减益状态]
local sk99012_status_break_clear_debuff_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[清除减益状态]
local sk99012_status_rate_clear_debuff_3 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[清除减益状态]
local sk99012_calc_status_clear_debuff_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[指挥旗特效]
local sk99012_pre_action_zhihuiqi_effect_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[指挥旗特效]
local sk99012_select_cnt_zhihuiqi_effect_4 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[指挥旗特效]
local sk99012_unselect_status_zhihuiqi_effect_4 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[指挥旗特效]
local sk99012_status_time_zhihuiqi_effect_4 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=8+4*取整(sk1032_SkillLv/sk1032_MAX_SkillLv)
	result = 8+4*math.floor(attacker:getSkillLv("sk1032")/attacker:getSkillLv("sk1032_MAX"));

	return result
end

-- 状态心跳[指挥旗特效]
local sk99012_status_break_zhihuiqi_effect_4 = function(attacker, lv)
	return 
0
end

-- 命中率公式[指挥旗特效]
local sk99012_status_rate_zhihuiqi_effect_4 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[指挥旗特效]
local sk99012_calc_status_zhihuiqi_effect_4 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99012.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99012_calc_status_add_att_far_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99012_pre_action_add_att_far_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk99012_select_cnt_add_att_far_0, 
		["sort_method"]="", 
		["status"]="add_att_far", 
		["status_break"]=sk99012_status_break_add_att_far_0, 
		["status_rate"]=sk99012_status_rate_add_att_far_0, 
		["status_time"]=sk99012_status_time_add_att_far_0, 
		["unselect_status"]=sk99012_unselect_status_add_att_far_0, 
	}, 
	{
		["calc_status"]=sk99012_calc_status_add_att_near_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99012_pre_action_add_att_near_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99012_select_cnt_add_att_near_1, 
		["sort_method"]="", 
		["status"]="add_att_near", 
		["status_break"]=sk99012_status_break_add_att_near_1, 
		["status_rate"]=sk99012_status_rate_add_att_near_1, 
		["status_time"]=sk99012_status_time_add_att_near_1, 
		["unselect_status"]=sk99012_unselect_status_add_att_near_1, 
	}, 
	{
		["calc_status"]=sk99012_calc_status_add_def_3_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99012_pre_action_add_def_3_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99012_select_cnt_add_def_3_2, 
		["sort_method"]="", 
		["status"]="add_def_3", 
		["status_break"]=sk99012_status_break_add_def_3_2, 
		["status_rate"]=sk99012_status_rate_add_def_3_2, 
		["status_time"]=sk99012_status_time_add_def_3_2, 
		["unselect_status"]=sk99012_unselect_status_add_def_3_2, 
	}, 
	{
		["calc_status"]=sk99012_calc_status_clear_debuff_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99012_pre_action_clear_debuff_3, 
		["scope"]="SELF", 
		["select_cnt"]=sk99012_select_cnt_clear_debuff_3, 
		["sort_method"]="", 
		["status"]="clear_debuff", 
		["status_break"]=sk99012_status_break_clear_debuff_3, 
		["status_rate"]=sk99012_status_rate_clear_debuff_3, 
		["status_time"]=sk99012_status_time_clear_debuff_3, 
		["unselect_status"]=sk99012_unselect_status_clear_debuff_3, 
	}, 
	{
		["calc_status"]=sk99012_calc_status_zhihuiqi_effect_4, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99012_pre_action_zhihuiqi_effect_4, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk99012_select_cnt_zhihuiqi_effect_4, 
		["sort_method"]="", 
		["status"]="zhihuiqi_effect", 
		["status_break"]=sk99012_status_break_zhihuiqi_effect_4, 
		["status_rate"]=sk99012_status_rate_zhihuiqi_effect_4, 
		["status_time"]=sk99012_status_time_zhihuiqi_effect_4, 
		["unselect_status"]=sk99012_unselect_status_zhihuiqi_effect_4, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------