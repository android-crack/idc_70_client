--上下的功能还没实现
local LoopView = class("LoopView", function(params)
	return CCNode:create()
end)

LoopView.DIRECTION_HORIZONTAL=1
LoopView.DIRECTION_VERTICAL=2

function LoopView:ctor(params)--{rect=显示区域,direct=方向,x,y细胞位置一,gap每个细胞的间隔,flag要显示的位置,max显示的细胞数量,notBtn是否有默认的左右按钮 默认有}  pos要从1开始
	assert(params.gap,"invalid param.gap")
	assert(params.max,"invalid param.max")
	assert(params.flag,"invalid param.flag")
	assert(params.rect,"invalid param.rect")

	self.gap=params.gap
	self.max=params.max
	self.flag=params.flag
	self.index=params.flag      --添加细胞的开始索引位置
	self.rect=params.rect

	self.min=1
	self.direct=params.direct or LoopView.DIRECTION_HORIZONTAL

	params.x=params.x or self.rect:getMinX()
	params.y=params.y or self.rect:getMinY()

	self.dragThreshold = 10
	self.defaultAnimateTime = 0.6
	self.isMove=false
	self.cell=nil

	self.points={}                                        --细胞所有位置的点坐标
	if  self.direct==  LoopView.DIRECTION_HORIZONTAL then
		for i=0,self.max+1 do
			self.points[i]=ccp(params.x+(i-1)*self.gap,params.y)
		end
	else

	end

	local node=display.newClippingRegionNode(self.rect)
	self:addChild(node)

	self.cells = {}

	self.view=display.newLayer()
	node:addChild(self.view)
	self.view:setTouchEnabled(true)

	self.view:addTouchEventListener(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, 0, true)

	self.notBtn= params.notBtn or false
	if not self.notBtn then
		self.buttonLeft = MyMenuItem.new({image = "#common_btn_arrow1.png", imageSelected="#common_btn_arrow1.png",imageDisabled = "#common_btn_arrow1.png"})
		self.buttonLeft:setEnabled(false)
		self.buttonLeft:regCallBack(function()
			self:moveCells(true)
		end)
		self.buttonRight = MyMenuItem.new({image ="#common_btn_arrow1.png",imageSelected="#common_btn_arrow1.png",imageDisabled ="#common_btn_arrow1.png"})
		self.buttonRight:setEnabled(false)
		self.buttonRight:setRotation(180)
		self.buttonRight:regCallBack(function()
			self:moveCells(false)
		end)
		if self.direct ==LoopView.DIRECTION_HORIZONTAL then
			local y=(self.rect:getMaxY()+self.rect:getMinY())/2
			self.buttonLeft:setPosition(ccp(self.rect:getMinX()-30,y))
			self.buttonRight:setPosition(ccp(self.rect:getMaxX()+30,y))
		else
		--还没实现
		end
		self:addChild(MyMenu.new({self.buttonLeft,self.buttonRight}))
	end
end

function LoopView:isTouchEnabled()
	return self.view:isTouchEnabled()
end

function LoopView:changeButton()
	if self.notBtn then return end
	if self:judgeCanMove(true) then
		self.buttonLeft:setEnabled(true)
	else
		self.buttonLeft:setEnabled(false)
	end
	if self:judgeCanMove(false) then
		self.buttonRight:setEnabled(true)
	else
		self.buttonRight:setEnabled(false)
	end
end

function LoopView:setTouchEnabled(isEnabled)
	if tolua.isnull(self) then return end
	if isEnabled==nil then isEnabled=false end
	self.view:setTouchEnabled(isEnabled)
end

--function LoopView:reorderCell()
--end

function LoopView:onTouch(event, x, y)
	--if self.rect:containsPoint(ccp(x, y)) then return true end
	if #self.cells==0 then return end

	if self.drag then
		if event=="ended" then
			self:onTouchEnded(x,y)
		elseif event=="cancelled" then
			self:onTouchCancelled(x, y)
		end
	end

	if not self.rect:containsPoint(ccp(x, y)) then return false end

	if event == "began" then
		return self:onTouchBegan(x, y)
	elseif event == "moved" then
		self:onTouchMoved(x, y)
	end
end

function LoopView:onTouchBegan(x, y)
	self.drag = {
		startX = x,     --第一次触摸位置
		startY = y,
		endX = x,       --上一次数模位置
		endY = y,
		time=os.clock(),
		isTap = true,
	}
	return true
end

