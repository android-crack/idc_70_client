
local ScrollView = class("ScrollView", function(rect)
    if not rect then rect = CCRect(0, 0, 0, 0) end
    local node = display.newClippingRegionNode(rect)
    node:registerNodeEvent()
    require("framework.api.EventProtocol").extend(node)
    return node
end)

ScrollView.DIRECTION_VERTICAL   = 1
ScrollView.DIRECTION_HORIZONTAL = 2

function ScrollView:ctor(rect, direction, showCell, touchPriority,sound)
    assert(direction == ScrollView.DIRECTION_VERTICAL or direction == ScrollView.DIRECTION_HORIZONTAL,
           "ScrollView:ctor() - invalid direction")
    
	self.m_bEnabled = true
	self.speedOff = 10
    self.dragThreshold = 10
    self.bouncThreshold = 140
    self.defaultAnimateTime = 0.6
    self.defaultAnimateEasing = "backOut"
    self.isSoundPlayed = false
 	self.showCell = showCell or 1
    self.direction = direction
    self.touchRect = rect
    self.sound = sound
	self.rect = rect
	self.touchPriority = touchPriority or 0
    self.offsetX = 0
    self.offsetY = 0
    self.cells = {}
    self.currentIndex = 0
    self.dynamicOffset = 0
    self.scrollEnable = true
    self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    self.view = display.newLayer()
    self:addChild(self.view)

    self.view:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y)
    end, false, self.touchPriority, true)
	self.view:setTouchMode(kCCTouchesOneByOne)
	
end

function ScrollView:getCurrentCell()
    if self.currentIndex > 0 then
        return self.cells[self.currentIndex]
    else
        return nil
    end
end

function ScrollView:getCellByIndex(index)
	if index > 0 then 
		return self.cells[index]
	else
		return nil
	end
end

function ScrollView:getCurrentIndex()
    return self.currentIndex
end

function ScrollView:setCurrentIndex(index, animated, time, easing)
    self:scrollToCell(index, animated, time, easing)
end

