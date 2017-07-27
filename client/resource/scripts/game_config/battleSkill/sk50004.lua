----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk50004 = class("cls_sk50004", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk50004.get_skill_id = function(self)
	return "sk50004";
end


-- 技能名 
cls_sk50004.get_skill_name = function(self)
	return T("近战船回复");
end

-- 获取技能的描述
cls_sk50004.get_skill_desc = function(self, skill_data, lv)
    

    -- 描述：每6秒自动给自己舰队内耐久最低的船只恢复气血。
    -- 公式：加血=A耐久上限*(0.075+0.015*技能等级)
	local base_desc = T("每6秒自动给自己舰队内耐久最低的船只恢复气血。");
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 公共CD 
cls_sk50004.get_common_cd = function(self)
	return 0;
end


-- 技能CD 
cls_sk50004._get_skill_cd = function(self)
    return 6;
end


-- 最大施法限制距离
cls_sk50004.get_limit_distance_max = function(self, attacker, lv)
	local result;

	-- 公式原文:结果=999999999
	result = 999999999;

	return result;
end

-- SP消耗公式
cls_sk50004.calc_sp_cost = function(self, attacker, lv)
	local result;

	-- 公式原文:结果=0
	result = 0;

	return result;
end

-- 施法清除状态 
cls_sk50004.get_skill_clear_status = function(self)
	return {"yinshen", };
end

-- 施法前特效名称 
cls_sk50004.get_before_effect_name = function(self)
	return "jn_xuli";
end


-- 施法前特效类型 
cls_sk50004.get_before_effect_type = function(self)
	return "particle_local";
end


-- 施法前特效时间 
cls_sk50004.get_before_effect_time = function(self)
	return 1500;
end


-- 施法音效 
cls_sk50004.get_effect_music = function(self)
	return "BT_SORTIE";
end


---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 目标选择基础数量[加血_2]
local sk50004_select_cnt_add_hp_2_0
sk50004_select_cnt_add_hp_2_0 = function(attacker, lv)
	return 
1;
end

-- 目标选择忽视状态[加血_2]
local sk50004_unselect_status_add_hp_2_0
sk50004_unselect_status_add_hp_2_0 = function(attacker, lv)
	return {"seal", "die", };
end

-- 状态持续时间[加血_2]
local sk50004_status_time_add_hp_2_0
sk50004_status_time_add_hp_2_0 = function(attacker, lv)
	return 
0;
end

-- 状态持续时间[加血_2]
local sk50004_status_break_add_hp_2_0
sk50004_status_break_add_hp_2_0 = function(attacker, lv)
	return 
0;
end

-- 命中率公式[加血_2]
local sk50004_status_rate_add_hp_2_0
sk50004_status_rate_add_hp_2_0 = function(attacker, target, lv, tbParam)
	local result;

	-- 公式原文:结果=1000
	result = 1000;

	return result;
end

-- 处理过程[加血_2]
local sk50004_calc_status_add_hp_2_0
sk50004_calc_status_add_hp_2_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {};
	-- 
	local iAHpLimit = attacker:getMaxHp();

	-- 公式原文:加血=A耐久上限*(0.075+0.015*技能等级)
	tbResult.add_hp = iAHpLimit*(0.075+0.015*lv);

	return tbResult;
end


-- 操作区

-- 添加状态数据
cls_sk50004.get_add_status = function(self)
	return {
    {
        ["calc_status"]=sk50004_calc_status_add_hp_2_0, 
        ["effect_name"]="", 
        ["effect_time"]="", 
        ["effect_type"]="", 
        ["scope"]="ALL_FRIEND", 
        ["select_cnt"]=sk50004_select_cnt_add_hp_2_0, 
        ["sort_method"]="HP", 
        ["status"]="add_hp_2", 
        ["status_break"]=sk50004_status_break_add_hp_2_0, 
        ["status_rate"]=sk50004_status_rate_add_hp_2_0, 
        ["status_time"]=sk50004_status_time_add_hp_2_0, 
        ["unselect_status"]=sk50004_unselect_status_add_hp_2_0, 
    }, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
