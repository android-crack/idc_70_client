----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillInitiative = require("module/battleAttrs/skill_initiative")

cls_sk1 = class("cls_sk1", clsSkillInitiative);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk1.get_skill_id = function(self)
	return "sk1";
end


-- 技能名 
cls_sk1.get_skill_name = function(self)
	return T("普通近战");
end

-- 获取技能的描述
cls_sk1.get_skill_desc = function(self, skill_data, lv)
	return "nil"
end

-- 获取技能的富文本描述
cls_sk1.get_skill_color_desc = function(self, skill_data, lv)
	return "nil"
end

-- 公共CD 
cls_sk1.get_common_cd = function(self)
	return 0;
end


-- 技能CD
cls_sk1._get_skill_cd = function(self, attacker)
	local result
	
	-- 公式原文:结果=1
	result = 1;

	return result
end

-- 施法方状态限制 
local status_limit = {"stun", }

cls_sk1.get_status_limit = function(self)
	return status_limit
end

-- 技能施法范围 
cls_sk1.get_select_scope = function(self)
	return "ENEMY";
end


-- 最小施法限制距离
cls_sk1.get_limit_distance_min = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 最大施法限制距离
cls_sk1.get_limit_distance_max = function(self, attacker, lv, target)
	local result
		-- 
	local iANearRange = attacker:getNearRange();

	-- 公式原文:结果=A近战攻击距离
	result = iANearRange;

	return result
end

-- SP消耗公式
cls_sk1.calc_sp_cost = function(self, attacker, lv, target)
	local result
	
	-- 公式原文:结果=0
	result = 0;

	return result
end

-- 施法前触发 
local skill_active_status = {"yiwangwuqian", "pugongbaoji", }

cls_sk1.get_skill_active_status = function(self)
	return skill_active_status
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 前置动作[近战攻击]
local sk1_pre_action_near_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[近战攻击]
local sk1_select_cnt_near_attack_0 = function(attacker, lv)
	return 
999
end

-- 目标选择忽视状态[近战攻击]
local sk1_unselect_status_near_attack_0 = function(attacker, lv)
	return {"seal", "die", }
end

-- 状态持续时间[近战攻击]
local sk1_status_time_near_attack_0 = function(attacker, lv)
	return 
0
end

-- 状态心跳[近战攻击]
local sk1_status_break_near_attack_0 = function(attacker, lv)
	return 
0
end

-- 命中率公式[近战攻击]
local sk1_status_rate_near_attack_0 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=950
	result = 950;

	return result
end

-- 处理过程[近战攻击]
local sk1_calc_status_near_attack_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	-- 公式原文:扣血=基础近战伤害
	tbResult.sub_hp = (200*math.pow(1.06,(attacker:getLevel()-1)))*math.min(5,math.max(math.pow((attacker:getAttNear())/(max(target:getDefense(),1)),1),1/5))*(1+attacker:getDamageInc()/1000-target:getDamageDec()/1000)/4;
	-- 公式原文:近战伤害标示=1
	tbResult.is_near_attack = 1;

	return tbResult
end

-- 前置动作[刀砍特效]
local sk1_pre_action_cut_effect_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end

-- 目标选择基础数量[刀砍特效]
local sk1_select_cnt_cut_effect_1 = function(attacker, lv)
	return 
end

-- 目标选择忽视状态[刀砍特效]
local sk1_unselect_status_cut_effect_1 = function(attacker, lv)
	return {"", }
end

-- 状态持续时间[刀砍特效]
local sk1_status_time_cut_effect_1 = function(attacker, lv)
	return 
1
end

-- 状态心跳[刀砍特效]
local sk1_status_break_cut_effect_1 = function(attacker, lv)
	return 
0
end

-- 命中率公式[刀砍特效]
local sk1_status_rate_cut_effect_1 = function(attacker, target, lv, tbParam)
	local result
	
	-- 公式原文:结果=1000
	result = 1000;

	return result
end

-- 处理过程[刀砍特效]
local sk1_calc_status_cut_effect_1 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {}
	
	return tbResult
end


-- 操作区

-- 添加状态数据
cls_sk1.get_add_status = function(self)
		return {
	{
		["calc_status"]=sk1_calc_status_near_attack_0, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1_pre_action_near_attack_0, 
		["scope"]="ENEMY", 
		["select_cnt"]=sk1_select_cnt_near_attack_0, 
		["sort_method"]="", 
		["status"]="near_attack", 
		["status_break"]=sk1_status_break_near_attack_0, 
		["status_rate"]=sk1_status_rate_near_attack_0, 
		["status_time"]=sk1_status_time_near_attack_0, 
		["unselect_status"]=sk1_unselect_status_near_attack_0, 
	}, 
	{
		["calc_status"]=sk1_calc_status_cut_effect_1, 
		["effect_name"]="", 
		["effect_time"]=0, 
		["effect_type"]="", 
		["pre_action"]=sk1_pre_action_cut_effect_1, 
		["scope"]="LAST_TARGET", 
		["select_cnt"]=sk1_select_cnt_cut_effect_1, 
		["sort_method"]="", 
		["status"]="cut_effect", 
		["status_break"]=sk1_status_break_cut_effect_1, 
		["status_rate"]=sk1_status_rate_cut_effect_1, 
		["status_time"]=sk1_status_time_cut_effect_1, 
		["unselect_status"]=sk1_unselect_status_cut_effect_1, 
	}, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
local music_info = require("game_config/music_info")
local play_random_skill_near_sound
play_random_skill_near_sound = function(sound, id, uid)
	if sound ~= nil and sound ~= "" then
		local sounds = {}
		local fire_sound = string.format("%s_%d", sound, 1)
		if string.format("%s_%d", sound, 1) ~= preSound then
		   sounds[#sounds + 1] = fire_sound
		end
		
		local fire2_sound = string.format("%s_%d", sound, 2)
		if string.format("%s_%d", sound, 2) ~= preSound then
			sounds[#sounds + 1] = fire2_sound
		end
		
		local fire3_sound = string.format("%s_%d", sound, 3)
		if string.format("%s_%d", sound, 3) ~= preSound then
			sounds[#sounds + 1] = fire3_sound
		end
		
		local rand_sound = sounds[math.random(#sounds)]
		preSound = rand_sound
		local sound_res = music_info[rand_sound].res
		if sound_res then
			local battle_data = getGameData():getBattleDataMt()
	        local is_player = battle_data:isCurClientControlShip(id)

			audioExt.playEffect(sound_res, false, is_player)
		end
	end
end

cls_sk1.get_skill_type = function(self)
	return "auto"
end

cls_sk1.play_use_effect_music = function(self, id, uid)
	local sound = self:get_effect_music()
	play_random_skill_near_sound(sound, id, uid)
end

-- 施放目标拓展距离
cls_sk1._get_limit_distance_max = function(self, attacker, lv)
	local near_attack_range = self:get_limit_distance_max(attacker, lv)
	local buff_obj = attacker:hasBuff("near_attack_range_up")
	if buff_obj then
		near_attack_range = near_attack_range + buff_obj.tbResult.add_near_att_range
	end
	return near_attack_range
end
