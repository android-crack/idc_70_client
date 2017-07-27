----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk68003 = class("cls_sk68003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk68003.get_skill_id = function(self)
	return "sk68003";
end


-- 技能名 
cls_sk68003.get_skill_name = function(self)
	return T("回避III");
end

-- 获取技能的描述
cls_sk68003.get_skill_desc = function(self, skill_data, lv)
	return T("受到攻击3%增加闪避率")
end

-- 获取技能的富文本描述
cls_sk68003.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk68003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk68003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk68003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- SP消耗公式
cls_sk68003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[受普攻闪避]
local sk68003_pre_action_shoupugongshanbi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[受普攻闪避]
local sk68003_select_cnt_shoupugongshanbi_0 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[受普攻闪避]
local sk68003_unselect_status_shoupugongshanbi_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[受普攻闪避]
local sk68003_status_time_shoupugongshanbi_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[受普攻闪避]
local sk68003_status_break_shoupugongshanbi_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[受普攻闪避]
local sk68003_status_rate_shoupugongshanbi_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[受普攻闪避]
local sk68003_calc_status_shoupugongshanbi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:通用触发状态="dodge"
	tbResult.ty_status_id = "dodge";
	-- 公式原文:通用触发概率=30
	tbResult.ty_rate = 30;
	-- 公式原文:通用触发状态时间=4
	tbResult.ty_status_time = 4;
	-- 公式原文:提升闪避=300
	tbResult.dodge= 300;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk68003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk68003_calc_status_shoupugongshanbi_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk68003_pre_action_shoupugongshanbi_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk68003_select_cnt_shoupugongshanbi_0, 
		["sort_method"]="", 
		["status"]="shoupugongshanbi", 
		["status_break"]=sk68003_status_break_shoupugongshanbi_0, 
		["status_rate"]=sk68003_status_rate_shoupugongshanbi_0, 
		["status_time"]=sk68003_status_time_shoupugongshanbi_0, 
		["unselect_status"]=sk68003_unselect_status_shoupugongshanbi_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------