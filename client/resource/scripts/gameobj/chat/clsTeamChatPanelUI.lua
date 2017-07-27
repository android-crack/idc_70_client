local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local ClsChatPanelBase = require("gameobj/chat/clsChatPanelBase")

local ClsTeamChatPanelUI = class("ClsTeamChatPanelUI", ClsChatPanelBase)
function ClsTeamChatPanelUI:ctor()
    local parameter = {
        json_res = "chat_team.json",
        channel = KIND_TEAM,
        data = DATA_TEAM
    }
    ClsTeamChatPanelUI.super.ctor(self, parameter)
    self:configUI()
    self:initEvent()
    self:configEvent()
end

function ClsTeamChatPanelUI:configUI()
    self.btn_record = getConvertChildByName(self.panel, "btn_record")
    local func = self.btn_record.setVisible
    function self.btn_record:setVisible(enable)
        func(self, enable)
        self:setTouchEnabled(enable)
    end
    self.btn_record:setPressedActionEnabled(true)
end

function ClsTeamChatPanelUI:configEvent()
    RegTrigger(JOIN_EXIT_TEAM_EVENT, function()
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

function ClsTeamChatPanelUI:updateView()
    local team_data = getGameData():getTeamData()
    local is_add_team = team_data:isInTeam()

    if is_add_team then
        self.btn_record:setVisible(true)
        self:createEditBox()
        self:createList(DATA_TEAM)
    else
        self.btn_record:setVisible(false)
        self:removeEditBox()
        self:createList(DATA_INVITE)
    end
end

function ClsTeamChatPanelUI:enterCall()
    self:updateView()
end

return ClsTeamChatPanelUI