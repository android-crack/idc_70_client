
local FrameView = class("FrameView", function(rect)
    if not rect then rect = CCRect(0, 0, 0, 0) end
    local node = display.newClippingRegionNode(rect)
    node:registerNodeEvent()
    require("framework.api.EventProtocol").extend(node)
    return node
end)

FrameView.DIRECTION_VERTICAL   = 1
FrameView.DIRECTION_HORIZONTAL = 2

function FrameView:ctor(rect,showCell, direction)
	
	self.speedOff = 10
    self.dragThreshold = 10
    self.bouncThreshold = 140
    self.defaultAnimateTime = 0.6
    self.defaultAnimateEasing = "backOut"

	self.showCell = showCell or 1
    self.direction = direction or FrameView.DIRECTION_HORIZONTAL
    self.touchRect = rect
	self.rect = rect
    self.offsetX = 0
    self.offsetY = 0
    self.cells = {}
    self.currentIndex = 0

    self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    self.view = display.newLayer()
    self:addChild(self.view)

    self.view:addTouchEventListener(function(event, x, y)
        return self:onTouch(event, x, y)
    end, false, 0, true)
end

function FrameView:getCurrentCell()
    if self.currentIndex > 0 then
        return self.cells[self.currentIndex]
    else
        return nil
    end
end

function FrameView:getCellByIndex(index)
	if index > 0 then 
		return self.cells[index]
	else
		return nil
	end
end

function FrameView:getCurrentIndex()
    return self.currentIndex
end

function FrameView:setCurrentIndex(index)
    self:scrollToCell(index)
end

