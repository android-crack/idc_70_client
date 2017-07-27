local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local Alert = require("ui/tools/alert")
local ClsChatBubble = require("gameobj/chat/clsChatBubble")

local ClsOtherChatBubble = class("ClsOtherChatBubble", ClsChatBubble)
function ClsOtherChatBubble:updateUI(cell_date, panel)
    self.cell_date = cell_date
    self:configUI()
    self:configEvent()
end

function ClsOtherChatBubble:onLongTap(x, y)
	if not tolua.isnull(self.m_chat_richlabel) then
        local chat_component = getUIManager():get("ClsChatComponent")
        local main_ui = chat_component:getPanelByName("ClsChatSystemMainUI")
        local cur_panel = main_ui:getCurPanel()
        if type(cur_panel.setEidtBoxStr) == "function" then
            cur_panel:setEidtBoxStr(self.m_chat_richlabel:getStringText())
            Alert:warning({msg = ui_word.STR_HAS_COPY})
        end
	end
end

function ClsOtherChatBubble:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/chat_other.json")
    self:addChild(self.panel)
    self.super.configUI(self)

    local data = self.cell_date
    local label = self:createRichLable(data)
	self.m_chat_richlabel = label
    local label_size = label:getSize()
    local base_data = self:setBubbleSize(label)

    local offset_x = (base_data.bubble_total_width - base_data.jiantou_bianju - label_size.width) / 2
    local pos_x = offset_x + base_data.jiantou_bianju

    local offset_y = (base_data.bubble_total_height - label_size.height) / 2
    local pos_y = offset_y - base_data.bubble_total_height
    label:setPosition(ccp(pos_x, pos_y))

    self.name:setText(string.format(ui_word.NAME_BOX_WITH_TIME, data.senderName, os.date("%H:%M", data.time)))
    self.name:setVisible(data.sender ~= GAME_SYSTEM_ID)

    self:createHead(data)

    self.main_chat_other = getConvertChildByName(self.panel, "main_chat_other")
    local origin_size = self.main_chat_other:getSize()
    local origin_width = origin_size.width

    local head_size = self.btn_avatar_bg:getSize()
    local head_height = head_size.height
    local top_offset = 15
    local name_offset = 20
    local juli = head_height / 4
    local bottom_offset = 10
    local bubble_height = math.max((3 * head_height) / 4, base_data.bubble_total_height)
    local cell_height = juli + bottom_offset + bubble_height

    local bg_avatar_pos = self.btn_avatar_bg:getPosition()
    local bubble_pos = self.bubble:getPosition()
    local name_pos = self.name:getPosition()
    local head_container_pos = self.head_container:getPosition()

    local cell_size = CCSize(origin_width, cell_height)
    self.main_chat_other:setSize(cell_size)
    self.chat:setSize(cell_size)
    self:setHeight(cell_height)

    self.btn_avatar_bg:setPosition(ccp(bg_avatar_pos.x, cell_height - top_offset - head_height / 2))
    self.bubble:setPosition(ccp(bubble_pos.x, cell_height - top_offset - head_height / 4))
    self.name:setPosition(ccp(name_pos.x, cell_height - name_offset))

    self:updateListPos()
end

--查看船长信息
function ClsOtherChatBubble:checkRoleInfo()
    local playerData = getGameData():getPlayerData()
    if self.m_cell_date.sender == playerData:getUid() then
        getUIManager():create("gameobj/playerRole/clsRoleInfoView")
    else
        getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil,self.m_cell_date.sender)
    end
end

--添加好友
function ClsOtherChatBubble:addFriend()
    local friend_data = getGameData():getFriendDataHandler()
    local num = friend_data:getFriendNum()
    if num < FRIENT_MAX_NUM then
        friend_data:askRequestAddFriend(self.m_cell_date.sender)
    else
        Alert:warning({msg = ui_word.FRIEND_ADD_FAILED})
    end
end

