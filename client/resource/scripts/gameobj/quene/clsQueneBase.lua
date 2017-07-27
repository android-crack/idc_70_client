--
-- Author: Ltian
-- Date: 2016-11-11 12:00:16
--
local ClsDialogQuene = require("gameobj/quene/clsDialogQuene")
local ClsQueneBase = class("ClsQueneBase")
--数据初始化
function ClsQueneBase:ctor(...)
	-- body
end

--返回队列的类型
function ClsQueneBase:getQueneType()
	return ""
end


--这个方法要重写---逻辑都写在这里记得调用 self:TaskEnd()
function ClsQueneBase:excTask()
	print("---------这是个测试----------")
	self:TaskEnd()

end

---------------------------------------------------------------

function ClsQueneBase:getDialogType()
	return ClsDialogQuene:getDialogType()
end

--队列结束的回调，在excTask()方法执行的逻辑结束后调用（不是代码最后），不要去重写
function ClsQueneBase:TaskEnd()
	print("----------这个队列结束了---------", self:getQueneType())
	ClsDialogQuene:excNextTask()
end


return ClsQueneBase