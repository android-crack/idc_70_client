--
-- Author: Your Name
-- Date: 2015-08-17 17:34:12
--
local SwitchViewCell = require("ui/tools/SwitchViewCell")
local ClsDynSwitchViewCell  = class("ClsDynSwitchViewCell", SwitchViewCell)

function ClsDynSwitchViewCell:ctor( size, data, select_call_back)
	self.size = size
	self.data = data
	self.select_call_back = select_call_back
end

function ClsDynSwitchViewCell:mkUi(index)
	self.index = index
end

function ClsDynSwitchViewCell:resetIndex(index)
	self.index = index
end

function ClsDynSwitchViewCell:select(index)
	if self.select_call_back ~= nil then
        self:select_call_back()
    end
end

function ClsDynSwitchViewCell:unSelect(index)
	
end

function ClsDynSwitchViewCell:setSelectCallBack(callBackFunc)
	self.select_call_back = callBackFunc
end

function ClsDynSwitchViewCell:mkItem(index)
	if tolua.isnull(self) then return end
	if not tolua.isnull(self.layer) then return end
    self.layer = display.newLayer()
    self:addChild(self.layer)
	self:mkUi(index)
end

function ClsDynSwitchViewCell:setTapCallFunc(func)
	self.tapFunc = func
end

function ClsDynSwitchViewCell:onTap(x, y)
	if self.tapFunc then
		self:tapFunc(x, y)
	end
end

function ClsDynSwitchViewCell:onLongTap(x,y)  --长按
	if self.longTabFunc then
		self:longTabFunc(x, y)
	else
		if self.tapFunc then
			self:tapFunc(x, y)
		end
	end
end

function ClsDynSwitchViewCell:setLongTabCallFunc(func)
	self.longTabFunc = func
end

function ClsDynSwitchViewCell:delItem()
	if tolua.isnull(self) then return end
	if tolua.isnull(self.layer) then return end
	self.layer:removeFromParentAndCleanup(true)
    self.layer = nil
end

function ClsDynSwitchViewCell:setNotAcceptClickEvent(enable)
	self.not_accept_click_event = enable
end

function ClsDynSwitchViewCell:getNotAcceptClickEvent()
	return self.not_accept_click_event
end

return ClsDynSwitchViewCell