--申请加入队伍
function ClsOtherChatBubble:inviteJoinTeam()
    local team_data = getGameData():getTeamData()
    team_data:handleChatEvent(3, self.server_info.teamId, self.server_info.sceneId)
end

--组队邀请
function ClsOtherChatBubble:askInviteAssembTeam()
    local team_data = getGameData():getTeamData()
    team_data:inviteFriend(self.m_cell_date.sender)
end

--邀请入会
function ClsOtherChatBubble:inviteJoinGuild()
    local guild_search_data = getGameData():getGuildSearchData()
    guild_search_data:askInvitePerson(self.m_cell_date.sender)
end

--申请入会
function ClsOtherChatBubble:applyJoinGuild()
    local guild_search_data = getGameData():getGuildSearchData()
    guild_search_data:askApplyGuild(self.server_info.groupId)
end

--拉黑名单
function ClsOtherChatBubble:putBlack()
    local chat_data = getGameData():getChatData()
    chat_data:putInBlackList(self.m_cell_date)
    chat_data:askJoinBlackList(self.m_cell_date.sender, 1)
end

--私聊
function ClsOtherChatBubble:goPrivate()
    local component_ui = getUIManager():get("ClsChatComponent")
    local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    main_ui:setPlayerBtnInfo(PLAYER_STATUS_PRIVATE, {uid = self.m_cell_date.sender, name = self.m_cell_date.senderName})
    main_ui:executeSelectTabLogic(INDEX_PLAYER)
end

--删除记录
function ClsOtherChatBubble:deleteRecord()
    local chat_data = getGameData():getChatData()
    chat_data:deleteMsgRecord(self.m_cell_date.sender)
end

local event_by_kind = {
    ["checkRoleInfo"] = ClsOtherChatBubble.checkRoleInfo,
    ["addFriend"] = ClsOtherChatBubble.addFriend,
    ["inviteJoinTeam"] = ClsOtherChatBubble.inviteJoinTeam,
    ["askInviteAssembTeam"] = ClsOtherChatBubble.askInviteAssembTeam,
    ["inviteJoinGuild"] = ClsOtherChatBubble.inviteJoinGuild,
    ["putBlack"] = ClsOtherChatBubble.putBlack,
    ["goPrivate"] = ClsOtherChatBubble.goPrivate,
    ["deleteRecord"] = ClsOtherChatBubble.deleteRecord,
    ["applyJoinGuild"] = ClsOtherChatBubble.applyJoinGuild
}

--下面的条件解释
local btn_info = {
    [1] = {info = {text = ui_word.CHAT_EXPAND_PLAYER_INFO, event = "checkRoleInfo"}},
    [2] = {condition = {["friend"] = false, ["open_friend"] = true}, info = {text = ui_word.CHAT_EXPAND_ADD_FRIEND, event = "addFriend"}},
    [3] = {condition = {["other_in_team"] = false, ["on_line"] = true, ["open_team"] = true}, info = {text = ui_word.CHAT_EXPAND_INVITE_JOIN_TEAM, event = "askInviteAssembTeam"}},
    [4] = {condition = {["other_in_team"] = true, ["me_in_team"] = false, ["open_team"] = true}, info = {text = ui_word.CHAT_EXPAND_ASK_JOIN_TEAM, event = "inviteJoinTeam"}},
    [5] = {condition = {["me_in_guild"] = true, ["other_in_guild"] = false, ["open_guild"] = true}, info = {text = ui_word.CHAT_EXPAND_INVITE_JOIN_GUILD, event = "inviteJoinGuild"}},
    [6] = {condition = {["me_in_guild"] = false, ["other_in_guild"] = true, ["open_guild"] = true}, info = {text = ui_word.CHAT_EXPAND_APPLY_JOIN_GUILD, event = "applyJoinGuild"}},
    [7] = {condition = {["on_line"] = true, ["pos_private"]= false}, info = {text = ui_word.CHAT_EXPAND_PRIVATE_CHAT, event = "goPrivate"}},
    [8] = {condition = {["in_black"] = false}, info = {text = ui_word.CHAT_EXPAND_PUT_IN_BLACK, event = "putBlack"}},
    [9] = {condition = {["pos_private"] = true}, info = {text = ui_word.CHAT_EXPAND_DELETER_CHAT, event = "deleteRecord"}},
}

