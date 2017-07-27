local PageControl = require("ui.tools.PageControl")
local ListView = class("ListView", PageControl)

local ListViewDEBUG = 2
ListView.ctor = function(self, rect, listcellTab, showCell, direction, touchPriority)
	self.showCell = showCell
	self.autoFit = false
	self.lastCell = nil
	local _direction = direction or PageControl.DIRECTION_VERTICAL
	ListView.super.ctor(self, rect, _direction, showCell, touchPriority)

	for i, cell in ipairs(listcellTab) do
		self:addCell(cell)
	end
end

function ListView:setAutoFit(isFit)
	self.autoFit = isFit
end

function ListView:reorderAllCells()
    local count = #self.cells
    local x, y = 0, 0
	y = self.rect:getMaxY()
	x = self.rect:getMinX()
    local maxWidth, maxHeight = 0, 0
    for i = 1, count do
        local cell = self.cells[i]
		cell:setAnchorPoint(ccp(0, 1)) -- 位置左上角开始
        cell:setPosition(ccp(x, y))
        if self.direction == PageControl.DIRECTION_HORIZONTAL then
        	local width = cell:getContentSize().width
            if not self.autoFit then            	
            	if width > maxWidth then maxWidth = width end
            	x = x + width
            else
            	x = x + width
        	end
        else	
        	local height = cell:getContentSize().height
        	if not self.autoFit then
	            if height > maxHeight then maxHeight = height end
	            y = y - height
	        else
 				y = y - height
        	end
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
    if self.direction == PageControl.DIRECTION_HORIZONTAL then
        size = CCSize(x, maxHeight)
    else
        size = CCSize(maxWidth, math.abs(y))
    end
    self.view:setContentSize(size)
end

function ListView:getCellByPos(x,y)  
	local curcell = self:getCurrentCell()
	local cellSize = curcell:getContentSize()
	local index = 1
	if self.direction == DIRECTION_HORIZONTAL then	
		index = math.floor((x - self.rect:getMinX())/cellSize.width)+self:getCurrentIndex()
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


function ListView:removeCell(cell)
	local index = 0
	for i = 1, #self.cells do
		if self.cells[i] == cell then 
			index = i
			break
		end
	end

	if index == 0 then return end

	cell:removeSelf()
	table.remove(self.cells, index)
	self:reorderAllCells()
	self.lastCell = nil
end

return ListView