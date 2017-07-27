--2016/11/01
--create by wmh0497
--滚动页面基类

--[[ 使用范例
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsTestItem = class("testItem", ClsScrollViewItem)
function ClsTestItem:init()
end
function ClsTestItem:updateUI(cell_date, cell_ui)
    local text_lab = cell_ui.text_lab
    if text_lab.setText then
        text_lab:setText("key = " .. cell_date.key)
    else
        text_lab:setString("key = " .. cell_date.key)
    end
end

local testView = class("testView", ClsBaseView)

function testView:onEnter(index)
    --cocosStudio的， is_fit_bottom = true是滑动到底部时最后一个cell在底下，而不是在顶上
    local score_view = ClsScrollView.new(200, 215, true, function()
            local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/test_btn.json")
            cell_ui.text_lab = getConvertChildByName(cell_ui, "giveup_text")
            return cell_ui
        end, {is_fit_bottom = true})
    score_view:setPosition(ccp(200, 200))
    self:addWidget(score_view)
    
    local cells = {}
    for i = 1, 20 do
        cells[i] = ClsTestItem.new(CCSize(140, 40), {key = i})
    end
    score_view:addCells(cells)
    
    --非cocosStudio, 需要传入参数is_widget = false
    local score_view2 = ClsScrollView.new(400, 215, true, function()
            local cell_ui = self:createButton({image = "#common_btn_blue1.png", text = "66666"})
            cell_ui.text_lab = cell_ui:getTitleLabel()
            cell_ui:setPosition(ccp(100, 0))
            return cell_ui
        end, {is_widget = false})
    score_view2:setPosition(ccp(400, 200))
    self:addChild(score_view2)
    
    local cells = {}
    for i = 1, 20 do
        cells[i] = ClsTestItem.new(CCSize(140, 40), {key = i}, {is_widget = false})
    end
    score_view2:addCells(cells)
    score_view2:regTouch(self) --非cocosStudio需要向ui注册触摸事件
    
    --删除全部项
    score_view2:removeAllCells()
end  --]]


--[[
width, height:滚动页面宽和高
is_vertical：是否是垂直滚动
ui_cretae_func：cell的ui创建方法，要有return
params:
    is_widget: 是否是cocosStudio页面， 不填默认为true
    is_fit_bottom: 是否底部时最后一个cell在底下 默认为false
	update_logic: 选择更新cell的优先方式
		不填: base模式
		base: 优先创建视野内的和滑动向下的内容（一般用这个，不填即可）
		down: 优先创建列表里靠后的内容和滑动向上的内容（如聊天框可用这个）
--]]
local MOVE_RESET_TIME = 0.3
local ClsScrollView = class("ClsScrollView", function(width, height, is_vertical, ui_cretae_func, params) 
        params = params or {}
        if params.is_widget == false then
            return CCSprite:create()
        end
        return UILayout:create() 
    end)

function ClsScrollView:ctor(width, height, is_vertical, ui_cretae_func, params)
	params = params or {}
	self.m_is_vertical = is_vertical or false
	self.m_width = width
	self.m_height = height
	self.m_ui_cretae_func = ui_cretae_func
	self.m_cells = {}
	self.m_params = params
	self.m_drag = nil
	self.m_drag_move_len = 10
	self.m_is_fit_bottom = params.is_fit_bottom or false
	self.m_update_logic_param = params.update_logic or "base"
	self.m_update_logic = nil

	self.m_is_touch_enable = true
	self.m_is_widget = true
	if false == self.m_params.is_widget then
		self.m_is_widget = false
	end
	self:init()
end

