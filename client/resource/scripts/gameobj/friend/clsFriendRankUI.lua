local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsAlert = require("ui/tools/alert")
local uiTools = require("gameobj/uiTools")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsFriendScrollView = require("gameobj/friend/clsFriendScrollView")

local cell_info = {
	[1] = {name = "rank_pic"},
    [2] = {name = "head_icon"},
    [3] = {name = "player_name"},
    [4] = {name = "player_level"},
    [5] = {name = "friend_level"},
    [6] = {name = "friend_bar"},
    [7] = {name = "friend_number_txt"},
    [8] = {name = "shengwang_coin"},
    [9] = {name = "player_power_num"},
    [10] = {name = "state_text"},
    [11] = {name = "select_pic"},
    [12] = {name = "btn_give"},
    [13] = {name = "myself"},
    [14] = {name = "friend"},
    [15] = {name = "tag_qq"},
    [16] = {name = "tag_wechat"},
    [17] = {name = "tag_group"},

}

local ClsRankCell = class("ClsRankCell", ClsScrollViewItem)

function ClsRankCell:updateUI(cell_date, panel)
	local data = cell_date
	self.btn_tab = {}

	for k, v in ipairs(cell_info) do
        local item = getConvertChildByName(panel, v.name)
        item.name = v.name

        if item:getDescription() == "Button" then
            item:setPressedActionEnabled(true)
            local btn_visible_func = item.setVisible
            function item:setVisible(enable)
                btn_visible_func(self, enable)
                self:setTouchEnabled(enable)
            end
            table.insert(self.btn_tab, item)
        end

        self[v.name] = item
    end

    self.tag_qq.kind = PLATFORM_QQ
    self.tag_wechat.kind = PLATFORM_WEIXIN

    local player_data = getGameData():getPlayerData()
   
    if player_data:getUid() == data.uid then --是自己
        self:setAllBtnVisible(false)
        self.myself:setVisible(true)
        self.state_text:setVisible(false)
        self.friend:setVisible(false)
    else                                   --好友
        local friend_data_handler = getGameData():getFriendDataHandler()
        local is_in = friend_data_handler:isInUserList(data.uid)
        local cur_platform = friend_data_handler:getPlatform()
        self.tag_qq:setVisible(is_in and cur_platform == self.tag_qq.kind)
        self.tag_wechat:setVisible(is_in and cur_platform == self.tag_wechat.kind)

        local is_guild_friend = getGameData():getGuildInfoData():isGuildMember(data.uid)
        self.tag_group:setVisible((not is_in) and is_guild_friend)

        self:configCellBtnEvent()
        self.btn_give:setVisible(data.rank_status and data.rank_status ~= 0)
        local cur_intimacy_info = friend_data_handler:getIntimacyInfo(data.uid)
        if cur_intimacy_info then
            self.friend_level:setText(cur_intimacy_info.name)
            if friend_data_handler:isMaxIntimacy(data.uid) then
                self.friend_number_txt:setText("max")
                self.friend_bar:setPercent(100)
            else
                local get_intimacy = friend_data_handler:getCurIntimacy(data.uid)
                local offset = get_intimacy - cur_intimacy_info.min_exp
                local all = cur_intimacy_info.max_exp - cur_intimacy_info.min_exp
                self.friend_number_txt:setText(string.format("%d/%d", offset, all))
                self.friend_bar:setPercent(offset * 100 / all)
            end
        end
    end

    self.player_name:setText(data.name)
    self.player_level:setText(string.format("Lv.%s", data.level))
    self.player_power_num:setText(data.rank_zhandouli)

    local player_photo_id = nil
    if not data.icon or data.icon == "" or tonumber(data.icon) == 0 then
        player_photo_id = 101
    else
        player_photo_id = tonumber(data.icon)
    end

    local boat_id = data.boatId
    if not boat_id or boat_id == 0 then
        boat_id = 1
    end

    self.head_icon:changeTexture(sailor_info[player_photo_id].res, UI_TEX_TYPE_LOCAL)
    local head_size = self.head_icon:getContentSize()
    self.head_icon:setScale(90 / head_size.height)

    local last_login_time_text, latest_login_time = uiTools:getLoginStatus(data.lastLoginTime)
    self.state_text:setText(last_login_time_text)
    self.state_text:setOpacity(255)--先还原
    if data.lastLoginTime ~= ONLINE then
        self.state_text:setOpacity(255 / 2)
    end

    if data.index then
        self.rank_pic:setVisible(true)
        local res = string.format("common_top_%s.png", data.index)
        self.rank_pic:changeTexture(res, UI_TEX_TYPE_PLIST)
    else
        self.rank_pic:setVisible(false)
    end
end

function ClsRankCell:setAllBtnVisible()
	for k, v in ipairs(self.btn_tab) do
        if not tolua.isnull(v) then
            v:setVisible(enable)
        end
    end	
end

function ClsRankCell:onTap(x, y)
    local select_cell = self.m_scroll_view.select_cell
    if not tolua.isnull(select_cell) then
        select_cell.select_pic:setVisible(false)
    end

    self.select_pic:setVisible(true)
    self.m_scroll_view.select_cell = self

    local main_ui = getUIManager():get("ClsFriendMainUI")
    main_ui:openExpandPanel(self)
