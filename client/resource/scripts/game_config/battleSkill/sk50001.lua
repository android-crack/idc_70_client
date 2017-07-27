----------------------- Auto Genrate Begin --------------------

-- 定义技能继承类型

local clsSkillAura = require("module/battleAttrs/skill_aura")

cls_sk50001 = class("cls_sk50001", clsSkillAura);


-- 属性段
---------------------------------------------------------------

-- 技能ID 
cls_sk50001.get_skill_id = function(self)
	return "sk50001";
end


-- 技能名 
cls_sk50001.get_skill_name = function(self)
	return T("远程船加怒");
end

-- 获取技能的描述
cls_sk50001.get_skill_desc = function(self, skill_data, lv)
    

    -- 描述：每6秒给全体船只增加${加怒}点怒气
    -- 公式：加怒=10+2*技能等级
	local base_desc = string.format(T("每6秒给全体船只增加%s点怒气"), (math.floor(10+2*lv)));
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 公共CD 
cls_sk50001.get_common_cd = function(self)
	return 0;
end


-- 技能CD 
cls_sk50001._get_skill_cd = function(self)
    return 6;
end


-- SP消耗公式
cls_sk50001.calc_sp_cost = function(self, attacker, lv)
	local result;

	-- 公式原文:结果=0
	result = 0;

	return result;
end

---------------------------------------------------------------

-- 添加Buff区
-- 状态结算用的函数



-- 目标选择基础数量[加怒]
local sk50001_select_cnt_jia_nu_0
sk50001_select_cnt_jia_nu_0 = function(attacker, lv)
	return 
999;
end

-- 目标选择忽视状态[加怒]
local sk50001_unselect_status_jia_nu_0
sk50001_unselect_status_jia_nu_0 = function(attacker, lv)
	return {"seal", "die", };
end

-- 状态持续时间[加怒]
local sk50001_status_time_jia_nu_0
sk50001_status_time_jia_nu_0 = function(attacker, lv)
	return 
0;
end

-- 状态持续时间[加怒]
local sk50001_status_break_jia_nu_0
sk50001_status_break_jia_nu_0 = function(attacker, lv)
	return 
0;
end

-- 命中率公式[加怒]
local sk50001_status_rate_jia_nu_0
sk50001_status_rate_jia_nu_0 = function(attacker, target, lv, tbParam)
	local result;

	-- 公式原文:结果=1000
	result = 1000;

	return result;
end

-- 处理过程[加怒]
local sk50001_calc_status_jia_nu_0
sk50001_calc_status_jia_nu_0 = function(attacker, target, lv, objStatus, tbParam)
	local tbResult = {};

	-- 公式原文:加怒=10+2*技能等级
	tbResult.add_sp = 10+2*lv;

	return tbResult;
end


-- 操作区

-- 添加状态数据
cls_sk50001.get_add_status = function(self)
	return {
    {
        ["calc_status"]=sk50001_calc_status_jia_nu_0, 
        ["effect_name"]="", 
        ["effect_time"]="", 
        ["effect_type"]="", 
        ["scope"]="FRIEND", 
        ["select_cnt"]=sk50001_select_cnt_jia_nu_0, 
        ["sort_method"]="", 
        ["status"]="jia_nu", 
        ["status_break"]=sk50001_status_break_jia_nu_0, 
        ["status_rate"]=sk50001_status_rate_jia_nu_0, 
        ["status_time"]=sk50001_status_time_jia_nu_0, 
        ["unselect_status"]=sk50001_unselect_status_jia_nu_0, 
    }, 
}
end

---------------------------------------------------------------


----------------------- Auto Genrate End   --------------------
