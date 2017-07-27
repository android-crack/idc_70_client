
local scheduler = CCDirector:sharedDirector():getScheduler()

local DynListView = class("DynListView", function(rect)
    if not rect then rect = CCRect(0, 0, 0, 0) end
    local node = display.newClippingRegionNode(rect)
    node:registerNodeEvent()
    require("framework.api.EventProtocol").extend(node)
    return node
end)

DynListView.DIRECTION_VERTICAL   = 1
DynListView.DIRECTION_HORIZONTAL = 2

DynListView.SCROLL_DIRECTION_VERTICAL_UP   = 1
DynListView.SCROLL_DIRECTION_VERTICAL_DOWN = 2
DynListView.SCROLL_DIRECTION_VERTICAL_LEFT = 3
DynListView.SCROLL_DIRECTION_VERTICAL_RIGHT   = 4

local TnternalClass = class("TnternalClass")
local tnternalClassTnstance = TnternalClass.new()

function DynListView:ctor(rect, direction, cells, datas, touchPriority)
    assert(direction == DynListView.DIRECTION_VERTICAL or direction == DynListView.DIRECTION_HORIZONTAL,
           "DynListView:ctor() - invalid direction")
    
	self.m_bEnabled = true

    self.dragThreshold = 10
    self.bouncThreshold = 140
    self.defaultAnimateTime = 0.6
    self.defaultAnimateEasing = "backOut"

    self.showCell = 1
    self.direction = direction
    self.touchRect = rect
	self.rect = rect
	self.touchPriority = touchPriority or 0
    self.offsetX = 0
    self.offsetY = 0
    self.cells = cells or {}
    self.cellNum = #self.cells

    self.maxCellWidth = 0
    self.maxCellHeight = 0

    self.showCellNum = 0
    self.offsetBackCellNum = 2

    self.overTopOrLeftCellPool = {}
    self.overBottomOrRightCellPool = {}

    self.datas = datas or {}
    self.dataNum = #self.datas
    self.dataBeginIndex = 1
    self.dataEndIndex = self.cellNum

    self.curScrollDirect = 0

    self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    -- create container layer
    self.view = display.newLayer()
    self:addChild(self.view)

    self.view:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y)
    end, false, self.touchPriority, true)
	self.view:setTouchMode(kCCTouchesOneByOne)
	
    local cellNum = math.min(self.dataNum, self.cellNum)
	for i = 1, cellNum do
		self.view:addChild(self.cells[i])
		self.cells[i]:setParent(self)
	end
	self:reorderAllCells()
end

function DynListView:setEnabled(value)
    self.m_bEnabled = value
end

function DynListView:getTouchRect()
    return self.touchRect
end

function DynListView:setTouchRect(rect)
    self.touchRect = rect
   -- self:dispatchEvent({name = "setTouchRect", rect = rect})
end

function DynListView:setOffsetBackCellNum(value)
    self.offsetBackCellNum = value
    if self.offsetBackCellNum < 2 then
        self.offsetBackCellNum = 2
    end
end

function DynListView:getClippingRect()
    return self:getClippingRegion()
end

function DynListView:setClippingRect(rect)
    self:setClippingRegion(rect)
   -- self:dispatchEvent({name = "setClippingRect", rect = rect})
end

function DynListView:isTouchEnabled()
    return self.view:isTouchEnabled()
end

function DynListView:setTouchEnabled(enabled)
	if not tolua.isnull(self.view) then
		self.view:setTouchEnabled(enabled)
	end
   -- self:dispatchEvent({name = "setTouchEnabled", enabled = enabled})
end

function DynListView:onTouch(event, x, y)
    if self.cellNum < 1 or self.dataNum < 1 then
        return
    end

    if event == "began" then
        if not self.touchRect:containsPoint(ccp(x, y)) then return false end
        if not self.m_bEnabled then return false end
        return self:onTouchBegan(x, y)
    elseif event == "moved" then
        self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    else -- cancelled
        self:onTouchCancelled(x, y)
    end
end

function DynListView:onTouchBegan(x, y)
	if self.drag then return false end 
   
	self.curTouchCell = self:getCellByPos(x, y)

	self.drag = {
        currentOffsetX = self.offsetX,
        currentOffsetY = self.offsetY,
        startX = x,
        startY = y,
        isTap = true,
    }
	
    if not tolua.isnull(self.curTouchCell) then
        self.curTouchCell:onTouch("began", x, y)
    end
	
	self.startPoint = {x=x, y=y}
	self.beginPoint = {x=x, y=y}

    return true