function ClsOtherChatBubble:judgeShowView(server_info)
    self.server_info = server_info
    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    local is_auto_trade = auto_trade_data:inAutoTradeAIRun()
    
    local team_data = getGameData():getTeamData()
    local in_team = team_data:isInTeam()

    local guild_data = getGameData():getGuildInfoData()
    local in_guild = guild_data:hasGuild()

    local chat_data = getGameData():getChatData()
    local private_ui = chat_data:getPrivateListUI()
    local pos_private = not tolua.isnull(private_ui)

    local in_black = chat_data:isInBlack(self.m_cell_date.sender)

    local onOffData = getGameData():getOnOffData()
    local judge_result = {
        ["friend"] = (server_info.isFriend ~= 0),
        ["other_in_team"] = (server_info.teamId ~= 0),
        ["me_in_team"] = in_team,
        ["me_in_guild"] = in_guild,
        ["other_in_guild"] = (server_info.groupId ~= 0),
        ["in_black"] = in_black,
        ["on_line"] = (server_info.isOnline ~= 0),
        ["pos_private"] = pos_private,
        ["open_friend"] = (server_info.isFriend ~= -1),
        ["open_team"] = (server_info.teamId ~= -1),
        ["open_guild"] = (server_info.groupId ~= -1),
    }

    self.can_result = {}
    for k, v in ipairs(btn_info) do 
        local is_available = true
        if v.condition then
            for g, h in pairs(v.condition) do
                if judge_result[g] ~= h then
                    is_available = false
                    break
                end
            end
        end
        if is_available then
            self.can_result[#self.can_result + 1] = v.info
        end
    end
end

-- server_info结构对方的信息状态
-- isOnline
-- groupId
-- teamId
-- isFriend
-- inBlack

function ClsOtherChatBubble:createExpandWin(server_info)
    self:judgeShowView(server_info)
    if not self.can_result or #self.can_result < 0 then return end 
    self.btn_cells = {}
    for k, v in ipairs(self.can_result) do
        local panel = GUIReader:shareReader():widgetFromJsonFile("json/chat_expand.json")
        local btn = getConvertChildByName(panel, "btn")
        btn:setTouchEnabled(true)
        btn:setPressedActionEnabled(true)
        local btn_text = getConvertChildByName(panel, "btn_text")
        btn_text:setText(v.text)
        btn:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            getUIManager():close("ClsChatExpand")
            event_by_kind[v.event](self)
        end, TOUCH_EVENT_ENDED)
        table.insert(self.btn_cells, panel)
    end

    local parameter = {
        cells = self.btn_cells,
    }
    self.expand_win = getUIManager():create("gameobj/chat/clsChatExpand", nil, parameter)
end

function ClsOtherChatBubble:configEvent()
    self.head_container:addEventListener(function()
        if self.m_cell_date.sender == GAME_SYSTEM_ID then cclog("是系统") end

        local auto_trade_data = getGameData():getAutoTradeAIHandler()
        if auto_trade_data:getIsAutoTrade() then--自动经商中无法进行跳转操作
            return
        end

        local missionDataHandler = getGameData():getMissionData()
        local is_auto_status = missionDataHandler:getAutoPortRewardStatus()
        if is_auto_status then
            return
        end

        local chat_data = getGameData():getChatData()
        if chat_data:isChecking() then return end
        chat_data:setCheckObj(self)
        chat_data:askPlayerInfo(self.m_cell_date.sender)
    end, TOUCH_EVENT_ENDED)
    self.head_container:setTouchEnabled(true)
end

return ClsOtherChatBubble