----------------------- Auto Genrate Begin --------------------


local ClsOtherSkillBase = require("game_config/otherSkill/OtherSkillBase")
local ClsSk1083 = class("sk1083", ClsOtherSkillBase);

-- 技能名：贸易
function ClsSk1083:formula(skill_data, sailor_data, lv)
    local tbResult = {};
	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;

	-- 公式原文:几率=(航海士品质-1)*4+技能等级*1
	tbResult.rate = (sailor_star-1)*4+lv*1;

    return tbResult;
end

-- 获取技能的描述
function ClsSk1083:get_skill_desc(skill_data, sailor_data, lv)
    	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;


    -- 描述：[sk1082]有${几率}%几率使商品卖出价格额外提高30%。
    -- 公式：几率=(航海士品质-1)*4+技能等级*1
	local base_desc = string.format(T("%0.1f%%几率提高商品卖出价格50%%。"), ((sailor_star-1)*4+lv*1));
	local child_desc = string.format(T("有%0.1f%%几率使商品卖出价格额外提高30%%。"), ((sailor_star-1)*4+lv*1));
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc};
end

-- 获取技能的描述
function ClsSk1083:get_skill_color_desc(skill_data, sailor_data, lv)
    	-- 航海士品质 （1~6代表E~S）
	local sailor_star = sailor_data.star;


	local base_desc = string.format(T("$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)几率提高商品卖出价格50%%。"), ((sailor_star-1)*4+lv*1))
	local child_desc = string.format(T("有$(c:COLOR_GREEN)%0.1f%%$(c:COLOR_CAMEL)几率使商品卖出价格额外提高30%%。"), ((sailor_star-1)*4+lv*1))
	return {["base_desc"] = base_desc, ["child_desc"] = child_desc}
end

-- 获取精简版技能描述
function ClsSk1083:get_skill_short_desc()
	return T("交易所买卖时，几率提高商品卖出价格")
end

return ClsSk1083

----------------------- Auto Genrate End   --------------------
