--
-- Author: Ltian
-- Date: 2015-10-26 11:03:36
--
local dataTools = require("module/dataHandle/dataTools")
local music_info = require("game_config/music_info")
local guild_badge = require("game_config/guild/guild_badge")
local ui_word = require("game_config/ui_word")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsMailItem = class("ClsMailItem", ClsScrollViewItem)
local widget_name = {
	"mail_title",
	"mail_content",
	"time",
	"get",
	"btn_get",
	"num",
	"red_dot",
	"btn_read",
}

local reward_widget = {
	{num = "num_1", pic = "pic_1", bg = "item_1"},
	{num = "num_2", pic = "pic_2", bg = "item_2"},
	{num = "num_3", pic = "pic_3", bg = "item_3"},
}

local delete_time = 561600

function ClsMailItem:getTime(orign_time)
	local last_login_time =  ""
	local original_time = os.time() - tonumber(orign_time)
	local time, time_tab = dataTools:getMostCnTimeStr(original_time)
	local isTime
	if original_time >= delete_time then
		isTime = true
	end

	if tonumber(time_tab.d) > 0 then
		last_login_time = time_tab.d..ui_word.STR_GUILD_TIME_DAY_TIPS
	elseif tonumber(time_tab.h) > 0 then
		last_login_time = time_tab.h..ui_word.STR_GUILD_TIME_HOUR_TIPS
	elseif tonumber(time_tab.m) > 0 then
		last_login_time = time_tab.m..ui_word.STR_GUILD_TIME_MIN_TIPS
	elseif tonumber(time_tab.s) > 0 then
		last_login_time = ui_word.FRIEND_S
	else
		last_login_time = ui_word.FRIEND_S
	end

	return last_login_time, isTime
end

function ClsMailItem:initUI(cell_date )
	self.lock = false
	self.panel = self.m_cell_ui
	self.panel:setPosition(ccp(0, 5))
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	for k,v in pairs(reward_widget) do
		self[v.num] = getConvertChildByName(self.panel, v.num)
		self[v.pic] = getConvertChildByName(self.panel, v.pic)
		self[v.bg] = getConvertChildByName(self.panel, v.bg)
		self[v.bg]:setVisible(false)
	end

	self.btn_get:setPressedActionEnabled(true)
	self.btn_get:addEventListener(function()

		if self.lock or not self then
			return
		end
		self.lock = true
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		require("framework.scheduler").performWithDelayGlobal(function()
        	self.lock = false
   		 end , 1)

		local mail_no_tips = 0
		GameUtil.callRpc("rpc_server_mail_get_attachment", {self.data.id, mail_no_tips})
	end, TOUCH_EVENT_ENDED)
	self.btn_read:setPressedActionEnabled(true)
	self.btn_read:addEventListener(function ( )
		GameUtil.callRpc("rpc_server_mail_del", {self.data.id})
	end, TOUCH_EVENT_ENDED)
end


function ClsMailItem:updateUI(cell_date, cell_ui)
	self.data = cell_date.data
	index = cell_date.index


	local title = require("module/message_parse").parse(self.data.title)
	local content = require("module/message_parse").parse(self.data.content)
	local ClsMailData = getGameData():getmailData()
	self.num:setText(string.format("%d/%d", index, ClsMailData:getMailMaxCount()))
	self.mail_title:setText(title)
	self.mail_content:setText(content)

	local reward = self.data.attachment
	local time, isToDelete = self:getTime(self.data.time)
	self.time:setText(time)
	if isToDelete and #reward ~= 0 then
		self.red_dot:setVisible(true)
	end
	self:updateView()
	self:addGuildTips()
end

function ClsMailItem:addGuildTips()
	local ClsMailData = getGameData():getmailData()
	if true ~= ClsMailData:isGuildMail(self.data) then
		return
	end
	if self.guild_tips_ui then
		return
	end
	self.guild_tips_ui = GUIReader:shareReader():widgetFromJsonFile("json/mail_guild.json")
	self.guild_tips_ui:setPosition(ccp(20, 56))
	self.panel:addChild(self.guild_tips_ui)
	convertUIType(self.guild_tips_ui)

	local guild_leader_name = getConvertChildByName(self.guild_tips_ui, "guild_leader_name")
	local guild_job = getConvertChildByName(self.guild_tips_ui, "guild_job")

	guild_leader_name:setText(self.data.guildInfo.name)
	guild_job:setText(string.format(ui_word.NAME_BOX_2, returnProfessionStr(self.data.guildInfo.job)))

	adaptSpriteLeftOrRight(guild_leader_name, guild_job)
end

function ClsMailItem:updateView()
	if self.data.status == 2 then
		self.get:setVisible(true)
		self.btn_get:setVisible(false)
		for k,v in pairs(reward_widget) do -- 隐藏奖励
			self[v.bg]:setVisible(false)
		end
	else
		self.btn_get:active()
		self.get:setVisible(false)
		local reward = self.data.attachment
		if #reward == 0 then
			self.btn_get:setVisible(false)
			self.btn_read:setVisible(true)
			self.btn_read:setTouchEnabled(true)
		else
			self.btn_get:setVisible(true)
			self.btn_read:setVisible(false)
			self.btn_read:setTouchEnabled(false)
		end
		for key, value in ipairs(reward) do
			if key > 3 then break end
			value.key = value.type
			value.value = value.amount
			local icon, amount, scale, name, diTuIcon, armature_res, color, desc, pic_local = getCommonRewardIcon(value)
			if not icon then break end
			local tmp_res = convertResources(icon)
			local res = string.format("item_box_%s.png", color)

			self["item_"..key]:setVisible(true)
			self["item_"..key]:changeTexture(res, UI_TEX_TYPE_PLIST)
			local pic_path = UI_TEX_TYPE_PLIST
			if pic_local then
				pic_path = UI_TEX_TYPE_LOCAL
			end
			self["pic_"..key]:changeTexture(convertResources(icon), pic_path)

			local pic_size = 60
			if value.key == ITEM_INDEX_BOAT then
				pic_size = 80
			end

			
			local size = self["pic_"..key]:getContentSize()
			scale = pic_size/size.width

			self["pic_"..key]:setScale(scale)
			self["num_"..key]:setText(amount)
			if diTuIcon then
				local diSprite = display.newSprite(icon)
				self["pic_"..key]:changeTexture(convertResources(diTuIcon), UI_TEX_TYPE_PLIST)
				self["pic_"..key]:addCCNode(diSprite)
			end
		end
	end
end

return ClsMailItem
