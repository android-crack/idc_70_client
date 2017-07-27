local element_mgr = require("base/element_mgr")

function rpc_client_current_scene(my_uid, scene_id, type_n, map_id, x, y, ship_id, name, add_speed, camp_n, iat, cat)
    local battle_data = getGameData():getBattleDataMt()
    if battle_data:GetBattleSwitch() then
        local params = {my_uid, scene_id, type_n, map_id, x, y, ship_id, name, add_speed, camp_n, iat, cat}
        battle_data:SetData("rpc_client_current_scene", params)
        return
    end

    local user_icon = nil
    local sceneDataHandler = getGameData():getSceneDataHandler()
    if iat then
        for k, v in pairs(iat) do
            if v.key == "port_id" then
                local portData = getGameData():getPortData()
                portData:changePortId(v.value)
            end
        end
    end

    for k, v in pairs(cat) do
        if v.key == "user_icon" then
            user_icon = tonumber(v.value)
        end
    end
    sceneDataHandler:setSceneInfo(scene_id, type_n, map_id)
    sceneDataHandler:setSceneInitPos(x, y)
    sceneDataHandler:setSceneMyPlayerInfo(my_uid, ship_id, name, add_speed, camp_n, user_icon)
    
	local playerShipsData = getGameData():getExplorePlayerShipsData()
	if sceneDataHandler:isSameScene(true) then
		if sceneDataHandler:isInExplore() then --同海域的切换增加提示
			playerShipsData:tryToShowWarningTips()
			explore_layer = getUIManager():get("ExploreLayer")
			if not tolua.isnull(explore_layer) then
				explore_layer:tryToOpenTransferFinishView()
			end
		end
		return
	end
    
    playerShipsData:cleanInfo()
    playerShipsData:initInfo()
    local scene_type_config = sceneDataHandler:getSceneTypeConfig()
    local scene_type = sceneDataHandler:getSceneType()
    if scene_type_config.EXPLORE == scene_type then --探索
        getGameData():getPlayersDetailData():setIsGoExplore(true)
        getGameData():getExploreData():clearEventData()
        startExploreScene()
    else  --副本
        local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
        ClsSceneManage:initSceneConfig(x, y)
        ClsSceneManage:enterScene()
    end
end
--[[
class obj_move {
	int uid;
	int dx; // 目标偏移量
	int dy; 
}
]]

-- 进入海域 num 海域编号 eid 进场目标uid  boatT 旗舰类型
--[[
// 进入海域
class enter_scene_t {
    int uid;
    int mapId;
    int x;
    int y;
    int ship_id;
}
void rpc_server_enter_area(object user,int sceneId,int x,int y);
void rpc_client_enter_area(int uid, enter_scene_t enterScene);
void rpc_client_enter_area_list(int uid, enter_scene_t* enterScene);
--]]
function rpc_client_enter_area(enter_scene_info)
    local battle_data = getGameData():getBattleDataMt()
    if battle_data:GetBattleSwitch() then
        local enter_area = battle_data:GetData("rpc_client_enter_area")
        if not enter_area then
            enter_area = {}
        end

        enter_area[#enter_area + 1] = enter_scene_info
        battle_data:SetData("rpc_client_enter_area", enter_area)
        return
    end

    getGameData():getExplorePlayerShipsData():addPosShipInfo(enter_scene_info)

    local chat_panel_ui = element_mgr:get_element("ClsChatSystemPanel")
    if not tolua.isnull(chat_panel_ui) then
        chat_panel_ui:updateShowMessage()
    end
end


function rpc_client_enter_area_list(enter_scene_info_list)
    local explore_player_ships_data = getGameData():getExplorePlayerShipsData()
    for _, enter_scene_info in pairs(enter_scene_info_list) do
        explore_player_ships_data:addPosShipInfo(enter_scene_info)
    end

    local chat_panel_ui = element_mgr:get_element("ClsChatSystemPanel")
    if not tolua.isnull(chat_panel_ui) then
        chat_panel_ui:updateShowMessage()
    end
end

function rpc_client_scene_user_status(uid, status)
    getGameData():getExplorePlayerShipsData():updateShipStatus(uid, status)
end

--[[
class team_t {
    // 队长
    int leader;
    // 成员
    int* member;
}
void rpc_client_scene_team_info(int uid, team_t teamInfo);
void rpc_client_scene_team_infos(int uid, team_t* teamInfos); --]]
function rpc_client_scene_team_info(team_info)
    local battle_data = getGameData():getBattleDataMt()
    if battle_data:GetBattleSwitch() then
        local scene_team_info = battle_data:GetData("rpc_client_scene_team_info")
        if not scene_team_info then
            scene_team_info = {}
        end

        scene_team_info[#scene_team_info + 1] = team_info
        battle_data:SetData("rpc_client_scene_team_info", team_info)
        return
    end
    
    getGameData():getExplorePlayerShipsData():updateTeamInfo(team_info)
end

function rpc_client_scene_team_infos(team_infos)
    local explore_player_ships_data = getGameData():getExplorePlayerShipsData()
    for k, team_info in ipairs(team_infos) do
        explore_player_ships_data:updateTeamInfo(team_info)
    end
end

--退出海域
function rpc_client_leave_area(area_id, uid)
	getGameData():getExplorePlayerShipsData():removeShipInfo(area_id, uid)
end

-- void rpc_server_move(object user,int dx,int dy); 
-- void rpc_client_move(int uid, obj_move msg); 
function rpc_client_move(info)
	getGameData():getExplorePlayerShipsData():moveToTPos(info)
end

function rpc_client_get_uid_info(uid, info)
    getGameData():getPlayersDetailData():addPlayerInfo(uid, info)
    --根据下发的船信息更新ui
    local teamData = getGameData():getTeamData()
    if teamData:isLock() then
        if uid == teamData:getTeamLeaderUid() then
            local explore_ui = getExploreUI()
            if not tolua.isnull(explore_ui) then
                explore_ui:updateTeamSpeedInfo()
            end
        end
    end
end

function rpc_client_get_redname_cd(cd_n)
    getGameData():getExplorePlayerShipsData():setCdTime(cd_n)
end

function rpc_client_transfer_position(type_n, error_n)
	if error_n > 1 then
		local error_info = require("game_config/error_info")
		local ClsAlert = require("ui/tools/alert")
		local msg_str = error_info[error_n].message
		ClsAlert:warning({msg = msg_str})
	end
end
---------------------------------------- ce版本协议 --------------------
-- 特殊任务播放阳光+海鸥
function rpc_client_mission_sunshine_seagull()
    getGameData():getExploreData():setPlaySunshineSeagull(true)
end

--任务完成删除播放阳光+海鸥
function rpc_client_delete_sunshine_seagull()
    getGameData():getExploreData():setPlaySunshineSeagull(false)
end

--特殊任务屏蔽逆风
function rpc_client_mission_shield_tailwind()
    getGameData():getExploreData():setShieldWindHead(true)
end

--任务完成删除屏蔽逆风
function rpc_client_delete_shield_tailwind()
    getGameData():getExploreData():setShieldWindHead(false)
end

-- 特殊任务每隔3秒出现一次装饰事件
function rpc_client_mission_decorate_event()
    getGameData():getExploreData():setRandomEvent(true)
end

--任务完成删除每隔3秒出现一次装饰事件
function rpc_client_delete_decorate_event()
    getGameData():getExploreData():setRandomEvent(false)
end

 ---------------------------------------- ce版本协议 --------------------