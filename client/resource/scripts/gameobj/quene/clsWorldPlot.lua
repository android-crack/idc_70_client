--
-- Author: Ltian
-- Date: 2016-11-11 17:32:03
--
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local Alert = require("ui/tools/alert")
local ClsWorldPlot = class("ClsWorldPlot", ClsQueneBase)
--数据初始化
function ClsWorldPlot:ctor(data)
	self.data = data
end

--这个方法要重写
function ClsWorldPlot:getQueneType()
	return self:getDialogType().mission
end


--这个方法要重写
function ClsWorldPlot:excTask()

	 Alert:showAttention(tostring(self.data), function()
	 	self:TaskEnd()
			        end, nil, function() self:TaskEnd() end, nil, true)	

end

return ClsWorldPlot