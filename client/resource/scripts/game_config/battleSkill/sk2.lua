----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk2 = class("cls_sk2", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk2.get_skill_id = function(self)
	return "sk2";
end


-- 技能名 
cls_sk2.get_skill_name = function(self)
	return T("普通远程");
end

-- 获取技能的描述
cls_sk2.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk2.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk2.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk2._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=2
	result = 2;

	return result
end

-- 施法方状态限制 
local status_limit = {"stun", }

cls_sk2.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk2.get_select_scope = function(self)
	return "ENEMY";
end


-- 最小施法限制距离
cls_sk2.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk2.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- attacker的攻击距离，不能设置，需要申明
	local iAAttRange = attacker:getFarRange();

	-- 公式原文:结果=A远程攻击距离
	result = iAAttRange;

	return result
end

-- SP消耗公式
cls_sk2.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前触发 
local skill_active_status = {"pugongbaoji", }

cls_sk2.get_skill_active_status = function(self)
	return skill_active_status
end

-- 受击特效预加载 
cls_sk2.get_preload_hit_effect = function(self)
	return "tx_shoujisuipian01";
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[远程攻击]
local sk2_pre_action_far_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[远程攻击]
local sk2_select_cnt_far_attack_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[远程攻击]
local sk2_unselect_status_far_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[远程攻击]
local sk2_status_time_far_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[远程攻击]
local sk2_status_break_far_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[远程攻击]
local sk2_status_rate_far_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[远程攻击]
local sk2_calc_status_far_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:受击特效="tx_shoujisuipian01"
	tbResult.hit_effect = "tx_shoujisuipian01";
	-- 公式原文:扣血=基础远程伤害
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttFar())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk2.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk2_calc_status_far_attack_0, 
		["effect_name"]="attack_yellow", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk2_pre_action_far_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk2_select_cnt_far_attack_0, 
		["sort_method"]="", 
		["status"]="far_attack", 
		["status_break"]=sk2_status_break_far_attack_0, 
		["status_rate"]=sk2_status_rate_far_attack_0, 
		["status_time"]=sk2_status_time_far_attack_0, 
		["unselect_status"]=sk2_unselect_status_far_attack_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk2.get_skill_type = function(self)
	return "auto"
end

-- 技能cd
cls_sk2.get_skill_cd = function(self, attacker)
	local fire_rate = attacker:getFireRate()
	local cd = self:_get_skill_cd()*(1 - fire_rate/1000.0)

	if cd < 0 then 
		return 0
	end
	
	return cd
end

local affect_cnt_status = {"far_attack_select_cnt_add", "far_attack_select_cnt_add_2"}

-- 目标数量
cls_sk2.select_cnt = function(self, attacker, status)
	local cnt = 1
	if status then
		cnt = status.select_cnt(attacker, lv)
	end

	for k, v in ipairs(affect_cnt_status) do
		local buff_obj = attacker:hasBuff(v)
		if buff_obj then cnt = cnt + buff_obj.tbResult.far_att_cnt end
	end

	return cnt
end

local boat_info = require("game_config/boat/boat_info")
local skill_effect_util = require("module/battleAttrs/skill_effect_util")
-- 技能施放特效显示
cls_sk2.skill_effect = function(self, attacker, target, status_idx)
	local all_status = self:get_add_status()
	local status = all_status[status_idx]
	local eff_name = status.effect_name
	local eff_type = status.effect_type
	local eff_time = status.effect_time
	
	local skill_id = self:get_skill_id()
	-- 获取对应的特效显示函数
	local func = skill_effect_util.effect_funcs[eff_type]

	local callback = self.end_display_call_back

	if attacker and boat_info[attacker.ship_id] and boat_info[attacker.ship_id].fire_res_2 then
		eff_name = boat_info[attacker.ship_id].fire_res_2
	end

	if func and eff_name and eff_name ~= "" then
		func({id = eff_name, owner = attacker, target = target, attacker = attacker, callback = callback, 
            skill_id = skill_id, duration = eff_time, ext_args = status_idx})
	else
		self:end_display_call_back(attacker, target, status_idx)
	end
end

cls_sk2.end_display_call_back = function(self, attacker, target, idx, dir, is_bullet)
	self.super.end_display_call_back(self, attacker, target, idx)
end
