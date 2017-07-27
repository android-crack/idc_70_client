----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk50002 = class("cls_sk50002", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk50002.get_skill_id = function(self)
	return "sk50002";
end


-- 技能名 
cls_sk50002.get_skill_name = function(self)
	return T("远程船普通攻击");
end

-- 获取技能的描述
cls_sk50002.get_skill_desc = function(self, skill_data, lv)
    

    -- 描述：普通远程伤害提升${50+技能等级*10}%
    -- 公式：船只伤害加成=500+100*技能等级
	local base_desc = string.format(T("普通远程伤害提升%s%%"), (math.floor(50+lv*10)));
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 公共CD 
cls_sk50002.get_common_cd = function(self)
	return 0;
end


-- 技能CD 
cls_sk50002._get_skill_cd = function(self)
    return 99999;
end


-- SP消耗公式
cls_sk50002.calc_sp_cost = function(self, attacker, lv)
	local result;

	-- 公式原文:结果=0
	result = 0;

	return result;
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 目标选择基础数量[船只伤害]
local sk50002_select_cnt_boat_dam_0
sk50002_select_cnt_boat_dam_0 = function(attacker, lv)
	return 
1;
end

-- 目标选择忽视状态[船只伤害]
local sk50002_unselect_status_boat_dam_0
sk50002_unselect_status_boat_dam_0 = function(attacker, lv)
	return {"seal", "die", };
end

-- 状态持续时间[船只伤害]
local sk50002_status_time_boat_dam_0
sk50002_status_time_boat_dam_0 = function(attacker, lv)
	return 
666666;
end

-- 状态持续时间[船只伤害]
local sk50002_status_break_boat_dam_0
sk50002_status_break_boat_dam_0 = function(attacker, lv)
	return 
0;
end

-- 命中率公式[船只伤害]
local sk50002_status_rate_boat_dam_0
sk50002_status_rate_boat_dam_0 = function(attacker, target, lv, tbParam)
	local result;

	-- 公式原文:结果=1000
	result = 1000;

	return result;
end

-- 处理过程[船只伤害]
local sk50002_calc_status_boat_dam_0
sk50002_calc_status_boat_dam_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {};

	-- 公式原文:船只伤害加成=500+100*技能等级
	tbResult.cz_damage_rate = 500+100*lv;

	return tbResult;
end


-- 操作区

-- 添加状态数据
cls_sk50002.get_add_status = function(self)
	return {
    {
        ["calc_status"]=sk50002_calc_status_boat_dam_0, 
        ["effect_name"]="", 
        ["effect_time"]="", 
        ["effect_type"]="", 
        ["scope"]="SELF", 
        ["select_cnt"]=sk50002_select_cnt_boat_dam_0, 
        ["sort_method"]="", 
        ["status"]="boat_dam", 
        ["status_break"]=sk50002_status_break_boat_dam_0, 
        ["status_rate"]=sk50002_status_rate_boat_dam_0, 
        ["status_time"]=sk50002_status_time_boat_dam_0, 
        ["unselect_status"]=sk50002_unselect_status_boat_dam_0, 
    }, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
