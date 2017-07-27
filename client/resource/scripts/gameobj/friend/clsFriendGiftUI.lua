local sailor_info = require("game_config/sailor/sailor_info")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local uiTools = require("gameobj/uiTools")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsFriendScrollView = require("gameobj/friend/clsFriendScrollView")

local canRecvAndSend = 1
local canRecv = 2
local canSend = 3

local cell_info = {
	[1] = {name = "head_icon"},
	[2] = {name = "player_name"},
	[3] = {name = "player_level"},
	[4] = {name = "select_pic"},
	[5] = {name = "btn_accept"},
	[6] = {name = "btn_send_back"},
	[7] = {name = "tips_support"},
	[8] = {name = "btn_return_give"},
}

local ClsGiftCell = class("ClsGiftCell", ClsScrollViewItem)

ClsGiftCell.updateUI = function(self, cell_date, panel)
	local data = cell_date
	if not data then return end 
	self.btn_tab = {}
	self.condition_widget_tab = {}
	for k, v in ipairs(cell_info) do
		local item = getConvertChildByName(panel, v.name)
		item.name = v.name

		if item:getDescription() == "Button" then
			item:setPressedActionEnabled(true)
			local btn_visible_func = item.setVisible
			item.setVisible = function(self, enable)
				btn_visible_func(self, enable)
				self:setTouchEnabled(enable)
			end
			table.insert(self.btn_tab, item)
		end
		self[v.name] = item
	end

	local player_photo_id = nil
	if not data.icon or data.icon == "" or tonumber(data.icon) == 0 then
		player_photo_id = 101
	else
		player_photo_id = tonumber(data.icon)
	end

	local boat_id = data.boatId
	if not boat_id or boat_id == 0 then
		boat_id = 1
	end

	self.head_icon:changeTexture(sailor_info[player_photo_id].res, UI_TEX_TYPE_LOCAL)
	local head_size = self.head_icon:getContentSize()
	self.head_icon:setScale(90 / head_size.height)

	self.btn_accept.status = canRecv
	self.btn_send_back.status = canRecvAndSend
	self.btn_return_give.status = canSend

	local intimacy_num = data.intimacy or 0

	for k, v in ipairs(self.btn_tab) do
		v:setVisible(v.status == data.gift_status)
	end

	self.player_name:setText(data.name)
	self.player_level:setText(string.format("Lv.%s", data.level))

	self:configCellBtnEvent()
end

ClsGiftCell.configCellBtnEvent = function(self)
	local friend_data_handler = getGameData():getFriendDataHandler()
	--接收
	self.btn_accept:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		friend_data_handler:askAcceptPowerByFriend(self.m_cell_date.uid)
	end, TOUCH_EVENT_ENDED)

	--接收并回赠
	self.btn_send_back:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local cur_platform = friend_data_handler:getPlatform()
		local btnCall
		btnCall = function()
			friend_data_handler:askAcceptWithSendPower(self.m_cell_date.uid) 
		end
		local is_in = nil
		local uid = self.m_cell_date.uid
		if GTab.IS_VERIFY then
			btnCall()
			return
		end
		if cur_platform == PLATFORM_QQ then
			is_in = friend_data_handler:isInUserList(uid)
			if is_in then
				local show_txt = string.format(ui_word.FRIEND_NOTICE_SURE, ui_word.FRIEND_TAB_QQ)
				ClsAlert:showAttention(show_txt, function()
					btnCall()
					local open_id = friend_data_handler:getOpenId(uid)
					local share_data =  getGameData():getShareData()
					share_data:shareToFriend(open_id, "friend_heart")
				end, nil, btnCall)
			else
				btnCall()
			end
		elseif cur_platform == PLATFORM_WEIXIN then
			is_in = friend_data_handler:isInUserList(uid)
			if is_in then
				getUIManager():create("gameobj/friend/clsFriendTipUI", nil, {uid = uid, kind = NOITCE_SEND_GIFT_TIP, btnCall = btnCall})
			else
				btnCall()
			end
		else
			btnCall()
		end
	end, TOUCH_EVENT_ENDED)

	--回赠
	self.btn_return_give:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		friend_data_handler:askReturnPowerToFriend(self.m_cell_date.uid)
	end, TOUCH_EVENT_ENDED)
end

ClsGiftCell.onTap = function(self, x, y)
	local select_cell = self.m_scroll_view.select_cell
	if not tolua.isnull(select_cell) then
		select_cell.select_pic:setVisible(false)
	end
	
	self.select_pic:setVisible(true)
	self.m_scroll_view.select_cell = self
	local main_ui = getUIManager():get("ClsFriendMainUI")
	main_ui:openExpandPanel(self)
