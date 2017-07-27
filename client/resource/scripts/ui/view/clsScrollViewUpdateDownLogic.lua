--2016/12/31
--create by wmh0497
--滚动页面更新策略

local ClsScrollViewUpdateDownLogic = class("ClsScrollViewUpdateDownLogic", require("ui/view/clsScrollViewUpdateBaseLogic"))

--return true 继续跑定时器创建
--return false 不跑定时器了，等触发时机
function ClsScrollViewUpdateDownLogic:updateCellHander()
	local cells = self.m_scroll_view:getCells()
	local cells_len_n = #cells
	for i = cells_len_n, 1, -1 do
		local cell = cells[i]
		if not cell:getIsCreate() then
			if self:isInCreateDownArea(cell) then
				self:makeCellCreate(cell)
				return true
			end
		end
	end
	return false
end

function ClsScrollViewUpdateDownLogic:isInCreateDownArea(cell)
	local inner_layer = self.m_scroll_view:getInnerLayer()
	if self.m_scroll_view:getIsVertical() then
		local cell_y = -1 * self.m_scroll_view:getStandardPos(cell).y
		local inner_layer_y = self.m_scroll_view:getStandardPos(inner_layer).y
		
		local create_top_y = inner_layer_y - self.m_scroll_view:getHeight()*1.33
		if create_top_y <= cell_y then
			return true
		end
	else
		local cell_x = self.m_scroll_view:getStandardPos(cell).x
		local inner_layer_x = self.m_scroll_view:getStandardPos(inner_layer).x
		
		local create_left_x = self.m_scroll_view:getWidth()*-0.33 - inner_layer_x
		if create_left_x <= cell_x then
			return true
		end
	end
	return false
end

return ClsScrollViewUpdateDownLogic