function ScrollView:addCell(cell)
	self.view:addChild(cell)
	self.cells[#self.cells + 1] = cell
	self:reorderAllCells()
	cell:setParent(self)
   -- self:dispatchEvent({name = "addCell", count = #self.cells})
end

function ScrollView:insertCellAtIndex(cell, index)
    self.view:addChild(cell)
    table.insert(self.cells, index, cell)
    self:reorderAllCells()
    --self:dispatchEvent({name = "insertCellAtIndex", index = index, count = #self.cells})
end

function ScrollView:removeCellAtIndex(index)
    local cell = self.cells[index]
    cell:removeSelf()
    table.remove(self.cells, index)
    self:reorderAllCells()
    --self:dispatchEvent({name = "removeCellAtIndex", index = index, count = #self.cells})
end

function ScrollView:removeAllCell()
    local count = #self.cells
    if count == 0 then return end
    repeat 
        self:removeCellAtIndex(count)
        count  = count - 1
    until count == 0
end

function ScrollView:setEnabled(value)
    self.m_bEnabled = value
end

function ScrollView:getView()
    return self.view
end

function ScrollView:getTouchRect()
    return self.touchRect
end

function ScrollView:setTouchRect(rect)
    self.touchRect = rect
   -- self:dispatchEvent({name = "setTouchRect", rect = rect})
end

function ScrollView:getClippingRect()
    return self:getClippingRegion()
end

function ScrollView:setClippingRect(rect)
    self:setClippingRegion(rect)
   -- self:dispatchEvent({name = "setClippingRect", rect = rect})
end

function ScrollView:scrollToCell(index, animated, time, easing)
    local count = #self.cells
    if count < 1 then
        self.currentIndex = 0
        return
    end

    if index < 1 then
        index = 1
    elseif index > count then
        index = count
    end
    self.currentIndex = index

    local offset = 0
    for i = 2, index do
        local cell = self.cells[i - 1]
        local size = cell:getContentSize()
        if self.direction == ScrollView.DIRECTION_HORIZONTAL then
            offset = offset - size.width
        else
            offset = offset + size.height
        end
    end

    self:setContentOffset(offset, animated, time, easing)
    --self:dispatchEvent({name = "scrollToCell", animated = animated, time = time, easing = easing})
end

function ScrollView:scrollToCellAdd()
	local count = #self.cells - self.showCell + 1 
	local index = self:getCurrentIndex() + 1
	if index > count then return end
	self:scrollToCell(index, true)
end

function ScrollView:scrollToCellSub()
	local index = self:getCurrentIndex() - 1
	if index < 1 then return end
	self:scrollToCell(index, true)
end

function ScrollView:isTouchEnabled()
    return self.view:isTouchEnabled()
end

function ScrollView:setTouchEnabled(enabled)
	if not tolua.isnull(self.view) then
		self.view:setTouchEnabled(enabled)
       if not enabled then
            self.drag = nil
        end 
	end
   -- self:dispatchEvent({name = "setTouchEnabled", enabled = enabled})
end

function ScrollView:getCellByPos(x,y)  
	local curcell = self:getCurrentCell()
	local cellSize = curcell:getContentSize()
	local index = 1
	if self.direction == ScrollView.DIRECTION_HORIZONTAL then	
		index = math.floor(x/cellSize.width)+self:getCurrentIndex()
	else
		index = math.floor(math.abs(self.rect:getMaxY()-y)/cellSize.height)+self:getCurrentIndex()
	end
	if index < 1 then 
		index = 1
	elseif index > #self.cells then
		return 
	end
	return self:getCellByIndex(index)
end

function ScrollView:onTouchBegan(x, y)
	if self.drag then return false end 
   
	if self.showCell == 1 then
		self.curCell = self:getCurrentCell()
	else --多个cell
		self.curCell = self:getCellByPos(x-self:getPositionX(), y-self:getPositionY())
	end
    if tolua.isnull(self.curCell) then return false end
	
	self.drag = {
        currentOffsetX = self.offsetX,
        currentOffsetY = self.offsetY,
        startX = x,
        startY = y,
        isTap = true,
    }
	
	self.curCell:onTouch("began", x, y)
	self.startPoint = {x=x, y=y}
	self.beginPoint = {x=x, y=y}
	self.speed = 0
    return true
end

function ScrollView:onTouchMoved(x, y)
    if not self.scrollEnable then return end 
    if not self.isSoundPlayed then
       audioExt.playEffect(self.sound)
    end
	self.speed = 0
    if self.direction == ScrollView.DIRECTION_HORIZONTAL then
        if self.drag.isTap and math.abs(x - self.drag.startX) >= self.dragThreshold then
            self.drag.isTap = false
            self.curCell:onTouch("cancelled", x, y)
        end

        if not self.drag.isTap then
			if self.startPoint.x - x > self.speedOff then
				self.speed = 1
			elseif self.startPoint.x -x < -self.speedOff then
				self.speed = -1
			end
            self:setContentOffset(x - self.drag.startX + self.drag.currentOffsetX)
        else
            self.curCell:onTouch("moved", x, y)
        end
    else
        if self.drag.isTap and math.abs(y - self.drag.startY) >= self.dragThreshold then
            self.drag.isTap = false
            self.curCell:onTouch("cancelled", x, y)
        end

        if not self.drag.isTap then
            self:setContentOffset(y - self.drag.startY + self.drag.currentOffsetY)
        else
           self.curCell:onTouch("moved", x, y)
        end
    end
	
	self.startPoint={x=x, y=y}
end

function ScrollView:onTouchEnded(x, y)
    if self.drag.isTap then
        self:onTouchEndedWithTap(x, y)
    else
        self:onTouchEndedWithoutTap(x, y)
    end
    self.drag = nil
end

function ScrollView:onTouchEndedWithTap(x, y) --点击，非拖动
	if self.curCell == nil then return end
    self.curCell:onTouch("ended", x, y)
	self.curCell:onTap(x, y)
end

function ScrollView:onTouchEndedWithoutTap(x, y)
    self.curCell:onTouch("cancelled", x, y)
end

function ScrollView:onTouchCancelled(x, y)
    self.drag = nil
end

function ScrollView:onTouch(event, x, y)
    if self.currentIndex < 1 then return end

    if event == "began" then
        if not self.touchRect:containsPoint(ccp(x, y)) then return false end
        if not self.m_bEnabled then return false end
        return self:onTouchBegan(x, y)
    elseif event == "moved" then
        self:onTouchMoved(x, y)
    elseif self.drag then 
        if event == "ended" then
            self:onTouchEnded(x, y)
        else
            self:onTouchCancelled(x, y)
        end
    end
end

function ScrollView:reorderAllCells()
    local count = #self.cells
    local x, y = 0, 0
	if self.direction ~= ScrollView.DIRECTION_HORIZONTAL then
		y = self.rect:getMaxY()
	end
    local maxWidth, maxHeight = 0, 0
    for i = 1, count do
        local cell = self.cells[i]
 
        cell:setPosition(x, y)
        if self.direction == ScrollView.DIRECTION_HORIZONTAL then
            local width = cell:getContentSize().width
            if width > maxWidth then maxWidth = width end
            x = x + width
        else
            local height = cell:getContentSize().height
            if height > maxHeight then maxHeight = height end
            y = y - height
        end
    end

    if count > 0 then
        if self.currentIndex < 1 then
            self.currentIndex = 1
        elseif self.currentIndex > count then
            self.currentIndex = count
        end
    else
        self.currentIndex = 0
    end

    local size
    if self.direction == ScrollView.DIRECTION_HORIZONTAL then
        size = CCSize(x, maxHeight)
    else
        size = CCSize(maxWidth, math.abs(y))
    end
    self.view:setContentSize(size)
end

function ScrollView:setContentOffset(offset, animated, time, easing)
    if tolua.isnull(self.view) then return end
    local ox, oy = self.offsetX, self.offsetY
    local x, y = ox, oy
    if self.direction == ScrollView.DIRECTION_HORIZONTAL then
		offset = offset - self.dynamicOffset
        self.offsetX = offset
        x = offset

        local maxX = self.bouncThreshold
        local minX = -self.view:getContentSize().width - self.bouncThreshold + self.touchRect.size.width
		if minX > 0 then minX = -self.bouncThreshold end
		if x > maxX then
            x = maxX
        elseif x < minX then
            x = minX
        end
    else
		offset = offset + self.dynamicOffset
        self.offsetY = offset
        y = offset
        local maxY = self.view:getContentSize().height + self.bouncThreshold - self.touchRect.size.height+self.rect:getMaxY()
        local minY = -self.bouncThreshold
        if y > maxY then
            y = maxY
        elseif y < minY then
            y = minY
        end
    end

    if animated then
        transition.stopTarget(self.view)
        transition.moveTo(self.view, {
            x = x,
            y = y,
            time = time or self.defaultAnimateTime,
            easing = easing or self.defaultAnimateEasing,
        })
    else
        self.view:setPosition(x, y)
    end
end

function ScrollView:onExit()
    self:removeAllEventListeners()
	self = nil
end

function ScrollView:setScrollEnable(enable)
    self.scrollEnable = enable
end
return ScrollView
