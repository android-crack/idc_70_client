--
-- 队伍列表
--
local ui_word             = require("game_config/ui_word")
local music_info          = require("game_config/music_info")
local ClsAlert            = require("ui/tools/alert")
local time_plunder_info   = require("game_config/loot/time_plunder_info")
local team_config         = require("game_config/team/team_config")
local ClsGuideMgr         = require("gameobj/guide/clsGuideMgr")
local ClsScrollView       = require("ui/view/clsScrollView")
local ClsBusinessListCell = require("gameobj/team/clsBusinessTeamCell")

local btn_name_1 = {
    "btn_set_team",
    "btn_quick_team",
}

local btn_name_2 = {
    "btn_team",
    "btn_enter"
}

local widget = {
    "btn_panel_1",
    "btn_panel_2",
    "btn_panel_3",
    "text_bg",
    "award_text",
    "tips_text",
    "btn_team_text",
    "btn_enter_text",
    "join_tips",
    "activity_text",
    "activity_num",
    "activity_text_bg",
    "activity_other_text",
}

----------------------------------------------- ClsBusinessTeamList ---------------------------------------------
local ClsBusinessTeamList = class("ClsBusinessTeamList", function() return UIWidget:create() end)

function ClsBusinessTeamList:ctor()
    self.touch_status  = true
    self.team_cells    = {}
    self.m_list_view   = nil
    self.m_list_width  = 748
    self.m_list_height = 400

    self:initUi()
end

function ClsBusinessTeamList:onExit()
end

function ClsBusinessTeamList:initUi()
    self:updateListView()
end

function ClsBusinessTeamList:updateListView()
    if self.player_tips and not tolua.isnull(self.player_tips) then
        getUIManager():close("ClsSelectTeamType")
        self.player_tips = nil
    end
    getUIManager():close("ClsTeamExpandWin")

    if self.panel and not tolua.isnull(self.panel) then
        self.panel:removeFromParent()
        self.panel = nil
    end
    local ui = getUIManager():get("ClsPlayerTips")
    if not tolua.isnull(ui) then
        getUIManager():close("ClsPlayerTips")
    end
    self.team_cells = {}
    if self.m_list_view then
        self.m_list_view:removeFromParentAndCleanup(true)
        self.m_list_view = nil
    end
    local team_data = getGameData():getTeamData()
    local team_list_info = team_data:getTeamListInfo()

    self:mkBtn(getGameData():getTeamData():isInTeam())
    if #team_list_info <= 0 then
        return
    end

    self.m_list_view = ClsScrollView.new(self.m_list_width, self.m_list_height, true, function()
        local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/team_list.json")
        return cell_ui
    end)
    for i,v in ipairs(team_list_info) do
        self.team_cells[i] = ClsBusinessListCell.new(CCSize(738, 110), v)
    end
    self.m_list_view:addCells(self.team_cells)
    self.m_list_view:setPosition(ccp(204, 83))
    self:addChild(self.m_list_view)
end

