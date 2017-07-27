local Alert = require("ui/tools/alert")
local error_info = require("game_config/error_info")
local time_plunder_info = require("game_config/loot/time_plunder_info")
local ui_word = require("scripts/game_config/ui_word")

-- 请求接受运镖任务 结果返回
function rpc_client_plunder_time_apply(err,task_id)
	if err ~= 0 then
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
		return
	end

	local data = getGameData():getConvoyMissionData()
	-- print( '  ------------ rpc_client_plunder_time_apply ---------',err,task_id)
	data:setCurItem(task_id)
	data:acceptMission(task_id)
end

-- 请求运镖任务列表 返回列表
function rpc_client_plunder_task_list(area_list,begin,duration)

	-- print( ' 请求运镖任务列表 返回列表 ')
	area_list = area_list or {}
	-- area_list = {1,2,3} -- for test

	local data = getGameData():getConvoyMissionData()
	data:setList(area_list) -- 海域列表
	data:setTimeData(begin,duration) -- 事件列表
	data:updateRelative() -- 刷新
end

-- 当前已接受任务的id 只能有一个
function rpc_client_plunder_current_task(task_id)
	-- print(' ------------ ',task_id)
	local data = getGameData():getConvoyMissionData()
	data:setCurItem(task_id)
	data:updateRelative() -- 刷新

	-- other. task_id > 0 有任务 ,==0 没接任务

end

-- 运镖任务完成 播放完成对话 设置奖励
function rpc_client_plunder_time_mission_info_complete(id, rewards)
	-- print(' ------- 完成任务 ----- ',id,rewards)

	local data = getGameData():getConvoyMissionData()
	data:setCurItem(0)
	data:updateRelative() -- 刷新

	local function complete_callback()
		-- print(' -------------------  回港奖励')
		-- 回港奖励
		local port_data = getGameData():getPortData()
		port_data:setEnterPortCallBack(function()

			if rewards then
				local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
				local ClsAutoTradeRewardPopViewQuene = require("gameobj/quene/clsAutoTradeRewardPopViewQuene")
				ClsDialogSequence:insertTaskToQuene(ClsAutoTradeRewardPopViewQuene.new({reward = rewards}))
			end

			local data = getGameData():getConvoyMissionData()
			-- data:completeMission(id,complete_callback)
			data:completeMission(id)

		end)

		-- print(' -------------------  任务完成提醒')
		-- 任务完成提醒
		local port_layer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(port_layer) then
			Alert:warning({msg = ui_word.FINISH_TRADE_COMPLETE})
		end
	end
	complete_callback()
end

-----------------------------------------------------------------------

local function upateTradeCompleteView()
	local trade_complete_ui = getUIManager():get("ClsPortTradeCompete")
	if not tolua.isnull(trade_complete_ui) then
		trade_complete_ui:updateView()
	end
end

--界面还没有创建时请求是否开启
function rpc_client_time_plunder_open(is_open, cd)
	if cd > 0 then
		local trade_complete_ui = getUIManager():get("ClsPortTradeCompete")
		if not tolua.isnull(trade_complete_ui) then
			trade_complete_ui:closeInquiryServerScheduler()
		end
	end
	local trade_complete_data = getGameData():getTradeCompleteData()
	trade_complete_data:setIsOpen(is_open)
	trade_complete_data:setCd(cd)
	if is_open == 1 then --如果开启的话，请求基本数据
		local trade_complete_data = getGameData():getTradeCompleteData()
		trade_complete_data:askTaskInfo()
	else
		upateTradeCompleteView()
	end
end

--开启的话请求基本信息
function rpc_client_plunder_time_info(err, info)
	if err == 0 then
		local trade_complete_data = getGameData():getTradeCompleteData()
		trade_complete_data:setTradeCompleteInfo(info)
		upateTradeCompleteView()
		--更新掠夺战报
		local trade_complete_ui = getUIManager():get("ClsPortTradeCompete")
		if not tolua.isnull(trade_complete_ui) then
			trade_complete_ui:updateListView()
		end
	else
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
	end
end

function rpc_client_time_plunder_end()
	Alert:warning({msg = ui_word.TIME_LOOT_FAIL_TIP, color = ccc3(dexToColor3B(COLOR_RED))})
end

-- function rpc_client_plunder_time_apply(err)
-- 	if err == 0 then
-- 		Alert:warning({msg = ui_word.TRADE_APPLY_SUCCESS})
-- 		local main_ui = getUIManager():get("ClsPortTeamUI")
-- 		if not tolua.isnull(main_ui) then
-- 			local business_ui = main_ui:getListUi()
-- 			business_ui:updateTradeBtnShow()
-- 		end
-- 	else
-- 		Alert:warning({msg = error_info[err].message, color = ccc3(dexToColor3B(COLOR_RED))})
-- 	end
-- end

function rpc_client_plunder_time_mission_removed()
	local trade_complete_data = getGameData():getTradeCompleteData()
	trade_complete_data:cleanData()

	local exploreData = getGameData():getExploreData()
	exploreData:closeTradeScheduler()

	getGameData():getConvoyMissionData():cleanCurItem()

	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		local ships_layer = explore_layer:getShipsLayer()
		if not tolua.isnull(ships_layer) then
			ships_layer:setLockSpeed(false)
		end
	end
end
