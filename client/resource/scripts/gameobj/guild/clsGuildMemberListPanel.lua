-- 
-- 成员列表
--
local ClsGuildExitViewPanel 		= require("gameobj/guild/guildExitViewPanel")
local ClsGuildEachMemberInfoPanel 	= require("gameobj/guild/guildEachMemberInfoPanel")
local ClsOtherGuildMemberListPanel 	= require("gameobj/guild/clsOtherGuildMemberListPanel")
local music_info 					= require("game_config/music_info")
local ui_word 						= require("game_config/ui_word")
local ClsAlert 						= require("ui/tools/alert")

local ClsGuildMemberListPanel 		= class("ClsGuildMemberListPanel", ClsOtherGuildMemberListPanel)

local MAIL_MAX_TIMES 				= 5

-- 重写父类，增加获取本人商会列表传给父类onEnter的操作
ClsGuildMemberListPanel.onEnter = function(self)
	self["open_panel"] 		= nil 

	local member_list = getGameData():getGuildInfoData():getGuildInfoMembersNumAsKey()
	ClsGuildMemberListPanel.super.onEnter(self, member_list)
end

-- 重写父类，增加对按钮的初始化
ClsGuildMemberListPanel.initBtns = function(self)
	self.btn_mail:setPressedActionEnabled(true)
	self.btn_call:setPressedActionEnabled(true)
	self.btn_leave:setPressedActionEnabled(true)

	self.btn_mail:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.open_panel = getUIManager():create("gameobj/guild/clsGuildNoTicePanel", nil, "mail")
	end, TOUCH_EVENT_ENDED)

	self.btn_call:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.open_panel = getUIManager():create("gameobj/guild/clsGuildNoTicePanel", nil, nil, true)
	end, TOUCH_EVENT_ENDED)

	self.btn_leave:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		ClsAlert:showAttention(ui_word.STR_GUILD_EXIT_OK_OR_CANCEL, function()
			getGameData():getGuildInfoData():askExitGuildTimesTips()
		end)
	end, TOUCH_EVENT_ENDED)
end

-- 重写父类，增加对按钮状态的更新
ClsGuildMemberListPanel.updateMemberData = function(self)
	local member_list = getGameData():getGuildInfoData():getGuildInfoMembersNumAsKey()
	ClsGuildMemberListPanel.super.updateMemberData(self, member_list)

	self:updateBtnMail()
	self:updateBtnCall()
end

ClsGuildMemberListPanel.updateBtnMail = function(self)
	local can_edit = getGameData():getGuildInfoData():isEidtNotice()
	self.btn_mail:setTouchEnabled( can_edit )
	if can_edit then 
		local mail_times = getGameData():getGuildInfoData():getMailTimes()
		if mail_times >= MAIL_MAX_TIMES then 
			self.btn_mail:disable()
		else
			self.btn_mail:active()
		end
	else
		self.btn_mail:disable()
	end
end

ClsGuildMemberListPanel.updateBtnCall = function(self)
	local is_normal = getGameData():getGuildInfoData():isNormalMember()
	self.btn_call:setTouchEnabled(not is_normal)
	if is_normal then 
		self.btn_call:disable()
	else
		self.btn_call:active()
	end
end

-- 重写父类，增加弹出框
ClsGuildMemberListPanel.selectCell = function(self, cell)
	local my_uid = getGameData():getPlayerData():getUid()
	local cell_data = cell:getData()
	if my_uid ~= cell_data.uid then
		self.exit_view = ClsGuildExitViewPanel.new()
		local curCellW, curCellH = cell:getWidth(), cell:getHeight()
		local worldPos = cell:convertToWorldSpace(ccp(curCellW / 2, curCellH / 2))
		local tmpView = ClsGuildEachMemberInfoPanel.new(cell_data, worldPos, self, false, self)
		self.exit_view:addChild(tmpView)
		self.exit_view:setTouchEnabled(true)
		self:addWidget(self.exit_view)
	end
	ClsGuildMemberListPanel.super.selectCell(self, cell)
end

ClsGuildMemberListPanel.preClose = function(self)
	if not tolua.isnull(self.open_panel) then self.open_panel:close() end
	if not tolua.isnull(self.exit_view) then self.removeWidget(self.exit_view) end
end

return ClsGuildMemberListPanel