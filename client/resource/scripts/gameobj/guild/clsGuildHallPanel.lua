--
-- 商会大厅（没有商会时）
-- 显示「加入商会」和「悬赏任务」

local ClsBaseView 			= require("ui/view/clsBaseView")
local music_info 			= require("game_config/music_info")
local ClsGuideMgr 			= require("gameobj/guide/clsGuideMgr")
local clsGuildHallPanel 	= class("clsGuildHallPanel", ClsBaseView)

-- json url
local hall_panel_json		= "json/guild_hall_type.json"

-- 商会的跳转类型的枚举
local OPEN_SKIP 			= require("ui/clsGuildMainUI").OPEN_SKIP

local TAB_INDEX 			= { GUILD_LIST  = 1, GUILD_TASK = 2 }

-- 页签配置
local TAB_INFO 				= {
	[TAB_INDEX.GUILD_LIST] 	= {
		panel_class = require("gameobj/guild/clsGuildListPanel"),
		panel_url = "gameobj/guild/clsGuildListPanel",
		btn_name = "btn_add_guild"
	}, 
	[TAB_INDEX.GUILD_TASK] 	= {
		panel_class = require("gameobj/guild/clsGuildTaskPanel"),
		panel_url = "gameobj/guild/clsGuildTaskPanel",
		btn_name = "btn_xuanshang"
	}
}

-- 跳转配置
local SKIP_TO_INDEX 	= 
{
	[OPEN_SKIP.HALL] 	= TAB_INDEX.GUILD_LIST,
	[OPEN_SKIP.TASK] 	= TAB_INDEX.GUILD_TASK,
}

function clsGuildHallPanel:getViewConfig()
	return {
		["is_back_bg"] 	= true,
		["effect"] 		= UI_EFFECT.DOWN,
	}
end

function clsGuildHallPanel:onEnter(open_skip)
	self["tab_btns"] 	= {} 			-- 页签按钮
	self["btn_texts"]	= {} 			-- 页签按钮文本
	self["tab_index"]	= nil 			-- 哪个页签
	self["cur_tab"]		= nil 			-- 正在打开的页签

	if SKIP_TO_INDEX[open_skip] then 
		self.tab_index = SKIP_TO_INDEX[open_skip]
	else
		self.tab_index = TAB_INDEX.GUILD_LIST
	end

	self:initUI()

	self:changeTab(self.tab_index, open_skip)

	ClsGuideMgr:tryGuide("clsGuildHallPanel")
end

function clsGuildHallPanel:initUI()
	local panel = GUIReader:shareReader():widgetFromJsonFile( hall_panel_json )
	self:addWidget(panel)

	for index, info in pairs(TAB_INFO) do
		local btn = getConvertChildByName(panel, info.btn_name)
		local text = getConvertChildByName(panel, info.btn_name.."_text")

		btn:addEventListener(function() self:selectBtnEffect(index) end, TOUCH_EVENT_BEGAN)

		btn:addEventListener(function() self:selectBtnEffect(self.tab_index) end, TOUCH_EVENT_CANCELED)

		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:changeTab(index)
		end, TOUCH_EVENT_ENDED)

		self.tab_btns[index] = btn
		self.btn_texts[index] = text
	end
	self.guild_board_btn = self.tab_btns[TAB_INDEX.GUILD_TASK]
end

function clsGuildHallPanel:changeTab(tab_index, open_skip)
	self:selectBtnEffect(tab_index)

	if self.cur_tab then self.cur_tab:close() end

	self.tab_btns[self.tab_index]:setTouchEnabled(true)
	self.tab_btns[tab_index]:setTouchEnabled(false)

	if not open_skip then TAB_INFO[tab_index].panel_class:clearEffectOnce() end

	if tab_index == TAB_INDEX.GUILD_TASK then TAB_INFO[tab_index].panel_class:clearBackBgOnce() end
	self.cur_tab = getUIManager():create(TAB_INFO[tab_index].panel_url, {}, open_skip, true)
	-- 由于UI资源的层级关系，下一层的btn_close需要回传给上一级guildMainUI
	getUIManager():get("ClsGuildMainUI"):setBtnClose(self.cur_tab:getBtnClose())

	self.cur_tab:setCloseCB(function()
		getUIManager():get("ClsGuildMainUI"):effectClose()
	end)

	self.tab_index = tab_index
end

function clsGuildHallPanel:selectBtnEffect(tab_index)
	for key, index in pairs(TAB_INDEX) do
		if index == tab_index then
			self.tab_btns[index]:setFocused(true)
			setUILabelColor(self.btn_texts[index], ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
		else
			self.tab_btns[index]:setFocused(false)
			setUILabelColor(self.btn_texts[index], ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
		end
	end
end

function clsGuildHallPanel:updateList(list)
	if self.tab_index == TAB_INDEX.GUILD_LIST and not tolua.isnull(self.cur_tab) then
		self.cur_tab:updateList(list)
	end
end

function clsGuildHallPanel:preClose()
	self.cur_tab:close()
end

return clsGuildHallPanel