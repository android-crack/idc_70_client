require("ui/tools/MyMenu")
require("ui/tools/MyMenuItem")
local music_info = require("game_config/music_info")
local SwitchView = class("SwitchView", function(params)
	return CCNode:create()
end)
 
SwitchView.DIRECTION_HORIZONTAL = 1
SwitchView.DIRECTION_VERTICAL = 2

function SwitchView:ctor(params)
	params.x = params.x or 0
	params.y = params.y or 0
	local priority = params.priority or 0
	self.direct = params.direct or SwitchView.DIRECTION_HORIZONTAL
	self.widget_left_btn = params.widget_left_btn
	self.widget_right_btn = params.widget_right_btn
	self.rect = params.rect or CCRect(0, 0, 0, 0)
	self.touchRect = self.rect
	self.dragThreshold = 10       			--拖动的最小临界值
	self.bouncThreshold = 100	  			--拖动到能翻页的最小临界值
	self.defaultAnimateTime = 0.6 			--默认动画时间
	self.defaultAnimateEasing = "backOut"   --默认ease
	self.viewLen = 0                          --总细胞长度
	self.index = 0                          --当前细胞的索引
	self.sound = params.sound          		--点击细胞的音效
	self.end_call_back_offset = params.end_call_back_offset or 10
	self.rightAndLeftFigureSound = params.rightAndLeftFigureSound or "" --左右按钮音效
	self.cells = {}

    
	self.offsetX = params.rect:getMinX()+params.x 
	if self.direct == SwitchView.DIRECTION_HORIZONTAL then
		self.offsetY = params.rect:getMinY()+params.y
	else
		self.offsetY = params.rect:getMaxY()+params.y
	end

	local node = display.newClippingRegionNode(self.rect)
	self:addChild(node)

	self.view = display.newLayer() --cell的父层
	node:addChild(self.view)
	self.view:setTouchEnabled(true)
	self.view:setPosition(self.offsetX, self.offsetY)
    self.view:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, priority, true)
	self.view:setTouchMode(kCCTouchesOneByOne)

	self.isButton = params.isButton
	if self.isButton == nil then 
		if self.direct == SwitchView.DIRECTION_VERTICAL then
			--竖直方向默认没有上下按钮
			self.isButton = false
		else
			--水平方向默认有左右按钮
			self.isButton = true
		end
	end
	if self.isButton then
	
		--初始化箭头偏移数据和缩放
		arrow_infos = params.arrow_infos or {}
		left_or_top_info = arrow_infos.arrow_left_or_top or {}
		right_or_bottom_info = arrow_infos.arrow_right_or_bottom or {}
		left_or_top_offset_x = left_or_top_info.offset_x or 0
		left_or_top_offset_y = left_or_top_info.offset_y or 0
		right_or_bottom_offset_x = right_or_bottom_info.offset_x or 0
		right_or_bottom_offset_y = right_or_bottom_info.offset_y or 0
		left_or_top_flip_x = left_or_top_info.flip_x or false
		left_or_top_flip_y = left_or_top_info.flip_y or false
		right_or_bottom_flip_x = right_or_bottom_info.flip_x or false
		right_or_bottom_flip_y = right_or_bottom_info.flip_y or false
		
		local buttonLeftImage = params.buttonLeftImage or "#common_btn_arrow1.png"
		local buttonLeftSelected = params.buttonLeftSelected or "#common_btn_arrow1.png"
		self.buttonLeft = MyMenuItem.new({image = buttonLeftImage, imageSelected = buttonLeftSelected,imageDisabled = buttonLeftSelected,sound = self.rightAndLeftFigureSound})
		self.buttonLeft:setEnabled(false)
		self.buttonLeft:regCallBack(function()
			if not self.view:isTouchEnabled() then return end
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:scrollToCell(self.index - 1,true)
		end)
		local buttonRightImage = params.buttonRightImage or "#common_btn_arrow1.png"
		local buttonRightSelected = params.buttonRightSelected or "#common_btn_arrow1.png"
		self.buttonRight = MyMenuItem.new({image = buttonRightImage,imageSelected = buttonRightSelected,imageDisabled = buttonRightSelected,sound = self.rightAndLeftFigureSound})
		self.buttonRight:setEnabled(false)
		self.buttonRight:setRotation(180)
		self.buttonRight:regCallBack(function()
			if not self.view:isTouchEnabled() then return end
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:scrollToCell(self.index + 1,true)
		end)
		if self.direct == SwitchView.DIRECTION_HORIZONTAL then
			local y = (self.rect:getMaxY() + self.rect:getMinY()) / 2
			self.buttonLeft:setPosition(ccp(self.rect:getMinX()-20 + left_or_top_offset_x, y + left_or_top_offset_y))
			self.buttonRight:setPosition(ccp(self.rect:getMaxX()+20 + right_or_bottom_offset_x ,y + right_or_bottom_offset_y))
		else
			local x = (self.rect:getMaxX() + self.rect:getMinX())/2
			self.buttonLeft:setPosition(ccp(x + left_or_top_offset_x, self.rect:getMaxY() + 20 + left_or_top_offset_y))
			self.buttonRight:setPosition(ccp(x + right_or_bottom_offset_x, self.rect:getMinY() - 20 + right_or_bottom_offset_y))
		end
		self.buttonLeft:setFlipX(left_or_top_flip_x)
		self.buttonLeft:setFlipY(left_or_top_flip_y)
		self.buttonRight:setFlipX(right_or_bottom_flip_x)
		self.buttonRight:setFlipY(right_or_bottom_flip_y)
		if params.opacity_enable then
			self.buttonLeft:setDisabledImageOpacity(params.opacity_enable)
			self.buttonRight:setDisabledImageOpacity(params.opacity_enable)
		end
		self.leftRightBtnMenu = MyMenu.new({self.buttonLeft, self.buttonRight})
		self:addChild(self.leftRightBtnMenu, 1)
	end

	self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)
