local cfg_port_info = require("game_config/port/port_info")

local ClsPortBattleData = class("ClsPortBattleData")

local WARSHIP_TYPE = 0
local SCULPTURE_TYPE = 1

ClsPortBattleData.ctor = function(self)
	self.occupy_info = {} --占领者信息
	self.challenge_info_list = {} --挑战者信息列表
	self.donate_list = {} --捐献列表
	self.cur_donate_times = 0 --捐献次数
	self.max_donate_times = 5
	self.donate_base = 40000
	self.donate_multiple = 70
	self.donate_type = WARSHIP_TYPE
	self.cur_donates = 0 --当前捐献的总量 
	self.max_donates = self.donate_base + self.donate_multiple * 1400  --最大捐献总量 巨舰16000+30*（捐献度-600）
	self.sculpture_donate_base = 80000
	self.sculpture_donate_multiple = 200
	self.sculpture_max_donates = self.sculpture_donate_base + self.sculpture_donate_multiple * 1400
	-- self.port_battle_status = PORT_BATTLE_STATUS.CLOSE --现在存于什么状态
	self.my_guild_rank = 0
	self.supply_goods = 0 --副本场景的补给数量
	self.battle_chart = {}
	self.defender_name = nil
	self.attacker_left_name = nil
	self.attacker_right_name = nil
	self.attacker_left_people = nil
	self.attacker_right_people = nil
	self.remain_time = 0 		  --港口战活动的剩余时间
	self.explore_occupy_info = {} --探索上的存储信息
	self.status = 0      		  --港口战的活动状态
	self.port_list = nil 		  --可占领的港口列表
	self.mvp_data = nil  		  --港口战MVP数据
	self.occupy_list = nil 		  --占领城市列表
	self.challenge_list = nil 	  --攻打城市列表
	self.portsInAreas = nil 	  --每片海域对应港口
end

ClsPortBattleData.initDonate = function(self)
	self.donate_list = {}
	local guild_info_data = getGameData():getGuildInfoData()
	local members = guild_info_data:getGuildInfoMembersNumAsKey() or {}
	for k, v in ipairs(members) do
		self.donate_list[k] = {uid = v.uid, name = v.name, build = 0}
	end
end


ClsPortBattleData.sortDonate = function(self, list)
	table.sort(list, function(a, b)
		return a.build > b.build
	end)
	return list
end

ClsPortBattleData.addSingleDonateInfo = function(self, info)
	local donate_multiple = self.donate_multiple
	if self.donate_type == SCULPTURE_TYPE then
		donate_multiple = self.sculpture_donate_multiple
	end
	for k, v in ipairs(self.donate_list) do
		if info.uid == v.uid then
			v.build = info.build --* donate_multiple
		end
	end
	self.donate_list = self:sortDonate(self.donate_list)
	-- self:calcCurDonates()
end

--检查是否在参战的商会里面
ClsPortBattleData.checkCanFight = function(self)
	local guild_info_data = getGameData():getGuildInfoData()
	local is_has_guild = guild_info_data:hasGuild()
	if not is_has_guild then
		return false
	end

	local challenge_info = self:getChallengeInfoList()
	local my_guild_id = guild_info_data:getGuildId()
	local occupy_info = self:getOccupyInfo()
	if my_guild_id == occupy_info.groupId and #challenge_info ~= 0 then
		return true
	end

	for k, v in pairs(challenge_info) do
		if my_guild_id == v.groupId then
			return true
		end
	end

	return false
end

-------------------- set get is function ------------------------------------
ClsPortBattleData.setDonateType = function(self, donate_type)
	self.donate_type = donate_type
end

ClsPortBattleData.setRemainTime = function(self, remain_time)
	self.remain_time = remain_time
end

ClsPortBattleData.getRemainTime = function(self)
	return self.remain_time
end

--info
--{
--	groupId
--	group_name
--	group_rank
--	group_prestige
--}
ClsPortBattleData.setOccupyInfo = function(self, port_id, info)
	self.occupy_info[port_id] = info
end

--list = info*
ClsPortBattleData.setChallengeInfoList = function(self, port_id, list)
	table.sort(list, function(a, b)
		if a.isWin ~= b.isWin then
			return a.isWin > b.isWin
		else
			return a.group_rank < b.group_rank
		end
	end)
	self.challenge_info_list[port_id] = list
end

ClsPortBattleData.getOccupyInfo = function(self, port_id)
	local port_data = getGameData():getPortData()
	port_id = port_id or port_data:getPortId()
	return self.occupy_info[port_id] or {}
end

--[[
	occupy_info = {
		["group_icon"] = "1",
		["group_name"] = "312312]",
		["portId"] = 2.000000,
		},
	}
]]--
ClsPortBattleData.setExploreOccupyInfo = function(self, occupy_info)
	self.explore_occupy_info[occupy_info.portId] = occupy_info
end

ClsPortBattleData.getExploreOccupyInfo = function(self, port_id)
	return self.explore_occupy_info[port_id] or {}
end

ClsPortBattleData.getAllPortsOccupyInfo = function(self)
	return self.explore_occupy_info
