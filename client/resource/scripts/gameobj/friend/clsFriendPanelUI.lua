local music_info = require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
local onOffKey_with_taksKey = {
	[1] = {on_off_info.FRIEND_LIST.value,},
	[2] = {on_off_info.FRIEND_THANKS.value, {on_off_info.ACCEPT_GIFTPAGE.value}},
}

local btn_widget = {
	[1] = { name = "btn_rank", index = TAB_RANK, text = "btn_rank_text" },
	[2] = { name = "btn_thanks", index = TAB_THANKS, text = "btn_thanks_text" },
}

local ClsFriendPanelUI = class("ClsFriendPanelUI", function() return UIWidget:create() end)
function ClsFriendPanelUI:ctor()
	self.btn_tab = {}
	self.panels = {}

	self:configUI()
end

function ClsFriendPanelUI:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_my_friend.json")
	self:addChild(self.panel)

	local taskData = getGameData():getTaskData()
	for k, v in ipairs(btn_widget) do
		local item = getConvertChildByName(self.panel, v.name)
		item.name = v.name
		item.index = v.index

		item.text = getConvertChildByName(self.panel, v.text)

		item.text:addEventListener(function() 
			setUILabelColor(v.text, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		end, TOUCH_EVENT_BEGAN)

		item:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:executeSelectLogic(v.index)
		end, TOUCH_EVENT_ENDED)

		self[v.name] = item
		table.insert(self.btn_tab, item)

		v.onOffKey = onOffKey_with_taksKey[k][1]
		v.task_keys = onOffKey_with_taksKey[k][2]
		if v.task_keys then
			local task_parameter = {
				[1] = item,
				[2] = v.task_keys,
				[3] = KIND_RECTANGLE,
				[4] = v.onOffKey,
				[5] = 56,
				[6] = 16,
				[7] = true,
			}
			taskData:regTask(unpack(task_parameter))
		end
	end

	self.panel_layer = getConvertChildByName(self.panel, "panel_layer")

	local func = self.panel_layer.addChild
	function self.panel_layer:addChild(panel)
		func(self, panel)
		local main_ui = getUIManager():get("ClsFriendMainUI")
		local friend_panel = main_ui:getPanelByName("ClsFriendPanelUI")
		friend_panel:insertPanelByName(panel.panel_index, panel)
		friend_panel.cur_panel = panel
	end

	self.friend_num = getConvertChildByName(self.panel, "friend_num")
	self:updateAllTimes()
end

function ClsFriendPanelUI:updateAllTimes()
	local friend_data_handler = getGameData():getFriendDataHandler()
	local friend_num = friend_data_handler:getFriendNum()
	self.friend_num:setText(string.format("%s/%s", friend_num, FRIENT_MAX_NUM))
	if tolua.isnull(self.cur_panel) then return end
	self.cur_panel:updateTimes()
end

function ClsFriendPanelUI:getPanelByName(name)
	return self.panels[name]
end

function ClsFriendPanelUI:insertPanelByName(name, panel)
	self.panels[name] = panel
end

function ClsFriendPanelUI:clickRankEvent()
	local panel = self:getPanelByName("ClsFriendRankUI")
	if tolua.isnull(panel) then
		local ClsFriendRankUI = require("gameobj/friend/clsFriendRankUI")
		panel = ClsFriendRankUI.new()
		panel.panel_index = "ClsFriendRankUI"
		self.panel_layer:addChild(panel)
	end
end

function ClsFriendPanelUI:clickGiftEvent()
	local panel = self:getPanelByName("ClsFriendGiftUI")
	if tolua.isnull(panel) then
		local ClsFriendGiftUI = require("gameobj/friend/clsFriendGiftUI")
		panel = ClsFriendGiftUI.new()
		panel.panel_index = "ClsFriendGiftUI"
		self.panel_layer:addChild(panel)
	end
end

local tab_events = {
	[TAB_RANK] = ClsFriendPanelUI.clickRankEvent,
	[TAB_THANKS] = ClsFriendPanelUI.clickGiftEvent,
}

function ClsFriendPanelUI:executeSelectLogic(index)
	local main_ui = getUIManager():get("ClsFriendMainUI")
	main_ui:closeExpandPanel()
	self.select_index = index 
	for k, v in ipairs(self.btn_tab) do
		local color = COLOR_TAB_SELECTED
		if index ~= v.index then
			color = COLOR_TAB_UNSELECTED
		end

		if not tolua.isnull(v) then
			v:setFocused(index == v.index)
			v:setTouchEnabled(index ~= v.index)
			v.text:setUILabelColor(color)
		end

		if not tolua.isnull(self.cur_panel) then
			self.cur_panel:removeFromParentAndCleanup(true)
		end
	end
	tab_events[index](self)
end

function ClsFriendPanelUI:updateListView(info)
	self.cur_panel:updateListView(info)
end

function ClsFriendPanelUI:updateCell(info)
	self.cur_panel:updateCell(info)
end

function ClsFriendPanelUI:updateCellBtnStatus(list)
	local main_ui = getUIManager():get("ClsFriendMainUI")
	main_ui:closeExpandPanel()
	self.cur_panel:updateCellBtnStatus(list)
end

function ClsFriendPanelUI:removeCellByUid(uid)
	local main_ui = getUIManager():get("ClsFriendMainUI")
	main_ui:closeExpandPanel()

	self.cur_panel:removeCellByUid(uid)
end

return ClsFriendPanelUI
