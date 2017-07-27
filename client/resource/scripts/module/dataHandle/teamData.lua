--2016/05/31
--wmh0497
--用于记录组队信息
local team_config = require("game_config/team/team_config")
local ClsElementMgr = require("base/element_mgr")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local port_info = require("game_config/port/port_info")
local area_info = require("game_config/port/area_info")
local ClsTeamData = class("teamData")

local GUILD_TYPE = 1
local WORLD_TYPE = 2
local JOIN_TEAM_TYPE = 3

function ClsTeamData:ctor()
    self.m_team_list_info = {}    --全部队伍列表info
    self.m_is_in_team = false     --是否队伍中
    self.m_is_team_leader = false --是否队长
    self.m_is_coming_back = false
    self.m_team_type = 1
    self.m_my_team_info = nil     --自己队伍info
    self.m_my_team_order = nil    --队伍中自己的次序
    self.refuse_invite_tbl = {}   --重登前再也不接受邀请
    self.m_be_invite_tbl = {}     --排队中组队邀请数据
    self.is_be_inviting = false   --是否正在播组队邀请
    self.is_enter_success = false --成功接收别人邀请进队
    self.friend_invite_num = 0    --主动邀请次数
    self.be_inviting_uid = nil    --组队邀请invitaor
    self.join_team_id = nil       --申请加入的队伍id
    self.m_is_team_full = false   --队伍是否满员
    self.m_guild_cd = nil         --组队商会邀请点击cd
    self.search_type = 1
    self.team_uid_partner = {}
    self.update_uid_partner_call_back ={}
    self.m_team_types = {
        ELITE_BATTLE = 4,
        TRADE_COMPLETE = 7,
        SEVEN = 8,
    }
end

function ClsTeamData:setTeamType(team_type)
    self.m_team_type = team_type
end

function ClsTeamData:getSelectTeamType()
    return self.m_team_type
end

function ClsTeamData:getTeamTypes()
    return self.m_team_types
end

function ClsTeamData:askTeamListInfo()
    if IS_VIRTUA_TEAM then -- 假组队数据处理
        local virtua_team_data = getGameData():getVirtuaTeamData()
        virtua_team_data:createVirtualTeam()
    else
        GameUtil.callRpc("rpc_server_team_list", {self.m_team_type}, "rpc_client_team_list")
    end
end

function ClsTeamData:askCreateTeam()
    GameUtil.callRpc("rpc_server_team_create", {self.m_team_type}, "rpc_client_team_create")
end

--组队邀请
function ClsTeamData:askInviteAssembTeam()
    GameUtil.callRpc("rpc_server_team_create", {})
end

--申请加入队伍
function ClsTeamData:askJoinTeam(team_id)
    self.join_team_id = team_id
    GameUtil.callRpc("rpc_server_team_join", {team_id})
end

--离队
function ClsTeamData:askLeaveTeam()
    local trade_complete_data = getGameData():getTradeCompleteData()
    local is_have_task = trade_complete_data:isHaveTask() 
    local function askLeaveTeam()
        GameUtil.callRpc("rpc_server_team_leave", {}, "rpc_client_team_leave")
    end

    if is_have_task then
        ClsAlert:showAttention(ui_word.LEAVE_TEAM_TIP_FAIL, askLeaveTeam)
    else
        askLeaveTeam()
    end
end

function ClsTeamData:askMyTeamInfo()
    GameUtil.callRpc("rpc_server_team_info", {})
end

function ClsTeamData:askChangeTeamType()
    GameUtil.callRpc("rpc_server_team_change_huodong_type", {self.m_team_type}, "rpc_client_team_chenge_huodong_type")
end

function ClsTeamData:askPromoteLeader(uid)
    GameUtil.callRpc("rpc_server_team_promote_leader", {uid}, "rpc_client_team_promote_leader")
end

function ClsTeamData:askJoinTeamInScene(uid)
    GameUtil.callRpc("rpc_server_team_join_in_scene", {uid}, "rpc_client_team_join_in_scene")
end

function ClsTeamData:askQuickJoin()
    GameUtil.callRpc("rpc_server_team_quick_join", {self.m_team_type}, "rpc_client_team_quick_join")
end

--世界喊话
function ClsTeamData:sendInviteByWorld()
    GameUtil.callRpc("rpc_server_team_world_invite",{}, "rpc_client_team_world_invite")
end