end

local ClsFriendGiftUI = class("ClsFriendGiftUI", function() return UIWidget:create() end)
ClsFriendGiftUI.ctor = function(self)
	self:configUI()
	self:updateListView()
end

ClsFriendGiftUI.configUI = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_gift.json")
	self:addChild(self.panel)

	self.accep_tili_num = getConvertChildByName(self.panel, "accep_tili_num")
	self:updateTimes()
end

ClsFriendGiftUI.updateListView = function(self, content)
	if not content then
		local friend_data = getGameData():getFriendDataHandler()
		content = friend_data:getGiftList()
	end

	--不论有无数据都先清空列表
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end

	if not content then cclog("没有赠送礼物列表数据") return end

	self.list_view = ClsFriendScrollView.new(785, 420, true, function()
		local cell = GUIReader:shareReader():widgetFromJsonFile("json/friend_my_friend_thanks.json")
		return cell
	end)

	self.list_view:setMoveCall(function() 
		local main_ui = getUIManager():get("ClsFriendMainUI")
		main_ui:closeExpandPanel()
	end)

	self.cells = {}
	for k, v in ipairs(content) do
		local cell = ClsGiftCell.new(CCSize(768, 104), v)
		self.cells[#self.cells + 1] = cell
	end

	self.list_view:addCells(self.cells)
	self.list_view:setPosition(ccp(185, 13))
	self:addChild(self.list_view)

	self.getReturnGuideObj = function()
		if not self.cells then return end
		local guide_layer = self.list_view:getInnerLayer()
		for k, cell in ipairs(self.cells) do
			if cell.m_cell_date.uid == ROBOT_FRIEND_ID and cell.m_cell_date.gift_status == 2 then
				local world_pos = cell:convertToWorldSpace(ccp(651, 47))
				local parent_pos = guide_layer:convertToWorldSpace(ccp(0,0))
				local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
				return guide_layer, guide_node_pos, {['w'] = 133, ['h'] = 40}
			end
		end
	end
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.5))
	arr:addObject(CCCallFunc:create(function() 
		local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
		ClsGuideMgr:tryGuide("ClsFriendMainUI")
	end))
	self:runAction(CCSequence:create(arr))
end

ClsFriendGiftUI.updateCell = function(self, info)
	if tolua.isnull(self.list_view) then return end
	for k, v in ipairs(self.list_view.m_cells) do
		if v.m_cell_date.uid == info.uid then
			info.index = v.m_cell_date.index
			v.m_cell_date = info
			if v:getIsCreate() then
				v:callUpdateUI()
			end
		end
	end
end

ClsFriendGiftUI.updateCellBtnStatus = function(self, list)
	if tolua.isnull(self.list_view) then
		self:updateListView()
	else
		--感谢页签只会有这两种状态
		local conditions = {
			[1] = true,
			[2] = true,
			[3] = true
		}

		for k, v in ipairs(list) do
			local is_exist = false
			for i, j in ipairs(self.list_view.m_cells) do
				if v.friendId == j.m_cell_date.uid then
					is_exist = true
					if not conditions[v.gift_status] then
						self.list_view:removeCell(j)
					else
						j.m_cell_date.rank_status = v.rank_status
						j.m_cell_date.gift_status = v.gift_status
						j.m_cell_date.intimacy = v.intimacy
						if j:getIsCreate() then
							j:callUpdateUI()
						end
					end
				end
			end 

			if not is_exist and conditions[v.gift_status] then
				local friend_data_handler = getGameData():getFriendDataHandler()
				local friend_info = friend_data_handler:getFriendInfoByUid(v.friendId)
				local cell = ClsGiftCell.new(CCSize(768, 104), friend_info)
				self.list_view:addCell(cell)
			end
		end
	end
end

ClsFriendGiftUI.removeCellByUid = function(self, uid)
	if tolua.isnull(self.list_view) then return end
	
	for k, v in ipairs(self.list_view.m_cells) do
		if v.m_cell_date.uid == uid then
			self.list_view:removeCell(v)
		end
	end
end

ClsFriendGiftUI.updateTimes = function(self)
	local friend_data_handler = getGameData():getFriendDataHandler()
	local accept_times = friend_data_handler:getAccpetTimes()
	self.accep_tili_num:setText(string.format("%s/%s", accept_times, MAX_ACCEPT_POWER))
end

return ClsFriendGiftUI

