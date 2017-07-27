--
-- 商会列表
--

local ui_word 				= require("game_config/ui_word")
local Alert 				= require("ui/tools/alert")
local music_info 			= require("scripts/game_config/music_info")
local ClsCommonFuns 		= require("gameobj/commonFuns")
local ClsScrollView 		= require("ui/view/clsScrollView")
local ClsScrollViewItem 	= require("ui/view/clsScrollViewItem")
local ClsBaseView 			= require("ui/view/clsBaseView")
local guild_badge_info 		= require("game_config/guild/guild_badge")

local guild_list_json 		= "json/guild_hall_search.json"
local guild_list_cell 		= "json/guild_hall_search_list.json"

local RANK_OVER 			= 200
local ITEM_SIZE 			= {WIDTH = 430, HEIGHT = 38}

---------------------- ClsGuildListItem start ---------------------------------------
local ClsGuildListItem 		= class("ClsGuildListItem", ClsScrollViewItem)

ClsGuildListItem.updateUI = function(self, data, panel)
	self["data"] 			= data

	self["guild_rank"] 		= getConvertChildByName(panel, "guild_rank")
	self["guild_name"] 		= getConvertChildByName(panel, "guild_name")
	self["member_amount"] 	= getConvertChildByName(panel, "member_amount")
	self["guild_level"] 	= getConvertChildByName(panel, "guild_level")
	self["join_text"] 		= getConvertChildByName(panel, "join_text")
	self["guild_selected"] 	= getConvertChildByName(panel, "guild_selected")

	self.guild_name:setText(data.name)
	self.member_amount:setText(data.members.."/"..data.maxMembers)
	self.guild_level:setText("Lv."..data.grade)
	self.guild_rank:setText(self:convertGuildRank(data.rank))
	self.join_text:setVisible(data.inApplyList ~= 0)
end

ClsGuildListItem.askApplyGuild = function(self)
	local data_handler 	= getGameData():getGuildSearchData()

	local time_now 		= os.time()
	local time_apply 	= data_handler:getGuildApplyTime(self.data.id)

	if time_apply and time_now - time_apply < 8 then 
		return Alert:warning({msg = ui_word.GUILD_AAPLY_NO_OFTEN, color = ccc3(dexToColor3B(COLOR_RED))})
	end

	data_handler:setGuildApplyTime(self.data.id, time_now)
	data_handler:askApplyGuild(self.data.id)
end

ClsGuildListItem.convertGuildRank = function(self, rank)
	local guild_rank = ""
	if rank ~= 0 then
		guild_rank = rank
		if rank > RANK_OVER then
			guild_rank = ui_word.STR_GUILD_APPLY_RANK_LAB
		end
	end
	return guild_rank
end

ClsGuildListItem.focuesd = function(self, value)
	self.guild_selected:setVisible(value)
end

ClsGuildListItem.updateApplyState = function(self, value)
	self.join_text:setVisible(value)
end

ClsGuildListItem.getGuildId = function(self)
	return self.data.id
end

ClsGuildListItem.getGroupIcon = function(self)
	return self.data.icon
end
---------------------- ClsGuildListItem end -----------------------------------------


---------------------- ClsGuildListPanel, start --------------------------------------
local ClsGuildListPanel 	= class("ClsGuildListPanel", ClsBaseView)

local current_effect 		= nil

-- static
ClsGuildListPanel.clearEffectOnce = function(self)
	current_effect = 0
end

-- static
ClsGuildListPanel.getViewConfig = function(self)
	return {
		is_swallow = false, 
		effect = current_effect or UI_EFFECT.DOWN
	}
end

ClsGuildListPanel.onCtor = function(self)
	current_effect = nil
end

-- 需要统一获取的按钮以及设置按钮按压效果
local btn_widget_name 		= { "btn_close", "btn_search", "btn_cancel", "refresh_btn", "btn_enter", "btn_creat"}

