--
-- Author: lzg0496
-- Date: 2017-03-23 17:07:50
-- Function: jjc的传奇界面

local cfg_music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local cfg_nobility_data = require("game_config/nobility_data")
local cfg_ui_word = require("game_config/ui_word")
local ClsUiCommon = require("ui/tools/UiCommon")


local ClsRankItem = class("ClsRankItem", ClsScrollViewItem)

--[[
	{
        ["icon"] = "101",
        ["index"] = 1.000000,
        ["level"] = 55.000000,
        ["name"] = "换名2017",
        ["nobility"] = 70004.000000,
        ["prestige"] = 66160.000000,
        ["uid"] = 10007.000000,
    },

--]]

function ClsRankItem:updateUI(cell_data, cell_ui)
	local need_widget_name = {
		lbl_level =	"my_level",
		btn_fight = "btn_challenge",
		spr_icon = "head_icon",
		lbl_name = "grade_text_1",
		lbl_prestige = "prestige_num",
		lbl_rank = "my_rank_num",
        lbl_rank_art = "rank_art_txt",
		spr_title = "title_name",
        btn_head_icon = "head_bg",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(cell_ui, v)
	end

  	self.btn_fight:setPressedActionEnabled(true)
  	self.btn_fight:addEventListener(function()
  		local arena_data = getGameData():getArenaData()
  		arena_data:askLegendFight(cell_data.uid)
  	end, TOUCH_EVENT_ENDED)

    self.btn_head_icon:addEventListener(function()
        local playerData = getGameData():getPlayerData()
        if cell_data.uid == playerData:getUid() then
            getUIManager():create("gameobj/playerRole/clsRoleInfoView")
        else
            getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, cell_data.uid)
        end
    end, TOUCH_EVENT_ENDED)

  	local player_data = getGameData():getPlayerData()
  	if cell_data.uid == player_data:getUid() then
  		self.btn_fight:setEnabled(false)
  	end

  	self.lbl_level:setText("Lv." .. cell_data.level)
  	self.lbl_name:setText(cell_data.name)
  	local sailor = ClsDataTools:getSailor(cell_data.icon)
  	self.spr_icon:changeTexture(sailor.res)
  	self.lbl_prestige:setText(cell_data.prestige)
    self.lbl_rank:setText(cell_data.index)
    self.lbl_rank_art:setText(cell_data.index)

    self.lbl_rank:setVisible(cell_data.index > 5)
    self.lbl_rank_art:setVisible(cell_data.index <= 5)
    
  	local title_res = cfg_nobility_data[cell_data.nobility].peerage_before
  	title_res = convertResources(title_res)
  	self.spr_title:changeTexture(title_res, UI_TEX_TYPE_PLIST)
end

local ClsArenaLegendUI = class("ClsArenaLegendUI", ClsBaseView)

function ClsArenaLegendUI:getViewConfig()
	return {
		is_swallow = false,
		is_back_bg = true,
	}
end

function ClsArenaLegendUI:onEnter()
    self:tryShowChangeRankUI()

    self:makeUI()
    self:initUI()
    self:configEvent()

end

function ClsArenaLegendUI:tryShowChangeRankUI()
    local arena_data = getGameData():getArenaData()
    local change_info = arena_data:getLegendChangePlayerInfo()
    if change_info.old_rank then
        getUIManager():create("gameobj/arena/clsArenaLegendRankChange", nil, change_info.old_rank, change_info.new_rank, change_info.attack_name)
    end
    arena_data:setLegendChangePlayerInfo({})
end

function ClsArenaLegendUI:makeUI()
    self.panel = createPanelByJson("json/arena_rank.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

	local need_widget_name = {
		spr_head_icon = "head_icon",
		lbl_level = "my_level",
		lbl_rank = "my_rank_num",
		lbl_prestige = "prestige_num",
		lbl_grade = "grade_num",
		lbl_challenge = "challenge_num",
		btn_close = "btn_close",
		btn_reward = "award_box",
		lbl_leave_day = "title_name",
        btn_hint = "btn_tips",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end
end

function ClsArenaLegendUI:initUI()
	self.spr_head_icon:setVisible(false)
	self.lbl_level:setText("")
	self.lbl_rank:setText("")
	self.lbl_prestige:setText("")
	self.lbl_grade:setText("")
	self.lbl_challenge:setText("")
	self.lbl_leave_day:setText("")
end

function ClsArenaLegendUI:configEvent()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self:close()
		local arena_ui = getUIManager():get("ClsArenaMainUI")
		if not tolua.isnull(arena_ui) then
			arena_ui:close()
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_reward:addEventListener(function() 
        audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/arena/clsArenaLegendRewardUI")
	end, TOUCH_EVENT_ENDED)

    self.btn_hint:setPressedActionEnabled(true)
    self.btn_hint:addEventListener(function() 
        audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
        getUIManager():create("ui/clsDescribeUI", nil, {json = "arena_rank_rules.json", is_back_bg = true, is_click_bg_close = true})
    end, TOUCH_EVENT_ENDED)
end

function ClsArenaLegendUI:updataUI()
	local arena_data = getGameData():getArenaData()
	self.legend_info = arena_data:getLegendPlayerInfo()
	local reward = self.legend_info.rewards or {}
	self.is_has_reward = (#reward > 0)

	local player_data = getGameData():getPlayerData()
	local head_icon = player_data:getIcon()

	local sailor = ClsDataTools:getSailor(head_icon)
	self.spr_head_icon:changeTexture(sailor.res)
	self.spr_head_icon:setVisible(true)
	self.lbl_level:setText("Lv." .. player_data:getLevel())
	self.lbl_prestige:setText(player_data:getBattlePower())
	ClsUiCommon:numberEffect(self.lbl_rank, 0, self.legend_info.index, 30)
	local str_grade = string.format(cfg_ui_word.ARENA_GRADE, self.legend_info.fighted_win, self.legend_info.fighted_total)
	self.lbl_grade:setText(str_grade)
	self.lbl_challenge:setText(self.legend_info.current_left .. "/" ..  self.legend_info.current_total)
	local str_left_day = string.format(cfg_ui_word.ARENA_LEFT_DAY, self.legend_info.left_day)
	self.lbl_leave_day:setText(str_left_day)

	if tolua.isnull(self.rank_list_view) then
		self.rank_list_view = ClsScrollView.new(437, 427, true, function()
            local cell_ui = createPanelByJson("json/arena_rank_list.json")
            return cell_ui
        end, {is_fit_bottom = true})
		self:addWidget(self.rank_list_view)
		self.rank_list_view:setPosition(ccp(445, 25))
	end
	self.rank_list_view:removeAllCells()

	local cells = {}
	local cell_size	= CCSize(424, 90)
	for k,v in ipairs(self.legend_info.ranks) do
		local cell_tab = ClsRankItem.new(cell_size, v)
		cells[#cells +1] = cell_tab
	end
	self.rank_list_view:addCells(cells)
    if #cells > 0 then
        self.rank_list_view:scrollToCellIndex(#cells)
    end
end

function ClsArenaLegendUI:onExit()
end

return ClsArenaLegendUI