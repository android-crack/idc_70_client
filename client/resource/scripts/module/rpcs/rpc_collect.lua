local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local relic_info = require("game_config/collect/relic_info")
local element_mgr = require("base/element_mgr")
local ui_word = require("game_config/ui_word")

function rpc_client_collect_baowu_list(baowuList)
	local collect_data = getGameData():getCollectData()
	collect_data:initBaozangData(baowuList)
end 

function rpc_client_collect_baowu_info(info)
	local collect_data = getGameData():getCollectData()
	collect_data:updateBaowuInfoClient(info)
end

function rpc_client_relic_share_times(cur_times, max_times)
	local collect_data = getGameData():getCollectData()
	collect_data:setShareTimes(cur_times, max_times) 
end

function rpc_client_collect_relic_unlock(relic_id)
	--播放遗迹解锁成功
	getUIManager():create("gameobj/relic/clsRelicActiveUI", nil, relic_id)
end

--发掘
function rpc_client_collect_relic_active(result, error_n, explore_point)
	EventTrigger(EVENT_RELIC_DISCOVER_OVER, result, explore_point)

	local relic_discover_ui_obj = getUIManager():get("ClsRelicDiscoverUI")
	if not tolua.isnull(relic_discover_ui_obj) then
		relic_discover_ui_obj:updateDigCallback(result, explore_point)
	end
	
	if 0 == result then
		local msg_str = error_info[error_n].message
		Alert:warning({msg = msg_str})
	end 
end

--发现遗迹的返回协议(暂时不用)
function rpc_server_collect_relic_discover()

end

--遗迹某个数据更新
function rpc_client_collect_relic_info(relic_info)
	local collect_data = getGameData():getCollectData()
	collect_data:updateRelicInfo(relic_info)

	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map) then
		explore_map:updatePoint(relic_info.id, EXPLORE_NAV_TYPE_RELIC)
	end

	local relic_ui = getUIManager():get("ClsRelicDiscoverUI")
	if not tolua.isnull(relic_ui) then
		relic_ui:updateInfo(relic_info.id)
		relic_ui:updateBtns()
	end
end

function rpc_client_collect_relic_star_event(relic_id, is_succ_n)
	local collect_data = getGameData():getCollectData()
	local relic_info = collect_data:getRelicInfoById(relic_id)
	if relic_info and relic_info.status and (2 == relic_info.status) and is_succ_n ~= 0 then
		relic_info.status = 3
	end
	local relic_discover_ui_obj = getUIManager():get("ClsRelicDiscoverUI")
	if not tolua.isnull(relic_discover_ui_obj) then
		relic_discover_ui_obj:updateRelicAnswerResultCallback(is_succ_n)
	end
end

--遗迹水手单挑
function rpc_client_collect_relic_sala(my_sailor_data, enemy_sailor_data, result, error)
end

--[[id, status]]--
function rpc_client_collect_relic_list(relicList)
	local collect_data = getGameData():getCollectData()
	collect_data:initSelfRelicData(relicList)
	EventTrigger(EVENT_SELF_RELIC_INFO)
end 

--发掘领奖
function rpc_client_collect_relic_get_reward( rewards, result_n, error_n)
	if 1 == result_n then
		local relic_discover_ui_obj = getUIManager():get("ClsRelicDiscoverUI")
		if not tolua.isnull(relic_discover_ui_obj) then
			relic_discover_ui_obj:updateRelicGetRewardCallback(rewards)
		end
	else
		local msg_str = error_info[error_n].message
		Alert:warning({msg = msg_str})
	end
end

--探索发奖
function rpc_client_collect_daily_reward(err, rewards_info)
	if err == 0 then
		Alert:showCommonReward(rewards_info)
	else
		local msg_str = error_info[err].message
		Alert:warning({msg = msg_str})
	end
end

-- [1] = {
-- 	    ["amount"] = 1.000000,
-- 	    ["id"] = 603.000000,
-- 	    ["memoJson"] = '{"color":1}',
-- 	    ["type"] = 10.000000,
-- 	},
--高级探索发奖，一个一个发
function rpc_client_relic_explore_10(err, rewards)
	if err == 0 then
		Alert:showCommonReward(rewards, nil, 0.4)
		local collect_data = getGameData():getCollectData()
		collect_data:insertTenExploreReward(rewards)
	else
		local msg_str = error_info[err].message
		Alert:warning({msg = msg_str})
	end
end

--设置港口对应遗迹的列表
function rpc_client_relic_tip_list(list)
	local collect_data = getGameData():getCollectData()
	collect_data:setRelicMissionList(list)
end

--更新某个港口对应的遗迹
function rpc_client_relic_tip_update(port_id, relic_id)
	local collect_data = getGameData():getCollectData()
	collect_data:updateRelicMissionToList(port_id, relic_id)
end

function rpc_client_relic_tip_del(relic_id)
	local collect_data = getGameData():getCollectData()
	collect_data:delRelicMissionFromList(relic_id)
end

function rpc_client_relic_advice(relic_id, error)

	if error ~= 0 then
		local msg_str = error_info[error].message 
		Alert:warning({msg = msg_str, size = 26})
		return
	end

	if not relic_id then
		Alert:warning({msg = ui_word.NOT_NAVIGATE_RELIC, size = 26})
		return 
	end
	if isExplore then--探索
		local dialog = require("ui/dialogLayer")
		dialog.hideDialog()
	end
	if not relic_id then return end
	Alert:warning({msg = relic_info[relic_id].advise_tip, size = 26})
end

--使用了战书道具后触发
function rpc_client_use_challenge_letter( errno )
	if errno == 0 then--进入战斗弹框
		getUIManager():create("gameobj/relic/clsRelicEventUI", nil, {status = RELIC_EVENT_FIGHT})
	elseif errno == 321 then--商会求助弹框
		getUIManager():create("gameobj/relic/clsRelicEventUI", nil, {status = RELIC_EVENT_HELP})
	end
end

function rpc_client_great_pirate_fight_get_reward(rewards)
	Alert:showCommonReward(rewards)
end

function rpc_client_get_challenge_letter(rewards)
	Alert:showCommonReward(rewards, function()
		local rpc_down_info = require("game_config/rpc_down_info")
		Alert:showAttention(rpc_down_info[359].msg, nil, nil, nil, {hide_cancel_btn = true})
	end)
end

function rpc_client_onekey_compose( errno, list )
	if errno == 0 then
		table.print(list)
		local baowu_data = getGameData():getBaowuData()
		for i, boat_baowu in ipairs(list) do
			if boat_baowu.amount > 0 then
				baowu_data:addBoatBaowu(boat_baowu)
			else
				baowu_data:delBaowu(boat_baowu.baowuId)
			end
		end
		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:refreshBackpackInfo()
		end
		Alert:warning({msg = ui_word.BACKPACK_ONE_KEY_COMPOSE_TIPS, size = 26})
	else
		local msg_str = error_info[errno].message
		Alert:warning({msg = msg_str})
	end
end