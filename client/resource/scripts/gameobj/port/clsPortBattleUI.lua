local cfg_music_info = require("game_config/music_info")
local clsUiTools = require("gameobj/uiTools")
local clsAlert = require("ui/tools/alert")
local cfg_ui_word = require("game_config/ui_word")
local cfg_port_info = require("game_config/port/port_info")
local clsDataTool = require("module/dataHandle/dataTools")
local cfg_guild_badge = require("game_config/guild/guild_badge")
local clsBaseView = require("ui/view/clsBaseView")
local port_fight_info = require("game_config/port/port_fight_info")

local ClsPortBattleUI = class("ClsPortBattleUI", clsBaseView)

local MAX_CHALLENGE = 2

local WIN = 1
local LOSE = -1

ClsPortBattleUI.getViewConfig = function(self)
	return {
	is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

local function setBtnStatus(btn, status)
	btn:setVisible(status)
	btn:setTouchEnabled(status)
end

ClsPortBattleUI.onEnter = function(self)
	self.plistTab = {
		["ui/guild_badge.plist"] = 1,
		["ui/guild_ui.plist"] = 1,
	}
	LoadPlist(self.plistTab)

	self.port_list = getGameData():getPortBattleData():getPortList()
	self.port_index = 1
	self.my_port_id = self.port_list[self.port_index]
	self.my_guild_id = getGameData():getGuildInfoData():getGuildId()
	self:askBaseData()
	self:mkUI()
	self:initUI()
	self:configEvent()
	self:updateUI()
end

ClsPortBattleUI.askBaseData = function(self)
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:askOccupyInfo(self.my_port_id)
end

local desc_txt = {
	["pub"] = cfg_ui_word.PUB_PORT_DESC,
	["ship"] = cfg_ui_word.SHIP_PORT_DESC,
	["market"] = cfg_ui_word.MARKET_PORT_DESC,
}

ClsPortBattleUI.mkUI = function(self)
	self.panel = createPanelByJson("json/portfight_war.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	local need_widget_name = {
		btn_close = "close_btn",
		-- btn_explain = "hint_btn",
		btn_apply = "btn_join",
		spr_vs_grey = "vs_grey",
		spr_vs_light = "vs_light",
		pal_occupy_info = "manager_panel",
		lbl_occupy_name = "manager_guild",
		lbl_occupy_prestige = "manager_prestige_num",
		spr_occupy_lose = "manager_lose",
		spr_occupy_win = "manager_win",
		lbl_occupy_rank = "top_num",
		spr_occupy_badge = "manager_badge",
		pal_manager_empty = "manager_empty",
		btn_apply_txt = "txt_join",
		lbl_close_time = "dead_line",
		lbl_close_tips = "end_time",
		lbl_txt_battle = "txt_battle",
		right_content = "right_content",
		btn_left = "war_left",
		btn_right = "war_right",
		lbl_title = "ui_title",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end

	for i = 1, MAX_CHALLENGE do
		local key = "lbl_challenge_rank_" .. i
		local value = "rank_num_" .. i
		self[key] = getConvertChildByName(self.panel, value)
		key = "lbl_challenge_name_" .. i
		value = "challenger_guild_" .. i
		self[key] = getConvertChildByName(self.panel, value)
		key = "lbl_challenge_prestige_" .. i
		value = "prestige_num_" .. i
		self[key] = getConvertChildByName(self.panel, value)
		key = "lbl_wait_" .. i 
		value = "txt_wait_" .. i
		self[key] = getConvertChildByName(self.panel, value)
		key = "pal_challenge_info_" .. i
		value = "challenger_panel_" .. i
		self[key] = getConvertChildByName(self.panel, value)
		key = "spr_challenger_badge_" .. i
		value = "challenger_badge_" .. i
		self[key] = getConvertChildByName(self.panel, value)
		key = "spr_challenger_lose_" .. i
		value = "challenger_lose_" .. i
		self[key] = getConvertChildByName(self.panel, value)
		key = "spr_challenger_win_" .. i
		value = "challenger_win_" .. i
		self[key] = getConvertChildByName(self.panel, value)
	end
end

ClsPortBattleUI.initUI = function(self)
	for i = 1, MAX_CHALLENGE do
		local key = "pal_challenge_info_" .. i
		self[key]:setVisible(false)
		key = "lbl_wait_" .. i
		self[key]:setVisible(false)
	end
	self.spr_vs_grey:setVisible(true)
	self.spr_vs_light:setVisible(false)

	setBtnStatus(self.btn_left, false)
	--只有一个候选港口
	if #self.port_list == 1 then
		setBtnStatus(self.btn_left, false)
		setBtnStatus(self.btn_right, false)
	end
end

ClsPortBattleUI.configEvent = function(self)
	-- self.btn_explain:setPressedActionEnabled(true)
	-- self.btn_explain:addEventListener(function()
	-- 	audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
	-- 	getUIManager():create("gameobj/port/clsPortBattleExplainUI")
	-- end, TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_apply:setPressedActionEnabled(true)
	self.btn_apply:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		if self.is_has_result then
			getUIManager():create("gameobj/port/clsPortBattleRankUI", nil, self.my_port_id)
			return
		end

		local port_battle_data = getGameData():getPortBattleData()
		if self.is_can_fight then
			port_battle_data:askBattleEnter(self.my_port_id)
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_left:setPressedActionEnabled(true)
	self.btn_left:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self.port_index = self.port_index - 1
		self:showtoggleBtn(true)
		if self.port_index <= 0 then
			self.port_index = 1
			return
		end
		self.my_port_id = self.port_list[self.port_index]
		self:askBaseData()
	end, TOUCH_EVENT_ENDED)

	self.btn_right:setPressedActionEnabled(true)
	self.btn_right:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
		self.port_index = self.port_index + 1
		self:showtoggleBtn(true)
		if self.port_index > #self.port_list then
			self.port_index = #self.port_list
			return
		end
		self.my_port_id = self.port_list[self.port_index]
		self:askBaseData()
	end, TOUCH_EVENT_ENDED)

	self.pal_occupy_info:addEventListener(function()
		local port_battle_data = getGameData():getPortBattleData()
		local occupy_info = port_battle_data:getOccupyInfo(self.my_port_id)
		if not occupy_info or not occupy_info.groupId or occupy_info.groupId == 0 then
			return 
		end

		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		if self.my_guild_id ~= occupy_info.groupId then
			getGameData():getGuildInfoData():requestOtherGuildInfo(occupy_info.groupId)
			return 
		end
	end, TOUCH_EVENT_ENDED)

	for i = 1, MAX_CHALLENGE do
		local key = "pal_challenge_info_" .. i
		self[key]:addEventListener(function()
			local port_battle_data = getGameData():getPortBattleData()
			local challenge_info_list = port_battle_data:getChallengeInfoList(self.my_port_id)
			local data = challenge_info_list[i]
			if not data or not data.groupId then
				return 
			end
			audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
			if data.groupId ~= self.my_guild_id then
				getGameData():getGuildInfoData():requestOtherGuildInfo(data.groupId)
				return
			end
		end, TOUCH_EVENT_ENDED)
	end
end

ClsPortBattleUI.updateUI = function(self)
	local port_battle_data = getGameData():getPortBattleData()
	local occupy_info = port_battle_data:getOccupyInfo(self.my_port_id)
	local occupy_guild_id = occupy_info.groupId
	local is_has_occupy = (occupy_guild_id and occupy_guild_id ~= 0) 
	self.lbl_occupy_name:setVisible(is_has_occupy)
	self.lbl_occupy_rank:setVisible(is_has_occupy)
	self.spr_occupy_badge:setVisible(is_has_occupy)
	self.lbl_occupy_prestige:setVisible(is_has_occupy)
	self.pal_manager_empty:setVisible(not is_has_occupy)
	self.pal_occupy_info:setVisible(is_has_occupy)
	self.pal_occupy_info:setTouchEnabled(is_has_occupy)
	self.spr_occupy_win:setVisible(false)
	self.spr_occupy_lose:setVisible(false)
	self.lbl_title:setText(cfg_port_info[self.my_port_id].name)
	if is_has_occupy then
		self.lbl_occupy_name:setText(occupy_info.group_name)
		self.lbl_occupy_rank:setText(occupy_info.group_rank)
		self.lbl_occupy_prestige:setText(occupy_info.group_prestige)
		local icon_res = cfg_guild_badge[tonumber(occupy_info.group_icon)].res
		self.spr_occupy_badge:changeTexture(icon_res, UI_TEX_TYPE_PLIST)
		if occupy_info.isWin == WIN then
			self.spr_occupy_win:setVisible(true)
		elseif occupy_info.isWin == LOSE then
			self.spr_occupy_lose:setVisible(true)
		end
	end
	
	local challenge_info_list = port_battle_data:getChallengeInfoList(self.my_port_id)
	for i = 1, MAX_CHALLENGE do
		local data = challenge_info_list[i]
		local is_has_challenge = type(data) ~= "nil"
		local key = "pal_challenge_info_" .. i
		self[key]:setVisible(is_has_challenge)
		self[key]:setTouchEnabled(is_has_challenge)
		key = "lbl_wait_" .. i
		self[key]:setVisible(not is_has_challenge)
		if is_has_challenge then
			key = "lbl_challenge_rank_" .. i
			self[key]:setText(data.group_rank)
			key = "lbl_challenge_name_" .. i
			self[key]:setText(data.group_name)
			key = "lbl_challenge_prestige_" .. i
			self[key]:setText(data.group_prestige)
			key = "spr_challenger_badge_" .. i
			local icon_res = cfg_guild_badge[tonumber(data.group_icon)].res
			self[key]:changeTexture(icon_res, UI_TEX_TYPE_PLIST)
			key = "spr_challenger_lose_" .. i
			self[key]:setVisible(data.isWin == LOSE)
			key = "spr_challenger_win_" .. i
			self[key]:setVisible(data.isWin == WIN)
		end
	end
	
	local is_vs_info = false
	if is_has_occupy or #challenge_info_list ~= 0 then
		is_vs_info = true
	end
	self.spr_vs_light:setVisible(is_vs_info)
	self.spr_vs_grey:setVisible(not is_vs_info)
	
	self.is_can_fight = port_battle_data:isCanFight(self.my_port_id)
	self.is_has_result = not self.is_can_fight
	local is_end = port_battle_data:isEnd(self.my_port_id)
	local str_btn_txt = ""
	if self.is_can_fight then
		str_btn_txt = cfg_ui_word.STR_PORT_BATTLE_ENTER 
	end
	if self.is_has_result then
		str_btn_txt = cfg_ui_word.STR_PORT_BATTLE_CHECK
	end
	self.btn_apply_txt:setText(str_btn_txt)

	self.lbl_close_time:setVisible(true)
	self.lbl_close_tips:setVisible(true)
	self.lbl_txt_battle:setVisible(false)
	self.btn_apply:setTouchEnabled(false)
	self.btn_apply:setVisible(false)
	self.btn_apply:disable()

	if self.is_can_fight or self.is_has_result then
		self.btn_apply:setTouchEnabled(true)
		self.btn_apply:setVisible(true)
		self.btn_apply:active()
		-- if not self.is_can_fight and self.is_has_result then
		-- 	if #challenge_info_list == 0 then
				-- self.lbl_txt_battle:setText("")
				-- self.lbl_txt_battle:setVisible(true)
		-- 	end
		-- end
	end
	if is_end then
		-- self.lbl_txt_battle:setVisible(true)
		-- self.lbl_txt_battle:setText(cfg_ui_word.STR_PORT_BATTLE_END_TIPS)
		self.lbl_close_time:setVisible(false)
		self.lbl_close_tips:setVisible(false)
	end

	local player_data = getGameData():getPlayerData()
	local arr_action = CCArray:create()
	arr_action:addObject(CCCallFunc:create(function()
		local remain_time = port_battle_data:getRemainTime() - os.time() - player_data:getTimeDelta()
		if remain_time > 0 then
			self.lbl_close_time:setText(clsDataTool:getTimeStrNormal(remain_time))
			return
		else
			self.lbl_close_time:setVisible(false)
			self.lbl_close_tips:setVisible(false)
		end
		self.lbl_close_time:stopAllActions()
	end))
	arr_action:addObject(CCDelayTime:create(1))
	self.lbl_close_time:stopAllActions()
	self.lbl_close_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))

	local tip_text = cfg_ui_word.STR_PORT_BATTLE_FIGHT_TIPS
	if getGameData():getPortBattleData():getPortBattleStatus() == PORT_BATTLE_STATUS.START_WAR_2 then
		tip_text = cfg_ui_word.STR_PORT_BATTLE_FIGHT_END_TIPS
	end
	self.lbl_close_tips:setText(tip_text)

	local cur_port_info = port_fight_info[self.my_port_id]
	local show_txt = desc_txt[cur_port_info.type]
	show_txt = string.format(show_txt, cur_port_info.privilege)
	self.right_content:setText(show_txt)
end

ClsPortBattleUI.showtoggleBtn = function(self, is_show)
	setBtnStatus(self.btn_left, is_show)
	setBtnStatus(self.btn_right, is_show)
	if is_show then
		if #self.port_list == 1 then
			setBtnStatus(self.btn_left, false)
			setBtnStatus(self.btn_right, false)
		else
			setBtnStatus(self.btn_left, true)
			setBtnStatus(self.btn_right, true)
			if self.port_index == 1 then
				setBtnStatus(self.btn_left, false)
			end
			if self.port_index == #self.port_list then
				setBtnStatus(self.btn_right, false)
			end
		end
	end
end

ClsPortBattleUI.onExit = function(self)
	UnLoadPlist(self.plistTab)
end

return ClsPortBattleUI




