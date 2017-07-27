----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk41003 = class("cls_sk41003", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk41003.get_skill_id = function(self)
	return "sk41003";
end


-- 技能名 
cls_sk41003.get_skill_name = function(self)
	return T("怒发冲冠");
end

-- 精简版技能描述 
cls_sk41003.get_skill_short_desc = function(self)
	return T("全体我方每秒恢复怒气，受击时额外恢复。");
end

-- 获取技能的描述
cls_sk41003.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("全体我方每6秒恢复%0.1f点怒气，且受到攻击时怒气额外恢复2点。"), (3+lv*2))
end

-- 获取技能的富文本描述
cls_sk41003.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)全体我方每6秒恢复$(c:COLOR_GREEN)%0.1f$(c:COLOR_CAMEL)点怒气，且受到攻击时怒气额外恢复2点。"), (3+lv*2))
end

-- 公共CD 
cls_sk41003.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk41003._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=66666
	result = 66666;

	return result
end

-- 最小施法限制距离
cls_sk41003.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk41003.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=99999999
	result = 99999999;

	return result
end

-- SP消耗公式
cls_sk41003.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[鼓舞士气]
local sk41003_pre_action_guwushiqi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[鼓舞士气]
local sk41003_select_cnt_guwushiqi_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[鼓舞士气]
local sk41003_unselect_status_guwushiqi_0 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[鼓舞士气]
local sk41003_status_time_guwushiqi_0 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[鼓舞士气]
local sk41003_status_break_guwushiqi_0 = function(attacker, lv)
	return 
6
end

-- 命中率公式[鼓舞士气]
local sk41003_status_rate_guwushiqi_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=2000
	result = 2000;

	return result
end

-- 处理过程[鼓舞士气]
local sk41003_calc_status_guwushiqi_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:鼓舞士气触发技能="sk90007a"
	tbResult.gwsq_skill_id = "sk90007a";

	return tbResult
end

-- 前置动作[怒发冲冠]
local sk41003_pre_action_nufachongguan_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[怒发冲冠]
local sk41003_select_cnt_nufachongguan_1 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[怒发冲冠]
local sk41003_unselect_status_nufachongguan_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[怒发冲冠]
local sk41003_status_time_nufachongguan_1 = function(attacker, lv)
	return 
666666
end

-- 状态心跳[怒发冲冠]
local sk41003_status_break_nufachongguan_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[怒发冲冠]
local sk41003_status_rate_nufachongguan_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[怒发冲冠]
local sk41003_calc_status_nufachongguan_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk41003.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk41003_calc_status_guwushiqi_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk41003_pre_action_guwushiqi_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk41003_select_cnt_guwushiqi_0, 
		["sort_method"]="", 
		["status"]="guwushiqi", 
		["status_break"]=sk41003_status_break_guwushiqi_0, 
		["status_rate"]=sk41003_status_rate_guwushiqi_0, 
		["status_time"]=sk41003_status_time_guwushiqi_0, 
		["unselect_status"]=sk41003_unselect_status_guwushiqi_0, 
	}, 
	{
		["calc_status"]=sk41003_calc_status_nufachongguan_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk41003_pre_action_nufachongguan_1, 
		["scope"]="FRIEND", 
		["select_cnt"]=sk41003_select_cnt_nufachongguan_1, 
		["sort_method"]="DISTANCE_ASEC", 
		["status"]="nufachongguan", 
		["status_break"]=sk41003_status_break_nufachongguan_1, 
		["status_rate"]=sk41003_status_rate_nufachongguan_1, 
		["status_time"]=sk41003_status_time_nufachongguan_1, 
		["unselect_status"]=sk41003_unselect_status_nufachongguan_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
