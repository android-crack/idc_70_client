local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsExplorePlotDialogQuene = class("ClsExplorePlotDialogQuene", ClsQueneBase)

function ClsExplorePlotDialogQuene:ctor(data)
	self.data = data
end

function ClsExplorePlotDialogQuene:getQueneType()
	return self:getDialogType().explorePlot
end

function ClsExplorePlotDialogQuene:excTask()
	
	self.data.call_back = function()
		if self.data and self.data.callBack ~= nil then
			self.data.callBack()
		end
		self:TaskEnd()
	end
	local view_ui = EventTrigger(EVENT_EXPLORE_PLOT_DIALOG, self.data)
	if tolua.isnull(view_ui) then self:TaskEnd() end
end

return ClsExplorePlotDialogQuene