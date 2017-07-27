local element_mgr = require("base/element_mgr")
local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsChatSpendDiamondTip = class("ClsChatSpendDiamondTip", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsChatSpendDiamondTip:getViewConfig()
    return {
        name = "ClsChatSpendDiamondTip",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

--页面创建时调用
function ClsChatSpendDiamondTip:onEnter(parameter)
    self.parameter = parameter
    self:configUI()
    self:configEvent()
end

function ClsChatSpendDiamondTip:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_common.json")
    self:addWidget(self.panel)

    local tips_common = getConvertChildByName(self.panel, "tips_common")
    local bg_size = tips_common:getContentSize()
    tips_common:setPosition(ccp(display.cx - bg_size.width / 2, display.cy - bg_size.height / 2))

    local widget_info = {
        [1] = {name = "text_1"},
        [2] = {name = "text_2"},
        [3] = {name = "btn_confirm"},
        [4] = {name = "btn_cancel"},
        [5] = {name = "btn_close"},
    }
 
    for k, v in ipairs(widget_info) do
        local item = getConvertChildByName(self.panel, v.name)
        if item:getDescription() == "Button" then
            item:setPressedActionEnabled(true)
            item:setTouchEnabled(true)
        end
        self[v.name] = item
    end

    self.text_1:setVisible(false)
    self.text_2:setText(self.parameter.show_tip)

    local touch_rect = CCRect(275, 151, 420, 264)
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            if not touch_rect:containsPoint(ccp(x, y)) then
                return true
            end
        elseif event_type == "ended" then
            self:close()
        end
    end)
end

function ClsChatSpendDiamondTip:configEvent()
    self.btn_close:addEventListener(function() 
        self:exitView()
    end, TOUCH_EVENT_ENDED)

    self.btn_confirm:addEventListener(function() 
        if type(self.parameter.ok_func) == "function" then
            self.parameter.ok_func()
            self:close()
        end
    end, TOUCH_EVENT_ENDED)   

    self.btn_cancel:addEventListener(function() 
        self:exitView()
    end, TOUCH_EVENT_ENDED)     
end

return ClsChatSpendDiamondTip