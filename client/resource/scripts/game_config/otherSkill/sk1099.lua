----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1099 = class("sk1099", ClsOtherSkillBase);

-- 技能名：回报
function ClsSk1099:formula(skill_data, sailor_data, lv)
    local tbResult = {};
	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;

	-- 公式原文:增加百分比=(航海士品质-1)*5+技能等级*2
	tbResult.rate = (sailor_star-1)*5+lv*2;

    return tbResult;
end

-- 获取技能的描述
function ClsSk1099:get_skill_desc(skill_data, sailor_data, lv)
    	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;


    -- 描述：[sk1098]完成商会多人任务后，有20%几率航海士经验增加${增加百分比}%。
    -- 公式：增加百分比=(航海士品质-1)*5+技能等级*2
	local base_desc = string.format(T("航海士海上航行获得经验增加%0.1f%%。"), ((sailor_star-1)*10+lv*4));
	local child_desc = string.format(T("完成商会多人任务后，有20%%几率航海士经验增加%0.1f%%。"), ((sailor_star-1)*5+lv*2));
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1099:get_skill_color_desc(skill_data, sailor_data, lv)
    	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;


	local base_desc = string.format(T("$(c:COLOR_CAMEL)航海士海上航行获得经验增加$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), ((sailor_star-1)*10+lv*4))
	local child_desc = string.format(T("完成商会多人任务后，有20%%几率航海士经验增加$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), ((sailor_star-1)*5+lv*2))
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1099:get_skill_short_desc()
	return T("海上航行时，以及完成商会任务时，航海士获得的经验值增加")
end

return ClsSk1099

----------------------- Auto Genrate End   --------------------