end

function SwitchView:setTouchPriority(priority)
	self.view:setTouchEnabled(false)
	self.view:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, priority, true)
	self.view:setTouchEnabled(true)
end

function SwitchView:setTouchRect(rect)
	self.touchRect = rect
end

function SwitchView:setSlider(slider)
	self.slider = slider
end

function SwitchView:setNotUseBufferDrag(is)
	self.not_use_buffer_drag = is
end

function SwitchView:changeButton()
	local count = #self.cells

	if not self.isButton or count == 0 then return end
	if self.index >= count then
		self.buttonRight:setEnabled(false)
	else
		self.buttonRight:setEnabled(true)
	end
	if self.index <= 1 then
		self.buttonLeft:setEnabled(false)
	else
		self.buttonLeft:setEnabled(true)
	end
end

function SwitchView:isTouchEnabled()
	return self.view:isTouchEnabled()
end

function SwitchView:disappearButton(isShow)
	self.isButton = isShow or false
	self.buttonRight:setVisible(self.isButton)
	self.buttonLeft:setVisible(self.isButton)
end

function SwitchView:setTouchEnabled(isEnabled)
	if tolua.isnull(self) then return end
	if isEnabled == nil then isEnabled = false end
	self.view:setTouchEnabled(isEnabled)

	if not tolua.isnull(self.leftRightBtnMenu) then
		self.leftRightBtnMenu:setTouchEnabled(isEnabled)
	end
end

function SwitchView:onTouch(event, x, y)
	-- if #self.cells == 0 then 
	-- 	if type(self.touchCallBack) == "function" then
	-- 		self.touchCallBack()
	-- 	end
	-- 	return
	-- end

	if self.drag then
		if event == "ended" then
			self:onTouchEnded(x,y)
		elseif event == "cancelled" then
			self:onTouchCancelled(x,y)
		end
	end
	if event == "began" then
		local pos = self:getParent():convertToNodeSpace(ccp(x, y))
		if not self.touchRect then
			if not self.rect:containsPoint(pos) then return false end
		else
			if not self.touchRect:containsPoint(pos) then return false end
		end
		return self:onTouchBegan(x,y)
	elseif event == "moved" then
		self:onTouchMoved(x, y)
	end
