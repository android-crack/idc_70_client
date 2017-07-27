----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1124 = class("sk1124", ClsOtherSkillBase);

-- 技能名：一劳永逸
function ClsSk1124:formula(skill_data, sailor_data, lv)
    local tbResult = {};

	-- 公式原文:几率=技能等级*8
	tbResult.rate = lv*8;

    return tbResult;
end

-- 获取技能的描述
function ClsSk1124:get_skill_desc(skill_data, sailor_data, lv)
    

    -- 描述：每次攻击有${几率}%几率直接清除。
    -- 公式：几率=技能等级*8
	local base_desc = string.format(T("每次攻击有%0.1f%%几率直接清除。"), (lv*8));
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1124:get_skill_color_desc(skill_data, sailor_data, lv)
    

	local base_desc = string.format(T("$(c:COLOR_CAMEL)每次攻击礁石浮冰有$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)几率直接清除。"), (lv*8))
	local child_desc = ""
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1124:get_skill_short_desc()
	return T("攻击海上的浮冰和礁石时，有几率直接清除目标")
end

return ClsSk1124

----------------------- Auto Genrate End   --------------------
