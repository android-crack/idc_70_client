require("gameobj/mission/missionInfo")

local Alert =  require("ui/tools/alert")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsMissionPlot = require("gameobj/quene/clsMissionPlot")
local ClsShipRewardPop = require("gameobj/quene/clsShipRewardPop")
local ClsChapterMissionPop = require("gameobj/quene/clsChapterMissionPop")
local ClsNewBieMissionPop = require("gameobj/quene/clsNewBieMissionPop")
local ClsPortRewardMission = require("gameobj/quene/clsPortRewardMission")
local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
local ui_word = require("game_config/ui_word")
local error_info = require("game_config/error_info")
local dailyMission = require("gameobj/mission/dailyMission")
local on_off_info=require("game_config/on_off_info")
local mission_to_sailor = require("game_config/sailor/mission_to_sailor")
local info_sailor_mission =  require("game_config/sailor/info_sailor_mission")
local ClsExploreShipWrecksPoint = require("gameobj/explore/clsExploreShipWrecksPoint") --沉船图标刷新


function rpc_client_mission_info(missionInfo)
	local mission_conf = getMissionInfo()
	local missionId = missionInfo.missionId
	if not missionId or not mission_conf[missionId] then return end

	local playerData = getGameData():getPlayerData()
	local missionDataHandler = getGameData():getMissionData()
	local exploreMapData = getGameData():getExploreMapData()
	local result = playerData:receiveMissionInfo(missionInfo)
	if result == DATA_DEAL_RESULT_SUCC then
		missionDataHandler:receiveClientComplete(missionInfo.missionId, missionInfo.status)
		exploreMapData:updateTaskPortSh()
		local ExploreMap = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
		if not tolua.isnull(ExploreMap) then
			EventTrigger(EVENT_MISSION_UPDATE)
		end

		EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)
	end
	--特殊任务直接打开某个界面
	if missionInfo.status == MISSION_STATUS_DOING then
		missionDataHandler:checkOpenPanel(missionInfo.missionId)
	end

	--世界尽头
	missionDataHandler:missionNpcHander()
	--开启任务战斗
	missionDataHandler:askIfHaveBattle(missionInfo.missionId)
	
	if missionInfo.status ~= MISSION_STATUS_COMPLETE_REWARD then
	    local port_data = getGameData():getPortData()
	    port_data:trySetPortPowerInfo()
	    port_data:showPowerChangeEffect()
	    EventTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE_STATUS)
	end
end

function rpc_client_mission_all_info(missionInfos)
	local result = nil
	local hasExce = nil
	local playerData = getGameData():getPlayerData()
	local missionDataHandler = getGameData():getMissionData()
	local exploreMapData = getGameData():getExploreMapData()
	local mission_conf = getMissionInfo()

	for k,v in ipairs(missionInfos) do
		if v.missionId and mission_conf[v.missionId] then
			result = playerData:receiveMissionInfo(v)
			if result == DATA_DEAL_RESULT_SUCC then
				missionDataHandler:receiveClientComplete(v.missionId, v.status)
			else
				hasExce = true
			end
		end
	end
	if not hasExce then
		exploreMapData:updateTaskPortSh()
		local ExploreMap = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
		if not tolua.isnull(ExploreMap) then
			EventTrigger(EVENT_MISSION_UPDATE)
		end
		EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)

	end
	--世界尽头
	missionDataHandler:missionNpcHander()

	local port_data = getGameData():getPortData()
	port_data:trySetPortPowerInfo()
	EventTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE_STATUS)
end

function rpc_client_mission_accept(missionId)
	local mission_conf = getMissionInfo()
	if not missionId or not mission_conf[missionId] then return end

	local NEW_BIE_TAG = 2
	local mission_data_handler = getGameData():getMissionData()
	local mission_info = getMissionInfo()

	if type(missionId) == "number" and mission_info[missionId] and mission_info[missionId].camp then
		mission_data_handler:setSelectMissionId(missionId)
	end

	if mission_info[missionId].chapter_type and mission_info[missionId].chapter_type == NEW_BIE_TAG then
		ClsDialogSequence:insertTaskToQuene(ClsNewBieMissionPop.new())
	elseif mission_info[missionId].chapter_type and mission_info[missionId].chapter_type > 0 then
		mission_data_handler:setEffectSwitch(true)
		ClsDialogSequence:insertTaskToQuene(ClsChapterMissionPop.new({id = missionId}))
	end

	--特殊弹任务剧情
	local _type = mission_info[missionId].chapter_type
	if _type and _type == 0 and mission_info[missionId].content ~= '' then
		ClsDialogSequence:insertTaskToQuene(ClsChapterMissionPop.new({id = missionId}))
	end

	ClsDialogSequence:insertTaskToQuene(ClsMissionPlot.new({id = missionId, type = "new"}))

	local playerData = getGameData():getPlayerData()
	local result = playerData:receiveMissionInfo({missionId=missionId, status=STATUS_DOING, progress=0, time=0})
