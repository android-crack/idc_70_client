--create by pyq0639 17/03/23
local strategy_conf = require("game_config/strategy/strategy_conf")
local strategy_text = require("game_config/strategy/strategy_text")
local ClsStrategyList = require("gameobj/strategy/clsStrategyList")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsStrategyUI = class("ClsStrategyUI", ClsBaseView)

local tab_pos = {
    ccp(99, 462),
    ccp(99, 387),
}

function ClsStrategyUI:getViewConfig()
    return {
        name = "ClsStrategyUI",
    }
end

function ClsStrategyUI:onEnter(tab, index)
	self.s_type = tab or 1
	self.s_index = index
	self.isRunning = false
	self.child_btn_panel = {}
	self._tab_btn_list = {}

	self:initUi()
	self:defaultSelect()
end

function ClsStrategyUI:initUi()
	self.main_panel = GUIReader:shareReader():widgetFromJsonFile("json/strategy.json")
	self:addWidget(self.main_panel)

	self.btn_bg = getConvertChildByName(self.main_panel, "btn_bg")
	self.btn_bg:setVisible(true)
    self.btn_bg:setAnchorPoint(ccp(0, 0))

    self.btn_close = getConvertChildByName(self.main_panel, "close_btn")
    self.btn_close:addEventListener(function()
    	self:close()
    end, TOUCH_EVENT_ENDED)

	for k,v in ipairs(strategy_conf) do
		local tab_btn_ui = GUIReader:shareReader():widgetFromJsonFile("json/strategy_tab.json")
		self._tab_btn_list[k] = getConvertChildByName(tab_btn_ui, "tab_open")
		self._tab_btn_list[k]:setPosition(tab_pos[k])
		self._tab_btn_list[k].label = getConvertChildByName(tab_btn_ui, "text_open")
		self._tab_btn_list[k].label:setText(v.name)
		self._tab_btn_list[k]:setTouchEnabled(true)
		self._tab_btn_list[k]:addEventListener(function()
			self:expandChildAndAdapt(k)
		end, TOUCH_EVENT_ENDED)
		self.main_panel:addChild(tab_btn_ui)
	end
end

function ClsStrategyUI:expandChildAndAdapt(tab)
	if self.isRunning then return end
	self.s_type = tab
	self.s_index = nil
	
	self:resetChildPanel()

	for k,v in ipairs(strategy_conf) do
        self._tab_btn_list[k]:setFocused(false)
        self._tab_btn_list[k]:setTouchEnabled(true)
        setUILabelColor(self._tab_btn_list[k].label, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
    end
    self._tab_btn_list[tab]:setFocused(true)
    self._tab_btn_list[tab]:setTouchEnabled(false)
    setUILabelColor(self._tab_btn_list[tab].label, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))

    self:showListUi()
end

function ClsStrategyUI:resetChildPanel()
	for i,v in pairs(self.child_btn_panel) do
        if not tolua.isnull(v) then
            v:removeFromParentAndCleanup(true)
        end
    end
    self.child_btn_panel = {}
    self._tab_btn_list[self.s_type].child = {}

    local bg_height = 43 * (#strategy_conf[self.s_type].little_name)
    for i, id in ipairs(strategy_conf[self.s_type].little_name) do
    	if strategy_text[id] then
			local child_btn_ui = GUIReader:shareReader():widgetFromJsonFile("json/strategy_btn.json")
			self._tab_btn_list[self.s_type].child[id] = {}
			self._tab_btn_list[self.s_type].child[id].btn = getConvertChildByName(child_btn_ui, "btn")
			self._tab_btn_list[self.s_type].child[id].label = getConvertChildByName(child_btn_ui, "btn_text")
			setUILabelColor(self._tab_btn_list[self.s_type].child[id].label, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
			self._tab_btn_list[self.s_type].child[id].label:setText(strategy_text[id].name)

			self._tab_btn_list[self.s_type].child[id].btn:setTouchEnabled(true)
			self._tab_btn_list[self.s_type].child[id].btn:addEventListener(function()
				self:selectChild(id)
			end, TOUCH_EVENT_ENDED)
			
			self.child_btn_panel[i] = UIWidget:create()
	        self.child_btn_panel[i]:addChild(child_btn_ui)
	        self.child_btn_panel[i]:setPosition(ccp(-62, -i *43))
	        self.btn_bg:addChild(self.child_btn_panel[i])

	        self.btn_bg:setAnchorPoint(ccp(0.5, 1))
	        self.btn_bg:setScale9Size(CCSize(140, bg_height + 2))
		end
    end

    local DELAY_TIME = 0.25
    local array_obj = CCArray:create()
    local pos_y = tab_pos[self.s_type].y - 38
    self.btn_bg:setPosition(ccp(80, pos_y))
    self.isRunning = true
    self.btn_bg:setScaleY(0)
    array_obj:addObject(CCScaleTo:create(DELAY_TIME, 1, 1))
    array_obj:addObject(CCCallFuncN:create(function()
        self.isRunning = false
    end))
    self.btn_bg:runAction(CCSequence:create(array_obj))

    for i = 1, 2 do
        local btn = self._tab_btn_list[i]
        btn:setPosition(ccp(tab_pos[i].x, tab_pos[i].y))
        if i > self.s_type then
            btn:runAction(CCMoveBy:create(DELAY_TIME, ccp(0, - bg_height - 5)))
        end
    end
end

function ClsStrategyUI:selectChild(index)
	if not self._tab_btn_list[self.s_type] or not self._tab_btn_list[self.s_type].child then
		return
	end
	self.s_index = index
	for k,v in pairs(self._tab_btn_list[self.s_type].child) do
		v.btn:setFocused(false)
		v.btn:setTouchEnabled(true)
		setUILabelColor(v.label, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
	end
	local select_info = self._tab_btn_list[self.s_type].child[index]
	select_info.btn:setFocused(true)
	select_info.btn:setTouchEnabled(false)
	setUILabelColor(select_info.label, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))

	self:showListUi()
end

function ClsStrategyUI:defaultSelect()
	if self.s_type then
		local child_index = self.s_index
		self:expandChildAndAdapt(self.s_type)
		if child_index then
			self:selectChild(child_index)
		end
	end
end

function ClsStrategyUI:showListUi()
	if not tolua.isnull(self.m_list_ui) then
		self.m_list_ui:removeFromParent()
		self.m_list_ui = nil
	end
	self.m_list_ui = ClsStrategyList.new(self.s_type, self.s_index)
	self:addWidget(self.m_list_ui)
end

return ClsStrategyUI