function ClsScrollView:init()

	local update_logic_clazz = nil
	if self.m_update_logic_param == "down" then
		update_logic_clazz = require("ui/view/clsScrollViewUpdateDownLogic")
	else
		update_logic_clazz = require("ui/view/clsScrollViewUpdateBaseLogic")
	end
	self.m_update_logic = update_logic_clazz.new(self)
    
    self.m_inner_layer = nil
    if self.m_is_widget then
        self.m_inner_layer = UILayout:create()
        self:addChild(self.m_inner_layer)
        self:setClippingEnable(true)
    else
        self.m_clip_node = CCClippingNode:create()
        self:addChild(self.m_clip_node)
        local draw_node = CCDrawNode:create()
        draw_node:setPosition(ccp(0, 0))
        self.m_clip_node:setStencil(draw_node)
        self.m_clip_node:setInverted(false)
        self.m_clip_node.draw_node = draw_node
        
        self.m_inner_layer = CCSprite:create()
        self.m_inner_layer:setAnchorPoint(ccp(0,0))
        self.m_clip_node:addChild(self.m_inner_layer)
        
        self.m_inner_layer.setSize = function(my_spr, size)
                my_spr:setContentSize(size)
            end
        self.m_inner_layer.getSize = function(my_spr)
            return my_spr:getContentSize()
        end
    end
    
    --注意，非cocosStuido的需要注册触摸事件
    if self.m_is_widget then
        self:addEventListener(function()
                local pos = self:getTouchStartPos()
                self:onTouchBegan(pos.x, pos.y)
            end, TOUCH_EVENT_BEGAN)
        self:addEventListener(function()
                local pos = self:getTouchMovePos()
                self:onTouchMoved(pos.x, pos.y)
            end, TOUCH_EVENT_MOVED)
        self:addEventListener(function()
                local pos = self:getTouchEndPos()
                self:onTouchEnded(pos.x, pos.y)
            end, TOUCH_EVENT_ENDED)
        self:addEventListener(function()
                self:onTouchCancelled()
            end, TOUCH_EVENT_CANCELED)
        self:setTouchEnabled(true)
    end
    
    self:setViewSize(CCSize(self.m_width, self.m_height))
    self:setInnerContainerSize(self.m_width, self.m_height)
    self:setAnchorPoint(ccp(0,0))
    
	self.m_timer_spr = nil
	self.m_long_touch_spr = nil
	if self.m_is_widget then
		self.m_timer_spr = UIWidget:create()
		self.m_long_touch_spr = UIWidget:create()
	else
		self.m_timer_spr = CCSprite:create()
		self.m_long_touch_spr = CCSprite:create()
	end
	self:addChild(self.m_timer_spr)
	self:addChild(self.m_long_touch_spr)
	self.m_timer_spr.is_open = false
	self.m_timer_spr.delay_close_time = nil
end

function ClsScrollView:getStandardPos(node)
    if self.m_is_widget then
        return node:getPosition()
    end
    local pos = {}
    pos.x, pos.y = node:getPosition()
    return pos
end

function ClsScrollView:getCurClock()
	return CCTime:getmillistimeofCocos2d()/1000
end

function ClsScrollView:regTouch(view_obj, order_n)
    if not tolua.isnull(view_obj) then
        order_n = order_n or 0
        local touch_func = function(event, x, y)
            if event == "began" then
                return self:onTouchBegan(x, y)
            elseif event == "moved" then
                self:onTouchMoved(x, y)
            elseif event == "ended" then 
                self:onTouchEnded(x, y)
            else
                self:onTouchCancelled()
            end
        end
        view_obj:regTouchEvent(self, touch_func, order_n)
    end
end

function ClsScrollView:setViewSize(size)
    if self.m_is_widget then
        self:setSize(size)
    else
        local color = ccc4f(0, 1, 0, 1)
        local points = CCPointArray:create(4)
        points:add(ccp(0, 0))
        points:add(ccp(0, size.height))
        points:add(ccp(size.width, size.height))
        points:add(ccp(size.width, 0))
        self.m_clip_node.draw_node:clear()
        self.m_clip_node.draw_node:drawPolygon(points, color, 0, color)
        self:setContentSize(CCSize(self.m_width, self.m_height))
    end
end

function ClsScrollView:setInnerContainerSize(width, height)
    local inner_width = self.m_width
    local inner_height = self.m_height
    if width > inner_width then
        inner_width = width
    end
    if height > inner_height then
        inner_height = height
    end
    
    self.m_inner_layer:setSize(CCSize(inner_width, inner_height))
end

function ClsScrollView:getInnerLayer()
    return self.m_inner_layer
end

function ClsScrollView:getIsVertical()
	return self.m_is_vertical
end

function ClsScrollView:getWidth()
	return self.m_width
end

