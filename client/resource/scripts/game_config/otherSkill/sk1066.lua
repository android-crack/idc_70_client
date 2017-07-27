----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1066 = class("sk1066", ClsOtherSkillBase);

-- 技能名：护航
function ClsSk1066:formula(skill_data, sailor_data, lv)
    local tbResult = {};

    return tbResult;
end

-- 获取技能的描述
function ClsSk1066:get_skill_desc(skill_data, sailor_data, lv)
    

    -- 描述：解锁清除障碍技能
    -- 公式：
	local base_desc = T("解锁清除障碍技能");
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1066:get_skill_color_desc(skill_data, sailor_data, lv)
    

	local base_desc = T("$(c:COLOR_CAMEL)解锁清除障碍技能")
	local child_desc = ""
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1066:get_skill_short_desc()
	return T("解锁清除障碍技能")
end

return ClsSk1066

----------------------- Auto Genrate End   --------------------
