--
-- Author: lzg0496
-- Date: 2017-04-11 14:06:11
-- Function: jjc传奇奖励界面

local ClsBaseView = require("ui/view/clsBaseView")
local cfg_music_info = require("game_config/music_info")
local arena_stage_legendend = require("game_config/arena/arena_stage_legendend")

local ClsArenaLegendRewardUI = class("ClsArenaLegendRewardUI", ClsBaseView)

local MAX_SEASON_LAYER = 9

local MAX_SEASON = 3

local EVERYDAY = 1
local SEASON = 2

ClsArenaLegendRewardUI.getViewConfig = function(self)
	return {is_back_bg = true}
end

ClsArenaLegendRewardUI.onEnter = function(self)
	 self.res_plist = {
		["ui/equip_icon.plist"] = 1,
	}

	LoadPlist(self.res_plist)

	self:makeUI()
	self:initUI()
	self:configEvent()

	self.cur_show_ui = EVERYDAY

	self:updataUI()
end

ClsArenaLegendRewardUI.makeUI = function(self)
	self.panel = createPanelByJson("json/arena_rank_tips.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	local need_widget_name = {
		pal_everyday = "everyday_reward",
		btn_everyday = "btn_everyday",
		btn_close = "btn_close",
		lbl_everyday = "txt_everyday",
		pal_season_reward = "season_reward",
		btn_season = "btn_season",
		lbl_season = "txt_season",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end

	self.show_ui = {
		self.pal_everyday,
		self.pal_season_reward,
	}

	self.btn_tab = {
		self.btn_everyday,
		self.btn_season,
	}

	self.lbl_tab = {
		self.lbl_everyday,
		self.lbl_season,
	}
end

ClsArenaLegendRewardUI.initUI = function(self)
	self.pal_everyday:setVisible(false)
	self.pal_season_reward:setVisible(false)
end

ClsArenaLegendRewardUI.configEvent = function(self)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function() 
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self:setViewTouchEnabled(false)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_everyday:setPressedActionEnabled(true)
	self.btn_everyday:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		self:setViewTouchEnabled(false)
		self.cur_show_ui = EVERYDAY
		self:updataUI()
	end, TOUCH_EVENT_ENDED)

	self.btn_season:setPressedActionEnabled(true)
	self.btn_season:addEventListener(function()
			audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
			self:setViewTouchEnabled(false)
			self.cur_show_ui = SEASON
			self:updataUI()
	end, TOUCH_EVENT_ENDED)
end

ClsArenaLegendRewardUI.updataUI = function(self)
	for index = 1, #self.show_ui do 
		local is_select = (index == self.cur_show_ui)
		self.show_ui[index]:setVisible(is_select)
		self.btn_tab[index]:setBright(not is_select)
		self.btn_tab[index]:setTouchEnabled(not is_select)
		local color = COLOR_CAMEL
		if is_select then
			color = COLOR_WHITE
		end
		self.lbl_tab[index]:setUILabelColor(color)
	end

	if self.cur_show_ui == SEASON then
		local arena_data = getGameData():getArenaData()
		local cur_season = arena_data:getLegendPlayerInfo().season % MAX_SEASON
		if cur_season == 0 then
			cur_season = MAX_SEASON
		end
		local reward_tab = require("game_config/arena/arena_season_reward_" .. cur_season)
		self:updateSeasonReward(reward_tab)
	end

	self:setViewTouchEnabled(true)
end

ClsArenaLegendRewardUI.updateSeasonReward = function(self, reward_tab)
	for i = 1, MAX_SEASON_LAYER do
		local reward = reward_tab[i].reward[1]
		local spr_icon = getConvertChildByName(self.pal_season_reward, "equip_icon_" .. i)
		spr_icon:changeTexture(reward.icon, UI_TEX_TYPE_PLIST)

		local lbl_name_and_num = getConvertChildByName(self.pal_season_reward, "equip_txt_" .. i)
		local str_name = string.format("%s x%d", reward.name, reward.count)
		lbl_name_and_num:setText(str_name)

		local color = QUALITY_COLOR_STROKE[reward.quality + 1] --默认显示白色
		lbl_name_and_num:setUILabelColor(color)
	end
end

return ClsArenaLegendRewardUI