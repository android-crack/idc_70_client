----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk63001 = class("cls_sk63001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk63001.get_skill_id = function(self)
	return "sk63001";
end


-- 技能名 
cls_sk63001.get_skill_name = function(self)
	return T("嗜血I");
end

-- 获取技能的描述
cls_sk63001.get_skill_desc = function(self, skill_data, lv)
	return T("近战普攻的3%治疗自己")
end

-- 获取技能的富文本描述
cls_sk63001.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk63001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk63001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk63001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- SP消耗公式
cls_sk63001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[近普攻吸血]
local sk63001_pre_action_jinpugongxixue_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[近普攻吸血]
local sk63001_select_cnt_jinpugongxixue_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[近普攻吸血]
local sk63001_unselect_status_jinpugongxixue_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[近普攻吸血]
local sk63001_status_time_jinpugongxixue_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[近普攻吸血]
local sk63001_status_break_jinpugongxixue_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[近普攻吸血]
local sk63001_status_rate_jinpugongxixue_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[近普攻吸血]
local sk63001_calc_status_jinpugongxixue_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:吸血几率=30
	tbResult.xixue_rate = 30;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk63001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk63001_calc_status_jinpugongxixue_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk63001_pre_action_jinpugongxixue_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk63001_select_cnt_jinpugongxixue_0, 
		["sort_method"]="", 
		["status"]="jinpugongxixue", 
		["status_break"]=sk63001_status_break_jinpugongxixue_0, 
		["status_rate"]=sk63001_status_rate_jinpugongxixue_0, 
		["status_time"]=sk63001_status_time_jinpugongxixue_0, 
		["unselect_status"]=sk63001_unselect_status_jinpugongxixue_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------