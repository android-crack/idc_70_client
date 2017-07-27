----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1105 = class("sk1105", ClsOtherSkillBase);

-- 技能名：赏金猎人
function ClsSk1105:formula(skill_data, sailor_data, lv)
    local tbResult = {};
	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;

	-- 公式原文:几率=(航海士品质-1)*3+技能等级
	tbResult.rate = (sailor_star-1)*3+lv;

    return tbResult;
end

-- 获取技能的描述
function ClsSk1105:get_skill_desc(skill_data, sailor_data, lv)
    	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;


    -- 描述：[sk1102]悬赏任务刷新时，${几率}%几率刷新出B级悬赏任务
    -- 公式：几率=(航海士品质-1)*3+技能等级
	local base_desc = string.format(T("完成悬赏任务，获得商会声望值增加%0.1f%%。"), ((sailor_star-1)*10+lv*4));
	local child_desc = string.format(T("悬赏任务刷新时，%0.1f%%几率刷新出B级悬赏任务"), ((sailor_star-1)*3+lv));
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1105:get_skill_color_desc(skill_data, sailor_data, lv)
    	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;


	local base_desc = string.format(T("$(c:COLOR_CAMEL)完成悬赏任务，获得商会声望值增加$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)。"), ((sailor_star-1)*10+lv*4))
	local child_desc = string.format(T("悬赏任务刷新时，$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)几率刷新出B级悬赏任务"), ((sailor_star-1)*3+lv))
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1105:get_skill_short_desc()
	return T("悬赏任务刷新时，几率刷出B级悬赏任务")
end

return ClsSk1105

----------------------- Auto Genrate End   --------------------
