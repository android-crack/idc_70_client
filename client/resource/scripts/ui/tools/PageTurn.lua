-- 翻页效果
local music_info=require("game_config/music_info")
local Alert = require("ui/tools/alert")
local news = require("game_config/news")

local function newUILayer()
	return CCLayer:create()
end

local PageTurn = class("PageTurn", newUILayer)

function PageTurn:ctor(rect, priority)  -- rect 为张开书的范围

	self.cells = {}
	self.currentIndex = 1
	self.rect = rect -- 触摸范围
	self.rect_cx = rect:getMidX()
	self.dragThreshold = 1 --判定滑动还是点击
	self.turnOff = 80  --翻页的条件
	self.turnNum = 0    -- 正在翻转的页数, 右翻加1，左翻减1
	self.scheduler = CCDirector:sharedDirector():getScheduler()
	self.defaultTurnLSpeedLay = 0.04
	self.defaultTurnRSpeedLay = 0.04
	self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

	-- local pri = priority or -127
    -- self:registerScriptTouchHandler(function(event, x, y)
    --     return self:onTouch(event, x, y)
    -- end, false, pri, true)
	-- self:setTouchEnabled(true)
end

function PageTurn:getCurrentCell()
	return self:getCellForIndex(self.currentIndex)
end

function PageTurn:getCellForIndex(index)
	if index > 0 and index <= #self.cells then
		return self.cells[index]
	else
		return nil
	end
end

function PageTurn:getCurrentIndex()
	return self.currentIndex
end

