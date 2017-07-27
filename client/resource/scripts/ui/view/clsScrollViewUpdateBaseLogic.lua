--2016/12/31
--create by wmh0497
--滚动页面更新策略

local ClsScrollViewUpdateBaseLogic = class("ClsScrollViewUpdateBaseLogic")

function ClsScrollViewUpdateBaseLogic:ctor(scroll_view)
	self.m_scroll_view = scroll_view
end

--return true 继续跑定时器创建
--return false 不跑定时器了，等触发时机
function ClsScrollViewUpdateBaseLogic:updateCellHander()
	for i, cell in ipairs(self.m_scroll_view:getCells()) do
		if not cell:getIsCreate() then
			if self:isInCreateArea(cell) then
				self:makeCellCreate(cell)
				return true
			end
		end
	end
	return false
end

function ClsScrollViewUpdateBaseLogic:isInCreateArea(cell)
	if tolua.isnull(cell) then
		return false
	end
	local inner_layer = self.m_scroll_view:getInnerLayer()
	if self.m_scroll_view:getIsVertical() then
		local cell_y = -1 * self.m_scroll_view:getStandardPos(cell).y
		local inner_layer_y = self.m_scroll_view:getStandardPos(inner_layer).y
		local scroll_view_height = self.m_scroll_view:getHeight()
		
		local create_bottom_y = inner_layer_y + scroll_view_height + cell:getHeight()
		local create_top_y = inner_layer_y - scroll_view_height*1.1
		if (create_top_y <= cell_y) and (cell_y <= create_bottom_y) then
			return true
		end
	else
		local cell_x = self.m_scroll_view:getStandardPos(cell).x
		local inner_layer_x = self.m_scroll_view:getStandardPos(inner_layer).x
		local scroll_view_width = self.m_scroll_view:getWidth()
		
		local create_left_x = scroll_view_width*-0.1 - inner_layer_x
		local create_right_x = scroll_view_width*1.33 - inner_layer_x + cell:getWidth()
		if (create_left_x <= cell_x) and (cell_x <= create_right_x) then
			return true
		end
	end
	return false
end

function ClsScrollViewUpdateBaseLogic:makeCellCreate(cell)
	if not cell:getIsCreate() then
		cell:setIsCreate(true)
		local ui_cretae_func = self.m_scroll_view:getUICretaeFunc()
		if ui_cretae_func then
			local cell_ui = ui_cretae_func()
			if cell_ui then
				cell:setCellUI(cell_ui)
				cell:addChild(cell_ui)
			end
		end
		cell:callUpdateUI()
		cell:setTouch(self.m_scroll_view:isTouch())
	end
end

return ClsScrollViewUpdateBaseLogic