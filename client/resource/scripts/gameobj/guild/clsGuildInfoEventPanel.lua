--
-- Author: 商会事迹面板
-- Date: 2015-12-14 16:14:01
--
local ClsMusicInfo =require("scripts/game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsGuildEventItem = class("ClsGuildEventItem", ClsScrollViewItem)

function ClsGuildEventItem:initUI(cell_date)
	self:addCCNode(cell_date)
end



local ClsGuildInfoEventPanel = class("clsGuildInfoEventPanel", ClsBaseView)

function ClsGuildInfoEventPanel:getViewConfig(...)
    return {is_back_bg = true}
end

function ClsGuildInfoEventPanel:onEnter()
	self:configUI()
	self.list_width = 383
	self.list_height = 260
	local guild_prestige_data = getGameData():getGuildPrestigeData()
	guild_prestige_data:askGuildEvent()
end

function ClsGuildInfoEventPanel:configUI()
    self.ui_layer = UIWidget:create()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_deed.json")
    convertUIType(self.panel)
    self.ui_layer:addChild(self.panel)
    self:addWidget(self.ui_layer)

    self.btn_close = getConvertChildByName(self.panel, "btn_close")

    self.btn_close:setPressedActionEnabled(true) 
    self.btn_close:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_CLOSE.res)
            self:close()
        end,TOUCH_EVENT_ENDED)
end

local function getEventTimeStr( time )
	local playerData = getGameData():getPlayerData()
	local server_time = playerData:getServerTime()
	local today = os.date("*t", server_time)
	local second_day = os.time({day = today.day, month = today.month, year = today.year, hour = 0, minute  = 0, second = 0})
	local time_str = ""
	--判断是否当天
	if time >= second_day and time < (second_day + 24 * 60 * 60) then
		time_str = os.date("%H:%M", time)
	else
		time_str = os.date("%m-%d", time)
	end
	return string.format(ui_word.NAME_BOX_2, time_str)
end

function ClsGuildInfoEventPanel:updateEventList(data)
	if not tolua.isnull(self.story_des_view) then
		self.story_des_view:removeAllCells()
	end
	table.sort(data, function(a, b)
		return a.time > b.time
	end)
	local cells = {}
	local list_h = 0
	for k, event in ipairs(data) do
		local label = createBMFont({text = getEventTimeStr(event.time) .. event.msg, anchor=ccp(0,0), fontFile = FONT_COMMON, size = 16, align=ui.TEXT_ALIGN_LEFT, width = self.list_width, color = ccc3(dexToColor3B(COLOR_BROWN)), x=5, y=0})
		local rect = label:getContentSize()
		rect.height = rect.height + 5
		list_h = list_h + rect.height

		cells[#cells + 1] = ClsGuildEventItem.new(rect,label)
	end
	
	local list_need_height = math.min(self.list_height, list_h)
	local list_y = 124
	self.can_touch = true
	if self.list_height > list_need_height then
		self.can_touch = false
		list_y = list_y + (self.list_height - list_need_height) * 0.56
	end
	if tolua.isnull(self.story_des_view) then
		self.story_des_view = ClsScrollView.new(self.list_width, list_need_height,true,nil,{is_fit_bottom = true})
		self.story_des_view:setPosition(ccp(323,list_y))
		self:addWidget(self.story_des_view)
	end

	self.story_des_view:addCells(cells)
	-- self.story_des_view:setTouchEnabled(self.can_touch) 
end

function ClsGuildInfoEventPanel:updateGuildEvent(list)
    self:updateEventList(list)
end

function ClsGuildInfoEventPanel:setTouch(enable)
    if not tolua.isnull(self.story_des_view) then
    	if self.can_touch then
    	 	self.story_des_view:setTouchEnabled(enable)
    	end 
    end
    if not tolua.isnull(self.ui_layer) then 
        self.ui_layer:setTouchEnabled(enable)
    end
end

function ClsGuildInfoEventPanel:onExit()
end

return ClsGuildInfoEventPanel
