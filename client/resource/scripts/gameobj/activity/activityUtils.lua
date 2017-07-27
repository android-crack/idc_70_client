--
-- Author: JaylinZh
-- Date: 2016-09-26 11:46:36
--
local ui_word = require("scripts/game_config/ui_word")
local ActivityUtils = {}
local WEEK_DAY = 7
--获取活动的对应周期字符串
function ActivityUtils:getActivityCycleStr(cycle,time,all_time)
	if cycle == 0 then
		return string.format(ui_word.ACTIVITY_TIME_STR,time,all_time) --"%d/%d次"
	else
		local str = ""
		if cycle >= WEEK_DAY then
			str = ui_word.ACTIVITY_CYCLE_DAY --"每%s周%d/%d次"
			cycle = math.ceil(cycle / WEEK_DAY)
		else
			str = ui_word.ACTIVITY_CYCLE_WEEK --"每%s天%d/%d次"
		end

		local cycle_str = ""
		if cycle == 1 then
			cycle_str = ""
		else
			cycle_str = cycle..""
		end

		return string.format(str,cycle_str,time,all_time)
	end
end

return ActivityUtils