local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local math_ceil = math.ceil
local math_fmod = math.mod
local btnFSize = CCSizeMake(0, 0)
local FixWidth = 58
local GuildEachMemberInfoPanel = class("GuildEachMemberInfoPanel", function() return UIWidget:create() end)


local DEACON_TOTAL_NUM = 5
local group_level = {
    GROUP_MEMBER_LEVEL_MEMBER,  -- 会员
    GROUP_MEMBER_LEVEL_DEACONRY,  -- 执事
    GROUP_MEMBER_LEVEL_VICE_CHAIRMAN, -- 副会长
    GROUP_MEMBER_LEVEL_CHAIRMAN,    --会长
}

function GuildEachMemberInfoPanel:createBtn(textStr, func)
    local btn = self.create_parent:createButton({scale=SMALL_BUTTON_SCALE, image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png", imageDisabled = "",
        text = textStr, fsize = 16,fcolor = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
    btn:regCallBack(func)
    btnFSize = btn:getContentSize()
    return btn
end

--is_apply:如果是申请的话，就只有一个信息查看按钮，否则就是商会成员的按钮表现
function GuildEachMemberInfoPanel:ctor(currentGuildInfo, pos, parent, is_apply,create_parent)
    if currentGuildInfo == nil then
        cclog("currentGuildInfo is nil")
    end
    self.create_parent = create_parent
    self.guildInfoData = getGameData():getGuildInfoData()
    if not self.guildInfoData:hasGuild() then
        return
    end
    self.currentGuildInfo = currentGuildInfo
    self.pos = pos
    self.parent = parent
    if is_apply then
        self:configApplyUI()
    else
        self:configUI()
    end
    self:configBg()
end

function GuildEachMemberInfoPanel:configBg()

    if #self.menuTab == 0 then return end 
    local btn_scale = 0.8
    local height = (btnFSize.height - 14) * #self.menuTab + 21

    local contentSize = CCSizeMake(btnFSize.width * btn_scale , height)

    local bg = CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame("common_9_tips2.png"))
    bg:setAnchorPoint(ccp(0, 0))
    bg:setPosition(ccp(0, 0))
    self:addCCNode(bg)
    bg:setContentSize(contentSize)

    local arrow_bg = CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame("common_btn_arrow3.png"))
    arrow_bg:setAnchorPoint(ccp(1, 0.5))
    self:addCCNode(arrow_bg)

    local num = #self.menuTab
    local indexNum = num
    local FixHDx = 5
    if num == 1 then
        FixHDx = 2
    end
    local posX = contentSize.width / 2
    local menu_layer = CCSprite:create()
    for i = 1, num do
        local tmpBtn = self.menuTab[indexNum]
        tmpBtn:setPosition(ccp(posX, (btnFSize.height / 2 + FixHDx) + (i - 1) * (btnFSize.height - 15)))
        indexNum = indexNum - 1
        menu_layer:addChild(tmpBtn)
    end

    self:addCCNode(menu_layer)

    local pos = self.pos
    pos.x = 550
    local show_pos_max_y = contentSize.height/2 + pos.y
    local show_pos_min_y = pos.y - contentSize.height/2
    local dis_y = contentSize.height / 2
    if show_pos_max_y > display.top then
        dis_y = dis_y + (show_pos_max_y - display.top)
    elseif show_pos_min_y < display.bottom then
        dis_y = dis_y + show_pos_min_y
    end
    pos.y = pos.y - dis_y
    arrow_bg:setPosition(ccp(8, dis_y))
    self:setPosition(self.pos)

    local Tips = require("ui/tools/Tips")
    Tips:runAction(self)
end

function GuildEachMemberInfoPanel:setTouch(enable)
    if tolua.isnull(self) then
        return
    end
    if not tolua.isnull(self.menu) then
        print("self.menu is ", enable)
        self.menu:setTouchEnabled(enable)
    end
end

function GuildEachMemberInfoPanel:guildVisitFriend()
    if self.currentGuildInfo then
        --收藏室
        local target_ui = getUIManager():get('ClsCollectMainUI')
        -- 如果不为空
        if not tolua.isnull(target_ui) then
            -- 先移除
            getUIManager():get("ClsCollectMainUI"):close()
        end
        -- 再添加
        local data = {}
        data.id = self.currentGuildInfo.uid
        target_ui = getUIManager():create('gameobj/port/clsCollectMainUI',nil,data)

    else
        cclog("self.currentGuildInfo is nil")
    end
    if not tolua.isnull(self:getParent()) then
        self:getParent():removeFromParentAndCleanup(true)
    end
end

function GuildEachMemberInfoPanel:changAuthority()
    if self.currentGuildInfo then
        local str = string.format(ui_word.STR_GUILD_CAHNGE_AUTHORITY_OPERATE, self.currentGuildInfo.name)
        Alert:showAttention(str, function()
            if self.currentGuildInfo then
                self.guildInfoData:changeAuthority(self.currentGuildInfo.uid, GROUP_MEMBER_LEVEL_CHAIRMAN)
            else
                cclog("self.currentGuildInfo is nil")
            end
        end)
    end
    if not tolua.isnull(self:getParent()) then
        self:getParent():removeFromParentAndCleanup(true)
    end
