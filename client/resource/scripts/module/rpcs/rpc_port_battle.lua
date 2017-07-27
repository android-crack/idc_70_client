--
-- Author: lzg0496 
-- Date: 2017-01-11 11:17:27
-- Function: 港口争夺战的相关协议
--
--

local cfg_error_info = require("game_config/error_info")
local cfg_ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local cfg_port_info = require("game_config/port/port_info")

function rpc_client_port_battle_occupy_info(occupy_info, challenge_info_list, port_id, status, remain_time)
	local port_battle_data = getGameData():getPortBattleData(status)
	port_battle_data:setRemainTime(remain_time)
	port_battle_data:setPortBattleStatus(status)
	port_battle_data:setOccupyInfo(port_id, occupy_info)
	port_battle_data:setChallengeInfoList(port_id, challenge_info_list)
	local port_battle_ui = getUIManager():get("ClsPortBattleUI")
	if not tolua.isnull(port_battle_ui) then
		port_battle_ui:updateUI()
	end

	local ClsPortBattleTips = getUIManager():get("ClsPortBattleTips")
	if not tolua.isnull(ClsPortBattleTips) then
		ClsPortBattleTips:updataInfoUI(port_id)
	end

	local ClsPortBattleSignUI = getUIManager():get("ClsPortBattleSignUI")
	if not tolua.isnull(ClsPortBattleSignUI) then
		ClsPortBattleSignUI:updatePortOccupyUI()
	end
end

function rpc_client_refresh_port_battle_status(status, remain_time)
	-- local port_town_ui = getUIManager():get("clsPortTownUI")
	-- if not tolua.isnull(port_town_ui) then
	-- 	local port_battle_data = getGameData():getPortBattleData()
	-- 	port_battle_data:askOccupyInfo(getGameData():getPortData():getPortId())
	-- 	port_battle_data:setRemainTime(remain_time)
	-- 	port_battle_data:setPortBattleStatus(status)
	-- end
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:setPortBattleStatus(status)
	port_battle_data:setRemainTime(remain_time)

	local port_battle_main_ui = getUIManager():get("ClsPortBattleMainUI")
	if not tolua.isnull(port_battle_main_ui) then
		port_battle_main_ui:updateUI()
	end

	local port_battle_ui = getUIManager():get("ClsPortBattleUI")
	if not tolua.isnull(port_battle_ui) then
		port_battle_ui:updateUI()
	end
end

function rpc_client_port_battle_apply(error_code)
	local port_battle_data = getGameData():getPortBattleData()
	if error_code ~= 0 then
		ClsAlert:warning({msg = cfg_error_info[error_code].message})
		return 
	end
	ClsAlert:warning({msg = cfg_ui_word.STR_APPLY_SUCCESS})
	--报名成功请求刷新数据
	local port_battle_enroll_ui = getUIManager():get("ClsPortBattleSignUI")
	if not tolua.isnull(port_battle_enroll_ui) then
		local select_port = port_battle_enroll_ui:getSelectPortId()
		if select_port then
			port_battle_data:askOccupyInfo(select_port)
		end
	end

	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui) then
		guild_main_ui:updateEnrollStatus(true)
	end
end

function rpc_client_group_build_info(is_attack, donate_list, cur_donate_val, amount)
	local port_battle_data = getGameData():getPortBattleData()
	local WARSHIP_TYPE = 0
	local SCULPTURE_TYPE = 1
	port_battle_data:setDonateType(WARSHIP_TYPE)
	if is_attack == SCULPTURE_TYPE then
		port_battle_data:setDonateType(SCULPTURE_TYPE)
	end
	port_battle_data:setDonateList(donate_list)
	port_battle_data:setCurDonateTimes(amount)
	port_battle_data:setCurDonates(cur_donate_val)

	local boat_donate_ui = getUIManager():get("ClsBoatDonateUI")
	if not tolua.isnull(boat_donate_ui) then
		boat_donate_ui:updataUI(is_attack, cur_donates)
	end
end

--如果捐献成功，下发单条的捐献信息
function rpc_client_group_build(single_donate_info, rewards)
	if type(rewards) == "table" then
		ClsAlert:showCommonReward(rewards)		
	end
	
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:singleAddDonates()
	port_battle_data:addSingleDonateInfo(single_donate_info)
	local cur_donate_times, max_donate_times = port_battle_data:getCurAndMaxDonateTimes()
	if cur_donate_times == max_donate_times then
		cur_donate_times = max_donate_times - 1
	end
	port_battle_data:setCurDonateTimes(cur_donate_times + 1)
	local boat_donate_ui = getUIManager():get("ClsBoatDonateUI")
	if not tolua.isnull(boat_donate_ui) then
		boat_donate_ui:updataUI()
	end
