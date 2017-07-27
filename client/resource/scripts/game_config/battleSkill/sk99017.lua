----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99017 = class("cls_sk99017", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99017.get_skill_id = function(self)
	return "sk99017";
end


-- 技能名 
cls_sk99017.get_skill_name = function(self)
	return T("boss突击（自爆）");
end

-- 精简版技能描述 
cls_sk99017.get_skill_short_desc = function(self)
	return T("快速冲撞敌方并自爆，造成大量近战伤害，并使其每秒扣除耐久。");
end

-- 获取技能的描述
cls_sk99017.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("快速冲撞敌方并自爆，造成%0.1f%%近战伤害，并每秒消耗目标一定耐久，持续6秒。"), (lv*100))
end

-- 获取技能的富文本描述
cls_sk99017.get_skill_color_desc = function(self, skill_data, lv)
	return T("技能等级配置每加1，技能效果加成100%")
end

-- 公共CD 
cls_sk99017.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk99017._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=20
	result = 20;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk99017.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99017.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk99017.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离+100
	result = iAAttRange+100;

	return result
end

-- SP消耗公式
cls_sk99017.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk99017.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk99017.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk99017.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=500
	result = 500;

	return result
end

-- 施法音效 
cls_sk99017.get_effect_music = function(self)
	return "BT_SORTIE";
end


-- 受击音效 
cls_sk99017.get_hit_music = function(self)
	return "BT_ZIBAO";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[突击_2]
local sk99017_pre_action_tuji_self_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[突击_2]
local sk99017_select_cnt_tuji_self_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[突击_2]
local sk99017_unselect_status_tuji_self_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[突击_2]
local sk99017_status_time_tuji_self_0 = function(attacker, lv)
	return 
2
end

-- 状态心跳[突击_2]
local sk99017_status_break_tuji_self_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[突击_2]
local sk99017_status_rate_tuji_self_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[突击_2]
local sk99017_calc_status_tuji_self_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:突击触发技能="sk99018"
	tbResult.tj_skill_id = "sk99018";
	-- 公式原文:突击速度=650
	tbResult.tj_speed = 650;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99017.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99017_calc_status_tuji_self_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk99017_pre_action_tuji_self_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk99017_select_cnt_tuji_self_0, 
		["sort_method"]="", 
		["status"]="tuji_self", 
		["status_break"]=sk99017_status_break_tuji_self_0, 
		["status_rate"]=sk99017_status_rate_tuji_self_0, 
		["status_time"]=sk99017_status_time_tuji_self_0, 
		["unselect_status"]=sk99017_unselect_status_tuji_self_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------