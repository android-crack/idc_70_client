--船厂商店TIP
local ui_word = require("game_config/ui_word")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsStoreTip = class("ClsStoreTip", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsStoreTip:getViewConfig()
    return {
        name = "ClsStoreTip",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsStoreTip:onEnter(parameter)
    self.config_data = parameter.config_data
    self:configUI()
end

function ClsStoreTip:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_tips.json")
    self:addWidget(self.panel)

    local panel_size = self.panel:getContentSize()
    self.panel:setPosition(ccp((display.width - panel_size.width) / 2, (display.height - panel_size.height) / 2))
    self.not_close_rect = CCRect((display.width - panel_size.width) / 2, (display.height - panel_size.height) / 2, panel_size.width, panel_size.height)
    
    local widget_info = {
        [1] = {name = "box_icon"},
        [2] = {name = "box_name"},
        [3] = {name = "box_tips_num"},
        [4] = {name = "box_introduce"},
        [5] = {name = "btn_use"}
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end
    self.btn_use:setVisible(false)

    local info = self.config_data
    self.box_icon:changeTexture(info.icon, UI_TEX_TYPE_PLIST)
    self.box_name:setText(info.name)
    self.box_introduce:setText(info.desc)
    self.box_tips_num:setText(info.amount)

    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            return true
        elseif event_type == "ended" then
            if not self.not_close_rect:containsPoint(ccp(x, y)) then
                getUIManager():close('ClsStoreTip')
            end
        end
    end)
end

return ClsStoreTip
