-- Author: pyq0639
-- Date: 2017-02-21 11:59:06
-- Function: 城市挑战任务数据
local mission_conf = require("game_config/city_challenge/city_challenge_data")
local port_info = require("game_config/port/port_info")
local ClsCityChallengeData = class("ClsCityChallengeData")
local ui_word = require("scripts/game_config/ui_word")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsPanelPopView = require("gameobj/quene/clsPanelPopView")

local HAS_FINISH = 2

function ClsCityChallengeData:ctor()
	self.m_cur_item = nil
end

function ClsCityChallengeData:setMissionList(info)
	local mission = {}
	local mission_id = info.task_id
	local port_id = info.port_id
	mission.id = mission_id
	mission.type = mission_conf[mission_id].type
	mission.port_id = port_id
	mission.status_tag = info.status

	local desc = {}
	for k,v in ipairs(table.clone(mission_conf[mission_id].target_tips)) do
		local green_tag = string.find(v, "#", 0)
		if green_tag then
			v = "#"..port_info[port_id].name
		end
		desc[k] = v
	end
	mission.desc = desc

	mission.complete_describe = {}
	mission.complete_describe[1] = string.format(mission_conf[mission_id].mission_tips[1], port_info[port_id].name)
	mission.name = mission_conf[mission_id].name
	mission.status = MISSION_STATUS_DOING
	mission.acceptTime = info.accept_time

	mission.complete_sum = {}
	mission.complete_sum[1] = info.max

	mission.missionProgress = {}
	mission.missionProgress[1] = {}
	mission.missionProgress[1]['value'] = info.current - 1

	self:setCurMissionList(mission)
	EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)

	self:whenAcceptMission(info.is_login ~= 0)
end

function ClsCityChallengeData:setCurMissionList(list)
	self.m_cur_item = list
end

function ClsCityChallengeData:getCurMissionList()
	return self.m_cur_item
end

function ClsCityChallengeData:delCurMission()
	self.m_cur_item = nil
	EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)
end

function ClsCityChallengeData:toTargetPort()
	if getGameData():getSceneDataHandler():isInExplore() then
		EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = self.m_cur_item.port_id, navType = EXPLORE_NAV_TYPE_PORT})
	else
		getGameData():getWorldMapAttrsData():goOutPort(self.m_cur_item.port_id, EXPLORE_NAV_TYPE_PORT)
	end
end

function ClsCityChallengeData:toOpenPanel(_type)
	local team_data_handle = getGameData():getTeamData()
	if team_data_handle:isInTeam() and not team_data_handle:isTeamLeader() then
		return
	end

	ClsDialogSequence:insertTaskToQuene(ClsPanelPopView.new("city_challenge", {data = self.m_cur_item, panel_type = _type}))
end

function ClsCityChallengeData:changeMissionStatus()
	if not self.m_cur_item then return end
	self.m_cur_item.status_tag = HAS_FINISH
	EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)
end

function ClsCityChallengeData:checkIsMissionPort()
	local mission_list = getGameData():getMissionData():getMissionInfo()
	for _, mission_info in pairs(mission_list) do
		if mission_info.status == MISSION_STATUS_DOING then
			if mission_info.ask_battle and mission_info.ask_battle == self.m_cur_item.port_id then
				return true
			end
		end
	end
end

function ClsCityChallengeData:whenClickMission()
	if not self.m_cur_item then return end

	local team_data_handle = getGameData():getTeamData()
	if team_data_handle:isInTeam() and not team_data_handle:isTeamLeader() then
		return
	end

	if self.m_cur_item.status_tag == HAS_FINISH then
		if getUIManager():isLive("ClsActivityMain") then
			getUIManager():close("ClsActivityMain")
		end
		getUIManager():create("gameobj/activity/clsActivityMain",nil,2)
		return
	end

	if self:checkIsMissionPort() then
		self:toOpenPanel("exchange")
		return
	end

	if getGameData():getSceneDataHandler():isInExplore() then
		self:toTargetPort()
		return
	end
	if self.m_cur_item.port_id == getGameData():getPortData():getPortId() then
		self:toOpenPanel("challenge")
	else
		self:toTargetPort()
	end
end

function ClsCityChallengeData:whenAcceptMission(is_login)
	if is_login or not self.m_cur_item or self.m_cur_item.status_tag == HAS_FINISH then return end
	if self.m_cur_item.port_id == getGameData():getPortData():getPortId() then
		self:toOpenPanel("challenge")
	else
		self:toOpenPanel("transmit")
	end
end

function ClsCityChallengeData:isPopChallengeView()
	if not self.m_cur_item or self.m_cur_item.status_tag == HAS_FINISH then return end
	if self.m_cur_item.port_id == getGameData():getPortData():getPortId() then
		return true
	end
end

-----协议调用-----
function ClsCityChallengeData:askCityTask()
	GameUtil.callRpc("rpc_server_trial_accept",{})
end

function ClsCityChallengeData:askFight()
	GameUtil.callRpc("rpc_server_trial_fight",{})
end

function ClsCityChallengeData:askToTargetPort()
	GameUtil.callRpc("rpc_server_trial_enter_port",{})
end

function ClsCityChallengeData:askGuildChat()
	GameUtil.callRpc("rpc_server_trial_group_ask", {})
end

function ClsCityChallengeData:askMissionList()
	GameUtil.callRpc("rpc_server_trial_info",{})
end

function ClsCityChallengeData:askChangeTask()
	GameUtil.callRpc("rpc_server_trial_replace_port",{})
end

return ClsCityChallengeData