function ClsScrollView:getHeight()
	return self.m_height
end

function ClsScrollView:getUICretaeFunc()
	return self.m_ui_cretae_func
end

function ClsScrollView:startLongTouchCount(time_n)
	local delay_act = CCDelayTime:create(1)
	local call_act = CCCallFunc:create(function()
			if self.m_drag and (not tolua.isnull(self.m_drag.cell)) and self.m_drag.is_tap and time_n == self.m_drag.start_time then
				self.m_drag.cell:onLongTap(self.m_drag.start_x, self.m_drag.start_y)
			end
		end)
	local seq_act = CCSequence:createWithTwoActions(delay_act, call_act)
	self.m_long_touch_spr:stopAllActions()
	self.m_long_touch_spr:runAction(seq_act)
end

function ClsScrollView:isInTouchView(x, y)
    --cocosStudio不需要判断点击范围，基本都是点中的
    if self.m_is_widget then return true end

    local pos = self:convertToNodeSpace(ccp(x,y))
    local anchor_pos = self:getAnchorPoint()
    local touch_x = -self.m_width * anchor_pos.x
    local touch_y = -self.m_height * anchor_pos.y
    local touch_rect = CCRect(touch_x, touch_y, self.m_width, self.m_height)
    return touch_rect:containsPoint(pos)
end

function ClsScrollView:isInViewByPos(x, y)
    local world_pos = self:getWorldPosition()
    local touch_rect = CCRect(world_pos.x, world_pos.y, self.m_width, self.m_height)
    return touch_rect:containsPoint(ccp(x, y))
end

function ClsScrollView:onTouchBegan(x, y)

    if not self.m_is_touch_enable then return end
    if not self:isInTouchView(x, y) then return false end

    local pos = self:getStandardPos(self.m_inner_layer)
    local cell_index, cell = self:getTouchCell(x, y)
	local cur_time = self:getCurClock()
    self.m_drag = {
        start_x = x,
        start_y = y,
        start_layer_x = pos.x,
        start_layer_y = pos.y,
        end_x = x,
        end_y = y,
        is_tap = true,
        cell_index = cell_index,
        cell = cell,
        start_time = cur_time,
    }
    self.m_inner_layer:stopAllActions()
    self:startLongTouchCount(cur_time)
    if cell then
        cell:onTouchBegan(x, y)
    end
    
    return true
end

local math_abs = math.abs
function ClsScrollView:onTouchMoved(x, y)
    if not self.m_drag then return end
    
    self.m_drag.end_x = x
    self.m_drag.end_y = y
    local is_cell_cancell = false
    if not self.m_is_vertical then
        if self.m_drag.is_tap and math_abs(x - self.m_drag.start_x) >= self.m_drag_move_len then
            self.m_drag.is_tap = false
            is_cell_cancell = true
        end
    else
        if self.m_drag.is_tap and math.abs(y - self.m_drag.start_y) >= self.m_drag_move_len then
            self.m_drag.is_tap = false
            is_cell_cancell = true
        end
    end
    if is_cell_cancell then
        if not tolua.isnull(self.m_drag.cell) then
            self.m_drag.cell:onTouchCancelled()
        end
        self.m_drag.cell = nil
        self.m_drag.cell_index = nil
    end
    self.m_inner_layer:stopAllActions()
    self:updateLayerMove()
end

function ClsScrollView:onTouchEnded(x, y)
	if not self.m_drag then return end
	self.m_drag.end_x = x
	self.m_drag.end_y = y
	self:updateLayerMove()
	local drag_info = self.m_drag
	self.m_drag = nil
	self.m_inner_layer:stopAllActions()
	self.m_long_touch_spr:stopAllActions()
	self:releaseTouchBack()
	--在最后触发，因为可能出现在onTap对listView进行删除
	self:tryToTap(drag_info)
end

function ClsScrollView:onTouchCancelled()
    self.m_drag = nil
    self.m_inner_layer:stopAllActions()
	self.m_long_touch_spr:stopAllActions()
    self:releaseTouchBack()
end