end

function rpc_client_mission_complete(missionId)
	local mission_info = getMissionInfo()
	local mInfo = mission_info[missionId]
	if mInfo == nil then
		cclog("Mission (%d) has no config in mission_info.", missionId)
		return
	end

	local playerData = getGameData():getPlayerData()
	local result = playerData:receiveMissionInfo({missionId=missionId, status=MISSION_STATUS_COMPLETE})

	local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
	ClsGuideMgr:cleanGuide(missionId)

	--如果是在自动寻路到藏宝图时完成任务不会被中断
	local is_break_and_call_resume = false
	if not tolua.isnull(getExploreUI()) then
		is_break_and_call_resume = true
	end
	local sailor_id = mission_to_sailor[missionId]
	local sailor_mission = nil
	local end_mission = nil
	local sailor_mission_count = 0
	if sailor_id then
		sailor_mission = info_sailor_mission[sailor_id]
		if sailor_mission then
			end_mission = sailor_mission[#sailor_mission]
		end
	end
	if sailor_id and end_mission.mission == missionId then
		-- dialogSequence:insertDialogTable({id = missionId, sailor_id = mission_to_sailor[missionId])  --完成任务
	else
		ClsDialogSequence:insertTaskToQuene(ClsMissionPlot.new({id = missionId, type = "complete"}))
	end
	
   	local port_data = getGameData():getPortData()
	port_data:trySetPortPowerInfo()
	EventTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE_STATUS)

end

function rpc_client_mission_get_reward(result, error, missionId)
	if result==1 then

	else
		Alert:warning({msg =error_info[error].message, size = 26})
	end
end

function rpc_client_click_button(result, error)
	if result==1 then

	else
		Alert:warning({msg =error_info[error].message, size = 26})
	end
end

--以下是悬赏rpc
--悬赏任务：
function rpc_client_get_daily_mission(result, error, freshGold, missionInfo ,freeTimes, completedTimes,allTimes) --现在要用
	local missionDataHandler = getGameData():getMissionData()
	if result == 1 then
		missionDataHandler:setHotelRewardNumbers({gold = freshGold})
		missionDataHandler:setHotelFreeNumbers({times = freeTimes})
		missionDataHandler:setComplatedTimes(completedTimes,allTimes)

		for k, v in pairs(missionInfo) do
			if v.jsonArgs then
				v.json_info = json.decode(v.jsonArgs)
			end
		end
		missionDataHandler:setHotelRewardMissionInfo(missionInfo)
		-- -- EventTrigger(EVENT_HOTEL_CREATE_HOTEL_REWARD_VIEW)
		local PortRewardUI = getUIManager():get("clsPortRewardUI")
		if not tolua.isnull(PortRewardUI) then
			PortRewardUI:initUI(true)
		end
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = ui_word.COMMON_ERROR_MSG_NULL
		end
		Alert:warning({msg = str, size = 26})
	end
end

local alert_lock = false

--接受悬赏：
function rpc_client_accept_daily_mission(result, error)
	local missionDataHandler = getGameData():getMissionData()
	if result == 1 then
		Alert:warning({msg = ui_word.HOTEL_GET_SUCCESS_TIPS, size = 26})
		local tempMissionInfo = missionDataHandler:getStartMissionInfo()
		if tempMissionInfo == nil then
			cclog("rpc_client_accept_daily_mission ========  tempMissionInfo is nil=========")
		end
		local team_data = getGameData():getTeamData()
		if team_data:isInTeam() and not team_data:isTeamLeader() then
			return
		end

		ClsDialogSequence:insertTaskToQuene(ClsPortRewardMission.new({missionId = nil, isEnd = nil, missionInfo = tempMissionInfo}))

	elseif result == 0 then

		if error == 478 then  ---有悬赏任务在做
			if getUIManager():get("AlertShowJumpWindow") then return end
			local back_time = 8
			Alert:showBayInvite(nil, function()
				missionDataHandler:giveUpMission()   --放弃任务
			end, function()
				Alert:warning({msg = ui_word.MISSION_TEAM_NO_SAME, size = 26})
			end, nil, true, back_time, ui_word.MISSION_TEAM_NO_SAME_OR_GIVEUP, ui_word.YES, ui_word.NO,nil,true)
			return
		end

		if error ~= 41 then   ---体力不足
			Alert:warning({msg = error_info[error].message, size = 26})
			return
		end

		local team_data = getGameData():getTeamData()
		if team_data:isInTeam() and not team_data:isTeamLeader() and not alert_lock then

			if isExplore then
				alert_lock = true
			else
				alert_lock = false
			end
			local parameter = {}
			if isExplore then
				parameter.ignore_sea = true
			end
			parameter.destroy_callback = function ()
				alert_lock = false
			end
			parameter.close_call = function ()
				alert_lock = false
			end
			Alert:showJumpWindow(POWER_NOT_ENOUGH, nil, parameter)

		end
	end
end

--取消悬赏任务
function rpc_client_cancel_daily_mission(result, error)
	local missionDataHandler = getGameData():getMissionData()
	if result == 1 then
		missionDataHandler:setHotelRewardAccept(nil)
		local PortRewardUI = getUIManager():get("clsPortRewardUI")
		if not tolua.isnull(PortRewardUI) then
			PortRewardUI:initUI()
		end

		Alert:warning({msg = ui_word.HOTEL_HAD_GIVE_UP_TIPS, size = 26})

		EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)	
		getGameData():getExploreNpcData():removeNpc(-1)	
		----放弃悬赏任务，小地图上的图标删除
		local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
		if not tolua.isnull(explore_map) then
			-- 刷新整个类型的图标,可以做数据对比刷新也行
			explore_map:resetPoint(EXPLORE_NAV_TYPE_SALVE_SHIP)
			explore_map:resetPoint(EXPLORE_NAV_TYPE_REWARD_PIRATE)
		end

		--EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = string.format(ui_word.COMMON_ERROR_MSG_CODE, error)
		end
		Alert:warning({msg = str, size = 26})
	end
