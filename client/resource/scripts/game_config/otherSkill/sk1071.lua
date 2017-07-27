----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1071 = class("sk1071", ClsOtherSkillBase);

-- 技能名：寻宝专家
function ClsSk1071:formula(skill_data, sailor_data, lv)
    local tbResult = {};

	-- 公式原文:几率=技能等级*6
	tbResult.rate = lv*6;

    return tbResult;
end

-- 获取技能的描述
function ClsSk1071:get_skill_desc(skill_data, sailor_data, lv)
    

    -- 描述：打捞宝箱有${几率}%几率收益翻倍。
    -- 公式：几率=技能等级*6
	local base_desc = string.format(T("打捞宝箱有%0.1f%%几率收益翻倍。"), (lv*6));
	local child_desc = "";
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1071:get_skill_color_desc(skill_data, sailor_data, lv)
    

	local base_desc = string.format(T("$(c:COLOR_CAMEL)打捞宝箱有$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)几率收益翻倍。"), (lv*6))
	local child_desc = ""
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1071:get_skill_short_desc()
	return T("打捞海上的宝箱有一定几率使收益翻倍")
end

return ClsSk1071

----------------------- Auto Genrate End   --------------------