end

function SwitchView:onExit()
end

function SwitchView:setOnTouchBeganCallBack(callBack)
    self.onTouchBeganCallBackFunc = callBack
end

function SwitchView:onTouchBeganCallBack(x,y)
    if self.onTouchBeganCallBackFunc and type(self.onTouchBeganCallBackFunc) == "function" then
        self.onTouchBeganCallBackFunc(x,y)
    end

    local count = #self.cells
	if count == 0 or not self.rect:containsPoint(ccp(x, y)) or ( self.touchRect and not self.touchRect:containsPoint(ccp(x,y)) ) then return end
	for i = 1,count do
		local pos = self.view:convertToNodeSpace(ccp(x,y))
		if self.cells[i]:boundingBox():containsPoint(pos) then
			if type(self.cells[i].onClick) == "function" then
				self.cells[i]:onClick(x,y)
			end
		end
	end
end

function SwitchView:onTouchBegan(x, y)
	self.drag = {
		startX = x,     --第一次触摸位置
		startY = y,
		endX = x,       --上一次数模位置
		endY = y,
		isTap = true,
		startTime = os.clock()
	}
	self:onTouchBeganCallBack(x, y)
	return true
end

function SwitchView:setOnTouchMovedCallBack(callBack)
    self.onTouchMovedCallBackFunc = callBack
end

function SwitchView:onTouchMovedCallBack(x,y)
    if self.onTouchMovedCallBackFunc and type(self.onTouchMovedCallBackFunc) == "function" then
        self.onTouchMovedCallBackFunc(x,y)
    end
end

function SwitchView:setNotTouchCellCallBack(callBack)
    self.notTouchCellCallBack = callBack
end

function SwitchView:onTouchMoved(x, y)
    if not self.drag then return end 
	if self.direct == SwitchView.DIRECTION_HORIZONTAL then
        if self.drag.isTap and math.abs(x - self.drag.startX) >= self.dragThreshold then
			self.drag.isTap = false
			--self.curCell:onTouch("cancelled", x, y)
		end

		if not self.drag.isTap then
			self:setContentOffset(x - self.drag.endX+self.view:getPositionX())
		else
		--     self.curCell:onTouch("moved", x, y)
		end
		self.drag.endX = x
	else
        if self.drag.isTap and math.abs(y - self.drag.startY) >= self.dragThreshold then
        	self:onTouchMovedCallBack(x,y)
			self.drag.isTap = false
			--            self.curCell:onTouch("cancelled", x, y)
		end

		if not self.drag.isTap then
			self:setContentOffset(y - self.drag.endY + self.view:getPositionY())
		else
		--           self.curCell:onTouch("moved", x, y)
		end
		self.drag.endY = y
	end
end

function SwitchView:onTouchCancelled(x, y)
	self.drag = nil
end

function SwitchView:setOnTouchEndedCallBack(callBack)
    self.onTouchEndedCallBackFunc = callBack
end

function SwitchView:onTouchEndedCallBack(x,y)
    if self.onTouchEndedCallBackFunc and type(self.onTouchEndedCallBackFunc) == "function" then
        self.onTouchEndedCallBackFunc(x,y)
    end
end

function SwitchView:setMoveEndCallBack(call_back)
	self.moveEndCallBack = call_back
end

function SwitchView:setMoveEndCallBackOffset( offset )
	self.end_call_back_offset = offset
end

