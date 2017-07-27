local ui_word = require("game_config/ui_word")
local music_info=require("game_config/music_info")
local Alert = require("ui/tools/alert")
local ClsScrollView = require("ui/view/clsScrollView")
local lose_found_conf = require("game_config/lose_found_data")
local ClsGainBackTab = class("ClsGainBackTab",require("ui/view/clsBaseView"))

---------------------------------listView Item----------------------------------------------
local ClsGainBackItem = class("ClsMissionPortItem", require("ui/view/clsScrollViewItem"))
local CASH_TYPE = 1
local DIAMOND_TYPE = 2
local cost_icon = {
	"#common_icon_coin.png",
	"#common_icon_diamond.png",
}
local widget_name = {
	"btn_list",
	"btn_list_text_1",
	"btn_list_icon",
	"btn_list_text",
	"title",
	"reward_bg_1",
	"reward_bg_2",
	"reward_bg_3",
	"reward_bg_4",
	"btn_panel"
}

ClsGainBackItem.updateUI = function(self, cell_date, panel)
	self.data = cell_date
	convertUIType(panel)
	for _, name in pairs(widget_name) do
		self[name] = getConvertChildByName(panel, name)
	end
	if not self.data.aid or not lose_found_conf[self.data.aid] then return end

	local activity_name = lose_found_conf[self.data.aid].name
	self.title:setText(activity_name)
	for i = 1, 4 do
		local reward_info = self.data.list[i]
		self["reward_bg_"..i]:setVisible(false)
		if reward_info then
			local item_res, amount = getCommonRewardIcon(reward_info)
			local reward_icon = getConvertChildByName(panel, "reward_icon_"..i)
			local reward_num = getConvertChildByName(panel, "reward_num_"..i)
			reward_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
			reward_num:setText(amount)
			self["reward_bg_"..i]:setVisible(true)
			if self.data.status == LOSE_FOUND_STATUS_FOUND then
				reward_num:setVisible(false)
			end
		end
	end
	self:setBtnStatus()

	self.btn_list:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local gain_back_ui = getUIManager():get("ClsGainBackTab")
		if not tolua.isnull(gain_back_ui) then
			local call_back = function()
				gain_back_ui:setTouch(false)
				getGameData():getGainBackData():askFindGainAlone(self.data.aid, self.data.type)
			end
			gain_back_ui:checkMoneyEnough(self.data.cost, call_back)
		end
	end, TOUCH_EVENT_ENDED)
end

ClsGainBackItem.setBtnStatus = function(self)
	self.btn_list:disable()
	self.btn_list_text_1:setVisible(false)
	self.btn_list_icon:setVisible(false)
	self.btn_list_text:setVisible(false)

	if self.data.status == LOSE_FOUND_STATUS_UNOPEN then
		self.btn_list_text_1:setText(ui_word.STR_LOSE_FOUND_UNOPEN)
		self.btn_list_text_1:setVisible(true)
	elseif self.data.status == LOSE_FOUND_STATUS_FOUND then
		self.btn_list_text_1:setText(ui_word.STR_LOSE_FOUND_FINISH)
		self.btn_list_text_1:setVisible(true)
	else
		self.btn_list:active()
		self.btn_list_icon:setVisible(true)
		self.btn_list_text:setVisible(true)
		self.btn_list_text:setText(self.data.cost)
		self.btn_list_icon:changeTexture(convertResources(cost_icon[self.data.type]), UI_TEX_TYPE_PLIST)
		if self.data.type == CASH_TYPE then
			self:alignWidget()
		end
	end
end

ClsGainBackItem.alignWidget = function(self)
	local off_set_x = 8
	local old_pos = self.btn_panel:getPosition()
	local total_size = self.btn_list_text:getSize().width + self.btn_list_icon:getSize().width * self.btn_list_icon:getScale() + off_set_x
	self.btn_panel:setPosition(ccp(- total_size/2, old_pos.y))
end

---------------------------------主界面UI---------------------------------------------------
local DIAMOND_TAB = 2
local btn_UI = {
	{res = "btn_ordinary_back", text_lab = "btn_ordinary_back_text"},
	{res = "btn_diamond_back", text_lab = "btn_diamond_back_text"},--完美找回
	{res = "btn_back",},--一键找回
}

ClsGainBackTab.getViewConfig = function(self)
	return {
		is_swallow = false,
	}
end

ClsGainBackTab.onEnter = function(self)
	local on_off_info = require("game_config/on_off_info")
	getGameData():getTaskData():setTask(on_off_info.INCOME_BACK.value, false)

	self:mkUI()
	self:setTouch(false)
	self:askData()
	self:regEvent()
	self:defaultSelect()
