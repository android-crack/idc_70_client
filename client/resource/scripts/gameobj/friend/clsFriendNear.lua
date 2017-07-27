local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local uiTools = require("gameobj/uiTools")
local role_info = require("game_config/role/role_info")
local common_funs = require("gameobj/commonFuns")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsNearFriendCell = class("ClsNearFriendCell", ClsScrollViewItem)
function ClsNearFriendCell:updateUI(cell_date, panel)
    self.data = cell_date
    local widget_info = {
        {name = "state_text"},
        {name = "head_containt"},
        {name = "head_icon"},
        {name = "near_name"},
        {name = "player_level"},
        {name = "job_icon"},
        {name = "player_name"},
        {name = "prestige_num"},
        {name = "have_add"},
        {name = "distance_text"}
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(panel, v.name)
    end
    self.head_containt:setClippingEnable(true)

    local friend_data = getGameData():getFriendDataHandler()
    local pic = friend_data:loadPlayerPic(self.data.uid, self.data.local_info.pictureSmall, function (error_id, file_url)
            if not tolua.isnull(self) and not tolua.isnull(self.head_icon) then
                local pic = friend_data:loadPlayerPic(self.data.uid, self.data.local_info.pictureSmall)
                self.head_icon:changeTexture(pic, UI_TEX_TYPE_LOCAL)
            end
        end)
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
    
    local show_name = self.data.local_info.nickName
    local len = common_funs:utfstrlen(show_name)
    if len > 7 then
        show_name = string.format("%s%s", common_funs:utf8sub(show_name, 1, 7), ui_word.SIGN_THREE_POINT)
    end
    self.near_name:setText(show_name)
    self.player_level:setText(string.format("Lv.%d", self.data.gameLevel))
    self.player_name:setText(self.data.gameName)
    self.prestige_num:setText(self.data.gamePrestige)
    self.distance_text:setText(string.format("%dM", self.data.local_info.distance))

    local friend_data = getGameData():getFriendDataHandler()
    --职业
    local role_icon = JOB_RES[self.data.gameRole]
    self.job_icon:changeTexture(role_icon, UI_TEX_TYPE_PLIST)

    --是否已经是好友了
    local is_friend = friend_data:isMyFriend(self.data.uid)
    self.have_add:setVisible(is_friend)

    --登陆状态
    self.state_text:setVisible(false)
end

function ClsNearFriendCell:onTap(x, y)
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

local ClsFriendNear = class("ClsFriendNear", function() return UIWidget:create() end)

function ClsFriendNear:ctor()
	self:configUI()
end

function ClsFriendNear:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_near.json")
    self:addChild(self.panel)

    local widget_info = {
        [1] = {name = "hide_person_check"}, 
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end

    self:updateListView()
end

function ClsFriendNear:updateListView()
    local friend_data = getGameData():getFriendDataHandler()
    local temp_friend = friend_data:getNeatFriend()
    if not temp_friend then return end
    local max_count = #temp_friend
    if max_count > 20 then max_count = 20 end
    local near_friend = {}
    for i = 1,max_count do
        near_friend[i] = temp_friend[i]
    end
    table.sort(near_friend, function (a, b)
        if tonumber(a.local_info.distance) == tonumber(b.local_info.distance) then
            return a.gamePrestige >= b.gamePrestige
        end
        return tonumber(a.local_info.distance) < tonumber(b.local_info.distance)
    end)

    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
    end

    self.list_view = ClsScrollView.new(785, 423, true, function()
        local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/friend_near_cell.json")
        return cell_ui
    end, {is_fit_bottom = true})

    self.cells = {}
    for k, v in ipairs(near_friend) do
        local cell = ClsNearFriendCell.new(CCSize(768, 104), v)
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(185, 20))
    self:addChild(self.list_view)
end

return ClsFriendNear