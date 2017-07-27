----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1070 = class("sk1070", ClsOtherSkillBase);

-- 技能名：打捞
function ClsSk1070:formula(skill_data, sailor_data, lv)
    local tbResult = {};

    return tbResult;
end

-- 获取技能的描述
function ClsSk1070:get_skill_desc(skill_data, sailor_data, lv)
    

    -- 描述：解锁打捞技能
    -- 公式：
	local base_desc = T("解锁打捞技能");
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1070:get_skill_color_desc(skill_data, sailor_data, lv)
    

	local base_desc = T("$(c:COLOR_CAMEL)解锁打捞技能")
	local child_desc = ""
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1070:get_skill_short_desc()
	return T("解锁打捞技能")
end

return ClsSk1070

----------------------- Auto Genrate End   --------------------