function FrameView:addCell(cell)
    self.view:addChild(cell)
    self.cells[#self.cells + 1] = cell
    self:reorderAllCells()
end

function FrameView:insertCellAtIndex(cell, index)
    self.view:addChild(cell)
    table.insert(self.cells, index, cell)
    self:reorderAllCells()
end

function FrameView:removeCellAtIndex(index)
    local cell = self.cells[index]
    cell:removeSelf()
    table.remove(self.cells, index)
    self:reorderAllCells()
end

function FrameView:removeAllCell()
    local count = #self.cells
    if count == 0 then return end
    repeat 
        self:removeCellAtIndex(count)
        count  = count - 1
    until count == 0
end

function FrameView:getTouchRect()
    return self.touchRect
end

function FrameView:setTouchRect(rect)
    self.touchRect = rect
end

function FrameView:scrollToCell(index, animated, time, easing)
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
        if self.direction == FrameView.DIRECTION_HORIZONTAL then
            offset = offset - size.width
        else
            offset = offset + size.height
        end
    end

    self:setContentOffset(offset, animated, time, easing)
end

function FrameView:scrollToCellAdd()
	local count = #self.cells - self.showCell + 1 
	local index = self:getCurrentIndex() + 1
	if index > count then return end
	self:scrollToCell(index, true)
end

function FrameView:scrollToCellSub()
	local index = self:getCurrentIndex() - 1
	if index < 1 then return end
	self:scrollToCell(index, true)
end

function FrameView:isTouchEnabled()
    return self.view:isTouchEnabled()
end

function FrameView:setTouchEnabled(enabled)
	if not tolua.isnull(self.view) then
		self.view:setTouchEnabled(enabled)
	end
end

function FrameView:getCellByPos(x,y)  
	local curcell = self:getCurrentCell()
	local cellSize = curcell:getContentSize()
	local index = 1
	if self.direction == FrameView.DIRECTION_HORIZONTAL then	
		--print(x, cellSize.width)
		index = math.floor(x/cellSize.width)+self:getCurrentIndex()
	else
		index = math.floor(math.abs(self.rect:getMaxY()-y)/cellSize.height)+self:getCurrentIndex()
	end	
	if index < 1 then 
		index = 1
	elseif index > #self.cells then 
		--index = #self.cells
		return 
	end
	return self:getCellByIndex(index)
end

function FrameView:onTouchBegan(x, y)
--	cclog("------------frame touch ")
    self.drag = {
        currentOffsetX = self.offsetX,
        currentOffsetY = self.offsetY,
        startX = x,
        startY = y,
        isTap = true,
    }
	
	if self.showCell == 1 then
		self.curCell = self:getCurrentCell()
	else --多个cell
		self.curCell = self:getCellByPos(x-self:getPositionX(), y-self:getPositionY())
	end
    if tolua.isnull(self.curCell) then return false end

	self.curCell:onTouch("began", x, y)
	self.startPoint = {x=x, y=y}
	self.speed = 0
    return true
end

function FrameView:onTouchMoved(x, y)
	self.speed = 0
    if self.direction == FrameView.DIRECTION_HORIZONTAL then
        if self.drag.isTap and math.abs(x - self.drag.startX) >= self.dragThreshold then
            self.drag.isTap = false
            --self.curCell:onTouch("cancelled", x, y)
        end

        if not self.drag.isTap then--拖拉
			if self.startPoint.x - x > self.speedOff then
				self.speed = 1
			elseif self.startPoint.x -x < -self.speedOff then
				self.speed = -1
			end
            self:setContentOffset(x - self.drag.startX + self.drag.currentOffsetX)
        else  --点击
            --self.curCell:onTouch("moved", x, y)
        end
    else
        if self.drag.isTap and math.abs(y - self.drag.startY) >= self.dragThreshold then
            self.drag.isTap = false
            --self.curCell:onTouch("cancelled", x, y)
        end

        if not self.drag.isTap then
            self:setContentOffset(y - self.drag.startY + self.drag.currentOffsetY)
        else
           --self.curCell:onTouch("moved", x, y)
        end
    end
	
	self.startPoint={x=x, y=y}
end

function FrameView:onTouchEnded(x, y)
    if self.drag.isTap then
        self:onTouchEndedWithTap(x, y)
    else
        self:onTouchEndedWithoutTap(x, y)
    end
    self.drag = nil
end

function FrameView:onTouchEndedWithTap(x, y) --点击,非拖动 子类可以重写实现其他效果
--    self.curCell:onTouch("ended", x, y)
--	self.curCell:onTap(x, y)
	
end

function FrameView:onTouchEndedWithoutTap(x, y)
    --self.curCell:onTouch("cancelled", x, y)
	error("FrameView:onTouchEndedWithoutTap() - inherited class must override this method")
end

function FrameView:onTouchCancelled(x, y)
    self.drag = nil
end

function FrameView:onTouch(event, x, y)
    if self.currentIndex < 1 then return end

    if event == "began" then
        if not self.touchRect:containsPoint(ccp(x, y)) then return false end
        return self:onTouchBegan(x, y)
    elseif event == "moved" then
        self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    else -- cancelled
        self:onTouchCancelled(x, y)
    end
end

function FrameView:reorderAllCells()
    local count = #self.cells
    local x, y = 0, 0
	if self.direction ~= FrameView.DIRECTION_HORIZONTAL then
		y = self.rect:getMaxY()
	end
	--x = self.rect:getMinX()
    local maxWidth, maxHeight = 0, 0
    for i = 1, count do
        local cell = self.cells[i]
 
        cell:setPosition(x, y)
        if self.direction == FrameView.DIRECTION_HORIZONTAL then
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
    if self.direction == FrameView.DIRECTION_HORIZONTAL then
        size = CCSize(x, maxHeight)
    else
        size = CCSize(maxWidth, math.abs(y))
    end
    self.view:setContentSize(size)
end

function FrameView:setContentOffset(offset, animated, time, easing)
    local ox, oy = self.offsetX, self.offsetY
    local x, y = ox, oy
    if self.direction == FrameView.DIRECTION_HORIZONTAL then
        self.offsetX = offset
        x = offset

        local maxX = self.bouncThreshold
        local minX = -self.view:getContentSize().width - self.bouncThreshold + self.touchRect.size.width
        if x > maxX then
            x = maxX
        elseif x < minX then
            x = minX
        end
    else
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

function FrameView:onExit()
    self:removeAllEventListeners()
	self = nil
end

return FrameView
