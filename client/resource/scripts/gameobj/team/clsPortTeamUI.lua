local team_config = require("game_config/team/team_config")
local music_info = require("game_config/music_info")
local ClsBusinessTeamList = require("gameobj/team/clsBusinessTeamList")
local ClsChatSystemMainUI = require("gameobj/chat/clsChatSystemMainUI")
local on_off_info = require("game_config/on_off_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsPortTeamUI = class("ClsPortTeamUI", ClsBaseView)
local ClsAlert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

local widget_name = {
	"btn_close",
	"btn_refresh_icon",
	"btn_chat_icon",
}

function ClsPortTeamUI:getViewConfig()
    return { 
        hide_before_view = true, 
        effect = UI_EFFECT.FADE, 
    }
end

function ClsPortTeamUI:onEnter(index, is_pop, is_create_team, is_auto_change)
	local taskData = getGameData():getTaskData()
    taskData:setTask(on_off_info.ORGANIZETEAM.value, false)

    self.m_plist_tab = {
        ["ui/team_ui.plist"] = 1,
        ["ui/chat_ui.plist"] = 1,
    }
    LoadPlist(self.m_plist_tab)

    self.s_type = nil
    self.def_select = index or 1
    if is_pop then
       self:gotoTargetTab()
    end

    self:initUi()
    self:askData()
    self:defaultSelect()

    local team_data = getGameData():getTeamData()
    if is_create_team then
        team_data:askCreateTeam()
    end
    if is_auto_change then
    	local is_in_team, _team_id = team_data:isInTeam()
        if is_in_team and _team_id ~= index then
            team_data:setTeamType(index)
            team_data:askChangeTeamType()
        end
    end
end

function ClsPortTeamUI:askData()
    local activity_data = getGameData():getActivityData()
    activity_data:requestActivityInfo()
end

function ClsPortTeamUI:initUi()
	local json_ui = GUIReader:shareReader():widgetFromJsonFile("json/team.json")
	self:addWidget(json_ui)
	for k,name in ipairs(widget_name) do
        self[name] = getConvertChildByName(json_ui, name)
    end
    for index, team_info in ipairs(team_config) do
    	local btn_name = "tab_"..index
    	local text_name = "tab_text_"..index
    	self[btn_name] = getConvertChildByName(json_ui, btn_name)
    	self[btn_name][text_name] = getConvertChildByName(json_ui, text_name)
        self[btn_name][text_name]:setText(team_info.name)
    	self[btn_name]:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:selectTab(index)
        end, TOUCH_EVENT_ENDED)
    end

    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        getUIManager():close("ClsSelectTeamType")
        self:effectClose()
        local port_layer = getUIManager():get("ClsPortLayer")
        local copy_scene_manager = require("gameobj/copyScene/copySceneManage")
        if not tolua.isnull(port_layer) then
            port_layer:createChatComponent()
        else
            copy_scene_manager:doLogic("createChatComponent")
        end
        local marketLayer = getUIManager():get("ClsPortMarket")
        if not tolua.isnull(marketLayer) then
            marketLayer:closeView()
        end
    end, TOUCH_EVENT_ENDED)

    self.btn_chat_icon:addEventListener(function()
        self:createChatComponent()
        local chat_component = getUIManager():get("ClsChatComponent")
        main_ui = chat_component:getPanelByName("ClsChatSystemMainUI")
        main_ui:executeSelectTabLogic(INDEX_WORLD)
        main_ui:goInto()
    end, TOUCH_EVENT_ENDED)

    self.btn_refresh_icon:setPressedActionEnabled(true)
    self.btn_refresh_icon:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local team_data = getGameData():getTeamData()
        team_data:askTeamListInfo()
    end, TOUCH_EVENT_ENDED)

    local team_data = getGameData():getTeamData()
    team_data:clearTeamInfo()
    self:showListUi()
end

function ClsPortTeamUI:createChatComponent()
    getUIManager():close("ClsChatComponent")
    getUIManager():create("gameobj/chat/clsChatComponent", nil, {not_need_panel = true})
    local chat_component = getUIManager():get("ClsChatComponent")
    main_ui = chat_component:getPanelByName("ClsChatSystemMainUI")
    local function closeCall()
        audioExt.playEffect(music_info.PORT_INFO_UP.res)
        main_ui:goOut()
    end
    main_ui:setCloseCall(closeCall)

    local close_rect = CCRect(483, 15, 475, 542)
    main_ui.bg_touch_panel:addEventListener(function()
        local pos = main_ui.bg_touch_panel:getTouchEndPos()
        if close_rect:containsPoint(ccp(pos.x, pos.y)) then
            closeCall()
        end
    end, TOUCH_EVENT_ENDED)
end

function ClsPortTeamUI:gotoTargetTab()
    local team_data = getGameData():getTeamData()
    local is_in_team, team_id = team_data:isInTeam()
    if team_id then
        self.def_select = team_id
    end
end

function ClsPortTeamUI:showListUi()
    self.m_list_ui = ClsBusinessTeamList.new()
    self:addWidget(self.m_list_ui)
end

function ClsPortTeamUI:defaultSelect()
	self:selectTab(self.def_select)
end

function ClsPortTeamUI:selectEffect(index)
	local BTN = "tab_"
	local TEXT = "tab_text_"
	for k,v in ipairs(team_config) do
		local btn_name = BTN..k
		self[btn_name]:setTouchEnabled(true)
		self[btn_name]:setFocused(false)
		setUILabelColor(self[btn_name][TEXT..k], ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
	end
	self[BTN..index]:setTouchEnabled(false)
	self[BTN..index]:setFocused(true)
	setUILabelColor(self[BTN..index][TEXT..index], ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
end

function ClsPortTeamUI:selectTab(index)
    if index ~= 1 then
        local copy_scene_manager = require("gameobj/copyScene/copySceneManage")
        if false == copy_scene_manager:doLogic("isCanChangeTeamTag") then
            ClsAlert:warning({msg = ui_word.NO_CHANGE_TEAM_TARGET})
            return
        end
    end
	self.s_type = index
	self:selectEffect(index)
    local team_data = getGameData():getTeamData()
    team_data:setTeamType(index)
    team_data:askTeamListInfo()
end

function ClsPortTeamUI:getListUi()
    return self.m_list_ui
end

function ClsPortTeamUI:updateListView()
    if self.m_list_ui then
        self.m_list_ui:updateListView()
    end
end

function ClsPortTeamUI:onExit()
	local virtua_team_data = getGameData():getVirtuaTeamData()
    virtua_team_data:reset()
    UnLoadPlist(self.m_plist_tab)
end

return ClsPortTeamUI