function PageTurn:addCell(cell)
    self:addChild(cell)
    self.cells[#self.cells + 1] = cell
    self:reorderAllCells()
end

function PageTurn:insertCellAtIndex(cell, index)
    self:addChild(cell)
    table.insert(self.cells, index, cell)
    self:reorderAllCells()
end

function PageTurn:replaceCellAtIndex(newCell, index)
    local cell = self.cells[index]
    if cell then cell:removeSelf() end

    self:addChild(newCell)
    self.cells[index] = newCell
    self:reorderAllCells()
end

function PageTurn:removeCellAtIndex(index)
    local cell = self.cells[index]
    cell:removeSelf()
    table.remove(self.cells, index)
    self:reorderAllCells()
end

function PageTurn:onTouch(event, x, y)

    if event == "began" then
		return self:onTouchBegan(x, y)
    elseif event == "moved" then
		self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    else -- cancelled
         self:onTouchCancelled(x, y)
    end
end

function PageTurn:onTouchCancelled(x, y)
   self.touchCancell = true
end

function PageTurn:onTouchBegan(x, y)
	if self.rect:containsPoint(ccp(x,y)) then
		self.touchCancell = false
		self.drag = false  --拖动
		self.curRcell = self:getCurrentCell()
		self.curLcell = self:getCellForIndex(self:getCurrentIndex() - 1)
		self.turn_book = true
		self.startPoint = {x=x, y=y}

		if x < self.rect_cx then 	 --触摸的是左边的页码(向右翻)
			self.types = -1
			self.curCell = self.curLcell
		else                         --右边的页
			self.types = 1
			self.curCell = self.curRcell
		end

		if self.turnNum ~= 0 and self.turnNum ~= self.types then
			self.touchCancell = true  --翻页过程中，不能交叉翻页
		end
		return true
	end

	return false
end

function PageTurn:onTouchMoved(x, y)
	if self.touchCancell then return end
	if self.startPoint==nil then return end
	if math.abs(x - self.startPoint.x) >= self.dragThreshold then
		self.drag = true
	end

	if self.types == -1 and x > self.startPoint.x then  --左边(向右翻)
		if self.currentIndex <= 1 then

			if self.turn_book then
				self.turn_book = false
				Alert:warning({msg = news.COLLECT_NO_SAILOR.msg})
			end
			
			return
		end
		if self.curLcell then
			if math.abs(self.startPoint.x-x) > self.turnOff then
				self.curLcell:setSkewY(-self.turnOff*0.1)
				self.curLcell:setScaleX(1-self.turnOff/200)
				self:onTouchCancelled()
				self:turnRight()
			else

				if not tolua.isnull(self.curLcell.normalNode) then
					self.curLcell.normalNode:setVisible(true)
				end

				if not tolua.isnull(self.curLcell.story_layer) then
					self.curLcell.story_layer:removeFromParentAndCleanup(true)
				end

				self.curLcell:setSkewY((self.startPoint.x - x)*0.1)
				self.curLcell:setScaleX(1-math.abs(self.startPoint.x-x)/200)
			end
		end

	elseif self.types == 1 and x < self.startPoint.x then--右边（向左翻）
		if self.currentIndex >= self.count then

			if self.turn_book then
				self.turn_book = false
				Alert:warning({msg = news.COLLECT_NO_SAILOR.msg})
			end
			return
		end

		if self.curRcell then
			if math.abs(self.startPoint.x-x) > self.turnOff then
				self.curRcell:setSkewY(self.turnOff*0.1)
				self.curRcell:setScaleX(1-self.turnOff/200)
				self:onTouchCancelled()
				self:turnLeft()
			else

				if not tolua.isnull(self.curRcell.normalNode) then
					self.curRcell.normalNode:setVisible(true)
				end

				if not tolua.isnull(self.curRcell.story_layer) then
					self.curRcell.story_layer:removeFromParentAndCleanup(true)
				end

				self.curRcell:setSkewY((self.startPoint.x - x)*0.1)
				self.curRcell:setScaleX(1-math.abs(self.startPoint.x-x)/200)
			end
		end
	end
end

function PageTurn:onTouchEnded(x, y)
	if self.touchCancell then

	elseif self.curCell and self.drag and self.startPoint then -- 恢复
		local action1 = CCSkewTo:create(math.abs(x-self.startPoint.x)*0.002, 0, 0)
		local action2 = CCScaleTo:create(math.abs(x-self.startPoint.x)*0.002, 1.0, 1.0)
		self.curCell:runAction(CCSpawn:createWithTwoActions(action1, action2))

	elseif not self.drag and self.curCell then --点击响应
		self.curCell:onTap(x,y)
	end
	self.startPoint = nil
end

function PageTurn:turnLeft(noSound) --向左翻
	if not noSound then
		local handler=audioExt.playEffect(music_info.ROOM_BOOK.res)
	end

	self.turnNum = self.turnNum + 1
	local curRcell = self.curRcell
	local curLcell = self:getCellForIndex(self.currentIndex + 1)
	self.currentIndex = self.currentIndex + 2
	local function hidePage(sender)
		sender:setVisible(false)
	end

	local function showPage(sender)
		sender:setVisible(true)
	end

	local function initType()
		self.turnNum = self.turnNum - 1
	end

	local function actionLeftPage()
		local LAction1 = CCSkewTo:create(0.45, 0, 0)
		local LAction2 = CCScaleTo:create(0.45, 1.0, 1.0)
		local Lspawn = CCSpawn:createWithTwoActions(LAction1, LAction2)
		local array = CCArray:create()
		array:addObject(CCCallFuncN:create(initType))
		array:addObject(CCCallFuncN:create(showPage))
		array:addObject(Lspawn)
		curLcell:runAction(CCSequence:create(array))
	end

	local function actionRigthPage()
		local RAction1 = CCSkewTo:create(self.defaultTurnLSpeedLay, 0, 20)
		local RAction2 = CCScaleTo:create(self.defaultTurnLSpeedLay, 0.05, 1.0)
		local Rspawn = CCSpawn:createWithTwoActions(RAction1, RAction2)
		local array = CCArray:create()
		array:addObject(Rspawn)
		array:addObject(CCCallFuncN:create(hidePage))
		array:addObject(CCCallFuncN:create(actionLeftPage))	 --actionLeftPage
		curRcell:runAction(CCSequence:create(array))
	end
	if not tolua.isnull(curRcell) then
		actionRigthPage()
	elseif not tolua.isnull(curLcell) then
		actionLeftPage()
	end
end

function PageTurn:turnRight(noSound) --向右翻
	if not noSound then
		local handler=audioExt.playEffect(music_info.ROOM_BOOK.res)
	end

	self.turnNum = self.turnNum - 1
	local curLcell = self.curLcell
	local curRcell = self:getCellForIndex(self.currentIndex - 2)
	self.currentIndex = self.currentIndex - 2

	local function hidePage(sender)
		sender:setVisible(false)
	end

	local function showPage(sender)
		sender:setVisible(true)
	end

	local function initType()
		self.turnNum = self.turnNum + 1
	end

	local function actionRigthPage()
		local RAction1 = CCSkewTo:create(0.45, 0, 0)
		local RAction2 = CCScaleTo:create(0.45, 1.0, 1.0)
		local Rspawn = CCSpawn:createWithTwoActions(RAction1, RAction2)
		local array = CCArray:create()
		array:addObject(CCCallFuncN:create(initType))
		array:addObject(CCCallFuncN:create(showPage))
		array:addObject(Rspawn)
		curRcell:runAction(CCSequence:create(array))
	end

	local function actionLeftPage()
		local LAction1 = CCSkewTo:create(self.defaultTurnRSpeedLay, 0, -20)
		local LAction2 = CCScaleTo:create(self.defaultTurnRSpeedLay, 0.05, 1.0)
		local Lspawn = CCSpawn:createWithTwoActions(LAction1, LAction2)
		local array = CCArray:create()
		array:addObject(Lspawn)
		array:addObject(CCCallFuncN:create(hidePage))
		array:addObject(CCCallFuncN:create(actionRigthPage))
		curLcell:runAction(CCSequence:create(array))
	end
	if not tolua.isnull(curLcell) then
		actionLeftPage()
	elseif not tolua.isnull(curRcell) then
		actionRigthPage()
	end
end

function PageTurn:indexPage(pageNum) --索引翻页
	local count = #self.cells --最大
	if pageNum > count then pageNum = count+1	end
	if pageNum < 1 then pageNum = 1 end
	local dPage = pageNum - self.currentIndex
	local pageCount = 0      -- 已经翻的页数
	local turnNum = math.floor(math.abs(dPage)/2) --要翻的页数
	--print(self.currentIndex, pageNum, turnNum)
	local function doStep()  --连续翻页
		self.curRcell = self:getCurrentCell()
		self.curLcell = self:getCellForIndex(self:getCurrentIndex() - 1)
		if pageCount == turnNum then

			if self.hander_time then
				self.scheduler:unscheduleScriptEntry(self.hander_time)
				self.hander_time = nil

				return
			end
		else

			pageCount = pageCount + 1
		end

		if dPage < 0 then
			self:turnRight(true)
		elseif dPage > 0 then
			self:turnLeft(true)
		end
	end

	if self.turnNum == 0  then
		self.hander_time = self.scheduler:scheduleScriptFunc(doStep, 0.1, false)
	end
end

---- private methods

function PageTurn:reorderAllCells()
	self.count = #self.cells
    for i = 1, self.count do
        if math.mod(i, 2) == 1 then --奇数，即右边显示的页
			self.cells[i]:setZOrder(self.count-i)
		else
			self.cells[i]:setZOrder(i)
			self.cells[i]:setSkewY(-20)
			self.cells[i]:setScaleX(0.05)
			self.cells[i]:setVisible(false)
		end
    end
end


function PageTurn:onEnter()
end

function PageTurn:onExit()
	if self.hander_time then
		self.scheduler:unscheduleScriptEntry(self.hander_time)
	end
end

return PageTurn
