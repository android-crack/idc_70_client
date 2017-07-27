local ui_word = require("game_config/ui_word")
local UiTools = require("gameobj/uiTools")
local music_info = require("game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

--掠夺提示类
local ClsBaseView = require("ui/view/clsBaseView")
local ClsExploreLootTip = class("ClsExploreLootTip", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsExploreLootTip:getViewConfig()
    return {
        name = "ClsExploreLootTip",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

--页面创建时调用
function ClsExploreLootTip:onEnter(parameter)
    self:setIsWidgetTouchFirst(true)
    self.parameter = parameter
    self:configUI()
    self:configEvent()
end

function ClsExploreLootTip.showTimePanel()

end

function ClsExploreLootTip:showAttactPanel()
    local widget_info = {
        [1] = {name = "attack_txt"},
        [2] = {name = "num"},
    }

    for k, v in ipairs(widget_info) do
        local item = getConvertChildByName(self.attact_panel, v.name)
        self.attact_panel[v.name] = item
    end

    self.attact_panel.attack_txt:setText(self.parameter.text)
    self:openScheduler()
end

function ClsExploreLootTip:closeScheduler()
    if self.update_scheduler then
        scheduler:unscheduleScriptEntry(self.update_scheduler)
        self.update_scheduler = nil
    end
end

function ClsExploreLootTip:openScheduler()
    local start_num = 5
    local function updateCount()
        start_num = start_num - 1
        if start_num > 0 then
            self.attact_panel.num:setText(start_num)
        else
            self:close()
        end
    end

    self:closeScheduler()
    self.update_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

local kind_func = {
    [LOOT_TIME_PANEL] = ClsExploreLootTip.showTimePanel,
    [LOOT_ATTACT_PANEL] = ClsExploreLootTip.showAttactPanel,
}

function ClsExploreLootTip:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_loot.json")
    self:addWidget(self.panel)

    self.info_bg = getConvertChildByName(self.panel, "bg")
    local bg_size = self.info_bg:getSize()

    local start_x = (display.width - bg_size.width) / 2
    local start_y = (display.height - bg_size.height) / 2
    self.touch_rect = CCRect(start_x, start_y, bg_size.width, bg_size.height)
    self.panel:setPosition(ccp(start_x, start_y))

    local panel_info = {
        [1] = {name = "plunder_time", kind = LOOT_TIME_PANEL},
        [2] = {name = "attact_panel", kind = LOOT_ATTACT_PANEL},
    }

    for k, v in ipairs(panel_info) do
        local panel = getConvertChildByName(self.panel, v.name)
        panel:setVisible(v.kind == self.parameter.kind)
        self[v.name] = panel
    end

    self.btn_confirm = getConvertChildByName(self.panel, "btn_confirm")
    self.btn_confirm:setPressedActionEnabled(true)
    self.btn_confirm:setTouchEnabled(true)
    local btn_info = {
        [1] = {name = "btn_confirm"},
        [2] = {name = "btn_close"}
    }

    for k, v in ipairs(btn_info) do
        local item = getConvertChildByName(self.panel, v.name)
        item:setPressedActionEnabled(true)
        item:setTouchEnabled(true)
        self[v.name] = item
    end

    self.btn_confirm:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        if type(self.parameter.okCall) == "function" then
            self.parameter.okCall()
        end
        self:close()
    end, TOUCH_EVENT_ENDED)

    self.btn_close:addEventListener(function() 
        self:close()
    end, TOUCH_EVENT_ENDED)

    kind_func[self.parameter.kind](self)
end

function ClsExploreLootTip:configEvent()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            return true
        else
            if not self.touch_rect:containsPoint(ccp(x, y)) then
                self:close()
            end
        end
    end)
end

function ClsExploreLootTip:onExit()
    self:closeScheduler()
end

return ClsExploreLootTip