end

function DynListView:onTouchMoved(x, y)
    if self.direction == DynListView.DIRECTION_HORIZONTAL then
        if self.drag.isTap and math.abs(x - self.drag.startX) >= self.dragThreshold then
            self.drag.isTap = false
            if not tolua.isnull(self.curTouchCell) then
                self.curTouchCell:onTouch("cancelled", x, y)
            end
        end

        if not self.drag.isTap then
            self:scrollAllCells(x - self.drag.startX + self.drag.currentOffsetX)
        else
           if not tolua.isnull(self.curTouchCell) then
               self.curTouchCell:onTouch("moved", x, y)
           end
        end
    else
        self:onTouchMovedCallBack(x,y)
        if self.drag.isTap and math.abs(y - self.drag.startY) >= self.dragThreshold then
            self.drag.isTap = false
            if not tolua.isnull(self.curTouchCell) then
                self.curTouchCell:onTouch("cancelled", x, y)
            end
        end

        if not self.drag.isTap then
            self:scrollAllCells(y - self.drag.startY + self.drag.currentOffsetY)
        else
           if not tolua.isnull(self.curTouchCell) then
               self.curTouchCell:onTouch("moved", x, y)
           end
        end
    end
	
	self.startPoint={x=x, y=y}
end

function DynListView:setOnTouchMovedCallBack(callBack)
    self.onTouchMovedCallBackFunc = callBack
end

function DynListView:onTouchMovedCallBack(x,y)
    if self.onTouchMovedCallBackFunc and type(self.onTouchMovedCallBackFunc) == "function" then
        self.onTouchMovedCallBackFunc(x,y)
    end
end

function DynListView:onTouchEnded(x, y)
    if self.drag.isTap then
        self:onTouchEndedWithTap(x, y)
    else
        self:onTouchEndedWithoutTap(x, y)
    end
    self.drag = nil
end

function DynListView:setNotTouchCellCallBack(callBack)
    self.notTouchCellCallBack = callBack
end

function DynListView:onTouchEndedWithTap(x, y) --点击，非拖动
	if tolua.isnull(self.curTouchCell) then 
        if type(self.notTouchCellCallBack) == "function" then
           self.notTouchCellCallBack()
        end
        return
    end
    self.curTouchCell:onTouch("ended", x, y)
	self.curTouchCell:onTap(x, y)
end

function DynListView:onTouchEndedWithoutTap(x, y)
    if not tolua.isnull(self.curTouchCell) then
        self.curTouchCell:onTouch("cancelled", x, y)
    end
    
    local offsetX, offsetY = self.offsetX, self.offsetY
    local index = 0
    if self.direction == DynListView.DIRECTION_HORIZONTAL then
        local x = 0
        local i = 1
        if offsetX >= 0 then
            index = 1
        elseif offsetX < self.rect.size.width - self.view:getContentSize().width then
            index = self.dataEndIndex - self.showCellNum + self.offsetBackCellNum
        else
            while i <= self.dataNum do
                if math.abs(offsetX) < x + self.maxCellWidth / 2 then
                    index = i
                    break
                end
                x = x + self.maxCellWidth
                i = i + 1
            end
        end
    else
        local y = 0
        local i = 1
        if offsetY <= 0 then
            index = 1
        elseif offsetY > self.view:getContentSize().height - self.rect.size.height then
            index = self.dataEndIndex - self.showCellNum + self.offsetBackCellNum
        else
            while i <= self.dataNum do
                if offsetY < y + self.maxCellHeight / 2 then
                    index = i
                    break
                end
                y = y + self.maxCellHeight
                i = i + 1
            end
        end
    end
    self:scrollToDataCell(index, true, nil, nil, tnternalClassTnstance)
end

function DynListView:onTouchCancelled(x, y)
    self.drag = nil
end

function DynListView:getCellByPos(x,y)  
    local index = self:getCellIndexByPos(x,y)
    return self:getCellByIndex(index)
end

