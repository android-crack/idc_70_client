----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk99006 = class("cls_sk99006", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk99006.get_skill_id = function(self)
	return "sk99006";
end


-- 技能名 
cls_sk99006.get_skill_name = function(self)
	return T("海怪近战普通攻击");
end

-- 获取技能的描述
cls_sk99006.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk99006.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk99006.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk99006._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=5/2
	result = 5/2;

	return result
end

-- 施法方状态限制 
local status_limit = {"stun", }

cls_sk99006.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk99006.get_select_scope = function(self)
	return "ENEMY";
end


-- 最小施法限制距离
cls_sk99006.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk99006.get_limit_distance_max = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=600
	result = 600;

	return result
end

-- SP消耗公式
cls_sk99006.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前触发 
local skill_active_status = {"kuaisuzhuangtian", "yumou", }

cls_sk99006.get_skill_active_status = function(self)
	return skill_active_status
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[近战攻击]
local sk99006_pre_action_near_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[近战攻击]
local sk99006_select_cnt_near_attack_0 = function(attacker, lv)
	return 
1
end

-- 目标选择忽视状态[近战攻击]
local sk99006_unselect_status_near_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[近战攻击]
local sk99006_status_time_near_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[近战攻击]
local sk99006_status_break_near_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[近战攻击]
local sk99006_status_rate_near_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[近战攻击]
local sk99006_calc_status_near_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础近战伤害
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4;

	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk99006.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk99006_calc_status_near_attack_0, 
		["effect_name"]="haiguai_fire", 
		["effect_time"]=0, 
		["effect_type"]="proj", 
		["pre_action"]=sk99006_pre_action_near_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk99006_select_cnt_near_attack_0, 
		["sort_method"]="", 
		["status"]="near_attack", 
		["status_break"]=sk99006_status_break_near_attack_0, 
		["status_rate"]=sk99006_status_rate_near_attack_0, 
		["status_time"]=sk99006_status_time_near_attack_0, 
		["unselect_status"]=sk99006_unselect_status_near_attack_0, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------

cls_sk99006.use_effect_display = function(self, attacker, targets, callback)
	self.super.use_effect_display(self, attacker, targets, callback)

	local sea_krakan = 32  -- 菊花怪
	if not attacker.is_ship and attacker.baseData.prop_id == sea_krakan then
		attacker:getBody():playAnimation("twine01", false)

		local ac_1 = CCDelayTime:create(self:_get_skill_cd() - 0.1)
		local ac_2 = CCCallFunc:create(function()
			if attacker and not attacker:is_deaded() and attacker:getBody() then
				attacker:getBody():playAnimation("move", true)
			end
        end)
        local running_scene = GameUtil.getRunningScene()
        running_scene:runAction(CCSequence:createWithTwoActions(ac_1, ac_2))
	end
end