ClsGuildListPanel.onEnter = function(self)
	self["panel"]			= nil 
	self["close_cb"] 		= nil
	self["btn_close"] 		= nil 		--close按钮在子节点的json上，父节点的关闭需要传个回调下来
	self["guild_list"]		= nil 		--商会列表
	self["input_box"] 		= nil 		--搜索商会的输入框
	self["btn_search"] 		= nil 		--搜索按钮
	self["btn_cancel"] 		= nil 		--撤销输入按钮
	self["refresh_btn"] 	= nil 		--刷新列表

	self["selected_cell"] 	= nil 		--选中的商会

	self["guild_name"] 		= nil 		--选中商会名字
	self["president_name"] 	= nil 		--选中商会会长
	self["brief_intro"] 	= nil 		--选中商会简介

	self["btn_enter"] 		= nil 		--申请加入
	self["btn_creat"] 		= nil 		--创建

	self:initUI()
	self:initEvent()
	getGameData():getGuildSearchData():askSearchGuild()
end

-- 初始化UI控件
ClsGuildListPanel.initUI = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile( guild_list_json )
	self:addWidget(self.panel)

	self.guild_name 	= getConvertChildByName(self.panel, "guild_brief_name")
	self.president_name = getConvertChildByName(self.panel, "president_name")
	self.brief_intro 	= getConvertChildByName(self.panel, "brief_intro")
	self.badge_icon 	= getConvertChildByName(self.panel, "badge_icon")
	
	for i, name in ipairs(btn_widget_name) do
		self[name] = getConvertChildByName(self.panel, name)
		self[name]:setPressedActionEnabled(true)
	end

	-- 初始化 输入框 和 列表，需要用代码创建
	self:initSearchInputBox()
	self:initGuildList()
	self:updateGuildBaseInfo()
end

