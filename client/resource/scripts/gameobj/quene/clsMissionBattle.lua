local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsMissionBattle = class("ClsMissionBattle", ClsQueneBase)

function ClsMissionBattle:ctor(data)
	self.data = data
end

function ClsMissionBattle:getQueneType()
	return self:getDialogType().mission_battle
end

function ClsMissionBattle:excTask()
	local func = self.data.func
	if type(func) == "function" then
		func()
		self:TaskEnd()
	end
end

return ClsMissionBattle

