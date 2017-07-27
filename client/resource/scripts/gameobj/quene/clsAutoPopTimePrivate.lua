
local ClsAutoPopTimePrivate = class("ClsAutoPopTimePrivate", require("gameobj/quene/clsQueneBase"))

function ClsAutoPopTimePrivate:ctor(data)
	self.data = data
end

function ClsAutoPopTimePrivate:getQueneType()
	return self:getDialogType().time_priate_finish_pop
end

function ClsAutoPopTimePrivate:excTask()
	getUIManager():create("gameobj/timePirate/clsTimePirateRewardView", nil, self.data, function() self:TaskEnd() end)
end

return ClsAutoPopTimePrivate