end

function ClsRankCell:configCellBtnEvent()
	local friend_data_handler = getGameData():getFriendDataHandler()
	--赠送礼物
    self.btn_give:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local cur_platform = friend_data_handler:getPlatform()
        local function btnCall()
            friend_data_handler:askSendPowerToFriend(self.m_cell_date.uid) 
        end
        if GTab.IS_VERIFY then
            btnCall()
            return
        end
        local is_in = nil
        local uid = self.m_cell_date.uid
        if cur_platform == PLATFORM_QQ then
            is_in = friend_data_handler:isInUserList(uid)
            if is_in then
                local show_txt = string.format(ui_word.FRIEND_NOTICE_SURE, ui_word.FRIEND_TAB_QQ)
                ClsAlert:showAttention(show_txt, function()
                    btnCall()
                    local open_id = friend_data_handler:getOpenId(uid)
                    local share_data =  getGameData():getShareData()
                    share_data:shareToFriend(open_id, "friend_heart")
                end, nil, btnCall)
            else
                btnCall()
            end
        elseif cur_platform == PLATFORM_WEIXIN then
            is_in = friend_data_handler:isInUserList(uid)
            if is_in then
                getUIManager():create("gameobj/friend/clsFriendTipUI", nil, {uid = uid, kind = NOITCE_SEND_GIFT_TIP, btnCall = btnCall})
            else
                btnCall()
            end
        else
            btnCall()
        end
    end, TOUCH_EVENT_ENDED)
end

local ClsFriendRankUI = class("ClsFriendRankUI", function() return UIWidget:create() end)
function ClsFriendRankUI:ctor()
    self:configUI()
    self:updateListView()
end

function ClsFriendRankUI:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_prestige.json")
    self:addChild(self.panel)

    self.send_tili_num = getConvertChildByName(self.panel, "send_tili_num")
    self:updateTimes()
end

function ClsFriendRankUI:updateListView(content)
	if not content then
		local friend_data = getGameData():getFriendDataHandler() 
		content = friend_data:getRankList()
	end

	--不论有无数据都先清空列表
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end

	if not content then cclog("没有好友数据") return end

	self.list_view = ClsFriendScrollView.new(785, 420, true, function()
		local cell = GUIReader:shareReader():widgetFromJsonFile("json/friend_my_friend_cell.json")
        return cell
    end)

    self.list_view:setMoveCall(function() 
        local main_ui = getUIManager():get("ClsFriendMainUI")
        main_ui:closeExpandPanel()
   	end)

    self.cells = {}
    for k, v in ipairs(content) do
        local cell = ClsRankCell.new(CCSize(768, 104), v)
        self.cells[#self.cells + 1] = cell
    end

    self.getGiveGuideObj = function()
        if not self.cells then return end
        local guide_layer = self.list_view:getInnerLayer()
        for k, cell in ipairs(self.cells) do
            if cell.m_cell_date.uid == ROBOT_FRIEND_ID and cell.m_cell_date.rank_status ~= 0 then
                local world_pos = cell:convertToWorldSpace(ccp(651, 47))
                local parent_pos = guide_layer:convertToWorldSpace(ccp(0,0))
                local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
                return guide_layer, guide_node_pos, {['w'] = 133, ['h'] = 40}
            end
        end
    end

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCCallFunc:create(function() 
        local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
        ClsGuideMgr:tryGuide("ClsFriendMainUI")
    end))
    self:runAction(CCSequence:create(arr))

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(185, 13))
    self:addChild(self.list_view)
end

function ClsFriendRankUI:updateCell(info)
    if tolua.isnull(self.list_view) then
        print("创建listview")
        self:updateListView()
        return
    end
    
    local is_exist = false
    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.uid == info.uid then
            is_exist = true
            info.index = v.m_cell_date.index
            v.m_cell_date = info
            if v:getIsCreate() then
                v:callUpdateUI()
            end
        end
    end

    if not is_exist then
        local cell = ClsRankCell.new(CCSize(768, 104), info)
        self.list_view:addCell(cell)
    end
end

function ClsFriendRankUI:updateCellBtnStatus(list) --更新排行列表按钮状态
    if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(list) do
        for i, j in ipairs(self.list_view.m_cells) do
            if v.friendId == j.m_cell_date.uid then
                j.m_cell_date.rank_status = v.rank_status
                j.m_cell_date.gift_status = v.gift_status
                j.m_cell_date.intimacy = v.intimacy

                if j:getIsCreate() then
                    j:callUpdateUI()
                end
            end
        end
    end
end

function ClsFriendRankUI:removeCellByUid(uid)
    if tolua.isnull(self.list_view) then return end

    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.uid == uid then
            self.list_view:removeCell(v)
        end
    end
end

function ClsFriendRankUI:updateTimes()
    local friend_data_handler = getGameData():getFriendDataHandler()
    local send_times = friend_data_handler:getSendTimes()
    self.send_tili_num:setText(string.format("%s/%s", send_times, MAX_SEND_POWER))
end

return ClsFriendRankUI

