local ClsBaseView = require("ui/view/clsBaseView")

local ClsShieldLayer = class("ClsShieldLayer", ClsBaseView)
function ClsShieldLayer:getViewConfig()
    return {
    	name = "ClsShieldLayer",
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsShieldLayer:onEnter(parameter)
    self:configEvent()

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(5))
    arr:addObject(CCCallFunc:create(function()
        self:close()
    end))
    self:runAction(CCSequence:create(arr))
end

function ClsShieldLayer:configEvent()
    self:regTouchEvent(self, function(eventType, x, y)
        if eventType == "began" then
            return true
        elseif eventType == "ended" then
            cclog("点中了屏蔽层")
        end
    end)
end

return ClsShieldLayer