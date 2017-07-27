--
-- Author: lzg0496
-- Date: 2015-12-14 16:14:01
-- Function: 商会战开战界

local clsBaseView = require("ui/view/clsBaseView")
local clsUiWord = require("game_config/ui_word")
local clsAlert = require("ui/tools/alert")
local music_info = require("scripts/game_config/music_info")
local clsDataTools = require("module/dataHandle/dataTools")
local error_info = require("game_config/error_info")

local FIGHT_ACTITY_TIME = 1800
local MAX_TURRET_AMOUNT = 6
local WIN_STATUS = 1
local LOSE_STATUS = -1
local NOT_JOIN_STATUS = 0

local clsGuildFightUI = class("clsGuildFightUI", clsBaseView)

clsGuildFightUI.getViewConfig = function(self, ...)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

clsGuildFightUI.onEnter = function(self)
	-- self:askBaseData()
	self.res_plist_t = {
	}
	LoadPlist(self.res_plist_t)
	self:mkUI()
	self:initUI()
	self:configEvent()
end

clsGuildFightUI.askBaseData = function(self)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:askBattleInfo()
end

clsGuildFightUI.mkUI = function(self)
	local title_panel = createPanelByJson("json/guild_stronghold.json")
	local need_widget_name = {
		btn_close = "btn_close",
	}
	self:addWidget(title_panel)
	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(title_panel, v)
	end

	local content_panel = createPanelByJson("json/guild_stronghold_battle.json")
	content_panel:setPosition(ccp(95, 15))
	self:addWidget(content_panel)

	need_widget_name = {
		btn_fight = "btn_fight",
		lbl_start_time_txt = "last_time", --剩余时间的文字
		lbl_start_time = "last_time_num",

		btn_rank_icon = "btn_rank_icon",
		lbl_fight_text = "btn_fight_text",
		lbl_rank_text = "btn_rank_text",
		btn_fight_icon = "btn_fight_icon",

		lbl_ready_time = "perpare_time_num", 
		lbl_ready_time_txt = "perpare_time", --"后开始"的文字

		lbl_leave_time = "close_time_num",
		lbl_leave_time_txt = "close_time", -- 关闭时间的文字

		--攻击方
		lbl_attack_guild_name = "guild_name_1",
		lbl_attack_guild_amount = "guild_amount_1",
		lbl_attack_military_win = "military_win_num_1",
		lbl_attack_reputation_num = "reputation_num_1",
		lbl_attack_progress_num = "progress_num_1",
		pro_attack_progress = "my_progress",
		Icon_battle_resule_1 = "battle_result_1",

		--防御方
		lbl_defense_guild_name = "guild_name_2",
		lbl_defense_guild_amount = "guild_amount_2",
		lbl_defense_military_win = "military_win_num_2",
		lbl_defense_reputation_num = "reputation_num_2",
		lbl_defense_progress_num = "progress_num_2",
		pro_defense_progress = "enemy_progress",
		lbl_defense_reputation_txt = "reputation_2",
		Icon_battle_resule_2 = "battle_result_2",
	}
	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(content_panel, v)
	end

	for i = 1, MAX_TURRET_AMOUNT do
		local str_name = "stronghold_" .. i
		local str_name_1 = "spr_turret_" .. i
		self[str_name_1] = getConvertChildByName(content_panel, str_name)
		str_name = "stronghold_name_" .. i
		str_name_1 = "lbl_turret_" .. i
		self[str_name_1] = getConvertChildByName(content_panel, str_name)
		str_name = "bar_" .. i
		str_name_1 = "bar_turret_" .. i
		self[str_name_1] = getConvertChildByName(content_panel, str_name)
	end
	self.no_data_panel = getConvertChildByName(content_panel, "no_data")
	self.battle_panel = getConvertChildByName(content_panel, "battle_panel")
end

clsGuildFightUI.initUI = function(self)
	self.btn_fight:disable()
	self.lbl_attack_guild_name:setText("")
	self.lbl_attack_guild_amount:setText("")
	self.lbl_attack_military_win:setText("")
	self.lbl_attack_reputation_num:setText("")
	self.lbl_attack_progress_num:setText("")
	self.pro_attack_progress:setPercent(0)
	self.lbl_defense_guild_name:setText("")
	self.lbl_defense_guild_amount:setText("")
	self.lbl_defense_military_win:setText("")
	self.lbl_defense_reputation_num:setText("")
	self.lbl_defense_progress_num:setText("")
	self.pro_defense_progress:setPercent(0)
	self.btn_rank_icon:setVisible(false)
	self.lbl_fight_text:setVisible(false)
	self.lbl_rank_text:setVisible(false)
	self.btn_fight_icon:setVisible(false)
	for i = 1, MAX_TURRET_AMOUNT do
		local str_name_1 = "spr_turret_" .. i
		self[str_name_1]:setVisible(false)
	end