--拒绝/接受某人的组队邀请
function ClsTeamData:handleTeamInvite(team_id, type, inviter)
    GameUtil.callRpc("rpc_server_team_response_targetId_invite", {team_id, type, inviter}, "rpc_client_team_response_targetId_invite")
end

function ClsTeamData:setAllRefuseInvite(uid)
    self.refuse_invite_tbl[uid] = true
end

function ClsTeamData:getRefuseStatus(uid)
    return self.refuse_invite_tbl[uid]
end

function ClsTeamData:setTeamListInfo(team_list)
    self.m_team_list_info = team_list
    local port_team_ui = getUIManager():get("ClsPortTeamUI")
    if not tolua.isnull(port_team_ui) and not tolua.isnull(port_team_ui:getListUi()) then
        port_team_ui:getListUi():updateListView()
    end
end

function ClsTeamData:isInTeam()
    local team_type = nil
    if self.m_my_team_info then
        team_type = self.m_my_team_info.type
    end
    return self.m_is_in_team, team_type
end

function ClsTeamData:isTeamFull()
    if self.m_my_team_info then
        return self.m_is_team_full
    end
end

function ClsTeamData:getMyTeamOrder()
    if self.m_my_team_info then
        return self.m_my_team_order
    end
end

function ClsTeamData:isTeamLeader()
    return self.m_is_team_leader
end

function ClsTeamData:setTeamLeader(status)
    self.m_is_team_leader = status
end

function ClsTeamData:getTeamLeaderUid()
    if self.m_is_in_team then
        if self.m_my_team_info then
            return self.m_my_team_info.leader
        end
    end
end

function ClsTeamData:isLock(is_show_tips)
    if self.m_is_in_team and (not self.m_is_team_leader) then
        if is_show_tips then
            -- ClsAlert:warning({msg = ui_word.TEAM_VIEW_CAN_NOT_DO_ANYTHING})
            local Alert = require("ui/tools/alert")
            local uiWord = require("game_config/ui_word")
            Alert:showAttention(uiWord.LEAVE_TEAM_TIP, function()
                local teamData = getGameData():getTeamData()
                teamData:askLeaveTeam()
            end)    
        end
        return true
    end
    if self.m_is_in_team and self.m_is_team_leader then
        --todo
    end
    return false
end

function ClsTeamData:isTeamLock(is_show_tips)
    if self.m_is_in_team then
        if is_show_tips then
            -- ClsAlert:warning({msg = ui_word.TEAM_VIEW_CAN_NOT_DO_ANYTHING})
            local Alert = require("ui/tools/alert")
            local uiWord = require("game_config/ui_word")
            Alert:showAttention(uiWord.LEAVE_TEAM_TIP, function()
                local teamData = getGameData():getTeamData()
                teamData:askLeaveTeam()
            end)    
        end
        return true
    end
    return false
end

local TEAM_LEADER_LOCK_KEY = {
    [on_off_info.PORT_QUAY_JJC.value] = true,
    [on_off_info.PORT_QUAY_FIGHT.value] = true,
}

function ClsTeamData:isTeamLeaderLock(on_off_value)
    if self.m_is_in_team and  self.m_is_team_leader then
        if TEAM_LEADER_LOCK_KEY[on_off_value] then
            ClsAlert:warning({msg = ui_word.TEAM_LEADER_NOT_TIPS})
            return true
        end
        if on_off_value  == on_off_info.PORT_QUAY_EXPLORE.value then --出海
            -- local my_team = self:getMyTeamInfo()
            -- local team_stauts = my_team.member_status
            -- local status = true
            -- for i,v in ipairs(team_stauts) do
            --     if v == 2 then
            --         status = false
            --         break
            --     end
            -- end
            -- if not status then
            --     ClsAlert:warning({msg = ui_word.TEAM_WAIT_OTHER_USER_TIPS})
            --     return true
            -- end
        end
        return false
    end
    return false
end

function ClsTeamData:getTeamListInfo()
    return self.m_team_list_info
end

function ClsTeamData:deleteTeam(team_id)
    local index = -1
    for i,v in ipairs(self.m_team_list_info) do
        if v.id == team_id then
            index = i
        end
    end
    if index ~= -1 then
        table.remove(self.m_team_list_info, index)
    end
end