function DynListView:getCellIndexByPos(x,y) 
    if self.maxCellWidth == 0 or self.maxCellHeight == 0 then
        return nil
    end
    local index = 0
    local pos = nil
    local cellBoundingBox = CCRect(0, 0, 0, 0)
    for k,v in ipairs(self.cells) do
        if not tolua.isnull(v) then
            pos = v:convertToNodeSpace(ccp(x, y))
            cellBoundingBox.size.width = v:getContentSize().width
            cellBoundingBox.size.height = v:getContentSize().height
            if cellBoundingBox:containsPoint(pos) then
                index = k
                break
            end
        end
    end

    if index == 0 then
        return nil
    end

    if index < 1 then 
        index = 1
    elseif index > self.cellNum then 
        index = self.cellNum
    end
    return index
end

function DynListView:getCellByIndex(index)
    return self.cells[index]
end

--外部接口
function DynListView:scrollToDataIndex(index)
    self:scrollToDataCell(index, nil, nil, nil, tnternalClassTnstance)
end

--内部接口
function DynListView:scrollToDataCell(index, animated, time, easing, tClassTnstance)
    if not tClassTnstance or tClassTnstance ~= tnternalClassTnstance then
        return
    end
    if self.cellNum < 1 or self.dataNum < 1 then
        return
    end

    if index < 1 then
        index = 1
    elseif index > self.dataNum - self.showCellNum + self.offsetBackCellNum then
        index = self.dataNum - self.showCellNum + self.offsetBackCellNum
        if index > self.dataNum then
            index = self.dataNum
        end
        if index < 1 then
            index = 1
        end
    end

    local offset = 0
    for i = 2, index do
        if self.direction == DynListView.DIRECTION_HORIZONTAL then
            offset = offset - self.maxCellWidth
        else
            offset = offset + self.maxCellHeight
        end
    end

    self:scrollAllCells(offset, animated, time, easing)
end

function DynListView:reorderAllCells()
    local x, y = 0, 0
    local cellWidth, cellHeight = 0, 0
    local allCellWidth, allCellHeight = 0, 0
    local cellAnchorPointX, cellAnchorPointY
    if self.direction == DynListView.DIRECTION_HORIZONTAL then
        y = self.rect:getMinY()
        x = self.rect:getMinX()
        cellAnchorPointX, cellAnchorPointY = 0, 0
    else
        y = self.rect:getMaxY()
        x = self.rect:getMinX()
        cellAnchorPointX, cellAnchorPointY = 0, 1
    end
    for i = 1, self.dataNum do
        if i <= self.cellNum then
            local cell = self.cells[i]
            cell:setAnchorPoint(ccp(cellAnchorPointX, cellAnchorPointY))
            cell:setPosition(ccp(x, y))
            cellWidth = cell:getContentSize().width
            cellHeight = cell:getContentSize().height
            if cellWidth > self.maxCellWidth then self.maxCellWidth = cellWidth end
            if cellHeight > self.maxCellHeight then self.maxCellHeight = cellHeight end
        end
        
        if self.direction == DynListView.DIRECTION_HORIZONTAL then
            allCellWidth = allCellWidth + cellWidth
            x = x + cellWidth
        else
            allCellHeight = allCellHeight + cellHeight
            y = y - cellHeight
        end
    end

    local size
    if self.direction == DynListView.DIRECTION_HORIZONTAL then
        size = CCSize(allCellWidth, self.maxCellHeight)
        self.showCellNum = math.ceil(self.rect.size.width / self.maxCellWidth)
        if self.showCellNum <= 0 then
            self.showCellNum = 1
        end
    else
        size = CCSize(self.maxCellWidth, allCellHeight)
        self.showCellNum = math.ceil(self.rect.size.height / self.maxCellHeight)
        if self.showCellNum <= 0 then
            self.showCellNum = 1
        end
    end
    self.view:setContentSize(size)
end

function DynListView:scrollAllCells(offset, animated, time, easing)
    self:updateScrollDirect(offset)
    self:setContentOffset(offset, animated, time, easing)
end

