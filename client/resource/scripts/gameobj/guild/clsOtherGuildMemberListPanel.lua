--
-- 基本商会成员列表（其它商会成员列表）
--
local music_info 					= require("scripts/game_config/music_info")
local ClsBaseView 					= require("ui/view/clsBaseView")
local ClsScrollView 				= require("ui/view/clsScrollView")
local ClsGuildMemberListCell 		= require("gameobj/guild/clsGuildMemberListCell")

local ClsOtherGuildMemberListPanel 	= class("ClsOtherGuildMemberListPanel", ClsBaseView)

local SORT_TYPE_JOB 	= 1
local SORT_TYPE_LEVEL 	= 2
local SORT_TYPE_POWER 	= 3
local SORT_TYPE_DEVOTE	= 4
local SORT_TYPE_LOGIN 	= 5

ClsOtherGuildMemberListPanel.getViewConfig = function(self)
	return {
		["is_back_bg"] 	= true,
		["effect"] 		= UI_EFFECT.DOWN,
	}
end

ClsOtherGuildMemberListPanel.onEnter = function(self, member_data)
	self["btn_close"] 		= nil 	--关闭按钮
	self["btn_mail"] 		= nil 	--全体邮件
	self["btn_call"] 		= nil 	--召集
	self["btn_leave"] 		= nil 	--离开公会

	self["member_list"] 	= nil 	--成员列表
	self["online_num"] 		= nil 	--在线人数
	self["sort_btns"] 		= {} 	--排序的按钮 { "panel" = ?, "arrow" = ? }

	self["member_data"] 	= member_data 
	self["selected_cell"] 	= nil 	--选中的cell
	self["sort_type"]		= SORT_TYPE_LOGIN
	self["sort_ward"] 		= -1 -- or 1

	self["sort_config"] 	= {
		[1] = {
			["name"] = "job",
			["sort_key"] = "authority"
		},
		[2] = {
			["name"] = "level",
			["sort_key"] = "level"
		},
		[3] = {
			["name"] = "power",
			["sort_key"] = "zhandouli"
		},
		[4] = {
			["name"] = "devote",
			["sort_key"] = "maxContribute"
		},
		[5] = {
			["name"] = "login",
			["sort_key"] = "lastLoginTime"
		},
	}

	self:initUI()
	self:updateMemberData(member_data)
end

ClsOtherGuildMemberListPanel.initUI = function(self)
	local widget = GUIReader:shareReader():widgetFromJsonFile( "json/guild_hall_member.json" )
	self:addWidget(widget)

	self.btn_close = getConvertChildByName(widget, "btn_close")
	self.btn_mail = getConvertChildByName(widget, "btn_mail")
	self.btn_call = getConvertChildByName(widget, "btn_call")
	self.btn_leave = getConvertChildByName(widget, "btn__leave")
	self.online_num = getConvertChildByName(widget, "member_num")

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	for index, info in pairs(self.sort_config) do
		local panel = getConvertChildByName(widget, info.name.."_panel")
		local arrow = getConvertChildByName(widget, "btn_arrow_"..info.name)
		self.sort_btns[index] = { panel = panel,arrow = arrow }
		panel:setTouchEnabled(true)
		panel:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:sortDataByType(index)
			self:updateMemberList()
		end, TOUCH_EVENT_ENDED)
	end


	self:initBtns()
	self:initMemberList()
end

ClsOtherGuildMemberListPanel.initBtns = function(self)
	self.btn_mail:setVisible(false)
	self.btn_call:setVisible(false)
	self.btn_leave:setVisible(false)
end

ClsOtherGuildMemberListPanel.initMemberList = function(self)
	self.member_list = ClsScrollView.new(770, 320, true, function () end, {is_widget = true, is_fit_bottom = true })
	self.member_list:setPosition(ccp(100, 110))
	self:addWidget(self.member_list)
end

-- 更新成员信息，也用于onEnter中初始化UI之后第一次对列表设置的操作
ClsOtherGuildMemberListPanel.updateMemberData = function(self, data)
	if not data then return end

	self.member_data = data
	self.member_list:removeAllCells()
	self.sort_ward = -1

	self:sortDataByType(SORT_TYPE_LOGIN)

	local cells = {}
	local onListCellTap = function(cell, x, y)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:selectCell(cell)
	end
	for k, data in pairs(self.member_data) do
		local cell = ClsGuildMemberListCell.new(CCSize(770, 40), data)
		table.insert(cells, cell)
		cell.onTap = onListCellTap
	end
	self.member_list:addCells(cells)
	self.member_list:scrollToCellIndex(1)
	self:selectCell(cells[1])

	self:updateOnlineNumber()
end

ClsOtherGuildMemberListPanel.updateOnlineNumber = function(self)
	local online_num, all_num = 0, 0
	for k, member in pairs(self.member_data) do
		all_num = all_num + 1
		if member.login == 1 then 
			online_num = online_num + 1
		end
	end
	self.online_num:setText(online_num.."/"..all_num)
end

-- 选中cell的操作
ClsOtherGuildMemberListPanel.selectCell = function(self, cell)
	if not tolua.isnull(self.selected_cell) then 
		self.selected_cell:setFocuesd(false) 
	end
	if not tolua.isnull(cell) then
		cell:setFocuesd(true)
		self.selected_cell = cell
	end
end

-- 用于排序之后的更新，数量不变，只更新每个cell里的数据
ClsOtherGuildMemberListPanel.updateMemberList = function(self)
	local cells = self.member_list:getCells()
	for k, cell in pairs(cells) do
		cell:updateUI(self.member_data[k])
	end
	self.member_list:scrollToCellIndex(1)
	self:selectCell(cells[1])
end

ClsOtherGuildMemberListPanel.sortDataByType = function(self, type)
	if type == self.sort_type then 
		self.sort_ward = self.sort_ward * -1 
	else
		self.sort_ward = 1
	end
	self.sort_type = type

	for index, widgets in pairs(self.sort_btns) do
		if index == self.sort_type then
			widgets.arrow:setVisible(true)
			widgets.arrow:setScaleX(self.sort_ward)
		else
			widgets.arrow:setVisible(false)
		end
	end

	local my_uid = getGameData():getPlayerData():getUid()
	-- 保证真正排序相等的时候是按UID排序的
	table.sort(self.member_data, function(infoA, infoB)
		-- 保证按时间排序的时候自己在第一位
		if infoA.uid == my_uid then infoA.lastLoginTime = -1 end
		if infoB.uid == my_uid then infoB.lastLoginTime = -1 end
		if self.sort_type == 1 then return infoA.uid < infoB.uid
		else return infoA.uid > infoB.uid end
	end)

	table.sort(self.member_data, function(infoA, infoB)
		local key = self.sort_config[self.sort_type].sort_key
		-- 在线时间排序
		if self.sort_type == SORT_TYPE_LOGIN then
			if self.sort_ward == 1 then
				if infoA.login > infoB.login then return true 
				elseif infoA.login < infoB.login then return false
				else return infoA.lastLoginTime < infoB.lastLoginTime end
			else
				if infoA.login < infoB.login then return true 
				elseif infoA.login > infoB.login then return false
				else return infoA.lastLoginTime > infoB.lastLoginTime end
			end
		end
		-- 其它排序
		local config = self.sort_config[self.sort_type]
		if self.sort_ward == 1 then
			return infoA[config.sort_key] > infoB[config.sort_key] 
		else
			return infoA[config.sort_key] < infoB[config.sort_key] 
		end
	end)
end

return ClsOtherGuildMemberListPanel