end

---自动悬赏
function rpc_client_auto_bounty( error )
	if error == 0 then
		local missionDataHandler = getGameData():getMissionData()
		missionDataHandler:setAutoPortRewardStatus(true)
	else
		Alert:warning({msg = error_info[error].message, size = 26})			
	end

end


---取消自动悬赏
function rpc_client_cancel_auto_bounty(error)
	if error == 0 then
		---取消自动悬赏回港
		local clsAutoPortRewardLayer = getUIManager():get("ClsAutoPortRewardLayer")
		if not tolua.isnull(clsAutoPortRewardLayer) then
			clsAutoPortRewardLayer:closeMySelf()
		end
		local missionDataHandler = getGameData():getMissionData()
		missionDataHandler:setAutoPortRewardStatus(false)
		missionDataHandler:setSelectAutoMission(false)

		return 
	end

	Alert:warning({msg = error_info[error].message, size = 26})

end

---组队悬赏探索界面处理

function rpc_client_team_bounty_special_handle(port_id, status)
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:setReceiveMissionPortId(port_id)

	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	if auto_trade_data:inAutoTradeAIRun() then--自动委任AI中，不进港
		auto_trade_data:addTradeLog("recv rpc_client_team_bounty_special_handle back, port_id is: " .. port_id)
		EventTrigger(EVENT_PORT_EXPLORE_ENTER, port_id)
	else
		if status == 0 then  ---未完成
			local team_data = getGameData():getTeamData()
			if team_data:isInTeam() and not team_data:isTeamLeader() then
				return
			end
			EventTrigger(EVENT_EXPLORE_SHOW_PORT_INFO, port_id)
		else   --- 完成

		end
	end

end


----钻石刷新
function rpc_client_refresh_mission(error)
	if error == 0 then
		local PortRewardUI = getUIManager():get("clsPortRewardUI")
		if not tolua.isnull(PortRewardUI) then
			PortRewardUI:setIsPlayFreshEff(true)
			PortRewardUI:initUI()
		end
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = ui_word.COMMON_ERROR_MSG_NULL
		end
		Alert:warning({msg = str, size = 26})
	end

end

