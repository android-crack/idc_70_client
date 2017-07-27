--
-- 5.1节日活动
--
local ClsScrollView 		= require("ui/view/clsScrollView")
local clsScrollViewItem 	= require("ui/view/clsScrollViewItem")
local ClsBaseView           = require("ui/view/clsBaseView")
local music_info            = require("game_config/music_info")
local ui_word 				= require("game_config/ui_word")
local ClsCommonFuns     	= require("gameobj/commonFuns")

local ListParams	=
{
	list_pos		= CCPoint(300, 120),
	list_width 		= 230, 
	list_height 	= 300,
	label_width 	= 230,
	label_height	= 22,
	font_size		= 14,
	vertical_space	= 4,
}

local AmountLabelParams =
{
	pos 			= CCPoint(695, 83),
	font_size 		= 14,
	anchor 			= CCPoint(0.5, 0.5),
	format_green 	= "$(c:COLOR_GREEN_STROKE)%s$(c:COLOR_WHITE_STROKE)/1",
	format_red 		= "$(c:COLOR_RED_STROKE)%s$(c:COLOR_WHITE_STROKE)/1",
}

--------------------------- ClsRareListCell ------------------------------------
local ClsRareListCell 	= class("ClsRareListCell", clsScrollViewItem)

function ClsRareListCell:updateUI(cell_data, widget)
	local item_res, amount, scale, name, _, _, color = getCommonRewardIcon(cell_data.reward)
	local user_name = self:convertUserNameStr(cell_data.name)
	local list_desc = string.format(ui_word.OTHER_PLAYER_REARD_TIP, user_name, RICHTEXT_COLOR_STROKE[color]..name)
	local rich_label = createRichLabel(list_desc, ListParams.label_width, ListParams.label_height, ListParams.font_size, ListParams.vertical_space, true, true)

	self:addChild(rich_label)
end

function ClsRareListCell:convertUserNameStr(name_str)
	local len_limit = 5
	local name_len = ClsCommonFuns:utfstrlen(name_str)
	if name_len > len_limit then
		name_str = ClsCommonFuns:utf8sub(name_str, 1, len_limit - 1) .. "..."
	end
	return name_str
end

---------------------------- ClsFestivalActivityMain -------------------------------
local ClsFestivalActivityMain = class("ClsFestivalActivityMain", ClsBaseView)

-- 节日活动页面加载的json地址
local FESTIVAL_MAIN_JSON      = "json/activity_dw.json"

-- 每个页签的索引号
local TAB_INDEX 		=
{
	["BOX"] 			= 1, 
	["RECHARGE"] 		= 2, 
	["DAILY"]  	  		= 3
}
-- 定义每个页签的一些属性
local TAB_INFO          = 
{
	-- 女神宝箱 
	[TAB_INDEX.BOX]  	= 
	{
		["class_url"]  	= "gameobj/festival/clsFestivalBoxTab",
		["btn_name"] 	= "tab_box",
		["btn_text"]	= "text_box",
		["show_list"]	= true,
		["show_amount"] = true,
	},
	-- 充值活动
	[TAB_INDEX.RECHARGE]= 
	{
		["class_url"] 	= "gameobj/festival/clsFestivalRechargeTab",
		["btn_name"]  	= "tab_charge",
		["btn_text"]	= "text_charge",
		["show_list"]	= false,
		["show_amount"] = false,
	},
	-- 日常活动
	[TAB_INDEX.DAILY] 	= 
	{
		["class_url"] 	= "gameobj/festival/clsFestivalDailyTab",
		["btn_name"]  	= "tab_daily",
		["btn_text"]	= "text_daily",
		["show_list"]	= false,
		["show_amount"] = false,
	},
}
-- 需要的资源
local PLIST_RES              = 
{
	["ui/activity_51.plist"] = 1,
	["ui/activity_ui.plist"] = 1
}

-- 页面配置
function ClsFestivalActivityMain:getViewConfig()
	return {
		["effect"]     = UI_EFFECT.DOWN, 
		["is_back_bg"] = true
	}
end

function ClsFestivalActivityMain:onEnter(tab_index)
	self["tab_index"] = tab_index or TAB_INDEX.BOX 		-- 选中的页签索引，没参数就是默认第一页
	self["cur_tab"]   = nil 							-- 目前显示的页面
	self["tab_btns"]  = {} 								-- 按序存三个页签的按钮
	self["btn_txts"]  = {} 								-- 按序存页签上的文本
	self["panel"] 	  = nil 							-- 界面显示

	self["rare_list"] = nil 							-- 稀有物品获取玩家列表
	self["amount_lab"]= nil 							-- 海洋之心数量

	LoadPlist(PLIST_RES)

	self:initUI()

	getGameData():getFestivalActivityData():askRareReardList()
end

function ClsFestivalActivityMain:onExit()
	-- 删除资源与数据
	UnLoadPlist(PLIST_RES)
end

function ClsFestivalActivityMain:preClose()
	-- 删除UI
	self:closeCurrentTab()
	getUIManager():close("ClsFestivalRewardTips")
end

