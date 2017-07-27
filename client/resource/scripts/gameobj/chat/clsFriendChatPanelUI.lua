local ui_word = require("scripts/game_config/ui_word")
local ClsChatPanelBase = require("gameobj/chat/clsChatPanelBase")

local ClsPrivateChatPanelUI = class("ClsPrivateChatPanelUI", ClsChatPanelBase)
function ClsPrivateChatPanelUI:ctor()
    local parameter = {
        json_res = "chat_friend.json",
        channel = KIND_PRIVATE,
    }
    self.super.ctor(self, parameter)

    self.widget_tab = {}
    self:configUI()
    self:initEvent()
end

function ClsPrivateChatPanelUI:configUI()
    local btn_info = {
        [1] = {name = "btn_send"},
        [2] = {name = "btn_record"},
    }

    for k, v in ipairs(btn_info) do
        local item = getConvertChildByName(self.panel, v.name)
        item.name = v.name
        if v.not_chatting == nil then
            v.not_chatting = false
        end
        item.not_chatting = v.not_chatting
        local func = item.setVisible
        function item:setVisible(enable)
            func(self, enable)
            self:setTouchEnabled(enable)
        end

        item:setPressedActionEnabled(true)
        self[v.name] = item
        self.widget_tab[#self.widget_tab + 1] = item
    end

    local txt_info = {
        [1] = {name = "friend_tips", not_chatting = true}
    }
    
    for k, v in ipairs(txt_info) do
        local item = getConvertChildByName(self.panel, v.name)
        if v.not_chatting == nil then
            v.not_chatting = false
        end
        item.not_chatting = v.not_chatting
        self[v.name] = item
        self.widget_tab[#self.widget_tab + 1] = item
    end
end

function ClsPrivateChatPanelUI:setViewShow(not_chatting)
    for k, v in ipairs(self.widget_tab) do
        local is_visible = true
        if v.not_chatting ~= not_chatting then
            is_visible = false
        end
        v:setVisible(is_visible)
    end
end

function ClsPrivateChatPanelUI:updateView(base_data)
    self.chatting_friend_info = base_data
    local not_chatting = not (base_data and true or false)
    self:setViewShow(not_chatting)

    local chat_data = getGameData():getChatData()
    local function clickBubbleCall(msg)
        self:setViewShow(false)
        self.chatting_friend_info = msg
        local chat_content = chat_data:getChatMessageListByUid(id)
        local list_parameter = {
            list_width = 357,
            list_height = 353
        }
        self:createChatListView(chat_content, list_parameter)
    end
    if not_chatting then --表示创建与之聊过天的所有好友最近信息列表
        local chat_content = chat_data:getFriendMessageList()
        if not chat_content or #chat_content < 1 then return end
        local list_parameter = {
            click_call = clickBubbleCall,
        }
        self:createChatListView(chat_content, list_parameter)
    else --创建与某个好友聊天列表
        clickBubbleCall(base_data)
    end
end

function ClsPrivateChatPanelUI:updateListView(msg)
    if KIND_PRIVATE ~= msg.type then return end
    local chat_data = getGameData():getChatData()
    if self.chatting_friend_info then
        local id, chat_object_name = chat_data:getChatObjectUidWithName(self.chatting_friend_info)
        local result = chat_data:judgeIsGoalByCurrentUid(id, msg)
        if result then
            if not tolua.isnull(self.list_view) then
                local cell_class = self:getBubbleType(msg)
                local cell = cell_class.new(CCSize(380, 85), msg)
                self.list_view:addCell(cell)
                self.list_view:scrollEndPos()
            else
                local list_parameter = {
                    list_width = 357,
                    list_height = 353
                }
                self:createChatListView({msg}, list_parameter)
            end
        end
    else--没有和具体的人聊
        if not tolua.isnull(self.list_view) then
            local find_obj = false
            local id, chat_object_name = chat_data:getChatObjectUidWithName(msg)
            for k, v in ipairs(self.list_view.m_cells) do
                local result = chat_data:judgeIsGoalByCurrentUid(id, v.m_cell_date)
                if result then
                    find_obj = true
                    v.m_cell_date = msg
                    if not tolua.isnull(v.root) then
                        v:updateUI(msg)
                    end
                    break
                end
            end
            if not find_obj then
                local cell_class = self:getBubbleType(msg)
                local cell = cell_class.new(CCSize(380, 85), msg)
                self.list_view:addCell(cell)
                self.list_view:scrollEndPos()
            end
        else
            self:updateView()
        end
    end
end

function ClsPrivateChatPanelUI:getCurChattingFriendInfo()
    return self.chatting_friend_info
end

return ClsPrivateChatPanelUI