local privateTotal = 100
local Alert = require("ui/tools/alert")
local error_info = require("game_config/error_info")
local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")

local STR_LOOT_NORESULT = ui_word.COMMON_NO_FIND_PLAYER
local GOAL_OPPONENT_DISAPPEAR_TIME = 180 
function rpc_client_fight_search(areaId, result, err, fighterData)
	if result == 0 then
		_msg = error_info[err].message
		Alert:warning({msg = _msg})
		return
	end
end

function rpc_client_fight_search_pk(result, err, session, fighterType, target)
	if result == 0 then
		Alert:warning({msg = error_info[err].message, x = display.cx, y = display.cy, color = ccc3(255, 0, 0)})
		return
	end
	cclog("===============================战斗进入方式已更改！！！")
end

local function addRedPoint()
	local taskData = getGameData():getTaskData()
	local taskKeys = {
        on_off_info.PORT_REPORT.value,
    }
    for i,v in ipairs(taskKeys) do 
        taskData:setTask(v, true)
    end
end

function rpc_client_plunder_report_list(plunder_report_list)
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:setPlunderReportList(plunder_report_list)
	if #plunder_report_list > 0 then
		addRedPoint()
		local port_layer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(port_layer) then
			port_layer:updateCenterBtn()
		end
	end	
end

function rpc_client_plunder_report_clean()
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:cleanPlunderReportList()
end

function rpc_client_plunder_report_add(plunder_report)
	local loot_data_handler = getGameData():getLootData()
	local current_plunder_report_list = loot_data_handler:getPlunderReportList()
	local report_num = #current_plunder_report_list

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) and ( report_num <= 0) then
		loot_data_handler:addPlunderReportToList(plunder_report)
		addRedPoint()
		port_layer:updateCenterBtn()
	else
		local is_have = false
		for k, v in ipairs(current_plunder_report_list) do
			if v.id == plunder_report.id then
				is_have = true
				current_plunder_report_list[k] = plunder_report
				break
			end
		end
		if not is_have then
			loot_data_handler:addPlunderReportToList(plunder_report)
			addRedPoint()
		end
	end
end

function rpc_client_plunder_report_del(report_id)
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:delPlunderReportFromReportList(report_id)
	local current_plunder_report_list = loot_data_handler:getPlunderReportList()
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) and (#current_plunder_report_list <= 0 ) and not tolua.isnull(port_layer.button_battle_report) then
		port_layer.button_battle_report:removeFromParentAndCleanup(true)
		port_layer.button_battle_report = nil
	end
end

function rpc_client_plunder_name_status(status, cd)
	local info = {
		is_red = (status == 1) and true or false,
		cd = cd or 0
	}
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:setRedNameInfo(info)

	local explore_ui = getUIManager():get("ExploreUI")
	if not tolua.isnull(explore_ui) then
		explore_ui:updateTradeBtn()
	end
end

function rpc_client_plunder_team_leader(uid)
	local friend_data_handler = getGameData():getFriendDataHandler()

    if friend_data_handler:isMyFriend(uid) then
    	Alert:warning({msg = ui_word.EXPLORE_LOOT_IS_FRIEND_NOT_LOOT_TIP, color = ccc3(dexToColor3B(COLOR_RED))})
    	return 
    end

    local guild_data = getGameData():getGuildInfoData()
	local is_my_guild = guild_data:getGuildInfoMemberByUid(uid)
	if is_my_guild then 
		Alert:warning({msg = ui_word.EXPLORE_LOOT_IS_GUILD_NOT_LOOT_TIP, color = ccc3(dexToColor3B(COLOR_RED))})
		return
	end

	local explore_data_handler = getGameData():getExploreData()
	explore_data_handler:askLootPlayer(uid)
end

function rpc_client_plunder_switch_name_status(err)
	if err > 0 then
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
	end
	getUIManager():close("ClsChangeNameStatusTip")
end

function rpc_client_plunder_be_arrest()
    getUIManager():create("gameobj/loot/clsPrizonUI")
end

function rpc_client_plunder_used_license()
	Alert:warning({msg = ui_word.LOOT_USE_LISENCE_TIP})
end

function rpc_client_plunder_bribe(err)
	if err > 0 then
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
		return
	end
	local prizon_ui = getUIManager():get("ClsPrizonUI")
	if not tolua.isnull(prizon_ui) then
		prizon_ui:closeView()
	end
end

function rpc_client_plunder_fail_tip(hours)  
	local port_data = getGameData():getPortData()
	port_data:setEnterPortCallBack(function()
		local auto_trade_data = getGameData():getAutoTradeAIHandler()
        if auto_trade_data:getIsAutoTrade() then--自动经商中无法进行跳转操作
            return
        end
		local show_txt = string.format(ui_word.LOOT_ENTER_PORT_TIP, hours)
		Alert:showAttention(show_txt, nil, nil, nil, {hide_cancel_btn = true})
	end)
end

--等待响应弹框（包括自己和队员）
function rpc_client_plunder_switch_status_confirm(is_leader, end_time)
	local kind = IS_LEADER
	if is_leader ~= 1 then
		kind = IS_TEAMATER
	end

	if end_time == nil then
		local player_data = getGameData():getPlayerData()
		local current_time = player_data:getCurServerTime()
		end_time = current_time + 8
	end

	getUIManager():create("gameobj/loot/clsChangeNameStatusTip", nil, {kind = kind, end_time = end_time})
end

--发送拒绝的玩家信息
function rpc_client_plunder_switch_status_refuse(refuse_uid)
	local team_data = getGameData():getTeamData()
	local player_info = team_data:getTeamUserInfoByUid(refuse_uid)
	Alert:warning({msg = string.format(ui_word.TEAMATER_REFUSE_SWITCH, player_info.name)})
	getUIManager():close("ClsChangeNameStatusTip")
end

function rpc_client_plunder_report_list(list)
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:setReportList(list)
end

--追踪
function rpc_client_plunder_report_trace(id, err, trace_time)
	if err > 0 then
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
	else
		local loot_data_handler = getGameData():getLootData()
		loot_data_handler:updateReport({id = id, trace_time = trace_time})
	end
end

function rpc_client_plunder_report_target_info(info)
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:updatePlayerInfo(info) 
end

function rpc_client_plunder_tracing_info(server_info)
	local info = {
		id = server_info.report_id,
		trace_time = server_info.trace_time,
		port_id = server_info.port_id,
		area_id = server_info.area_id,
		x = server_info.x,
		y = server_info.y,
		name = server_info.name,
		duration = server_info.duration
	}

	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:setTracingInfo(info)
end

--战报更新
function rpc_client_plunder_report_update(report)
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:updateReport(report)	
end

--更新玩家信息
function rpc_client_plunder_report_target_update(info)
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:updatePlayerInfo(info, true)	
end



