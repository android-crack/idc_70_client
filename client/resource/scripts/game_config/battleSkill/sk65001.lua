----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk65001 = class("cls_sk65001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk65001.get_skill_id = function(self)
	return "sk65001";
end


-- 技能名 
cls_sk65001.get_skill_name = function(self)
	return T("杀戮I");
end

-- 获取技能的描述
cls_sk65001.get_skill_desc = function(self, skill_data, lv)
	return T("击杀恢复耐久15%")
end

-- 获取技能的富文本描述
cls_sk65001.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk65001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk65001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk65001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- SP消耗公式
cls_sk65001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[击杀回血]
local sk65001_pre_action_jishahuixue_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[击杀回血]
local sk65001_select_cnt_jishahuixue_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[击杀回血]
local sk65001_unselect_status_jishahuixue_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[击杀回血]
local sk65001_status_time_jishahuixue_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[击杀回血]
local sk65001_status_break_jishahuixue_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[击杀回血]
local sk65001_status_rate_jishahuixue_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[击杀回血]
local sk65001_calc_status_jishahuixue_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:击杀回血数值=150
	tbResult.kill_huixue_value = 150;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk65001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk65001_calc_status_jishahuixue_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk65001_pre_action_jishahuixue_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk65001_select_cnt_jishahuixue_0, 
		["sort_method"]="", 
		["status"]="jishahuixue", 
		["status_break"]=sk65001_status_break_jishahuixue_0, 
		["status_rate"]=sk65001_status_rate_jishahuixue_0, 
		["status_time"]=sk65001_status_time_jishahuixue_0, 
		["unselect_status"]=sk65001_unselect_status_jishahuixue_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------