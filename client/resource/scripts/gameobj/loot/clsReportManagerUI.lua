local music_info = require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
-- local onOffKey_with_taksKey = {
--     [1] = {on_off_info.FRIEND_LIST.value,},
--     [2] = {on_off_info.FRIEND_THANKS.value, {on_off_info.ACCEPT_GIFTPAGE.value}},
-- }

local btn_widget = {
    [1] = { name = "btn_plunder", index = TAB_PLUNDER, text = "txt_plunder" },
    [2] = { name = "btn_plundered", index = TAB_PLUNDERED, text = "txt_plundered" },
}

local ClsReportManagerUI = class("ClsReportManagerUI", function() return UIWidget:create() end)
function ClsReportManagerUI:ctor()
    self.btn_tab = {}
    self.panels = {}

    self:configUI()
    local loot_data = getGameData():getLootData()
    loot_data:askReportPlayerInfos()
    loot_data:askTraceingPlayerInfo()
end

function ClsReportManagerUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_report.json")
    self:addChild(self.panel)

    local taskData = getGameData():getTaskData()
    for k, v in ipairs(btn_widget) do
        local item = getConvertChildByName(self.panel, v.name)
        item.name = v.name
        item.index = v.index

        item.text = getConvertChildByName(self.panel, v.text)

        item.text:addEventListener(function() 
            setUILabelColor(v.text, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
        end, TOUCH_EVENT_BEGAN)

        item:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:executeSelectLogic(v.index)
        end, TOUCH_EVENT_ENDED)

        self[v.name] = item
        table.insert(self.btn_tab, item)

        -- v.onOffKey = onOffKey_with_taksKey[k][1]
        -- v.task_keys = onOffKey_with_taksKey[k][2]
        -- if v.task_keys then
        --     local task_parameter = {
        --         [1] = item,
        --         [2] = v.task_keys,
        --         [3] = KIND_RECTANGLE,
        --         [4] = v.onOffKey,
        --         [5] = 56,
        --         [6] = 16,
        --         [7] = true,
        --     }
        --     taskData:regTask(unpack(task_parameter))
        -- end
    end

    self.panel_layer = getConvertChildByName(self.panel, "panel_layer")

    local func = self.panel_layer.addChild
    function self.panel_layer:addChild(panel)
        func(self, panel)
        local main_ui = getUIManager():get("ClsFriendMainUI")
        local report_manager = main_ui:getPanelByName("ClsReportManagerUI")
        report_manager:insertPanelByName(panel.panel_index, panel)
        report_manager.cur_panel = panel
    end
end

function ClsReportManagerUI:getPanelByName(name)
    return self.panels[name]
end

function ClsReportManagerUI:insertPanelByName(name, panel)
    self.panels[name] = panel
end

function ClsReportManagerUI:clickPlunderEvent()
    local panel = self:getPanelByName("ClsPlunderReportUI")
    if tolua.isnull(panel) then
        local ClsPlunderReportUI = require("gameobj/loot/clsPlunderReportUI")
        panel = ClsPlunderReportUI.new()
        panel.panel_index = "ClsPlunderReportUI"
        self.panel_layer:addChild(panel)
    end
end

function ClsReportManagerUI:clickPlunderedEvent()
    local panel = self:getPanelByName("ClsPlunderedReportUI")
    if tolua.isnull(panel) then
        local ClsPlunderedReportUI = require("gameobj/loot/clsPlunderedReportUI")
        panel = ClsPlunderedReportUI.new()
        panel.panel_index = "ClsPlunderedReportUI"
        self.panel_layer:addChild(panel)
    end
end

local tab_events = {
    [TAB_PLUNDER] = ClsReportManagerUI.clickPlunderEvent,
    [TAB_PLUNDERED] = ClsReportManagerUI.clickPlunderedEvent,
}

function ClsReportManagerUI:executeSelectLogic(index)
    for k, v in ipairs(self.btn_tab) do
        v:setFocused(index == v.index)
        v:setTouchEnabled(index ~= v.index)

        if not tolua.isnull(self.cur_panel) then
            self.cur_panel:removeFromParentAndCleanup(true)
        end

        local color = COLOR_TAB_SELECTED
        if index ~= v.index then
            color = COLOR_TAB_UNSELECTED
        end
        v.text:setUILabelColor(color)
    end
    tab_events[index](self)
end

function ClsReportManagerUI:updateListCell(info)
    if not tolua.isnull(self.cur_panel) then
        self.cur_panel:updateListCell(info)
    end
end

return ClsReportManagerUI