end

ClsPortBattleData.getChallengeInfoList = function(self, port_id)
	local port_data = getGameData():getPortData()
	port_id = port_id or port_data:getPortId()
	return self.challenge_info_list[port_id] or {}
end

--list = {
--	{[uid], [build]}
--}
ClsPortBattleData.setDonateList = function(self, list)
	self:initDonate()
	local donate_multiple = self.donate_multiple
	if self.donate_type == SCULPTURE_TYPE then
		donate_multiple = self.sculpture_donate_multiple
	end
	for k, v in ipairs(list) do
		for k1, v1 in ipairs(self.donate_list) do
			if v.uid == v1.uid then
				v1.build = v.build --* donate_multiple
			end
		end
	end
	self.donate_list = self:sortDonate(self.donate_list)
	-- self:calcCurDonates()
end

ClsPortBattleData.calcCurDonates = function(self)
	local donate_base = self.donate_base
	if self.donate_type == SCULPTURE_TYPE then
		donate_base = self.sculpture_donate_base
	end

	self.cur_donates = donate_base
	for k, v in pairs(self.donate_list) do
		self.cur_donates = self.cur_donates + v.build
	end
end

ClsPortBattleData.getDonateList = function(self)
	return self.donate_list
end

ClsPortBattleData.setCurDonateTimes = function(self, times)
	self.cur_donate_times = times or 0
end

ClsPortBattleData.getCurAndMaxDonateTimes = function(self)
	return self.cur_donate_times, self.max_donate_times
end

ClsPortBattleData.getCurAndMaxDonates = function(self)
	local max_donates = self.max_donates

	if self.donate_type == SCULPTURE_TYPE then
		max_donates = self.sculpture_max_donates
	end

	return self.cur_donates, max_donates
end

ClsPortBattleData.setCurDonates = function(self, val)
	self.cur_donates = val * self.donate_multiple + self.donate_base
	if self.donate_type == SCULPTURE_TYPE then
		self.cur_donates = val * self.sculpture_donate_multiple + self.sculpture_donate_base
	end
end

ClsPortBattleData.singleAddDonates = function(self)
	if self.donate_type == SCULPTURE_TYPE then
		self.cur_donates = self.cur_donates + self.sculpture_donate_multiple
	else
		self.cur_donates = self.cur_donates + self.donate_multiple
	end
end

--是否开放港口争夺战
ClsPortBattleData.isOpenBattle = function(self, check_port_id)
	local port_data = getGameData():getPortData()
	check_port_id = check_port_id or port_data:getPortId()
	-- 1 表示开放 0 表示未开放
	return cfg_port_info[check_port_id].port_battle == 1 
end

-- ClsPortBattleData.setPortBattleStatus = function(self, status)
-- 	self.port_battle_status = status
-- end

-- ClsPortBattleData.getPortBattleStatus = function(self)
-- 	return self.port_battle_status
-- end

ClsPortBattleData.setMyGuildRank = function(self, rank)
	self.my_guild_rank = rank
end

ClsPortBattleData.getMyGuildRank = function(self)
	return self.my_guild_rank 
end

-- ClsPortBattleData.isCanApply = function(self)
-- 	return self.port_battle_status == PORT_BATTLE_STATUS.APPLY 
-- end

-- ClsPortBattleData.isCanDonate = function(self)
-- 	return self.port_battle_status == PORT_BATTLE_STATUS.DONATE 
-- end

ClsPortBattleData.isCanFight = function(self, port_id)
	if self:getOccupyInfo(port_id).isWin ~= 0 then
		return false
	end

	local info_list = self:getChallengeInfoList(port_id) 
	for k, v in pairs(info_list) do
		if v.isWin ~= 0 then
			return false
		end
	end
	return (self.status == PORT_BATTLE_STATUS.START_WAR_1 or self.status == PORT_BATTLE_STATUS.START_WAR_2)
end

-- ClsPortBattleData.isClose = function(self)
-- 	return self.port_battle_status == PORT_BATTLE_STATUS.CLOSE
-- end

ClsPortBattleData.isEnd = function(self, port_id)
	if self:getOccupyInfo(port_id).isWin ~= 0 then
		return true
	end

	local info_list = self:getChallengeInfoList(port_id)
	for k, v in pairs(info_list) do
		if v.isWin ~= 0 then
			return true
		end
	end
	return (self.status == PORT_BATTLE_STATUS.FINISH_1 or self.status == PORT_BATTLE_STATUS.FINISH_2)
end

-- ClsPortBattleData.isReady = function(self)
-- 	return self.port_battle_status == PORT_BATTLE_STATUS.READY
-- end

ClsPortBattleData.isOpenPort = function(self, port_id)
	if not cfg_port_info[port_id] then
		return false
	end
	return cfg_port_info[port_id].port_battle == 1
end

ClsPortBattleData.getDonateCash = function(self)
	local player_data = getGameData():getPlayerData()
	--10*ROUND((1.5^INT(角色等级/10))*660,-2)*2
	local part1 = math.pow(1.5, math.floor(player_data:getLevel() / 10))*660
	return math.floor(part1/100 + 0.5)*100*20 --百位四舍五入取整
