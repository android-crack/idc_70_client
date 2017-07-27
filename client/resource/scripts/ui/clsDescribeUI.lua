--
-- Author: lzg0496
-- Date: 2017-04-01 11:48:05
-- Function: 通用的界面显示。一般界面只带了一个关闭按钮和策划拼的文字

local ClsBaseView = require("ui/view/clsBaseView")
local cfg_music_info = require("game_config/music_info")

local clsDescribeUI = class("clsDescribeUI", ClsBaseView)

function clsDescribeUI:getViewConfig(ui_parms)
    return ui_parms
end

--ui_parms除了baseview的参数除外
--json 要创建界面的json名
--is_click_bg_close 是否要点击背景关闭

function clsDescribeUI:onEnter(ui_parms)
    self.ui_parms = ui_parms or {}
    self:makeUI()
end

function clsDescribeUI:makeUI()
    if not self.ui_parms.json then print("创建json为nil") return end

    self.panel = createPanelByJson("json/" .. self.ui_parms.json)
    convertUIType(self.panel)
    self:addWidget(self.panel)

    local btn_close = getConvertChildByName(self.panel, "btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addEventListener(function()
        audioExt.playEffect(cfg_music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)

    if self.ui_parms.is_click_bg_close then
        self:regTouchEvent(self, function(eventType, x, y)
            if eventType == "ended" then
                self:close()
            end
        end)
    end
end

return clsDescribeUI
