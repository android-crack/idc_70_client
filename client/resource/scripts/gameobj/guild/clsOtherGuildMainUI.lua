--
-- 查看其它商会的信息
--

local ClsGuildBaseUI 		= require("gameobj/guild/clsGuildBaseUI")
local music_info 			= require("scripts/game_config/music_info")

local ClsOtherGuildMainUI 	= class("ClsOtherGuildMainUI", ClsGuildBaseUI)

local GUILD_SKILL_INFO 		= require("game_config/guild/guild_skill_info")

ClsOtherGuildMainUI.getViewConfig = function(self)
	return {
		["hide_before_view"] = true, 
		["effect"]			 = UI_EFFECT.FADE,
	}
end

ClsOtherGuildMainUI.onEnter = function(self, data)
	self["data"] 				= data
	self["btn_member_other"] 	= nil -- 查看别人的商会成员
	self["notice_content"]		= nil -- 商会公告
	self["btn_join"] 			= nil -- 申请入会
	self["skill_panel"] 		= {}  -- 商会技能{"icon","level","name"} * 6

	ClsOtherGuildMainUI.super.onEnter(self)

	self:updateGuildBaseInfo(data)
end

ClsOtherGuildMainUI.initGuildHallView = function(self)
	ClsOtherGuildMainUI.super.initGuildHallView(self)

	self.mine_panel:setVisible(false)
	self.other_panel:setVisible(true)

	self.btn_member_other = getConvertChildByName(self.other_panel, "btn_member_other")
	self.notice_content = getConvertChildByName(self.other_panel, "notice_content_2")
	self.btn_join = getConvertChildByName(self.other_panel, "btn_join")

	for index = 1, 6 do
		table.insert(self.skill_panel, {
			icon = getConvertChildByName(self.other_panel, "skill_icon_"..index),
			name = getConvertChildByName(self.other_panel, "skill_name_"..index),
			level = getConvertChildByName(self.other_panel, "skill_level_"..index)
		})
	end

	self.btn_join:setPressedActionEnabled(true)
	self.btn_join:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:joinOtherGuild()
	end, TOUCH_EVENT_ENDED)

	self.btn_member_other:setPressedActionEnabled(true)
	self.btn_member_other:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:openMemberList()
	end, TOUCH_EVENT_ENDED)
end

ClsOtherGuildMainUI.updateGuildBaseInfo = function(self, info)
	ClsOtherGuildMainUI.super.updateGuildBaseInfo(self, info)
	self.notice_content:setText(info.notice)

	local skill_level = {}
	for k, v in pairs(info.skill_list) do
		skill_level[v.key] = v.level
	end

	for index, info in pairs(GUILD_SKILL_INFO) do
		local panel = self.skill_panel[index]
		panel.icon:changeTexture( convertResources(info.guild_skill_icon), UI_TEX_TYPE_PLIST )
		panel.name:setText(info.guild_skill_name)
		panel.level:setText("Lv."..skill_level[info.name])
	end
end

ClsOtherGuildMainUI.joinOtherGuild = function(self)
	local data = {
		res = tonumber(self.data.icon),
		name = self.data.name,
		id = self.data.id,
		level = self.data.grade,
	}
	getUIManager():create("gameobj/guild/clsCreateGuildTips.lua", nil, data, nil, true)
end

ClsOtherGuildMainUI.openMemberList = function(self)
	getUIManager():create("gameobj/guild/clsOtherGuildMemberListPanel", nil, self.data.members)
end

ClsOtherGuildMainUI.getCurGuildId = function(self)
	return self.data.id
end

return ClsOtherGuildMainUI