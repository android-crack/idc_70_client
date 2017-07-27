local area_info = require("game_config/port/area_info")
local port_info = require("game_config/port/port_info")
local explore_whirlpool = require("game_config/explore/explore_whirlpool")
local relic_info = require("game_config/collect/relic_info")
local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
local area_mission_info = require("game_config/explore/area_mission_info")
local port2port_distance_info = require("game_config/port/port2port_distance_info")
local exploreFormula = require("module/explore/exploreFormula")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local randomLootInfo = require("game_config/random/random_loot_info")
local on_off_info = require("game_config/on_off_info")
local exploreMapUtil = require("module/explore/exploreMapUtil")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
local ExploreMapData = class("ExploreMapData")

ExploreMapData.ONE_AREA_MISSION_STATUS_COMPETE = 2
ExploreMapData.ALL_AREA_MISSION_STATUS_COMPETE = 3

ExploreMapData.ctor = function(self)
	self.taskPort = {}
	self.taskPortList = {}
	self.taskSh = {}
	self.taskShList = {}
	self.taskMapSelectPortId = nil
	self.areaMissionInfo = nil
	self.hasInitData = nil
	self.exploreExpectDis = 0
	self.exploreExpectFood = 0
	self.cur_select_point_info = nil
end

ExploreMapData.init = function(self)
	local portData = getGameData():getPortData()
	self.curAraeId = port_info[portData:getPortId()].areaId -- 当前海域id
	self.curClickAreaId = 0

	if not self.hasInitData then
		local portPveData = getGameData():getPortPveData()
		self.hasInitData = true
		self:initAreaRect()
		portPveData:initData()
		self:askAreaMisInfo(self.curAraeId)
	end
	local supplyData = getGameData():getSupplyData()
	supplyData:askSupplyInfo(true)
end

ExploreMapData.initAreaRect = function(self)
	self.area_rect = {}  --按ID排序 ，海域范围
	for k, v in ipairs(area_info) do	 -- 7个海域
		self.area_rect[k] = CCRect(v.lbPos[1], v.lbPos[2], v.width, v.height)
	end
	self.area_rect[8] = CCRect(0, 1792, 3616, 288)  -- 北极
	self.area_rect[9] = CCRect(0, 0, 3616, 288)     -- 南极
end

ExploreMapData.setCurAreaId = function(self, areaId)
	self.curAraeId = areaId
end

ExploreMapData.getCurAreaId = function(self)
	local portData = getGameData():getPortData()
	if port_info[portData:getPortId()] == nil then
		return 1
	end
	return self.curAraeId or port_info[portData:getPortId()].areaId
end

ExploreMapData.setCurClickAreaId = function(self, areaId)
	self.curClickAreaId = areaId
end

ExploreMapData.setCurSelectPointInfo = function(self, select_info)
	self.cur_select_point_info = select_info
end

ExploreMapData.getCurSelectPointInfo = function(self)
	return self.cur_select_point_info
end

ExploreMapData.getCurClickAreaId = function(self)
	return self.curClickAreaId
end

ExploreMapData.clearCurClickAreaId = function(self)
	self:setCurClickAreaId(0)
end

ExploreMapData.getCurPointAreaId = function(self)
	if self.curClickAreaId ~= 0 then
		return self.curClickAreaId
	end
	return self.curAraeId
end

