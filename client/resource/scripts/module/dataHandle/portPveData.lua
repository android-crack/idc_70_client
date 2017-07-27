local port_info = require("game_config/port/port_info")
local battle_type_info = require("game_config/battle/battle_type_info") -- battlecfg
local pve_port_info = require("game_config/portPve/pve_port_info")
local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
local dataTools = require("module/dataHandle/dataTools")
local UI_WORD = require("game_config/ui_word")
local news=require("game_config/news")
local Alert = require("ui/tools/alert")
local battle_data_util = require("module/dataHandle/battle_data_util")

local portPveData = class("PortPveData")

function portPveData:ctor()
	self.portInfoDics = {}
	self.strongHoldInfoDics = {}
	self.opponentInfo = {}
	self._isCompletePort = false
	self._isLastFightWin = false
	self.openPortInfoDics = {}
	self.openShInfoDics = {}
	self.portFightLayerDic = {}
	self.shFightLayerDic = {}
	self.notShowBattleResult = false
	self.cdCheckPoint1Hour = 12 --12点
	self.cdCheckPoint2Hour = 18 --18点
	self.cdCheckPoint3Hour = 24 --24点
end

--初始化数据
function portPveData:initData()
	self:resetData()

	-- self:askAllCpInfo()
end

function portPveData:setNotShowBattleResult(value)
	self.notShowBattleResult = value
end

function portPveData:getNotShowBattleResult()
	return self.notShowBattleResult
end

function portPveData:resetData()
	self.portInfoDics = {}
	self.strongHoldInfoDics = {}

	for k, v in pairs(port_info) do
		local portInfo = {}
		portInfo.portId = k
		portInfo.status = EX_PVE_STATUS_HIDE
		portInfo.isOwner = 0
		portInfo.step = 0
		portInfo.checkpointId = 0
		portInfo.fromServer = false

		self.portInfoDics[k] = portInfo
	end

	for k, v in pairs(pve_stronghold_info) do
		local strongHoldInfo = {}
		strongHoldInfo.strongholdId = k
		strongHoldInfo.status = EX_PVE_STATUS_HIDE
		strongHoldInfo.step = 0
		strongHoldInfo.complete = 0  --已经打过的次数
		strongHoldInfo.fromServer = false
		strongHoldInfo.coolCD = 0

		self.strongHoldInfoDics[k] = strongHoldInfo
	end
end

--清除数据
function portPveData:clearData()
	self.portInfoDics = {}
	self.strongHoldInfoDics = {}
	self.openPortInfoDics = {}
	self.openShInfoDics = {}
	self:clearOpponentData()
end 

function portPveData:clearOpponentData()
	self.opponentInfo = {}
end

--递归查找可以攻打的港口id
function portPveData:getPreCanFightPortId(checkPointId)
	local cpInfo = self:getPortCpInfo(checkPointId)
	local portId = cpInfo.port_id
	if self:canFightPort(portId) then
		return portId
	else
		local preCheckPointIds = lua_string_split(cpInfo.pre_checkpoint, ",")
		for k,v in pairs(preCheckPointIds) do
			if v ~= "" then
				local returnPortId = self:getPreCanFightPortId(tonumber(v))
				if returnPortId ~= nil then
					return returnPortId
				end
			end
		end
	end
end

--递归查找可以攻打的海上据点id
function portPveData:getPreCanFightShId(strongHoldId)
	local cpInfo = self:getStrongHoldCpInfo(strongHoldId)
	if self:canFightStrongHold(strongHoldId) then
		return strongHoldId
	else
		local preStrongHoldIds = lua_string_split(cpInfo.pre_stronghold, ",")
		for k,v in pairs(preStrongHoldIds) do
			if v ~= "" then
				local returnShId = self:getPreCanFightShId(tonumber(v))
				if returnShId ~= nil then
					return returnShId
				end
			end
		end
	end
end

portPveData.FIGHT_TYPE_PORT = 1
portPveData.FIGHT_TYPE_SH = 2

--快速查找可以攻打的港口/海上据点id-----------港口优先
function portPveData:getPreCanFight1()
	for k,v in pairs(self.portInfoDics) do
		if self:canFightPort(k) then
			return self.FIGHT_TYPE_PORT,k
		end
	end

	for k,v in pairs(self.strongHoldInfoDics) do
		if self:canFightStrongHold(k) then
			return self.FIGHT_TYPE_SH,k
		end
	end

	return nil,nil
