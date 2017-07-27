
local clsAutoPopWelfare = class("clsAutoPopWelfare", require("gameobj/quene/clsQueneBase"))

function clsAutoPopWelfare:ctor(data)
	self.data = data
end

function clsAutoPopWelfare:getQueneType()
	return self:getDialogType().auto_pop_welfare
end

function clsAutoPopWelfare:excTask()
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		getUIManager():create("gameobj/welfare/clsWelfareMain",nil,8,function()
		    self:TaskEnd()
		end, true)
	else
		self:TaskEnd()
	end
end

return clsAutoPopWelfare