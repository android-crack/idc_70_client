----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk61001 = class("cls_sk61001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk61001.get_skill_id = function(self)
	return "sk61001";
end


-- 技能名 
cls_sk61001.get_skill_name = function(self)
	return T("穿甲I");
end

-- 获取技能的描述
cls_sk61001.get_skill_desc = function(self, skill_data, lv)
	return T("远程普攻10%减目标防御")
end

-- 获取技能的富文本描述
cls_sk61001.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk61001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk61001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk61001.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- SP消耗公式
cls_sk61001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[远普攻降防]
local sk61001_pre_action_yuanpugongjiangfang_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远普攻降防]
local sk61001_select_cnt_yuanpugongjiangfang_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[远普攻降防]
local sk61001_unselect_status_yuanpugongjiangfang_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[远普攻降防]
local sk61001_status_time_yuanpugongjiangfang_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[远普攻降防]
local sk61001_status_break_yuanpugongjiangfang_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远普攻降防]
local sk61001_status_rate_yuanpugongjiangfang_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[远普攻降防]
local sk61001_calc_status_yuanpugongjiangfang_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:通用触发状态="sub_def"
	tbResult.ty_status_id = "sub_def";
	-- 公式原文:通用触发概率=100
	tbResult.ty_rate = 100;
	-- 公式原文:通用触发状态时间=2
	tbResult.ty_status_time = 2;
	-- 公式原文:降防数值=500
	tbResult.jiangfang_value = 500;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk61001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk61001_calc_status_yuanpugongjiangfang_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk61001_pre_action_yuanpugongjiangfang_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk61001_select_cnt_yuanpugongjiangfang_0, 
		["sort_method"]="", 
		["status"]="yuanpugongjiangfang", 
		["status_break"]=sk61001_status_break_yuanpugongjiangfang_0, 
		["status_rate"]=sk61001_status_rate_yuanpugongjiangfang_0, 
		["status_time"]=sk61001_status_time_yuanpugongjiangfang_0, 
		["unselect_status"]=sk61001_unselect_status_yuanpugongjiangfang_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------