function ClsBusinessTeamList:mkBtn(is_in_team, team_type)
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/team_btn.json")
    self.panel:setPosition(ccp(200, 10))
    self:addChild(self.panel)

    for k,v in ipairs(widget) do
        self[v] = getConvertChildByName(self.panel, v)
    end

    self.can_click = true

    local select_team_type = getGameData():getTeamData():getSelectTeamType()
    self:updateActivityInfo()

    if is_in_team then
        self.text_bg:setVisible(false)

        local team_invite_type = getGameData():getTeamData():getMyTeamInviteType()

        if team_invite_type  == TEAM_INVITE_TYPE.FREE then
            self.btn_team_text:setText(ui_word.TEAM_INVITE_FREE)
        else
            self.btn_team_text:setText(ui_word.TEAM_INVITE_INVITE)
        end
        if select_team_type == team_type then
            self.btn_panel_1:setVisible(false)
            self.btn_panel_2:setVisible(true)
            self.btn_panel_3:setVisible(false)
            for i,v in ipairs(btn_name_2) do
                self[v] = getConvertChildByName(self.panel, v)
                self[v]:setTouchEnabled(true)
                self[v]:setPressedActionEnabled(true)
            end

            local guide_parent = getUIManager():get("ClsPortTeamUI")
            guide_parent.btn_enter = self.btn_enter

            self.btn_team:addEventListener(function()
                audioExt.playEffect(music_info.PORT_INFO_UP.res)
                if self.can_click then
                    self.can_click = false
                    local ui = getUIManager():get("ClsSelectTeamType")
                    if tolua.isnull(ui) then
                        getUIManager():close("ClsSelectTeamType")
                        local pos = self.btn_team:convertToWorldSpace(ccp(-87, 18))
                        ui = getUIManager():create("gameobj/team/clsSelectTeamType", nil, pos)
                    else
                        getUIManager():close("ClsSelectTeamType")
                        self.player_tips = nil
                        return
                    end
                    self.player_tips = ui

                    local array = CCArray:create()
                    array:addObject(CCDelayTime:create(0.8))
                    array:addObject(CCCallFunc:create(function()
                        self.can_click = true
                    end))
                    local action = CCSequence:create(array)
                    self.btn_team:runAction(action)
                end
            end, TOUCH_EVENT_ENDED)
            if getGameData():getTeamData():isTeamLeader() then
                self.btn_enter:active()
            else
                self.btn_enter:disable()
            end
            self.btn_enter:addEventListener(function()
                audioExt.playEffect(music_info.COMMON_BUTTON.res)
                self:gotoMission()
            end, TOUCH_EVENT_ENDED)

            local team_types = getGameData():getTeamData():getTeamTypes()
            if select_team_type == team_types.TRADE_COMPLETE then
                self:updateTradeBtnShow()
            elseif select_team_type == team_types.SEVEN then
                self.btn_enter_text:setText(ui_word.SEVENT_ACTIVITY_ENTER)
            else
                self.btn_enter_text:setText(ui_word.TEAM_ENTER_ACTIVITY)
            end
        else
            self.btn_panel_1:setVisible(false)
            self.btn_panel_2:setVisible(false)
            self.btn_panel_3:setVisible(true)
            self.btn_change = getConvertChildByName(self.panel, "btn_change")
            self.btn_change:setPressedActionEnabled(true)
            self.btn_change:addEventListener(function()
                audioExt.playEffect(music_info.COMMON_BUTTON.res)
                getGameData():getTeamData():askChangeTeamType()
            end, TOUCH_EVENT_ENDED)
        end
    else
        self.btn_panel_1:setVisible(true)
        self.btn_panel_2:setVisible(false)
        self.btn_panel_3:setVisible(false)
        local team_data = getGameData():getTeamData()

        for i,v in ipairs(btn_name_1) do
            self[v] = getConvertChildByName(self.panel, v)
            self[v]:setTouchEnabled(true)
            self[v]:setPressedActionEnabled(true)
        end

        self.btn_set_team:addEventListener(function ( )
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            team_data:askCreateTeam()
        end, TOUCH_EVENT_ENDED)

        -- 快速组队按钮事件添加
        self.btn_quick_team:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)

            local is_enough, cost = getGameData():getTeamData():checkCostIsEnough()
            local tips_str = ui_word.QUICK_JOIN_TEAM_ENOUGH_TIPS
            if not is_enough then 
                tips_str = ui_word.QUICK_JOIN_TEAM_NOT_ENOUGH_TIPS
            end

            ClsAlert:showAttention(tips_str, function()
                team_data:askQuickJoin()
            end)

        end, TOUCH_EVENT_ENDED)
    end

     ClsGuideMgr:tryGuide("ClsPortTeamUI")
end

function ClsBusinessTeamList:updateTradeBtnShow()
    local trade_complete_data = getGameData():getTradeCompleteData()
    local status = trade_complete_data:getTaskStatus()
    if status == TASK_CAN_ACCEPT_STATUS then--能接受任务
        self.btn_enter_text:setText(ui_word.STR_ACCEPT)
    elseif status == TASK_ACCEPTED_STATUS then
        self.btn_enter_text:setText(ui_word.STR_GO)
    else
        self.btn_enter_text:setText(ui_word.STR_ACCEPT)
    end
