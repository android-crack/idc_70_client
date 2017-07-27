local ClsBaseView = require("ui/view/clsBaseView")
local ClsBattleVirLayer = class("ClsBattleVirLayer", ClsBaseView)

function ClsBattleVirLayer:getViewConfig(name)
    return {
        name = name,
        is_swallow = false,
    }
end

return ClsBattleVirLayer