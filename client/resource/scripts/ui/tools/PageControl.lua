
local ScrollView = require("ui.tools.ScrollView")
local PageControl = class("PageControl", ScrollView)

function PageControl:onTouchEndedWithoutTap(lx, ly)
    local offsetX, offsetY = self.offsetX, self.offsetY
    local index = 0
    local count = #self.cells
    local trigDragDistance = 0
    if self.direction == ScrollView.DIRECTION_HORIZONTAL then
        offsetX = -offsetX
		local curcell = self:getCurrentCell()
		offsetX = offsetX + self.speed * curcell:getContentSize().width*0.8
        local x = 0
        local i = 1

        if self.drag.startX > lx then
            while i <= count do
                local cell = self.cells[i]
                local size = cell:getContentSize()
                trigDragDistance = self.trigDragDistance or size.width/2
                if offsetX < x + trigDragDistance then
                    index = i
                    self:endTouchCallFunc(lx, ly, ScrollView.DIRECTION_HORIZONTAL)
                    break
                end
                x = x + size.width
                i = i + 1
            end
        else
            while i <= count do
                local cell = self.cells[i]
                local size = cell:getContentSize()
                trigDragDistance = self.trigDragDistance or size.width/2
                if offsetX < x + (size.width - trigDragDistance) then
                    index = i
                    self:endTouchCallFunc(lx, ly, ScrollView.DIRECTION_HORIZONTAL)
                    break
                end
                x = x + size.width
                i = i + 1
            end
        end

        if i > count-self.showCell+1 then index = count-self.showCell+1 end
		if index < 1 then index = 1 end
    else
        local y = 0
        local i = 1

        if self.drag.startY < ly then
            while i <= count do
                local cell = self.cells[i]
                local size = cell:getContentSize()
                trigDragDistance = self.trigDragDistance or size.height / 2
                if offsetY < y + trigDragDistance then
                    index = i
                    self:endTouchCallFunc(lx, ly, ScrollView.DIRECTION_VERTICAL)
                    break
                end
                y = y + size.height
                i = i + 1
            end
        else
            while i <= count do
                local cell = self.cells[i]
                local size = cell:getContentSize()
                trigDragDistance = self.trigDragDistance or size.height / 2
                if offsetY < y + (size.height - trigDragDistance) then
                    index = i
                    self:endTouchCallFunc(lx, ly, ScrollView.DIRECTION_VERTICAL)
                    break
                end
                y = y + size.height
                i = i + 1
            end
        end
        
        if i > count-self.showCell+1 then index = count-self.showCell+1 end
		if index < 1 then index = 1 end
    end

    self:scrollToCell(index, true)
end

function PageControl:endTouchCallFunc(x, y, viewType)
	if not self.callFunc then return end
	
	local cellSize = self:getCurrentCell():getContentSize()
	local distance = 0
	local dSize = 0
	if viewType == ScrollView.DIRECTION_HORIZONTAL then
		distance = math.abs(self.beginPoint.x - x)
		dSize = cellSize.width * 0.5
	else
		distance = math.abs(self.beginPoint.y - y)
		dSize = cellSize.height * 0.5
	end
	
	if distance > dSize then
		self.callFunc()
	end
end

function PageControl:setPageCallFunc(callFunc)
	if type(callFunc) == "function" then
		self.callFunc = callFunc
	end
end

--拖动多少距离就显示下一个cell
function PageControl:setTrigDragDistance(value)
    self.trigDragDistance = value
end

return PageControl
