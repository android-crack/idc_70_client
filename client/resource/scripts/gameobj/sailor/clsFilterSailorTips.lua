local ListCell = require("ui/tools/ListCell")
local ListView = require("ui/tools/ListView")
local element_mgr = require("base/element_mgr")
local ui_word = require("scripts/game_config/ui_word")
local music_info = require("game_config/music_info")

local ClsFilterSailorTipsCell = class("ClsFilterSailorTipsCell",ListCell) 
function ClsFilterSailorTipsCell:setData(data, order)
    local order_data = ": "..ui_word.DOWN_ORDER
    if  order then
        order_data = ": "..ui_word.UP_ORDER
    end
    if data == ui_word.SAILOR_STORY_MISSION then
        order_data =""
    end
	local title_label = createRichLabel(data..order_data, 160, 20, 16, nil, true)
	title_label:ignoreAnchorPointForPosition(false)
	title_label:setAnchorPoint(ccp(0.5,0.5))
	title_label:setPosition(86,19)
	title_label:setTag(1)
	self:addChild(title_label)
end

function ClsFilterSailorTipsCell:changBg(selected)
   if selected then
        self.bg = display.newSprite("#common_btn_screen.png", 10, 0)
        self.bg:setAnchorPoint(ccp(0, 0))
        self:addChild(self.bg, -1)
    else
        if not tolua.isnull(self.bg) then
            self.bg:removeFromParentAndCleanup(true)
        end
    end	
end



----------------------------------------------------------------------
local ClsFilterSailorTips = class("ClsFilterSailorTips", function() return display.newLayer() end)

function ClsFilterSailorTips:ctor(parent, temp, type_num, is_sailor_order)
	element_mgr:add_element("ClsFilterSailorTips", self)

	self.parent = parent
	self.temp = temp
	if not type_num then
		type_num = 1
	end
	self.type_num = type_num
    self.is_sailor_order = is_sailor_order
	local uiLayer = UILayer:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/captain_info_title.json")
	convertUIType(self.panel)
	uiLayer:addWidget(self.panel)
	uiLayer:setPosition(self.temp.pos)
	self:addChild(uiLayer)

	self:initUI()

	self:registerScriptTouchHandler(function(event, x, y)
	return self:onTouch(event, x, y) end)
	self:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)	
end

function ClsFilterSailorTips:initUI()

    local cur_titles = {
	    ui_word.BOAT_BAOWU_COLLECT_STAR,
	    ui_word.SAILOR_STAR,
	    ui_word.STR_FRIEND_LV,
	    ui_word.SAILOR_STORY_MISSION,
	}


    local cells = {}
    for k, v in pairs(cur_titles) do
        local title_cell = ClsFilterSailorTipsCell.new(CCSize(182, 41))
        title_cell:setData(v, self.is_sailor_order)

        title_cell:setTouchBeginFunc(function()
            title_cell:changBg(true)
        end)

        title_cell:setTouchCancelFunc(function()
            title_cell:changBg(false)
        end)

        title_cell:setTapFunc(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:selectTitleCell(k, title_cell)
        end)
        cells[#cells + 1] = title_cell
    end

    self:selectTitleCell(1, cells[self.type_num])
    --local listRect = CCRect(785, 60, 168, 140)  --376
    --self.temp.pos
    local listRect = CCRect(self.temp.pos.x, self.temp.pos.y+10, 168, 140)
    self.list_view = ListView.new(listRect, cells, 3, ListView.DIRECTION_VERTICAL)
    self.list_view:setTouchEnabled(true)
    self:addChild(self.list_view, 1)
	
end 

function ClsFilterSailorTips:selectTitleCell(num, cell)
    cell:changBg(true)
    if self.last_selectd_cell then
        self.last_selectd_cell:changBg(false)
    end
    if self.last_selectd_cell  then
        self.parent:clearTips(num)
    end


    self.last_selectd_cell = cell
end

function ClsFilterSailorTips:onTouch(event, x, y)
    if event == "began" then
        self:onTouchBegan(x, y)
    end
end

function ClsFilterSailorTips:onTouchBegan(x , y)

    if x > self.temp.pos.x and x < self.temp.pos.x + self.size.width and y > self.temp.pos.y and y < self.temp.pos.y + self.size.height then
        return true
    else
        self:removeFromParentAndCleanup(true)
        self.parent:clearTips()
        return false
    end
end

function ClsFilterSailorTips:onExit()
	element_mgr:del_element("ClsFilterSailorTips")
end
return ClsFilterSailorTips