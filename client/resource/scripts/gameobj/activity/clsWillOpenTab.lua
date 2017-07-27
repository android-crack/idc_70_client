-- 未开放活动
-- Author: Ltian
-- Date: 2016-07-01 10:27:55
--
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local CompositeEffect = require("gameobj/composite_effect")
local on_off_info = require("game_config/on_off_info")
local music_info = require("scripts/game_config/music_info")
local ui_word = require("game_config/ui_word")
local alert = require("ui/tools/alert")

local clsWillOpenActivityItem = class("clsWillOpenActivityItem", function() return UIWidget:create() end)

local OPEN_STATE_TRUE = 1
local OPEN_STATE_FLASE = 0

function clsWillOpenActivityItem:ctor(data)
	self.data = data
	self:mkUI()
end

local widget_name = {
	"activity_pic",
	"port_bg",
	"activity_name",
	"activity_time_num",
	"activity_level",
	"title",
	"rule_info",
	"start_info",
	"btn_go",
	"btn_go_text",
}

function clsWillOpenActivityItem:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_closed.json")
	convertUIType(self.panel)
	self.panel:setAnchorPoint(ccp(0.5, 0.5))
	self.panel:setPosition(ccp(180, 100))
	self:addChild(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.activity_pic:setVisible(true)
	self.port_bg:setVisible(false)
	self.btn_go:setVisible(false)
	self:updateView()
end


function clsWillOpenActivityItem:flipCard(is_reset)
	local music_info = require("scripts/game_config/music_info")

	self.flip_status = self.activity_pic:isVisible()
	if is_reset  then
		if self.flip_status then
			return
		else
			self.is_running = false
		end
	end
	if self.is_running  then return end
	self.is_running = true
	audioExt.playEffect(music_info.PORT_INFO_UP.res)
	local array = CCArray:create()
	local scale1 = CCScaleTo:create(0.2, 0, 1)
	local change_card = CCCallFunc:create(function()

		self.activity_pic:setVisible(not self.flip_status)
		self.port_bg:setVisible(self.flip_status)
	end)

	local change_card_end = CCCallFunc:create(function()
		self.is_running = false
	end)

	local scale2 = CCScaleTo:create(0.2, 1, 1)
	array:addObject(scale1)
	array:addObject(change_card)
	array:addObject(scale2)
	array:addObject(change_card_end)
	self.panel:runAction(CCSequence:create(array))
end

function clsWillOpenActivityItem:updateView()
	self.activity_name:setText(self.data.name)
	self.activity_time_num:setText(self.data.time_announce)
	self.activity_level:setText(self.data.open_level)
	self.title:setText(self.data.name)
	self.rule_info:setText(self.data.activity_desc)
	self.activity_pic:changeTexture("ui/activity_pic/"..self.data.activity_pic)
	self.start_info:setText(self.data.time_all)

	
	if self.data.is_completed == 1 then
		self:setGray(true)
		return 
	end
	
	local function btn_go_callback()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		if isExplore and self.data.explore_skip == 1 then
			local port_info = require("game_config/port/port_info")
			local Alert = require("ui/tools/alert")
			local portData = getGameData():getPortData()
			local portName = port_info[portData:getPortId()].name
			local tips = require("game_config/tips")
			local str = string.format(tips[77].msg, portName)
			Alert:showAttention(str, function()
				---回港
				portData:setEnterPortCallBack(function()
					if not tolua.isnull(getUIManager():get("ClsActivityMain")) then return end
					getUIManager():create("gameobj/activity/clsActivityMain")
				end)
				portData:askBackEnterPort()
			end, nil, nil, {hide_cancel_btn = true})
			return
		end

		-- check level
		local lv_limit = self.data.level_limit
		if getGameData():getPlayerData():getLevel() < lv_limit then
			alert:warning({msg = string.format(ui_word.ACTIVITY_LEVEL_LIMIT,lv_limit), size = 26})
			return
		end
		if self.data.skip_info[1] == "shipyard_shop" then
			local news_info = require("game_config/news")
			alert:warning({msg = news_info.ACTIVITY_BLACK_MARKET.msg, size = 26})
			return
		end
		-- do skip
		require("gameobj/mission/missionSkipLayer"):skipLayerByName(self.data.skip_info[1])
	end
	self.btn_go:addEventListener(btn_go_callback, TOUCH_EVENT_ENDED)
	--self.btn_go:setPressedActionEnabled(true)

	-- self.btn_go:setVisible(true) -- test
	self.btn_go_text:removeAllChildren()

	local effect_layer = UIWidget:create()
	self.btn_go_text:addChild(effect_layer)
	
	if tonumber(self.data.remain_time) > 0 then
		self.btn_go:setVisible(true)
		self.btn_go:setTouchEnable(true)
	end
	effect_layer:setPosition(ccp(-110,41))
	local effect = CompositeEffect.new("tx_activity_ongoing", 0, 0, effect_layer, nil, nil, nil, nil, true)

end


function clsWillOpenActivityItem:setGray(bGray)
	local imgs = {"activity_pic"}
	for __ , name in ipairs(imgs) do
		self[name]:setGray(bGray)
	end

	-- local texts = {"activity_name"}
	-- for __ , name in ipairs(texts) do
	-- 	setUILabelColor(self[name] , ccc3(dexToColor3B(COLOR_GREY_STROKE)))
	-- end
end

local clsWillOpenActivityCell = class("clsWillOpenActivityCell", ClsScrollViewItem)

function clsWillOpenActivityCell:initUI(cell_data)
	self.data = cell_data
	self.items = {}
	self:mkUi()
end

local widget_name = {

}
function clsWillOpenActivityCell:mkUi()
	local offset_X = 375
	for i,v in ipairs(self.data) do
		self.items[i] = clsWillOpenActivityItem.new(v)
		self.items[i]:setPosition(ccp(offset_X * (i -1 ),0))
		self:addChild(self.items[i])
	end
	self:updateView()
end

function clsWillOpenActivityCell:onTap(x, y)
	local flip_card = nil
	if x < 550 then
		flip_card = self.items[1]
	else
		flip_card = self.items[2]
	end
	local main = getUIManager():get("ClsActivityMain"):getRegChild("clsWillOpenActivityTab")

	main:resetCard()
	
	if not tolua.isnull(flip_card) then
		flip_card:flipCard()
	end
end

function clsWillOpenActivityCell:updateView()
end

local clsWillOpenActivityTab = class("clsWillOpenActivityTab", function() return UIWidget:create() end)

function clsWillOpenActivityTab:ctor()
	getUIManager():get("ClsActivityMain"):regChild("clsWillOpenActivityTab",self)
	self:regFunc()
	self:mkUI()
	self.node = display.newNode()
	self:addCCNode(self.node)
	self.node:registerScriptHandler(function(event)
		if event == "exit" then
			-- self:onExit()
		end
	end)
	self.flip_cards = {}
end

-- 每天多少秒
local DAY_SECOND = 24 * 60 * 60

-- 获取当天时间
local function getTimeIntraday()
	local time = os.time()
	return (time + 28800) % DAY_SECOND
end

function clsWillOpenActivityTab:mkUI()
	self.cells = {}
	local activity_data  = getGameData():getActivityData()
	-- local doing_activity = activity_data:getWillDoingActivity()
	local activity_list = activity_data:getLimitTimeActivityList()
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
	end
	local today = os.date("%w")
	
	
	
	if #activity_list < 1 then return end
	local _rect = CCRect(195, 30, 747, 464)
	local cell_size = CCSize(740, 190)

	if not self.list_view then
		self.list_view = ClsScrollView.new(747,464,true,nil,{is_fit_bottom = true})
		self.list_view:setPosition(ccp(195,30))
	end
	
	
	table.sort(activity_list, function(a, b)

		if a.is_completed == b.is_completed then
			if a.remain_time == b.remain_time then
				return a.lock_order < b.lock_order
			else
				return a.remain_time > b.remain_time
			end
		else
			return a.is_completed < b.is_completed
		end
		
	end)

	-- doing_activity = self:sortWillDoActivity(doing_activity)

	local raw = 2		--一列放2个cell
	local toalCol = math.ceil((#activity_list)/raw) --cell的总数
	for i=1,toalCol do
		local data = {}
		for j=1,2 do
			local index = (i - 1) * raw + j
			if activity_list[index] then
				table.insert(data, activity_list[index])
			end
		end
		self.cells[i] = clsWillOpenActivityCell.new(cell_size, data)
		self.list_view:addCell(self.cells[i])

	end
	-- self.list_view:setCurrentIndex(1)
	self:addChild(self.list_view)
end

function clsWillOpenActivityTab:saveFlipCard(card)
	self.flip_cards[card] = card
end

function clsWillOpenActivityTab:resetCard()
	for k,v in pairs(self.flip_cards) do
		v:flipCard(true)
	end
end

function clsWillOpenActivityTab:regFunc()
	-- self:registerScriptHandler(function(event)
	-- 	if event == "exit" then self:onExit() end
	-- end)
end

function clsWillOpenActivityTab:preClose()

end

function clsWillOpenActivityTab:onExit()
	-- getUIManager():get("ClsActivityMain"):unRegChild("clsWillOpenActivityTab")
end

function clsWillOpenActivityTab:setTouch(enable)
	-- body
end

return clsWillOpenActivityTab
