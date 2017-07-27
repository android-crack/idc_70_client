local alert = require("ui/tools/alert")
local sailor_info = require("game_config/sailor/sailor_info")
local friend_intimacy = require("game_config/friend/friend_intimacy")
local friend_gift = require("game_config/friend/friend_gift")
local ui_word = require("game_config/ui_word")
local tips = require("game_config/tips")
local uiTools = require("gameobj/uiTools")
local news = require("game_config/news")
local ClsDataHandler = require("gameobj/friend/clsFriendDataHandler")

local ONE_DAY = 24 * 3600

local FriendDataHandler = class("FriendDataHandler")
FriendDataHandler.ctor = function(self)
	self.send_times = nil
	self.accept_times = nil
	self.latest_recommend_num = 0 --最后一次系统推荐给我的好友数量

	self.rank_data = {}
	self.user_info = {}

	local module_game_sdk = require("module/sdk/gameSdk")
	self.platform = module_game_sdk.getPlatform()

	-- self.platform = PLATFORM_WEIXIN
	self.is_refuse_apply = false
	self:initDataHandlers()

	self.cur_friend_num = nil
	self.cur_friend_level = nil
	self.history_friend_num = nil
	self.history_friend_level = nil
	self:configFolder()
end

FriendDataHandler.configFolder = function(self)
	local loadObj = getGameData():getNetRes()

	local folder = "qq"
	if self.platform == PLATFORM_WEIXIN then
		folder = "wechat"
	end

	loadObj:configFolder(folder)
end

FriendDataHandler.isCanRecall = function(self, uid)
	local info = self:getUserInfo(uid)
	if not info then
		return false
	else
		if info.canRecall == 0 then
			return false
		else
			return true
		end
	end
end

FriendDataHandler.setCurFriendNum = function(self, num)
	self.cur_friend_num = num
	local qq_wechat_ui = self:getPanelByName("ClsFriendQQWechat")
	if tolua.isnull(qq_wechat_ui) then return end
	qq_wechat_ui:updateRewardInfo()
end

FriendDataHandler.getCurFriendNum = function(self)
	return self.cur_friend_num
end

FriendDataHandler.setCurFriendLevel = function(self, num)
	self.cur_friend_level = num
	local qq_wechat_ui = self:getPanelByName("ClsFriendQQWechat")
	if tolua.isnull(qq_wechat_ui) then return end
	qq_wechat_ui:updateRewardInfo()
end

FriendDataHandler.getCurFriendLevel = function(self)
	return self.cur_friend_level
end

FriendDataHandler.setHistoryFriendNum = function(self, num)
	self.history_friend_num = num
end

FriendDataHandler.getHistoryFriendNum = function(self)
	return self.history_friend_num
end

FriendDataHandler.setHistoryFriendLevel = function(self, num)
	self.history_friend_level = num
end

FriendDataHandler.getHistoryFriendLevel = function(self)
	return self.history_friend_level
end

FriendDataHandler.getCurRelationStage = function(self)
	local friend_relation = require("game_config/friend/friend_relation")
	local is_num = false
	for k, v in ipairs(friend_relation) do
		if v.kind == "num" and self.history_friend_num < v.goal_value then
			is_num = true
			return v
		end 
	end

	if is_num then return end
	for k, v in ipairs(friend_relation) do
		if v.kind == "level" and self.history_friend_level < v.goal_value then
			return v
		end
	end
end

FriendDataHandler.setRefuseApply = function(self, enable)
	self.is_refuse_apply = enable
	local add_ui = self:getPanelByName("ClsAddPanelUI")
	if not tolua.isnull(add_ui) then
		add_ui:updateRefuseApplyView(enable)
	end
end

FriendDataHandler.getRefuseApply = function(self)
	return self.is_refuse_apply
end

FriendDataHandler.getPlatform = function(self)
	return self.platform
end

FriendDataHandler.getPanelByName = function(self, name)
	local main_ui = getUIManager():get("ClsFriendMainUI")
	if tolua.isnull(main_ui) then return end
	local panel = main_ui:getPanelByName(name)
	return panel
end