function ClsScrollView:updateLayerMove()
    if not self.m_drag then return end
    if self.m_drag.is_tap then return end
    
    if not self.m_is_vertical then
        self.m_inner_layer:setPosition(ccp(self.m_drag.end_x - self.m_drag.start_x + self.m_drag.start_layer_x, self.m_drag.start_layer_y))
    else
        self.m_inner_layer:setPosition(ccp(self.m_drag.start_layer_x, self.m_drag.end_y - self.m_drag.start_y + self.m_drag.start_layer_y))
    end
    self:openUpdateTimer()
end

---------------------------------上面就是一个单独滚动层需要的东东，下面就是跟cell有关啦------------------------------------------------------

function ClsScrollView:setTouch(is_enable)
    if self.m_is_touch_enable ~= is_enable then
        self.m_is_touch_enable = is_enable
        if self.m_is_widget then
            self:setTouchEnabled(is_enable)
        end
        for _, cell in ipairs(self.m_cells) do
            if cell:getIsCreate() then
                cell:setTouch(is_enable)
            end
        end
    end
end

function ClsScrollView:isTouch()
    return self.m_is_touch_enable
end

function ClsScrollView:getCells()
    return self.m_cells or {}
end

--如果没有cell，则会返回nil
function ClsScrollView:getTopCellIndex()
    local cell_info = self:getTopNearCellInfo()
    if cell_info then
        return cell_info.id
    end
end

function ClsScrollView:scrollToCellIndex(index_n)
    if self.m_cells and index_n and self.m_cells[index_n] then
        local cell = self.m_cells[index_n]
        local layer_pos = self:getStandardPos(self.m_inner_layer)
        local cell_pos = self:getStandardPos(cell)
        if self.m_is_vertical then
            local new_pos_y = self.m_height - cell_pos.y - cell:getHeight()
            if self.m_is_fit_bottom then
                if new_pos_y + self.m_height > self.m_inner_layer:getSize().height then
                    new_pos_y = self.m_inner_layer:getSize().height - self.m_height
                end
            end
            self:moveAction(layer_pos.x, new_pos_y)
        else
            local new_pos_x = -cell_pos.x
            if self.m_is_fit_bottom then
                if new_pos_x < (self.m_width - self.m_inner_layer:getSize().width) then
                    new_pos_x = self.m_width - self.m_inner_layer:getSize().width
                end
            end
            self:moveAction(new_pos_x, layer_pos.y)
        end
        self:setDelayCloseTimer(MOVE_RESET_TIME + 0.1)
        self:openUpdateTimer()
    end
end

--调用updateUI
function ClsScrollView:updateCell(cell)
    if not tolua.isnull(cell) and (cell:getIsCreate()) then
        cell:callUpdateUI()
    end
end

function ClsScrollView:updateCellIndex(index_n)
    local cell = self.m_cells[index_n]
    self:updateCell(cell)
end

local math_abs = math.abs
function ClsScrollView:releaseTouchBack()
    if self.m_drag then return end
    
    local layer_pos = self:getStandardPos(self.m_inner_layer)
    if self.m_is_vertical then
        local layer_pos_y = layer_pos.y
        if layer_pos_y < 0 then
            self:moveAction(layer_pos.x, 0)
            return
        end
        
        local near_cell_info = self:getTopNearCellInfo()
        if near_cell_info then
            local new_pos_y = layer_pos_y + near_cell_info.offset_y
            if self.m_is_fit_bottom then
                if new_pos_y + self.m_height > self.m_inner_layer:getSize().height then
                    new_pos_y = self.m_inner_layer:getSize().height - self.m_height
                end
            end
            self:moveAction(layer_pos.x, new_pos_y)
        end
    else
        local layer_pos_x = layer_pos.x
        if layer_pos_x > 0 then
            self:moveAction(0, layer_pos.y)
            return
        end
        
        local near_cell_info = self:getTopNearCellInfo()
        if near_cell_info then
            local new_pos_x = layer_pos_x - near_cell_info.offset_x
            if self.m_is_fit_bottom then
                if new_pos_x < (self.m_width - self.m_inner_layer:getSize().width) then
                    new_pos_x = self.m_width - self.m_inner_layer:getSize().width
                end
            end
            self:moveAction(new_pos_x, layer_pos.y)
        end
    end
end

