--
-- 商会成员列表的格子
--

local ClsScrollViewItem 		= require("ui/view/clsScrollViewItem")
local nobility_data 			= require("game_config/nobility_data")
local ui_word 					= require("game_config/ui_word")

local ClsGuildMemberListCell 	= class("ClsGuildMemberListCell", ClsScrollViewItem)

ClsGuildMemberListCell.initUI = function(self, data)
	self["data"]		= data
	self["panel"] 		= GUIReader:shareReader():widgetFromJsonFile( "json/guild_hall_member_list.json" )

	self["title"] 		= getConvertChildByName(self.panel, "title") 			-- 称号
	self["name"] 		= getConvertChildByName(self.panel, "member_name") 		-- 名字
	self["job"] 		= getConvertChildByName(self.panel, "member_job") 		-- 职位
	self["level"] 		= getConvertChildByName(self.panel, "member_level") 	-- 等级
	self["honor"] 		= getConvertChildByName(self.panel, "member_power") 	-- 声望
	self["devote"] 		= getConvertChildByName(self.panel, "member_devote") 	-- 贡献
	self["login_time"] 	= getConvertChildByName(self.panel, "member_login") 	-- 登陆时间
	self["member_me"] 	= getConvertChildByName(self.panel, "member_me_icon") 	-- 自己的标示
	self["selected_bg"] = getConvertChildByName(self.panel, "image_vew") 		-- 选中高亮背景

	self:addChild(self.panel)
end

ClsGuildMemberListCell.updateUI = function(self, data)
	self.data = data
	if not tolua.isnull(self.title) then
		self.title:changeTexture(convertResources(self:getNobilityIcon(data.nobility)), UI_TEX_TYPE_PLIST)
	end
	self.name:setText(data.name)
	self.job:setText(returnProfessionStr(data.authority))
	self.level:setText("Lv."..data.level)
	self.honor:setText(data.zhandouli)
	self.devote:setText(data.maxContribute)
	self.login_time:setText(self:getLoginStr(data.login, data.lastLoginTime))
	if getGameData():getPlayerData():getUid() == data.uid then
		self.member_me:setVisible(true)
	else
		self.member_me:setVisible(false)
	end
end

ClsGuildMemberListCell.getNobilityIcon = function(self, nobility)
	local config = nobility_data[nobility]
	return config and config.peerage_before or "title_name_knight.png"
end

ClsGuildMemberListCell.getLoginStr = function(self, login, seconds)
	if login == 1 then return ui_word.FRIEND_ONLINE end

	local days = math.floor(seconds / ( 3600 * 24 ))
	local hours = math.floor(seconds % ( 3600 * 24 ) / 3600)
	local str = (days == 0) and (string.format(ui_word.FRIEND_H, hours)) or (string.format(ui_word.FRIEND_D, days))
	return str
end

ClsGuildMemberListCell.getData = function(self)
	return self.data
end

ClsGuildMemberListCell.setFocuesd = function(self, value)
	value = value == nil and true or value
	self.selected_bg:setVisible(value)
end

return ClsGuildMemberListCell