function SwitchView:onTouchEnded(x, y)
	self:onTouchEndedCallBack(x, y)
    if self.drag and self.drag.isTap then
		self:onTouchEndedWithTap(x, y)
	else
		self:onTouchEndedWithoutTap(x, y)
		local view_y = self.view:getPositionY()
		if ( type(self.moveEndCallBack) == "function" and ( view_y - ( self.viewLen - self.rect.size.height + self.offsetY ) >= self.end_call_back_offset ) ) then
			self.moveEndCallBack()
		end
	end
	self.drag = nil
end

function SwitchView:setTouchCallBack(call_back)
	self.touchCallBack = call_back
end

function SwitchView:onTouchEndedWithTap(x, y) --点击，非拖动
	if type(self.touchCallBack) == "function" then
		self.touchCallBack()
	end
	local count = #self.cells
	if count == 0 or 
		not self.rect:containsPoint(ccp(x, y)) or 
		( self.touchRect and not self.touchRect:containsPoint(ccp(x,y)) ) then
		return
	end
	for i = 1 , count do
		local pos = self.view:convertToNodeSpace(ccp(x,y))
		if self.cells[i]:boundingBox():containsPoint(pos) then
			if i ~= self.index then
				self:scrollToCell(i,true)
			end
			if type(self.cells[self.index].onTap) == "function" then
				self.cells[self.index]:onTap(x,y)
			end
			break
		end
	end
end