end

--快速查找可以攻打的港口/海上据点id-----------海上据点优先
function portPveData:getPreCanFight2()
	for k,v in pairs(self.strongHoldInfoDics) do
		if self:canFightStrongHold(k) then
			return self.FIGHT_TYPE_SH,k
		end
	end

	for k,v in pairs(self.portInfoDics) do
		if self:canFightPort(k) then
			return self.FIGHT_TYPE_PORT,k
		end
	end

	return nil,nil
end

function portPveData:setPortFightLayerId(portId, layerId)
	self.portFightLayerDic[portId] = layerId
end

function portPveData:getPortFightLayerId(portId)
	return self.portFightLayerDic[portId]
end

function portPveData:setShFightLayerId(strongholdId, layerId)
	self.shFightLayerDic[strongholdId] = layerId
end

function portPveData:getShFightLayerId(strongholdId)
	return self.shFightLayerDic[strongholdId]
end

function portPveData:getBattleIndex(id, sid)
    local data = battle_type_info[id].generalBattle
    local battle_info_config_data = getGameData():getBattleInfoConfigData()
    if battle_info_config_data:isEliteConfig() then
        data = battle_type_info[id].eliteBattle
    end
	
    for k, v in ipairs(data) do
		if v == sid then
			return k
		end
	end
end

function portPveData:getPvePortCompletePro()
	-- local qihaiAchieveData = getGameData():getQihaiAchieveData()
	local completeNum = 0
	local allNum = 0
	-- for k,v in pairs(self.portInfoDics) do
	-- 	if v.fromServer then
	-- 		if self:isPortFree(k) then
	-- 			completeNum = completeNum + 1
	-- 		end
	-- 		allNum = allNum + 1
	-- 	end
	-- end

	-- local achieveData = qihaiAchieveData:getAchieveByStatus(1)

	if achieveData then
		completeNum = achieveData.progress
		allNum = achieveData.amount
	end
	
	if allNum == 0 then
		return 100
	end

	return math.floor(completeNum*100 / allNum)
end

function portPveData:getPveShCompletePro()
	local completeNum = 0
	local allNum = 0
	for k,v in pairs(self.strongHoldInfoDics) do
		if v.fromServer then
			if self:isStrongHoldFree(k) or self:isStrongHoldCool(k) then
				completeNum = completeNum + 1
			end
			allNum = allNum + 1
		end
	end

	if allNum == 0 then
		return 100
	end

	return math.floor(completeNum*100 / allNum)
end

function portPveData:getPortDiffInfo(id)
    local myPower = getGameData():getPlayerData():getBattlePower()
    local myPowerOff = myPower*0.85
	local pve_info = self:getPortPveInfo(id)
	local diffStr = nil
    local diffColor = nil
    local canFight = 0
    local isMeetLevel,_ = self:isPortMeetLevel(id)
	if not isMeetLevel then
		diffStr=UI_WORD.PVE_CP_DIFF_NAME4
	    diffColor=COLOR_RED
	elseif self:canFightPort(id) then
		canFight = 1
		if pve_info.enemy_power<myPowerOff then
	        diffStr=UI_WORD.PVE_CP_DIFF_NAME1
	        diffColor=COLOR_GREY_STROKE
	    elseif myPowerOff<=pve_info.enemy_power and pve_info.enemy_power<myPower then
	        diffStr=UI_WORD.PVE_CP_DIFF_NAME2
	        diffColor=COLOR_GREEN
	    else
	    	diffStr=UI_WORD.PVE_CP_DIFF_NAME3
	    	diffColor=COLOR_RED
	    end
	else
		diffStr=UI_WORD.PVE_CP_DIFF_NAME4
	    diffColor=COLOR_RED
	end
	return {diffStr=diffStr, diffColor=diffColor, canFight=canFight}
end

