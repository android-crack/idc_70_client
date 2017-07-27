----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1073 = class("sk1073", ClsOtherSkillBase);

-- 技能名：向导
function ClsSk1073:formula(skill_data, sailor_data, lv)
    local tbResult = {};

	-- 公式原文:几率=技能等级*4
	tbResult.rate = lv*4;

    return tbResult;
end

-- 获取技能的描述
function ClsSk1073:get_skill_desc(skill_data, sailor_data, lv)
    

    -- 描述：探索副本内，打捞沉船有${几率}%几率收益翻倍。
    -- 公式：几率=技能等级*4
	local base_desc = string.format(T("探索副本内，打捞沉船有%0.1f%%几率收益翻倍。"), (lv*4));
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1073:get_skill_color_desc(skill_data, sailor_data, lv)
    

	local base_desc = string.format(T("$(c:COLOR_CAMEL)藏宝海湾内，打捞沉船有$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)几率获得额外钻石。"), (lv*4))
	local child_desc = ""
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1073:get_skill_short_desc()
	return T("打捞藏宝海湾里的沉船有一定几率获得额外钻石")
end

return ClsSk1073

----------------------- Auto Genrate End   --------------------
