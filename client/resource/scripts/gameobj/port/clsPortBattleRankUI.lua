local ClsBaseView = require("ui/view/clsBaseView")
local composite_effect = require("gameobj/composite_effect")
local music_info = require("scripts/game_config/music_info")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsScrollView = require("ui/view/clsScrollView")

local winning_times = 3 --连胜场数

local ClsPortBattleRankItem = class("ClsPortBattleRankItem", ClsScrollViewItem)


ClsPortBattleRankItem.updateUI = function(self, data, cell)
	local lbl_rank = getConvertChildByName(cell, "rank_num")
	lbl_rank:setText(data.rank)
	local rank_pic = getConvertChildByName(cell, "rank_pic")
	if data.rank <= 3 then
		rank_pic:setVisible(true)
		lbl_rank:setVisible(false)
	end

	local lbl_player_name = getConvertChildByName(cell, "rank_name")
	lbl_player_name:setText(data.name)

	local spr_winning = getConvertChildByName(cell, "txt_winning")
	spr_winning:setVisible(data.win_streak >= winning_times)

	local lbl_attack = getConvertChildByName(cell, "attack_num")
	lbl_attack:setText(data.attack)

	local lbl_score = getConvertChildByName(cell, "grade_num")
	lbl_score:setText(data.score)
end


local ClsPortBattleRankUI = class("ClsPortBattleRankUI", ClsBaseView)

ClsPortBattleRankUI.onEnter = function(self, port_id, is_guide, guide_call_back, is_hide_mvp)
	self.guide_call_back = guide_call_back
	self.is_guide = is_guide
	self.is_hide_mvp = is_hide_mvp
	self.port_id = port_id
	self:mkUI()
	self:configEvent()
	self:initUI()
	self:askBaseData()
end

ClsPortBattleRankUI.mkUI = function(self)
	local panel = createPanelByJson("json/portfight_rank.json")
	local need_widget_name = {
		btn_close = "close",
		btn_tab_grade = "btn_tab_grade",
		btn_tab_award = "btn_tab_award",
		pal_grade = "tab1",
		pal_award = "tab2",
		lbl_tab_grade_txt = "grade_text",
		lbl_tab_award_txt = "award_text",
		btn_mvp = "btn_mvp",
	}
	self:addWidget(panel)
	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(panel, v)
	end

	local port_battle_ui = getUIManager():get("ClsPortBattleUI")
	if not tolua.isnull(port_battle_ui) then
		port_battle_ui:showtoggleBtn(false)
	end
end

ClsPortBattleRankUI.configEvent = function(self)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
		if self.is_guide then
			self.guide_effect:removeFromParentAndCleanup(true)
			self.guide_call_back()
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

	self.btn_mvp:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)

		local ask_data_handler = function()
			getGameData():getPortBattleData():askPortBattleMVP(self.port_id)
		end
		local get_data_handler = function()
			return getGameData():getPortBattleData():getMVPData()
		end
		getUIManager():create("gameobj/guild/clsGuildFightMVPUi", nil, ask_data_handler, get_data_handler, true)
	end, TOUCH_EVENT_ENDED)
end

ClsPortBattleRankUI.initUI = function(self)
	self:clickGradeTab()
	if self.is_guide then
		self.guide_effect = composite_effect.bollow("tx_1042_1", 0, 0, self.btn_close)
	end

	self.btn_mvp:setTouchEnabled(true)
	if self.is_hide_mvp then
		self.btn_mvp:setVisible(false)
		self.btn_mvp:setTouchEnabled(false)
	end
end

ClsPortBattleRankUI.clickGradeTab = function(self)
	self.btn_tab_grade:setFocused(true)
	self.btn_tab_award:setFocused(false)
	self.pal_grade:setVisible(true)
	self.pal_award:setVisible(false)
	setUILabelColor(self.lbl_tab_grade_txt, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
	setUILabelColor(self.lbl_tab_award_txt, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
end

ClsPortBattleRankUI.clickAwardTab = function(self)
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
	end
	self.btn_tab_grade:setFocused(false)
	self.btn_tab_award:setFocused(true)
	self.pal_grade:setVisible(false)
	self.pal_award:setVisible(true)
	setUILabelColor(self.lbl_tab_award_txt, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
	setUILabelColor(self.lbl_tab_grade_txt, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
end

ClsPortBattleRankUI.askBaseData = function(self)
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:askBattleChart(self.port_id)
end

ClsPortBattleRankUI.updateRankUI = function(self)
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
	end
	self.list_view = ClsScrollView.new(738, 263, true, function()
		local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/portfight_rank_information.json")
		return cell_ui
	end, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(-360, -150))
	self.pal_grade:addChild(self.list_view)

	local port_battle_data = getGameData():getPortBattleData()
	local chart_data = port_battle_data:getBattleChart()
	local cells = {}
	for k, data in ipairs(chart_data) do
		data.rank = k
		local cell = ClsPortBattleRankItem.new(CCSize(738, 34), data)
		cells[#cells + 1] = cell
	end
	self.list_view:addCells(cells)
end


ClsPortBattleRankUI.onExit = function(self)
	local port_battle_ui = getUIManager():get("ClsPortBattleUI")
	if not tolua.isnull(port_battle_ui) then
		port_battle_ui:showtoggleBtn(true)
	end
end

return ClsPortBattleRankUI
