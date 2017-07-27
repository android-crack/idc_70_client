local ScrollViewCell = require("ui.tools.ScrollViewCell")
local ListCell = class("ListCell", ScrollViewCell)

function ListCell:ctor(size, node)
	ListCell.super.ctor(size)
	self.tapFunc = nil
	self.unTapFunc = nil
	if node == nil then return end

	self.node = node
	self:addChild(node)
end

function ListCell:changeState()
	if self.stateChangeEventFunc then 
		self.stateChangeEventFunc()
	end
end

function ListCell:stateChangeEvent(func)
	self.stateChangeEventFunc = func
end

function ListCell:setTapFunc(func)
	if func == nil then return end
	self.tapFunc = func
end

function ListCell:setUnTapFunc(func)
	if func == nil then return end
	self.unTapFunc = func
end

function ListCell:setMoveFunc(func)
	if func == nil then return end
	self.moveFunc = func
end

function ListCell:onTap(x, y)
	if self.tapFunc ~= nil then 
		self.tapFunc(x, y, self)
	end
end

function ListCell:onUnTap(x, y)
	if self.unTapFunc ~= nil then 
		self.unTapFunc(x, y, self)
	end
end

function ListCell:onTouchMoved(x, y)
	--cclog("ScrollViewCell onTouchMoved")
	if self.moveFunc~=nil then
		self.moveFunc(x, y, self)
	end
end 

function ListCell:onTouchEnded(x, y)
	if self.node then 
		if self.node.onTouch then
			return self.node:onTouch("ended", x, y)
		end
	end
end

function ListCell:setTouchBeginFunc(func)
	if func == nil then return end
	self.touchBegin = func
end

function ListCell:onTouchBegan(x, y)
	if self.touchBegin ~= nil then
		self.touchBegin(x, y, self)
	end
end


function ListCell:setTouchCancelFunc(func)
	if func == nil then return end
	self.touchCancel = func
end

function ListCell:onTouchCancelled(x, y)
	if self.touchCancel ~= nil then
		self.touchCancel(x, y, self)
	end
end


return ListCell