
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local Alert = require("ui/tools/alert")
local clsBattlePower = class("clsBattlePower", ClsQueneBase)
--数据初始化
function clsBattlePower:ctor(data)
	self.data = data
end

function clsBattlePower:getQueneType()
	return self:getDialogType().battle_power
end

function clsBattlePower:excTask()
	Alert:showZhanDouLiEffect(self.data.newPower, self.data.oldPower, nil, function() self:TaskEnd() end)
end

return clsBattlePower