--				UI相关				--
function ClsFestivalActivityMain:initUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile( FESTIVAL_MAIN_JSON )
	self:addWidget(self.panel)

	-- 给切换页签的按钮添加事件
	for index, info in ipairs(TAB_INFO) do
		self.btn_txts[index] = getConvertChildByName(self.panel, info.btn_text)
		-- 获取每个页签按钮
		self.tab_btns[index] = getConvertChildByName(self.panel, info.btn_name)
		-- 点中按钮，显示效果
		self.tab_btns[index]:addEventListener(function() self:selectBtnEffect(index) end, TOUCH_EVENT_BEGAN)
		-- 点中取消，播放之前的效果
		self.tab_btns[index]:addEventListener(function() self:selectBtnEffect(self.tab_index) end, TOUCH_EVENT_CANCELED)
		-- 点中结束，切换页签和按钮状态
		self.tab_btns[index]:addEventListener(function()

			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:changeTab(index)

		end, TOUCH_EVENT_ENDED)
	end

	-- close事件
	self:initCloseBtn()
	self:initRareList()
	self:initHeartAmount()

	self:changeTab(self.tab_index)
end

function ClsFestivalActivityMain:initCloseBtn()
	local btn_close = getConvertChildByName(self.panel, "btn_close")

	btn_close:setPressedActionEnabled(true)
	btn_close:setVisible(true)

	btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
end

function ClsFestivalActivityMain:initRareList()
	self.rare_list = ClsScrollView.new( ListParams.list_width, ListParams.list_height, true, function() end, {is_fit_bottom = true, is_widget = false})
	self.rare_list:setPosition(ListParams.list_pos)
	self:addChild(self.rare_list)
	self.rare_list:regTouch(self)
	self:updateRareList()
end

function ClsFestivalActivityMain:initHeartAmount()
	self.amount_lab = createRichLabel(self:getAmountStr(), 100, AmountLabelParams.font_size, AmountLabelParams.font_size, 0, true, true)
	self.amount_lab:setAnchorPoint(AmountLabelParams.anchor)
	self.amount_lab:setPosition(AmountLabelParams.pos)
	self:addChild(self.amount_lab)
end

------------------ 切换页面 ----------------------
function ClsFestivalActivityMain:changeTab(tab_index)
	self:changeBtn(tab_index)
	self:closeCurrentTab()
	self:openTab(tab_index)
	self.tab_index = tab_index
end

-- 改变选中按钮
function ClsFestivalActivityMain:changeBtn(tab_index)
	self:selectBtnEffect(tab_index)
	for index, btn in ipairs(self.tab_btns) do
		if index == tab_index then
			btn:setTouchEnabled(false) 
		else
			btn:setTouchEnabled(true)
		end
	end
end

function ClsFestivalActivityMain:openTab(tab_index)
	self.rare_list:setVisible(TAB_INFO[tab_index].show_list)
	self.amount_lab:setVisible(TAB_INFO[tab_index].show_amount)

	local tab_class = require(TAB_INFO[tab_index].class_url)
	self.cur_tab = tab_class.new()
	self:addWidget(self.cur_tab)
end

function ClsFestivalActivityMain:closeCurrentTab()
	if self.cur_tab and not tolua.isnull(self.cur_tab) then
		self.cur_tab:removeFromParentAndCleanup(true)
		self.cur_tab = nil
	end
end

-- 点中按钮的效果
function ClsFestivalActivityMain:selectBtnEffect(tab_index)
	for index, btn in ipairs(self.tab_btns) do
		if index == tab_index then
			btn:setFocused(true)
			setUILabelColor(self.btn_txts[index], ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
		else
			btn:setFocused(false)
			setUILabelColor(self.btn_txts[index], ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
		end
	end
end

function ClsFestivalActivityMain:getAmountStr()
	local amount, str_format = getGameData():getFestivalActivityData():getSeaHeartNum(), nil
	if amount > 0 then 
		str_format = AmountLabelParams.format_green
	else
		str_format = AmountLabelParams.format_red
	end
	local str = string.format(str_format, amount)
	return str
end
---------------------------------------------------
--             update接口               --
--              tab_1  box              --
-- 更新珍贵物品获取者
function ClsFestivalActivityMain:updateRareList()
	self.rare_list:removeAllCells()
	local list_data, list_cells  = getGameData():getFestivalActivityData():getRareRewardList(), {}
	-- 服务器传过来的数据时反的，需要倒置处理
	local length = #list_data
	for k = 1, length do
		table.insert(list_cells, ClsRareListCell.new(CCSize(ListParams.label_width, ListParams.label_height), list_data[length - k + 1], {is_widget = false}))
	end 

	self.rare_list:addCells(list_cells)
	self.rare_list:scrollToCellIndex(1)
end
-- 更新海洋之心数量
function ClsFestivalActivityMain:updateSeaHeartNum()
	self.amount_lab:setString(self:getAmountStr())
end
--              tab_2  recharge              --
-- 更新充值送礼状态
function ClsFestivalActivityMain:updateRechargeInfo()
	if self.tab_index == TAB_INDEX.RECHARGE and self.cur_tab then
		self.cur_tab:updateRechargeStatus()
	end
end
--             tab_3  daily               --
-- 更新日常活动状态
function ClsFestivalActivityMain:updateDailyActivity()
	if self.tab_index == TAB_INDEX.DAILY and self.cur_tab then
		self.cur_tab:updateDailyActivity()
	end
end

return ClsFestivalActivityMain