local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsChapterMissionPop = class("ClsChapterMissionPop", ClsQueneBase)

function ClsChapterMissionPop:ctor(data)
	self.data = data
end

function ClsChapterMissionPop:getQueneType()
	return self:getDialogType().chapter_mission_plot
end

function ClsChapterMissionPop:excTask()
	local mission_info = getMissionInfo()
	local mid = self.data.id
	local call_back = function()
		self:TaskEnd()
	end
	getUIManager():create("gameobj/mission/clsChapterMissionUI", nil, mission_info[mid], call_back)
end

return ClsChapterMissionPop