function ClsScrollView:getTopNearCellInfo()
    local near_cell_info = nil
    local layer_pos = self:getStandardPos(self.m_inner_layer)
    if self.m_is_vertical then
        for i, cell in ipairs(self.m_cells) do
            local pos_y = self:getStandardPos(cell).y
            local offset_y = self.m_height - (pos_y + layer_pos.y + cell:getHeight())
            local dis_n = math_abs(offset_y)
            if near_cell_info then
                if near_cell_info.dis > dis_n then
                    near_cell_info.dis = dis_n
                    near_cell_info.offset_y = offset_y
                    near_cell_info.id = i
                end
            else
                near_cell_info = {}
                near_cell_info.dis = dis_n
                near_cell_info.offset_y = offset_y
                near_cell_info.id = i
            end
        end
    else
        for i, cell in ipairs(self.m_cells) do
            local pos_x = self:getStandardPos(cell).x
            local offset_x = pos_x + layer_pos.x
            local dis_n = math_abs(offset_x)
            if near_cell_info then
                if near_cell_info.dis > dis_n then
                    near_cell_info.dis = dis_n
                    near_cell_info.offset_x = offset_x
                    near_cell_info.id = i
                end
            else
                near_cell_info = {}
                near_cell_info.dis = dis_n
                near_cell_info.offset_x = offset_x
                near_cell_info.id = i
            end
        end
    end
    return near_cell_info
end

function ClsScrollView:tryToTap(drag_info)
    if not drag_info then return end
    if not drag_info.is_tap then return end
    local index, cell = self:getTouchCell(drag_info.end_x, drag_info.end_y)
    if cell then
        cell:onTap(drag_info.end_x, drag_info.end_y)
    end
end

function ClsScrollView:getTouchCell(world_x, world_y)
    local layer_pos = nil
    if self.m_is_widget then
        layer_pos = self.m_inner_layer:getWorldPosition()
    else
        layer_pos = self.m_inner_layer:convertToWorldSpace(ccp(0,0))
    end
    local touch_x = world_x - layer_pos.x
    local touch_y = world_y - layer_pos.y
    for index, cell in ipairs(self.m_cells) do
        if not tolua.isnull(cell) then
            if self:isInCell(cell, touch_x, touch_y) and cell:getIsCreate() then
                return index, cell
            end
        end
    end
    return nil, nil
end

function ClsScrollView:isInCell(cell, touch_x, touch_y)
    local pos = self:getStandardPos(cell)
    if pos.x <= touch_x and touch_x <= (pos.x + cell:getWidth()) and 
        pos.y <= touch_y and touch_y <= (pos.y + cell:getHeight()) then
        
        return true
    end
    return false
end

function ClsScrollView:moveAction(x, y, move_end_callback)
    self.m_inner_layer:stopAllActions()
    local array = CCArray:create()
    array:addObject(CCEaseSineOut:create(CCMoveTo:create(MOVE_RESET_TIME, ccp(x,y))))
    array:addObject(CCCallFunc:create(function()
            self:openUpdateTimer()
            if type(move_end_callback) == "function" then
                move_end_callback()
            end
        end))
    self.m_inner_layer:runAction(CCSequence:create(array)) 
end

--添加cell到指定index
function ClsScrollView:addCellByIndex(cell, index)
	table.insert(self.m_cells, index, cell)
	self.m_inner_layer:addChild(cell)
	self:updateCellParent()
	self:updateScoreViewSize()
	self:openUpdateTimer()
end