end

function GuildEachMemberInfoPanel:addFriendRequest()
    local friendHandler = getGameData():getFriendDataHandler()
    if self.currentGuildInfo then
        friendHandler:askRequestAddFriend(self.currentGuildInfo.uid)
    else
        cclog("self.currentGuildInfo is nil")
    end
    if not tolua.isnull(self:getParent()) then
        self:getParent():removeFromParentAndCleanup(true)
    end
end

function GuildEachMemberInfoPanel:kickGuildMember()
    if self.currentGuildInfo then
        local str = string.format(ui_word.STR_GUILD_KICK_OUT_OPERATE,self.currentGuildInfo.name)
        Alert:showAttention(str, function()
            if self.currentGuildInfo then
                self.guildInfoData:captainKickGuildMember(self.currentGuildInfo.uid)
            else
                cclog("self.currentGuildInfo is nil")
            end
        end)
    end
    if not tolua.isnull(self:getParent()) then
        self:getParent():removeFromParentAndCleanup(true)
    end
end

function GuildEachMemberInfoPanel:exitGuild()
    Alert:showAttention(ui_word.STR_GUILD_EXIT_OK_OR_CANCEL, function()
        if self.currentGuildInfo then
            self.guildInfoData:askExitGuild()
        else
            cclog("self.currentGuildInfo is nil")
        end
    end)
    if not tolua.isnull(self:getParent()) then
        self:getParent():removeFromParentAndCleanup(true)
    end
end

function GuildEachMemberInfoPanel:promoteGuildMember()
    if self.currentGuildInfo then

        local authority = self.currentGuildInfo.authority
        local change_authority = nil
        for i,v in ipairs(group_level) do
            if authority < v then
                change_authority = v
                break
            end
        end
        local str = string.format(ui_word.STR_GUILD_PROMOTE_AUTHORITY_OPERATE, self.currentGuildInfo.name, returnProfessionStr(change_authority))
        Alert:showAttention(str, function()
            if self.currentGuildInfo then
                local authority = self.currentGuildInfo.authority
                local change_authority = nil
                for i,v in ipairs(group_level) do
                    if authority < v then
                        change_authority = v
                        break
                    end
                end
                if change_authority then
                    self.guildInfoData:changeAuthority(self.currentGuildInfo.uid, change_authority)
                end
            else
                cclog("self.currentGuildInfo is nil")
            end
        end)
    end
    if not tolua.isnull(self:getParent()) then
        self:getParent():removeFromParentAndCleanup(true)
    end
end

function GuildEachMemberInfoPanel:reduceGuildMember()
    if self.currentGuildInfo then
        local authority = self.currentGuildInfo.authority
        local vice_chairman_num, deacon_num = getGameData():getGuildInfoData():getGuildViceChairmanAndDeaconNum()
        local change_authority = nil
        for i,v in ipairs(group_level) do
            if authority == v then
                change_authority = group_level[i - 1]
                if authority == GROUP_MEMBER_LEVEL_VICE_CHAIRMAN and deacon_num == DEACON_TOTAL_NUM  then
                    change_authority = group_level[i - 2]
                end

                break
            end
        end
        local str = string.format(ui_word.STR_GUILD_REDUCE_AUTHORITY_OPERATE, self.currentGuildInfo.name, returnProfessionStr(change_authority))

        Alert:showAttention(str, function()
            if self.currentGuildInfo then
                local authority = self.currentGuildInfo.authority
                if authority == GROUP_MEMBER_LEVEL_MEMBER then
                    return
                end
                local change_authority = nil
                for i,v in ipairs(group_level) do
                    if authority == v then
                        change_authority = group_level[i - 1]
                        if authority == GROUP_MEMBER_LEVEL_VICE_CHAIRMAN and deacon_num == DEACON_TOTAL_NUM  then
                            change_authority = group_level[i - 2]
                        end
                        break
                    end
                end
                if change_authority then
                    self.guildInfoData:changeAuthority(self.currentGuildInfo.uid, change_authority)
                end
            else
                cclog("self.currentGuildInfo is nil")
            end
        end)
    end
    if not tolua.isnull(self:getParent()) then
        self:getParent():removeFromParentAndCleanup(true)
    end
end

