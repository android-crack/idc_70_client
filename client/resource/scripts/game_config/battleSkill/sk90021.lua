----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90021 = class("cls_sk90021", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90021.get_skill_id = function(self)
	return "sk90021";
end


-- 技能名 
cls_sk90021.get_skill_name = function(self)
	return T("链弹（破攻）释放");
end

-- 获取技能的描述
cls_sk90021.get_skill_desc = function(self, skill_data, lv)
	return T("使所有目标有5%几率进入眩晕，具体数值受双方速度影响。")
end

-- 获取技能的富文本描述
cls_sk90021.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)使所有目标有5%几率进入眩晕，具体数值受双方速度影响。")
end

-- 公共CD 
cls_sk90021.get_common_cd = function(self)
	return 0;
end


-- SP消耗公式
cls_sk90021.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[眩晕]
local sk90021_pre_action_stun_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[眩晕]
local sk90021_select_cnt_stun_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[眩晕]
local sk90021_unselect_status_stun_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[眩晕]
local sk90021_status_time_stun_0 = function(attacker, lv)
	return 
4
end

-- 状态心跳[眩晕]
local sk90021_status_break_stun_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[眩晕]
local sk90021_status_rate_stun_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[眩晕]
local sk90021_calc_status_stun_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90021.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90021_calc_status_stun_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90021_pre_action_stun_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk90021_select_cnt_stun_0, 
		["sort_method"]="", 
		["status"]="stun", 
		["status_break"]=sk90021_status_break_stun_0, 
		["status_rate"]=sk90021_status_rate_stun_0, 
		["status_time"]=sk90021_status_time_stun_0, 
		["unselect_status"]=sk90021_unselect_status_stun_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk90021.get_skill_type = function(self)
    return "auto"
end

cls_sk90021.get_skill_lv = function(self, attacker)
    return cls_sk12002:get_skill_lv( attacker )
end