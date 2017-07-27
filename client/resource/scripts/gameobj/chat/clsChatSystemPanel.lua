local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local ui_word = require("scripts/game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsChatListViewCell = require("ui/tools/clsChatListViewCell")
local ClsRichLabel = require("ui/tools/richlabel/richlabel")
local ClsChatPanelBase = require("gameobj/chat/clsChatPanelBase")
local ClsChatBase = require("gameobj/chat/clsChatBase")
local ClsScrollView = require("ui/view/clsScrollView")

local ClsPanelScrollView = class("ClsPanelScrollView", ClsScrollView)
function ClsPanelScrollView:onTouchMoved(x, y)
    
end

function ClsPanelScrollView:onTouchEnded(x, y)
    if not self.m_drag then 
        self:scrollEndPos()
        return 
    end
    self.m_drag.end_x = x
    self.m_drag.end_y = y
    local drag_info = self.m_drag
    self:tryToTap(drag_info)
    self:scrollEndPos()
end

local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local touch_event_for_chat_message = require("gameobj/chat/touchEventForChatMessage")

local chat_system_panel_use_widget = {
	[1] = { name = "chat_channel_text", kind = TEXT},
	[2] = { name = "btn_chat", kind = BTN , on_off_key = on_off_info.CHAT_MAIN.value, task_keys = {
			on_off_info.CHAT_FRIEND.value,
		}},
	[3] = { name = "chat_channel_bg"},
	[4] = { name = "chat_panel"},
	[5] = { name = "chat_box"},
}

local record_info = {
    [1] = {info = {channel = KIND_NOW, res = "ui/txt/txt_chat_now.png"}},
    [2] = {condition = {["guild"] = true}, info = {channel = KIND_GUILD, res = "ui/txt/txt_chat_guild.png"}},
    [3] = {condition = {["team"] = true}, info = {channel = KIND_TEAM, res = "ui/txt/txt_chat_team.png"}},
}

local ClsChatSystemPanel = class("ClsChatSystemPanel", ClsChatBase)

function ClsChatSystemPanel:ctor()
    self.recogn_ui_plist_res = {
        ["ui/chat_ui.plist"] = 1,
    }
    LoadPlist(self.recogn_ui_plist_res)

    local base_param = {
        json_res = "chat_box.json",
    }
    self.super.ctor(self, base_param)

	self:configUI()
	self:configEvent()
end

function ClsChatSystemPanel:configUI()
	local taskData = getGameData():getTaskData()
    for k, v in ipairs(chat_system_panel_use_widget) do
    	self[v.name] = getConvertChildByName(self.panel, v.name)
    	self[v.name].name = v.name
    	if v.kind == BTN then
    		self[v.name]:setPressedActionEnabled(true)
    	end

    	if v.on_off_key and v.task_keys then
        	taskData:regTask(self[v.name], v.task_keys, KIND_CIRCLE, v.on_off_key, 18, 18, true)
    	end
    end

    self.record_btns = {}
    for k = 1, 3 do
        local name = string.format("btn_%s", k)
        local btn = getConvertChildByName(self.panel, name)
        btn.name = name
        btn.img = getConvertChildByName(btn, "img")
        btn:setPressedActionEnabled(true)

        local func = btn.setVisible
        function btn:setVisible(enable)
            func(self, enable)
            self:setTouchEnabled(enable)
        end

        self.record_btns[#self.record_btns + 1] = btn
    end

    --判断哪些录音按钮可以使用
    self:updateBtnShow()
    self.chat_panel.is_show = true
    self.action_bg = self.chat_panel
    
    self.chat_channel_bg:setVisible(false)
    self:updateShowMessage()

    local self_visible = self.setVisible
    function self:setVisible(enable)
        self_visible(self, enable)
        local scale = 1
        if not enable then
            scale = 0
        end
        self:setScale(scale)
    end
end

function ClsChatSystemPanel:updateBtnShow()
    if tolua.isnull(self) then return end
    self.can_result = {}
    local guild_data = getGameData():getGuildInfoData()
    local guild_id = guild_data:getGuildId()
    local add_guild = (guild_id ~= nil and guild_id ~= 0 and true or false)

    local in_team = getGameData():getTeamData():isInTeam()

    local judge_result = {
        ["guild"] = add_guild,
        ["team"] = in_team,
    }

    for k, v in ipairs(record_info) do
        local is_available = true
        if v.condition then
            for i, j in pairs(v.condition) do
                if judge_result[i] ~= j then
                    is_available = false
                    break
                end 
            end
        end
        if is_available then
            self.can_result[#self.can_result + 1] = v.info
        end
    end

    local chat_data_hander = getGameData():getChatData()
    --为录音按钮统一注册事件
    for k, v in ipairs(self.record_btns) do
        local result = self.can_result[k]
        if result then
            v.img:changeTexture(result.res, UI_TEX_TYPE_LOCAL)
            v:setVisible(true)
            v:addEventListener(function()
                chat_data_hander:stopRecord()
            end, TOUCH_EVENT_ENDED)

            v:addEventListener(function()
                v:setScale(1.3)
                chat_data_hander:recordMessage(result.channel)
            end, TOUCH_EVENT_BEGAN)

            v:addEventListener(function()
                chat_data_hander:cancelRecord()
            end, TOUCH_EVENT_CANCELED)
        else
            v:setVisible(false)
        end
    end
end

function ClsChatSystemPanel:setTouchEnabled(enable)
    if not enable then
        local chat_data_hander = getGameData():getChatData()
        chat_data_hander:stopRecord()
    end
end

function ClsChatSystemPanel:updateShowMessage()
	if not tolua.isnull(self.list_view) then 
        self.list_view:removeFromParent()
        self.list_view = nil
    end

    local chat_data_hander = getGameData():getChatData()
    local show_list = chat_data_hander:getSmallPanelList()
    self:createListView(show_list)
end

function ClsChatSystemPanel:isFindMsg(msg_id)
    if tolua.isnull(self.list_view) then return end

    for k, v in ipairs(self.list_view:getCells()) do
        if tonumber(v.m_cell_date.id) == msg_id then
            return true
        end
    end
    return false
end

function ClsChatSystemPanel:createListView(content)
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end
    if not content or #content < 1 then return end

    local list_width = 353
    local list_height = 73
    self.list_view = ClsPanelScrollView.new(list_width, list_height, true, function()

    end, {is_fit_bottom = true, update_logic = "down"})
    local cell_size = CCSize(355, 35)

    self.cells = {}
    local max_cell_num = 3
    local cell_num = (#content >= max_cell_num and max_cell_num) or (#content)
    local start_cell_index = (cell_num == max_cell_num and #content - 2) or 1

    for k = start_cell_index, #content do
        local cell = ClsChatListViewCell.new(cell_size, content[k])
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(15, 10))
    self.chat_box:addChild(self.list_view)

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCCallFunc:create(function()
        if tolua.isnull(self.list_view) then return end
        self.list_view:scrollEndPos()
    end))
    self:runAction(CCSequence:create(arr))
end  

function ClsChatSystemPanel:configEvent()
	--切换到聊天主界面
	self.btn_chat:addEventListener(function()
        self:toMainUI()
	end, TOUCH_EVENT_ENDED)
    
    RegTrigger(JOIN_EXIT_GUILD_EVENT, function() 
        self:updateBtnShow()
    end)

    RegTrigger(JOIN_EXIT_TEAM_EVENT, function() 
        self:updateBtnShow()
    end)
	
	self.exit_node = display.newNode()
	self:addCCNode(self.exit_node)
	self.exit_node:registerScriptHandler(function(event)
		if event == "exit" then
			UnRegTrigger(JOIN_EXIT_GUILD_EVENT)
			UnRegTrigger(JOIN_EXIT_TEAM_EVENT)
		end
	end)
end

function ClsChatSystemPanel:toMainUI(data, is_play_music)
    self:setVisible(false)
    if is_play_music then
        audioExt.playEffect(music_info.PORT_INFO_UP.res)
    end

    local chat_date = getGameData():getChatData()
    local have_not_read_msg = chat_date:isHaveNotReadMsg()
    if have_not_read_msg then
        if not data then
            data = {kind = INDEX_PRIVATE}
        end
    end

    local component_ui = getUIManager():get("ClsChatComponent")
    local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    local channel = data and data.kind
    if not channel then
        channel = chat_date:getChannel()
    end
    main_ui:executeSelectTabLogic(channel)

    local guild_small_map = getUIManager():get("ClsGuildSmallMap")
    if not tolua.isnull(guild_small_map) then
        channel = INDEX_GUILD
    end

    if channel == INDEX_PRIVATE then
        local private_ui = chat_date:getPrivateListUI()
        if not tolua.isnull(private_ui) then
            private_ui:updateView()
        end
    end
    main_ui:goInto()
end

return ClsChatSystemPanel