function ClsTeamData:setMyTeamInfo(my_team_info)
    local SELECT_TEAM = 2
    self.m_is_in_team = false
    self.m_is_team_leader = false
    self.m_is_team_full = false
    self.m_my_team_info = nil
    self.m_my_team_order = nil
    -- self.m_my_team_level = nil   
    if my_team_info then
        self.my_team_invite_type = my_team_info.invite_type
        local my_uid = getGameData():getPlayerData():getUid() or 0
        if my_team_info.leader == my_uid then
            self.m_is_team_leader = true
        end
        
        for k, info in ipairs(my_team_info.info) do
            if info.uid == my_uid then
                self.m_is_in_team = true
                self.m_my_team_order = k
                self.m_my_team_info = my_team_info
                -- self.m_my_team_level = info.grade
                if #(my_team_info.info) == 3 then
                    self.m_is_team_full = true
                end
                break
            end
        end
    else
        self.my_team_invite_type = nil
    end
    
    local data = self:getTeamUserInfoByUid(getGameData():getPlayerData():getUid() or 0)

    local team_task_ui = getUIManager():get("ClsTeamMissionPortUI")
    if not tolua.isnull(team_task_ui) then
        if team_task_ui:getSelectType() == SELECT_TEAM then
            team_task_ui:updateTeamViewInfo()
        end
        team_task_ui:showTeamPanel()
    end

    EventTrigger(JOIN_EXIT_TEAM_EVENT)
    --主界面的自己船舶
    local partner_data = getGameData():getPartnerData()
    local boat_id = partner_data:getShowMainBoatId()
    EventTrigger(EVENT_PORT_CHANGE_BOAT, boat_id)
end

function ClsTeamData:getMyTeamInfo()
    return self.m_my_team_info
end

function ClsTeamData:getMyTeamInviteType()
    return self.my_team_invite_type
end

