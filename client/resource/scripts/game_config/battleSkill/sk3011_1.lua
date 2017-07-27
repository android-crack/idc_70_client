----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk3011_1 = class("cls_sk3011_1", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk3011_1.get_skill_id = function(self)
	return "sk3011_1";
end


-- 技能名 
cls_sk3011_1.get_skill_name = function(self)
	return T("眩晕释放1");
end

-- 获取技能的描述
cls_sk3011_1.get_skill_desc = function(self, skill_data, lv)
	
	-- 描述："nil"
	-- 公式："nil"
	return "nil"
end

-- 公共CD 
cls_sk3011_1.get_common_cd = function(self)
	return 0;
end


-- SP消耗公式
cls_sk3011_1.calc_sp_cost = function(self, attacker, lv)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 目标选择基础数量[眩晕]
local sk3011_1_select_cnt_stun_0
sk3011_1_select_cnt_stun_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[眩晕]
local sk3011_1_unselect_status_stun_0
sk3011_1_unselect_status_stun_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[眩晕]
local sk3011_1_status_time_stun_0
sk3011_1_status_time_stun_0 = function(attacker, lv)
	return 
8
end

-- 状态心跳[眩晕]
local sk3011_1_status_break_stun_0
sk3011_1_status_break_stun_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[眩晕]
local sk3011_1_status_rate_stun_0
sk3011_1_status_rate_stun_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[眩晕]
local sk3011_1_calc_status_stun_0
sk3011_1_calc_status_stun_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk3011_1.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk3011_1_calc_status_stun_0, 
		["effect_name"]="", 
		["effect_time"]="", 
		["effect_type"]="", 
		["scope"]="ENEMY", 
		["select_cnt"]=sk3011_1_select_cnt_stun_0, 
		["sort_method"]="", 
		["status"]="stun", 
		["status_break"]=sk3011_1_status_break_stun_0, 
		["status_rate"]=sk3011_1_status_rate_stun_0, 
		["status_time"]=sk3011_1_status_time_stun_0, 
		["unselect_status"]=sk3011_1_unselect_status_stun_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------