--移动cell
function ClsScrollView:moveCellByIndex(cell, index)
	local temp = {}
	for k, v in ipairs(self.m_cells) do
		if cell ~= v then
			temp[#temp + 1] = v
		end
	end
	table.insert(temp, index, cell)
	self.m_cells = temp
	self:updateCellParent()
	self:updateScoreViewSize()
	self:openUpdateTimer()
end

function ClsScrollView:addCell(cell)
	table.insert(self.m_cells, cell)
	self.m_inner_layer:addChild(cell)
	self:updateCellParent()
	self:updateScoreViewSize()
	self:openUpdateTimer()
end

function ClsScrollView:addCells(cells)
	for _, cell in ipairs(cells) do
		table.insert(self.m_cells, cell)
		self.m_inner_layer:addChild(cell)
	end
	self:updateCellParent()
	self:updateScoreViewSize()
	self:initScoreViewItemShow()
	self:openUpdateTimer()
end

function ClsScrollView:removeAllCells()
    for _, cell in ipairs(self.m_cells) do
        cell:removeFromParentAndCleanup(true)
    end
    self.m_cells = {}
    self:updateScoreViewSize()
    self:releaseTouchBack()
end

function ClsScrollView:removeCell(remove_cell)
	for key, cell in ipairs(self.m_cells) do
		if cell == remove_cell then
			table.remove(self.m_cells, key)
			cell:removeFromParentAndCleanup(true)
			self:updateScoreViewSize()
			self:updateLayerMove()
			self:releaseTouchBack()
			self:openUpdateTimer()
			return
		end
	end
end

--如果cell的大小有变，可调用这个
function ClsScrollView:resetScoreViewSize()
	self:updateScoreViewSize()
	self:releaseTouchBack()
	self:openUpdateTimer()
end

--更新滚动页面大小
function ClsScrollView:updateScoreViewSize()
    local len_n = #self.m_cells
    if self.m_is_vertical then
        local height_n = 0
        for i = 1, len_n do
            local cell = self.m_cells[i]
            height_n = height_n + cell:getHeight()
            cell:setPosition(ccp(0, self.m_height - height_n))
        end
        
        if height_n < self.m_height then
            height_n = self.m_height
        end
        self:setInnerContainerSize(self.m_width, height_n)
    else
        local width_n = 0
        for i = 1, len_n do
            local cell = self.m_cells[i]
            cell:setPosition(ccp(width_n, 0))
            width_n = width_n + cell:getWidth()
        end
        
        if width_n < self.m_width then
            width_n = self.m_width
        end
        self:setInnerContainerSize(width_n, self.m_height)
    end
end

function ClsScrollView:updateCellParent()
	for _, cell in ipairs(self.m_cells) do
		cell:setScoreView(self)
	end
end

--初始化，创建ScoreView初始化页面
function ClsScrollView:initScoreViewItemShow()
    if self.m_is_vertical then
        local height_n = 0
        for i, cell in ipairs(self.m_cells) do
            height_n = height_n + cell:getHeight()
            self:uiUpdateTimer()
            if height_n >= self.m_height then
                break
            end
        end
    else
        local width_n = 0
        for i, cell in ipairs(self.m_cells) do
            width_n = width_n + cell:getWidth()
            self:uiUpdateTimer()
            if width_n >= self.m_width then
                break
            end
        end
    end
end

function ClsScrollView:openUpdateTimer()
    if self.m_timer_spr.is_open then
        return
    end
    self.m_timer_spr.is_open = true
    self.m_timer_spr:stopAllActions()
    local delay_act = CCDelayTime:create(0.01)
    local call_act = CCCallFunc:create(function()
            if self.m_timer_spr.delay_close_time then
                if self.m_timer_spr.delay_close_time <= self:getCurClock() then
                    self.m_timer_spr.delay_close_time = nil
                end
            end
            if (not self:uiUpdateTimer()) and (not self.m_timer_spr.delay_close_time) then
                self.m_timer_spr.is_open = false
                self.m_timer_spr:stopAllActions()
            end
        end)
    local seq_act = CCSequence:createWithTwoActions(delay_act, call_act)
    self.m_timer_spr:runAction(CCRepeatForever:create(seq_act))
end

function ClsScrollView:setDelayCloseTimer(delay_time_n)
    self.m_timer_spr.delay_close_time = self:getCurClock() + delay_time_n
end

function ClsScrollView:uiUpdateTimer()
    return self.m_update_logic:updateCellHander()
end

function ClsScrollView:scrollEndPos()
	if self.m_is_vertical then
		local new_pos_y = self.m_inner_layer:getSize().height - self.m_height
		self.m_inner_layer:setPosition(ccp(0, new_pos_y))
	else
		local new_pos_x = self.m_width - self.m_inner_layer:getSize().width
		self.m_inner_layer:setPosition(ccp(new_pos_x, 0))
	end
	self:openUpdateTimer()
end

return ClsScrollView