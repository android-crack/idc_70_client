local music_info = require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
local ClsRankMainUI = class("ClsRankMainUI",require("ui/view/clsBaseView"))

ClsRankMainUI.getViewConfig = function(self)
	return { 
		effect = UI_EFFECT.DOWN,
		is_swallow = true,
		is_back_bg = true, 
	}
end

local tab_name = {
	{res = "tab_guild", label = "tab_guild_text", on_off_key = on_off_info.RANKING_LIST_GUILD.value, _type = GUILD_RANK_TYPE},         --商会
	{res = "tab_prestige", label = "tab_prestige_text", on_off_key = on_off_info.RANKING_LIST_PROSPER.value, _type = PRESTIGE_RANK_TYPE}, --声望
	{res = "tab_wealth", label = "tab_wealth_text", on_off_key = on_off_info.RANKING_LIST_CASH.value, _type = WEALTH_RANK_TYPE},        --财富
	{res = "tab_pirates", label = "tab_pirates_text", on_off_key = on_off_info.RANKING_LIST_PIRATE.value, _type = PIRATE_RANK_TYPE},    --海盗
}

local LIST_UI_PATH = {
	[PRESTIGE_RANK_TYPE] = "gameobj/rank/clsPrestigeRankUI", --声望
	[WEALTH_RANK_TYPE] = "gameobj/rank/clsWealthRankUI", --财富
	[PIRATE_RANK_TYPE] = "gameobj/rank/clsPirateRankUI", --海盗
	[GUILD_RANK_TYPE] = "gameobj/rank/clsGuildRankUI", --商会
}

ClsRankMainUI.onEnter = function(self, tab_id)
	self.plist = {
		["ui/title_name.plist"] = 1,
		["ui/guild_ui.plist"] = 1,
	}
	LoadPlist(self.plist)

	audioExt.playEffect(music_info.PAPER_STRETCH.res)

	self:checkIsNewGrade()

	self.s_tab = nil
	self.default_tab = tab_id or 1
	self:mkUI()
	self:setTouch(false)
	self:defaultSelect()
end

ClsRankMainUI.checkIsNewGrade = function(self)
	local rank_data_handle = getGameData():getRankData()
	if rank_data_handle:getIsNewGrade() then
		rank_data_handle:popNewGradeTip()
		rank_data_handle:setIsNewGrade(false)
	end
end

ClsRankMainUI.mkUI = function(self)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/rank_list.json")
	convertUIType(panel)
	self:addWidget(panel)

	for k, info in ipairs(tab_name) do
		self[info.res] = getConvertChildByName(panel, info.res)
		if not getGameData():getOnOffData():isOpen(info.on_off_key) then
			self[info.res]:setVisible(false)
		end
		self[info.res].lab = getConvertChildByName(panel, info.label)
		self[info.res]:addEventListener(function()
			self:selectTab(k)
		end, TOUCH_EVENT_ENDED)
	end

	self.btn_close = getConvertChildByName(panel, "btn_close")
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self:closeView()
	end, TOUCH_EVENT_ENDED)

	self.btn_why = getConvertChildByName(panel, "btn_question")
	self.btn_why:setPressedActionEnabled(true)
	self.btn_why:setTouchEnabled(true)
	self.btn_why:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local container = UIWidget:create()
		local panel = GUIReader:shareReader():widgetFromJsonFile('json/rank_instructions.json')
		local btn_close = getConvertChildByName(panel, "btn_close")

		btn_close:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_CLOSE.res)
			getUIManager():close("rankMainTip")
		end,TOUCH_EVENT_ENDED)

		container:addChild(panel)
		getUIManager():create("ui/view/clsBaseTipsView", nil, "rankMainTip", {is_back_bg = true}, container, true)
	end,TOUCH_EVENT_ENDED)
end

ClsRankMainUI.defaultSelect = function(self)
	self:selectTab(self.default_tab)
end

ClsRankMainUI.selectTab = function(self, index)
	if self.s_tab == index then return end
	audioExt.playEffect(music_info.COMMON_CLOSE.res)
	self.s_tab = index
	for k, info in ipairs(tab_name) do
		self[info.res]:setFocused(self.s_tab == k)
		self[info.res]:setTouchEnabled(self.s_tab ~= k)
		if self.s_tab == k then
			setUILabelColor(self[info.res].lab, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
		else
			setUILabelColor(self[info.res].lab, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
		end
	end

	getGameData():getRankData():isResetData(tab_name[index]._type)

	-- self:setTouch(false)
	if self.show_view and not tolua.isnull(self.show_view) then
		self.show_view:removeFromParent()
		self.show_view = nil
	end
	local _type = tab_name[index]._type
	self.show_view = require(LIST_UI_PATH[_type]).new(_type)
	self:addWidget(self.show_view)
	self.show_view:setZOrder(-1)
end

ClsRankMainUI.closeView = function(self)
	audioExt.playEffect(music_info.COMMON_CLOSE.res)
	self:close()
end

ClsRankMainUI.setTouch = function(self, enable)
	for k, info in ipairs(tab_name) do
		if k == self.s_tab then
			self[info.res]:setTouchEnabled(false)
		else
			self[info.res]:setTouchEnabled(enable)
		end
	end
end

ClsRankMainUI.getListView = function(self, _type)
	if tab_name[self.s_tab]._type ~= _type then return end
	return self.show_view
end

ClsRankMainUI.getSelectType = function(self)
	return tab_name[self.s_tab]._type
end

ClsRankMainUI.onFinish = function(self)
	UnLoadPlist(self.plist)
end

return ClsRankMainUI