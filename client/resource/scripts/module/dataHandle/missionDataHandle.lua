require("module/gameBases")
require("gameobj/mission/missionInfo")
local on_off_info = require("game_config/on_off_info")
local daily_mission = require("game_config/mission/daily_mission")
local ui_word = require("game_config/ui_word")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsMissionBattle = require("gameobj/quene/clsMissionBattle")
local ClsPortRewardMission = require("gameobj/quene/clsPortRewardMission")
local handler = class("MissionData")

function handler:ctor()
	self.curPortSelectMisTab = nil
	self.hotelRewardData = {}
	self.hotelRewardAcccpet = nil
	self.btnClickCompleteDic = {}
	self.isFirstIntoPort = true
	self.hotelFinishTimesNum = 0
	self.is_show_accept_by_chatmission = true
	self.panel_pop_tbl = {}

	self.middlePortMissionStatus = 0

	---悬赏任务在探索界面是否进港
	self.mission_status = 2

	---记录在探索界面接受悬赏任务的port_id
	self.receive_mission_port_id = 0
	self.complated_times = 0  ---悬赏任务完成次数
	self.all_times = 0      ---总的悬赏次数
	self.is_lock_effect = false

	self.auto_mission_status = false ----自动悬赏的状态
	self.auto_mission_times = 0  --自动悬赏次数
	self.auto_select_status = true ---选择自动悬赏的状态

	self.assist_info = {}
end

-- used_count 已使用次数 total_count 总次数
function handler:setAssistInfo(info)
	self.assist_info = info
end

function handler:getAssistInfo()
	return self.assist_info or {}
end

function handler:setEffectSwitch(bool)
	self.is_lock_effect = bool
end

function handler:getEffectSwitch()
	return self.is_lock_effect
end

function handler:setReceiveMissionPortId(port_id)
	self.receive_mission_port_id = port_id
end

function handler:getReceiveMissionPortId()
	return self.receive_mission_port_id
end

function  handler:setMissionStatus(status)
	self.mission_status = status
end

function handler:getMissionStatus()
	return self.mission_status
end

function handler:setPortMissionStatus(middle_status)
	self.middlePortMissionStatus = middle_status
end

function handler:getPortMissionStatus()
	return self.middlePortMissionStatus
end


function handler:askGetMissionReward(missionId)
	if not missionId then
		return
	end

	local missionInfo = self:getMissionInfoById(missionId)
	if missionInfo and missionInfo.status == MISSION_STATUS_COMPLETE_REWARD then
		return
	end
	GameUtil.callRpc("rpc_server_mission_get_reward", {missionId})
end

function handler:getMissionInfo()
	local missionInfo = {}
	local playerData = getGameData():getPlayerData()
	if playerData.missionInfo then
		local mission_info = getMissionInfo()
		for i, v in pairs(playerData.missionInfo) do
			if v.status ~= MISSION_STATUS_COMPLETE_REWARD then -- 过滤完成并领取了奖励的任务
				local mission = mission_info[v.id]
				if mission then
					mission.id = v.id
					mission.status = v.status
					mission.missionProgress = v.missionProgress
					mission.acceptTime = v.acceptTime
					table.insert(missionInfo, mission)
				end
			else
				--cclog("[missionDataHandle:getMissionInfo:任务%d已完全，过滤]", v.id)
			end
		end
	end
	return missionInfo
end

--返回玩家身上的主线任务
function handler:getMainLineMission()
	local missionInfo = self:getMissionInfo()
	if missionInfo then
		for i, v in pairs(missionInfo) do
			local mission = getMissionInfo()[v.id]
			if mission and mission.type and mission.type == ui_word.MAIN_TASK then
				return v.id
			end
		end
	end
end

function handler:dailyMissionGoOn(mission_info)
	local dailyMissionInfo = self:getHotelRewardAccept()
	local data = mission_info
	local goal_port_id = nil
	local mission_attck_pirate = false
	local mission_salve_ship = false
	if data.json_info["portId"] then
		goal_port_id = data.json_info["portId"]
	elseif data.json_info["battleInfo"] then
		mission_attck_pirate = true
		pos_x = data.json_info["battleInfo"]["position_x"]
		pos_y = data.json_info["battleInfo"]["position_y"]
	elseif data.json_info["wreckInfo"] then
		mission_salve_ship = true
		pos_x = data.json_info["wreckInfo"]["position_x"]
		pos_y = data.json_info["wreckInfo"]["position_y"]
	end

	if goal_port_id then
		if isExplore then
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = goal_port_id, navType = EXPLORE_NAV_TYPE_PORT})
			return
		end

		local supplyData = getGameData():getSupplyData()
		supplyData:askSupplyInfo(true, function()
			local mapAttrs = getGameData():getWorldMapAttrsData()

			mapAttrs:goOutPort(goal_port_id, EXPLORE_NAV_TYPE_PORT)
		end)
	end

	if mission_attck_pirate  or mission_salve_ship then

		local explore_type = EXPLORE_NAV_TYPE_REWARD_PIRATE
		if mission_salve_ship then
			explore_type = EXPLORE_NAV_TYPE_SALVE_SHIP
		end

		if isExplore then
			local pos = {pos_x, pos_y}
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {navType = explore_type, pos = pos})
			return
		end

		local supplyData = getGameData():getSupplyData()
		supplyData:askSupplyInfo(true, function()
			local mapAttrs = getGameData():getWorldMapAttrsData()
			local params ={pos = {pos_x, pos_y}}
			mapAttrs:goOutPort(nil, explore_type, nil, nil, params)
		end)
	end