function LoopView:onTouchMoved(x, y)
	local delay=0
	if self.direct == LoopView.DIRECTION_HORIZONTAL then
		if math.abs(x - self.drag.startX) >= self.dragThreshold then
			delay=os.clock()-self.drag.time
			self.time=os.clock()
			if self.drag.isTap then
				self.drag.isTap = false
			end
		end
		--移动下一个
		if not self.drag.isTap  then
			if self.drag.endX>x then
				self:moveCells(true,delay)
			else
				self:moveCells(false,delay)
			end
		end

		self.drag.endX=x
	else

	end
end

function LoopView:onTouchCancelled(x, y)
	self.drag = nil
end

function LoopView:onTouchEnded(x, y)
	if self.drag.isTap then
		self:onTouchEndedWithTap(x, y)
	else
		self:onTouchEndedWithoutTap(x, y)
	end
	self.drag = nil
end

function LoopView:onTouchEndedWithTap(x, y) --点击，非拖动
	local count=#self.cells
	if count==0 or not self.rect:containsPoint(ccp(x, y)) then return end
	for i=1,count do
		if self.cells[i]:boundingBox():containsPoint(ccp(x,y)) then
			if i~=self.index then
			else
				self.cells[self.index]:onTap(x,y)
			end
		end
	end
end

function LoopView:onTouchEndedWithoutTap(x_, y_) --触摸结束后判断是否要回弹
	if #self.cells==0 then return end
end

function LoopView:getCurrentCell()
	return self.cell
end

function LoopView:judgeCanMove(isLeft)
	local pos         -- 要判断那个位置上的细包
	if isLeft then
		if self.flag==self.max then
			pos=self.min
		else
			pos=self.flag+1
		end
	else
		if self.flag==self.min then
			pos=self.max
		else
			pos=self.flag-1
		end
	end

	for k,v in pairs(self.cells) do
		if v.pos==pos  then
			return true
		end
	end

	return false
end

function LoopView:moveCells(isLeft,delay) --isLeft isUp
	if self.isMove then return end
	local canMove= self:judgeCanMove(isLeft)
	if not canMove then
		delay=self.defaultAnimateTime*2
	else
		delay= delay or self.defaultAnimateTime
		if delay > 0.8 then
			delay = 0.8
		elseif delay<0.25 then
			delay = 0.25
		end
	end
	local count=#self.cells
	if count==0 then return end


	self.isMove=true                              --move的执行以便做判断细胞是否在move

	local seq = transition.sequence({
		CCDelayTime:create(delay),
		CCCallFunc:create(function()self.isMove=false
		end),
	})
	self:runAction(seq)

	for i=1,count do
		local cell=self.cells[i]
		cell:stopAllActions()
		local action
		if isLeft then
			if canMove then
				if cell.pos==self.flag then cell:unSelect() end
				cell.pos=cell.pos-1
				if cell.pos==self.flag then self.cell=cell end
				if cell.pos==self.min-1 then
					cell.pos=self.max
					cell:setPosition(self.points[cell.pos+1])
				end

				if cell.pos==self.flag then cell:select() end

				action=CCMoveTo:create(delay,self.points[cell.pos])
			else
				action = transition.sequence({
					CCMoveTo:create(delay/2,self.points[cell.pos-1]),
					CCMoveTo:create(delay/2,self.points[cell.pos]),
				})
			end
			cell:runAction(action)
		else
			if canMove then
				if cell.pos==self.flag then cell:unSelect() end
				cell.pos=cell.pos+1
				if cell.pos==self.flag then self.cell=cell end
				if cell.pos==self.max+1 then
					cell.pos=self.min
					cell:setPosition(self.points[cell.pos-1])
				end
				if cell.pos==self.flag then cell:select() end
				action=CCMoveTo:create(delay,self.points[cell.pos])
			else
				action = transition.sequence({
					CCMoveTo:create(delay/2,self.points[cell.pos+1]),
					CCMoveTo:create(delay/2,self.points[cell.pos]),
				})
			end
			cell:runAction(action)
		end
	end

	self:changeButton()
end

function LoopView:addCell(cell)
	assert(self.flag,"LoopView has full cell")
	if tolua.isnull(cell) or not self.index then return end
	table.insert(self.cells,cell)

	cell.pos=self.index
	cell:setPosition(self.points[cell.pos].x,self.points[cell.pos].y)
	self.view:addChild(cell)

	if self.index==self.flag then                        -- 是显示选中的那个位置
		cell:select()
		self.cell=cell
	else
		cell:unSelect()                                  -- 其他位置
	end
	self.index=self.index+1
	cclog("max"..self.max.."  min"..self.min.."--self.index"..self.index)
	if self.index==self.flag then
		self.index=nil
	elseif self.index>self.max then
		self.index=self.min
	end
	self:changeButton()
end

function LoopView:removeAllCell()
	for k,cell in pairs(self.cells) do
		self.view:removeChild(cell,true)
	end
	self.cells={}
	self.index=self.flag
end


return LoopView
