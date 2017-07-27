local element_mgr = require("base/element_mgr")
local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsChatPanelBase = require("gameobj/chat/clsChatPanelBase")

local ClsGuildChatPanelUI = class("ClsGuildChatPanelUI", ClsChatPanelBase)
function ClsGuildChatPanelUI:ctor()
    local parameter = {
        json_res = "chat_guild.json",
        channel = KIND_GUILD,
        data = DATA_GUILD,
    }
    self.super.ctor(self, parameter)
    self.widget_tab = {}
   	self:configUI()
    self:initEvent()
    self:configEvent()
end

function ClsGuildChatPanelUI:configUI()
    local btn_info = {
        [1] = {name = "btn_record"},
        [2] = {name = "btn_guild", not_add_guild = true},
    }

    for k, v in ipairs(btn_info) do
        local item = getConvertChildByName(self.panel, v.name)
        item.name = v.name
        if v.not_add_guild == nil then
            v.not_add_guild = false
        end
        local func = item.setVisible
        function item:setVisible(enable)
            func(self, enable)
            self:setTouchEnabled(enable)
        end
        item.not_add_guild = v.not_add_guild

        item:setPressedActionEnabled(true)
        self[v.name] = item
        self.widget_tab[#self.widget_tab + 1] = item
    end
    
    local txt_info = {
        [1] = {name = "guild_tips", not_add_guild = true},
    }
    
    for k, v in ipairs(txt_info) do
        local item = getConvertChildByName(self.panel, v.name)
        if v.not_add_guild == nil then
            v.not_add_guild = false
        end
        item.not_add_guild = v.not_add_guild
        self[v.name] = item
        self.widget_tab[#self.widget_tab + 1] = item
    end
end

function ClsGuildChatPanelUI:updateView()
    local guild_info_data = getGameData():getGuildInfoData()
    local guild_id = guild_info_data:getGuildId()
    local is_add_guild = (guild_id ~= nil and guild_id ~= 0 and true or false)
    local not_add_guild = not is_add_guild

    if is_add_guild then
        self:createEditBox()
    else
        self:removeEditBox()
    end

    for k, v in ipairs(self.widget_tab) do
        local is_visible = true
        if v.not_add_guild ~= not_add_guild then
            is_visible = false
        end
        v:setVisible(is_visible)
    end

    if self.btn_guild:isVisible() then
        if self:judgeBtnAvailable() then
            self.btn_guild:active()
        else
            self.btn_guild:disable()
        end
        --移除以前聊天内容
        if not tolua.isnull(self.list_view) then
            self.list_view:removeFromParentAndCleanup(true)
            self.list_view = nil
        end
    else
        self:createList(self.data_kind)
    end
end

function ClsGuildChatPanelUI:enterCall()
    self:updateView()
end

function ClsGuildChatPanelUI:judgeBtnAvailable()
    local prizon_ui = getUIManager():get("ClsPrizonUI")
    local auto_trade_data = getGameData():getAutoTradeAIHandler()

    if not tolua.isnull(prizon_ui) or auto_trade_data:inAutoTradeAIRun() then
        return false
    end

    local onOffData = getGameData():getOnOffData()
    if not onOffData:isOpen(on_off_info.PORT_UNION.value) then
        return false
    end

    local port_layer = getUIManager():get("ClsPortLayer")
    if tolua.isnull(port_layer) then
        return false
    end

    return true
end

function ClsGuildChatPanelUI:configEvent()
    self.btn_guild:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local skip_layer = require("gameobj/mission/missionSkipLayer")
        skip_layer:skipLayerByName("guild")
    end, TOUCH_EVENT_ENDED)

    RegTrigger(JOIN_EXIT_GUILD_EVENT, function()
        if tolua.isnull(self) then return end
        self:updateView()
    end)
	
	self.exit_node = display.newNode()
	self:addCCNode(self.exit_node)
	self.exit_node:registerScriptHandler(function(event)
		if event == "exit" then
			UnRegTrigger(JOIN_EXIT_GUILD_EVENT)
		end
	end)
end

function ClsGuildChatPanelUI:deleteCell(msg_id)
    if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.id == msg_id then
            self.list_view:removeCell(v)
            break
        end
    end
end

return ClsGuildChatPanelUI