end

clsGuildFightUI.configEvent = function(self)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_fight:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local vs_data = getGameData():getGuildFightData():getVSData()
		if not vs_data then return end
		local guild_fight_data = getGameData():getGuildFightData()
		if vs_data[1].win_camp == NOT_JOIN_STATUS and vs_data[2].win_camp == NOT_JOIN_STATUS then
			guild_fight_data:askEnterBattleScene()
		else
			if vs_data[1].score == NOT_JOIN_STATUS and vs_data[2].score == NOT_JOIN_STATUS then
				local ERROR_ID = 871
				clsAlert:warning({msg = error_info[ERROR_ID].message})
			else
				getUIManager():create("gameobj/guild/clsGuildFightRankUI", nil, nil, nil, true)
			end
		end
	end, TOUCH_EVENT_ENDED)
end

clsGuildFightUI.showDefaultUI = function(self)
	local LEFT_OWN_CAMP = 1
	local vs_data = getGameData():getGuildFightData():getVSData()
	if not vs_data then return end
	local is_left = vs_data[1].camp == LEFT_OWN_CAMP
	for i = 1, MAX_TURRET_AMOUNT do
		local str_name_1 = "bar_turret_" .. i
		self[str_name_1]:setPercent(100)

		str_name_1 = "spr_turret_" .. i
		self[str_name_1]:setVisible(true)
		self[str_name_1]:changeTexture("guild_castle_blue.png", UI_TEX_TYPE_PLIST)
		if i ~= 1 or i ~= 4 then
			self[str_name_1]:changeTexture("guild_turret_blue.png", UI_TEX_TYPE_PLIST)
		end
		local is_other_camp = nil
		if is_left then
			if i >= MAX_TURRET_AMOUNT/2 then
				is_other_camp = true
			end
		else
			if i <= MAX_TURRET_AMOUNT/2 then
				is_other_camp = true
			end
		end
		if is_other_camp then
			self[str_name_1]:changeTexture("guild_castle_red.png", UI_TEX_TYPE_PLIST)
			if i ~= 1 or i ~= 4 then
				self[str_name_1]:changeTexture("guild_turret_red.png", UI_TEX_TYPE_PLIST)
			end
		end
	end
end

