----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk23001 = class("cls_sk23001", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk23001.get_skill_id = function(self)
	return "sk23001";
end


-- 技能名 
cls_sk23001.get_skill_name = function(self)
	return T("援助（自爆舰）");
end

-- 精简版技能描述 
cls_sk23001.get_skill_short_desc = function(self)
	return T("召唤一艘持续12秒的自爆舰协助战斗。");
end

-- 获取技能的描述
cls_sk23001.get_skill_desc = function(self, skill_data, lv)
	return T("召唤一艘持续12秒，拥有自爆技能的自爆舰协助战斗。")
end

-- 获取技能的富文本描述
cls_sk23001.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)召唤一艘持续12秒拥有自爆技能的舰船，对靠近的敌方造成施法者耐久$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)的伤害。"), (50*(1+lv*0.1)*0.4))
end

-- 公共CD 
cls_sk23001.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk23001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=2
	result = 2;

	return result
end

-- 技能触发概率
cls_sk23001.get_skill_rate = function(self, attacker)
	local result
	
	-- 公式原文:结果=100+5*取整(sk23001_SkillLv/sk23001_MAX_SkillLv)
	result = 100+5*math.floor(attacker:getSkillLv("sk23001")/attacker:getSkillLv("sk23001_MAX"));

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk23001.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk23001.get_select_scope = function(self)
	return "SELF";
end


-- SP消耗公式
cls_sk23001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[分身_2]
local sk23001_pre_action_fenshen_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[分身_2]
local sk23001_select_cnt_fenshen_2_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[分身_2]
local sk23001_unselect_status_fenshen_2_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[分身_2]
local sk23001_status_time_fenshen_2_0 = function(attacker, lv)
	return 
15
end

-- 状态心跳[分身_2]
local sk23001_status_break_fenshen_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[分身_2]
local sk23001_status_rate_fenshen_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[分身_2]
local sk23001_calc_status_fenshen_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:分身强度=0.5*(1+0.1*技能等级)*1000
	tbResult.fenshen_strength = 0.5*(1+0.1*lv)*1000;
	-- 公式原文:分身数量=1
	tbResult.fenshen_cnt = 1;
	-- 公式原文:分身造型=26
	tbResult.fenshen_ship_id = 26;
	-- 公式原文: 分身技能1 = "1906"
	tbResult.fenshen_skill_1 =  "1906";

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk23001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk23001_calc_status_fenshen_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk23001_pre_action_fenshen_2_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk23001_select_cnt_fenshen_2_0, 
		["sort_method"]="", 
		["status"]="fenshen_2", 
		["status_break"]=sk23001_status_break_fenshen_2_0, 
		["status_rate"]=sk23001_status_rate_fenshen_2_0, 
		["status_time"]=sk23001_status_time_fenshen_2_0, 
		["unselect_status"]=sk23001_unselect_status_fenshen_2_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk23001.end_display_call_back = function(self, attacker, target, idx, dir, is_bullet)
	local battle_data = getGameData():getBattleDataMt()
	dir = battle_data:fenshenPosition(attacker)

	self.super.end_display_call_back(self, attacker, target, idx, dir, is_bullet)
end