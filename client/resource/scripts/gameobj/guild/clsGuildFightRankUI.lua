--
-- Author: lzg0496 
-- Date: 2016-12-03 14:26:25
-- Function: 商会战积分排行榜

local clsBaseView = require("ui/view/clsBaseView")
local music_info = require("scripts/game_config/music_info")
local clsScrollViewItem = require("ui/view/clsScrollViewItem")
local clsScrollView = require("ui/view/clsScrollView")
local composite_effect = require("gameobj/composite_effect")

local clsGuildFightRankItem = class("clsGuildFightRankItem", clsScrollViewItem)

clsGuildFightRankItem.updateUI = function(self, data, cell)
	local lbl_rank = getConvertChildByName(cell, "rank_num")
	lbl_rank:setText(data.rank)
	local rank_pic = getConvertChildByName(cell, "rank_pic")
	if data.rank <= 3 then
		rank_pic:setVisible(true)
		lbl_rank:setVisible(false)
		rank_pic:changeTexture("common_top_" .. data.rank .. ".png", UI_TEX_TYPE_PLIST)
	end

	local lbl_player_name = getConvertChildByName(cell, "rank_name")
	lbl_player_name:setText(data.name)

	local spr_winning = getConvertChildByName(cell, "txt_winning")
	spr_winning:setVisible(data.isStreak == 1)

	local lbl_attack = getConvertChildByName(cell, "attack_num")
	lbl_attack:setText(data.attack)

	local lbl_win = getConvertChildByName(cell, "win_num")
	lbl_win:setText(data.occupy)

	local lbl_score = getConvertChildByName(cell, "grade_num")
	lbl_score:setText(data.score)

	local is_myself = (data.uid == getGameData():getPlayerData():getUid())
	getConvertChildByName(cell, "myself_bg"):setVisible(is_myself)

end

local clsGuildFightRankUI = class("clsGuildFightRankUI", clsBaseView)

clsGuildFightRankUI.onEnter = function(self, is_guild, guild_call_back, is_show_mvp)
	self.guild_call_back = guild_call_back
	self.is_guild = is_guild
	self.is_show_mvp = is_show_mvp
	self:mkUI()
	self:configEvent()
	self:initUI()
	self:askBaseData()
end

clsGuildFightRankUI.askBaseData = function(self)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:askGuildBattleChart()
end

clsGuildFightRankUI.mkUI = function(self)
	local panel = createPanelByJson("json/guild_stronghold_sea_rank.json")
	local need_widget_name = {
		btn_close = "close",
		btn_prebattle = "btn_prebattle",
		btn_mvp = "btn_mvp",
		btn_tab_grade = "btn_tab_grade",
		btn_tab_award = "btn_tab_award",
		pal_grade = "tab1",
		pal_award = "tab2",
		lbl_tab_grade_txt = "grade_text",
		lbl_tab_award_txt = "award_text",

	}
	self:addWidget(panel)
	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(panel, v)
	end
end

clsGuildFightRankUI.initUI = function(self)
	self:clickGradeTab()
	if self.is_guild then
		self.guild_effect = composite_effect.bollow("tx_1042_1", 0, 0, self.btn_close)
	end
end

clsGuildFightRankUI.checkShowMvpBtn = function(self)
	self.btn_prebattle:setTouchEnabled(false)
	self.btn_prebattle:setVisible(false)
	self.btn_mvp:setTouchEnabled(false)
	self.btn_mvp:setVisible(false)
	if self.is_show_mvp then
		self.btn_prebattle:setTouchEnabled(true)
		self.btn_mvp:setTouchEnabled(true)
		self.btn_prebattle:setVisible(true)
		self.btn_mvp:setVisible(true)
	end
end

clsGuildFightRankUI.clickGradeTab = function(self)
	self:checkShowMvpBtn()
	self.btn_tab_grade:setFocused(true)
	self.btn_tab_award:setFocused(false)
	self.pal_grade:setVisible(true)
	self.pal_award:setVisible(false)
	setUILabelColor(self.lbl_tab_grade_txt, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
	setUILabelColor(self.lbl_tab_award_txt, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
end

clsGuildFightRankUI.clickAwardTab = function(self)
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
	end
	self:checkShowMvpBtn()
	self.btn_tab_grade:setFocused(false)
	self.btn_tab_award:setFocused(true)
	self.pal_grade:setVisible(false)
	self.pal_award:setVisible(true)
	setUILabelColor(self.lbl_tab_award_txt, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
	setUILabelColor(self.lbl_tab_grade_txt, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
end

clsGuildFightRankUI.configEvent = function(self)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
		if self.is_guild then
			self.guild_effect:removeFromParentAndCleanup(true)
			self.guild_call_back()
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_tab_grade:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:askBaseData()
		self:clickGradeTab()
	end, TOUCH_EVENT_ENDED)

	self.btn_tab_award:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:clickAwardTab()
	end, TOUCH_EVENT_ENDED)

	self.btn_prebattle:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local camp_name_1, camp_name_2 = nil, nil
		local vs_data = getGameData():getGuildFightData():getVSData()
		for _, info in pairs(vs_data) do
			if info.camp == 1 then
				camp_name_1 = info.name
			elseif info.camp == 2 then
				camp_name_2 = info.name
			end
		end
		getUIManager():create("gameobj/copyScene/clsGuildBattleSoloUI", nil, 0, camp_name_1, camp_name_2, true)
		getGameData():getGuildFightData():askSoleInfo()
	end, TOUCH_EVENT_ENDED)

	self.btn_mvp:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/guild/clsGuildFightMVPUi")
	end, TOUCH_EVENT_ENDED)
end

clsGuildFightRankUI.updateRankUI = function(self)
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
	end
	self.list_view = clsScrollView.new(738, 263, true, function()
		local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/guild_stronghold_sea_rank_information.json")
		return cell_ui
	end, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(-360, -150))
	self.pal_grade:addChild(self.list_view)

	local guild_fight_data = getGameData():getGuildFightData()
	local chart_data = guild_fight_data:getChartData()
	local cells = {}
	for k, data in ipairs(chart_data) do
		data.rank = k
		local cell = clsGuildFightRankItem.new(CCSize(738, 34), data)
		cells[#cells + 1] = cell
	end
	self.list_view:addCells(cells)
end

clsGuildFightRankUI.onExit = function(self)
end

return clsGuildFightRankUI