-- local DATA_FRIEND = 1
-- local DATA_APPLY = 2
-- local DATA_SEARCH = 3
-- local DATA_RECOMMEND = 4

local data_handler_info = {
	[1] = {key = DATA_FRIEND},
	[2] = {key = DATA_APPLY},
	[3] = {key = DATA_SEARCH},
	[4] = {key = DATA_RECOMMEND},
} 

FriendDataHandler.initDataHandlers = function(self)
	self.data_handlers = {}
	for k, v in ipairs(data_handler_info) do
		local handler = ClsDataHandler.new(v.key)
		self.data_handlers[v.key] = handler
	end
end

FriendDataHandler.getIntimacyInfo = function(self, uid)
	local info = self.data_handlers[DATA_FRIEND].uid_list[uid]
	if info then
		local pos = 1
		local cur_intimacy = info.intimacy
		local is_find = false
		local temp = {}
		for k, v in ipairs(friend_intimacy) do
			local min_exp = v.exp[1]
			if min_exp >= cur_intimacy then--找到位置了
				is_find = true
				if min_exp > cur_intimacy then
					pos = k - 1
				else
					pos = k
				end
				local find_info = friend_intimacy[pos]
				temp.name = find_info.name
				temp.min_exp = find_info.exp[1]
				temp.max_exp = find_info.exp[2]
				return temp
			end
		end
		if not is_find then
			local find_info = friend_intimacy[#friend_intimacy]
			temp.name = find_info.name
			temp.min_exp = find_info.exp[1]
			temp.max_exp = find_info.exp[2]
			return temp
		end
	end
end

FriendDataHandler.getCurIntimacy = function(self, uid)
	local info = self.data_handlers[DATA_FRIEND].uid_list[uid]
	if info then
		return info.intimacy or 0
	end
end

FriendDataHandler.isMaxIntimacy = function(self, uid)
	local cur_intimacy = self:getCurIntimacy(uid)
	if cur_intimacy >= friend_intimacy[#friend_intimacy].exp[2] then
		return true
	else
		return false
	end
end

FriendDataHandler.getCurStageMaxIntimacy = function(self, intimacy)
	for k, v in ipairs(friend_intimacy) do
		if v.exp[1] <= intimacy and intimacy <= v.exp[2] then
			return v
		end
	end
end

FriendDataHandler.getGiftInfo = function(self, reward_num)
	for k, v in ipairs(friend_gift) do
		if v.num == reward_num then
			return v
		end
	end
end

-- {
-- [1] = 10066.000000,
-- [2] = 10067.000000,
-- [3] = 10071.000000,
-- }
--初始化除好友之外的uid_list
FriendDataHandler.initOtherUidListByKey = function(self, key, list)
	if not list or #list < 1 then cclog("初始化数据为空") return end
	for k, v in ipairs(list) do
		self.data_handlers[key]:initUidListByUid(v)
		self:askDetailInfo(v)
	end
end

--好友初始化用的list
-- {
-- [1] = {
--     ["intimacy"] = 1.000000,
--     ["status"] = 0.000000,
--     ["uid"] = 9999.000000,
--     },
-- [2] = {
--     ["intimacy"] = 1.000000,
--     ["status"] = 2.000000,
--     ["uid"] = 10053.000000,
--     },
-- [3] = {
--     ["intimacy"] = 1.000000,
--     ["status"] = 0.000000,
--     ["uid"] = 10052.000000,
--     },
-- }

--初始化好友uid_list
FriendDataHandler.initFriendUidListByKey = function(self, list)
	if not list or #list < 1 then cclog("好友初始化数据为空") return end
	for k, v in ipairs(list) do
		self.data_handlers[DATA_FRIEND]:initUidListByInfo(v)
		self:askDetailInfo(v.uid)
	end
end

--插入一个数据到uid_list
FriendDataHandler.insertOneToUidList = function(self, key, friend_id)
	self.data_handlers[key]:initUidListByUid(friend_id)
	self:askDetailInfo(friend_id)
end

FriendDataHandler.updateSearchView = function(self, info)
	local add_ui = self:getPanelByName("ClsAddPanelUI")
	if not tolua.isnull(add_ui) then
		add_ui:addSearchCell(info)
	end
end

FriendDataHandler.updateRankView = function(self, info)
	local friend_panel = self:getPanelByName("ClsFriendPanelUI")
	if tolua.isnull(friend_panel) then return end
	
	local rank_ui = friend_panel:getPanelByName("ClsFriendRankUI")
	if not tolua.isnull(rank_ui) then
		rank_ui:updateCell(info)
	end
end

FriendDataHandler.updateApplyView = function(self, info)
	local add_ui = self:getPanelByName("ClsAddPanelUI")
	if not tolua.isnull(add_ui) then
		add_ui:insertApplyCell(info)
	end
end

local update_view_by_pos = {
	[DATA_SEARCH] = FriendDataHandler.updateSearchView,
	[DATA_FRIEND] = FriendDataHandler.updateRankView,
	[DATA_APPLY] = FriendDataHandler.updateApplyView,
}

--通过详细信息组装信息
FriendDataHandler.assembUserInfo = function(self, info)
	local locations = self:getLocationsByUid(info.uid)

	for k, key in ipairs(locations) do
		self.data_handlers[key]:insertDataToUidList(info)
		self.data_handlers[key]:insertDataToNumList(info)
		if type(update_view_by_pos[key]) == "function" then
			update_view_by_pos[key](self, info)
		end
		if key == DATA_SEARCH then
			self:askFriendRequestStatus(info.uid)
		end

		if key == DATA_FRIEND then
			self:askFriendStatus(info.uid)
		end
	end
end

--获取数据所在的位置
FriendDataHandler.getLocationsByUid = function(self, uid)
	local locations = {}
	for k, v in ipairs(self.data_handlers) do
		for i, j in pairs(v.uid_list) do
			if i == uid then
				table.insert(locations, v.key)
			end
		end
	end
	return locations
end

FriendDataHandler.deleteObj = function(self, kind, uid)
	self.data_handlers[kind]:removeObj(uid)
end

FriendDataHandler.addFriend = function(self, uid)
	--添加到好友列表中
	self.data_handlers[DATA_FRIEND]:initUidListByInfo({['uid'] = uid, ['status'] = 0, ['intimacy'] = 0})
	self:askDetailInfo(uid)
	
	--将其从申请列表中删除
	self:deleteObj(DATA_APPLY, uid)

	--界面上删除申请列表中该对象以及改变添加好友按钮状态
	local add_ui = self:getPanelByName("ClsAddPanelUI")
	if not tolua.isnull(add_ui) then
		add_ui:removeApplyCellByUid(uid)
		add_ui:updateAddBtnStatus(uid, 1)
	end
end

FriendDataHandler.deleteFriend = function(self, uid)
	self.data_handlers[DATA_FRIEND]:removeObj(uid)

	local chat_data = getGameData():getChatData()
	chat_data:cleanPrivateMsg(uid)

	local main_ui = getUIManager():get("ClsFriendMainUI")
	if tolua.isnull(main_ui) then return end

	local friend_ui = main_ui:getPanelByName("ClsFriendPanelUI")
	if not tolua.isnull(friend_ui) then
		friend_ui:removeCellByUid(uid)
	end

	local add_ui = main_ui:getPanelByName("ClsAddPanelUI")
	if not tolua.isnull(add_ui) then
		add_ui:updateAddBtnStatus(uid, 0)
	end
end

FriendDataHandler.setInteractiveInfo = function(self, list)
	if not list or #list < 1 then
		cclog("状态列表为空")
		return
	end

	for k, v in ipairs(list) do
		local new_info_list = {
			[1] = {
				["uid"] = v.friendId,
				["key"] = "rank_status",
				["value"] = v.rank_status,
			},
			[2] = {
				["uid"] = v.friendId,
				["key"] = "gift_status",
				["value"] = v.gift_status,
			},
			[3] = {
				["uid"] = v.friendId,
				["key"] = "intimacy",
				["value"] = v.intimacy,
			}
		}
		self.data_handlers[DATA_FRIEND]:updateDataList(new_info_list)
	end

	local friend_ui = self:getPanelByName("ClsFriendPanelUI")
	if not tolua.isnull(friend_ui) then
		friend_ui:updateCellBtnStatus(list)
	end
end

FriendDataHandler.initSearchListByUidAsKeyList = function(self, list)
	local add_ui = self:getPanelByName("ClsAddPanelUI")
	if not list or #list < 1 then	
		if not tolua.isnull(add_ui) then
			add_ui:setTipVisible(true)
		end
		return
	end

	if not tolua.isnull(add_ui) then
		add_ui:setTipVisible(false)
	end

	self.data_handlers[DATA_SEARCH]:clean()
	self.data_handlers[DATA_RECOMMEND]:clean()

	self:initOtherUidListByKey(DATA_SEARCH, list)
end

FriendDataHandler.initSystemCommandList = function(self, list)
	self.data_handlers[DATA_RECOMMEND]:clean()

	if not list or #list < 1 then cclog("推荐数据为空") return end
	self.latest_recommend_num = #list

	if not list or #list < 1 then
		return 
	end

	--将机器人放在第一位
	local temp = {}
	for k, v in ipairs(list) do
		if v.uid == 9999 then
			temp[#temp + 1] = v
			break
		end
	end

	for k, v in ipairs(list) do
		if v.uid ~= 9999 then
			temp[#temp + 1] = v
		end
	end

	local add_ui = self:getPanelByName("ClsAddPanelUI")
	--放入对应的handler
	for k, v in ipairs(temp) do
		self.data_handlers[DATA_RECOMMEND]:insertDataToUidList(v)
		self.data_handlers[DATA_RECOMMEND]:insertDataToNumList(v)
		self:askFriendRequestStatus(v.uid)
		if not tolua.isnull(add_ui) then
			add_ui:addRecommendCell(v)
		end
	end
end

FriendDataHandler.insertSystemCommandList = function(self, list)
	if #list > 0 then
		self:setLatestRcommendNum(#list)
	end

	for k, v in ipairs(list) do 
		self.data_handlers[DATA_RECOMMEND]:insertDataToUidList(v)
		self.data_handlers[DATA_RECOMMEND]:insertDataToNumList(v)
		if v.uid ~= 9999 then
			self:askFriendRequestStatus(v.uid)
		end

		local add_ui = self:getPanelByName("ClsAddPanelUI")
		if not tolua.isnull(add_ui) then
			add_ui:addRecommendCell(v)
			add_ui:setAskStatus(false)
		end
	end
end

FriendDataHandler.getLatestRcommendNum = function(self)
	return self.latest_recommend_num or 0 
end

FriendDataHandler.setLatestRcommendNum = function(self, num)
	self.latest_recommend_num = num
end

FriendDataHandler.getFriendInfoByUid = function(self, uid)
	local temp = self.data_handlers[DATA_FRIEND].uid_list[uid]
	if temp then
		return temp
	end
end

FriendDataHandler.isMyFriend = function(self, uid)
	local temp = self.data_handlers[DATA_FRIEND].uid_list[uid]
	if temp then
		return true
	end
	return false
end

FriendDataHandler.isHaveFriend = function(self)
	local list = self.data_handlers[DATA_FRIEND].num_list
	if not list then
		return false
	elseif #list < 1 then
		return false
	else
		return true
	end
end

FriendDataHandler.getFriendNum = function(self)
	local num = 0
	for k, v in pairs(self.data_handlers[DATA_FRIEND].uid_list) do
		num = num + 1
	end

	return num
end

FriendDataHandler.isAtLine = function(self, uid)
	local friend_info = self:getFriendInfoByUid(uid)
	return friend_info.lastLoginTime == ONLINE
end

FriendDataHandler.getTotalOnLineFriend = function(self)
	local online_friends = {}
	for k, v in ipairs(self.data_handlers[DATA_FRIEND]["num_list"]) do
		if v.lastLoginTime == ONLINE then
			table.insert(online_friends, v)
		end
	end
	return online_friends
end

FriendDataHandler.getPlayerBaseInfo = function(self)
	local player_tab = {}
	local flagBoatId = nil
	local playerData = getGameData():getPlayerData()
	local boatData = getGameData():getBoatData()

	local partner_data = getGameData():getPartnerData()
	local boat_id = partner_data:getMainBoatId()

	player_tab.boatId = boat_id
	player_tab.name = playerData:getName()
	player_tab.icon = playerData:getIcon()
	player_tab.cash = playerData:getCash()
	player_tab.lastLoginTime = -1
	player_tab.level = playerData:getLevel()
	-- player_tab.rank_money = playerData:getBusinessMoney()
	player_tab.rank_zhandouli = playerData:getBattlePower()
	player_tab.title = nil
	player_tab.uid = playerData:getUid()
	return player_tab
end

FriendDataHandler.isLogining = function(self, info)
	if info.lastLoginTime == ONLINE then
		return true
	else
		return false
	end
end

FriendDataHandler.assembRankList = function(self)
	self.rank_data = {}
	for k, v in ipairs(self.data_handlers[DATA_FRIEND].num_list) do
		self.rank_data[k] = v
	end

	for k = 1, #self.rank_data do
		for i = k, #self.rank_data do
			if self:isLogining(self.rank_data[k]) then
				if self:isLogining(self.rank_data[i]) then
					if self.rank_data[k].intimacy < self.rank_data[i].intimacy then
						local temp = self.rank_data[i]
						self.rank_data[i] = self.rank_data[k]
						self.rank_data[k] = temp
					end
				end 
			else
				if self:isLogining(self.rank_data[i]) then
					local temp = self.rank_data[i]
					self.rank_data[i] = self.rank_data[k]
					self.rank_data[k] = temp
				else
					if self.rank_data[k].intimacy < self.rank_data[i].intimacy then
						local temp = self.rank_data[i]
						self.rank_data[i] = self.rank_data[k]
						self.rank_data[k] = temp
					end
				end
			end
		end
	end
end

FriendDataHandler.getRankList = function(self)
	self:assembRankList()
	return self.rank_data
end

FriendDataHandler.getLaunchKind = function(self, uid)
	if not self.user_info then 
		return
	end
	
	for k, v in ipairs(self.user_info) do
		if v.uid == uid then
			if v.qqStartup > 0 then
				return LAUNCH_KIND_QQ
			elseif v.wxStartup > 0 then
				return LAUNCH_KIND_WECHAT
			end
		end
	end
end

FriendDataHandler.getQQWechatList = function(self)
	if not self.user_info then return end
	for k, v in ipairs(self.user_info) do
		if k <= 3 then
			self.user_info[k].index = k
		else
			self.user_info[k].index = nil
		end
	end

	return self.user_info
end

--关系链玩家是否在线
FriendDataHandler.isOnline = function(self, uid)
	local info = self:getUserInfo(uid)
	return (info.lastLoginTime == ONLINE)
end

FriendDataHandler.getUserInfo = function(self, uid)
	for k, v in ipairs(self.user_info) do
		if v.uid == uid then
			return v
		end
	end
end

FriendDataHandler.getOpenId = function(self, uid)
	for k, v in ipairs(self.user_info) do
		if v.uid == uid then
			return v.openid
		end
	end
end

FriendDataHandler.isInUserList = function(self, uid)
	if not self.user_info then return false end

	for k, v in ipairs(self.user_info) do
		if v.uid == uid then
			return true
		end
	end
	return false
end

FriendDataHandler.getApplyList = function(self)
	return self.data_handlers[DATA_APPLY].num_list
end

FriendDataHandler.getRecommendList = function(self)
	return self.data_handlers[DATA_RECOMMEND].num_list
end

FriendDataHandler.getSearchList = function(self)
	return self.data_handlers[DATA_SEARCH].num_list
end

FriendDataHandler.setTimeToFile = function(self, uid, value)
	return self.friend_file_handler:setTimeToFile(uid, value)
end

FriendDataHandler.getTimeFromFile = function(self, uid)
	return self.friend_file_handler:getTimeFromFile(uid)
end

FriendDataHandler.loadUserInfo = function(self)
	local ClsFriendFileHandler = require("gameobj/friend/clsFriendFileHandler")
	if not self.friend_file_handler then
		self.friend_file_handler = ClsFriendFileHandler.new(self.platform)
	end

	self.friend_file_handler:loadTimeList()

	local module_game_sdk = require("module/sdk/gameSdk")
	local user_info = module_game_sdk.getUserInfo()
	self.user_info = user_info
	module_game_sdk.askFriendRelation()
end

FriendDataHandler.assembRelationInfo = function(self, list)
	if not list then cclog("服务端没有下发用户信息") return end

	self.user_info = list

	local player_data = getGameData():getPlayerData()
	local loadObj = getGameData():getNetRes()

	for k, v in ipairs(self.user_info) do
		if v.icon then
			-- 现将当前事件写入文件
			local pre_load_time = self:getTimeFromFile(v.uid)
			local is_load = true
			if pre_load_time then
				if player_data:getCurServerTime() - pre_load_time < ONE_DAY then
					cclog("缓存时间不够长不考虑下载")
					is_load = false
					v.is_loading = false
				end
			end

			if is_load then
				v.is_loading = true
				local loadEndCall
				loadEndCall = function(value)
					v.is_loading = false
					if value ~= 0 then return end
					self:setTimeToFile(v.uid, player_data:getCurServerTime())
					--一次性写入下载时间记录
					self.friend_file_handler:writeTimeToList()
					local qq_wechat_ui = self:getPanelByName("ClsFriendQQWechat")
					if tolua.isnull(qq_wechat_ui) then return end
					qq_wechat_ui:updateCell(v.uid)
				end
				loadObj:downNetRes(v.icon, tostring(v.uid), "png", loadEndCall)
			end
		end
	end

	table.sort(self.user_info, function(a, b) 
		return a.gamePrestige > b.gamePrestige
	end)
end

-------------------------------附近的人 begin---------------------------- 
--从sdk拉取的数据，这里并没有游戏数据
FriendDataHandler.setNeatFriends = function(self, info)
	self.near_friends = {}
	for i, v in pairs(info) do
		self.near_friends[v.openId] = v
	end
	--获取openidlist
	local open_id_list = {}
	for k, v in pairs(self.near_friends) do
		open_id_list[#open_id_list + 1] = k
	end
	self:askNearFriendInfo(open_id_list)
end

FriendDataHandler.updateNeatFriend = function(self, friend_list)
	self.final_near_friend = {}
	for k, v in pairs(friend_list) do
		local open_id = v.openid
		if self.near_friends[open_id] then
			local local_info = self.near_friends[open_id]
			v.local_info = table.clone(local_info)
			self.final_near_friend[#self.final_near_friend + 1] = v
		end
	end

	local near_friend_ui = self:getPanelByName("ClsFriendNear")
	if not tolua.isnull(near_friend_ui) then
		near_friend_ui:updateListView()
	end
end

FriendDataHandler.getNeatFriend = function(self)
	return self.final_near_friend
end
-------------------------------附近的人 end-------------------------------

--获取指定状态好友列表
FriendDataHandler.getFriendListByStatus = function(self, status_list)
	local goal_friends = {}
	for k, v in ipairs(self.data_handlers[DATA_FRIEND].num_list) do
		for i, j in ipairs(status_list) do
			if j == v.status then
				table.insert(goal_friends, v)
			end
		end
	end
	return goal_friends
end

local gift_s = {
	canRecvAndSend = 1,
	canRecv = 2,
	canSend = 3,
}

FriendDataHandler.getGiftList = function(self)
	local goal_friends = {}
	for k, v in ipairs(self.data_handlers[DATA_FRIEND].num_list) do
		for i, j in pairs(gift_s) do
			if j == v.gift_status then
				table.insert(goal_friends, v)
			end
		end
	end
	return goal_friends
end

FriendDataHandler.getLocalPic = function(self, uid)
	local loadObj = getGameData():getNetRes()
	local pic_info = loadObj:findindir(tostring(uid))
	if not pic_info or not pic_info[1] then return end
	if CCFileUtils:sharedFileUtils():isFileExist(pic_info[1]) then
		return pic_info[1]
	else
		cclog("本地没有图片")
		return
	end
end

-- PLAYER_NORMAL = 1--普通玩家
-- PLAYER_VIP = 2   --普通会员 
-- PLAYER_SVIP = 3  --超级会员
FriendDataHandler.loadPlayerPic = function(self, uid, url, callback)
	local loadObj = getGameData():getNetRes()
	local pic_info = loadObj:findindir(tostring(uid))
	if pic_info[1] and self:isTimeOK(uid) then
		return pic_info[1]
	else
		loadObj:downNetRes(url, tostring(uid), "png", function(error_id, file_url)
			if error_id == 0 then --下载成功	
				print("下载成功了------------------")	
				local player_data = getGameData():getPlayerData()		
				self:setTimeToFile(uid, player_data:getCurServerTime())
				--一次性写入下载时间记录
				self.friend_file_handler:writeTimeToList()
				callback(error_id, file_url)
			end
		end)
	end
end


FriendDataHandler.isTimeOK = function(self, uid)
	-- 现将当前事件写入文件
	local pre_load_time = self:getTimeFromFile(uid)
	if pre_load_time then
		local player_data = getGameData():getPlayerData()	
		if player_data:getCurServerTime() - pre_load_time < ONE_DAY then
			cclog("缓存时间不够长不考虑下载")
			return true
		end
	end
end

FriendDataHandler.getVipStatus = function(self, uid)
	local goal_player = nil
	for k, v in ipairs(self.user_info) do
		if v.uid == uid then
			goal_player = v
		end
	end
	if not goal_player then cclog("没有找到") return end
	if goal_player.is_svip == 1 then
		return PLAYER_SVIP
	else
		if goal_player.is_vip == 1 then
			return PLAYER_VIP
		else
			return PLAYER_NORMAL
		end
	end
end

-- local lfs = require"lfs"
-- FriendDataHandler.getFileName = function(self, dir, file_pre)
--     for file in lfs.dir(dir) do
--         if file ~= "." and file ~= ".." then
--         	if self:getFilePre(file) == file_pre then
--         		return dir..'/'..file
--         	end
--         end
--     end
-- end

-- FriendDataHandler.getFilePre = function(self, file_name)
-- 	local _, _, file_pre = string.find(file_name, "((.+))%.(.+)")
-- 	return file_pre
-- end

FriendDataHandler.setSendAcceptTimes = function(self, send_time, accept_time)
	if send_time then
		self.send_times = send_time
	end

	if accept_time then
		self.accept_times = accept_time
	end

	local main_ui = getUIManager():get("ClsFriendMainUI")
	if tolua.isnull(main_ui) then return end

	local friend_panel = main_ui:getPanelByName("ClsFriendPanelUI")
	local add_ui = main_ui:getPanelByName("ClsAddPanelUI")
	if not tolua.isnull(friend_panel) then
		friend_panel:updateAllTimes()
	end
end

FriendDataHandler.getSendTimes = function(self)
	return self.send_times or 0
end

FriendDataHandler.getAccpetTimes = function(self)
	return self.accept_times or 0
end

FriendDataHandler.getSailorList = function(self)
	local dataSailor = getGameData():getSailorData()
	local ownSailor = dataSailor:getOwnSailors()
	self.sailor_info = sailor_info
	if ownSailor == nil then 
		return self.sailor_info
	end
	for key, _ in pairs(ownSailor) do
		self.sailor_info[key].isShow = true
	end
	
	return self.sailor_info 
end

FriendDataHandler.getSailorInfo = function(self, index)
	return self.sailor_info[index]
end

FriendDataHandler.setTempFriendBaowu = function(self, list)
	self.tempFriendBaowu = list
end

FriendDataHandler.getTempFriendBaowu = function(self)
	return self.tempFriendBaowu
end

FriendDataHandler.setTempFriendShip = function(self, list)
	self.tempFriendShip = list
	local ui = getUIManager():get("ClsCollectMainUI")
	if not tolua.isnull(ui) then
		ui:receiveBoatData()
	end
end

FriendDataHandler.getTempFriendShip = function(self)
	local boat_config = require("game_config/boat/boat_info")
	local collect_ships = {}
	for k, v in pairs(self.tempFriendShip) do
		if boat_config[v] and boat_config[v].collect == 1 then
			table.insert(collect_ships, v)
		end
	end
	return collect_ships
end

FriendDataHandler.setTempFriendEquip = function(self, list)
	self.tempFriendEquip = list
end

FriendDataHandler.getTempFriendEquip = function(self)
	return self.tempFriendEquip
end

FriendDataHandler.setTempFriendSailor = function(self, list)
	self.tempFriendSailor = list
end

FriendDataHandler.getTempFriendSailor = function(self)
	local sailor_config = require("game_config/sailor/sailor_info")
	local collect_sailors = {}
	for k, v in pairs(self.tempFriendSailor) do
		if sailor_config[v.sailorId] and sailor_config[v.sailorId].collect == 1 then
			table.insert(collect_sailors, v)
		end
	end
	return collect_sailors
end

--请求某个人的详细信息
FriendDataHandler.askDetailInfo = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_info",{uid})
end

--请求关系链信息
FriendDataHandler.askUserInfo = function(self, token)
	-- rpc_client_friend_relation()
	GameUtil.callRpc("rpc_server_friend_relation", {token})
end

--通过或者拒绝加好友的请求
FriendDataHandler.askAllowOrRefuseFriend = function(self, uid,result)
	GameUtil.callRpc("rpc_server_friend_add_reply", { uid, result })
end

FriendDataHandler.askDeleteMyFriendList = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_del", {uid})
end

FriendDataHandler.askRecommedFriendList = function(self)
	GameUtil.callRpc("rpc_server_friend_recommend_user", {})
end

FriendDataHandler.askNextRecommend = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_recommend_user_next", {})
end


--请求加别人为好友
FriendDataHandler.askRequestAddFriend = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_add_request",{uid})
end

--请求单个好友信息
FriendDataHandler.askFriendInfo = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_info",{uid})
end

--请求好友状态
FriendDataHandler.askFriendRequestStatus = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_request_status",{uid})
end

local MAX_INT = 4294967295

--搜索玩家
FriendDataHandler.askSearchFriend = function(self, name, uid)
	local uid = uid or 0
	if (uid > MAX_INT) then
		uid = 0
	end
	GameUtil.callRpc("rpc_server_friend_search",{name, uid})
end

--赠送
FriendDataHandler.askSendPowerToFriend = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_praise_send",{uid})
end

--接收
FriendDataHandler.askAcceptPowerByFriend = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_praise_recv",{uid})
end

--回赠
FriendDataHandler.askReturnPowerToFriend = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_praise_return",{uid})
end

--接收并赠送
FriendDataHandler.askAcceptWithSendPower = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_praise_recv_and_send",{uid})
end

--请求好友的交互状态
--warning:最初获得的好友列表是有好友状态的,但是如果你删除了好友,重新加回来的话,就需要去主动请求与他的交互状态
FriendDataHandler.askFriendStatus = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_praise_status",{uid})
end

--请求好友拥有的船舶列表
FriendDataHandler.askFriendOwnedBoats = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_visit_boat_info", {uid},"rpc_client_friend_visit_boat_info")
end

--请求好友切磋
FriendDataHandler.askFriendPk = function(self, friend_uid)
	GameUtil.callRpc("rpc_server_fight_qiecuo", {friend_uid})
end

FriendDataHandler.askAgreePk = function(self, is_agree, attacker)
	GameUtil.callRpc("rpc_server_qiecuo_return", {is_agree, attacker})
end

FriendDataHandler.askRefuseApply = function(self, status)
	GameUtil.callRpc("rpc_server_friend_ban_request_status", {status})
end

--请求附近好友信息
FriendDataHandler.askNearFriendInfo = function(self, friend_list)
	GameUtil.callRpc("rpc_server_friend_relation_user_info", {friend_list})
end

FriendDataHandler.getNearbyPersonInfo = function(self)
	if not self.get_near_friend_lock then
		local game_sdk = require("module/sdk/gameSdk")
		game_sdk.getNearbyPersonInfo()
		self.get_near_friend_lock = true
		require("framework.scheduler").performWithDelayGlobal(function()
			self.get_near_friend_lock = false
		end , 30)
	end
end

FriendDataHandler.askFriendCallBack = function(self, uid)
	GameUtil.callRpc("rpc_server_friend_relation_recall", {uid})
end

return FriendDataHandler