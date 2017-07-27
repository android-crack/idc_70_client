----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk22002 = class("cls_sk22002", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk22002.get_skill_id = function(self)
	return "sk22002";
end


-- 技能名 
cls_sk22002.get_skill_name = function(self)
	return T("钩索（熟练）");
end

-- 精简版技能描述 
cls_sk22002.get_skill_short_desc = function(self)
	return T("抛出钩锁，对射程内单体敌方造成近战伤害，将其拉至身边。");
end

-- 获取技能的描述
cls_sk22002.get_skill_desc = function(self, skill_data, lv)
	return string.format(T("抛出钩索，对射程内单体敌方造成%0.1f%%近战伤害，并将其拉至身边。"), (150+lv*10))
end

-- 获取技能的富文本描述
cls_sk22002.get_skill_color_desc = function(self, skill_data, lv)
	return string.format(T("$(c:COLOR_CAMEL)抛出钩索，对射程内单体敌方造成$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)近战伤害，并将其拉至身边。"), (150+lv*10))
end

-- 公共CD 
cls_sk22002.get_common_cd = function(self)
	return 3;
end


-- 技能CD
cls_sk22002._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=2
	result = 2;

	return result
end

-- 技能触发概率
cls_sk22002.get_skill_rate = function(self, attacker)
	local result
	
	-- 公式原文:结果=200
	result = 200;

	return result
end

-- 施法方状态限制 
local status_limit = {"silence", "stun", }

cls_sk22002.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk22002.get_select_scope = function(self)
	return "ENEMY";
end


-- 最大施法限制距离
cls_sk22002.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk22002.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 受击音效 
cls_sk22002.get_hit_music = function(self)
	return "BT_HOOK_HIT";
end


-- 受击特效预加载 
cls_sk22002.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[钩锁]
local sk22002_pre_action_gousuo_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:位移=-1*MIN(T距离*0.8,300)
	tbResult.translate = -1*math.min(GetDistanceFor3D(attacker.body.node, target.body.node)*0.8,300);

	return tbResult
end

-- 目标选择基础数量[钩锁]
local sk22002_select_cnt_gousuo_0 = function(attacker, lv)
	local result
	
	-- 公式原文:结果=1+1*取整(sk22002_SkillLv/sk22002_MAX_SkillLv)
	result = 1+1*math.floor(attacker:getSkillLv("sk22002")/attacker:getSkillLv("sk22002_MAX"));

	return result
end

-- 目标选择忽视状态[钩锁]
local sk22002_unselect_status_gousuo_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[钩锁]
local sk22002_status_time_gousuo_0 = function(attacker, lv)
	return 
1/2
end

-- 状态心跳[钩锁]
local sk22002_status_break_gousuo_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[钩锁]
local sk22002_status_rate_gousuo_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[钩锁]
local sk22002_calc_status_gousuo_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=基础近战伤害*(1.5+技能等级*0.1)
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4*(1.5+lv*0.1);
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk22002.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk22002_calc_status_gousuo_0, 
		["effect_name"]="gousuo", 
		["effect_time"]=0, 
		["effect_type"]="gousuo", 
		["pre_action"]=sk22002_pre_action_gousuo_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk22002_select_cnt_gousuo_0, 
		["sort_method"]="", 
		["status"]="gousuo", 
		["status_break"]=sk22002_status_break_gousuo_0, 
		["status_rate"]=sk22002_status_rate_gousuo_0, 
		["status_time"]=sk22002_status_time_gousuo_0, 
		["unselect_status"]=sk22002_unselect_status_gousuo_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
local skill_effect_util = require("module/battleAttrs/skill_effect_util")
cls_sk22002.skill_effect = function(self, attacker, target, status_idx)
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