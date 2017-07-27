----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99001 = class("cls_sk99001", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99001.get_skill_id = function(self)
	return "sk99001";
end


-- 技能系别 
cls_sk99001.get_skill_series = function(self)
	return 102;
end


-- 技能名 
cls_sk99001.get_skill_name = function(self)
	return T("BOSS链弹准备释放");
end

-- 精简版技能描述 
cls_sk99001.get_skill_short_desc = function(self)
	return T("BOSS正常技能");
end

-- 获取技能的描述
cls_sk99001.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk99001.get_skill_color_desc = function(self, skill_data, lv)
	return T("$(c:COLOR_CAMEL)通用技能，增加50速度")
end

-- 公共CD 
cls_sk99001.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk99001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=15
	result = 15;

	return result
end

-- 技能施法范围 
cls_sk99001.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk99001.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk99001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"jn_xuli", }

cls_sk99001.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk99001.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk99001.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=3000
	result = 3000;

	return result
end

-- 施法音效 
cls_sk99001.get_effect_music = function(self)
	return "BT_CHAIN_CASTING";
end


-- 开火音效 
cls_sk99001.get_fire_music = function(self)
	return "BT_CHAIN_SHOT";
end


-- 受击音效 
cls_sk99001.get_hit_music = function(self)
	return "BT_CHAIN_HIT";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[链弹]
local sk99001_pre_action_liandan_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[链弹]
local sk99001_select_cnt_liandan_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[链弹]
local sk99001_unselect_status_liandan_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[链弹]
local sk99001_status_time_liandan_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[链弹]
local sk99001_status_break_liandan_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[链弹]
local sk99001_status_rate_liandan_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[链弹]
local sk99001_calc_status_liandan_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:关联技能="sk99002"
	tbResult.BossSkill = "sk99002";
	-- 公式原文:场景技能长度=400
	tbResult.BossSkill_Length = 400;
	-- 公式原文:场景技能宽度=200
	tbResult.BossSkill_Width = 200;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99001_calc_status_liandan_0, 
		["effect_name"]="liuxingchui02", 
		["effect_time"]=1, 
		["effect_type"]="particle_launch", 
		["pre_action"]=sk99001_pre_action_liandan_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk99001_select_cnt_liandan_0, 
		["sort_method"]="", 
		["status"]="liandan", 
		["status_break"]=sk99001_status_break_liandan_0, 
		["status_rate"]=sk99001_status_rate_liandan_0, 
		["status_time"]=sk99001_status_time_liandan_0, 
		["unselect_status"]=sk99001_unselect_status_liandan_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------