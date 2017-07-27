----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk43006 = class("cls_sk43006", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk43006.get_skill_id = function(self)
	return "sk43006";
end


-- 技能名 
cls_sk43006.get_skill_name = function(self)
	return T("应变");
end

-- 精简版技能描述 
cls_sk43006.get_skill_short_desc = function(self)
	return T("航海士所在舰船的耐久小于50%时,增加防御和暴击，免疫减防");
end

-- 获取技能的描述
cls_sk43006.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("航海士所在舰船的耐久小于50%%时,增加防御和暴击率%0.1f%%，免疫减防"), (35+3*lv))
end

-- 获取技能的富文本描述
cls_sk43006.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)航海士所在舰船的耐久小于50%%时,增加防御和暴击率$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)，免疫减防"), (35+3*lv))
end

-- 公共CD 
cls_sk43006.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk43006._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 最小施法限制距离
cls_sk43006.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk43006.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk43006.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[坚如磐石]
local sk43006_pre_action_jianrupanshi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[坚如磐石]
local sk43006_select_cnt_jianrupanshi_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[坚如磐石]
local sk43006_unselect_status_jianrupanshi_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[坚如磐石]
local sk43006_status_time_jianrupanshi_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[坚如磐石]
local sk43006_status_break_jianrupanshi_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[坚如磐石]
local sk43006_status_rate_jianrupanshi_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[坚如磐石]
local sk43006_calc_status_jianrupanshi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 前置动作[近普攻吸血]
local sk43006_pre_action_jinpugongxixue_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[近普攻吸血]
local sk43006_select_cnt_jinpugongxixue_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[近普攻吸血]
local sk43006_unselect_status_jinpugongxixue_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[近普攻吸血]
local sk43006_status_time_jinpugongxixue_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[近普攻吸血]
local sk43006_status_break_jinpugongxixue_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[近普攻吸血]
local sk43006_status_rate_jinpugongxixue_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk43006_SkillLv/sk43006_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk43006")/attacker:getSkillLv("sk43006_MAX"));

	return result
end

-- 处理过程[近普攻吸血]
local sk43006_calc_status_jinpugongxixue_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:吸血几率=250
	tbResult.xixue_rate = 250;

	return tbResult
end

-- 前置动作[加防_3]
local sk43006_pre_action_add_def_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加防_3]
local sk43006_select_cnt_add_def_3_2 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[加防_3]
local sk43006_unselect_status_add_def_3_2 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加防_3]
local sk43006_status_time_add_def_3_2 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[加防_3]
local sk43006_status_break_add_def_3_2 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加防_3]
local sk43006_status_rate_add_def_3_2 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iARemainHP = attacker:getHp();

	-- 公式原文:结果=2000*取整((A耐久上限-A剩余耐久)*2/A耐久上限)
	result = 2000*math.floor((iAHpLimit-iARemainHP)*2/iAHpLimit);

	return result
end

-- 处理过程[加防_3]
local sk43006_calc_status_add_def_3_2 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iADefense = attacker:getDefense();

	-- 公式原文:加防=A防御*(0.35+0.03*技能等级)
	tbResult.add_defend = iADefense*(0.35+0.03*lv);

	return tbResult
end

-- 前置动作[暴击_2]
local sk43006_pre_action_baoji_2_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[暴击_2]
local sk43006_select_cnt_baoji_2_3 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[暴击_2]
local sk43006_unselect_status_baoji_2_3 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[暴击_2]
local sk43006_status_time_baoji_2_3 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[暴击_2]
local sk43006_status_break_baoji_2_3 = function(attacker, lv)
	return 
0
end

-- 命中率公式[暴击_2]
local sk43006_status_rate_baoji_2_3 = function(attacker, target, lv, tbParam)
	local result
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iARemainHP = attacker:getHp();

	-- 公式原文:结果=2000*取整((A耐久上限-A剩余耐久)*2/A耐久上限)
	result = 2000*math.floor((iAHpLimit-iARemainHP)*2/iAHpLimit);

	return result
end

-- 处理过程[暴击_2]
local sk43006_calc_status_baoji_2_3 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:暴击概率=350+30*技能等级
	tbResult.custom_baoji_rate=350+30*lv;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk43006.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk43006_calc_status_jianrupanshi_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43006_pre_action_jianrupanshi_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk43006_select_cnt_jianrupanshi_0, 
		["sort_method"]="", 
		["status"]="jianrupanshi", 
		["status_break"]=sk43006_status_break_jianrupanshi_0, 
		["status_rate"]=sk43006_status_rate_jianrupanshi_0, 
		["status_time"]=sk43006_status_time_jianrupanshi_0, 
		["unselect_status"]=sk43006_unselect_status_jianrupanshi_0, 
	}, 
	{
		["calc_status"]=sk43006_calc_status_jinpugongxixue_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43006_pre_action_jinpugongxixue_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk43006_select_cnt_jinpugongxixue_1, 
		["sort_method"]="", 
		["status"]="jinpugongxixue", 
		["status_break"]=sk43006_status_break_jinpugongxixue_1, 
		["status_rate"]=sk43006_status_rate_jinpugongxixue_1, 
		["status_time"]=sk43006_status_time_jinpugongxixue_1, 
		["unselect_status"]=sk43006_unselect_status_jinpugongxixue_1, 
	}, 
	{
		["calc_status"]=sk43006_calc_status_add_def_3_2, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43006_pre_action_add_def_3_2, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk43006_select_cnt_add_def_3_2, 
		["sort_method"]="", 
		["status"]="add_def_3", 
		["status_break"]=sk43006_status_break_add_def_3_2, 
		["status_rate"]=sk43006_status_rate_add_def_3_2, 
		["status_time"]=sk43006_status_time_add_def_3_2, 
		["unselect_status"]=sk43006_unselect_status_add_def_3_2, 
	}, 
	{
		["calc_status"]=sk43006_calc_status_baoji_2_3, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk43006_pre_action_baoji_2_3, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk43006_select_cnt_baoji_2_3, 
		["sort_method"]="", 
		["status"]="baoji_2", 
		["status_break"]=sk43006_status_break_baoji_2_3, 
		["status_rate"]=sk43006_status_rate_baoji_2_3, 
		["status_time"]=sk43006_status_time_baoji_2_3, 
		["unselect_status"]=sk43006_unselect_status_baoji_2_3, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