function DynListView:reArrangeOverCells()
    local function collectOverTopOrLeftCells()
        local overTopOrLeftCellNum = 0
        for k,v in ipairs(self.cells) do
            if self.direction == DynListView.DIRECTION_HORIZONTAL then
                if (v:getPositionX()+self.view:getPositionX()) <= self.rect:getMinX() - v:getContentSize().width then
                    overTopOrLeftCellNum = overTopOrLeftCellNum + 1
                end
            else
                if (v:getPositionY()+self.view:getPositionY()) >= self.rect:getMaxY() + v:getContentSize().height then
                    overTopOrLeftCellNum = overTopOrLeftCellNum + 1
                end
            end
        end
        if overTopOrLeftCellNum > self.dataNum - self.dataEndIndex then
            overTopOrLeftCellNum = self.dataNum - self.dataEndIndex
        end
        for i=1,overTopOrLeftCellNum do
            self.overTopOrLeftCellPool[#self.overTopOrLeftCellPool + 1] = table.remove(self.cells,1)
        end
    end
    local function updateOverTopOrLeftCells()
        local lastCellPosX, lastCellPosY = 0, 0
        if #self.cells > 0 then
            local lastCell = self:getCellByIndex(#self.cells)
            lastCellPosX, lastCellPosY = lastCell:getPosition()
            self.dataBeginIndex = self.dataBeginIndex + #self.overTopOrLeftCellPool
            self.dataEndIndex = self.dataEndIndex
        else
            if self.direction == DynListView.DIRECTION_HORIZONTAL then
                self.dataEndIndex = math.floor(math.abs(self.offsetX)/self.maxCellWidth)
                local dataBeginIndexTmp = self.dataEndIndex + 1
                if #self.overTopOrLeftCellPool > self.dataNum - self.dataEndIndex then
                    self.dataEndIndex = self.dataNum - #self.overTopOrLeftCellPool
                end
                self.dataBeginIndex = self.dataEndIndex + 1
                lastCellPosX = self.rect:getMinX() - self.offsetX - self.maxCellWidth
                if dataBeginIndexTmp > self.dataBeginIndex then
                    lastCellPosX = lastCellPosX - (dataBeginIndexTmp-self.dataBeginIndex)*self.maxCellWidth
                end
                lastCellPosY = self.rect:getMinY()
            else
                self.dataEndIndex = math.floor(math.abs(self.offsetY)/self.maxCellHeight)
                local dataBeginIndexTmp = self.dataEndIndex + 1
                if #self.overTopOrLeftCellPool > self.dataNum - self.dataEndIndex then
                    self.dataEndIndex = self.dataNum - #self.overTopOrLeftCellPool
                end
                self.dataBeginIndex = self.dataEndIndex + 1
                lastCellPosY = self.rect:getMaxY() - self.offsetY + self.maxCellHeight
                if dataBeginIndexTmp > self.dataBeginIndex then
                    lastCellPosY = lastCellPosY + (dataBeginIndexTmp-self.dataBeginIndex)*self.maxCellHeight
                end
                lastCellPosX = self.rect:getMinX()
            end
        end
        for k,v in ipairs(self.overTopOrLeftCellPool) do
            self.dataEndIndex = self.dataEndIndex + 1
            if type(v.setData) == "function" then
                v:setData(self.datas[self.dataEndIndex])
            end
            v:onUnTap(0,0)
            if self.direction == DynListView.DIRECTION_HORIZONTAL then
                v:setPositionX(lastCellPosX + self.maxCellWidth*k)
            else
                v:setPositionY(lastCellPosY - self.maxCellHeight*k)
            end
            self.cells[#self.cells + 1] = v
        end
        self.overTopOrLeftCellPool = {}
    end

    local function collectOverBottomOrRightCells()
        local overBottomOrRightCellNum = 0
        for k,v in ipairs(self.cells) do
            if self.direction == DynListView.DIRECTION_HORIZONTAL then
                if (v:getPositionX()+self.view:getPositionX()) >= self.rect:getMaxX() then
                    overBottomOrRightCellNum = overBottomOrRightCellNum + 1
                end
            else
                if (v:getPositionY()+self.view:getPositionY()) <= self.rect:getMinY() then
                    overBottomOrRightCellNum = overBottomOrRightCellNum + 1
                end
            end
        end
        if overBottomOrRightCellNum > self.dataBeginIndex - 1 then
            overBottomOrRightCellNum = self.dataBeginIndex - 1
        end
        for i=1,overBottomOrRightCellNum do
            self.overBottomOrRightCellPool[#self.overBottomOrRightCellPool + 1] = table.remove(self.cells,#self.cells)
        end
    end
    local function updateOverBottomOrRightCells()
        local firstCellPosX, firstCellPosY = 0, 0
        if #self.cells > 0 then
            local firstCell = self:getCellByIndex(1)
            firstCellPosX, firstCellPosY = firstCell:getPosition()
            self.dataBeginIndex = self.dataBeginIndex
            self.dataEndIndex = self.dataEndIndex - #self.overBottomOrRightCellPool
        else
            
        end

        for k,v in ipairs(self.overBottomOrRightCellPool) do
            self.dataBeginIndex = self.dataBeginIndex - 1
            if type(v.setData) == "function" then
                v:setData(self.datas[self.dataBeginIndex])
            end
            v:onUnTap(0,0)
            if self.direction == DynListView.DIRECTION_HORIZONTAL then
                v:setPositionX(firstCellPosX - v:getContentSize().width*k)
            else
                v:setPositionY(firstCellPosY + v:getContentSize().height*k)
            end
            table.insert(self.cells, 1, v)
        end
        self.overBottomOrRightCellPool = {}
    end

	if self.curScrollDirect == DynListView.SCROLL_DIRECTION_VERTICAL_UP or self.curScrollDirect == DynListView.SCROLL_DIRECTION_VERTICAL_LEFT then
    	if self.dataEndIndex < self.dataNum then
            collectOverTopOrLeftCells()
            updateOverTopOrLeftCells()
        elseif self.dataEndIndex >= self.dataNum then
            self.dataEndIndex = self.dataNum
        end
	else
		if self.dataBeginIndex > 1 then
            collectOverBottomOrRightCells()
            updateOverBottomOrRightCells()
        elseif self.dataBeginIndex < 1 then
            self.dataBeginIndex = 1
        end
	end
end
function DynListView:updateScrollDirect(offset)
    local offsetX = 0
    local offsetY = 0
    self.curScrollDirect = 0
    if self.direction == DynListView.DIRECTION_HORIZONTAL then
        offsetX = offset - self.offsetX
    else
        offsetY = offset - self.offsetY
    end
    if math.abs(offsetX) > 0 then
        if offsetX > 0 then
            self.curScrollDirect = DynListView.SCROLL_DIRECTION_VERTICAL_RIGHT
        else
            self.curScrollDirect = DynListView.SCROLL_DIRECTION_VERTICAL_LEFT
        end
    elseif math.abs(offsetY) > 0 then
        if offsetY > 0 then
            self.curScrollDirect = DynListView.SCROLL_DIRECTION_VERTICAL_UP
        else
            self.curScrollDirect = DynListView.SCROLL_DIRECTION_VERTICAL_DOWN
        end
    end
end

function DynListView:setContentOffset(offset, animated, time, easing)
    local ox, oy = self.offsetX, self.offsetY
    local x, y = ox, oy
    if self.direction == DynListView.DIRECTION_HORIZONTAL then
		self.offsetX = offset
        x = offset

        local minX = self.rect.size.width - self.view:getContentSize().width - self.bouncThreshold
        if minX >= -self.bouncThreshold then
            minX = -self.bouncThreshold
        end
        local maxX = self.bouncThreshold

        if x > maxX then
            x = maxX
        elseif x < minX then
            x = minX
        end
    else
        self.offsetY = offset
        y = offset

        local maxY = self.view:getContentSize().height - self.rect.size.height
        if maxY < 0 then
            maxY = self.view:getContentSize().height
        else
            maxY = self.view:getContentSize().height - self.rect.size.height + self.bouncThreshold
        end
        local minY = -self.bouncThreshold

        if y > maxY then
            y = maxY
        elseif y < minY then
            y = minY
        end
    end

    if animated then
        transition.stopTarget(self.view)
        self:startScrollScheduler()
        
        local moveToAction = CCEaseBackOut:create(CCMoveTo:create(self.defaultAnimateTime, ccp(x,y)))
        local callBackAction = CCCallFunc:create(function()
            self:stopScrollScheduler()
            end)
        local seqAction = transition.sequence({moveToAction, callBackAction})
        self.view:runAction(seqAction)
    else
        self.view:setPosition(x, y)
        self:reArrangeOverCells()
    end
end

function DynListView:startScrollScheduler()
    self:stopScrollScheduler()
    self.scrollTimer = scheduler:scheduleScriptFunc(function()
        self:reArrangeOverCells()
    end,0,false)
end

function DynListView:stopScrollScheduler()
	if self.scrollTimer then
		scheduler:unscheduleScriptEntry(self.scrollTimer)
		self.scrollTimer = nil
	end
end

function DynListView:onExit()
	self:stopScrollScheduler()
    self:removeAllEventListeners()
	self = nil
end

return DynListView