function ClsTeamData:updateMyTeamInfo(team_info)
    local my_uid = getGameData():getPlayerData():getUid() or 0

    self:setMyTeamInfo(team_info)
    local has_update = false
    for k, v in ipairs(self.m_team_list_info) do
        if v.id == team_info.id then
            self.m_team_list_info[k] = team_info
            has_update = true
            break
        end
    end
    if not has_update then
        self.m_team_list_info[#self.m_team_list_info + 1] = team_info
    end
   
    local port_team_ui_obj = getUIManager():get("ClsPortTeamUI")

    if not tolua.isnull(port_team_ui_obj) and not self:isTeamLeader() then
        port_team_ui_obj:gotoTargetTab()
        port_team_ui_obj:defaultSelect()
        return
    end
   
    self:askTeamListInfo()
end

--T队友
function ClsTeamData:tickTeamPlayer(uid)
     GameUtil.callRpc("rpc_server_team_remove_teammate", {uid}, "rpc_client_team_remove_teammate")
end

function ClsTeamData:selfHadTick()
    self:setMyTeamInfo(nil)
    self:askTeamListInfo()
end

function ClsTeamData:joinTeamCB()
    self:setTeamLeader(false)
end

--邀请好友
function ClsTeamData:inviteFriend(uid)
    GameUtil.callRpc("rpc_server_team_uid_invite", {uid})
end

function ClsTeamData:getFriendInviteNum()
    return self.friend_invite_num
end

function ClsTeamData:setFriendInviteNum(count)
    self.friend_invite_num = count
end

function ClsTeamData:askNearByPeople()
    GameUtil.callRpc("rpc_server_team_invite_people_nearby", {}, "rpc_client_team_invite_people_nearby")
end

--切换邀请类型
function ClsTeamData:changeInviteType(type_id)
    GameUtil.callRpc("rpc_server_team_change_invite_type", {type_id}, "rpc_client_team_change_invite_type")
end

function ClsTeamData:setIsPopMainUI(bool)
    self.is_enter_success = bool
end

function ClsTeamData:getIsPopMainUI()
    return self.is_enter_success
end

--------------------------商会邀请---------------------------------------------
function ClsTeamData:sendInviteByGuild()
    GameUtil.callRpc("rpc_server_team_invite_group", {}, "rpc_client_team_invite_group")
end 

function ClsTeamData:receiveGuildInvite(chat_id)
    GameUtil.callRpc("rpc_server_team_receive_group_invite", {chat_id})
end

----------------------------进港检测下是否弹邀请框-----------------------------------------------
function ClsTeamData:autoPopInviteView()
    self:playInvitedUI()
end

function ClsTeamData:getTeamUserInfoByUid(uid)
    if self.m_my_team_info then
        local temp = {}
        for i,v in ipairs(self.m_my_team_info.info) do
            if v.uid == uid then
                return v
            end
        end
    end
end
--------------------------判断搜索港口类型-----------------------
function ClsTeamData:setSearchType(type)
    self.search_type = type
end
function ClsTeamData:getSearchType()
    return self.search_type
end

function ClsTeamData:askUIDPartner(uid)
    GameUtil.callRpc("rpc_server_team_member_partner_data", {uid}, "rpc_client_team_member_partner_data")
end

function ClsTeamData:setUIDPartner(info)
    self.team_uid_partner[info.uid] = info
    if type(self.update_uid_partner_call_back[info.uid]) == "function" then
        self.update_uid_partner_call_back[info.uid]()
        self.update_uid_partner_call_back[info.uid] = nil
    end
    
    local layer = ClsElementMgr:get_element("clsFarArenaInfo")
    if not tolua.isnull(layer) then
        -- layer:updateTeamInfo()
        layer:updateView()
    end
end

function ClsTeamData:getUIDPartner(uid, call_back)
    if not self.team_uid_partner[uid] then
        self.update_uid_partner_call_back[uid] = call_back
        self:askUIDPartner(uid)
    else
        return self.team_uid_partner[uid]
    end
end

function ClsTeamData:clearPartnerData()
    self.team_uid_partner = {}
end

function ClsTeamData:clearTeamInfo()
    self.m_team_list_info = {}
end

function ClsTeamData:saveVirtualTeamFightMissionID(mission_id)
    self.virtual_mission_id = mission_id
end

function ClsTeamData:getVirtualTeamFightMissionID()
    return self.virtual_mission_id
end

--接收到他人组队邀请
function ClsTeamData:receiveTeamInvited(msg)
    if type(msg) ~= "table" then return end
    for _, info in ipairs(self.m_be_invite_tbl) do
        if info.uid == msg.uid then 
            return -- 若相同人名发的邀请信息返回
        end
    end
    if self.be_inviting_uid and (self.be_inviting_uid == msg.uid) then return end

    local team_invited_ui = getUIManager():get("ClsTeamInviteUI")
    if not tolua.isnull(team_invited_ui) then
        local leave_invited_num = getGameData():getTeamData():getInvitedNum()
        team_invited_ui:updateInvitedNum(leave_invited_num + 2)
    end
    table.insert(self.m_be_invite_tbl, msg)
    self:playInvitedUI()
end

function ClsTeamData:isExitNotPlayPage()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    if ClsSceneManage:doLogic("checkAlert") then 
        return true 
    end

    local prizon_ui = getUIManager():get("ClsPrizonUI")
    if not tolua.isnull(prizon_ui) then
        return true
    end

    local arena_ui = getUIManager():get("ClsArenaMainUI")
    if not tolua.isnull(arena_ui) then
        return true
    end

    local copy_ui = getUIManager():get("ClsCopySceneUI")
    if (not tolua.isnull(copy_ui) and not copy_ui:isCanTeamInvite()) then
        return true
    end

    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    if auto_trade_data:inAutoTradeAIRun() then return true end

    local battle_data = getGameData():getBattleDataMt()
    if battle_data:GetBattleSwitch() then
        return true 
    end
end

function ClsTeamData:playInvitedUI()
    if self:isExitNotPlayPage() then 
        self:getInvitedMsg()
        self:resetInvitedUid()
        return 
    end

    if not self.is_be_inviting then -- 没有正在播的信息
        local invited_msg = self:getInvitedMsg()
        if invited_msg then
            self.is_be_inviting = true
            getUIManager():create("gameobj/team/clsTeamInviteUI", nil, invited_msg)
        end
    end
end

function ClsTeamData:getInvitedMsg()
    if #self.m_be_invite_tbl == 0 then 
        self:resetInvitedUid()
        return 
    end

    local _msg = self.m_be_invite_tbl[1]
    self.be_inviting_uid = _msg.uid
    table.remove(self.m_be_invite_tbl, 1)
    return _msg
end

function ClsTeamData:resetInvitedUid()
    self.be_inviting_uid = nil
end

--获取被邀请次数
function ClsTeamData:getInvitedNum()
    return #self.m_be_invite_tbl
end

function ClsTeamData:setBeInviteShow(bool)
    self.is_be_inviting = bool
    if not bool then
        self:resetInvitedUid()
    end
end

function ClsTeamData:cleanAllInvite()
    self.m_be_invite_tbl = {}
end

function ClsTeamData:toEnterOtherTeam(target_id, call_back, not_enough_call_back)
    if type(call_back) ~= "function" then return end

    local panel = nil
    local port_data = getGameData():getPortData()
    local self_in_port_id = port_data:getPortId()
    local self_in_explore = getGameData():getSceneDataHandler():isInExplore()
    local self_in_scene_id = getGameData():getSceneDataHandler():getMapId()
    local IS_PORT = 1000
    local IS_SEA_SCENE = 10000
    local tip_text = nil
    if target_id < IS_PORT then --队伍在另一个港口
        if self_in_explore or target_id ~= self_in_port_id then
            tip_text = string.format(ui_word.JION_NOT_SAME_PORT_TIPS_1, port_info[target_id].sea_area, port_info[target_id].name)
        else
            call_back()
        end
    elseif target_id < IS_SEA_SCENE then --队伍在另一个海域
        if not self_in_explore or target_id - IS_PORT ~= self_in_scene_id then
            tip_text = string.format(ui_word.JION_NOT_SAME_PORT_TIPS, area_info[target_id - IS_PORT].name)
        else
            call_back()
        end
    else
        if self_in_scene_id and self_in_scene_id == target_id then
            call_back()
        else --队伍在无人海域
            tip_text = string.format(ui_word.JION_NOT_SAME_PORT_TIPS, ui_word.NONE_PEOPLE_SCENE)
        end
    end
    if tip_text then--跳转需消耗判断
        local red_tips = ui_word.USE_TRANSFER_ITEM_NONENOUNGH_STR
        local is_enough, cost_num, cost_type, cost_id, user_own = self:checkCostIsEnough()
        if user_own then --道具充足
            cost_num = string.format("%s/%s", user_own, cost_num)
            red_tips = nil
        end
        if not is_enough then
            panel = ClsAlert:showJumpWindow(DIAMOND_NOT_ENOUGH_GOSHOP, nil, {need_cash = cost_num, come_type = ClsAlert:getOpenShopType().VIEW_3D_TYPE, enter_call = not_enough_call_back})
        else
            panel = ClsAlert:showCostDetailTips(tip_text, ui_word.USE_TO_TARGER_TEAM_STR, cost_type, cost_id, cost_num, 
                ui_word.USE_TRANSFER_ITEM_STR, function()
                    call_back()
                end,{red_tips = red_tips, btn_name = ui_word.MAIN_OK})
        end
    end
    return panel
end

function ClsTeamData:checkCostIsEnough()
    local ITEM_ID = TRANSFER_ITEM.ID
    local ITEM_COST = 1
    local DIAMOND_COST = TRANSFER_ITEM.NEED_GOLD
    local user_diamond = getGameData():getPlayerData():getGold()
    local propDataHandle = getGameData():getPropDataHandler()
    local get_item = propDataHandle:get_propItem_by_id(ITEM_ID) or {count = 0}

    if get_item.count >= ITEM_COST then
        return true, ITEM_COST, ITEM_INDEX_PROP, ITEM_ID, get_item.count
    elseif user_diamond >= DIAMOND_COST then
        return true, DIAMOND_COST, ITEM_INDEX_GOLD
    end
    return false, DIAMOND_COST
end

function ClsTeamData:handleChatEvent(event_type, send_id, address_id)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    if ClsSceneManage:doLogic("checkAlert") then return end

    if self:isTeamLock(true) then return end
    
    local call_back = nil
    if event_type == GUILD_TYPE then
        call_back = function()
            self:receiveGuildInvite(tonumber(send_id))
        end
    elseif event_type == WORLD_TYPE then
        call_back = function()
            self:handleTeamInvite(tonumber(send_id), 1, 0)
        end
    else
        call_back = function()
            self:askJoinTeam(tonumber(send_id))
        end
    end
    self:toEnterOtherTeam(address_id, call_back)
end

function ClsTeamData:getGuildCDTime()
    return self.m_guild_cd
end

function ClsTeamData:setGuildCDTime(curTime)
    self.m_guild_cd = curTime
end

--成功进队要检查关掉的界面(以后在这扩展)
local PANEL_NAME = {
    "ClsRelicDiscoverUI",
}

function ClsTeamData:toClosePanel()
    for _,name in ipairs(PANEL_NAME) do
        if getUIManager():isLive(name) then
            getUIManager():close(name)
        end
    end
end

return ClsTeamData