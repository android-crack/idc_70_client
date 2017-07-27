local ui_word = require("game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsGuildRankCell = class("ClsGuildRankCell", ClsScrollViewItem)
local ClsGuildBadge = require("game_config/guild/guild_badge")

local FORE_FONT = 3
local cell_widget = {
	"rank_num",
	"guild_name",
	"guild_leader",
	"rank_bg_1",
	"guild_icon",
	"prestige_text",
	"member_num",
}

ClsGuildRankCell.updateUI = function(self, cell_data, panel)
	self.m_data = cell_data
	for i,v in ipairs(cell_widget) do
		self[v] = getConvertChildByName(panel, v)
	end
	self:mkUi()
end

ClsGuildRankCell.mkUi = function(self)
	self.rank_num:setText(self.m_data.pos)
	if self.m_data.pos <= FORE_FONT then
		self.rank_bg_1:setVisible(true)
	end
	self.guild_name:setText(self.m_data.name)
	self.guild_leader:setText(self.m_data.man_name)
	self.prestige_text:setText(self.m_data.prestige)
	self.member_num:setText(self.m_data.amount .. "/" .. self.m_data.size)

	local icon = ClsGuildBadge[tonumber(self.m_data.icon)].explore
	self.guild_icon:changeTexture(icon, UI_TEX_TYPE_PLIST)
end

ClsGuildRankCell.onTap = function(self, x,y)
	local data = self.m_data
	if getGameData():getGuildInfoData():getGuildId() ~= data.groupId then
		getGameData():getGuildInfoData():requestOtherGuildInfo(data.groupId)
	else
		getUIManager():create("ui/clsGuildMainUI")
	end
end

local ClsGuildRankUI = class("ClsGuildRankUI", function() 
	return UIWidget:create() 
end)

ClsGuildRankUI.ctor = function(self, type)
	self.m_list_width = 765
	self.m_list_height = 347
	self._type = type
	self:initUi()
end

local main_widget = {
	"my_rank_num",
}

ClsGuildRankUI.initUi = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/rank_guild.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	for _,name in ipairs(main_widget) do
		self[name] = getConvertChildByName(self.panel, name)
	end

	self:updateView()
end

ClsGuildRankUI.updateGuildText = function(self)
	local wealth_rank_info = getGameData():getRankData():getListByType(self._type)
	if not getGameData():getGuildInfoData():hasGuild() then
		self.my_rank_num:setText(ui_word.STR_GUILD_ADD_TIPS)
	elseif wealth_rank_info and wealth_rank_info.is_in_rank then
		self.my_rank_num:setText(string.format(ui_word.STR_USER_RANK_POS, wealth_rank_info.user_pos))
	else
		self.my_rank_num:setText(ui_word.STR_OUT_SIDE_RANK)
	end
end

ClsGuildRankUI.updateView = function(self)
	if self.m_list_view and not tolua.isnull(self.m_list_view) then
		self.m_list_view:removeFromParent()
		self.m_list_view = nil
	end

	local rank_data_handle = getGameData():getRankData()
	local wealth_rank_info = rank_data_handle:getListByType(self._type)
	if not wealth_rank_info then
		rank_data_handle:askRankList(self._type)
		return 
	end

	self:updateGuildText()

	self.cells = {}
	self.m_list_view = ClsScrollView.new(self.m_list_width, self.m_list_height, true, function()
		local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/rank_guild_list.json")
		return cell_ui
	end)
	for i,v in ipairs(wealth_rank_info.rank_list or {}) do
		v.pos = i
		self.cells[i] = ClsGuildRankCell.new(CCSize(770, 74), v)
	end
	self.m_list_view:addCells(self.cells)
	self.m_list_view:setPosition(ccp(155, 88))
	self:addChild(self.m_list_view)

	-- if getUIManager():isLive("ClsRankMainUI") then
	-- 	getUIManager():get("ClsRankMainUI"):setTouch(true)
	-- end
end

return ClsGuildRankUI