local ui_word = require("scripts/game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsChatPanelBase = require("gameobj/chat/clsChatPanelBase")
local ClsPrivateListUI = class("ClsPrivateListUI", ClsChatPanelBase)
function ClsPrivateListUI:ctor()
	local parameter = {
        json_res = "chat_friend.json",
        channel = KIND_PRIVATE,
    }
    self.super.ctor(self, parameter)
    self:configUI()
    self:initEvent()
end

function ClsPrivateListUI:configUI()
    self.btn_record = getConvertChildByName(self.panel, "btn_record")
    local func = self.btn_record.setVisible
    function self.btn_record:setVisible(enable)
        func(self, enable)
        self:setTouchEnabled(enable)
    end
    self.btn_record:setPressedActionEnabled(true)

    self.friend_tips = getConvertChildByName(self.panel, "friend_tips")
    self.title = getConvertChildByName(self.panel, "title")
    self.friend_tips:setVisible(false)
    self.title:setVisible(false)
end

function ClsPrivateListUI:enterCall()
    self:updateView()
end

function ClsPrivateListUI:updateView()
    local component_ui = getUIManager():get("ClsChatComponent")
    local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    self.data = main_ui:getPlayerBtnPara()

    local friend_data = getGameData():getFriendDataHandler()
    local is_friend = friend_data:isMyFriend(self.data.uid)--判断是否是我的好友
    self.title:setVisible(not is_friend)

	self:createEditBox()
	self:createList(self.data)
end

function ClsPrivateListUI:createList(data)
    local chat_data = getGameData():getChatData()
    chat_data:setMsgRead(data.uid)--将与该人聊天的信息全部设成已读
    self:deleteListView()
    local content = nil
    if data and data.list and #data.list > 0 then
        content = data.list
    else
        content = chat_data:getOnePrivateMsg(data.uid)
    end
    self.super.createList(self, nil, content)
end

function ClsPrivateListUI:deleteListView()
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end
end

function ClsPrivateListUI:addCell(player_info, msg)
    if player_info.uid ~= self.data.uid then return end
    local chat_data = getGameData():getChatData()
    chat_data:setMsgRead(player_info.uid)
    if not tolua.isnull(self.list_view) then
        local cell_class = self:getBubbleType(msg)
        local cell = cell_class.new(CCSize(380, 85), msg)
        self.list_view:addCellByIndex(cell, 1)
        self.list_view:scrollToCellIndex(1)
    else
        local content = chat_data:getOnePrivateMsg(player_info.uid)
        self.super.createList(self, nil, content)
    end
end

return ClsPrivateListUI