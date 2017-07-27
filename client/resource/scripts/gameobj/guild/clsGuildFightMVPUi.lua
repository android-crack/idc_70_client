local music_info = require("game_config/music_info")
local nobility_conf = require("game_config/nobility_data")
local ui_word = require("game_config/ui_word")
local clsBaseView = require("ui/view/clsBaseView")
local ClsCommonFuns = require("gameobj/commonFuns")
local ClsGuildFightMVPUi = class("ClsGuildFightMVPUi", clsBaseView)

local WIDGET_INDEX = 3
local need_widget_name = {
	"player_prestige_",
	"nobility_",
	"player_name_",
	"player_level_",
	"player_job_",
	"head_",
	"tips_text_",
	"head_bg_",
	"player_prestige_txt_",
	"mvp_blank_",
	"nobility_bg_",
	"tips_bg_",
	"txt_title_name_",
}

ClsGuildFightMVPUi.getViewConfig = function(self)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

ClsGuildFightMVPUi.onEnter = function(self, ask_data_handler, get_data_handler, is_port_battle)
	self.res_plist_t = {
		["ui/guild_mvp.plist"] = 1,
	}
	LoadPlist(self.res_plist_t)
	self.is_port_battle = is_port_battle
	self.ask_data_handler = ask_data_handler
	self.get_data_handler = get_data_handler
	self:mkUI()
	self:initUI()
	self:regEvent()
	self:askMvpData()
end

ClsGuildFightMVPUi.askMvpData = function(self)
	if self.ask_data_handler then
		self.ask_data_handler()
		return
	end
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:askMVPInfo()
end

ClsGuildFightMVPUi.mkUI = function(self)
	local panel = createPanelByJson("json/guild_stronghold_mvp.json")
	self:addWidget(panel)
	for i = 1, WIDGET_INDEX do
		for _, v in pairs(need_widget_name) do
			self[v..i] = getConvertChildByName(panel, v..i)
		end
	end
	self.btn_close = getConvertChildByName(panel, "btn_close")
end

ClsGuildFightMVPUi.regEvent = function(self)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
end

ClsGuildFightMVPUi.initUI = function(self)
	local BLANK_BG_RES = "guild_mvp_blank.png"
	for i = 1, WIDGET_INDEX do
		for _, v in pairs(need_widget_name) do
			self[v..i]:setVisible(false)
		end
		self["txt_title_name_"..i]:setVisible(true)
		self["mvp_blank_"..i]:setVisible(true)
		self["head_bg_"..i]:setVisible(true)
		self["head_bg_"..i]:changeTexture(BLANK_BG_RES, UI_TEX_TYPE_PLIST)
	end
end

--[[
	index,
	name,
	icon,
	level,
	roleId,
	nobilityId,
	prestige,
	value,
]]
ClsGuildFightMVPUi.updateUI = function(self)
	local guild_fight_data = getGameData():getGuildFightData()
	local mvp_list = guild_fight_data:getMVPData()
	if self.get_data_handler then
		mvp_list = self.get_data_handler()
	end
	local MVP_TIP_TEXT = {
		ui_word.STR_GUILD_FIGHT_MVP_1,
		ui_word.STR_GUILD_FIGHT_MVP_2,
		ui_word.STR_GUILD_FIGHT_MVP_3,
	}

	for _, info in pairs(mvp_list or {}) do
		local seaman_res = string.format("ui/seaman/seaman_%s.png", info.icon)
		local index = info.index
		local nobilityMsg =	nobility_conf[info.nobilityId] or {}
		local file_name = nobilityMsg.peerage_before or "title_name_knight.png"

		file_name = convertResources(file_name)
		for _, v in pairs(need_widget_name) do
			self[v..index]:setVisible(true)
		end
		self["mvp_blank_"..index]:setVisible(false)
		self["nobility_bg_"..index]:setVisible(true)
		self["tips_bg_"..index]:setVisible(true)
		self["player_name_"..index]:setText(info.name)
		self["head_"..index]:changeTexture(seaman_res, UI_TEX_TYPE_LOCAL)
		self["player_level_"..index]:setText("Lv."..info.level)
		self["player_job_"..index]:setText(JOB_TITLE[info.roleId])
		self["head_bg_"..index]:changeTexture(SAILOR_JOB_BG[info.roleId].mvp, UI_TEX_TYPE_PLIST)
		self["player_prestige_"..index]:setText(info.prestige)
		self["nobility_"..index]:changeTexture(file_name, UI_TEX_TYPE_PLIST)
		self["tips_text_"..index]:setText(string.format(MVP_TIP_TEXT[index], info.value))
		self:alignLabel(self["player_prestige_txt_"..index], self["player_prestige_"..index], self["head_"..index], ClsCommonFuns:utfstrlen(tostring(info.prestige)))
	
		--港口战特殊显示
		if self.is_port_battle and index == 2 then
			self.tips_text_2:setText(string.format(ui_word.STR_PORT_BATTLE_FIGHT_MVP_2, info.value))
		end
	end

	if self.is_port_battle then
		self.txt_title_name_2:setText(ui_word.STR_PORT_BATTLE_MVP_NAME_1)
	end
end

--动态居中控件
ClsGuildFightMVPUi.alignLabel = function(self, text_obj, value_obj, base_obj, str_len)
	local ONE_CHAR_WIDTH = 8
	local widget_dis = 32
	local text_old_pos = text_obj:getPosition()
	local value_old_pos = value_obj:getPosition()
	local total_width = (str_len*ONE_CHAR_WIDTH + widget_dis)/2
	local new_pos = base_obj:getPosition().x - total_width
	text_obj:setPosition(ccp(new_pos, text_old_pos.y))
	value_obj:setPosition(ccp(widget_dis + new_pos, value_old_pos.y))
end

ClsGuildFightMVPUi.onExit = function(self)
	UnLoadPlist(self.res_plist_t)
end

return ClsGuildFightMVPUi