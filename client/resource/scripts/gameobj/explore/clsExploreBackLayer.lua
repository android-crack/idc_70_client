--
-- Author: lzg0496
-- Date: 2016-12-07 21:51:10
-- Function: 探索任务回退层
local ClsBaseView = require("ui/view/clsBaseView")

local ClsExploreBackLayer = class("ClsExploreBackLayer", ClsBaseView)

function ClsExploreBackLayer:getViewConfig()
    return {
        name = "ClsExploreBackLayer",
        is_swallow = false
    }
end

function ClsExploreBackLayer:onEnter()
   
end

function ClsExploreBackLayer:onExit()
end

return ClsExploreBackLayer