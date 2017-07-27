--
-- Author: lzg0496
-- Date: 2017-03-29 10:54:48
-- Function: 商会战站前信息界面

local ClsBaseView = require("ui/view/clsBaseView")
local cfg_music_info = require("game_config/music_info")
local cfg_ui_word = require("game_config/ui_word")
local cfg_title_info = require("game_config/title/info_title")
local ClsDataTools = require("module/dataHandle/dataTools")
local cfg_role_info = require("game_config/role/role_info")
local cfg_nobility_data = require("game_config/nobility_data")
local ClsGuildBattlePlayerItem = require("gameobj/copyScene/clsGuildBattlePlayerItem")

local ClsGuildBattleSoloUI = class("ClsGuildBattleSoloUI", ClsBaseView)

local APPLY_STATUS = 0
local FIGHT_STATUS = 1
local END_STATUS = 2

local MAX_CAMP = 2
local MAX_ELEMENT_COUNT = 3

ClsGuildBattleSoloUI.getViewConfig = function(self)
	return {
		is_back_bg = true,
	}
end

ClsGuildBattleSoloUI.onEnter = function(self, remain_time, camp_name_1, camp_name_2, is_hide)
	self.remain_time = remain_time 
	self.camp_name_1 = camp_name_1 or ""
	self.camp_name_2 = camp_name_2 or ""
	self.is_hide = is_hide

	self:setCurStatus()
	
	self:makeUI()
	self:initUI()
	self:configEvent()
end

ClsGuildBattleSoloUI.setCurStatus = function(self)
	self.cur_status = FIGHT_STATUS

	if self.remain_time > 0 then
		self.cur_status = APPLY_STATUS
		return
	end

	local guild_fight_data = getGameData():getGuildFightData()
	local solo_info = guild_fight_data:getSoloInfo()
	for camp = 1, MAX_CAMP do
		for element = 1, MAX_ELEMENT_COUNT do
			if solo_info[camp] and solo_info[camp][element] then
				if solo_info[camp][element].isWin == 0 then
					return
				end
			end
		end
	end

	self.cur_status = END_STATUS
end

ClsGuildBattleSoloUI.makeUI = function(self)
	self.panel = createPanelByJson("json/guild_stronghold_solo.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	local need_widget_name = {
		btn_close = "btn_close",
		btn_hint = "btn_hint",
		lbl_guild_name_1 = "guild_name_1",
		lbl_guild_name_2 = "guild_name_2",
		lbl_time_tips = "countdown",
		pal_vs_1 = "vs_bg_1",
		pal_vs_2 = "vs_bg_2",
		pal_vs_3 = "vs_bg_3",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end
end

ClsGuildBattleSoloUI.initUI = function(self)
	self.lbl_guild_name_1:setText(self.camp_name_1 or "")
	self.lbl_guild_name_2:setText(self.camp_name_2 or "")

	self.lbl_time_tips:setText("")

	local arr_action = CCArray:create()
	arr_action:addObject(CCCallFunc:create(function()
		if self.remain_time > 0 then
			local str_time = ClsDataTools:getTimeStrNormal(self.remain_time)
			str_time = str_time .. cfg_ui_word.STR_PORT_BATTLE_START_TIPS
			self.lbl_time_tips:setText(str_time)
			self.remain_time = self.remain_time - 1
			self:setCurStatus()
			return
		end

		self.lbl_time_tips:stopAllActions()
		self:setCurStatus()

		local str_tips = cfg_ui_word.GUILD_STRONGHOLD_FIGHT_TIPS
		if self.cur_status == END_STATUS then
			str_tips = cfg_ui_word.GUILD_STRONGHOLD_END_TIPS
		end

		self.lbl_time_tips:setText(str_tips)
	end))

	arr_action:addObject(CCDelayTime:create(1))

	self.lbl_time_tips:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))

	if self.is_hide then
		self.btn_hint:setVisible(false)
		self.btn_hint:setTouchEnabled(false)
	end
end

ClsGuildBattleSoloUI.configEvent = function(self)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_hint:setPressedActionEnabled(true)
	self.btn_hint:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		getUIManager():create("ui/clsDescribeUI", nil, {is_back_bg = true, json = "guild_stronghold_solo_hint.json"})
	end, TOUCH_EVENT_ENDED)
end

ClsGuildBattleSoloUI.updataUI = function(self)
	local guild_fight_data = getGameData():getGuildFightData()
	local solo_info = guild_fight_data:getSoloInfo()

	local str_item =  "player_item_%d_%d"
	local str_pan_vs = "pal_vs_%d"
	for camp = 1, MAX_CAMP do
		for element = 1, MAX_ELEMENT_COUNT do
			local item = string.format(str_item, camp, element)
			if tolua.isnull(self[item]) then
				local player_item = ClsGuildBattlePlayerItem.new(camp, element)
				self[item] = player_item
				local pal_vs = string.format(str_pan_vs, element)

				self[pal_vs]:addChild(player_item)
				local pos_x = 50
				if camp == 1 then
					pos_x = -290
				end
				self[item]:setPosition(ccp(pos_x, -43))
			end
			self[item]:updataUI(solo_info[camp][element], self.cur_status)
		end
	end
end

return ClsGuildBattleSoloUI