end

function ClsBusinessTeamList:updateActivityInfo()
    local curType = getGameData():getTeamData():getSelectTeamType()
    local team_activity_txt = team_config[curType].team_activity_txt
    self.activity_num:setVisible(false)
    self.activity_text:setVisible(false)
    self.activity_other_text:setVisible(false)
    self.activity_text_bg:setVisible(team_activity_txt ~= '')
    if team_config[curType].activity_txt_need_num > 0 then
        local activityData = getGameData():getActivityData()
        self.activity_text:setText(team_activity_txt)
        local leaveTimes = activityData:getActivityLeaveTimes(team_config[curType].activity_id)
        if leaveTimes then
            self.activity_num:setVisible(true)
            self.activity_text:setVisible(true)
            local str = string.format(ui_word.TEAM_LIMIT_TIP, leaveTimes)
            if leaveTimes < 0 then
                str = string.format(ui_word.TEAM_LIMIT_TIP, ui_word.ACTIVITY_STR10)
            end
            self.activity_num:setText(str)
        end
    else
        if team_activity_txt == '' then return end
        self.activity_other_text:setVisible(true)
        self.activity_other_text:setText(team_activity_txt)
    end
end

function ClsBusinessTeamList:gotoMission()
    if IS_VIRTUA_TEAM then --假组队情况进入战斗
        local virtua_team_data = getGameData():getVirtuaTeamData()
        virtua_team_data:askToBattle()
        return
    end
    local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
    local my_team_info = getGameData():getTeamData():getMyTeamInfo()
    if not my_team_info then return end
    local team_id = my_team_info.type
    local layer_name = team_config[team_id].skip_info
    local has_not_suit = false
    local activity_need_level = team_config[team_id].limit
    local team_key = team_config[team_id].team_key
    for k, info in ipairs(my_team_info.info) do
        if info.grade < activity_need_level then
            has_not_suit = true
            ClsAlert:warning({msg = string.format(ui_word.NOT_SUIT_TEAM_ACTIVITY, info.name, activity_need_level)})
        end
    end
    if has_not_suit then return end

    if layer_name == "" then
        EventTrigger(EVENT_DEL_PORT_ITEM)
        return
    end

    if layer_name == "ports" then
        local mapAttrs = getGameData():getWorldMapAttrsData()
        local portData = getGameData():getPortData()
        local port_id = portData:getPortId() -- 当前港口id
        mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE, function()
        end, function()
            if tolua.isnull(self) then return end
        end)

    elseif layer_name =="reward" then
        EventTrigger(EVENT_MAIN_SELECT_LAYER, TYPE_LAYER_PORT)
        local DialogQuene = require("gameobj/quene/clsDialogQuene")
        local clsLoginAwardUIQuene = require("gameobj/quene/clsLoginAwardUIQuene")
        DialogQuene:insertTaskToQuene(clsLoginAwardUIQuene.new({func = function() EventTrigger(EVENT_DEL_PORT_ITEM) end}))
    elseif layer_name == "arena" then
        local arena_data_handler = getGameData():getArenaData()
        arena_data_handler:askPlayerArenaBaseInfo()

    elseif layer_name == "town" then
        -- 关闭主界面
        getUIManager():get("ClsActivityMain"):close()
        -- 等后续Ui框架优化,现在先这么处理
        -- 尝试获取
        local target_ui = getUIManager():get('clsPortTownUI')
        -- 如果不为空
        if not tolua.isnull(target_ui) then
            -- 先移除
            getUIManager():get("clsPortTownUI"):close()
        end
        -- 再添加
        getUIManager():create('gameobj/port/clsPortTownUI',nil,1)

    elseif layer_name == "trade_complete_ask" then--贸易经商
        local trade_complete_data = getGameData():getTradeCompleteData()
        local status = trade_complete_data:getTaskStatus()
        if status == TASK_CAN_ACCEPT_STATUS then--能接受任务
            local trade_complete_data = getGameData():getTradeCompleteData()
            trade_complete_data:askApply()
        elseif status == TASK_ACCEPTED_STATUS then--接了任务
            local trade_complete_data = getGameData():getTradeCompleteData()
            local info = trade_complete_data:getTradeCompleteInfo()
            if not info then return end
            local task_id = info.id
            local task_info = time_plunder_info[task_id]
            local go_port_id = task_info.mission_goal_port_id
            local supply_data = getGameData():getSupplyData()
            supply_data:askSupplyInfo(true, function()
                local map_attrs = getGameData():getWorldMapAttrsData()
                map_attrs:goOutPort(go_port_id, EXPLORE_NAV_TYPE_PORT)
            end)
        elseif status == TASK_FINISH_STATUS then
            ClsAlert:warning({msg = ui_word.TIME_LOOT_FINISH_TIP})
        else
            ClsAlert:warning({msg = ui_word.ACTIVITY_NOT_OPEN})
        end
    elseif layer_name == "sea_god_fight" then--海神战斗
        if getGameData():getTeamData():isTeamFull() then
            local activity_data = getGameData():getActivityData()
            activity_data:askSeaGodActivityStart()
        else
            ClsAlert:warning({msg = ui_word.TEAM_SEA_GOD_ENTER})
        end
    elseif layer_name == "guild_treasure" then
        --暂时把
        self:tryOpenBayUI()
    elseif layer_name == "market" then
        local market_layer = getUIManager():get("ClsPortMarket")
        if not tolua.isnull(market_layer) then
            getUIManager():close("ClsPortMarket")
        else
            missionSkipLayer:skipLayerByName(layer_name)
        end
    elseif layer_name == "seven" then
        local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
        local port_layer = getUIManager():get("ClsPortLayer")
        local port_team_ui = getUIManager():get("ClsPortTeamUI")
        if not tolua.isnull(port_layer) then
            port_layer:setTouch(false)
        end
        if not tolua.isnull(port_team_ui) then
            getUIManager():close("ClsPortTeamUI")
        end

        local ExplorePirate = getGameData():getExplorePirateEventData()
        local PirateInfo = ExplorePirate:getAllPirateInfo()
        local pirate_id = nil
        if PirateInfo and #PirateInfo ~= 0 then
            local t = {}
            for id, v in pairs(PirateInfo) do
                t[#t + 1] = id
            end
            pirate_id = t[table.random_key(t)]
        end
        missionSkipLayer:skipPortLayer({time_private_id = pirate_id})
    elseif layer_name == "mineral_point" then
        if #my_team_info.info < 2 then
            ClsAlert:warning({msg = ui_word.STR_TEAM_CANNOT_TIPS})
            return
        end
        local port_id = getGameData():getPortData():getPortId()
        local near_contend = port_info[port_id].near_contend
        local mineral_point_id = nil
        if near_contend then
            mineral_point_id = near_contend[math.random(#near_contend)]
        end
        local port_layer = getUIManager():get("ClsPortLayer")
        local port_team_ui = getUIManager():get("ClsPortTeamUI")
        local activity_main_ui = getUIManager():get("ClsActivityMain")
        if not tolua.isnull(port_layer) then
            port_layer:setTouch(false)
        end
        if not tolua.isnull(port_team_ui) then
            getUIManager():close("ClsPortTeamUI")
        end

        if not tolua.isnull(activity_main_ui) then
            getUIManager():close("ClsActivityMain")
        end
        missionSkipLayer:skipLayerByName("mineral_point", mineral_point_id)
    else
        missionSkipLayer:skipLayerByName(layer_name)
    end
end

function ClsBusinessTeamList:tryOpenBayUI()
    local MAX_MEMBER = 3 --满员是3个人
    local team_data = getGameData():getTeamData()
    local team_info = team_data:getMyTeamInfo().info
    if team_data:isLock(true) then
        return
    end

    if #team_info ~= MAX_MEMBER then
        ClsAlert:warning({msg = ui_word.COPY_PERSON_NOT_ENOUGH})
        return
    end

    --玩家身为队长并且组队满3人才可以发出邀请协议
    if team_data:isTeamLeader() and #team_info == MAX_MEMBER then
        local bay_data = getGameData():getBayData()
        bay_data:sendTeamAsk()
        return true
    end
end

return ClsBusinessTeamList