end

-- 处理世界任务模块的数据 转为任务列表模块的数据
function handler:dealAcceptedWorldMissionInfo(missionInfo)
	local info = getGameData():getWorldMissionData():getAcceptedWorldMissionInfo()
	local cfg = require("game_config/world_mission/world_mission_info")
	local twm_cfg = require("game_config/world_mission/world_mission_team")

		-- ['name'] = T('皇室的委托'),
		-- ['type'] = 'explore_event',
		-- ['area'] = 1,
		-- ['star'] = 1,
		-- ['time_limit'] = 21600,
		-- ['position_map'] = {50,16},
		-- ['position_explore'] = {770,246},
		-- ['rewards'] = 'reward_wordmission_31',
		-- ['progress'] = {{"explore_event", {["id"]=5, ["times"]=2}}},
		-- ['mission_txt'] = T('皇室舰队遭到袭击，装有重要文件的宝箱遗落大海，高价悬赏大海的航者寻回。'),
		-- ['mission_target_tips'] = {T("海上打捞宝箱"),"",T("%s个")},
		-- ['mission_accept_dialog'] = {{68,T("皇室市政官"),1,T("我们的皇室舰队遭到海盗袭击，有几个重要宝箱遗落大海，你能帮忙寻找吗？")},{0,"",2,T("宝箱装的是什么好宝贝？")},{68,T("皇室市政官"),1,T("你认为我会告诉你吗？")},{0,"",2,T("……好吧（你认为我不会打开吗）")}},
		-- ['mission_complete_dialog'] = {{68,T("皇室市政官"),1,T("干得好，你是不是偷偷打开了？")},{0,"",2,T("这么轻，一定不是珠宝黄金，没兴趣。")},{68,T("皇室市政官"),1,T("（流汗）那就好……")}},
		-- ['goto_team'] = 0,


	local mission_conf = nil
	if info then mission_conf = cfg[info.id] or twm_cfg[info.id] end
	if mission_conf ~= nil then
		local t = {}
		info.cfg = mission_conf
		t.id =  info.id
		t.complete_sum = {}
		local WM_TYPE = {
			['explore_event'] = 'explore_event',
			['business'] = 'business',
			['battle'] = 'battle',
			['teambattle'] = 'teambattle',
		}
		local _type = info.cfg.type
		if _type == WM_TYPE.explore_event then
			t.complete_sum[1] = info.cfg.progress[1][2].times
			t.info = info
		elseif _type == WM_TYPE.business then
			t.complete_sum[1] = info.cfg.progress[1][2].amount
			t.info = info
		elseif _type == WM_TYPE.battle or _type == WM_TYPE.teambattle then
			t.complete_sum[1] = info.cfg.progress[1][2].times
			t.info = info
		end

		t.missionProgress = {}
		t.missionProgress[1] = {}
		t.missionProgress[1]['value'] = info.progress[1].value

		t.desc = info.cfg.mission_target_tips
		t.name = info.cfg.name

		t.skip_info = {}
		t.type = ui_word.MISSION_WORLD_MISSION -- 随机任务
		t.status = info.status
		t.acceptTime = info.startTime
		self:addMissionInfo(missionInfo,t)
	end
	return missionInfo
end

