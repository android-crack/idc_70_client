--
-- 商会钻石捐献
--

local ClsBaseView 			= require("ui/view/clsBaseView")
local music_info 			= require("scripts/game_config/music_info")
local ui_word 				= require("game_config/ui_word")
local ClsAlert 				= require("ui/tools/alert")

local ClsGuildDonatePanel 	= class("ClsGuildDonatePanel", ClsBaseView)

ClsGuildDonatePanel.getViewConfig = function(self)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

ClsGuildDonatePanel.onEnter = function(self)
	self["donate_times"] 		= nil
	self["award_num"] 			= nil
	self["last_times"] 			= nil
	self["diamond_num"] 		= nil
	self["donation_progress"] 	= nil 
	self["donation_progress_num"] 	= nil
	self["btn_close"] 			= nil
	self["btn_gold"] 			= nil
	self["btn_txt_diamond"] 	= nil

	self:initUI()
	self:updateGuildLevel()
	getGameData():getGuildInfoData():askGuildInvestInfo()
end

ClsGuildDonatePanel.initUI = function(self)
	local panel = GUIReader:shareReader():widgetFromJsonFile( "json/guild_hall_donate.json" )
	self:addWidget(panel)

	local widget_names = {
		"donation_progress",
		"donation_progress_num",
		"donate_times",
		"award_num",
		"last_times",
		"diamond_num",
		"btn_close",
		"btn_gold",
		"btn_txt_diamond"
	}
	for i, name in pairs(widget_names) do
		self[name] = getConvertChildByName(panel, name)
	end

	self.btn_close:setPressedActionEnabled(true)
	self.btn_gold:setPressedActionEnabled(true)

	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
	self.btn_gold:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:donate()
	end, TOUCH_EVENT_ENDED)
end

ClsGuildDonatePanel.updateInvestInfo = function(self)
	local invest_info = getGameData():getGuildInfoData():getInvestInfo()
	local data_handler = getGameData():getGuildInfoData()

	self.donate_times:setText(invest_info.invest_time - 1)
	self.diamond_num:setText(invest_info.consume)

	local times = invest_info.invest_all
	if times == -1 then
		self.last_times:setText(ui_word.STR_GUILD_INVEST_TIPS_NON_LIMIT)
	else
		self.last_times:setText( times - (invest_info.invest_time - 1) )
	end

	for k, v in pairs(invest_info.reward) do
		if v.type == ITEM_INDEX_CONTRIBUTE then
			self.award_num:setText("x"..v.amount)
		end
	end

	if getGameData():getPlayerData():getGold() >= invest_info.consume then
		setUILabelColor(self.btn_txt_diamond, ccc3(dexToColor3B(COLOR_WHITE)))
	else
		setUILabelColor(self.btn_txt_diamond, ccc3(dexToColor3B(COLOR_RED)))
	end
end

ClsGuildDonatePanel.updateGuildLevel = function(self)
	local data_handler = getGameData():getGuildInfoData()
	local cur, max = data_handler:getCurExp(), data_handler:getMaxExp()
	if max == -1 then 
		self.donation_progress_num:setText("0/0")
		self.donation_progress:setPercent(0)
	else
		self.donation_progress_num:setText(cur.."/"..max)
		self.donation_progress:setPercent(cur / max * 100)
	end
end

ClsGuildDonatePanel.donate = function(self)
	local guild_data = getGameData():getGuildInfoData()
	local invest_info = guild_data:getInvestInfo()
	if invest_info then
		local invest_cost = invest_info.consume
		local player_data = getGameData():getPlayerData()
		local enough_gold = invest_cost <= player_data:getGold()
		if not enough_gold then
			local guild_info_ui = getUIManager():get("ClsGuildMainUI")
			local alertType = ClsAlert:getOpenShopType()
			ClsAlert:showJumpWindow(DIAMOND_NOT_ENOUGH, guild_info_ui, {come_type = alertType.VIEW_NORMAL_TYPE})
		else
			audioExt.playEffect(music_info.COMMON_GOLD.res)
			local guild_boss_data = getGameData():getGuildBossData()
			guild_boss_data:investBoss()
		end
	end
end

return ClsGuildDonatePanel