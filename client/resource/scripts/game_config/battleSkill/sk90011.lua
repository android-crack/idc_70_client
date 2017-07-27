----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk90011 = class("cls_sk90011", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk90011.get_skill_id = function(self)
	return "sk90011";
end


-- 技能名 
cls_sk90011.get_skill_name = function(self)
	return T("步步为营释放倍击2");
end

-- 获取技能的描述
cls_sk90011.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk90011.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 最小施法限制距离
cls_sk90011.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk90011.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[加血_2]
local sk90011_pre_action_add_hp_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[加血_2]
local sk90011_select_cnt_add_hp_2_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[加血_2]
local sk90011_unselect_status_add_hp_2_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[加血_2]
local sk90011_status_time_add_hp_2_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[加血_2]
local sk90011_status_break_add_hp_2_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[加血_2]
local sk90011_status_rate_add_hp_2_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[加血_2]
local sk90011_calc_status_add_hp_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
		-- 
	local iAHpLimit = attacker:getMaxHp();
	-- 
	local iTHpLimit = target:getMaxHp();
	-- 
	local iTRemainHP = target:getHp();

	-- 公式原文:加血=((1.5+技能等级*0.5)*A耐久上限*0.01)*(1+0.5*取整((T耐久上限-T剩余耐久)*2/T耐久上限))
	tbResult.add_hp = ((1.5+lv*0.5)*iAHpLimit*0.01)*(1+0.5*math.floor((iTHpLimit-iTRemainHP)*2/iTHpLimit));

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk90011.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk90011_calc_status_add_hp_2_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk90011_pre_action_add_hp_2_0, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk90011_select_cnt_add_hp_2_0, 
		["sort_method"]="", 
		["status"]="add_hp_2", 
		["status_break"]=sk90011_status_break_add_hp_2_0, 
		["status_rate"]=sk90011_status_rate_add_hp_2_0, 
		["status_time"]=sk90011_status_time_add_hp_2_0, 
		["unselect_status"]=sk90011_unselect_status_add_hp_2_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
cls_sk90011.get_skill_type = function(self)
    return "auto"
end

cls_sk90011.get_skill_lv = function(self, attacker)
	return cls_sk42004:get_skill_lv( attacker )
end
