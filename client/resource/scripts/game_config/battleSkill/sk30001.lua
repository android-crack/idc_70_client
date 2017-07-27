----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk30001 = class("cls_sk30001", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk30001.get_skill_id = function(self)
	return "sk30001";
end


-- 技能名 
cls_sk30001.get_skill_name = function(self)
	return T("全屏伤害");
end

-- 获取技能的描述
cls_sk30001.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk30001.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk30001.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk30001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 技能施法范围 
cls_sk30001.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk30001.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk30001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击特效预加载 
cls_sk30001.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[攻击]
local sk30001_pre_action_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=-100
	tbResult.translate = -100;

	return tbResult
end

-- 目标选择基础数量[攻击]
local sk30001_select_cnt_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[攻击]
local sk30001_unselect_status_attack_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[攻击]
local sk30001_status_time_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[攻击]
local sk30001_status_break_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[攻击]
local sk30001_status_rate_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[攻击]
local sk30001_calc_status_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=999999
	tbResult.sub_hp = 999999;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=2
	tbResult.shake_range = 2;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk30001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk30001_calc_status_attack_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk30001_pre_action_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk30001_select_cnt_attack_0, 
		["sort_method"]="", 
		["status"]="attack", 
		["status_break"]=sk30001_status_break_attack_0, 
		["status_rate"]=sk30001_status_rate_attack_0, 
		["status_time"]=sk30001_status_time_attack_0, 
		["unselect_status"]=sk30001_unselect_status_attack_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
