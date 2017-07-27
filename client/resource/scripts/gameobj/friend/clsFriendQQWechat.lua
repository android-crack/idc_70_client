local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local uiTools = require("gameobj/uiTools")
local common_funs = require("gameobj/commonFuns")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsAlert = require("ui/tools/alert")
local OVER_DAY = 7 --超过天数召回

local ClsQQWechatCell = class("ClsQQWechatCell", ClsScrollViewItem)
function ClsQQWechatCell:updateUI(cell_date, panel)
    self.data = cell_date
    local widget_info = {
        [1] = {name = "rank_pic"},
        [2] = {name = "head_containt"},
        [3] = {name = "head_icon"},
        [4] = {name = "wechat_name"},
        [5] = {name = "player_level"},
        [6] = {name = "job_icon"},
        [7] = {name = "player_name"},
        [8] = {name = "prestige_num"},
        [9] = {name = "qq_icon"},
        [10] = {name = "vip_qq_icon"},
        [11] = {name = "have_add"},
        [12] = {name = "state_text"},
        [13] = {name = "qq_start"},
        [14] = {name = "wechat_start"},
        [15] = {name = "btn_recall"},
        [16] = {name = "wechat_icon"}
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(panel, v.name)
    end
    self.head_containt:setClippingEnable(true)

    self.qq_start:addEventListener(function()
        getUIManager():create("gameobj/tips/clsBootRewardTips")
    end, TOUCH_EVENT_ENDED)

    self.wechat_start:addEventListener(function()
        local show_txt = string.format(ui_word.FRIEND_LAUNCH_TIP, ui_word.FRIEND_TAB_WECHAT)
        ClsAlert:warning({msg = show_txt})
    end, TOUCH_EVENT_ENDED)

    self.wechat_icon:addEventListener(function()
        local show_txt = string.format(ui_word.FRIEND_LAUNCH_TIP, ui_word.FRIEND_TAB_WECHAT)
        ClsAlert:warning({msg = show_txt})
    end, TOUCH_EVENT_ENDED)

    local btn_visible = self.btn_recall.setVisible
    function self.btn_recall:setVisible(enable)
        btn_visible(self, enable)
        self:setTouchEnabled(enable)
    end

    local friend_data = getGameData():getFriendDataHandler()
    self.btn_recall:setPressedActionEnabled(true)
    local is_online = friend_data:isOnline(self.data.uid)
    if is_online then
        self.btn_recall:setVisible(false)
    else
        self.btn_recall:setVisible(friend_data:isCanRecall(self.data.uid))      
    end
    if self.btn_recall:isVisible() and GTab.IS_VERIFY then
        self.btn_recall:setVisible(false)
    end
    self.btn_recall:addEventListener(function ( )
        local friend_data_handle = getGameData():getFriendDataHandler()
        friend_data_handle:askFriendCallBack(self.data.uid)

    end, TOUCH_EVENT_ENDED)
    local pic = nil
    if not self.data.is_loading then
        pic = friend_data:getLocalPic(self.data.uid)
    else
        pic = "ui/seaman/seaman_101.png"
    end

    if not pic then 
        pic = "ui/seaman/seaman_101.png"
    end

    self.head_icon:changeTexture(pic, UI_TEX_TYPE_LOCAL)
    local bg_size = self.head_containt:getSize()
    local sp_size = self.head_icon:getSize()
    local scale_width = bg_size.width / sp_size.width
    local scale_height = bg_size.height / sp_size.height
    local scale = math.min(scale_height, scale_width)
    self.head_icon:setScale(scale)
    
    local show_name = self.data.name
    local len = common_funs:utfstrlen(show_name)
    if len > 7 then
        show_name = string.format("%s%s", common_funs:utf8sub(show_name, 1, 7), ui_word.SIGN_THREE_POINT)
    end
    self.wechat_name:setText(show_name)
    self.player_level:setText(string.format("Lv.%d", self.data.gameLevel))
    self.player_name:setText(self.data.gameName)
    self.prestige_num:setText(self.data.gamePrestige)

    local friend_data = getGameData():getFriendDataHandler()
    local cur_status = friend_data:getVipStatus(self.data.uid)
    self.qq_icon:setVisible(cur_status == PLAYER_VIP)
    self.vip_qq_icon:setVisible(cur_status == PLAYER_SVIP) 

    local launch_kind = friend_data:getLaunchKind(self.data.uid)
    self.qq_start:setVisible(launch_kind == LAUNCH_KIND_QQ)
    self.wechat_start:setVisible(launch_kind == LAUNCH_KIND_WECHAT) 
    self.qq_start:setTouchEnabled(launch_kind == LAUNCH_KIND_QQ)
    self.wechat_start:setTouchEnabled(launch_kind == LAUNCH_KIND_WECHAT)
    self.wechat_icon:setVisible(launch_kind == LAUNCH_KIND_WECHAT)
    self.wechat_icon:setTouchEnabled(launch_kind == LAUNCH_KIND_WECHAT)
    
    --奖杯
    if self.data.index then
        self.rank_pic:setVisible(true)
        local res = string.format("common_top_%s.png", self.data.index)
        self.rank_pic:changeTexture(res, UI_TEX_TYPE_PLIST)
    else
        self.rank_pic:setVisible(false)
    end

    --职业
    local role_icon = JOB_RES[self.data.gameRole]
    self.job_icon:changeTexture(role_icon, UI_TEX_TYPE_PLIST)

    --是否已经是好友了
    local is_friend = friend_data:isMyFriend(self.data.uid)
    self.have_add:setVisible(is_friend)

    --登陆状态
    local last_login_time_text, latest_login_time = uiTools:getLoginStatus(self.data.lastLoginTime)
    self.state_text:setText(last_login_time_text)
    self.state_text:setOpacity(255)--先还原
    if self.data.lastLoginTime ~= ONLINE then
        self.state_text:setOpacity(255 / 2)
    end
end

function ClsQQWechatCell:onTap(x, y)
    local player_data = getGameData():getPlayerData()
    if player_data:getUid() == self.data.uid then --是自己
        return
    end
    
    local ui = getUIManager():get("ClsQQWechatExpand")
    if tolua.isnull(ui) then --扩展面板不存在
        ui = getUIManager():create("gameobj/friend/clsQQWechatExpand")
    else
        if ui:isOnePerson(self.m_cell_date.uid) then
            getUIManager():close("ClsQQWechatExpand")
            return
        end
    end
    
    ui:setBindCell(self)
end

local ClsFriendQQWechat = class("ClsFriendQQWechat", function() return UIWidget:create() end)
function ClsFriendQQWechat:ctor()
    self:configUI()
    self:configEvent()
    self:updateListView()
end

function ClsFriendQQWechat:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_wechat.json")
    self:addChild(self.panel)

    local widget_info = {
        [1] = {name = "award_icon"},
        [2] = {name = "award_txt"},
        [3] = {name = "wechat_friend_amount"},
        [4] = {name = "btn_invite"},
        [5] = {name = "wechat_title"},
        [6] = {name = "wechat_friend"},
        [7] = {name = "award_amount"}
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end

    self.friend_relation_target1 = getConvertChildByName(self.panel, "friend_relation_target1")
    self.friend_relation_target2 = getConvertChildByName(self.panel, "friend_relation_target2")

    local friend_data = getGameData():getFriendDataHandler()
    local cur_platform = friend_data:getPlatform()
    if cur_platform == PLATFORM_QQ then
        self.wechat_title:setText(ui_word.FRIEND_QQ_TITLE)
        self.wechat_friend:setText(ui_word.FRIEND_QQ_FRIEND_TIP)
    elseif cur_platform == PLATFORM_WEIXIN then
        self.wechat_title:setText(ui_word.FRIEND_WECHAT_TITLE)
        self.wechat_friend:setText(ui_word.FRIEND_WECHAT_FRIEND_TIP)
    end

    self:updateRewardInfo()
end

function ClsFriendQQWechat:configEvent()
    self.btn_invite:setTouchEnabled(true)
    self.btn_invite:setPressedActionEnabled(true)
    self.btn_invite:addEventListener(function() 
        local share_data = getGameData():getShareData()
        share_data:share("friend_invite")
    end, TOUCH_EVENT_ENDED)
    self.btn_invite:setVisible(not GTab.IS_VERIFY)
end

function ClsFriendQQWechat:updateRewardInfo()
    local friend_data = getGameData():getFriendDataHandler()
    local relation_info = friend_data:getCurRelationStage()
    if relation_info then
        self.friend_relation_target1:setVisible(true)
        self.friend_relation_target2:setVisible(false)
        self.award_icon:changeTexture(relation_info.img, UI_TEX_TYPE_PLIST)
        self.award_amount:setText(relation_info.reward_num)
        self.wechat_friend:setText(relation_info.desc)
        local cur_num = friend_data:getCurFriendNum()
        if relation_info.kind == 'level' then
            cur_num = friend_data:getCurFriendLevel()
        end
        self.wechat_friend_amount:setText(string.format("%d/%d", cur_num, relation_info.goal_value))
    else
        self.friend_relation_target1:setVisible(false)
        self.friend_relation_target2:setVisible(true)
    end
end

function ClsFriendQQWechat:updateListView(content)
    if not content then 
        local friend_data = getGameData():getFriendDataHandler()
        content = friend_data:getQQWechatList()
    end

    if not content or #content < 1 then cclog("数据为空") return end

    self.list_view = ClsScrollView.new(785, 353, true, function()
        local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/friend_wechat_cell.json")
        return cell_ui
    end, {is_fit_bottom = true})

    self.cells = {}
    for k, v in ipairs(content) do
        local cell = ClsQQWechatCell.new(CCSize(768, 104), v)
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(185, 90))
    self:addChild(self.list_view)
end

function ClsFriendQQWechat:updateCell(uid)
    if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.uid == uid then
            if v:getIsCreate() then
                v:callUpdateUI()
            end
        end
    end
end

return ClsFriendQQWechat