--金币刷新任务
function rpc_client_refresh_mission_by_gold(result, error)
	if result == 1 then
		local PortRewardUI = getUIManager():get("clsPortRewardUI")
		if not tolua.isnull(PortRewardUI) then
			PortRewardUI:setIsPlayFreshEff(true)
			PortRewardUI:initUI()
		end
	else
		local errInfo = error_info[error]
		local str = nil
		if errInfo then
			str = errInfo.message
		else
			str = ui_word.COMMON_ERROR_MSG_NULL
		end
		Alert:warning({msg = str, size = 26})
	end
end

--领取奖励
function rpc_client_day_first_complete_reward(random_rewards)
	local PortRewardUI = getUIManager():get("clsPortRewardUI")
	if not tolua.isnull(PortRewardUI) then
		PortRewardUI:addGetRewardView(random_rewards)
	end
end

---悬赏任务弹框
function rpc_client_accept_mission_pop_window(flag, error)
	if error == 0  then
		local missionDataHandler = getGameData():getMissionData()
		missionDataHandler:setWindowTipsStatus(flag)
	end
end

function rpc_client_get_daily_mission_reward(result, error, rewards, exp_rate, friend_rate, is_more_mission, complete_times, allTimes)--random_rewards, skill_change_rewards,
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:setComplatedTimes(complete_times,allTimes)
	if result == 1 then
		local PortRewardUI = getUIManager():get("clsPortRewardUI")
		if not tolua.isnull(PortRewardUI) then
			PortRewardUI:showGetRewardView(exp_rate, is_more_mission, rewards, friend_rate)
		else
			showGetRewardView(exp_rate, is_more_mission, rewards, friend_rate)
		end
		missionDataHandler:setHotelRewardAccept(nil)
		EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)
	else

	end
end

