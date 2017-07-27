--2016/05/31
--wmh0497
--组队协议接收部分

local error_info =require("game_config/error_info")
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local ClsElementMgr = require("base/element_mgr")
local parseMsg = require("module/message_parse.lua")
local dataTools = require("module/dataHandle/dataTools")

--[[
	findType: 1 港口查询，2 海域查询
	teamType: 1 经商，2 藏宝海湾，3 顶上之战
	class team_info_t {
		int id;
		int type;
		int leader;
		int* member_uid;
		int* member_grade;
		int* member_status;
		string* member_icon;
		string* member_name;

	}
	获取组队信息，findType港口组队信息还是海域等，teamType是经商还是掠夺等
	findType为港口则id为港口id，如果为海域则id为海域id
	void rpc_server_team_list(object oUser, int findType, int teamType);
	void rpc_client_team_list(int uid, team_info_t* list, int id); --]]
function rpc_client_team_list(list)
	getGameData():getTeamData():setTeamListInfo(list)
end

--[[
	// 创建队伍
	void rpc_server_team_create(object oUser, int teamType);
	void rpc_client_team_create(int uid, int errno);
--]]

function rpc_client_team_create(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
		getGameData():getTeamData():askTeamListInfo()
	elseif error_n == 0 then
		ClsAlert:warning({msg = string.format(ui_word.CREATE_TEAM_TIP, getGameData():getPlayerData():getName())})
		getGameData():getTeamData():setTeamLeader(true)
	end
end

--[[
	// 加入队伍
	void rpc_server_team_join(object oUser, int teamId);
	void rpc_client_team_join(int uid, int errno); --]]
function rpc_client_team_join(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
		getGameData():getTeamData():askTeamListInfo()
	elseif error_n == 0 then
		-- ClsAlert:warning({msg = ui_word.TEAM_JION_SECC})
		getGameData():getTeamData():joinTeamCB()
	elseif error_n < 0 then
		getGameData():getTeamData():askTeamListInfo()
	end
end

function  rpc_client_team_teammate_return_succ(name)
	ClsAlert:warning({msg = name..ui_word.TEAM_HAS_JOIN_TEAM_TIPS})
end

-- 同步队伍信息
function rpc_client_team_info(team_info)
	local team_data_handle = getGameData():getTeamData()
	team_data_handle:updateMyTeamInfo(team_info)
	local far_arena_info = ClsElementMgr:get_element("clsFarArenaInfo")
	if not tolua.isnull(far_arena_info) then
		far_arena_info:updateTeamInfo(true)
	end
	
	-- local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	-- if team_data_handle:isTeamLeader() and not team_data_handle:isTeamFull() then
	--     getGameData():getCopySceneData():askMoveCamera()
	-- end
end


function rpc_client_team_chenge_huodong_type(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
		getGameData():getTeamData():askTeamListInfo()
	else
		getGameData():getTeamData():askTeamListInfo()
	end
end
--[[
	// 离开队伍
	void rpc_server_team_leave(object oUser);
	void rpc_client_team_leave(int uid, int errno); --]]
function rpc_client_team_leave(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
		-- local percent_view = ClsElementMgr:get_element("ClsBusinessTeamList")
		-- if not tolua.isnull(percent_view) then
		--     percent_view:setBtnsTouch(true)
		-- end
	end
	local chat_data_handler = getGameData():getChatData()
	chat_data_handler:cleanTeamMsg()
	
	getGameData():getTeamData():askTeamListInfo()
	getGameData():getTeamData():setMyTeamInfo(nil)
	local chat_panel_ui = ClsElementMgr:get_element("ClsChatSystemPanel")
	if not tolua.isnull(chat_panel_ui) then
		chat_panel_ui:updateShowMessage()
	end

	if error_n == 0 then
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
		ClsSceneManage:doLogic("askLeaveCopyScene")
	end
end

function rpc_client_team_invite_people_nearby(friend)
	local near_by_list = {}
	for i, info in ipairs(friend) do
		local temp = {}
		temp.level = info.grade
		temp.prestige = info.prestige
		temp.uid = info.uid
		temp.name = info.name
		near_by_list[i] = temp
	end
	local friend_invite = getUIManager():get("ClsFriendInvite")
	if not tolua.isnull(friend_invite) then
		friend_invite:updateNearByView(near_by_list)
	end
end

function rpc_client_team_recive_friend_invite(error)
	-- body
end

function rpc_client_team_delete(team_id)
	getGameData():getTeamData():deleteTeam(team_id)
end

--T人协议
function rpc_client_team_remove_teammate(errors)
	if errors > 0 then
		ClsAlert:warning({msg = error_info[errors].message})
	else
	   
	end
end

--被T了，下行协议
function rpc_client_team_be_remove(errors)
	getGameData():getTeamData():selfHadTick()
	if errors > 0 then
		ClsAlert:warning({msg = error_info[errors].message})
	end
end

function rpc_client_team_uid_invite(error_, uid)
	if error_info ~= 0 then
		ClsAlert:warning({msg = error_info[error_].message})
	end
end

function rpc_client_team_invite_list(friends, times)
	-- local friend_invite = getUIManager():get("ClsFriendInvite")
	-- if not tolua.isnull(friend_invite) then
	--     friend_invite:updateView()
	-- end
end

--[[
 int teamId;        --队伍id
 int uid;           --邀请人uid
 string leaderName; --邀请人名字
 int teamType;      --组队活动类型
 int sceneId;       --地点
]]
function rpc_client_team_be_invite(info)    
	local teamData = getGameData():getTeamData()
	if teamData:getRefuseStatus(info.uid) then return end
	teamData:receiveTeamInvited(info)
end

--邀请的人成功入队
function rpc_client_team_invite_received(target_id)
	local friend_invite = getUIManager():get("ClsFriendInvite")
	if not tolua.isnull(friend_invite) then
		friend_invite:friendHasInvite(target_id)
	end
end

------------------------------商会邀请--------------------------------------------
function rpc_client_team_invite_group(errors)
	if errors == 0 then --成功
		ClsAlert:warning({msg = ui_word.STR_SEND_SUCCEED})
	else
		ClsAlert:warning({msg = error_info[errors].message})
	end
end

function rpc_client_team_world_invite(errors)
	local chat_data = getGameData():getChatData()
	if errors == 0 then --成功
		ClsAlert:warning({msg = ui_word.STR_SEND_SUCCEED})
	else
		if errors == 438 then
			-- ClsAlert:warning({msg = string.format(ui_word.CHAT_NEXT_SEND_MSG, chat_data:getChatCD(DATA_WORLD))})
		else
			ClsAlert:warning({msg = error_info[errors].message})
		end
	end
end

function rpc_client_team_receive_group_invite(errors, port_id)
	local port_layer = getUIManager():get("ClsPortLayer")
	if errors == 0 then --成功
		--todo
	elseif errors > 0 then
		ClsAlert:warning({msg = error_info[errors].message})
		if not tolua.isnull(port_layer) then
			port_layer:setTouch(true)
		end 
		if isExplore then
			local chat_panel_ui = ClsElementMgr:get_element("ClsChatSystemPanel")
			if not tolua.isnull(chat_panel_ui) then
				chat_panel_ui:setTouch(true)
			end
		end
	end
end

--组队事件下发
function rpc_client_team_event(time, msg)
   local info = parseMsg.parse(msg)
end

function rpc_client_team_member_partner_data(info)
	getGameData():getTeamData():setUIDPartner(info)
end

--切换组队邀请类型
function rpc_client_team_change_invite_type(error_id)
	if error_id == 0 then --成功
		--todo
	else
		ClsAlert:warning({msg = error_info[error_id].message})
	end
end

--提升队员为队长
function rpc_client_team_promote_leader(error_id)
	if error_id == 0 then
		local exploreLayer = getUIManager():get("ExploreLayer")
		if not tolua.isnull(exploreLayer) then
			local explore_land = exploreLayer:getLand()
			explore_land:breakAuto(true)
		end
	end
end

--在场景中加入某船只队伍
function rpc_client_team_join_in_scene(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	end    
end

function rpc_client_mission_auto_team(mission_id)
	IS_VIRTUA_TEAM = true
	getGameData():getTeamData():saveVirtualTeamFightMissionID(mission_id)
end

function rpc_client_mission_team_dissolve()
	IS_VIRTUA_TEAM = false
end

function rpc_client_team_quick_join(error_n)
	if error_n > 0 then
		ClsAlert:warning({msg = error_info[error_n].message})
	else
		ClsAlert:warning({msg = ui_word.QUICK_JOIN_TEAM_SUCCESS_TIPS})
	end
	getGameData():getTeamData():askTeamListInfo()
end

function rpc_client_team_response_targetId_invite(errno, teamId)
	if errno > 0 then
		ClsAlert:warning({msg = error_info[errno].message})
	end
	if teamId > 0 then
		getGameData():getTeamData():toClosePanel()
		if tolua.isnull(getExploreUI()) and getUIManager():isLive("ClsGuidePortLayer") then
			if not getUIManager():isLive("ClsPortTeamUI") then
				getUIManager():removeViewOnFront("ClsGuidePortLayer")
				getUIManager():removeAllTipsView()
				getUIManager():create("gameobj/team/clsPortTeamUI", nil, nil, true)
			end
		else
			local copy_scene_manager = require("gameobj/copyScene/copySceneManage")
			if false == copy_scene_manager:doLogic("isPopTeamMainUI") then
				return
			end
			getGameData():getTeamData():setIsPopMainUI(true)
		end
	end
end

--邀请别人失败返回
function rpc_client_team_invite_fail(uid, type)
	local friend_invite_ui = getUIManager():get("ClsFriendInvite")
	if not tolua.isnull(friend_invite_ui) then
		friend_invite_ui:handleFailInvited(uid, type)
	end
end