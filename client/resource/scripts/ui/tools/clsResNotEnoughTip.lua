local tool = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local UiTools = require("gameobj/uiTools")
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsBaseView = require("ui/view/clsBaseView")
local ClsResNotEnoughTip = class("ClsResNotEnoughTip", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsResNotEnoughTip:getViewConfig()
    return {
        name = "ClsResNotEnoughTip",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsResNotEnoughTip:onEnter(items, parent)
    self.items = items
    self.parent = parent
    self.items_num = #items
    self:configUI()
end

function ClsResNotEnoughTip:skipCashEvent(item)
    Alert:showJumpWindow(CASH_NOT_ENOUGH, self.parent, {need_cash = tonumber(item.cash), come_type = Alert:getOpenShopType().VIEW_3D_TYPE, come_name = "shipyard_create"})
end

function ClsResNotEnoughTip:skipPaperEvent(item)
     Alert:showJumpWindow(PAPER_NOT_ENOUGH, self.parent)
end

local event_by_kind = {
    ["paper"] = ClsResNotEnoughTip.skipPaperEvent,
    ["cash"] = ClsResNotEnoughTip.skipCashEvent,
}

local name_by_kind = {
    ["paper"] = ui_word.SHIPYARD_PAPAER_NOT_ENOUGH,
    ["cash"] = ui_word.SHIPYARD_CASH_NOT_ENOUGH,
}

function ClsResNotEnoughTip:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_shipyard.json")
    self:addWidget(self.panel)
    local panel_size = self.panel:getContentSize()
    self.panel:setPosition(ccp((display.width - panel_size.width) / 2, (display.height - panel_size.height) / 2))

    local panel_info = {
        [1] = {name = "panel_2", num = 2},
        [2] = {name = "panel_3", num = 3},
    }

    for k, v in ipairs(panel_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name]:setVisible(self.items_num == v.num)
        if self.items_num == v.num then
            self.current_panel = self[v.name]
        end
    end

    for k, v in ipairs(self.items) do
        local name = string.format("btn_%s", k)
        local text = string.format("btn_text_%s",k)
        local btn = getConvertChildByName(self.current_panel, name)
        btn:setTouchEnabled(true)
        btn.label = getConvertChildByName(btn, text)
        btn.label:setText(name_by_kind[v.kind])
        btn.name = name
        btn:setPressedActionEnabled(true)
        btn:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:closeView()
            event_by_kind[v.kind](self, v)
        end, TOUCH_EVENT_ENDED)
        self.current_panel[name] = btn
    end

    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:setTouchEnabled(true)
    self.btn_close:addEventListener(function() 
        self:closeView()
    end, TOUCH_EVENT_ENDED)

    self.not_touch_rect = CCRect((display.width - panel_size.width) / 2, (display.height - panel_size.height) / 2, panel_size.width, panel_size.height)
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            if not self.not_touch_rect:containsPoint(ccp(x, y)) then
                return true
            end
        elseif event_type == "ended" then
            self:closeView()
        end
    end) 
end

function ClsResNotEnoughTip:closeView()
    getUIManager():close('ClsResNotEnoughTip')
end

return ClsResNotEnoughTip