-- 初始化按钮触摸
ClsGuildListPanel.initEvent = function(self)
	self.btn_close:addEventListener(function()			-- btn_close
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeBtnClick()
	end, TOUCH_EVENT_ENDED)

	self.btn_enter:addEventListener(function()			-- btn_enter
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.selected_cell then self.selected_cell:askApplyGuild() end
	end, TOUCH_EVENT_ENDED)

	self.btn_search:addEventListener(function()			-- btn_search
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local key_words = ClsCommonFuns:returnUTF_8CharValid( self.input_box:getText() )
		if self:checkKeyWords(key_words) then 
			getGameData():getGuildSearchData():askSearchGuild(key_words)
			self:setBtnSearch(false)
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_cancel:addEventListener(function()			-- btn_cancel
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.input_box:setText("")
		self:setBtnSearch(true)
	end, TOUCH_EVENT_ENDED)

	self.btn_creat:addEventListener(function() 			-- btn_creat
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/guild/guildCreateDlg")
	end, TOUCH_EVENT_ENDED)

	self.refresh_btn:addEventListener(function()		-- refresh_btn
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:setBtnRefresh(false)
		getGameData():getGuildSearchData():askSearchGuild()
	end, TOUCH_EVENT_ENDED)
end

-- 初始化编辑框
ClsGuildListPanel.initSearchInputBox = function(self)
	local frame = display.newSpriteFrame("common_9_block3.png")
	local sprite = CCScale9Sprite:createWithSpriteFrame(frame)
	self.input_box = CCEditBox:create(CCSize(244, 42), sprite)
	self.input_box:setPosition(350, 440)
	self.input_box:setPlaceholderFont(font_tab[FONT_COMMON], 16)
	self.input_box:setFont(font_tab[FONT_COMMON], 16)
	self.input_box:setPlaceHolder(ui_word.STR_GUILD_SEARCH_INPUT)
	self.input_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self.input_box:setFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self.input_box:setInputFlag(kEditBoxInputFlagSensitive)
	self.input_box:setMaxLength(7)
	self:addChild(self.input_box)

	self.input_box:registerScriptEditBoxHandler(function(eventType, target)
		if eventType == "ended" then
			self.btn_search:setVisible(true)
			self.btn_cancel:setVisible(false)
		end
	end)
end

-- 初始化商会列表
ClsGuildListPanel.initGuildList = function(self)
	self.guild_list = ClsScrollView.new(436, 240, true, function() return GUIReader:shareReader():widgetFromJsonFile( guild_list_cell ) end, {is_fit_bottom = true})
	self.guild_list:setPosition(ccp(172, 115))
	self:addWidget(self.guild_list)
end

-- 因为一些界面资源构造，父节点需要用到子节点的关闭
ClsGuildListPanel.setCloseCB = function(self, cb_func)
	if type(cb_func) == "function" then
		self.close_cb = cb_func
	end
end

-- 更新列表中的东西
ClsGuildListPanel.updateList = function(self, guild_list) 									-- update
	self:setBtnRefresh(true)

	if not guild_list then return end

	self.guild_list:removeAllCells()

	local onListCellTap = function(cell, x, y)
		if self.selected_cell and self.selected_cell == cell then return end

		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:selectCell(cell)
	end

	table.sort(guild_list, function(a, b) return a.rank < b.rank end)

	local guild_cells = {}
	for k, data in pairs(guild_list) do 
		local cell = ClsGuildListItem.new(CCSizeMake(ITEM_SIZE.WIDTH, ITEM_SIZE.HEIGHT), data)
		table.insert(guild_cells, cell)
		cell.onTap = onListCellTap
	end

	self.guild_list:addCells(guild_cells)
	self.guild_list:scrollToCellIndex(1)
	self:selectCell(guild_cells[1])
end

-- 更新选中的商会的基本信息
ClsGuildListPanel.updateGuildBaseInfo = function(self, info) 								-- update

	if not info then 
		self.btn_enter:setTouchEnabled(false)
	else
		self.btn_enter:setTouchEnabled(true)
	end

	info = info or {}

	self.guild_name:setText(info.name or "")
	self.president_name:setText(info.user_name or "")
	self.brief_intro:setText(self:convertGuildNotice(info.notice) or "")
end

-- 更新申请状态
ClsGuildListPanel.updateGuildApplyState = function(self, guild_id)
	if self.selected_cell:getGuildId() == guild_id then 
		return self.selected_cell:updateApplyState(true) 
	end

	for k, cell in pairs(self.guild_lsit:getAllCells()) do
		if cell:getGuildId() == guild_id then 
			return cell:updateApplyState(true)
		end
	end
end

-- 选中一个Cell要做的操作
ClsGuildListPanel.selectCell = function(self, cell)
	if not tolua.isnull(self.selected_cell) then 
		self.selected_cell:focuesd(false) 
	end
	if not tolua.isnull(cell) then
		cell:focuesd(true)
		getGameData():getGuildSearchData():askSearchBaseInfo(cell:getGuildId())
		self.selected_cell = cell

		local badge_info = guild_badge_info[tonumber(self.selected_cell:getGroupIcon() or 1)]
		self.badge_icon:changeTexture( convertResources(badge_info.res), UI_TEX_TYPE_PLIST )
	end
end

-- 检查搜索关键词
ClsGuildListPanel.checkKeyWords = function(self, key_words)
	if check_string_has_invisible_char(key_words) then
		Alert:warning({msg = ui_word.INPUT_ILLEGAL, color = ccc3(dexToColor3B(COLOR_RED))})
		return false
	end

	if ClsCommonFuns:utfstrlen(key_words) == 0 then
		Alert:warning({msg = ui_word.STR_GUILD_SEARCH_INPUT, color = ccc3(dexToColor3B(COLOR_RED))})
		return false
	end

	if not checkNameTextValid(key_words) or not checkChatTextValid(key_words) then 
		return false 
	end

	return true
end

ClsGuildListPanel.getBtnClose = function(self)
	return self.btn_close
end

ClsGuildListPanel.closeBtnClick = function(self)
	if self.close_cb then 
		self.close_cb()
	else
		self:close()
	end
end

ClsGuildListPanel.convertGuildNotice = function(self, notice)
	if not notice then return nil end
	local limit_len  = 17 * 4 - 1
	local notice_len = ClsCommonFuns:utfstrlen(notice)
	if notice_len > limit_len then 
		notice = ClsCommonFuns:utf8sub(notice, 1, limit_len) .. "..."
	end
	return notice
end

ClsGuildListPanel.setBtnSearch = function(self, value)
	self.btn_search:setVisible(value)
	self.btn_cancel:setVisible(not value)
end

ClsGuildListPanel.setBtnRefresh = function(self, value)
	self.refresh_btn:setTouchEnabled(value)
	if value then 
		self.refresh_btn:active()
	else
		self.refresh_btn:disable()
	end
end

return ClsGuildListPanel
---------------------- ClsGuildListPanel end ----------------------------------------