end

ClsGainBackTab.askData = function(self)
	local gain_back_data = getGameData():getGainBackData()
	gain_back_data:askGainList()
end

ClsGainBackTab.mkUI = function(self)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/award_back.json")
	convertUIType(panel)
	for i,v in ipairs(btn_UI) do
		self[v.res] = getConvertChildByName(panel, v.res)
		self[v.res].tag = i
		if v.text_lab then
			self[v.res].text_lab = getConvertChildByName(panel, v.text_lab)
		end
	end
	self.tab = {
		self.btn_ordinary_back,
		self.btn_diamond_back,
	}
	self.list_view_bg = getConvertChildByName(panel, "personal_bg")
	self:addWidget(panel)
end

ClsGainBackTab.updateView = function(self)
	if not self.s_type then return end
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeFromParent()
		self.list_view = nil
	end
	local gain_back_handle = getGameData():getGainBackData()
	local gain_list = gain_back_handle:getGainList()
	if not gain_list or not gain_list[self.s_type] then 
		self:setTouch(true)
		return 
	end

	self.cells = {}
	self.list_view = ClsScrollView.new(464, 392, true, function()
		local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/award_back_list.json")
		return cell_ui
	end)
	for i, v in ipairs(gain_list[self.s_type] or {}) do
		self.cells[i] = ClsGainBackItem.new(CCSize(460, 112), v)
	end
	self.list_view:addCells(self.cells)
	self.list_view:setPosition(ccp(13, 13))
	self.list_view_bg:addChild(self.list_view)
	self:setTouch(true)

	if gain_back_handle:isAllFoundBack(self.s_type) then
		self.btn_back:disable()
	else
		self.btn_back:active()
	end
end

ClsGainBackTab.defaultSelect = function(self)
	self:selectTab(DIAMOND_TAB)
end

ClsGainBackTab.selectEffect = function(self, index)
	local color = ccc3(dexToColor3B(COLOR_TAB_UNSELECTED))
	for _, btn in pairs(self.tab) do
		btn:setFocused(false)
		btn:setTouchEnabled(true)
		setUILabelColor(btn.text_lab, color)
	end
	color = ccc3(dexToColor3B(COLOR_TAB_SELECTED))
	self.tab[index]:setFocused(true)
	self.tab[index]:setTouchEnabled(false)
	setUILabelColor(self.tab[index].text_lab, color)
end

ClsGainBackTab.selectTab = function(self, index)
	self.s_type = index
	self:selectEffect(index)
	self:updateView()
end

ClsGainBackTab.checkMoneyEnough = function(self, cost, call_back, str)
	local user_own = getGameData():getPlayerData():getCash()
	local jump_tag = CASH_NOT_ENOUGH
	if self.s_type == DIAMOND_TYPE then
		user_own = getGameData():getPlayerData():getGold()
		jump_tag = DIAMOND_NOT_ENOUGH 
	end
	if not user_own or not cost then return end
	if user_own >= cost then
		if str then
			local COST_TYPE = {
				ITEM_INDEX_CASH,
				ITEM_INDEX_GOLD,
			}
			Alert:showCostDetailTips(str, nil, COST_TYPE[self.s_type], nil, cost, nil, call_back)
		else
			if type(call_back) == "function" then
				call_back()
			end
		end
	else
		Alert:showJumpWindow(jump_tag, parent, {need_cash = cost, come_type = Alert:getOpenShopType().VIEW_3D_TYPE,})
	end
end

ClsGainBackTab.regEvent = function(self)
	self.btn_back:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local gain_back_handle = getGameData():getGainBackData()
		local call_back = function()
			gain_back_handle:askGainPrefetGet(self.s_type)
		end
		local cost = gain_back_handle:getAllCostByType(self.s_type)
		self:checkMoneyEnough(cost, call_back, ui_word.STR_LOSE_FOUND_COST_TIPS)
	end, TOUCH_EVENT_ENDED)

	for index, btn in ipairs(self.tab) do
		btn:addEventListener(function()
			if btn.tag then
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				self:selectTab(btn.tag)
			end
		end, TOUCH_EVENT_ENDED)
	end
end

ClsGainBackTab.setTouch = function(self, enable)
	if not tolua.isnull(self.list_view) then
		self.list_view:setTouch(enable)
	end
	for _, info in ipairs(btn_UI) do
		if not tolua.isnull(self[info.res]) then
			self[info.res]:setTouchEnabled(enable)
		end
	end
end

return ClsGainBackTab