clsGuildFightUI.updateUI = function(self)
	local guild_fight_data = getGameData():getGuildFightData()
	local player_data = getGameData():getPlayerData()
	local vs_data = guild_fight_data:getVSData()
	local fight_time = guild_fight_data:getFightTime()
	fight_time = fight_time - (os.time() - player_data:getTimeDelta())
	local guard_data = guild_fight_data:getGuardData()

	if table.is_empty(vs_data) or not vs_data[1] then
		-- self:close()
		self.battle_panel:setVisible(false)
		self.no_data_panel:setVisible(true)
		self.btn_fight:setTouchEnabled(false)
		return
	end
	
	local is_leave_status = vs_data[1].finished

	for index, info in ipairs(vs_data) do
		local str_name = "Icon_battle_resule_"..index
		local res_str = nil
		if info.win_camp == WIN_STATUS then
			res_str = "ui/txt/txt_guildwar_win.png"
		elseif info.win_camp == LOSE_STATUS then
			res_str = "ui/txt/txt_guildwar_lose.png"
		end
		self[str_name]:setVisible(false)
		if res_str then
			self[str_name]:setVisible(true)
			self[str_name]:changeTexture(res_str, UI_TEX_TYPE_LOCAL)
		end
	end

	self.btn_fight:active()
	local attack_data = vs_data[1]
	local defense_data = vs_data[2]
	local sum_score = attack_data.score + defense_data.score
	if sum_score == 0 then
	   sum_score = 1 
	end
	self.lbl_attack_guild_name:setText(attack_data.name)
	self.lbl_attack_guild_amount:setText(attack_data.amount)
	self.lbl_attack_military_win:setText(attack_data.wins)
	self.lbl_attack_reputation_num:setText(attack_data.prestige)
	self.lbl_attack_progress_num:setText(attack_data.score)
	self.lbl_defense_guild_name:setText(defense_data.name)
	self.lbl_defense_guild_amount:setText(defense_data.amount)
	self.lbl_defense_military_win:setText(defense_data.wins)
	self.lbl_defense_reputation_num:setText(defense_data.prestige)
	self.lbl_defense_progress_num:setText(defense_data.score)
	self.pro_attack_progress:setPercent(attack_data.score / sum_score * 100)
	self.pro_defense_progress:setPercent(defense_data.score / sum_score * 100)
	
	self.lbl_start_time_txt:setVisible(is_leave_status == 0)
	self.lbl_start_time:setVisible(is_leave_status == 0)
	self.lbl_ready_time:setVisible(is_leave_status == 0)
	self.lbl_ready_time_txt:setVisible(is_leave_status == 0)
	self.lbl_leave_time:setVisible(is_leave_status == 1)
	self.lbl_leave_time_txt:setVisible(is_leave_status == 1)

	local lbl_num = self.lbl_defense_reputation_num
	local pos = ccp(0, self.lbl_defense_reputation_txt:getPosition().y)
	pos.x = lbl_num:getPosition().x - lbl_num:getContentSize().width
	self.lbl_defense_reputation_txt:setPosition(pos)


	local lbl_time = self.lbl_leave_time
	if is_leave_status ~= 1 then
		lbl_time = self.lbl_start_time
		self.lbl_start_time_txt:setVisible(fight_time <= FIGHT_ACTITY_TIME)
		self.lbl_start_time:setVisible(fight_time <= FIGHT_ACTITY_TIME)
		self.lbl_ready_time:setVisible(fight_time > FIGHT_ACTITY_TIME)
		self.lbl_ready_time_txt:setVisible(fight_time > FIGHT_ACTITY_TIME)
		if fight_time > FIGHT_ACTITY_TIME then
			fight_time = fight_time - FIGHT_ACTITY_TIME 
			lbl_time = self.lbl_ready_time
		end
	end

	lbl_time:stopAllActions()
	if fight_time ~= 0 then
		local arr_action = CCArray:create()
		arr_action:addObject(CCCallFunc:create(function()
			fight_time = fight_time - 1
			if fight_time <= 0 then
				-- self:askBaseData()
				lbl_time:stopAllActions()
				return 
			end
			lbl_time:setText(clsDataTools:getTimeStrNormal(fight_time))
		end))
		arr_action:addObject(CCDelayTime:create(1))
		lbl_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
	end

	if vs_data[1].win_camp ~= NOT_JOIN_STATUS and vs_data[2].win_camp ~= NOT_JOIN_STATUS then
		self.btn_rank_icon:setVisible(true)
		self.lbl_rank_text:setVisible(true)
	else
		self.btn_fight_icon:setVisible(true)
		self.lbl_fight_text:setVisible(true)
	end

	if table.is_empty(guard_data) then
		self:showDefaultUI()
		return
	end

	for i = 1, MAX_TURRET_AMOUNT do
		local str_name_1 = "spr_turret_" .. i
		self[str_name_1]:setVisible(true)
		local is_same_camp = guild_fight_data:isSameCamp(guard_data[i].camp)
		self[str_name_1]:changeTexture("guild_castle_blue.png", UI_TEX_TYPE_PLIST)
		if i ~= 1 or i ~= 4 then
			self[str_name_1]:changeTexture("guild_turret_blue.png", UI_TEX_TYPE_PLIST)
		end

		if not is_same_camp then
			self[str_name_1]:changeTexture("guild_castle_red.png", UI_TEX_TYPE_PLIST)
			if i ~= 1 or i ~= 4 then
				self[str_name_1]:changeTexture("guild_turret_red.png", UI_TEX_TYPE_PLIST)
			end
		end
	
		str_name_1 = "lbl_turret_" .. i
		local color = ccc3(dexToColor3B(COLOR_BLUE_STROKE))
		if not is_same_camp then
			color = ccc3(dexToColor3B(COLOR_RED_STROKE))
		end
		setUILabelColor(self[str_name_1], color)

		str_name_1 = "bar_turret_" .. i
		if guard_data then
			self[str_name_1]:setPercent(guard_data[i].hp / guard_data[i].max_hp * 100)
		end
	end
end

clsGuildFightUI.onExit = function(self)
	UnLoadPlist(self.res_plist_t)
end

return clsGuildFightUI
