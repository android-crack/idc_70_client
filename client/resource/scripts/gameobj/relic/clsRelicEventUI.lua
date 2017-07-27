local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsRelicEventUI = class("ClsRelicEventUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsRelicEventUI:getViewConfig()
    return {
        name = "ClsRelicEventUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

function ClsRelicEventUI:onEnter(parameter)
    parameter = parameter or {}
    self.relic_id = parameter.relic_id or 0
    self.view_status = parameter.status
    if not self.view_status then
        self:checkViewStatus()
    end

    self.resPlist = {
        ["ui/relic/relic.plist"] = 1,
    }
    LoadPlist(self.resPlist)

	self:configUI()
    self:configEvent()
end

local show_txt = {
    [RELIC_EVENT_HELP] = ui_word.RELIC_ASK_HELP,
    [RELIC_EVENT_GO] = ui_word.RELIC_GO,
    [RELIC_EVENT_FIGHT] = ui_word.RELIC_FIGHT,
}

function ClsRelicEventUI:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/relic_battle.json")
    self:addWidget(self.panel)

    self.card_bg = getConvertChildByName(self.panel, "relic_card_frame")
    
    self._btn = getConvertChildByName(self.panel, "btn_team")
    self._btn:setPressedActionEnabled(true)
    self.show_txt = getConvertChildByName(self._btn, "txt_team")
    self.show_txt:setText(show_txt[self.view_status])
end

function ClsRelicEventUI:checkViewStatus()
    local team_data = getGameData():getTeamData()
    if team_data:isTeamFull() then
        self.view_status = RELIC_EVENT_FIGHT
    else 
        self.view_status = RELIC_EVENT_HELP
    end
end

function ClsRelicEventUI:askHelp()
    self:closeView()
    local collect_data = getGameData():getCollectData()
    collect_data:askGuildHelp(self.relic_id)
end

function ClsRelicEventUI:goFindPirate()
    -- self:closeView()
    -- getUIManager():close("ClsRelicDiscoverUI")
    -- local collect_data = getGameData():getCollectData()
    -- local goal_info = {id = self.relic_id, navType = EXPLORE_NAV_TYPE_RELIC}
    -- EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, goal_info)
end

function ClsRelicEventUI:askFight()
    self:closeView()
    local collect_data = getGameData():getCollectData()
    collect_data:askRelicPirateFight(self.relic_id)
end

-- RELIC_EVENT_HELP = 1
-- RELIC_EVENT_GO = 2
-- RELIC_EVENT_FIGHT = 3

local event_by_status = {
    [RELIC_EVENT_HELP] = ClsRelicEventUI.askHelp,
    [RELIC_EVENT_GO] = ClsRelicEventUI.goFindPirate,
    [RELIC_EVENT_FIGHT] = ClsRelicEventUI.askFight,
}

function ClsRelicEventUI:configEvent()
    self._btn:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        event_by_status[self.view_status](self)
    end, TOUCH_EVENT_ENDED)

    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            local bg_size = self.card_bg:getSize()
            local bg_world_pos = self.card_bg:getWorldPosition()
            local anchor_point = self.card_bg:getAnchorPoint()
            local min_x = bg_world_pos.x - bg_size.width * anchor_point.x
            local max_x = min_x + bg_size.width
            local min_y = bg_world_pos.y - bg_size.height * anchor_point.x
            local max_y = min_y + bg_size.height
            if x >= min_x and x <= max_x and y >= min_y and y <= max_y then
                return false
            end
            return true
        elseif event_type == "ended" then
            self:closeView()
        end
    end)
end

function ClsRelicEventUI:closeView()
    self:close()
end

function ClsRelicEventUI:onExit()
    UnLoadPlist(self.resPlist)
end

return ClsRelicEventUI