----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1078 = class("sk1078", ClsOtherSkillBase);

-- 技能名：捕猎
function ClsSk1078:formula(skill_data, sailor_data, lv)
    local tbResult = {};

    return tbResult;
end

-- 获取技能的描述
function ClsSk1078:get_skill_desc(skill_data, sailor_data, lv)
    

    -- 描述：解锁捕猎技能
    -- 公式：
	local base_desc = T("解锁捕猎技能");
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1078:get_skill_color_desc(skill_data, sailor_data, lv)
    

	local base_desc = T("$(c:COLOR_CAMEL)解锁捕猎技能")
	local child_desc = ""
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1078:get_skill_short_desc()
	return T("解锁捕猎技能")
end

return ClsSk1078

----------------------- Auto Genrate End   --------------------
