local SwitchView = require("ui/tools/SwitchView")
local ListView = class("ListView", SwitchView)

function ListView:scrollToCell(index, animated, time, easing)
	local count = #self.cells
	if count < 1 then
		self.index = 0
		return
	end
	if not index or index > count or index < 1 then return end

	if self.index and self.index > 0  then        --改变细胞状态
		if(type(self.cells[self.index].unSelect)=="function") then
			self.cells[self.index]:unSelect(self.index)
	   end
	end
    --动态加载  太叼了
    for i = index,index + 4  do
    	local cell = self.cells[i]
    	if not tolua.isnull(cell) then
    		cell:mkItem()
    	end
    end
    
	self.index = index
	self.cells[self.index]:select(self.index)
	self:changeButton()

	if time and time < 0 then return end

	local offset = self.offsetY
	if self.direct == SwitchView.DIRECTION_HORIZONTAL then
		offset = self.offsetX
	end
	for i = 2, index do
		local cell = self.cells[i - 1]
		local size = cell:getContentSize()
		if self.direct == SwitchView.DIRECTION_HORIZONTAL then
			offset = offset - size.width
		else
			offset = offset + size.height
		end
	end
	self:setContentOffset(offset, animated, time, easing)
end

function ListView:setCurrentIndex(index, animated)
	self:scrollToCell(index, animated)
end

return ListView
