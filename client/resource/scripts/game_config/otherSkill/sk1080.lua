----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1080 = class("sk1080", ClsOtherSkillBase);

-- 技能名：收获
function ClsSk1080:formula(skill_data, sailor_data, lv)
    local tbResult = {};

	-- 公式原文:几率=技能等级*6
	tbResult.rate = lv*6;

    return tbResult;
end

-- 获取技能的描述
function ClsSk1080:get_skill_desc(skill_data, sailor_data, lv)
    

    -- 描述：成功捕猎后，有${几率}%几率获得双倍经验书。
    -- 公式：几率=技能等级*6
	local base_desc = string.format(T("成功捕猎后，有%0.1f%%几率获得双倍经验书。"), (lv*6));
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1080:get_skill_color_desc(skill_data, sailor_data, lv)
    

	local base_desc = string.format(T("$(c:COLOR_CAMEL)成功捕猎鲨鱼海怪后，有$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)几率获得双倍经验书。"), (lv*6))
	local child_desc = ""
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1080:get_skill_short_desc()
	return T("捕捞鲨鱼海兽时获得的航海士经验书数量有一定几率翻倍")
end

return ClsSk1080

----------------------- Auto Genrate End   --------------------