end

function rpc_client_port_battle_chart(chart)
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:setBattleChart(chart)

	--港口争夺战的排行榜ui更新
	-- local copy_scene_manage = require("gameobj/copyScene/copySceneManage")
	-- copy_scene_manage:doLogic("updateBattleChart")
	local port_battle_rank_ui = getUIManager():get("ClsPortBattleRankUI")
	if not tolua.isnull(port_battle_rank_ui) then
		port_battle_rank_ui:updateRankUI()
	end
end

function rpc_client_port_battle_activity_info(apply_ports)
	local scene_data_handle = getGameData():getSceneDataHandler()

	local to_panel = "port_fight_ui"
	local port_data = getGameData():getPortData()

	local cur_port_id = port_data:getPortId()
	local cur_area_id = port_data:getPortAreaId()
	local target_port_id = apply_ports[1] --默认选中报名的第一个港口

	--就近原则，先打开本港口的报名界面
	for k, port_id in ipairs(apply_ports) do 
		if port_id == cur_port_id then
			local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
			mission_skip_layer:skipLayerByName(to_panel)
			return
		end
	end

	local world_map_attrs_data = getGameData():getWorldMapAttrsData()
	for k, port_id in ipairs(apply_ports) do 
		if cfg_port_info[port_id].areaId == cur_area_id then
			target_port_id = port_id
			break
		end
	end

	local port_name = cfg_port_info[target_port_id].name
	local area_name = cfg_port_info[target_port_id].sea_area

	local go_callback = function()
		if scene_data_handle:isInExplore() then
			return
		end
		world_map_attrs_data:goOutPort(target_port_id, EXPLORE_NAV_TYPE_PORT, function()
			local port_data = getGameData():getPortData()
			port_data:setEnterPortCallBack(function()
				if port_data:getPortId() ~= target_port_id then return end
				local mission_skip_layer = require("gameobj/mission/missionSkipLayer")
				mission_skip_layer:skipLayerByName(to_panel)
			end)
		end)
	end

	local params = {
		area_name = area_name, 
		port_name = port_name, 
		go_callback = go_callback
	}

	ClsAlert:showGoToPortFight(params)	
end

function rpc_client_port_occupy_info(guild_list)
	local map_ui = getUIManager():get("ExploreMap")
	if tolua.isnull(map_ui) then
		map_ui = getUIManager():get("PortMap")	
	end

	local port_battle_data = getGameData():getPortBattleData()
	for k, v in  pairs(guild_list) do
		port_battle_data:setExploreOccupyInfo(v)
		if not tolua.isnull(map_ui) then
			map_ui:updatePoint(v.portId, EXPLORE_NAV_TYPE_PORT)
		end
	end

	local port_battle_enroll_ui = getUIManager():get("ClsPortBattleSignUI")
	if not tolua.isnull(port_battle_enroll_ui) then
		port_battle_enroll_ui:updateMapPortUI()
	end
end

function rpc_client_port_battle_list(status, port_list)
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:setPortBattleStatus(status)
	port_battle_data:setPortList(port_list)

	local port_battle_main_ui = getUIManager():get("ClsPortBattleMainUI")
	if not tolua.isnull(port_battle_main_ui) then
		port_battle_main_ui:updateUI()
	end
end

function rpc_client_port_battle_mvp_info(mvp_info)
	getGameData():getPortBattleData():setMVPData(mvp_info)
	local ClsGuildFightMVPUi = getUIManager():get("ClsGuildFightMVPUi")
	if not tolua.isnull(ClsGuildFightMVPUi) then
		ClsGuildFightMVPUi:updateUI()
	end
end

function rpc_client_group_port_battle(occupy_list, challenge_list)
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:setOccupyList(occupy_list)
	port_battle_data:setChallegeList(challenge_list)

	local port_battle_enroll_ui = getUIManager():get("ClsPortBattleSignUI")
	if not tolua.isnull(port_battle_enroll_ui) then
		port_battle_enroll_ui:updateCurOccupyList()
	end

	local guild_port_tip = getUIManager():get("ClsGuildPortPrivilegeTip")
	if not tolua.isnull(guild_port_tip) then
		guild_port_tip:updateUI()
	end

	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui) then
		guild_main_ui:updateEnrollStatus()
	end
end
