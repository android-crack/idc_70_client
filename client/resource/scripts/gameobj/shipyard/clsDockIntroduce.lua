--建造介绍界面
local music_info = require("game_config/music_info")

local touch_rect = CCRect(212, 49, 536, 434)

local ClsBaseView = require("ui/view/clsBaseView")
local ClsDockIntroduce = class("ClsDockIntroduce", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsDockIntroduce:getViewConfig()
    return {
        name = "ClsDockIntroduce",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

--页面创建时调用
function ClsDockIntroduce:onEnter()
    self:configUI()
    self:configEvent()
end

function ClsDockIntroduce:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_build_introduce.json")
    self:addWidget(self.panel)

    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_close:setTouchEnabled(true)
end

function ClsDockIntroduce:configEvent()
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:closeView()
    end, TOUCH_EVENT_ENDED)
end

function ClsDockIntroduce:closeView()
    getUIManager():close("ClsDockIntroduce")
end

return ClsDockIntroduce
