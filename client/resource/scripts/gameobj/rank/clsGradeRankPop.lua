local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local ClsCommonMenuPop = require("gameobj/rank/clsCommonMenuPop")
local ClsGradeRankPop = class("ClsGradeRankPop", ClsCommonMenuPop)

ClsGradeRankPop.getViewConfig = function(self)
	return {
		is_swallow = false,
	}
end

ClsGradeRankPop.checkGradeRank = function(self, params)
	local user_grade = getGameData():getPlayerData():getLevel()
	local min_grade, max_grade = params[1], params[2]
	if user_grade >= min_grade and user_grade <= max_grade then

	else
		ClsAlert:warning({msg = ui_word.STR_OUT_GRADE_RANK_TIP})
	end
end

local widget_tab = {
	[1] = {name = "btn_21", event = ClsGradeRankPop.checkGradeRank, event_params = {21, 30}},
	[2] = {name = "btn_31", event = ClsGradeRankPop.checkGradeRank, event_params = {31, 40}},
	[3] = {name = "btn_41", event = ClsGradeRankPop.checkGradeRank, event_params = {41, 50}},
	[4] = {name = "btn_51", event = ClsGradeRankPop.checkGradeRank, event_params = {51, 70}},
}

ClsGradeRankPop.onEnter = function(self, close_call_back)
	local params = {
		json_path = "json/rank_prestige_btn_2.json",
		widget_info = widget_tab,
		call_back = close_call_back,
	}

	ClsGradeRankPop.super.onEnter(self, params)
end

return ClsGradeRankPop