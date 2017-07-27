local gamePlot = require("gameobj/mission/gamePlot")
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsMissionPlot = class("ClsMissionPlot", ClsQueneBase)

function ClsMissionPlot:ctor(data)
	self.data = data
end

function ClsMissionPlot:getQueneType()
	return self:getDialogType().mission
end

function ClsMissionPlot:excTask()
	local mission_data_handler = getGameData():getMissionData()
	local mission_info = getMissionInfo()
	local mid = self.data.id
	if type(mid) == "number" and mission_info[mid] and mission_info[mid].camp then
		mission_data_handler:setSelectMissionId(mid)
	end
	EventTrigger(EVENT_EXPLORE_PAUSE)
	gamePlot:setPausePlot(false)
	gamePlot:insertPlot({id = mid, type = self.data.type, callFunc = function()
		local call_back = getGameData():getMissionData():getMissionCompletedCallBack()
        if type(self.data.callback) == "function" then
            self.data.callback()
        end
        if type(call_back) == "function" then
            call_back()
			return
		end
		self:TaskEnd()
	end})
end

return ClsMissionPlot