function portPveData:getShDiffInfo(id)
    local myPower = getGameData():getPlayerData():getBattlePower()
    local myPowerOff = myPower*0.85
	local pve_info = self:getStrongHoldPveInfo(id)
	local diffStr = nil
    local diffColor = nil
    local canFight = 0
	local isMeetLevel,_ = self:isStrongHoldMeetLevel(id)
	if not isMeetLevel then
		diffStr=UI_WORD.PVE_CP_DIFF_NAME4
	    diffColor=COLOR_RED
	elseif self:canFightStrongHold(id) then
		canFight = 1
		if pve_info.enemy_power<myPowerOff then
	        diffStr=UI_WORD.PVE_CP_DIFF_NAME1
	        diffColor=COLOR_GREY_STROKE
	    elseif myPowerOff<=pve_info.enemy_power and pve_info.enemy_power<myPower then
	        diffStr=UI_WORD.PVE_CP_DIFF_NAME2
	        diffColor=COLOR_GREEN
	    else
	    	diffStr=UI_WORD.PVE_CP_DIFF_NAME3
	    	diffColor=COLOR_RED
	    end
	elseif self:isStrongHoldLock(id) then
		diffStr=UI_WORD.PVE_CP_DIFF_NAME4
	    diffColor=COLOR_RED
	else
		diffStr=UI_WORD.PVE_CP_DIFF_NAME5
	    diffColor=COLOR_BROWN
	end
	return {diffStr=diffStr, diffColor=diffColor, canFight=canFight}
end

