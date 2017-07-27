----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk30005 = class("cls_sk30005", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk30005.get_skill_id = function(self)
	return "sk30005";
end


-- 技能名 
cls_sk30005.get_skill_name = function(self)
	return T("全屏火焰弹");
end

-- 获取技能的描述
cls_sk30005.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk30005.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk30005.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk30005._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk30005.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk30005.get_select_scope = function(self)
	return "ENEMY";
end


-- 最小施法限制距离
cls_sk30005.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk30005.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk30005.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_skillready", }

cls_sk30005.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_scene", }

cls_sk30005.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk30005.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk30005.get_effect_music = function(self)
	return "BT_SORTIE";
end


-- 开火音效 
cls_sk30005.get_fire_music = function(self)
	return "BT_HUOYANDAN_SHOT";
end


-- 受击音效 
cls_sk30005.get_hit_music = function(self)
	return "BT_HUOYANDAN_HIT";
end


-- 受击特效预加载 
cls_sk30005.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian03";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[扣血]
local sk30005_pre_action_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[扣血]
local sk30005_select_cnt_sub_hp_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[扣血]
local sk30005_unselect_status_sub_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[扣血]
local sk30005_status_time_sub_hp_0 = function(attacker, lv)
	return 
6
end

-- 状态心跳[扣血]
local sk30005_status_break_sub_hp_0 = function(attacker, lv)
	return 
1
end

-- 命中率公式[扣血]
local sk30005_status_rate_sub_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[扣血]
local sk30005_calc_status_sub_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian03"
	tbResult.hit_effect = "tx_shoujisuipian03";
	-- 公式原文:扣血=999999
	tbResult.sub_hp = 999999;
	-- 公式原文:震屏次数=10
	tbResult.shake_time = 10;
	-- 公式原文:震屏幅度=10
	tbResult.shake_range = 10;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk30005.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk30005_calc_status_sub_hp_0, 
		["effect_name"]="ranshaodan", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk30005_pre_action_sub_hp_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk30005_select_cnt_sub_hp_0, 
		["sort_method"]="", 
		["status"]="sub_hp", 
		["status_break"]=sk30005_status_break_sub_hp_0, 
		["status_rate"]=sk30005_status_rate_sub_hp_0, 
		["status_time"]=sk30005_status_time_sub_hp_0, 
		["unselect_status"]=sk30005_unselect_status_sub_hp_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------