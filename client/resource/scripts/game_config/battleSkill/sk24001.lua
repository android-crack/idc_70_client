----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk24001 = class("cls_sk24001", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk24001.get_skill_id = function(self)
	return "sk24001";
end


-- 技能名 
cls_sk24001.get_skill_name = function(self)
	return T("突击（希腊火）");
end

-- 精简版技能描述 
cls_sk24001.get_skill_short_desc = function(self)
	return T("从船周围喷射火焰，对喷射到的敌方造成大量伤害，并使其无法被治疗。");
end

-- 获取技能的描述
cls_sk24001.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("从船周围喷射火焰，每秒对喷射到的目标造成%0.1f%%伤害，并使其无法被治疗6秒，并降低攻击50%%"), (150+lv*10))
end

-- 获取技能的富文本描述
cls_sk24001.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)船周围喷射火焰，每秒对目标造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)伤害，无法被治疗，并降低攻击50%%"), (150+lv*10))
end

-- 公共CD 
cls_sk24001.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk24001._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=2
	result = 2;

	return result
end

-- 技能触发概率
cls_sk24001.get_skill_rate = function(self, attacker)
	local result
	
	-- 公式原文:结果=100
	result = 100;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk24001.get_status_limit = function(self)
	return status_limit
end

-- SP消耗公式
cls_sk24001.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前特效名称 
local before_effect_name = {"tx_skillready", }

cls_sk24001.get_before_effect_name = function(self)
	return before_effect_name
end

-- 施法前特效类型 
local before_effect_type = {"particle_local", }

cls_sk24001.get_before_effect_type = function(self)
	return before_effect_type
end

-- 施法前特效时间
cls_sk24001.get_before_effect_time = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 施法音效 
cls_sk24001.get_effect_music = function(self)
	return "BT_CHAIN_CASTING";
end


-- 受击音效 
cls_sk24001.get_hit_music = function(self)
	return "BT_SORTIE_HIT";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[希腊火_2]
local sk24001_pre_action_xilahuo_self_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[希腊火_2]
local sk24001_select_cnt_xilahuo_self_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[希腊火_2]
local sk24001_unselect_status_xilahuo_self_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[希腊火_2]
local sk24001_status_time_xilahuo_self_0 = function(attacker, lv)
	return 
6
end

-- 状态心跳[希腊火_2]
local sk24001_status_break_xilahuo_self_0 = function(attacker, lv)
	return 
1/2
end

-- 命中率公式[希腊火_2]
local sk24001_status_rate_xilahuo_self_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[希腊火_2]
local sk24001_calc_status_xilahuo_self_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:突击触发技能="sk90020"
	tbResult.tj_skill_id = "sk90020";

	return tbResult
end

-- 前置动作[通用触发技能]
local sk24001_pre_action_tongyongchufajineng_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[通用触发技能]
local sk24001_select_cnt_tongyongchufajineng_1 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[通用触发技能]
local sk24001_unselect_status_tongyongchufajineng_1 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[通用触发技能]
local sk24001_status_time_tongyongchufajineng_1 = function(attacker, lv)
	return 
0
end

-- 状态心跳[通用触发技能]
local sk24001_status_break_tongyongchufajineng_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[通用触发技能]
local sk24001_status_rate_tongyongchufajineng_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000*取整(sk24001_SkillLv/sk24001_MAX_SkillLv)
	result = 1000*math.floor(attacker:getSkillLv("sk24001")/attacker:getSkillLv("sk24001_MAX"));

	return result
end

-- 处理过程[通用触发技能]
local sk24001_calc_status_tongyongchufajineng_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:通用触发技能="sk90016"
	tbResult.ty_skill_id = "sk90016";

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk24001.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk24001_calc_status_xilahuo_self_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk24001_pre_action_xilahuo_self_0, 
		["scope"]="SELF", 
		["select_cnt"]=sk24001_select_cnt_xilahuo_self_0, 
		["sort_method"]="", 
		["status"]="xilahuo_self", 
		["status_break"]=sk24001_status_break_xilahuo_self_0, 
		["status_rate"]=sk24001_status_rate_xilahuo_self_0, 
		["status_time"]=sk24001_status_time_xilahuo_self_0, 
		["unselect_status"]=sk24001_unselect_status_xilahuo_self_0, 
	}, 
	{
		["calc_status"]=sk24001_calc_status_tongyongchufajineng_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk24001_pre_action_tongyongchufajineng_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk24001_select_cnt_tongyongchufajineng_1, 
		["sort_method"]="", 
		["status"]="tongyongchufajineng", 
		["status_break"]=sk24001_status_break_tongyongchufajineng_1, 
		["status_rate"]=sk24001_status_rate_tongyongchufajineng_1, 
		["status_time"]=sk24001_status_time_tongyongchufajineng_1, 
		["unselect_status"]=sk24001_unselect_status_tongyongchufajineng_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
local skill_effect_util = require("module/battleAttrs/skill_effect_util")
cls_sk24001.skill_effect = function(self, attacker, target, status_idx)
    local all_status = self:get_add_status()
    local status = all_status[status_idx]
    local eff_name = status.effect_name
    local eff_type = status.effect_type

    local skill_id = self:get_skill_id()
    local lv = attacker:has_skill_ex(skill_id)
    local eff_time = status.status_time(attacker, lv)

    local func = skill_effect_util.effect_funcs[eff_type]
    local callback = self.end_display_call_back
    
    if func and eff_name and eff_name ~= "" then 
        func({id = eff_name, owner = attacker, target = target, attacker = attacker, callback = callback, 
            skill_id = skill_id, duration = eff_time, ext_args = status_idx})
    else
        self:end_display_call_back(attacker, target, status_idx)
    end                                 
end