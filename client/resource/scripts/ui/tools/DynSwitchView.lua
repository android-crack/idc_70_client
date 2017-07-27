local SwitchView=require("ui/tools/SwitchView")
local ClsDynSwitchView = class("ClsDynSwitchView", SwitchView)

function ClsDynSwitchView:ctor(params)
	self.is_fit_full = params.fit_full or false -- 是否底部自适应靠到最底
	ClsDynSwitchView.super.ctor(self, params)
end

function ClsDynSwitchView:scrollToCell(index, animated, time, easing)
	local count = self:getMaxMoveIndex()
	if count < 1 then
		self.index = 0
		return
	end
	if not index then return end

	if index < 1 then
        index = 1
    elseif index > count then
        index = count
    end

	if self.index and self.index > 0  then        --改变细胞状态
		if(type(self.cells[self.index].unSelect)=="function") then
			self.cells[self.index]:unSelect(self.index)
	   end
	end
    --动态加载  太叼了
    local hasMkItem = false
    local showCellNum = self.showCellNum or 4
    for i = index,index + showCellNum  do
    	local cell = self.cells[i]
    	if not tolua.isnull(cell) then
    		if type(cell.mkItem)=="function" then
                hasMkItem = true
                cell:mkItem(i)
            end
    	end
    end
    if hasMkItem then
	    self:reorderAllCells()
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

function ClsDynSwitchView:setTouchPriority(priority)
	self.view:setTouchEnabled(false)
    self.view:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, priority, true)
	self.view:setTouchEnabled(true)
	self.view:setTouchMode(kCCTouchesOneByOne)
end

function ClsDynSwitchView:getMaxMoveIndex()
	local count = #self.cells
	if count < 1 then return 0 end
	if self.is_fit_full then
		local start_length = 0
		local true_index_n = count
		local height_n = self.rect.size.height
		if self.direct == SwitchView.DIRECTION_HORIZONTAL then
			height_n = self.rect.size.width
		end
		for i = count, 1, -1 do
			if self.direct == SwitchView.DIRECTION_HORIZONTAL then
				start_length = start_length + self.cells[i]:getContentSize().width
			else
				start_length = start_length + self.cells[i]:getContentSize().height
			end
			if start_length > height_n then
				break
			end
			true_index_n = i
		end
		if start_length > height_n then
			return true_index_n
		end
		return 1
	end
	return count
end

function ClsDynSwitchView:changeButton()
	local count = self:getMaxMoveIndex()
	if self.widget_left_btn and self.widget_right_btn and count > 0 then
		self.widget_right_btn:setVisible(self.index < count)
		self.widget_left_btn:setVisible(self.index > 1)
		--todo
	end

	if not self.isButton or count ==0 then return end
	self.buttonRight:setEnabled(self.index < count)
	self.buttonLeft:setEnabled(self.index > 1)
end

function ClsDynSwitchView:setContentOffset(offset, animated, time, easing)
	if not self.is_fit_full then
		ClsDynSwitchView.super.setContentOffset(self, offset, animated, time, easing)
		return
	end
	local count = #self.cells
	if count == 0 then
		return
	end
	local x, y = self.view:getPositionX(), self.view:getPositionY()
	local cellSize=self.cells[#self.cells]:getContentSize()

	if self.direct == SwitchView.DIRECTION_HORIZONTAL then
		x = offset
		local maxX = self.offsetX
		local minX = math.min(self.offsetX - self.viewLen + self.rect.size.width, maxX)
		if not animated then
			maxX = maxX + self.bouncThreshold
			minX = minX - self.bouncThreshold
		end
		if x > maxX then
			x = maxX
		elseif x < minX then
			x = minX
		end
	else
		y = offset
		local minY = self.offsetY
		local maxY = math.max(self.offsetY + self.viewLen - self.rect.size.height, minY)
		if not animated then
			maxY = maxY + self.bouncThreshold
			minY = minY - self.bouncThreshold
		end
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

function ClsDynSwitchView:setEmptyCall(call)
	self.empty_call = call
end

function ClsDynSwitchView:onTouchEndedWithTap(x, y) --点击，非拖动
	if type(self.touchCallBack) == "function" then
		self.touchCallBack()
	end

	local d_time = os.clock() - self.drag.startTime

	local count = #self.cells
	local find_cell = false
	for i = 1, count do
		local pos = self.view:convertToNodeSpace(ccp(x,y))
		if self.cells[i]:boundingBox():containsPoint(pos) then
			find_cell = true
			if d_time >= 0.3 then
				if type(self.cells[i].onLongTap) == "function" then
					self.cells[i]:onLongTap(x,y)
				end
			else
				if type(self.cells[i].onTap) == "function" then
					if type(self.cells[i].getNotAcceptClickEvent) == "function" then
						if not self.cells[i]:getNotAcceptClickEvent() then
							self.cells[i]:onTap(x,y)
						end
					else
						self.cells[i]:onTap(x,y)
					end
					break
				end
			end

		end
	end
	if not find_cell then
		if type(self.empty_call) == "function" then
			self.empty_call()
		end
	end
end	

function ClsDynSwitchView:setShowCellNum(num)
	self.showCellNum = num
end	

return ClsDynSwitchView