end

--chart = info* = {
	-- name, 名字
	-- attack, 攻击的次数
	-- score, 积分多少
	-- win_streak, 连胜多少场
--}
ClsPortBattleData.setBattleChart = function(self, chart)
	table.sort(chart, function(a, b)
		return a.score > b.score
	end)
	self.battle_chart = chart
end

ClsPortBattleData.getBattleChart = function(self)
	return self.battle_chart
end

ClsPortBattleData.setDefenderName = function(self, name)
	self.defender_name = name
end

ClsPortBattleData.setAttackerLeftName = function(self, name)
	self.attacker_left_name = name
end

ClsPortBattleData.setAttackerRightName = function(self, name)
	self.attacker_right_name = name
end

ClsPortBattleData.setAttackerLeftPeople = function(self, people)
	self.attacker_left_people = people
end

ClsPortBattleData.setAttackerRightPeople = function(self, people)
	self.attacker_right_people = people
end

ClsPortBattleData.setPortBattleStatus = function(self, status)
	self.status = status
end

ClsPortBattleData.setPortList = function(self, list)
	self.port_list = list
end

ClsPortBattleData.getPortList = function(self)
	return self.port_list
end

ClsPortBattleData.getPortBattleStatus = function(self)
	return self.status
end

ClsPortBattleData.getDefenderName = function(self)
	return self.defender_name
end

ClsPortBattleData.getAttackerLeftName = function(self)
	return self.attacker_left_name
end

ClsPortBattleData.getAttackerRightName = function(self)
	return self.attacker_right_name
end

ClsPortBattleData.getAttackerLeftPeople = function(self)
	return self.attacker_left_people
end

ClsPortBattleData.getAttackerRightPeople = function(self)
	return self.attacker_right_people
end

ClsPortBattleData.setMVPData = function(self, mvp_info)
	self.mvp_data = mvp_info
end

ClsPortBattleData.getMVPData = function(self)
	return self.mvp_data
end

ClsPortBattleData.getOccupyList = function(self)
	return self.occupy_list
end

ClsPortBattleData.getChallegeList = function(self)
	return self.challenge_list
end

ClsPortBattleData.setOccupyList = function(self, list)
	self.occupy_list = list
end

ClsPortBattleData.setChallegeList = function(self, list)
	self.challenge_list = list
end

ClsPortBattleData.getAllPorts = function(self)
	if not self.portsInAreas then
		self.portsInAreas = {}
		for port_id, port_info in ipairs(cfg_port_info) do
			local area_id = port_info.areaId
			if area_id then
				if not self.portsInAreas[area_id] then
					self.portsInAreas[area_id] = {}
				end
				table.insert(self.portsInAreas[area_id], port_id)
			end 
		end
	end
	return self.portsInAreas
end
-------------------- set get is function -------------------------------------

----------------------------- 协议请求 ---------------------------------------

--查看当前港口的对战信息
ClsPortBattleData.askOccupyInfo = function(self, check_port_id)
	GameUtil.callRpc("rpc_server_port_battle_occupy_info", {check_port_id})
end

--报名港口争夺战
ClsPortBattleData.askBattleApply = function(self, check_port_id)
	GameUtil.callRpc("rpc_server_port_battle_apply", {check_port_id})
end

--获得捐献信息
ClsPortBattleData.askDonateInfo = function(self, port_id)
	GameUtil.callRpc("rpc_server_group_build_info", {port_id})
end

--捐献
ClsPortBattleData.askDonate = function(self, port_id)
	GameUtil.callRpc("rpc_server_group_build", {port_id})
end

--进入争夺战
ClsPortBattleData.askBattleEnter = function(self, check_port_id)
	GameUtil.callRpc("rpc_server_port_battle_enter", {check_port_id})
end

--请求某个阵营的积分列表
ClsPortBattleData.askBattleChart = function(self, port_id)
	GameUtil.callRpc("rpc_server_port_battle_chart", {port_id})
end

--请求已经报名的港口列表如果没有，则直接下行show_error协议
ClsPortBattleData.askApplyPortsInfo = function(self)
	GameUtil.callRpc("rpc_server_port_battle_activity_info", {})
end

--请求占领港口的商会名有哪些
--参数没用，但要配合后端。后端没用可删除
ClsPortBattleData.askPortsOccupyInfo = function(self, areaId)
	GameUtil.callRpc("rpc_server_port_occupy_info", {areaId})
end

ClsPortBattleData.askPortBattleStatus = function(self)
	GameUtil.callRpc("rpc_server_port_battle_list", {})
end

ClsPortBattleData.askPortBattleMVP = function(self, port_id)
	GameUtil.callRpc("rpc_server_port_battle_mvp_info", {port_id})
end

ClsPortBattleData.askCurPortsInfo = function(self, group_id)
	GameUtil.callRpc("rpc_server_group_port_battle", {group_id})
end
----------------------------- 协议请求 ---------------------------------------

return ClsPortBattleData
