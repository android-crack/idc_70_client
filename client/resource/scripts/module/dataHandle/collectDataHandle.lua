local sailor_info = require("game_config/sailor/sailor_info")
local boat_info = require("game_config/boat/boat_info")
local relic_info = require("game_config/collect/relic_info")
local ui_word = require("game_config/ui_word")
local tool = require("module/dataHandle/dataTools")
local NPC_TYPE = require("gameobj/explore/exploreNpc/exploreNpcType")
local baozang_info = require("game_config/collect/baozang_info")
local relic_star_info = require("game_config/collect/relic_star_info")
local Alert = require("ui/tools/alert")

local amountBase = 10
local treasureid = 1 -- [todo]:修改默认值。能打捞到的宝物id

local RELIC_STATE_OPEN = 1
local RELIC_STATE_EVENT = 2
local RELIC_STATE_REWARD = 3
local RELIC_STATE_FINISH = 4


local handler = class("CollectData")

handler.ctor = function(self)
	self.is_blackmaketman_show = false -- 是否发现了黑市商人的位置
	self.blackmarketman_port = nil -- 黑市商人所在的港口位置
	self.blackmarket_type = 0 -- 能获取的宝物类型
	self.treat_consume = 0 -- 酒馆请客消耗
	self.relic_mission_list = {}--遗迹任务列表
	self.relic_ten_explore_reward = {}--探索十次奖励
	self.treasureinfo = nil
	self.relic_share_times = 0
	self.relic_max_share_times = 0
	self.pre_ask_help_time = nil

	--玩家曾经拥有过的船id, 只要第一次制造完成拥有后（造船厂船舶制造时间结束，点击【确定】按钮，进入我的船坞列表后表示拥有）
	self.everOwnedBoats = {}

	self.area_relic_dic = {}
	for k, v in ipairs(relic_info) do
		if not self.area_relic_dic[v.areaId] then
			self.area_relic_dic[v.areaId] = {}
		end
		self.area_relic_dic[v.areaId][#self.area_relic_dic[v.areaId] + 1] = k
	end
	self.current_visit_friend_relic_info = {}
	self.current_visit_relic_info = {}
end

local time_delta = 10
handler.isCanAsk = function(self)
	if self.pre_ask_help_time == nil then
		return true
	else
		local player_data = getGameData():getPlayerData()
		local cur_time = os.time() + player_data:getTimeDelta()
		if cur_time - self.pre_ask_help_time >= time_delta then
			return true
		else
			return false
		end
	end
end

handler.getMsgSendCd = function(self)
	local player_data = getGameData():getPlayerData()
	local cur_time = os.time() + player_data:getTimeDelta()
	return time_delta - (cur_time - self.pre_ask_help_time)
end

handler.setShareTimes = function(self, cur_times, max_times)
	if cur_times and self.relic_share_times ~= cur_times then
		self.relic_share_times = cur_times
	end

	if max_times and self.relic_max_share_times ~= max_times then
		self.relic_max_share_times = max_times
	end
	EventTrigger(EVENT_PORT_SAILOR_FOOD) 
end

handler.getShareTimes = function(self)
	return self.relic_share_times
end

handler.getMaxShareTimes = function(self)
	return self.relic_max_share_times
end

local MAX_REWARD_NUM = 5
handler.insertTenExploreReward = function(self, reward)
	for k, v in ipairs(reward) do
		table.insert(self.relic_ten_explore_reward, v)
	end

	if #self.relic_ten_explore_reward == MAX_REWARD_NUM then
		local relic_ui = getUIManager():get("ClsRelicDiscoverUI")
		if not tolua.isnull(relic_ui) then
			relic_ui:showRewardUI(self.relic_ten_explore_reward)
		end
	end
end

handler.cleanTenExploreReward = function(self)
	self.relic_ten_explore_reward = {}
end

--[port_id] = relic_id
handler.setRelicMissionList = function(self, list)
	for k, v in ipairs(list) do
		self.relic_mission_list[v.port] = v.relic
	end
end

handler.getRelicIdByPortId = function(self, port_id)
	return self.relic_mission_list[port_id]
end

handler.judgeRelicMissionContainCurPort = function(self, relic_id, port_id)
	for k, v in pairs(self.relic_mission_list) do
		if relic_id == v and k == port_id then
			return true
		end
	end
end

--更新某个港口能接的遗迹ID(遗迹ID唯一对应任务ID)
handler.updateRelicMissionToList = function(self, port_id, relic_id)
	self.relic_mission_list[port_id] = relic_id
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		local port_data = getGameData():getPortData()
		local port_id = port_data:getPortId() --当前港口id
		if port_id == port_id then
			port_layer:judgeIsHaveRelicMission()
		end
	end
end

handler.delRelicMissionFromList = function(self, relic_id)
	local port_data = getGameData():getPortData()
	local port_id = port_data:getPortId() --当前港口id
	if not self:judgeRelicMissionContainCurPort(relic_id, port_id) then
		self:delRelicMissionInfo(relic_id)
		return
	end
	self:delRelicMissionInfo(relic_id)

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:delRelicMissionIcon()
	end
end

handler.delRelicMissionInfo = function(self, relic_id)
	local remain_list = {}
	for k, v in pairs(self.relic_mission_list) do
		if v ~= relic_id then
			remain_list[k] = v
		end
	end
	self.relic_mission_list = remain_list
end

handler.setCurrentVisitRelicInfo = function(self, info)
	self.current_visit_relic_info = info
end

handler.getCurrentVisitRelicsInfo = function(self)
	return self.current_visit_relic_info
end

handler.askFriendOwnSailors = function(self, uid, call_back)
	self.visit_call_back = call_back
	GameUtil.callRpc("rpc_server_friend_visit_sailor_info", {uid}, "rpc_client_friend_visit_sailor_info")
end

handler.receiveEverOwnedBoats = function(self, boats)
	self.everOwnedBoats = boats

	local ui = getUIManager():get('ClsCollectMainUI')
	if not tolua.isnull(ui) then
		ui:openBoatUi()
	end
end

handler.getEverOwnedBoats = function(self)
	return self.everOwnedBoats
end

handler.visitSailorCollect = function(self)
	local ui = getUIManager():get('ClsCollectMainUI')
	if not tolua.isnull(ui) then
		ui:receiveSailorData()
	elseif self.visit_call_back and type(self.visit_call_back) == "function" then
		self.visit_call_back()
	end
	self.visit_call_back = nil
end

handler.getCollectSailorNum = function(self)
	self:initSailorData()
	return #self.normalSailors + #self.seniorSailors + #self.legendSailors
end

handler.initSailorData = function(self)
	self.normalSailors = {}
	self.seniorSailors = {}
	self.legendSailors = {}

	for id, sailor in pairs(sailor_info) do
		if sailor.collect == 1 then
			if sailor.star <= 3 then -- 普通水手
				table.insert(self.normalSailors, id)
			elseif sailor.star == 4 or sailor.star == 5  then --高级水手
				table.insert(self.seniorSailors, id)
			elseif sailor.star == 7 or sailor.star == 6  then --传奇水手
				table.insert(self.legendSailors, id)
			end
		end
	end
end


--好友是否已经拥有此水
handler.isFriendOwnSailor = function(self, sailor_id)
	local handle = getGameData():getFriendDataHandler()
	local sailorList = handle:getTempFriendSailor()

	if not sailorList then return false end
	for k, v in pairs(sailorList) do
		if sailor_id == v.sailorId then
			return true
		end
	end
	return false
end

--获取普通水手
handler.getNormalSailors = function(self)
	table.sort(self.normalSailors, function(a, b)
		local a_info = sailor_info[a]
		local b_info = sailor_info[b]
		if a_info.star ~= b_info.star then
			return a_info.star < b_info.star
		end
		if a_info.id ~= b_info.id then
			return a_info.id < b_info.id
		end
	end)
	return self.normalSailors
end

--获取高级水手
handler.getSeniorSailors = function(self)
	table.sort(self.seniorSailors, function(a, b)
		local a_info = sailor_info[a]
		local b_info = sailor_info[b]
		if a_info.star ~= b_info.star then
			return a_info.star < b_info.star
		end
		if a_info.id ~= b_info.id then
			return a_info.id < b_info.id
		end
	end)
	return self.seniorSailors
end

--获取传奇水手
handler.getLegendSailors = function(self)
	table.sort(self.legendSailors, function(a, b)
		local a_info = sailor_info[a]
		local b_info = sailor_info[b]
		if a_info.star ~= b_info.star then
			return a_info.star < b_info.star
		end
		if a_info.id ~= b_info.id then
			return a_info.id < b_info.id
		end
	end)
	return self.legendSailors
end

--初始化船舶数据
handler.initBoatData = function(self)
	local boatData = getGameData():getBoatData()
	local ownBoats = boatData:getOwnBoats() -- 船舶
	self.collectedBoat = {}
	for id, _ in pairs(boat_info) do
		self.collectedBoat[id] = false
	end
	if ownBoats == nil then return end

	for _,boatInfo in pairs(ownBoats) do
		self.collectedBoat[boatInfo.id] = boatInfo
	end
end

--获取船舶数据
handler.getBoats = function(self)
	self:initBoatData()
	return self.collectedBoat
end

handler.setBoatName = function(self, boatId, name)
	local boatData = getGameData():getBoatData()
	boatData:setBoatName(boatId, name)
end

handler.getBoatName = function(self, boatId)
	local boatData = getGameData():getBoatData()
	return boatData:getBoatName(boatId)
end

handler.askRelicPirateFight = function(self)
	GameUtil.callRpc("rpc_server_great_pirate_fight", {})
end

handler.askGuildHelp = function(self, relic_id)
	if self:isCanAsk() then
		local player_data = getGameData():getPlayerData()
		self.pre_ask_help_time = os.time() + player_data:getTimeDelta()
		GameUtil.callRpc("rpc_server_group_ask_for_help", {2, relic_id})
	else
		local error_info=require("game_config/error_info")
		Alert:warning({msg = string.format(error_info[845].message, self:getMsgSendCd())})
	end
end

handler.askAdviseRelic = function(self)
	GameUtil.callRpc("rpc_server_relic_advice", {})
end

handler.askForRelicData = function(self, play_id)
	if play_id == nil then
	   GameUtil.callRpc("rpc_server_collect_relic_list", {}, "rpc_client_collect_relic_list")
	else
	   GameUtil.callRpc("rpc_server_friend_visit_relic_info", {play_id}, "rpc_client_friend_visit_relic_info")
	end
end

handler.reAskRelicInfo = function(self)
	if not self.relic_info then
		return
	end

	for k, v in ipairs(self.relic_info) do
		self:askRelicInfo(v.id)
	end
end

--找到目标遗迹进行导航
handler.findNavigateRelicID = function(self, at_explore)
	local start_pos = nil
	if not at_explore then
		local port_data = getGameData():getPortData()
		local port_id = port_data:getPortId() --当前港口id
		local port_info = require("game_config/port/port_info")
		start_pos = port_info[port_id].sea_pos
	else
		local player_id = getGameData():getPlayerData():getUid()
		local my_ship = getGameData():getExplorePlayerShipsData():getShipByUid(player_id)
		local posx, posy = my_ship:getPos()
		local explore_layer = getExploreLayer()
		local ships_layer = explore_layer:getShipsLayer()
		posx, posy = ships_layer:cocosToTile(posx, posy)
		start_pos = {[1] = posx, [2] = posy}
	end

	local goal_relic_id = nil
	local min_distance = nil
	if not self.relic_info then return end
	for k, v in ipairs(self.relic_info) do--遍历已经发现了的遗迹
		if self:isCanDigOrExplore(v.id) then--能发掘或者能探索的遗迹都符合
			local current_relic_pos = relic_info[v.id].world_coord
			if not goal_relic_id then
				goal_relic_id = v.id
				min_distance = self:getDistance(start_pos, current_relic_pos)
			end

			local current_distance = self:getDistance(start_pos, current_relic_pos)
			if current_distance < min_distance then
				goal_relic_id = v.id
				min_distance = current_distance
			end
		end
	end
	return goal_relic_id
end

--判断发现了的遗迹是否可以发掘或者探索
handler.isCanDigOrExplore = function(self, id)
	local item = self:getRelicInfoById(id)
	if item.dig == 0 then--表示该遗迹还没有发掘过
		local relic_data_handler = getGameData():getRelicData()
		local is_unlock_relic = relic_data_handler:isUnlockTotalOk(item.id)
		if is_unlock_relic then
			return true
		else
			return false
		end
	elseif item.dig >= 1 then--表示遗迹发掘过
		if item.star >= item.relicInfo.max_star then
			if item.canGetDailyReward and item.canGetDailyReward ~= 0 then
				return true
			else
				return false
			end
		else
			local star = (item.star or 0) + 1
			local need_lv = relic_star_info[star].grade
			local player_data = getGameData():getPlayerData()
			local cur_lv = player_data:getLevel()
			if need_lv > cur_lv then
				if item.canGetDailyReward and item.canGetDailyReward ~= 0 then
					return true
				else
					return false
				end
			else
				return true
			end
		end
	end
end

handler.getDistance = function(self, pos1, pos2)
	return Math.distance(pos1[1], pos1[2], pos2[1], pos2[2])
end

handler.setfindNewRelicID = function(self, relicId)
	self.findRelicID = relicId
end

handler.getFindNewRelicID = function(self)
	return self.findRelicID
end

handler.getRelicsInfo = function(self)
	return self.relic_info
end

handler.getCurrentVisitFriendRelicsInfo = function(self)
	return self.current_visit_friend_relic_info
end

handler.getRelicsInfosOrderById = function(self)
	if nil == self.relic_infos_by_id then
		self.relic_infos_by_id = {}
	end
	return self.relic_infos_by_id
end

handler.getRelicInfoById = function(self, id)
	if self.relic_info then
		for _, relic in ipairs(self.relic_info) do
			if relic.id == id then
				return relic
			end
		end
	end
end

handler.getConfigInfo = function(self, id)
	local item = {}
	item.id = id
	item.relicInfo = relic_info[id]
	return item
end

handler.getRelicIsFinish = function(self, id)
	local item = self:getRelicInfoById(id)
	if item and item.status then
		if item.status >= RELIC_STATE_FINISH then
			return true
		end
	end
	return false
end

--获取遗迹当前该显示奖励的星级
handler.getRelicRewardStar = function(self, id)
	local item = self:getRelicInfoById(id)
	local star_n = item.star or 1
	if item and item.status then
		if item.status < RELIC_STATE_REWARD then
			star_n = star_n + 1
		end
	end
	return star_n
end

handler.getShowText = function(self, condition)
	local text = nil
	if condition.port then
		local port_info = require("game_config/port/port_info")
		local port_name = port_info[condition.port].name
		text = string.format(ui_word.RELIC_ACTIVE_CONDITION_PORT, port_name, condition.level)
	elseif condition.relic then
		local relic_info = require("game_config/collect/relic_info")
		local relic_name = relic_info[condition.relic].name
		text = string.format(ui_word.RELIC_ACTIVE_CONDITION_RELIC, relic_name, condition.level)
	elseif condition.sailor then
		local sailor_info = require("game_config/sailor/sailor_info")
		local sailor_info = sailor_info[condition.sailor].name
		text = string.format(ui_word.RELIC_ACTIVE_CONDITION_SAILOR, sailor_info, condition.level)
	end
	return text
end


--是否发掘过遗迹
handler.isDigedRelic = function(self, relic_id)
	local item = self:getRelicInfoById(relic_id)
	if item and item.dig then
		if item.dig >= 1 then
			return true
		end
	end
	return false
end

--是否发现过遗迹
handler.isDiscoveryRelic = function(self, relic_id)
	return self:getRelicInfoById(relic_id) ~= nil
end


handler.getSuddenlyEvents = function(self)
	return self.relicSuddlyEventIds
end

handler.getRelicsBuffData = function(self)
	return self.relicBuffData
end

handler.setRelicsBuffData = function(self, data)
	self.relicBuffData = data
end

handler.setRelicEventReward = function (self, value)
	self.RelicEventReward = value
end

handler.getRelicEventReward = function (self)
	return self.RelicEventReward
end

handler.initFriendRelicData = function(self, relicList)
	self.current_visit_friend_relic_info = {}
	if relicList == nil then return end
	for _, v in ipairs(relicList) do
		local info = relic_info[v.id]
		local relic = v
		relic.relicInfo = info
		relic.active = 1  --好友互访的时候能够看到的都是解锁并且激活了的
		self.current_visit_friend_relic_info[#self.current_visit_friend_relic_info + 1] = relic
	end
end

--插入新的遗迹数据
handler.updateRelicInfo = function(self, one_relic_info)
	if nil == self.relic_info then
		self.relic_info = {}
	end
	if nil == self.relic_infos_by_id then
		self.relic_infos_by_id = {}
	end
	
	one_relic_info.relicInfo = relic_info[one_relic_info.id]
	self.relic_infos_by_id[one_relic_info.id] = one_relic_info

	local index_n = nil
	for k, v in ipairs(self.relic_info) do
		if v.id == one_relic_info.id then
			index_n = k
			break
		end
	end

	local relic_discover_ui_obj = getUIManager():get("ClsRelicDiscoverUI")
	if not index_n then
		self.relic_info[#self.relic_info + 1] = one_relic_info
	else
		local pre_info = self.relic_info[index_n]
		self.relic_info[index_n] = one_relic_info
		if not tolua.isnull(relic_discover_ui_obj) then
			if pre_info.dig >= 1 then--之前就发掘过了
				relic_discover_ui_obj:updateRelicInfoCallback(one_relic_info)
			elseif one_relic_info.dig >= 1 then--现在发掘的遗迹
				relic_discover_ui_obj:updateFirstOpenRelicCallback(one_relic_info)
			end
		end
	end
end

handler.getRelicByType = function(self, areaId)
	self.relicByKind = {}
	if self.relic_info == nil then Alert:warning({msg = T("遗迹数据为空！")}) end
	for id, info in ipairs(self.relic_info) do
		local _areaId = info.areaId
		if info.areaId == areaId then
			info.id = id
			if info.status == nil then info.status = STATUS_UNACTIVE end
			table.insert(self.relicByKind, info)
		end
	end

	return self.relicByKind
end

handler.askAcceptRelicMission = function(self, relic_id)
	GameUtil.callRpc("rpc_server_relic_tip_accept", {relic_id})
end

handler.askRelicInfo = function(self, id)
	GameUtil.callRpc("rpc_server_collect_relic_info", {id}, "rpc_client_collect_relic_info")
end

handler.getRelicReward = function(self, id)
	GameUtil.callRpc("rpc_server_collect_relic_get_reward", {id})
end

handler.relicActive = function(self, id)
	GameUtil.callRpc("rpc_server_collect_relic_active", {id}, "rpc_client_collect_relic_active")
end

handler.relicExplore = function(self, id)
	GameUtil.callRpc("rpc_server_collect_daily_reward", {id})
end

handler.relicExplore10 = function(self, id)
	GameUtil.callRpc("rpc_server_relic_explore_10", {id})
end

handler.relicEventIsSucc = function(self, id, question_id, index)
	GameUtil.callRpc("rpc_server_collect_relic_star_event", {id, question_id, index})
end

--发现遗迹上行的协议
handler.askDiscoveryRelic = function(self, relic_id)
	GameUtil.callRpc("rpc_server_collect_relic_discover", {relic_id})
end

--请求购买分享的遗迹
handler.askBuyShareRelic = function(self, relic_id, chat_id)
	GameUtil.callRpc("rpc_server_relic_buy", {relic_id, chat_id})
end

handler.askShareRelic = function(self, relic_id)
	GameUtil.callRpc("rpc_server_relic_share", {relic_id})
end

handler.askShareTimes = function(self)
	GameUtil.callRpc("rpc_server_relic_share_times", {})
end

--进入水手单挑
handler.askEnterSailorBattle = function(self, relic_id, step)
	GameUtil.callRpc("rpc_server_fight_pve", { 1400001, battle_config.fight_type_pve_relic_battle, json.encode({["relic"] = relic_id})})
end

handler.addRelicInfo =  function(self, id)
	local relic = {}
	relic.active = 0
	relic.reward = 0
	relic.id = id
	local info = relic_info[id]
	relic.relicInfo = info

	if self.relic_info == nil then
		self.relic_info = {}
	end
	self.relic_info[#self.relic_info + 1] = relic
end

handler.getRelicStatus = function(self, id)
	local _status = self.relic_info[id].status

	return _status == nil and STATUS_UNACTIVE or _status
end

handler.setRelicStatus = function(self, id, status)

	if self.relic_info[id] == nil then
		self.relic_info[id] = {}
	end
	self.relic_info[id].status = status
end

handler.askForBaozangData = function(self)
	GameUtil.callRpc("rpc_server_collect_baowu_list",{})
end

handler.updateBaowuInfoServer = function(self, id)
	GameUtil.callRpc("rpc_server_collect_baowu_info", {id}, "rpc_client_collect_baowu_info")
end

handler.initFriendBaozangData = function(self, list)
	local baowulist = table.clone(require("game_config/collect/baozang_info"))
	if list ~= nil then
		for key,value in ipairs(baowulist) do
			baowulist[key].status = STATUS_UNACTIVE
		end
		for key,value in ipairs(list) do
			if baowulist[value]~=nil then
				baowulist[value].status = STATUS_ACTIVE_REWARD
			end
		end
	end
	self.baowuInfo = baowulist
end

--初始化宝物数据，游戏启动设置，无须再调用
handler.initBaozangData = function(self, baozangList)

	self.baowuInfo = baozang_info

	if baozangList ~= nil then
		for _,baozang in ipairs(baozangList) do --不在baozangList的列表的amount字段和status字段都为nil
			local _info = self.baowuInfo[baozang.id]
			_info.id = baozang.id
			_info.amount = baozang.amount
			_info.status = baozang.status
		end
	end
end

handler.updateBaowuInfoClient = function(self, info)
	local _id = info.id
	local _baowu = self.baowuInfo[_id]
	_baowu.amount = info.amount
	_baowu.status = info.status
end

--通过类型获取宝藏
handler.getBaozangById = function(self, kindId)
	local treasureKind = {
		[1] = KIND_TRANS_BAOWU_TYPE_SAILOR_WEAPON,
		[2] = KIND_TRANS_BAOWU_TYPE_SAILOR_ARMOR,
		[3] = KIND_TRANS_BAOWU_TYPE_SAILOR_BOOK,
	}
	self.baozangByKind = {}

	for id, info in ipairs(self.baowuInfo) do

		if info.type == treasureKind[kindId] then
			info.id = id

			if info.status == nil then info.status = STATUS_UNACTIVE end
			if info.amount == nil then info.amount = 0 end
			table.insert(self.baozangByKind, info)
		end
	end

	return self.baozangByKind
end

handler.getBaowu = function(self, index)
	return self.baozangByKind[index]
end

handler.getBaowuById = function(self, id)
	return self.baowuInfo[id]
end


--判断宝藏碎片完整
handler.isBaowuAllCollect = function(self, id)
	local _baowu = self.baowuInfo[id]
	local _amount = _baowu.amount
	local _star = _baowu.star
	if _amount == _star*amountBase then
		return true
	end
	return false
end

handler.getRemainAmount = function(self, id)
	local _baowu = self.baowuInfo[id]
	if _baowu == nil then

		return
	end
	local _curAmount = self.baowuInfo[id].amount or 0
	local _star = self.baowuInfo[id].star
	return _star*amountBase - _curAmount
end

handler.getBaowuStatus = function(self, id)
	local _status = self.baowuInfo[id].status
	return _status == nil and STATUS_UNACTIVE or _status
end

handler.setbaowuStatus = function(self, id, status)
	if self.baowuInfo[id] == nil then
		self.baowuInfo[id] = {}
	end
	self.baowuInfo[id].status = status
end

handler.isBlackMarketManShowed = function(self)
	return self.is_blackmaketman_show
end

handler.setBlackMarketManShowed = function(self, show)
	self.is_blackmaketman_show = show
end

handler.setBlackMarketManPort = function(self, portid)
	self.blackmarketman_port = portid
	self:setBlackMarketManShowed(true)
end

handler.getBlackMarketManPort = function(self)
	return self.blackmarketman_port
end

handler.setBlackMarketType = function(self, kind)
	self.blackmarket_type = kind
end

handler.getBlackMarketType = function(self)
	return self.blackmarket_type
end

-- 获取请客消耗
handler.getTreatConsume = function(self)
	return self.treat_consume
end

handler.setTreatConsume = function(self, val)
	self.treat_consume = val
end

handler.setEffectParams = function(self, value)
	self.effectParams = value
end

handler.getEffectParams = function(self)
	return self.effectParams
end

--cost_type 应用于可选择性的消费使用道具，对应gamebases中的物品奖励index
handler.sendUseItemMessage = function (self, itemId, amount, arg1, cost_type)
	arg1 = arg1 or 0
	amount = amount or 1
	cost_type = cost_type or 0
	--getGameData():getPropDataHandler():useItemId(itemId)
	GameUtil.callRpc("rpc_server_sailor_use_item", {arg1, itemId, amount, cost_type}, "rpc_client_sailor_use_item")
end

handler.askSellItem = function (self, propType, item_id, amount)
	if propType == BAG_PROP_TYPE_ASSEMB then
		-- GameUtil.callRpc("rpc_server_boat_sell_material", {item_id, amount})
	elseif propType == BAG_PROP_TYPE_COMSUME then
		GameUtil.callRpc("rpc_server_item_sell", {item_id, amount})
	end
end

handler.getAreaRelicIds = function(self, area_id)
	local open_ids, all_ids = {}, {}
	if self.area_relic_dic[area_id] then
		all_ids = self.area_relic_dic[area_id]
	end
	if not self.relic_info then
		return open_ids, all_ids
	end
	for k,v in pairs(self.relic_info) do
		if v.relicInfo and v.relicInfo.areaId == area_id then
			open_ids[#open_ids + 1] = v.id
		end
	end
	return open_ids, all_ids
end

return handler
