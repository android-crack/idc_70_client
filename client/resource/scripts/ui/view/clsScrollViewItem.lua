--2016/10/31
--create by wmh0497
--滚动页面cell

--[[
size:滚动页面宽和高
cell_date：外部传入数据
params:
    is_widget: 是否是cocosStudio页面， 不填默认为true
--]]
local ClsScrollViewItem = class("ClsScrollViewItem", function(size, cell_date, params)
        params = params or {}
        if false == params.is_widget then
            return CCSprite:create()
        end
        return UIWidget:create()
    end)

function ClsScrollViewItem:ctor(size, cell_date, params)
	params = params or {}
	self.m_params = params
	self.m_width = size.width
	self.m_height = size.height
	self.m_cell_date = cell_date
	self.m_cell_ui = nil
	self.m_is_widget = true
	self.m_is_create = false
	self.m_scroll_view = nil
	self.m_is_init_ui = false
	if false == self.m_params.is_widget then
		self.m_is_widget = false
	end
	self:init()
end

----------可重载开始-------------------------------------------
--初始化自己的数据
function ClsScrollViewItem:init()
end

--添加cell各自特有的ui块，这个是非重用的，请注意，使用addChild加，只会调用一次
function ClsScrollViewItem:initUI(cell_date)
end

--会调用多次的，请注意
function ClsScrollViewItem:updateUI(cell_date, cell_ui)
end

--设置触摸事件
function ClsScrollViewItem:setTouch(is_enable)
end

--选中cell项的回调
function ClsScrollViewItem:onTap(x, y)
end

function ClsScrollViewItem:onLongTap(x, y)
end

function ClsScrollViewItem:onTouchBegan(x, y)
end
function ClsScrollViewItem:onTouchCancelled()
end
----------可重载结束-------------------------------------------

function ClsScrollViewItem:setScoreView(scroll_view)
	self.m_scroll_view = scroll_view
end

function ClsScrollViewItem:getScoreView()
	return self.m_scroll_view
end

function ClsScrollViewItem:setCellUI(cell_ui)
    self.m_cell_ui = cell_ui
end

function ClsScrollViewItem:getCellUI(cell_ui)
    return self.m_cell_ui
end

function ClsScrollViewItem:getHeight()
    return self.m_height
end

function ClsScrollViewItem:setHeight(height)
	if self.m_height ~= height then
		self.m_height = height
		if not tolua.isnull(self.m_scroll_view) then
			self.m_scroll_view:resetScoreViewSize()
		end
	end
end

function ClsScrollViewItem:getWidth()
    return self.m_width
end

function ClsScrollViewItem:setWidth(width)
	if self.m_width ~= width then
		self.m_width = width
		if not tolua.isnull(self.m_scroll_view) then
			self.m_scroll_view:resetScoreViewSize()
		end
	end
end

function ClsScrollViewItem:callUpdateUI()
    if not self.m_is_init_ui then
        self.m_is_init_ui = true
        self:initUI(self.m_cell_date)
    end
    self:updateUI(self.m_cell_date, self.m_cell_ui)
end

function ClsScrollViewItem:setIsCreate(is_create)
    self.m_is_create = is_create
end

function ClsScrollViewItem:getIsCreate()
    return self.m_is_create
end

return ClsScrollViewItem