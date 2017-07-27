--
-- 悬赏任务
--

local Alert 				= require("ui/tools/alert")
local ui_word 				= require("game_config/ui_word")
local music_info 			= require("game_config/music_info")
local ClsPortRewardUI 		= require("gameobj/port/clsPortRewardUI")
local ClsGuildTaskMain 		= require("gameobj/guild/clsGuildTaskMain")
local ClsBaseView 			= require("ui/view/clsBaseView")
local on_off_info 			= require("game_config/on_off_info")

local ClsGuildTaskPanel 	= class("ClsGuildTaskPanel", ClsBaseView)

local TAB_INDEX 			= { REWARD_TASK = 1, MULTI_TASK = 2 }

local BTN_NAME 				= {
	[TAB_INDEX.REWARD_TASK] = "xsh", 
	[TAB_INDEX.MULTI_TASK] 	= "multi"
}

local guild_task_bg_json 	= "json/guild_task_bg.json"

local current_effect 		= nil

local current_back_bg 		= true
-- static
ClsGuildTaskPanel.clearEffectOnce = function(self)
	current_effect = 0
end

ClsGuildTaskPanel.clearBackBgOnce = function(self)
	current_back_bg = false
end

-- static
ClsGuildTaskPanel.getViewConfig = function(self)
	return {
		is_back_bg = current_back_bg,
		is_swallow = current_back_bg, 
		effect = current_effect or UI_EFFECT.DOWN
	}
end

ClsGuildTaskPanel.resetEffectConfig = function(self)
	current_effect = nil
	current_back_bg = true
end

ClsGuildTaskPanel.onEnter = function(self, open_skip)
	self["cur_pos"] = ccp(0, 0)
	self["tab_btns"] = {}
	self["btn_texts"] = {}
	self["cur_tab"] = nil
	self["tab_index"] = TAB_INDEX.REWARD_TASK
	self["btn_close"] = nil
	self["close_cb"] = nil
	self["set_tab"] = false

	self["plist_tab"] = 
	{
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/guild_ui.plist"] = 1,
	}
	LoadPlist(self.plist_tab)

	if not current_back_bg then self.cur_pos = ccp(65, 20) end

	-- if not open_skip then
		if open_skip ==  "guild_multi_task" or open_skip == "task_detail_multi" then 
			self.tab_index = TAB_INDEX.MULTI_TASK
		end
	-- end

	self:initUI()
	self:changeTab(self.tab_index, open_skip)

	self.set_tab = true

	ClsGuildTaskPanel.resetEffectConfig()
end

ClsGuildTaskPanel.initUI = function(self)
	local panel = GUIReader:shareReader():widgetFromJsonFile( guild_task_bg_json )
	panel:setPosition(self.cur_pos)
	self:addWidget(panel)

	local diamond_bar = getConvertChildByName(panel, "diamond_bar")
	local diamond_layer = require("ui/tools/clsPlayerInfoItem").new(ITEM_INDEX_TILI)
	diamond_bar:addCCNode(diamond_layer)

	for index, name in pairs(BTN_NAME) do
		local btn = getConvertChildByName(panel, "tab_"..name)
		local text = getConvertChildByName(panel, name.."_text")

		btn:addEventListener(function() self:selectBtnEffect(index) end, TOUCH_EVENT_BEGAN)

		btn:addEventListener(function() self:selectBtnEffect(self.tab_index) end, TOUCH_EVENT_CANCELED)

		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:changeTab(index)
		end, TOUCH_EVENT_ENDED)

		self.tab_btns[index] = btn
		self.btn_texts[index] = text
	end

	--多人任务注册红点
	getGameData():getTaskData():regTask(self.tab_btns[TAB_INDEX.MULTI_TASK], {
		on_off_info.GUILD_MULTI_TASK.value,--商会任务
		on_off_info.GUILD_TASK.value,
	}, KIND_CIRCLE, on_off_info.GUILD_MULTI_TASK.value, 45, 10, true)

	self.btn_close = getConvertChildByName(panel, "close_btn")
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeBtnClick()
	end, TOUCH_EVENT_ENDED)
end

ClsGuildTaskPanel.changeTab = function(self, tab_index, open_skip)
	if tab_index == TAB_INDEX.MULTI_TASK then
		if not self:checkMultiStatus() then 
			self:selectBtnEffect(self.tab_index)
		end
	end

	self:selectBtnEffect(tab_index)

	if self.cur_tab then self.cur_tab:close() end

	self.tab_btns[self.tab_index]:setTouchEnabled(true)
	self.tab_btns[tab_index]:setTouchEnabled(false)

	if tab_index == TAB_INDEX.REWARD_TASK then
		self:openRewardUI(open_skip)
	else
		self:openMultiUI(open_skip)
	end

	self.tab_index = tab_index
end

ClsGuildTaskPanel.openRewardUI = function(self, open_skip)
	if self.set_tab or not open_skip then ClsPortRewardUI:clearEffectOnce() end
	
	self.cur_tab = getUIManager():create("gameobj/port/clsPortRewardUI", nil, self.cur_pos)
	-- 第一次打开的时候播放音效？
	self.cur_tab:setIsPlayGetSound(not self.set_tab)
end

ClsGuildTaskPanel.openMultiUI = function(self, open_skip)
	if self.set_tab or not open_skip then ClsGuildTaskMain:clearEffectOnce() end

	self.cur_tab = getUIManager():create("gameobj/guild/clsGuildTaskMain", nil, open_skip, self.cur_pos)
end

ClsGuildTaskPanel.selectBtnEffect = function(self, tab_index)
	for key, index in pairs(TAB_INDEX) do
		if index == tab_index then
			self.tab_btns[index]:setFocused(true)
			setUILabelColor(self.btn_texts[index], ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		else
			self.tab_btns[index]:setFocused(false)
			setUILabelColor(self.btn_texts[index], ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
		end
	end
end

ClsGuildTaskPanel.checkMultiStatus = function(self)
	if isExplore then 
		Alert:warning({msg = ui_word.TASK_MORE_MISSION_EXPLORE , size = 26})
		return false
	end

	local taskList = getGameData():getGuildTaskData():getGuildTaskList()
	local redPoint = self.tab_btns[TAB_INDEX.MULTI_TASK].taskEffect
	if((taskList and #taskList > 0) or (redPoint and redPoint:isVisible()))then
		return true
	else
		Alert:warning({msg = ui_word.GUILD_TASK_NO_TASK , size = 26})
		return false
	end
end

ClsGuildTaskPanel.setCloseCB = function(self, cb_func)
	if type(cb_func) == "function" then
		self.close_cb = cb_func
	end
end

ClsGuildTaskPanel.closeBtnClick = function(self)
	if self.close_cb then 
		self.close_cb() 
	else
		self:close()
	end
end

ClsGuildTaskPanel.getBtnClose = function(self)
	return self.btn_close
end

ClsGuildTaskPanel.preClose = function(self)
	if not tolua.isnull(self.cur_tab) then self.cur_tab:close() end
end

ClsGuildTaskPanel.onExit = function(self)
	UnLoadPlist(self.plist_tab)
end

return ClsGuildTaskPanel