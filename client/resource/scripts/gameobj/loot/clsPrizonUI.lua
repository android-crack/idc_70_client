local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local tool = require("module/dataHandle/dataTools")
local scheduler = CCDirector:sharedDirector():getScheduler()

local BTN_ADMIT = 1
local BTN_BRIBE = 2

local ClsBaseView = require("ui/view/clsBaseView")
local ClsPrizonUI = class("ClsPrizonUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsPrizonUI:getViewConfig()
    return {
        name = "ClsPrizonUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsPrizonUI:onEnter()
    self:configUI()
end

function ClsPrizonUI:bribeOfficer()
    local loot_data = getGameData():getLootData()
    loot_data:askBribeOfficer()
end

function ClsPrizonUI:admitMistake()
    self.info_bg:setVisible(false)
    for k, v in ipairs(self.btns) do
        v:setVisible(false)
    end

    getUIManager():close("ClsChatComponent")
    getUIManager():create("gameobj/chat/clsChatComponent")
end

local event_by_index = {
    [BTN_ADMIT] = ClsPrizonUI.admitMistake,
    [BTN_BRIBE] = ClsPrizonUI.bribeOfficer,
}

function ClsPrizonUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/plunder.json")
    self:addWidget(self.panel)

    self.show_tip = getConvertChildByName(self.panel, "text_1")
    self.info_time = getConvertChildByName(self.panel, "info_time")
    self.time_tips = getConvertChildByName(self.panel, "time_tips")
    self.info_bg = getConvertChildByName(self.panel, "info_bg")
    self.info_time:setVisible(false)
    self.time_tips:setVisible(false)
    local player_data = getGameData():getPlayerData()
    local name = player_data:getName()
    self.show_tip:setText(string.format(ui_word.LOOT_ARREST_TIP, name))

    local btn_info = {
        [1] = {name = "btn_admit", index = BTN_ADMIT},
        [2] = {name = "btn_bribe", index = BTN_BRIBE}
    }

    self.btns = {}
    for k, v in ipairs(btn_info) do
        local btn = getConvertChildByName(self.info_bg, v.name)
        btn:setPressedActionEnabled(true)
        btn.index = v.index
        local tempFunc = btn.setVisible
        function btn:setVisible(enable)
            tempFunc(self, enable)
            self:setTouchEnabled(enable)
        end

        btn:addEventListener(function()
            event_by_index[v.index](self)
        end, TOUCH_EVENT_ENDED)
        self[v.name] = btn
        self.btns[#self.btns + 1] = btn
    end

    local plot_dialog = require("gameobj/mission/plotDialog")
    local dialog_tab = {
        [1] = {
            [1] = 25,
            [2] = ui_word.LOOT_ARREST_DIALOG_WHO,
            [3] = 1,
            [4] = ui_word.LOOT_ARREST_DIALOG_TIP,
            [5] = 5,
        },
    }

    getUIManager():create("gameobj/mission/plotDialog", nil, dialog_tab)
    self:openScheduler()
end

function ClsPrizonUI:closeScheduler()
	if self.update_scheduler then
  		scheduler:unscheduleScriptEntry(self.update_scheduler)
        self.update_scheduler = nil
	end
end

function ClsPrizonUI:openScheduler()
	local function updateCount()
		if tolua.isnull(self) then return end
        local player_data = getGameData():getPlayerData()
        local loot_data = getGameData():getLootData()
        current_time = player_data:getCurServerTime()
        local cd = loot_data:getRedNameInfo().cd
        local time = cd
        if time >= current_time then
            local show_txt = string.format(ui_word.LOOT_ARREST_SCHEDULE_TIP_1, tool:getTimeStrNormal(time - current_time))
            self.info_time:setText(show_txt)
            self.info_time:setVisible(true)
            show_txt = string.format(ui_word.LOOT_ARREST_SCHEDULE_TIP_2, tool:getTimeStrNormal(time - current_time))
            self.time_tips:setText(show_txt)
            self.time_tips:setVisible(true)
        else
            local loot_data = getGameData():getLootData()
            loot_data:askArrest()
            self:closeView()
        end
    end

    self:closeScheduler()
    self.update_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

function ClsPrizonUI:closeView()
    self:closeScheduler()
    getUIManager():close("PlotDialog")
    self:close()
    getUIManager():close("ClsChatComponent")
    local port_layer = getUIManager():get("ClsPortLayer")
    if not tolua.isnull(port_layer) then
        port_layer:createChatComponent()
    end
end

function ClsPrizonUI:onExit()
	ClsPrizonUI.super.onExit(self)
	self:closeScheduler()
end

return ClsPrizonUI