function portPveData:getAllCanFightPortInfo()
	local infos = {}
	for k,v in pairs(self.portInfoDics) do
		if self:isPortOpen(k) then
			local info = {id=k, cpInfo=self:getPortCpInfo(v.checkpointId), pveInfo=v}
			info.name = info.cpInfo.port
			info.name_pos = port_info[k].name_pos
			info.diffInfo = self:getPortDiffInfo(k)
			info.canFight = info.diffInfo.canFight
			info.enemyPower = v.enemy_power
			infos[#infos + 1] = info
		end
	end

	local function sortPort(a,b)
		if a.canFight == b.canFight then
			return a.enemyPower>b.enemyPower
		else
			return a.canFight<b.canFight
		end
	end

	table.sort(infos, sortPort)

	return infos
end

function portPveData:getAllCanFightShInfo()
	local infos = {}
	for k,v in pairs(self.strongHoldInfoDics) do
		if self:isStrongHoldOpen(k) or self:isStrongHoldCool(k) then
			local info = {id=k, cpInfo=self:getStrongHoldCpInfo(k), pveInfo=v}
			info.name = info.cpInfo.name
			info.name_pos = info.cpInfo.name_pos
			info.diffInfo = self:getShDiffInfo(k)
			info.canFight = info.diffInfo.canFight
			info.enemyPower = v.enemy_power
			infos[#infos + 1] = info
		end
	end

	local function sortSh(a,b)
		if a.canFight == b.canFight then
			return a.enemyPower>b.enemyPower
		else
			return a.canFight<b.canFight
		end
	end

	table.sort(infos, sortSh)

	return infos
end

function portPveData:getCpInfo(file_name, id)
	local info = file_name[id]
	if not info then
		return nil
	end

	local stepInfos = {}
	local fightData = nil
	local rewards = nil
	for i = 1, info.step_amount do
		fightData = info["fight_step_"..i.."_data"]
		if not fightData or type(fightData) ~= "table" then
			return
		end
		rewards = {}
		if fightData.type == 2 then
			fightData.index = self:getBattleIndex(fightData.id, fightData.sid)
			fightData.power = self:getGeneralBattlePower(fightData.id, fightData.index)
		else
			fightData.power = self:getPiratePower(fightData.id)
		end
		
		if type(info["fight_step_"..i.."_reward"]) == "table" then
			for k1,v1 in pairs(info["fight_step_"..i.."_reward"]) do
				if type(v1) == "table" then
					for k2,v2 in pairs(v1) do
						rewards[#rewards + 1] = {type = k1, id = v2.id or 0, amount = v2.amount}
					end
				end
			end
		end

		if type(info["reward_" .. i]) == "table" then
			for k1,v1 in pairs(info["reward_" .. i]) do
				if type(v1) == "table" then
					for k2,v2 in pairs(v1) do
						rewards[#rewards + 1] = {type = k1, id = v2.id or 0, amount = v2.amount}
					end
				end
			end
		end
		
		stepInfos[#stepInfos+1] = {name=info["fight_step_"..i.."_name"], fightData=fightData, reward=info["fight_step_"..i.."_reward"],extReward = info["reward_" .. i], all_rewards = rewards}
	end
	info.stepInfos = stepInfos

	return info
end

function portPveData:getPortCpInfo(checkPointId)
	return self:getCpInfo(pve_port_info, checkPointId)
end

function portPveData:getStrongHoldCpInfo(strongHoldId)
	return self:getCpInfo(pve_stronghold_info, strongHoldId)
end

function portPveData:getPortPveInfo(portId)
	return self.portInfoDics[portId]
end

function portPveData:getStrongHoldAllPveInfo()
	return self.strongHoldInfoDics
end

function portPveData:getStrongHoldPveInfo(strongHoldId)
	return self.strongHoldInfoDics[strongHoldId]
end

function portPveData:canFightPort(portId)
	local pveInfo = self.portInfoDics[portId]
	return (pveInfo ~=nil and pveInfo.status == EX_PVE_STATUS_OPEN_ALL)
end

function portPveData:canFightStrongHold(strongHoldId)
	local pveInfo = self.strongHoldInfoDics[strongHoldId]
	return (pveInfo ~=nil and pveInfo.status == EX_PVE_STATUS_OPEN_ALL)
end

function portPveData:isStrongHoldMeetLevel(strongHoldId)
	if not strongHoldId then
		return true, 0
	end
	local pveInfo = self:getStrongHoldPveInfo(strongHoldId)
	local cpInfo = self:getStrongHoldCpInfo(pveInfo.strongholdId)

	if not cpInfo then
		return true, 0
	end
	
	local playerData = getGameData():getPlayerData()
	if playerData:getLevel() >= cpInfo.level then
		return true, cpInfo.level
	end
	return false, cpInfo.level
end

function portPveData:isPortMeetLevel(portId)
	if not portId then
		return true, 0
	end
	local pveInfo = self:getPortPveInfo(portId)
	local cpInfo = self:getPortCpInfo(pveInfo.checkpointId)

	if not cpInfo then
		return true, 0
	end

	local playerData = getGameData():getPlayerData()
	if playerData:getLevel() >= cpInfo.level then
		return true, cpInfo.level
	end
	return false, cpInfo.level
end

function portPveData:isPortOpen(portId)
	local pveInfo = self.portInfoDics[portId]
	return (pveInfo ==nil or pveInfo.status == EX_PVE_STATUS_OPEN_LOCK or pveInfo.status == EX_PVE_STATUS_OPEN_ALL)
end

function portPveData:isPortLock(portId)
	local pveInfo = self.portInfoDics[portId]
	return (pveInfo ==nil or pveInfo.status == EX_PVE_STATUS_OPEN_LOCK)
end

function portPveData:isPortFree(portId)
	local pveInfo = self.portInfoDics[portId]
	return (pveInfo ==nil or pveInfo.status == EX_PVE_STATUS_HIDE)
end

function portPveData:isStrongHoldOpen(strongHoldId)
	local pveInfo = self.strongHoldInfoDics[strongHoldId]
	return (pveInfo ==nil or pveInfo.status == EX_PVE_STATUS_OPEN_LOCK or pveInfo.status == EX_PVE_STATUS_OPEN_ALL)
end

function portPveData:isStrongHoldFree(strongHoldId)
	local pveInfo = self.strongHoldInfoDics[strongHoldId]
	return (pveInfo ==nil or pveInfo.status == EX_PVE_STATUS_HIDE)
end

function portPveData:isStrongHoldLock(strongHoldId)
	local pveInfo = self.strongHoldInfoDics[strongHoldId]
	return (pveInfo ==nil or pveInfo.status == EX_PVE_STATUS_OPEN_LOCK)
end

function portPveData:isStrongHoldCool(strongHoldId)
	local pveInfo = self.strongHoldInfoDics[strongHoldId]
	return (pveInfo ==nil or pveInfo.status == EX_PVE_STATUS_COOL_DOWN)
end

function portPveData:isStrongHoldImmortal(strongHoldId)
	local pveInfo = self.strongHoldInfoDics[strongHoldId]
	local cpInfo = pve_stronghold_info[strongHoldId]
	return (pveInfo ~=nil and cpInfo ~=nil and cpInfo.is_immortal ~=nil and cpInfo.is_immortal ==1 and pveInfo.status == EX_PVE_STATUS_HIDE and pveInfo.fromServer ==true)
end

function portPveData:setPortPveStatus(portId, status)
	if self.portInfoDics[portId] then
		self.portInfoDics[portId].status = status

		EventTrigger(EVENT_EXPLORE_PVE_CPDATA_PORT_UPDATE, self.portInfoDics, self.strongHoldInfoDics)
	end
end

function portPveData:setCompletePort()
	self._isCompletePort = true
end

function portPveData:setLastFightWin(isWin)
	self._isLastFightWin = isWin
end

function portPveData:isCompletePort()
	local isCompletePort = false
	if self._isCompletePort then
		isCompletePort = true
	end

	self._isCompletePort = false

	return isCompletePort
end

function portPveData:isLastFightWin()
	local isLastFightWin = false
	if self._isLastFightWin then
		isLastFightWin = true
	end

	self._isLastFightWin = false

	return isLastFightWin
end

local scheduler = CCDirector:sharedDirector():getScheduler()

--从战斗返回探索
function portPveData:resetExplore()
	local uid = self.opponentInfo.uid
	local pveType = self.opponentInfo.pveType
	if uid then
		if pveType == EX_PVE_TYPE_PORT then
			if self.hander_reset_ex then
				scheduler:unscheduleScriptEntry(self.hander_reset_ex)
				self.hander_reset_ex = nil
			end

			self.time_reset_ex = 1
			local function resetExploreTimerCB(dt)
				self.time_reset_ex = self.time_reset_ex - 1
				if self.time_reset_ex <= 0 then
					self.time_reset_ex = 0
					if self.hander_reset_ex then
						scheduler:unscheduleScriptEntry(self.hander_reset_ex)
						self.hander_reset_ex = nil

						local team_data = getGameData():getTeamData()
						if not team_data:isInTeam() or team_data:isTeamLeader() then -- 组队情况下，不触发战斗任务的完成和战斗
						   --任务到港，不弹框
						    local mission_data_handler = getGameData():getMissionData()
						    mission_data_handler:askIfHaveBattle(nil, goalId)
						    local is_mission_to_port = mission_data_handler:enterBattlePort(goalId)
						    if is_mission_to_port then return end
						end
						
						EventTrigger(EVENT_EXPLORE_SHOW_PORT_INFO, uid)
					end
				end
			end
			self.hander_reset_ex = scheduler:scheduleScriptFunc(resetExploreTimerCB, 0.1, false)
			EventTrigger(EVENT_EXPLORE_MYSHIP_PAUSE)
		elseif pveType == EX_PVE_TYPE_STRONGHOLD then
			EventTrigger(EVENT_EXPLORE_MYSHIP_PAUSE)
		end
	end

	self:clearOpponentData()
end 

--接收单个港口关卡信息
function portPveData:receivePortInfo(portInfo)
	portInfo.fromServer = true
	self.portInfoDics[portInfo.portId] = portInfo

	if self:isPortOpen(portInfo.portId) then
		self.openPortInfoDics[portInfo.portId] = portInfo
	else
		self.openPortInfoDics[portInfo.portId] = nil
	end

	local cpInfo = self:getPortCpInfo(portInfo.checkpointId)
	if not cpInfo then
		portInfo.enemy_power = 0
	else
		local isMeetLevel,_ = self:isPortMeetLevel(portInfo.portId)
		if not isMeetLevel then
			portInfo.enemy_power = cpInfo.stepInfos[1].fightData.power
		elseif self:canFightPort(portInfo.portId) then
			portInfo.enemy_power = cpInfo.stepInfos[portInfo.step+1].fightData.power
		else
			portInfo.enemy_power = cpInfo.stepInfos[1].fightData.power
		end
	end

	if self:isPortFree(portInfo.portId) then
		local mapAttrs = getGameData():getWorldMapAttrsData()
		mapAttrs:setPortStatus(portInfo.portId, PORT_STATUS_ZHANLING)
	end

	EventTrigger(EVENT_PORT_PVE_CPDATA_PORT_UPDATE, portInfo.portId)
	EventTrigger(EVENT_EXPLORE_PVE_CPDATA_PORT_UPDATE, portInfo.portId)
end

--接收单个海上据点关卡信息
function portPveData:receiveStrongHoldInfo(strongHoldInfo)
	strongHoldInfo.fromServer = true
	strongHoldInfo.coolCD = 0
	self.strongHoldInfoDics[strongHoldInfo.strongholdId] = strongHoldInfo

	if self:isStrongHoldOpen(strongHoldInfo.strongholdId) then
		self.openShInfoDics[strongHoldInfo.strongholdId] = strongHoldInfo
	elseif self:isStrongHoldCool(strongHoldInfo.strongholdId) then
		local curTime = os.time()
		-- local curHour = tonumber(os.date("%H",curTime))
		-- local curMin = tonumber(os.date("%M",curTime))
		-- local curSec = tonumber(os.date("%S",curTime))

		-- if curHour <= self.cdCheckPoint1Hour then
		-- 	strongHoldInfo.coolCD = self.cdCheckPoint1Hour*60*60 - (curHour*60*60 + curMin*60 + curSec)
		-- elseif curHour <= self.cdCheckPoint2Hour then
		-- 	strongHoldInfo.coolCD = self.cdCheckPoint2Hour*60*60 - (curHour*60*60 + curMin*60 + curSec)
		-- else
		-- 	strongHoldInfo.coolCD = self.cdCheckPoint3Hour*60*60 - (curHour*60*60 + curMin*60 + curSec)
		-- end

		strongHoldInfo.coolCD = strongHoldInfo.remainTime + curTime

		self.openShInfoDics[strongHoldInfo.strongholdId] = strongHoldInfo
	elseif self:isStrongHoldImmortal(strongHoldInfo.strongholdId) then
		self.openShInfoDics[strongHoldInfo.strongholdId] = strongHoldInfo
	else
		self.openShInfoDics[strongHoldInfo.strongholdId] = nil
	end

	local cpInfo = self:getStrongHoldCpInfo(strongHoldInfo.strongholdId)
	if not cpInfo then
		strongHoldInfo.enemy_power = 0
	else
		local isMeetLevel,_ = self:isStrongHoldMeetLevel(strongHoldInfo.strongholdId)
		if not isMeetLevel then
			strongHoldInfo.enemy_power = cpInfo.stepInfos[1].fightData.power
		elseif self:canFightStrongHold(strongHoldInfo.strongholdId) then
			strongHoldInfo.enemy_power = cpInfo.stepInfos[strongHoldInfo.step+1].fightData.power
		elseif self:isStrongHoldLock(strongHoldInfo.strongholdId) then
			strongHoldInfo.enemy_power = cpInfo.stepInfos[1].fightData.power
		else
			strongHoldInfo.enemy_power = cpInfo.stepInfos[1].fightData.power
		end
	end

	EventTrigger(EVENT_PORT_PVE_CPDATA_SH_UPDATE, strongHoldInfo.strongholdId)
	EventTrigger(EVENT_EXPLORE_PVE_CPDATA_SH_UPDATE, strongHoldInfo.strongholdId)
end

--请求所有港口和据点的关卡信息
function portPveData:askAllCpInfo()
	--SERVER_FUNC["rpc_server_checkpoint_all_info"]()
end

--接收所有港口和据点的关卡信息
function portPveData:receiveAllCpInfo(portInfos, strongHoldInfos)
	self:resetData()

	for i=1,#portInfos do
		portInfos[i].fromServer = true
		self.portInfoDics[portInfos[i].portId] = portInfos[i]

		if self:isPortOpen(portInfos[i].portId) then
			self.openPortInfoDics[portInfos[i].portId] = portInfos[i]
		else
			self.openPortInfoDics[portInfos[i].portId] = nil
		end

		local cpInfo = self:getPortCpInfo(portInfos[i].checkpointId)
		if not cpInfo then
			portInfos[i].enemy_power = 0
		else
			local isMeetLevel,_ = self:isPortMeetLevel(portInfos[i].portId)
			if not isMeetLevel then
				portInfos[i].enemy_power = cpInfo.stepInfos[1].fightData.power
			elseif self:canFightPort(portInfos[i].portId) then
				portInfos[i].enemy_power = cpInfo.stepInfos[portInfos[i].step+1].fightData.power
			else
				portInfos[i].enemy_power = cpInfo.stepInfos[1].fightData.power
			end
		end
	end

	for i=1,#strongHoldInfos do
		strongHoldInfos[i].coolCD = 0
		strongHoldInfos[i].fromServer = true
		print("strongholdId", strongHoldInfos[i].strongholdId, strongHoldInfos[i].complete)
		self.strongHoldInfoDics[strongHoldInfos[i].strongholdId] = strongHoldInfos[i]

		if self:isStrongHoldOpen(strongHoldInfos[i].strongholdId) then
			self.openShInfoDics[strongHoldInfos[i].strongholdId] = strongHoldInfos[i]
		elseif self:isStrongHoldCool(strongHoldInfos[i].strongholdId) then
			local curTime = os.time()
			-- local curHour = tonumber(os.date("%H",curTime))
			-- local curMin = tonumber(os.date("%M",curTime))
			-- local curSec = tonumber(os.date("%S",curTime))

			-- if curHour <= self.cdCheckPoint1Hour then
			-- 	strongHoldInfos[i].coolCD = self.cdCheckPoint1Hour*60*60 - (curHour*60*60 + curMin*60 + curSec)
			-- elseif curHour <= self.cdCheckPoint2Hour then
			-- 	strongHoldInfos[i].coolCD = self.cdCheckPoint2Hour*60*60 - (curHour*60*60 + curMin*60 + curSec)
			-- else
			-- 	strongHoldInfos[i].coolCD = self.cdCheckPoint3Hour*60*60 - (curHour*60*60 + curMin*60 + curSec)
			-- end

			strongHoldInfos[i].coolCD = strongHoldInfos[i].remainTime + curTime

			self.openShInfoDics[strongHoldInfos[i].strongholdId] = strongHoldInfos[i]
		elseif self:isStrongHoldImmortal(strongHoldInfos[i].strongholdId) then
			self.openShInfoDics[strongHoldInfos[i].strongholdId] = strongHoldInfos[i]
		else
			self.openShInfoDics[strongHoldInfos[i].strongholdId] = nil
		end

		local cpInfo = self:getStrongHoldCpInfo(strongHoldInfos[i].strongholdId)
		if not cpInfo then
			strongHoldInfos[i].enemy_power = 0
		else
			local isMeetLevel,_ = self:isStrongHoldMeetLevel(strongHoldInfos[i].strongholdId)
			if not isMeetLevel then
				strongHoldInfos[i].enemy_power = cpInfo.stepInfos[1].fightData.power
			elseif self:canFightStrongHold(strongHoldInfos[i].strongholdId) then
				strongHoldInfos[i].enemy_power = cpInfo.stepInfos[strongHoldInfos[i].step+1].fightData.power
			elseif self:isStrongHoldLock(strongHoldInfos[i].strongholdId) then
				strongHoldInfos[i].enemy_power = cpInfo.stepInfos[1].fightData.power
			else
				strongHoldInfos[i].enemy_power = cpInfo.stepInfos[1].fightData.power
			end
		end
	end

	EventTrigger(EVENT_PORT_PVE_CPDATA_ALL_UPDATE, self.portInfoDics, self.strongHoldInfoDics)
	EventTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE, self.portInfoDics, self.strongHoldInfoDics)
end

--请求（抵达港口时）
function portPveData:askArrivePort(checkpointId, callBack)
	self.askArrivePortCallBack = callBack
	GameUtil.callRpc("rpc_server_arrive_checkpoint", {checkpointId}, "rpc_client_arrive_checkpoint")
end

--请求（抵达海上据点时）
function portPveData:askArriveStrongHold(strongholdId, callBack)
	self.askArriveShCallBack = callBack
	GameUtil.callRpc("rpc_server_arrive_stronghold", {strongholdId}, "rpc_client_arrive_stronghold")
end

function portPveData:getOpponentInfo()
	return self.opponentInfo
end

function portPveData:initBattleInfo(id, index)
	self.opponentInfo.battleId = id
	self.opponentInfo.battleIndex = index
	-- TODO:临时处理
	local battle_type_info = require("game_config/battle/battle_type_info")
	self.opponentInfo.battleSid = battle_type_info[id].generalBattle[index]
	self.opponentInfo.enemyPower = self:getGeneralBattlePower(id, index)
end

function portPveData:initOpponentInfo(id, isStrongHold)
	self:clearOpponentData()
	local pveInfo = nil
	local pveName = nil
	local pveType = nil
	local checkPointInfo = nil
	if not isStrongHold then
		pveInfo = self.portInfoDics[id]
		pveType = EX_PVE_TYPE_PORT
		checkPointInfo = self:getPortCpInfo(pveInfo.checkpointId)
		pveName = checkPointInfo.port
	else
		pveInfo = self.strongHoldInfoDics[id]
		pveType = EX_PVE_TYPE_STRONGHOLD
		checkPointInfo = self:getStrongHoldCpInfo(pveInfo.strongholdId) 
		pveName = checkPointInfo.name
	end
	local uid = id
	local nextStep = pveInfo.step + 1
	local fightData = checkPointInfo.stepInfos[nextStep].fightData
	local reward = checkPointInfo.stepInfos[nextStep].reward
	local extReward = checkPointInfo.stepInfos[nextStep].extReward

	if fightData.type == 2 then
		--战役
		self:initBattleInfo(fightData.id, fightData.index)
		self.opponentInfo.isBattle = true
	else
		--海盗
		self.opponentInfo.enemyPower = self:getPiratePower(id)
		self.opponentInfo.isBattle = false
	end

	self.opponentInfo.uid = uid
	self.opponentInfo.pveName = pveName
	self.opponentInfo.pveType = pveType
	self.opponentInfo.step = pveInfo.step
	self.opponentInfo.nextStep = nextStep
	self.opponentInfo.fighterType = battle_config.fight_type_portPve
	self.opponentInfo.complete = pveInfo.complete
	self.opponentInfo.honour = 0
	self.opponentInfo.material = reward.material or {}
	self.opponentInfo.plunder_point = reward.plunderPoint or 0
	self.opponentInfo.reward = reward
	self.opponentInfo.extReward = extReward
	self.opponentInfo.exp =  reward.exp or 0
	self.opponentInfo.cash = reward.silver or 0
	self.opponentInfo.gold = reward.gold or 0
	if  self.opponentInfo.complete==0 then
		self.opponentInfo.exp = self.opponentInfo.exp+(extReward.exp or 0)
		self.opponentInfo.cash = self.opponentInfo.cash+(extReward.silver or 0)
		self.opponentInfo.gold = self.opponentInfo.gold+(extReward.gold or 0)
	end
	--[[print("++++++++++++++++++++pve奖励数据+++++++++++++++++++++++++++")
	print("complete-->",self.opponentInfo.complete)
	print("reward cash",reward.silver,"reward.exp",reward.exp)
	print("extReward cash",extReward.silver,"extReward.exp",extReward.exp)
	print("++++++++++++++++++++pve奖励数据+++++++++++++++++++++++++++")]]

	--体力消耗
	self.opponentInfo.costPower = checkPointInfo["fight_step_"..(nextStep).."_consume"] or 0
	self.opponentInfo.fightData = fightData
	self.opponentInfo.myPower = getGameData():getPlayerData():getBattlePower()
end

function portPveData:askCheckPointFight(type, id, step)
	GameUtil.callRpc("rpc_server_checkpoint_fight", {type, id, step}, "rpc_client_checkpoint_fight")
end

-----------------------------------------------------------------------------------------
-- id：战役大类
-- index：该类战役第几场
-- 获取普通战役数据的难度，策划调表数据
function portPveData:getGeneralBattlePower(id, index)
	local power = 0
	local battleTypeInfo = dataTools:getBattleTypeInfo(id)
	if not battleTypeInfo then
		return power
	end
	if not battleTypeInfo.generalBattle or not battleTypeInfo.generalBattle[index] then
		return power
	end
	local battleId = battleTypeInfo.generalBattle[index]
	local battle_info_config_data = getGameData():getBattleInfoConfigData()
    local battleInfo = dataTools:getFight(battleId, battle_info_config_data.GENERAL_CONFIG)

    if battleInfo then
        power = battleInfo.difficulty or 0
    end

    return power
end

-- id：海盗舰队id
-- 获取海盗战斗数据的难度
function portPveData:getPiratePower(id)
	local pirate_fleet_info = require("game_config/portPve/pve_port_pirate_fleet_info")
	local pirate_info = require("game_config/portPve/pve_port_pirate_info")
	local pirate_fleet = pirate_fleet_info[id]
	local pirate_list = pirate_fleet.pirate_list

	local power = 0
	local boatPowerInfo = {}
	local boatData = getGameData():getBoatData()
	for i, pirate_Id in ipairs(pirate_list) do
		local pirateInfo = pirate_info[pirate_Id]

		boatPowerInfo.fireFar = pirateInfo.gun_value1
		boatPowerInfo.fireClose = pirateInfo.fireClose
		boatPowerInfo.armor = pirateInfo.max_hp
		boatPowerInfo.ship_defense = pirateInfo.ship_defense
		boatPowerInfo.speed = pirateInfo.speed
		power = power + boatData:getBoatFightValue(boatPowerInfo)
	end
	return power
end
-----------------------------------------------------------------------------------------

return portPveData