--guild_material:商会建材 64，guild_honor:商会声望
function showGetRewardView(exp_rate, is_more_mission, rewards, friend_rate)  ---获得奖励弹框 random_rewards, skill_change_rewards,
	--self.completedReward = table.clone(self.current_btn_reward.value.reward) or {}
	Alert:warning({msg = ui_word.COMPOLETE_DAILY_MISSION, size = 26})
	local tempReward = {}
	local missionDataHandler = getGameData():getMissionData()

	local daily_mission_data = missionDataHandler:getHotelRewardMissionInfo()
	for i,v in ipairs(daily_mission_data) do
		print(i,v)
	end
	local tempReward = table.clone(daily_mission_data[1].reward)
	local exp_reward = nil
	for k,v in ipairs(tempReward) do
		if v.key == ITEM_INDEX_EXP then
			exp_reward = v
		end
	end
	exp_rate = exp_rate or 0
	exp_reward.value = getGameData():getBuffStateData():getExpUpResult(exp_reward.value)
	if exp_rate > 0 then
		exp_reward.add_num = math.ceil(exp_reward.value*(exp_rate)/100)
		Alert:warning({msg = string.format(ui_word.TEAM_REWARD_ADD_EXP_TIPS, exp_rate), size = 26}) ---你的经验额外增加
	end

	if friend_rate and friend_rate > 0 then
		Alert:warning({msg = string.format(ui_word.DAILY_MISSION_ADD_FRIENT_POINT, friend_rate), size = 26})
	end

	local filtrator = {
		[1] = ITEM_INDEX_GROUP_EXP,
		[2] = ITEM_INDEX_BOSS_INVEST,
		[3] = ITEM_INDEX_GROUP_PRESTIGE,
	}

	--如果没奖励则不播
	if (#tempReward) <= 0 then return end
	local function endCall()

		if is_more_mission == 1 then   ----悬赏任务有多人任务
			Alert:warning({msg = ui_word.TASK_MORE_MISSION, size = 26})
		end
	end
	--

	local temp_reward = {}
	for k, v in ipairs(tempReward) do
		local save = true
		for i, j in ipairs(filtrator) do
			if j == v.key then
				save = false
				break
			end
		end
		if save then
			temp_reward[#temp_reward + 1] = v
		end
	end
	tempReward = temp_reward
	ClsDialogSequence:insertTaskToQuene(ClsCommonRewardPop.new({reward = rewards, callBackFunc = endCall}))
end

--完成悬赏的次数
function rpc_client_daily_complete_times(times)
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:setHotelFinishTimesNum(times)
end


--悬赏次数
function rpc_client_get_mission_times(times,auto_times)
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:setHotelRewardTenNums(times)
	missionDataHandler:setAutoMissionTimes(auto_times)
	
    local ClsAutoPortRewardLayer = getUIManager():get("ClsAutoPortRewardLayer")
    if not tolua.isnull(ClsAutoPortRewardLayer) then
        ClsAutoPortRewardLayer:updateTimes()
    end	
end

--悬赏信息,登陆下发，和点击接受任务按钮下发
function rpc_client_daily_mission_info(accpetTime, freshGold, missionInfo)

	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:setHotelRewardAcceptTime(accpetTime)
	missionDataHandler:setHotelRewardNumbers({gold = freshGold}) --argument 结构中有刷新的次数
	missionDataHandler:setHotelRewardAccept(missionInfo)
	if missionInfo.jsonArgs then
		missionInfo.json_info = json.decode(missionInfo.jsonArgs)
		--有battle_info字段表示pve信息,添加npc数据
		local battle_info =  missionInfo.json_info.battleInfo
		if battle_info then
			if missionInfo.status ~= MISSION_STATUS_COMPLETE then
				local battle_id = battle_info.battle
				local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")
				local data = {id = -1, server_id = -1, battle_id = battle_id, type = exploreNpcType.REWARD_PIRATE, attr = battle_info}
				getGameData():getExploreNpcData():addNpc(data)
				ClsExploreShipWrecksPoint:updateShipWrecksPoint()--刷新沉船图标
			else
				getGameData():getExploreNpcData():removeNpc(-1)
			end
		end

		--有wreckInfo字段表示沉船信息
		local wreckInfo =  missionInfo.json_info.wreckInfo
		if wreckInfo and isExplore and missionInfo.status ~= MISSION_STATUS_COMPLETE then
			local ClsExploreSeaBoatEvent = require("gameobj/explore/exploreEvent/exploreSeaBoatEvent")
			if tolua.isnull(ClsExploreSeaBoatEvent) then
				local explore_layer = getExploreLayer()
				if not tolua.isnull(explore_layer) then
					local explore_event_layer = explore_layer:getExploreEventLayer()
					if not tolua.isnull(explore_event_layer) then
						explore_event_layer:createCustomEventByName("explore_wreck")
					end					
				end
			end

			ClsExploreShipWrecksPoint:updateShipWrecksPoint()--刷新沉船图标
		end
	end

	local tmp = {}
	tmp[#tmp + 1] = missionInfo
	missionDataHandler:setHotelRewardMissionInfo(tmp)
	local PortRewardUI = getUIManager():get("clsPortRewardUI") --点击接受任务按钮的时候，更新界面
	if not tolua.isnull(PortRewardUI) then
		PortRewardUI:initUI()
	end
	missionDataHandler:setHotelRewardAccept(missionInfo)
	missionDataHandler:completeHotelRewardInfo(table.clone(missionInfo)) --保存任务信息
	EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)

end

--完成悬赏任务
function rpc_client_complete_daily_mission(missionId, rewards)
	local missionDataHandler = getGameData():getMissionData()
	missionDataHandler:alertHotelRewardCompletedView(missionId, rewards)
end

----增加悬赏任务次数
function rpc_client_add_accept_times(allTimes, errno)
	if errno == 0 then
		--initBar(allTimes)
		local PortRewardUI = getUIManager():get("clsPortRewardUI") --点击接受任务按钮的时候，更新界面
		if not tolua.isnull(PortRewardUI) then
			PortRewardUI:initBar(allTimes)
		end
	else
		Alert:warning({msg = error_info[errno].message, size = 26})
	end
end

----藏宝图
function rpc_client_treasure_info(treasure_info)
	getGameData():getPropDataHandler():setTreasureInfo({treasure_id = treasure_info.treasureId, mapId = treasure_info.mapId, positionId = treasure_info.positionId, time = treasure_info.end_time})
	getGameData():getPropDataHandler():useItemId(treasure_info.treasureId)
	----调用藏宝图
	getGameData():getPropDataHandler():alertTreasureView()

end

local function tryDispacthDarkRedPoint(key, is_open)
	local boatData = getGameData():getBoatData()
	boatData:tryDispacthDarkRedPoint(is_open)
end

local event_by_key = {
	[on_off_info.DARK_MARKET.value] = tryDispacthDarkRedPoint,
}

local function setRedPointState( key, on_off )
	local task_data = getGameData():getTaskData()
	local isOpen = (on_off == 1)
	local judgeFunc = event_by_key[key]
	if type(judgeFunc) == "function"then
		judgeFunc(key, isOpen)
		return
	end

	task_data:setTask(key, isOpen, true)
end
function rpc_client_red_point(key, on_off)
	setRedPointState(key, on_off)
end

function rpc_client_red_point_list( list )
	local task_data = getGameData():getTaskData()
	for _,key in ipairs(list) do
		setRedPointState(key, 1)
	end
end

function rpc_client_mission_got_boat(boat)
	if not boat.id then return end 
	ClsDialogSequence:insertTaskToQuene(ClsShipRewardPop.new({boatInfo = boat}))
end

---悬赏打捞沉船
function rpc_client_bounty_explore_event_end(type,error)
	if error == 0 then
		local explore_layer = getExploreLayer()
		local explore_event_layer = explore_layer:getExploreEventLayer()
		if not tolua.isnull(explore_event_layer) then
			local explore_wreck_event_id = explore_event_layer:getEventIdByType("explore_wreck")
			explore_event_layer:removeCustomEventById(explore_wreck_event_id)
		end

		local missionDataHandler = getGameData():getMissionData()
		local mission_info = missionDataHandler:getHotelRewardAccept()
		local params = {}
		if mission_info.status == STATUS_FINISHED then
			misPort = mission_info.json_info["start_port"]
			params.target_id = misPort
			if params.target_id then
				EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = params.target_id, navType = EXPLORE_NAV_TYPE_PORT})
			end
			ClsExploreShipWrecksPoint:updateShipWrecksPoint() --刷新沉船图标，这里完成了沉船任务
		end
	end