-- 增加任务
function handler:addMissionInfo(missionInfo,t)
	-- local info = self:getMissionInfo() -- 要修改的啊..为什么每次get都得创建新表 而不存起来.数据有变动的时候再变就行了.
	missionInfo[#missionInfo+1] = t
end

function handler:dealCityChallengeMission(missionInfo)
	local info = getGameData():getCityChallengeData():getCurMissionList()
	if info then
		self:addMissionInfo(missionInfo,info)
	end
	return missionInfo
end

--以后需求新增的任务类型都在下面配置
local MISSION_TBL = {
	["city_challenge"] = {data_func = handler.dealCityChallengeMission},
}

-- 获取所有任务信息
function handler:getMissionAndDailyMissionInfo()
	local missionInfo = self:getMissionInfo()
	local dailyMissionInfo = self:getHotelRewardAccept()
	missionInfo = self:dealAcceptedWorldMissionInfo(missionInfo)

	for _, info in pairs(MISSION_TBL) do
		if info.data_func and type(info.data_func) == "function" then
			missionInfo = info.data_func(self, missionInfo)
		end
	end

	if dailyMissionInfo then
		local dailyMission = require("gameobj/mission/dailyMission")
		local ui_word = require("game_config/ui_word")
		local dailyMissionTable = table.clone(dailyMissionInfo)

		local dailyId = tonumber(dailyMissionTable.missionId) 
		local transformMissionTable
		if dailyId > 0 then
			local missionInfo = daily_mission[dailyId]
			missionInfo.id = dailyMissionTable.id
			missionInfo.amount = dailyMissionTable.amount
			transformMissionTable = dailyMission:transformMissionInfo(missionInfo, dailyMissionTable)
			dailyMissionTable.complete_sum = dailyMissionTable.amount
			dailyMissionTable.complete_describe = transformMissionTable.progressDes
			dailyMissionTable.desc = transformMissionTable.missionTip
			dailyMissionTable.missionProgress = dailyMissionTable.progress
			dailyMissionTable.name = transformMissionTable.name or " "
			dailyMissionTable.completeTips = transformMissionTable.completeTips
			dailyMissionTable.skip_info = missionInfo.skip_info
		else
			--藏宝图不显示在这里
		end
		dailyMissionTable.type = ui_word.DAILY_TASK
		dailyMissionTable.status = dailyMissionTable.status --STATUS_DOING
		dailyMissionTable.target_port_id = dailyMissionTable.id
		dailyMissionTable.id = 0
		dailyMissionTable.acceptTime = self:getHotelRewardAcceptTime()
		self.dailyMissionTable = dailyMissionTable
		missionInfo[#missionInfo + 1] = dailyMissionTable
	end

	local other_mission = self:getOtherMission()
	if type(other_mission) == "table" then
		missionInfo[#missionInfo + 1] = other_mission
	end

	table.sort(missionInfo, function(a, b)
		local mission_priority = {
			[ui_word.MAIN_TASK] = 2,
			[ui_word.BRANCH_TASK] = 1,
			[ui_word.MISSION_SAILOR] = 1,
			[ui_word.DAILY_TASK] = 1,
			[ui_word.TRADE_TASK] = 1,
			[ui_word.RELIC_TASK] = 1,
			[ui_word.MISSION_WORLD_MISSION] = 1,
			[ui_word.CITY_TASK] = 1,
		}
		if mission_priority[a.type] ~= mission_priority[b.type] then
			return mission_priority[a.type] > mission_priority[b.type]
		else
			a.priority = a.priority or 0
			b.priority = b.priority or 0
			if a.acceptTime == b.acceptTime then
				return a.priority > b.priority
			else
				return a.acceptTime > b.acceptTime
			end
		end
	end)

	return missionInfo
end

function handler:insertOtherMission(info)
	local temp = {}
	temp.complete_sum = info.complete_sum --完成数量-总进度
	temp.complete_describe = {}
	temp.complete_describe[1] = info.complete_describe --完成条件
	temp.desc = info.desc  --描述
	temp.skip_info = info.skip_info --跳转
	temp.name = info.name --名字
	temp.type = info.type --类型
	temp.acceptTime = info.acceptTime --接受时间
	temp.status = info.status --状态
	temp.missionProgress = info.missionProgress --实际进度
	self.other_mission = temp
end

function handler:getOtherMission()
	return self.other_mission
end

function handler:clearOtherMission()
	self.other_mission = nil
end

-- 得到完成任务的任务表
function handler:getCompleteMissionInfo()
	local completeInfo = {}
	local mission_info = getMissionInfo()
	local playerData = getGameData():getPlayerData()
	for i, v in pairs(playerData.missionInfo) do
		if v.status ~= MISSION_STATUS_DOING then
			local mission = mission_info[v.id]
			mission.id = v.id
			mission.status = v.status
			mission.missionProgress = v.missionProgress
			mission.acceptTime = v.acceptTime
			table.insert(completeInfo, mission)
		end
	end
	return completeInfo
end

function handler:isShowMissionPlot()
	local playerData = getGameData():getPlayerData()

	if playerData.missionInfo == nil then return false end

	local mission_info = getMissionInfo()
	for i, v in pairs(playerData.missionInfo) do
		if v.status == MISSION_STATUS_DOING and mission_info[v.id] and mission_info[v.id].show_plot == 1 then
			return true
		end
	end

	return false
end

-- 得到正在做的任务
function handler:getDoingMissionInfo()
	local playerData = getGameData():getPlayerData()
	if playerData.missionInfo == nil then
		cclog(T("任务信息为空"))
	end
	local doingMission = {}
	local mission_info = getMissionInfo()
	for i, v in pairs(playerData.missionInfo) do
		if v.status == MISSION_STATUS_DOING then
			local mission = mission_info[v.id]
			mission.id = v.id
			mission.status = v.status
			mission.missionProgress = v.missionProgress
			mission.acceptTime = v.acceptTime
			table.insert(doingMission, mission)
		end
	end

	local function sortMission(a,b)
		return a.id>b.id
	end

	table.sort(doingMission, sortMission)

	return doingMission
end

function handler:getDoingMissionId()
	local playerData = getGameData():getPlayerData()
	if playerData.missionInfo == nil then
		cclog(T("任务信息为空"))
	end
	local doingMissionId = {}
	for i, v in pairs(playerData.missionInfo) do
		if v.status == MISSION_STATUS_DOING then
			table.insert(doingMissionId,  v.id)
		end
	end

	local function sortMission(a,b)
		return a>b
	end

	table.sort(doingMissionId, sortMission)

	return doingMissionId
end

function handler:getPlayerMissionInfo()
	local playerMission = {}
	local mission_info = getMissionInfo()
	local playerData = getGameData():getPlayerData()
	for i, v in pairs(playerData.missionInfo) do
		local mission = mission_info[v.id]
		mission.id = v.id
		mission.status = v.status
		mission.missionProgress = v.missionProgress
		mission.acceptTime = v.acceptTime
		table.insert(playerMission, mission)
	end
	return playerMission
end

function handler:isMissionDoing(missionId)
	if not missionId then
		return false
	end
	local playerData = getGameData():getPlayerData()
	local missionInfo = playerData.missionInfo[missionId]

	if missionInfo and missionInfo.status == MISSION_STATUS_DOING then
		return true
	end

	return false
end

function handler:setSelectMissionId(missionId)
	self.selectiID = missionId
end

function handler:getSelectMissionId()
	return self.selectiID
end

function handler:getMissionInfoById(missionId)
	if not missionId then
		return nil
	end
	local playerData = getGameData():getPlayerData()
	local missionInfo = playerData.missionInfo[missionId]

	return missionInfo
end

--任务ID，港口索引
function handler:setPortSelectMisId(missionId, guideIndex)
	if missionId~=nil then
		cclog(T("===================================设置任务港口导航数据 missionId=")..missionId)
	else
		cclog(T("===================================设置任务港口导航数据 missionId=nil"))
	end
	self.curPortSelectMisTab = {missionId = missionId, guideIndex = guideIndex}
end

function handler:getPortSelectMisId()
	return self.curPortSelectMisTab
end

function handler:getIsFirstIntoPort()
	local isFirstIntoPort = self.isFirstIntoPort
	self.isFirstIntoPort = false
	return isFirstIntoPort
end

function handler:getHotelFinishTimesNum()
	return self.hotelFinishTimesNum
end

function handler:setHotelFinishTimesNum(value)
	self.hotelFinishTimesNum = value
end

--前端触发完成
function handler:receiveClientComplete(missionId, status)
	local mission_info = getMissionInfo()
	if not mission_info[missionId] then
		return
	end

	local complete_client = mission_info[missionId].complete_client
	if not complete_client then
		return
	end

	if complete_client[1]=="btnClick" then
		self:receiveBtnClickComplete(complete_client[2], missionId, status)
	end
end

local btnNameToKeyValue = {}
--点击触发完成
function handler:receiveBtnClickComplete(onOffName, missionId, status)
	local onOffkey = btnNameToKeyValue[onOffName]
	if onOffkey == nil then
		for k, v in pairs(on_off_info) do
			if v.name == onOffName then
				onOffkey = v.value
				btnNameToKeyValue[onOffName] = v.value
				break
			end
		end
	end

	if status == STATUS_DOING then
		self:openBtnClickComplete(onOffkey, missionId)
	else
		self:closeBtnClickComplete(onOffkey, missionId)
	end
end

function handler:openBtnClickComplete(onOffkey, missionId)
	--cclog("===============================openBtnClickComplete key="..onOffkey.." missionId="..missionId)
	if self.btnClickCompleteDic[onOffkey] == nil then
		self.btnClickCompleteDic[onOffkey] = {isLock=false, misNum=0, misDic={}}
	end

	local btnClickCompleteInfo = self.btnClickCompleteDic[onOffkey]
	if not btnClickCompleteInfo.misDic[missionId] then
		btnClickCompleteInfo.misDic[missionId] = true
		btnClickCompleteInfo.misNum = btnClickCompleteInfo.misNum + 1
	end
end

function handler:closeBtnClickComplete(onOffkey, missionId)
	if self.btnClickCompleteDic[onOffkey] == nil then
		return
	end
	--cclog("===============================closeBtnClickComplete key="..onOffkey.." missionId="..missionId)

	local btnClickCompleteInfo = self.btnClickCompleteDic[onOffkey]
	if btnClickCompleteInfo.misDic[missionId] then
		btnClickCompleteInfo.misDic[missionId] = nil
		btnClickCompleteInfo.misNum = btnClickCompleteInfo.misNum - 1

		if btnClickCompleteInfo.misNum < 0 then
			btnClickCompleteInfo.misNum = 0
		end
	end

	self:unLockBtnClickComplete(onOffkey)
end

function handler:lockBtnClickComplete(onOffkey)
	if self.btnClickCompleteDic[onOffkey] == nil then
		return
	end

	local btnClickCompleteInfo = self.btnClickCompleteDic[onOffkey]
	btnClickCompleteInfo.isLock = true
end

function handler:unLockBtnClickComplete(onOffkey)
	if self.btnClickCompleteDic[onOffkey] == nil then
		return
	end

	local btnClickCompleteInfo = self.btnClickCompleteDic[onOffkey]
	btnClickCompleteInfo.isLock = false
end

function handler:isLockBtnClickComplete(onOffkey)
	if self.btnClickCompleteDic[onOffkey] == nil then
		return false
	end

	return self.btnClickCompleteDic[onOffkey].isLock
end

function handler:hasBtnClickComplete(onOffkey)
	if self.btnClickCompleteDic[onOffkey] == nil then
		return false
	end

	local btnClickCompleteInfo = self.btnClickCompleteDic[onOffkey]
	if btnClickCompleteInfo.misNum > 0 then
		return true
	end

	return false
end

function handler:askBtnClickComplete(onOffkey)
	GameUtil.callRpc("rpc_server_click_button", {onOffkey},"rpc_client_click_button")
end

-- 客户端完成条件
function handler:tryBtnClickComplete(onOffkey)
	if self:hasBtnClickComplete(onOffkey) == true and self:isLockBtnClickComplete() == false then
		self:lockBtnClickComplete(onOffkey)
		self:askBtnClickComplete(onOffkey)
	end
end

--悬赏任务
function handler:getDailyMissionInfo()
	local playerData = getGameData():getPlayerData()
	return playerData.dailyMissionInfo
end

function handler:setHotelRewardMissionInfo(rewardData)
	self.hotelRewardData = rewardData
end

function handler:getHotelRewardMissionInfo()
	return self.hotelRewardData
end

function handler:setHotelRewardAccept(rewardData)
	self.hotelRewardAcccpet = rewardData
end

function handler:getHotelRewardAccept()
	return self.hotelRewardAcccpet
end

function handler:getHotelRewardAcceptStatus()
	if self.hotelRewardAcccpet and (self.hotelRewardAcccpet.status == 1 or self.hotelRewardAcccpet.status == 2) then
		print("====getHotelRewardAcceptStatus=======", self.hotelRewardAcccpet.status)
		return true
	else
		return false
	end
end

function handler:getMissionTypeName(missionType)
	for k, v in ipairs(daily_mission) do
        if v.mission_type == missionType then
            local mission_name = v.mission_name
            if mission_name then
                return tostring(mission_name[#mission_name])
            end
        end
    end
	return "nil"
end

--刷新悬赏任务难度
function handler:refreshDifficulty()
	GameUtil.callRpc("rpc_server_refresh_mission_difficulty", {}, "rpc_client_refresh_mission_difficulty")
end

--放弃悬赏任务
function handler:giveUpMission()
	GameUtil.callRpc("rpc_server_cancel_daily_mission", {}, "rpc_client_cancel_daily_mission")
end

--用金币刷新，悬赏任务
function handler:refreshTaskByGold()
	GameUtil.callRpc("rpc_server_refresh_mission_by_gold", {}, "rpc_client_refresh_mission_by_gold")
end

--钻石刷新，悬赏任务
function handler:refreshTaskByDiamond(is_free)
	GameUtil.callRpc("rpc_server_refresh_mission", {is_free}, "rpc_client_refresh_mission")
end

--接受悬赏任务
function handler:acceptMission(index, port_id)
	cclog(T("接受index = %s"), index)
	GameUtil.callRpc("rpc_server_accept_daily_mission", {index, port_id}, "rpc_client_accept_daily_mission")
end

--自动悬赏接受任务
function handler:acceptAutoMission(index, port_id)
	GameUtil.callRpc("rpc_server_auto_bounty", {index, port_id})---, "rpc_client_auto_bounty"
end

--领取奖励
function handler:getRewardMission()
	GameUtil.callRpc("rpc_server_get_daily_mission_reward", {}, "rpc_client_get_daily_mission_reward")
end

---增加悬赏任务的次数
function handler:addMissionNums(times)
	GameUtil.callRpc("rpc_server_add_accept_times", {times}, "rpc_client_add_accept_times")
end

---悬赏弹框
function handler:askTaskTipsStatus(tips_status)
	GameUtil.callRpc("rpc_server_accept_mission_pop_window", {tips_status}, "rpc_client_accept_mission_pop_window")
end

---组队悬赏探索界面协议
function handler:askTeamMissionComplateStatus(port_id)
	GameUtil.callRpc("rpc_server_team_bounty_special_handle", {port_id}, "rpc_client_team_bounty_special_handle")
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	if auto_trade_data:inAutoTradeAIRun() then--自动委任AI中，不进港
		auto_trade_data:addTradeLog("send rpc_server_team_bounty_special_handle port is:" .. port_id)--加log
		EventTrigger(EVENT_PORT_TRADE_RPC_PORT, port_id)
	end
end

---悬赏探索沉船
function handler:askMissionSeaBoat(mission_type, is_win)
	GameUtil.callRpc("rpc_server_bounty_explore_event_end", {mission_type, is_win}, "rpc_client_bounty_explore_event_end")
end

---取消自动悬赏
function handler:askCancelAutoBounty()
	GameUtil.callRpc("rpc_server_cancel_auto_bounty", {}, "rpc_client_cancel_auto_bounty")
end

--1.是vip玩家，
--2.自动悬赏次数 >0
--3.开关
----自动悬赏开启的条件
function handler:isAutoPortRewardStatus()
	local playerData = getGameData():getPlayerData()
	local player_is_vip = playerData:isVip()

	local onOffData = getGameData():getOnOffData()
	local on_off_info=require("game_config/on_off_info")

	--local auto_mission_times = self:getAutoMissionTimes()

	local is_auto_mission = false
	--print("-----------自动悬赏开启的条件-------",onOffData:isOpen(on_off_info.AUTO_TREAT.value) ,player_is_vip ,auto_mission_times)
	if onOffData:isOpen(on_off_info.AUTO_TREAT.value) and player_is_vip then
		is_auto_mission = true
	end

	return is_auto_mission
end

function handler:setSelectAutoMission(status)
	self.auto_select_status = status
end

function handler:getSelectAutoMission(  )
	return self.auto_select_status
end

function handler:getAutoPortRewardStatus(  )
	return self.auto_mission_status
end

function handler:setAutoPortRewardStatus(status)
	self.auto_mission_status = status
end

---自动悬赏的次数
function handler:setAutoMissionTimes(times)
	self.auto_mission_times = times
end

function handler:getAutoMissionTimes()
	return self.auto_mission_times
end

---弹框状态
function handler:setWindowTipsStatus(flag)
	self.is_open = flag
end

function handler:getWindowTipsStatus()
	return self.is_open
end
--悬赏任务
function handler:getHotelRewardNums()
	return self.hotelRewardNums --{time = 1, token = 3, gold = 1}
end

function handler:setHotelRewardNumbers(nums)
	self.hotelRewardNums = nums
end

---悬赏完成次数（藏宝图奖励有关）
function handler:setComplatedTimes(nums,all_times)
	self.complated_times = nums
	self.all_times = all_times
end
function handler:getComplatedTimes()
	return self.complated_times, self.all_times
end

---悬赏任务免费的次数
function handler:setHotelFreeNumbers(nums)
	self.hotelFreeNums = nums
end

function handler:getHotelFreeNumbers()
	return self.hotelFreeNums
end

--悬赏任务接受时间
function handler:getHotelRewardAcceptTime()
	local time = self.acceptTime or 0
	return time
end

function handler:setHotelRewardAcceptTime(time)
	self.acceptTime = time
end

--悬赏任务10次数量
function handler:getHotelRewardTenNums()
	local num = self.tenNums or 0
	return num
end

function handler:setHotelRewardTenNums(times)
	self.tenNums = times
end

--获取任务的描述
function handler:getMissionTaskByType(data, missionConfig, index)
	local port_info = require("game_config/port/port_info")
	local goods_info = require("game_config/port/goods_info")
    local tips = ""
    local json_info = data.json_info
    local missionDesc = missionConfig.mission_desc
    local desc = missionDesc[index]
    --cclog("=============   %s", desc)
    if missionConfig.mission_type == "business" then
        tips = string.format(desc, tostring(json_info.profit))
    elseif missionConfig.mission_type == "port" then
        tips = desc
    elseif missionConfig.mission_type == "shopping"  then
        local name = goods_info[json_info.goodsId].name
        tips = string.format(desc, name)
    elseif missionConfig.mission_type == "battle" then
    	local battle_info_config_data = getGameData():getBattleInfoConfigData()
        local battle_info = battle_info_config_data:getBattleConfigFileInfo()[json_info.battleId]
        tips = string.format(desc, battle_info.name)
    elseif missionConfig.mission_type == "plunder" then
        tips = desc
    elseif missionConfig.mission_type == "upgrade" then
        tips = desc
    elseif missionConfig.mission_type == "sellgoods" then
        local name = port_info[json_info.portId].name
        tips = string.format(desc, name)
    elseif missionConfig.mission_type == "sailor" then
        tips = desc
    elseif missionConfig.mission_type == "boat" then
        tips = desc
    elseif missionConfig.mission_type == "enlistsailors" then
        tips = desc
    elseif missionConfig.mission_type == "portshop" then
        tips = desc
    end

    return tips
end

function handler:completeHotelRewardInfo(info)
	self.completeInfo = info
end

function handler:getCompleteHotelRewardInfo()
	return self.completeInfo
end

function handler:StartMissionInfo(info)
	self.startMissionInfo = info
end

function handler:getStartMissionInfo()
	return self.startMissionInfo
end

function handler:resetData()
end

--悬赏任务完成
function handler:alertHotelRewardCompletedView(missionId, rewards)
	
	local tempMissionInfo = self:getCompleteHotelRewardInfo()
	local team_data = getGameData():getTeamData()
	if  team_data:isInTeam() and not team_data:isTeamLeader() then
		return
	end
	ClsDialogSequene:insertTaskToQuene(ClsPortRewardMission.new({missionId = missionId, isEnd = true, reward = rewards, missionInfo = tempMissionInfo}))
end

---悬赏任务完成第一步
function handler:alertMissionUncompletedView(missionId)
	local tempMissionInfo = self:getCompleteHotelRewardInfo()
	local team_data = getGameData():getTeamData()
	if  team_data:isInTeam() and not team_data:isTeamLeader() then
		return
	end
	ClsDialogSequene:insertTaskToQuene(ClsPortRewardMission.new({missionId = missionId, isEnd = false, reward = nil, missionInfo = tempMissionInfo}))
end

function handler:setHotelMissionCompletedInfo(missionInfo)
	self.hotelMissionInfo = missionInfo
end

function handler:getHotelMissionCompletedInfo(missionInfo)
	return self.hotelMissionInfo
end

function handler:isShowAcceptByChatMission()
	return self.is_show_accept_by_chatmission
end

function handler:clearShowAcceptByChatMission()
	self.is_show_accept_by_chatmission = false
end

function handler:saveClickMissionID(mission_id)
	self.click_mission_id = mission_id
end
function handler:getClickMissionID()
	local id = self.click_mission_id
	self.click_mission_id = nil
	return id
end

--获取任务特殊船
function handler:getMissionSpecialBoatId()
	local mission_special_boat_id = nil
	local mission_list = self:getMissionInfo()
	for i,v in ipairs(mission_list) do
		if v.special_boat > 0 then
			mission_special_boat_id = v.special_boat
		end
	end
	return mission_special_boat_id
end

--获取强制新手流程任务
function handler:getMissionGuideId()
	local mission_guide_id = 0
	local mission_ship_id = 0
	local mission_list = self:getMissionInfo()
	for i,v in ipairs(mission_list) do
		if v.fomation_click > 0 or v.fomation_click_ship > 0 then
			mission_guide_id = v.fomation_click
			mission_ship_id = v.fomation_click_ship
		end
	end
	return mission_guide_id, mission_ship_id
end

ERROR_NOT_OPEN = 460
ERROR_NOT_INVEST = 459

--判断跳转的页面对应的功能有没有打开
function handler:getSkipIsOpen(skip_name)
	local onOffData = getGameData():getOnOffData()
	if skip_name == "guild" then
		return onOffData:isOpen(on_off_info.PORT_UNION.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "friend" then
		return onOffData:isOpen(on_off_info.MAIN_FRIEND.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "fight" then
		return onOffData:isOpen(on_off_info.PORT_QUAY_FIGHT.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "guild_task" then
		return onOffData:isOpen(on_off_info.PORT_HOTEL_TREAT.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "arena" then
		return onOffData:isOpen(on_off_info.PORT_QUAY_JJC.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "hotelRecruit" then
        return onOffData:isOpen(on_off_info.PORT_HOTEL.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "shipyard_shop" then
        return onOffData:isOpen(on_off_info.PORT_SHIPYARD.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "market" then
        return onOffData:isOpen(on_off_info.PORT_MARKET.value) or false, ERROR_NOT_OPEN
	elseif skip_name == "shipyard_shop" then
        return onOffData:isOpen(on_off_info.PORT_SHIPYARD.value) or false, ERROR_NOT_OPEN
	else
		return true
	end
end

function handler:setMissionCompletedCallBack(call_back)
	if type(call_back) ~= "function" then return end
	self.mission_completed_cb = call_back
end

function handler:getMissionCompletedCallBack()
	return self.mission_completed_cb
end

function handler:clearMissionCompletedCallBack()
	self.mission_completed_cb = nil
end

function handler:clearPlot()
	require("gameobj/mission/missionPlotDialogue"):hidePlotDialog()
    self:clearMissionCompletedCallBack()
end

function handler:gotoMissionBattle(mission_id)
	if getGameData():getAutoTradeAIHandler():inAutoTradeAIRun() then return end
	GameUtil.callRpc("rpc_server_mission_fight", {mission_id})
end

-- 世界尽头特殊处理
function handler:missionNpcHander()
	local mission_list = self:getMissionInfo()
	local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")
	local npc_list = {
		["whirlpool"]  = {is_remove = true, npc_type = exploreNpcType.MISSION_XUANWO, mission_data = nil}, 
		["pirate_npc"] = {is_remove = true, npc_type = exploreNpcType.PLUNDER_MISSION_PIRATE, mission_data = nil}
	}
	for k,v in pairs(mission_list) do
		local explore_pos = v.explore_pos
		if explore_pos and v.sea_pos == 0 then
			if explore_pos.type then
				local npc_item = npc_list[explore_pos.type]
				if npc_item and v.status ~= MISSION_STATUS_COMPLETE then
					npc_item.is_remove = false
					npc_item.mission_data = table.clone(explore_pos)
				end
			end
		end
	end
	
	local exploreNpcData = getGameData():getExploreNpcData()
	for k, v in pairs(npc_list) do
		local npc_id = exploreNpcType.NPC_CUSTOM_ID[v.npc_type]
		if v.is_remove then
			exploreNpcData:removeNpc(npc_id)
		elseif not exploreNpcData:hasNpcId(npc_id) then
			if k == "whirlpool" then
				local attr = {sea_pos = {v.mission_data.x, v.mission_data.y}, name = ui_word.MISSION_END_WORLD}
				exploreNpcData:addStandardNpc(npc_id, npc_id, v.npc_type, attr, nil, nil)
			elseif k == "pirate_npc" then
				local attr = v.mission_data.attr
				attr.sea_pos = {v.mission_data.x, v.mission_data.y}
				exploreNpcData:addStandardNpc(npc_id, npc_id, v.npc_type, attr, nil, nil)
			end
		end
	end
end
--到达世界尽头开启战斗
function handler:completetoEndWorld()
	local mission_list = self:getMissionInfo()
	for k,v in pairs(mission_list) do
		local explore_pos = v.explore_pos
		if explore_pos then
			self:gotoMissionBattle(v.id)
		end
	end
end

--打开特殊界面
function handler:checkOpenPanel(missionId)
	local mission_conf = getMissionInfo()
	if mission_conf[missionId].accept_mission_popup > 0 then
	    local skipToLayer = require("gameobj/mission/missionSkipLayer")
	    local port_layer = getUIManager():get("ClsPortLayer")
	    if not tolua.isnull(port_layer) then
	        local ClsDialogLayer = require("ui/dialogLayer")
	        ClsDialogLayer:hideDialog()
	        if not tolua.isnull(port_layer.portItem) then
	            port_layer.portItem:removeFromParentAndCleanup(true)
	            port_layer.portItem = nil
	        end

	        local skip_key = skipToLayer:getSkipName(missionId)
	        local skipMissLayer = skipToLayer:skipLayerByName(skip_key)
	        port_layer:addItem(skipMissLayer)
	    end
	end
end

--开启任务战斗
function handler:askIfHaveBattle(mission_id, port_id)
	if getGameData():getAutoTradeAIHandler():inAutoTradeAIRun() or self:getAutoPortRewardStatus() then return end

	local mission_list = self:getMissionInfo()
	if port_id then
		for k,v in pairs(mission_list) do
			if v.ask_battle == port_id and v.status == 1 then
				ClsDialogSequene:insertTaskToQuene(ClsMissionBattle.new({func = function()
					self.mission_battle_port = v.ask_battle
					self:gotoMissionBattle(v.id)
				end}))
			end
		end
		return
	end

	local target_mission = nil
	for k,v in pairs(mission_list) do
		local port_layer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(port_layer)  then  --判断是否在港口
			local port_data = getGameData():getPortData()
			local port_id = port_data:getPortId() -- 当前港口
			--在港口情况下，判断战斗港口和本港口一样发送战斗协议
			if v.id == mission_id and tonumber(v.ask_battle) == port_id and v.status == 1 then
				ClsDialogSequene:insertTaskToQuene(ClsMissionBattle.new({func = function()
					self.mission_battle_port = v.ask_battle
					self:gotoMissionBattle(mission_id)
				end}))
			end
			return
		end
		if v.id == mission_id and tonumber(v.ask_battle) > 1 and v.status == 1 and
			v.have_plot_battle == 1
			then
			ClsDialogSequene:insertTaskToQuene(ClsMissionBattle.new({func = function()
					self.mission_battle_port = v.ask_battle
					self:gotoMissionBattle(mission_id)
			end}))
		end
	end
end

function handler:enterBattlePort(port_id)
	if getGameData():getAutoTradeAIHandler():inAutoTradeAIRun() or self:getAutoPortRewardStatus() then return end
	
	local mission_list = self:getMissionInfo()
	for k,v in pairs(mission_list) do
		if port_id == v.enter_battle_port then
			GameUtil.callRpc("rpc_server_port_arrive", {port_id})
			return true
		end
		if v.special_askbattle and v.special_askbattle > 0 then
			GameUtil.callRpc("rpc_server_port_arrive", {port_id})
			return false
		end
	end
end

function handler:isMissionEnterBattlePort(port_id)
	local mission_list = self:getMissionInfo()
	for k,v in pairs(mission_list) do
		if port_id == v.enter_battle_port then
			return true
		end
	end
end

function handler:getMissionBattlePort()
	return self.mission_battle_port
end

--比较两个任务的大小
--return -1 m_1小于m_2, 0 等于, 1 大于
function handler:comparemMissionIdSize(m_1, m_2)
    if not m_1 then return -1 end
    if not m_2 then return 1 end
    
    local mission_1_tab = string.split(m_1, "_")
    local mission_2_tab = string.split(m_2, "_")

    for k, v in ipairs(mission_1_tab) do
        if tonumber(mission_2_tab[k]) < tonumber(v) then
            return 1
        elseif tonumber(mission_2_tab[k]) > tonumber(v) then
            return -1
        end
    end

    if #mission_1_tab < #mission_2_tab then return -1 end

    return 0
end

function handler:getMissionRewardList(rewards)
	local reward_convert_tbl = {
		gold = {res = "common_icon_diamond.png"},
		royal = {res = "common_icon_honour.png"},
		honour = {res = "common_icon_honour.png"},
		silver = {res = "common_icon_coin.png"},
		exp = {res = "common_icon_exp.png"},
		power = {res = "common_icon_power.png"},
		promote = {res = "bo_load.png"},
		starcrest = { res = "common_item_medal.png"},
		trearuse = {res = "common_item_trearusemap.png"}, 
		shipyard_map = {res = "common_item_letter.png"},
		rum = {res = "common_icon_honour.png"},
		boat = {res = "common_icon_elite.png"},
	}
	local temp = {}
	for reward_name, account in pairs(rewards) do
		if reward_convert_tbl[reward_name] then
			if reward_name == "boat" then
				account = 1
			end
			table.insert(temp, {res = reward_convert_tbl[reward_name].res, num = account})
		end
	end
	local function sortReward(v1, v2)
		return tonumber(v1.num) > tonumber(v2.num)
	end
	table.fsort(temp, sortReward)
	return temp
end

function handler:addPanel2List(panel_name)
	if not panel_name then return end
	self.panel_pop_tbl[panel_name] = true
end

function handler:autoPopPanelView()
	local skipToLayer = require("gameobj/mission/missionSkipLayer")
	for layerName, _ in pairs(self.panel_pop_tbl) do
		skipToLayer:skipLayerByName(layerName)
	end
	self.panel_pop_tbl = {}
end

return handler