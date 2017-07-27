local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local clsLoginAwardUIQuene = class("clsLoginAwardUIQuene", ClsQueneBase)

function clsLoginAwardUIQuene:ctor(data)
	self.data = data
end

function clsLoginAwardUIQuene:getQueneType()
	return self:getDialogType().loginAwardUI
end

function clsLoginAwardUIQuene:excTask()
	local MainAwardUI = getUIManager():get("MainAwardUI")
	if tolua.isnull(MainAwardUI) then
		local port_layer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(port_layer) then
			getUIManager():create("gameobj/welfare/clsLoginAwardUI",function()
				self.data.func()
			end)
		end
	else
		self:TaskEnd()
	end
end

return clsLoginAwardUIQuene