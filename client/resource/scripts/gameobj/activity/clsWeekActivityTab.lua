-- Author: Ltian
-- Date: 2016-07-01 15:23:03
--
local ui_word = require("scripts/game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local music_info = require("scripts/game_config/music_info")

local clsWeekActivityItem = class("clsWeekActivityItem", function() return UIWidget:create() end)

local widget_name ={
	"activity_name",
	"day_num",
	"activity_pic",
	"activity_time",-- 活动时间文本
	"activity_name_today",
	"day_bg",
	"txt_today",
	"day_bg_today",
}

function clsWeekActivityItem:ctor(data)
	self.data = data
	self:mkUI()
end

function clsWeekActivityItem:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_week.json")
	convertUIType(self.panel)
	self:addChild(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:updateView()
end

function clsWeekActivityItem:getSize()
	return self.panel:getContentSize()
end

function clsWeekActivityItem:updateView()
	local DAY_TIME = {
		[1] = ui_word.ACTIVITY_MONDAY,
		[2] = ui_word.ACTIVITY_TUESDAY,
		[3] = ui_word.ACTIVITY_WEDNESDAY,
		[4] = ui_word.ACTIVITY_THURSDAY,
		[5] = ui_word.ACTIVITY_FRIDAY,
		[6] = ui_word.ACTIVITY_SATURDAY,
		[7] = ui_word.ACTIVITY_SUNDAY,
	}
	local file_name = self.data.static_info.activity_pic_week
	self.activity_pic:changeTexture("ui/activity_pic/"..file_name)
	self.activity_name:setText(self.data.static_info.name)
	self.activity_time:setText(self.data.static_info.time_announce)
	self.day_num:setText(DAY_TIME[self.data.day_index])
	self.txt_today:setText(DAY_TIME[self.data.day_index])
	self.activity_name_today:setText(self.data.static_info.name)


	--当天的活动
	local today = os.date("%w")
	if today == 0 then today = 7 end
	if tonumber(today) == self.data.day_index then
		self.day_bg:setVisible(false)
		self.day_bg_today:setVisible(true)

		self.activity_name:setVisible(false)
		self.activity_name_today:setVisible(true)

	end

end

function clsWeekActivityItem:touchCallBack()

	-- table.print(self.data.static_info)

	local cfg = self.data.static_info
	-- 活动周历弹出框
	local main_ui = GUIReader:shareReader():widgetFromJsonFile("json/activity_week_info.json")
	convertUIType(main_ui)

	-- local rule_info_label = getConvertChildByName(panel, "rule_info")
	-- local start_info_label = getConvertChildByName(panel, "start_info")
	-- local title_label = getConvertChildByName(panel, "title")
	-- local richText = createRichLabel(static_info.time_all, 300, 44, 16)
	-- richText:setAnchorPoint(ccp(0, 1))
	-- start_info_label:addCCNode(richText)
	-- rule_info_label:setText(static_info.activity_desc)
	-- title_label:setText(static_info.name)
	local wgts = {
		["text_name"] = "title", -- 活动名称
		["text_intro"] = "info_txt_1", -- 简介文本 introduce
		["text_team_or_not"] = "info_txt_2", -- 人数要求 单人/组队
		["text_require"] = "info_txt_3", -- 活动要求文本
		["text_act_time"] = "info_txt_4", -- 活动时间
		["obj_item1"] = "reward_icon_1", -- 活动奖励1
		["obj_item2"] = "reward_icon_2", -- 活动奖励2
		["obj_item3"] = "reward_icon_3", -- 活动奖励3
		["btn_close"] = "btn_close", --关闭按钮
	}

	for k,v in pairs(wgts) do
		main_ui[k] = getConvertChildByName(main_ui, v)
	end

	main_ui.text_intro:setText(cfg.activity_desc)
	main_ui.text_name:setText(cfg.name)
	main_ui.text_team_or_not:setText((cfg.team_or_single==2) and ui_word.ACTIVITY_TEAM or ui_word.ACTIVITY_SINGLE)
	main_ui.text_require:setText(cfg.open_level)
	main_ui.text_act_time:setText(cfg.time_all)
	main_ui.btn_close:setPressedActionEnabled(true)
	main_ui.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		getUIManager():close("WeekActivityTip")
	end, TOUCH_EVENT_ENDED)

	-- 奖励
	for i=1,3 do
		v = cfg.activity_reward[i]
		local item = main_ui[string.format("%s%d","obj_item",i)]
		item:setVisible(v and true or false)
		item:changeTexture(v, UI_TEX_TYPE_PLIST)
	end

	local container = UIWidget:create()
	container:addChild(main_ui)



	getUIManager():create("ui/view/clsBaseTipsView", nil, "WeekActivityTip", {is_back_bg = true}, container, true)
end

local clsWeekActivityCell = class("clsWeekActivityCell", ClsScrollViewItem)
function clsWeekActivityCell:initUI(cell_data)
	self.data = cell_data
	self.items = {}
	self:mkUi()
end

function clsWeekActivityCell:mkUi()
	for i,v in ipairs(self.data) do
		local item = clsWeekActivityItem.new(v)
        local panel_size = item:getSize()
     	local posX, posY = item:getPosition()

		self.items[i] = item
		posX = (panel_size.width + 20) * (i -1)
		item:setPosition(ccp(posX,0))
		self:addChild(item)
       	item.touch_rect = CCRect(posX, 0, panel_size.width, panel_size.height)
	end
end

function clsWeekActivityCell:onTap(x, y)
	local touch_pos = self:getWorldPosition()
	-- local touch_pos = ccp(x,y)
	local touch_x = x - touch_pos.x
	local touch_y = y - touch_pos.y
	for _,v in pairs(self.items) do
    	if v.touch_rect:containsPoint(ccp(touch_x,touch_y)) then
    		v:touchCallBack()
    		break
    	end
	end
end

local ClsWeekActivityTab = class("ClsWeekActivityTab", function() return UIWidget:create() end)

function ClsWeekActivityTab:ctor()
	self:initData()
	self:mkUI()
	self.node = display.newNode()
	self:addCCNode(self.node)
	self.node:registerScriptHandler(function(event)
		if event == "exit" then
			-- self:onExit()
		end
	end)
end

function ClsWeekActivityTab:initData()
	local new_activity = table.clone(require("game_config/activity/new_activity"))
	local temp_activity = {}
	self.week_activity = {}
	for aid, info in ipairs(new_activity) do
		if info.week_day[1] then
			for _,day_index in ipairs(info.week_day) do
				local index = day_index
				if day_index == 0 then
					index = index + 7
				end

				temp_activity[index] = {
					["static_info"] = info,
					["day_index"] = index,
				}
			end
		end
	end

	for k,v in pairs(temp_activity) do
		table.insert(self.week_activity,v)
	end

	table.sort(self.week_activity,function(a1,a2)
		return a1.day_index < a2.day_index
	end)

end

function ClsWeekActivityTab:mkUI()
	self.cells = {}

	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeAllCells()
	end

	local activity_count = #self.week_activity
	-- for k,v in pairs(self.week_activity) do
	-- 	activity_count = activity_count + 1
	-- end

	if activity_count < 1 then return end
	local _rect = CCRect(195, 20, 747, 480)
	local cell_size = CCSize(740, 236)

	if not self.list_view then
		self.list_view = ClsScrollView.new(747,480,true,nil,{is_fit_bottom = true})
		self.list_view:setPosition(ccp(195,20))
	end

	local raw = 4 --一行4个，放2行
	local toalCol = math.ceil((activity_count)/raw) --cell的总数
	for i=1,toalCol do
		local data = {}
		for j=1,4 do
			local index = (i - 1) * raw + j
			if self.week_activity[index] then
				table.insert(data, self.week_activity[index])
			end
		end
		self.cells[i] = clsWeekActivityCell.new(cell_size, data)
		self.list_view:addCell(self.cells[i])
	end
	-- self.list_view:setCurrentIndex(1)
	--todo
	-- local main_tab = getUIManager():get("ClsActivityMain")
	-- local parent_node = main_tab:getChildPanel("girl_panel")
	-- parent_node:addCCNode(self.list_view)
	self:addChild(self.list_view)
end

function ClsWeekActivityTab:preClose()
	-- body
end

return ClsWeekActivityTab