function SwitchView:setContentOffset(offset, animated, time, easing)
	local count = #self.cells
	if count == 0 then
		return
	end
	local x, y = self.view:getPositionX(), self.view:getPositionY()
	local cellSize=self.cells[#self.cells]:getContentSize()

	if self.direct == SwitchView.DIRECTION_HORIZONTAL then
		x = offset
		if not animated then
			local maxX = self.offsetX + self.bouncThreshold
			local minX = self.offsetX - self.bouncThreshold - (self.viewLen - cellSize.width)
			if x > maxX then
				x = maxX
			elseif x < minX then
				x = minX
			end
		end
	else
		y = offset
		local maxY = nil
		local minY = nil
		if self.not_use_buffer_drag then
			maxY = self.offsetY - self.rect.size.height + self.viewLen
			minY = self.offsetY
		else
			maxY = self.offsetY + self.viewLen
			minY = self.offsetY - self.bouncThreshold
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
	if not tolua.isnull(self.slider) then
		local slider_height = self.slider:getContentSize().width
		local slider_ball_height_half = (self.slider:getSlidBallContentsize().width * self.slider:getSlidBallScaleX())  / 2
		local total_cell_length = ( #self.cells ) * self.cells[1]:getContentSize().height
		local view_pos_x, view_pos_y = self.view:getPosition()
		local move_scape = total_cell_length - self.rect.size.height
		local offset = ( (view_pos_y - self.offsetY) < 0 and 0 ) or  ( (view_pos_y - self.offsetY) > move_scape and move_scape ) or (view_pos_y - self.offsetY)
    	local real_move_offset = slider_ball_height_half + (offset / move_scape) * (slider_height - 2 * slider_ball_height_half)
		self.slider:setPercent( ( 100 * real_move_offset ) / slider_height )
	end
end

function SwitchView:onTouchEndedWithoutTap(x_, y_) --触摸结束后判断是否要回弹

	local count = #self.cells
	if count == 0 then return end
	local index = 0
	local trigDragDistance = 0
	local viewX, viewY = self.view:getPositionX(), self.view:getPositionY()
	if self.direct == SwitchView.DIRECTION_HORIZONTAL then
		local x = self.offsetX
		local i = 1
		self.trigDragDistance = 30

		if self.drag.startX > x_ then
			while i <= count do
				local cell = self.cells[i]
				local size = cell:getContentSize()
				trigDragDistance = self.trigDragDistance or size.width / 2
				local value = x - trigDragDistance
				if i == count then value = -self.bouncThreshold - (self.viewLen-size.width) end
				if viewX >= value then
					index = i
					break
				end
				x = x - size.width
				i = i + 1
			end
		else
			while i <= count do
				local cell = self.cells[i]
				local size = cell:getContentSize()
				trigDragDistance = self.trigDragDistance or size.width / 2
				local value = x - (size.width - trigDragDistance)
				if i == count then value = -self.bouncThreshold - (self.viewLen - size.width) end
				if viewX >= value then
					index = i
					break
				end
				x = x - size.width
				i = i + 1
			end
		end
	else
		local y = self.offsetY
		for k, v in ipairs(self.cells) do
			local size = v:getContentSize()
			trigDragDistance = self.trigDragDistance or size.height / 2
			local value = y + trigDragDistance
			if viewY <= value then
				index = k
				break
			end
			if k == count then index = k end
			y = y + size.height
		end
	end
	self:scrollToCell(index, true)
end

function SwitchView:scrollToCell(index, animated, time, easing)
	local count = #self.cells
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
		if(type(self.cells[self.index].unSelect) == "function") then
			self.cells[self.index]:unSelect(self.index)
	  	end
	end
    --动态加载  太叼了
    for k,cell in ipairs(self.cells) do
        if k < index - 1 or k > index + 1 then
            if type(cell.delItem) == "function" then
                cell:delItem()
            end
        else
            if type(cell.mkItem) == "function" then
                cell:mkItem()
            end
        end
    end
    
	if self.sound and self.index ~= index then
        audioExt.playEffect(self.sound, false)
    end

	self.index = index

	if type(self.cells[self.index].select) == "function" then 
		self.cells[self.index]:select(self.index)
	end
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

function SwitchView:getCurrentCell()
	return self:getCellByIndex(self.index)
end

function SwitchView:getCellByIndex(index)
	if index then return self.cells[index] end
end

function SwitchView:getCurrentIndex()
	return self.index
end

function SwitchView:setCurrentIndex(index)
	self:scrollToCell(index)
end

function SwitchView:addCell(cell,zorder)
	self.view:addChild(cell,zorder or 0)
	table.insert(self.cells,cell)
	self:reorderAllCells()
end

function SwitchView:insertCellAtIndex(cell, index)
	self.view:addChild(cell)
	table.insert(self.cells, index, cell)
	self:reorderAllCells()
end

function SwitchView:insertCellToEnd(cell)
	self.view:addChild(cell)
	table.insert(self.cells, cell)
	self:reorderAllCells()
end

function SwitchView:removeCellAtIndex(index)
	if not index then return end
	local cell = self.cells[index]
	if tolua.isnull(cell) then return end
	self.view:removeChild(cell, true)
	table.remove(self.cells, index)
	for k, v in ipairs(self.cells) do --删除cell之后
		if type(v.resetIndex) == "function" then
			v:resetIndex(k)
		end
	end
	self:reorderAllCells()
end

function SwitchView:removeAllCell()
	for k,cell in pairs(self.cells) do
		self.view:removeChild(cell,true)
	end
	self.cells = {}
end

function SwitchView:reorderAllCells()
	local count = #self.cells
	local x, y = 0, 0
	local view_content_size = CCSize()
	self.viewLen = 0
	local maxWidth, maxHeight = 0, 0
	for i = 1, count do
		local cell = self.cells[i]
		local size = cell:getContentSize()
		if self.direct == SwitchView.DIRECTION_HORIZONTAL then
			cell:setPosition(x,y)
			self.viewLen = self.viewLen+size.width
			x = self.viewLen
		else
			cell:setPosition(x,y - size.height)
			self.viewLen = self.viewLen + size.height
			y = -self.viewLen
		end
	end

	if count > 0 then
		if self.index < 1 then
			self.index = 1
		elseif self.index > count then
			self.index = count
		end
	else
		self.index = 0
	end
	self:changeButton()
end

--拖动多少距离就显示下一个cell
function SwitchView:setTrigDragDistance(value)
    self.trigDragDistance = value
end

return SwitchView