function GuildEachMemberInfoPanel:configApplyUI()

    self.menuTab = {}

    local btn_info = self:createBtn(ui_word.STR_SEE_GUILD_MEMBER_INFO_BTN, function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            local playerData = getGameData():getPlayerData()
            if self.currentGuildInfo.uid == playerData:getUid() then
                getUIManager():create("gameobj/playerRole/clsRoleInfoView")
            else
                getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil,self.currentGuildInfo.uid)
            end
            if not tolua.isnull(self:getParent()) then
                self:getParent():removeFromParentAndCleanup(true)
            end
        end)
    self.menuTab[#self.menuTab + 1] = btn_info
end

function GuildEachMemberInfoPanel:createChatComponent()
    getUIManager():close("ClsChatComponent")
    getUIManager():create("gameobj/chat/clsChatComponent", nil, {not_need_panel = true})
    local chat_component = getUIManager():get("ClsChatComponent")
    local main_ui = chat_component:getPanelByName("ClsChatSystemMainUI")
    local function closeCall()
        audioExt.playEffect(music_info.PORT_INFO_UP.res)
        main_ui:goOut()
    end
    main_ui:setCloseCall(closeCall)
    main_ui:setPlayerBtnInfo(PLAYER_STATUS_PRIVATE, {uid = self.currentGuildInfo.uid, name = self.currentGuildInfo.name})
    main_ui:executeSelectTabLogic(INDEX_PLAYER)
    main_ui:goInto()

    local close_rect = CCRect(483, 15, 475, 542)
    main_ui.bg_touch_panel:addEventListener(function()
        local pos = main_ui.bg_touch_panel:getTouchEndPos()
        if close_rect:containsPoint(ccp(pos.x, pos.y)) then
            closeCall()
        end
    end, TOUCH_EVENT_ENDED)
end

function GuildEachMemberInfoPanel:configUI()
    self.menuTab = {}
	local playerData = getGameData():getPlayerData()
    local onOffData = getGameData():getOnOffData()

    --退出公会
    if self.currentGuildInfo.uid ~= playerData:getUid() then

        -----查看信息
        local btn_info = self:createBtn(ui_word.STR_SEE_GUILD_MEMBER_INFO_BTN, function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            local playerData = getGameData():getPlayerData()
            if self.currentGuildInfo.uid == playerData:getUid() then
                getUIManager():create("gameobj/playerRole/clsRoleInfoView")
            else
                getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil,self.currentGuildInfo.uid)
            end
            if not tolua.isnull(self:getParent()) then
                self:getParent():removeFromParentAndCleanup(true)
            end
        end)
        self.menuTab[#self.menuTab + 1] = btn_info

        ---密聊
        local btn_talk = self:createBtn(ui_word.STR_WITH_TALK_BTN, function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:createChatComponent()
            if not tolua.isnull(self:getParent()) then
                self:getParent():removeFromParentAndCleanup(true)
            end
        end)
        self.menuTab[#self.menuTab + 1] = btn_talk

        ---好友申请
        --给好友发消息,跳转到发消息界面
        local btnFriendRequest = self:createBtn(ui_word.STR_FRIEND_APPLY, function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:addFriendRequest()
        end)
        self.menuTab[#self.menuTab + 1] = btnFriendRequest
        local friend_data_handler = getGameData():getFriendDataHandler()
        if not onOffData:isOpen(on_off_info.MAIN_FRIEND.value)
            or friend_data_handler:isMyFriend(self.currentGuildInfo.uid) then
            btnFriendRequest:setEnabled(false)
        end

        --移出公会
        if self.guildInfoData:isEidtNotice() then
            --if self.currentGuildInfo.authority ~= self.guildInfoData:playerAuthority() then
                --提升职位
                local btn_promote_job = self:createBtn(ui_word.STR_PROMOTE_GUILD_JOB, function()
                    audioExt.playEffect(music_info.COMMON_BUTTON.res)
                    self:promoteGuildMember()
                end)
                self.menuTab[#self.menuTab + 1] = btn_promote_job
                if (not self.guildInfoData:isCaptain() and self.currentGuildInfo.authority ~= GROUP_MEMBER_LEVEL_MEMBER) then --self.currentGuildInfo.authority == GROUP_MEMBER_LEVEL_VICE_CHAIRMAN or
                    btn_promote_job:setEnabled(false) --会长对副会长没有提升，而副会长只对会员有提升操作
                end

                --降低职位
                local btn_reduce_job = self:createBtn(ui_word.STR_REDUCE_GUILD_JOB, function()
                    audioExt.playEffect(music_info.COMMON_BUTTON.res)
                    self:reduceGuildMember()
                end)
                self.menuTab[#self.menuTab + 1] = btn_reduce_job
                if self.currentGuildInfo.authority == GROUP_MEMBER_LEVEL_MEMBER or
                    (not self.guildInfoData:isCaptain() and self.currentGuildInfo.authority ~= GROUP_MEMBER_LEVEL_DEACONRY) then
                    btn_reduce_job:setEnabled(false) --会员不能降低，副会长只对执事有降低操作
                end

                --移除商会
                local btnKick = self:createBtn(ui_word.STR_CHAIRMAN_GUILD_KICK_OUT, function()
                    audioExt.playEffect(music_info.COMMON_BUTTON.res)
                    self:kickGuildMember()
                end)
                self.menuTab[#self.menuTab + 1] = btnKick
                if (not self.guildInfoData:isCaptain() and self.currentGuildInfo.authority > GROUP_MEMBER_LEVEL_DEACONRY) then
                    btnKick:setEnabled(false) --副会长只对执事和会员有移出操作
                end
            --end
        end
    end
end

return GuildEachMemberInfoPanel