end


-- pirate_info = {missionId, pirateId}
function rpc_client_seaforce_pirate_info(pirates, fight_pirate_id)
	local mission_pirate_data = getGameData():getMissionPirateData()
	mission_pirate_data:refreshAllPirate(pirates)
	mission_pirate_data:setFightPirateId(fight_pirate_id)
end


function rpc_client_boat_decoration_effect()
	local ClsShipEffectUIQuene = require("gameobj/quene/clsShipEffectUIQuene")
	ClsDialogSequence:insertTaskToQuene(ClsShipEffectUIQuene.new())
end

--城市挑战任务数据返回
function rpc_client_trial_info(info)
	local ONE_ROUND_MATCH_COUNT = 7
	local FINISH_STATUS = 2
	if info.current == ONE_ROUND_MATCH_COUNT and info.status == FINISH_STATUS then
		return
	end
	getGameData():getCityChallengeData():setMissionList(info)
end

function rpc_client_trial_fight(error_n)
	if error_n > 0 then
        Alert:warning({msg = error_info[error_n].message})
    end
end

function rpc_client_trial_accept(error_n)
	if error_n > 0 then
        Alert:warning({msg = error_info[error_n].message})
    end
end

--完成当前的挑战任务
function rpc_client_trial_current_finish(current_progress, is_end)
	local ONE_ROUND_MATCH_COUNT = 7
	local city_challenge_handle = getGameData():getCityChallengeData()
	if is_end == 0 then --活动未结束
		if current_progress == ONE_ROUND_MATCH_COUNT then
			city_challenge_handle:delCurMission()
			city_challenge_handle:toOpenPanel("next_accept")
		else
			city_challenge_handle:changeMissionStatus()
		end
	else
		city_challenge_handle:delCurMission()
	end
end

function rpc_client_trial_open_or_close(is_open)
	if is_open == 0 then
		if getUIManager():isLive("ClsCityChallengePop") then
			getUIManager():close("ClsCityChallengePop")
		end
		local city_challenge_handle = getGameData():getCityChallengeData()
		city_challenge_handle:delCurMission()
		city_challenge_handle:toOpenPanel("final_close")
	end
end

-- 主线任务援助奖励发放
function rpc_client_assist_win_reward(rewards, info)
	local ClsMissionBattleFail = require("gameobj/quene/clsMissionBattleFail")
    ClsDialogSequence:insertTaskToQuene(ClsMissionBattleFail.new({info = info, rewards = rewards, is_reward = true}))
end

function rpc_client_assist_mission_fight_failed(mission_id)
    local ClsMissionBattleFail = require("gameobj/quene/clsMissionBattleFail")
    ClsDialogSequence:insertTaskToQuene(ClsMissionBattleFail.new({mission_id = mission_id}))
end

function rpc_client_assist_info(info)
	local mission_data_handler = getGameData():getMissionData()
	mission_data_handler:setAssistInfo(info)
end