ExploreMapData.getSeaArea = function(self, pos, first_area_id)
	local cur_area_id = self.curAraeId
	if first_area_id then
		cur_area_id = first_area_id
	end
	local curAreaRect = self.area_rect[cur_area_id]
	if curAreaRect ~= nil then
		if curAreaRect:containsPoint(pos) then
			return cur_area_id
		end
		local crossAreaRect = nil
		local curAraeInfo = area_info[cur_area_id]
		if curAraeInfo ~= nil and curAraeInfo.cross_area_priority ~= nil then
			for i,j in pairs(curAraeInfo.cross_area_priority) do
				crossAreaRect = self.area_rect[j]
				if crossAreaRect ~= nil and crossAreaRect:containsPoint(pos) then
					return j
				end
			end
		end
	end
	local arena = {}
	for k ,v in pairs(self.area_rect) do
		if v:containsPoint(pos) then
			arena[#arena + 1] = k
		end
	end
	if #arena > 0 then
		return arena[1]
	end

	return 0 -- 其他海域
end

ExploreMapData.getSeaAreaWithTPos = function(self, pos, first_area_id)
    return self:getSeaArea(exploreMapUtil.landTileToThumbTile(pos), first_area_id)
end

ExploreMapData.getClickOpenAreaId = function(self, pos)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local opeanArea = mapAttrs:getSeaArea()
	for k, v in ipairs(area_info) do	 -- 7个海域
		--if opeanArea[k] then
		if true then
			local apos = {x = v.lbPos[1], y = v.lbPos[2]}
			if pos.x >= apos.x and pos.x <= (apos.x + v.width) and pos.y >= apos.y and pos.y <= (apos.y + v.height) then
				return k
			end
		end
	end
	return 0
end

ExploreMapData.isClickOpenArea = function(self, pos)
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local opeanArea = mapAttrs:getSeaArea()
	for k, v in ipairs(area_info) do	 -- 7个海域
		if opeanArea[k] then
			local apos = {x = v.lbPos[1], y = v.lbPos[2]}
			if pos.x >= apos.x and pos.x <= (apos.x + v.width) and pos.y >= apos.y and pos.y <= (apos.y + v.height) then
				return true
			end
		end
	end
	return false
end

ExploreMapData.isLegalAreaId = function(self, areaId)
	if not areaId or type(areaId) ~= "number" then
		return nil
	end

	if areaId <= 0 or areaId > #area_info then
		return nil
	end

	return true
end

ExploreMapData.updateTaskPortSh = function(self)
	self.taskPort = {}
	self.taskPortList = {}

	self.taskSh = {}
	self.taskShList = {}
	self.taskMapSelectPortId = nil

	local task_port_dic = {}

	local missionGuide = require("gameobj/mission/missionGuide")
	local missionDataHandler = getGameData():getMissionData()

	local dataList = missionDataHandler:getDoingMissionId()
	if not dataList or #dataList < 1 then return end
	local mission_info = getMissionInfo()
	for _ , mission_id in ipairs(dataList) do
		local mission=mission_info[mission_id]
		if mission.guide then
			for k, portId in pairs(mission.guide) do
				if not missionGuide:judgeMissionFinishByPort(mission,portId) then
					if not self.taskPort[portId] then
						self.taskPort[portId] = {}
					end
					if not task_port_dic[portId] then
						task_port_dic[portId] = true
						self.taskPortList[#self.taskPortList + 1] = {missionType=mission.type, missionId = mission.id, portId=portId}
						if not self.taskMapSelectPortId and mission.skip_port == 1 then
							self.taskMapSelectPortId = portId
						end
					end
					self.taskPort[portId][#self.taskPort[portId] + 1] = mission_id
				end
			end
		end

		if mission.guidesh and mission.guidesh > 0 then
			if not self.taskSh[mission.guidesh] then
				self.taskShList[#self.taskShList + 1] = {missionType=mission.type, shId = mission.guidesh}
			end
			self.taskSh[mission.guidesh] = true
		end
	end

	--当玩家接到有任命港口的任务时强制默认选中任命的港口
	for _ , mission_id in ipairs(dataList) do
		local mission = mission_info[mission_id]
		if mission.guide_notout and mission.guide_notout > 0 then
			self.taskMapSelectPortId = mission.guide[1]
			break
		end
	end

end

ExploreMapData.getTaskPort = function(self)
	return self.taskPort
end

ExploreMapData.getTaskPortList = function(self)
	return self.taskPortList
end

ExploreMapData.getTaskSh = function(self)
	return self.taskSh
end

ExploreMapData.getTaskShList = function(self)
	return self.taskShList
end

ExploreMapData.getTaskMapSelectPortId = function(self)
	return self.taskMapSelectPortId
end

--获取两个港口的距离
ExploreMapData.getPort2PortDistance = function(self, port1Id, port2Id)
	if port1Id == port2Id then
		return 0
	end
	if not port2port_distance_info[port1Id] or not port2port_distance_info[port1Id][port2Id] then
		cclog(T("=====================获取港口至港口距离异常：找不到距离配置！！！"))
		return 0
	end
	local distance = port2port_distance_info[port1Id][port2Id]
	return math.ceil(distance)
end

ExploreMapData.getExploreExpectDis = function(self)
	return self.exploreExpectDis
end

ExploreMapData.getExploreExpectFood = function(self)
	return self.exploreExpectFood
end

ExploreMapData.getWhirlByAreaId = function(self, area_id)
	for k, v in pairs(explore_whirlpool) do
		if v.sea_index == area_id then
			return v
		end
	end
end

local getAreaWhirlItem
getAreaWhirlItem = function(area_id)
	for k, v in pairs(explore_whirlpool) do
		if v.sea_index == area_id then
			return k ,v
		end
	end
end
ExploreMapData.goMayChangeWhirlHandler = function(self, destId, navType, prarms, go_callback, no_change_callback, cancel_callback)
	local pos_info = self:getDestPosInfo(destId, navType, prarms)
	local sceneDataHander = getGameData():getSceneDataHandler()
	local is_in_port = sceneDataHander:isInPortScene()
	local is_in_explore = sceneDataHander:isInExplore()
	if is_in_port or is_in_explore then
		local now_area_id = nil
		local map_id = sceneDataHander:getMapId()
		if is_in_port then
			now_area_id = port_info[map_id].areaId
		else
			now_area_id = map_id
		end
		local go_area_id = pos_info.area_id
		if go_area_id and now_area_id and go_area_id ~= now_area_id then
			local go_area_item = area_info[go_area_id]
			local now_area_item = area_info[now_area_id]
			local now_whirl_id, now_whirl_item = getAreaWhirlItem(now_area_id)
			local go_whirl_id, go_whirl_item = getAreaWhirlItem(go_area_id)
			if go_area_item and now_area_item and now_whirl_id and go_whirl_id then
				local is_around = false
				for _, around_area_id in ipairs(now_area_item.around_areas) do
					if around_area_id == go_area_id then
						is_around = true
						break
					end
				end
				if not is_around then
					local onOffData = getGameData():getOnOffData()
					if onOffData:isOpen(on_off_info[now_whirl_item.switch_key].value) and onOffData:isOpen(on_off_info[go_whirl_item.switch_key].value) then
						local news_info = require("game_config/news")
						Alert:showAttention(string.format(news_info.EXPLORER_WHIRLPOOL.msg, now_whirl_item.name), function() go_callback(now_whirl_id) end, cancel_callback, function()
								no_change_callback(true)
							end, {ok_text = ui_word.GO_WHIRL, cancel_text = ui_word.GO_SAILING, use_orange_btn = true})
						return
					end
				end
			end
		end
	end
	no_change_callback(false)
end

ExploreMapData.getDestPosInfo = function(self, destId, navType, params)
	local end_pos = nil
	local area_id = nil
	params = params or {}
	if navType == EXPLORE_NAV_TYPE_PORT then
		local port_item =  port_info[destId]
		end_pos = port_item.ship_pos
		area_id = port_item.areaId
	elseif navType == EXPLORE_NAV_TYPE_SH then
		end_pos = pve_stronghold_info[destId].ship_pos
	elseif navType == EXPLORE_NAV_TYPE_WHIRLPOOL then
		local whirlpool_item = explore_whirlpool[destId]
		end_pos = whirlpool_item.sea_pos
		area_id = whirlpool_item.sea_index
	elseif navType == EXPLORE_NAV_TYPE_RELIC then
		local relic_item = relic_info[destId]
		end_pos = relic_item.ship_pos
		area_id = relic_item.areaId
	elseif navType == EXPLORE_NAV_TYPE_TIME_PIRATE then
		end_pos = getGameData():getExplorePirateEventData():getTimePirateConfig()[destId].sea_pos
	elseif navType == EXPLORE_NAV_TYPE_POS then
		if params.pos then
			end_pos = params.pos
		else
			local cache_info = getGameData():getExploreData():getGoalInfo()
			if cache_info then
				end_pos = cache_info.pos
			end
		end
		if params.area_id then
			area_id = params.area_id
		end
	end
	if not area_id and end_pos then
		area_id = self:getSeaAreaWithTPos(ccp(end_pos[1], end_pos[2]))
	end
	return {["end_pos"] = end_pos, ["area_id"] = area_id}
end

--计算出海预计距离
ExploreMapData.calcExploreExpectDis = function(self, destId, navType)
	if not destId then
		return 0
	end

	local distance = 0
	local start_pos
	local end_pos = self:getDestPosInfo(destId, navType).end_pos

	-- 探索中的话
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		if explore_layer:getLand() then
			distance = explore_layer:getLand():calculateShipToPosDistance(end_pos)
		end
	else
		local portData = getGameData():getPortData()
		local portId = portData:getPortId()
		start_pos = port_info[portId].ship_pos

		local util = require("module/transformUtil")
		distance = util.calculatePosToPosDistance(start_pos, end_pos)
	end

	self.exploreExpectDis = toint(distance)

	return self.exploreExpectDis
end

--计算出海预计消耗食物
ExploreMapData.calcExploreExpectFood = function(self, destId, navType, distance)
	if not destId then
        self.exploreExpectFood = 0
		return 0
	end
	require("gameobj/battle/cameraFollow")
	local exploreData = getGameData():getExploreData()
	local portData = getGameData():getPortData()
	local sailorDistance = distance or self:calcExploreExpectDis(destId, navType)
	local supplyData = getGameData():getSupplyData()
	local sailorSpeed = exploreData:getShipNormalSpeed()

	sailorSpeed = sailorSpeed * 2 / 1.3
	local sailorTime = sailorDistance / sailorSpeed

	self.exploreExpectFood = exploreFormula.calcNeedFoodByExplore(supplyData:getTotalSailor(), sailorTime)

	return self.exploreExpectFood
end

--计算出海可行距离
ExploreMapData.calcExploreCanGoDis = function(self)
	local exploreData = getGameData():getExploreData()
	local supplyData = getGameData():getSupplyData()
	local dis = 0
	local sailorSpeed = exploreData:getShipNormalSpeed()

	sailorSpeed = sailorSpeed * 2 / 1.3
	local sailorTime = exploreFormula.calcTimeByExplore(supplyData:getCurSailor(), supplyData:getCurFood())

	dis = math.floor(sailorSpeed * sailorTime)
	return dis
end

--//////////////////////////////海域任务//////////////////////////////

ExploreMapData.getAreaMissionInfo = function(self)
	if self.areaMissionInfo then
		self.areaMissionInfo.baseData = area_mission_info[self.areaMissionInfo.missionId]
		self.areaMissionInfo.areaName = area_info[self.areaMissionInfo.baseData.area].name
	end
	return self.areaMissionInfo
end

--海域任务-请求任务数据
ExploreMapData.askAreaMisInfo = function(self, areaId)
	-- GameUtil.callRpc("rpc_server_area_mission_info", {areaId},"rpc_client_area_mission_info")
end

ExploreMapData.receiveAreaMisInfo = function(self, missionInfo)
	self.areaMissionInfo = missionInfo
end

--海域任务-请求领取奖励
ExploreMapData.askGetAreaMisReward = function(self, areaId)
	GameUtil.callRpc("rpc_server_area_mission_get_reward", {areaId},"rpc_client_area_mission_get_reward")
end

ExploreMapData.receiveAreaMisReward = function(self, missionId, result, err)
	if result==0 then
		Alert:warning({msg =error_info[err].message, size = 26})
		return
	end

	if result == 1 then
		local data = self:getMissionInfoById(missionId)
		local tempReward = {}
		for k, v in pairs(data.reward) do
			if k == "gold" then
				local itemReward = {}
				itemReward.key = ITEM_INDEX_GOLD
				itemReward.value = tonumber(v)
				itemReward.id = 0
				tempReward[#tempReward + 1] = itemReward
			elseif k == "keepsake" then
				--
				for tKey, tValue in pairs(v) do
					local itemReward = {}
					itemReward.key = ITEM_INDEX_KEEPSAKE
					itemReward.value = tonumber(tValue.amount)
					itemReward.id = tValue.id
					tempReward[#tempReward + 1] = itemReward
				end
			end
		end
		Alert:showCommonReward(tempReward, function()

		end)
	end
end

ExploreMapData.getMissionInfoById = function(self, missionId)
	return area_mission_info[missionId]
end

ExploreMapData.askMapPortInfos = function(self, port_ids)
	if not port_ids or #port_ids < 1 then return end
	local market_data = getGameData():getMarketData()
	market_data:askPortGoodInfos(port_ids)
end

return ExploreMapData
