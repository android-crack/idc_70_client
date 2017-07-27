
local ListTapView = class("ListTapView", function(rect)
   	return CCLayer:create()
end)

function ListTapView:ctor(rect, cells, touchPriority)    
	self.rect = rect
    self.cells = cells
 
    self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    self:setContentSize(rect.size)
    self:setPosition(rect.origin.x, rect.origin.y)
    self:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y)
    end, false, 0, true)
    self:reorderAllCells()
end

function ListTapView:onTouchBegan(x, y)
	local curCell = self:itemForTouch(x, y)
	if not tolua.isnull(curCell) then 
		curCell:onTap(x, y)
		return true
	else
		return false
	end
end

function ListTapView:itemForTouch(x, y)
	if tolua.isnull(self) then
		return
	end
	local pos = self:convertToNodeSpace(ccp(x, y))
	local children = self:getChildren()
	if children:count() > 0 then
		for i = 0, children:count() - 1 do
			local pChild = children:objectAtIndex(i)
			if not tolua.isnull(pChild) then
				local size = pChild:getContentSize()
				local pChildX, pChildY = pChild:getPosition()
				local anChorPoint = pChild:getAnchorPoint()
				local touchRect = CCRectMake( pChildX - size.width * anChorPoint.x, pChildY - size.height * anChorPoint.y,
                      size.width, size.height)
				if touchRect:containsPoint(ccp(pos.x, pos.y)) then
					return pChild
				end
			end
		end
	end
end


function ListTapView:onTouchMoved(x, y)
	
end

function ListTapView:onTouchEnded(x, y)
   
end

function ListTapView:onTouch(event, x, y)
	local pos = self:getParent():convertToNodeSpace(ccp(x, y))
    if event == "began" then
        if not self.rect:containsPoint(ccp(pos.x, pos.y)) then return false end
        return self:onTouchBegan(x, y)
    elseif event == "moved" then
        self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    else -- cancelled
        self:onTouchCancelled(x, y)
    end
end

function ListTapView:reorderAllCells()
    local count = #self.cells
    local x, y = 0, 0
    y = self.rect.size.height
    for i = 1, count do
        local cell = self.cells[i]
        cell:setAnchorPoint(ccp(0, 1))
        cell:setPosition(x, y)
        local height = cell:getContentSize().height
        y = y - height
        cell.index = i
        self:addChild(cell)
    end
end

function ListTapView:onExit()
    --self:removeAllEventListeners()
	self = nil
end

function ListTapView:onEnter()
    
end

return ListTapView
