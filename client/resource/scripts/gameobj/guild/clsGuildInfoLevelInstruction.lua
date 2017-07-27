local ClsBaseView = require("ui/view/clsBaseView")
local ClsMusicInfo = require("scripts/game_config/music_info")

local ClsGuildInfoLevelInstruction = class("ClsGuildInfoLevelInstruction",ClsBaseView)

function ClsGuildInfoLevelInstruction:getViewConfig(...)
    return {
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

function ClsGuildInfoLevelInstruction:onEnter()
    local ui_layer = UIWidget:create()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_level.json")
    convertUIType(panel)
    ui_layer:addChild(panel)
    self:addWidget(ui_layer)

    local btn_close = getConvertChildByName(panel, "btn_close")
    btn_close:setPressedActionEnabled(true) 
    btn_close:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_CLOSE.res)
            self:close()
        end,TOUCH_EVENT_ENDED)
end

return ClsGuildInfoLevelInstruction