
local error_info=require("game_config/error_info")
local news = require("game_config/news")
local Alert = require("ui/tools/alert")
local battleResult = require("module/battleAttrs/battleResult")
local clsUiWord = require("game_config/ui_word")
local explore_event = require("game_config/explore/explore_event")

--获取水手 食物 点数，登陆时下发
function rpc_client_port_explore_consume(totalSailor, totalFood, sailor, food)
	local supplyData = getGameData():getSupplyData()
	supplyData:setTotalSailorAndFood(totalSailor, totalFood)
	supplyData:setCurSailor(sailor)
	supplyData:setCurFood(food)
end

-- 补给消耗->剩余情况，当前最大补给和水手
-- void rpc_client_area_supply_goods(int uid,int goods);                                                                                                              
-- void rpc_client_area_supply_sails(int uid,int sails); 
function rpc_client_area_supply_goods(food)
	getGameData():getSupplyData():setCurFood(food)
end
function rpc_client_area_supply_sails(sailor)
	getGameData():getSupplyData():setCurSailor(sailor)
end

--补充水手 食物 点数
function rpc_client_port_explore_supply(result, err, supplyType)
	if result==1 then
		local supplyData = getGameData():getSupplyData()
		supplyData:receiveSupplyResult(supplyType)
	else
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
	end
end

--补充水手 食物 点数(不过这条协议需要把当前的食物和水手数上传才返回)
function rpc_client_collect_relic_supply(result, err)
	if result==1 then
		local enterPortUI = getUIManager():get("clsEnterPortUI")
		if not tolua.isnull(enterPortUI) then
			enterPortUI:showAfterSupply()
			return
		end
		if EventTrigger(EVENT_RELIC_SUPLY_DONE) then
			return
		end
		local supplyData = getGameData():getSupplyData()
		supplyData:saveConsumeCash()
		local news = require("game_config/news")
		local text = string.format(news.EXPLORER_SUPPLY_CASH.msg, supplyData:getComsumeCash())
		Alert:explorerSupplyAttention(text)
	else
		EventTrigger(EVENT_RELIC_SUPLY_DONE, true)
		local _msg = error_info[err].message
		Alert:warning({msg = _msg})
	end
end 

-- 清空货物
function rpc_client_business_clear_all_goods(result, err)
end 

--//////////////////////////海域任务//////////////////////////

-- class mission_area_info_t { 
-- int missionId;                                                               
-- int status;
-- int progress; 
-- int amount;
-- }  
function rpc_client_area_mission_info(missionInfo)
	local exploreMapData = getGameData():getExploreMapData()
	exploreMapData:receiveAreaMisInfo(missionInfo)
end

function rpc_client_area_mission_get_reward(missionId, result, err)
	local exploreMapData = getGameData():getExploreMapData()
	exploreMapData:receiveAreaMisReward(missionId, result, err)
end

function rpc_client_scene_event_list(eventList)--事件列表
	local exploreData = getGameData():getExploreData()
	exploreData:addEvent(eventList)
end

function rpc_client_scene_event_delete(serverEventID)
	local exploreData = getGameData():getExploreData()
	exploreData:removeEventById(serverEventID)
end

function  rpc_client_explore_event_reward(eventType, rewards)
	local ExploreReward = require("module/explore/exploreReward")
	local explore_event_item = explore_event[eventType]
	if explore_event_item then
		local event_type = explore_event_item.event_type
		if event_type == "patrol" or event_type == "patrol_boss" then
			battleResult.showBattleResult(rewards)
			return
		end
	end
	if not getGameData():getTeamData():isLock() then
		ExploreReward:showRewardEffect(eventType, rewards)
	end
end

--wmh todo
rpc_client_scene_explore_convey = function(result, err)
	local _msg = error_info[err].message
	Alert:warning({msg = _msg})
end

--rpc_server_port_explore_start_new
--[[class scene_evnet_t {
	int evId;
	int evType;
	int x;
	int y;
	string jsonArgs;
}
// 事件列表
void rpc_client_scene_event_list( int uid,  scene_evnet_t* lstEv );

// 场景事件结束
void rpc_server_scene_event_end(object oUser, int evnetId, int flag );
]]

function rpc_client_explore_copy_enable(key, result, error)
	-- body
	print("key---------", key, result, error)
end

function rpc_client_cangbaotu_del()
	getGameData():getPropDataHandler():clearTreasureInfo()
end

function rpc_client_cangbao_bay_leader_ask()
	Alert:showBayInvite(nil, function()
		local bay_data = getGameData():getBayData()
		bay_data:sendResponse(1)
	end, function()
		local bay_data = getGameData():getBayData()
		bay_data:sendResponse(2)
	end)
end

--队长请求了开启藏宝海湾活动之后
function rpc_client_cangbao_bay_team_ask(list, result, error_code)
	local element_mgr =  require("base/element_mgr")
	local main_tab = getUIManager():get("ClsActivityMain")
	if error_code == 0 then
		Alert:showBayInvite(main_tab, nil, nil)
		return
	end
	
	if result == 0 then
		Alert:warning({msg = error_info[error_code].message})
		if not tolua.isnull(main_tab) then
			main_tab:setTouch(true)
		end
		return
	end

	if not tolua.isnull(main_tab) then
		main_tab:setTouch(true)
	end

	if #list ~= 0 then
		local team_data = getGameData():getTeamData()
		local str = ""

		for k, uid in ipairs(list) do
			local member_data = team_data:getTeamUserInfoByUid(uid) 
			str = str .. member_data.name .. clsUiWord.STR_COPY_SCENE_MEMBER
			if k ~= #list then
				str = str .. clsUiWord.STR_COPY_SCENE_AND
			end
		end
		str = str .. clsUiWord.STR_COPY_SCENE_NO_FREQUENCY
		Alert:warning({msg = str})
	end
end

function rpc_client_cangbao_bay_response(result, error)
end

--告诉队长, 谁拒绝了副本(reason 1拒绝 2超时, 3没次数)
function rpc_client_cangbao_bay_delete_ask(reason, who_uids)
	local str = ""
	local team_data = getGameData():getTeamData()

	for k, uid in ipairs(who_uids) do
		local teamUser_info = team_data:getTeamUserInfoByUid(uid)
		if reason == 1 then
			str = string.format(clsUiWord.STR_COPY_SCENE_DECLINE_TIPS1, teamUser_info.name)
		elseif reason == 2 then
			str = string.format(clsUiWord.STR_COPY_SCENE_DECLINE_TIPS1, teamUser_info.name)
		elseif reason == 3 then
			str = string.format(clsUiWord.STR_COPY_SCENE_DECLINE_TIPS3, teamUser_info.name)
		end
		Alert:warning({msg = str})
	end
	local bay_data = getGameData():getBayData()
	local callback = bay_data:getResponseCallback()
	bay_data:setResponseCallback(nil)
	if type(callback) == "function" then
		callback()
	end
end

function rpc_client_near_port(portId,err,old_prestige,new_prestige)
	if err == 0 then
		local new_port_data = {["portId"] = portId,["old_prestige"] = old_prestige,["new_prestige"] = new_prestige}
		getGameData():getExploreData():findNewPort(new_port_data)
	else
		-- local _msg = error_info[err].message
		-- Alert:warning({msg = _msg})
	end
end