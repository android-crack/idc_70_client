----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk3031 = class("cls_sk3031", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk3031.get_skill_id = function(self)
	return "sk3031";
end


-- 技能系别 
cls_sk3031.get_skill_series = function(self)
	return 2;
end


-- 技能名 
cls_sk3031.get_skill_name = function(self)
	return T("链弹");
end

-- 精简版技能描述 
cls_sk3031.get_skill_short_desc = function(self)
	return T("对射程内敌方造成一定远程伤害，并使其减速5秒，清除所有增益效果");
end

-- 获取技能的描述
cls_sk3031.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("对射程内敌方敌方造成%0.1f%%的远程伤害，并使其减速5秒，清除所有增益效果"), (120+lv*3))
end

-- 获取技能的富文本描述
cls_sk3031.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)对射程内敌方造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的远程伤害，并使其减速5秒，清除所有增益效果"), (120+lv*3))
end

-- 公共CD 
cls_sk3031.get_common_cd = function(self)
	return 1;
end


-- 技能CD
cls_sk3031._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=15
	result = 15;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk3031.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk3031.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk3031.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk3031.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"sf_liandan", }

cls_sk3031.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk3031.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk3031.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk3031.get_effect_music = function(self)
	return "BT_CHAIN_CASTING";
end


-- 开火音效 
cls_sk3031.get_fire_music = function(self)
	return "BT_CHAIN_SHOT";
end


-- 受击音效 
cls_sk3031.get_hit_music = function(self)
	return "BT_CHAIN_HIT";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[玩家链弹]
local sk3031_pre_action_player_liandan_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[玩家链弹]
local sk3031_select_cnt_player_liandan_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[玩家链弹]
local sk3031_unselect_status_player_liandan_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[玩家链弹]
local sk3031_status_time_player_liandan_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[玩家链弹]
local sk3031_status_break_player_liandan_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[玩家链弹]
local sk3031_status_rate_player_liandan_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[玩家链弹]
local sk3031_calc_status_player_liandan_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:关联技能="sk99003"
	tbResult.BossSkill = "sk99003";
	-- 公式原文:场景技能长度=A远程攻击距离
	tbResult.BossSkill_Length = iAAttRange;
	-- 公式原文:场景技能宽度=200
	tbResult.BossSkill_Width = 200;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk3031.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk3031_calc_status_player_liandan_0, 
		["effect_name"]="liuxingchui03", 
		["effect_time"]=1, 
		["effect_type"]="particle_launch", 
		["pre_action"]=sk3031_pre_action_player_liandan_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk3031_select_cnt_player_liandan_0, 
		["sort_method"]="", 
		["status"]="player_liandan", 
		["status_break"]=sk3031_status_break_player_liandan_0, 
		["status_rate"]=sk3031_status_rate_player_liandan_0, 
		["status_time"]=sk3031_status_time_player_liandan_0, 
		["unselect_status"]=sk3031_unselect_status_player_liandan_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------