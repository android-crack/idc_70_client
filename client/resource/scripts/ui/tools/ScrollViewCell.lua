
local ScrollViewCell = class("ScrollViewCell", function(contentSize)
    local node = display.newNode()
    if contentSize then node:setContentSize(contentSize) end
    node:registerNodeEvent()
    require("framework.api.EventProtocol").extend(node)
    return node
end)

function ScrollViewCell:onTouch(event, x, y)
	if event == "began" then
        self:onTouchBegan(x, y)
    elseif event == "moved" then
        self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    else -- cancelled
        self:onTouchCancelled(x, y)
    end
end

function ScrollViewCell:onTouchBegan(x, y)
	--cclog("ScrollViewCell onTouchBegan")
end 

function ScrollViewCell:onTouchMoved(x, y)
	--cclog("ScrollViewCell onTouchMoved")
end 

function ScrollViewCell:onTouchEnded(x, y)
	--cclog("ScrollViewCell onTouchEnded")
end

function ScrollViewCell:onTouchCancelled(x, y)
	--cclog("cancell")
end 

function ScrollViewCell:onTap(x, y)
end

function ScrollViewCell:onExit()
    self:removeAllEventListeners()
end

function ScrollViewCell:setParent(parentList)
	self.parent = parentList
end

function ScrollViewCell:getParent()
	return self.parent
end

return ScrollViewCell
