----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk15003 = class("cls_sk15003", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk15003.get_skill_id = function(self)
	return "sk15003";
end


-- 技能名 
cls_sk15003.get_skill_name = function(self)
	return T("船体加固（抉择）");
end

-- 精简版技能描述 
cls_sk15003.get_skill_short_desc = function(self)
	return T("每秒给射程内所有我方恢复耐久，持续6秒。");
end

-- 获取技能的描述
cls_sk15003.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("每秒给射程内所有我方单位恢复施法者耐久上限%0.1f%%的耐久，持续6秒。"), (2+0.2*lv))
end

-- 获取技能的富文本描述
cls_sk15003.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)每秒给射程内所有我方单位恢复施法者耐久上限$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的耐久，持续6秒。"), (2+0.2*lv))
end

-- 公共CD 
cls_sk15003.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk15003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=2
	result = 2;

	return result
end

-- 技能触发概率
cls_sk15003.get_skill_rate = function(self, attacker)
	local result
	
	-- 公式原文:结果=100
	result = 100;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk15003.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk15003.get_select_scope = function(self)
	return "FRIEND";
end


-- 最大施法限制距离
cls_sk15003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk15003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法音效 
cls_sk15003.get_effect_music = function(self)
	return "BT_REINFORCE_1";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血]
local sk15003_pre_action_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血]
local sk15003_select_cnt_add_hp_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加血]
local sk15003_unselect_status_add_hp_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[加血]
local sk15003_status_time_add_hp_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=6+2*取整(sk15003_SkillLv/sk15003_MAX_SkillLv)
	result = 6+2*math.floor(attacker:getSkillLv("sk15003")/attacker:getSkillLv("sk15003_MAX"));

	return result
end

-- 状态心跳[加血]
local sk15003_status_break_add_hp_0 = function(attacker, lv)
	return 
1
end

-- 命中率公式[加血]
local sk15003_status_rate_add_hp_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[加血]
local sk15003_calc_status_add_hp_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=A耐久上限*(0.02+0.002*技能等级)
	tbResult.add_hp = iAHpLimit*(0.02+0.002*lv);

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk15003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk15003_calc_status_add_hp_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk15003_pre_action_add_hp_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk15003_select_cnt_add_hp_0, 
		["sort_method"]="", 
		["status"]="add_hp", 
		["status_break"]=sk15003_status_break_add_hp_0, 
		["status_rate"]=sk15003_status_rate_add_hp_0, 
		["status_time"]=sk15003_status_time_add_hp_0, 
		["unselect_status"]=sk15003_unselect_status_add_hp_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
