--
-- Author: Ltian
-- Date: 2016-12-11 19:59:06
--
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsPortPowerChangeEffetQuene = class("ClsPortPowerChangeEffetQuene", ClsQueneBase)


--数据初始化
function ClsPortPowerChangeEffetQuene:ctor(data)
	self.data = data
end

--这个方法要重写
function ClsPortPowerChangeEffetQuene:getQueneType()
	return self:getDialogType().port_power_change_effect
end


--这个方法要重写
function ClsPortPowerChangeEffetQuene:excTask()
	self.data.callback = function ( )
		self:TaskEnd()
	end
	local is_ok = getUIManager():create("gameobj/port/clsPortPowerChangeEffect", nil, self.data)--创建
	if not is_ok then
		self:TaskEnd()
	end
end

return ClsPortPowerChangeEffetQuene
