
local  GuildExitViewPanel = class("GuildExitViewPanel", function() return UILayout:create() end)

function GuildExitViewPanel:ctor(touchPriority)
      
    self:setTouchEnabled(true)
    self:setSize(CCSize(display.width,display.height))
    self:addEventListener(function()
        self:onTouchBegan(x, y)
        end,TOUCH_EVENT_BEGAN)

    self:addEventListener(function()
        self:onTouchMoved(x, y)
        end,TOUCH_EVENT_MOVED)

    self:addEventListener(function()
        self:onTouchEnded(x, y)
        end,TOUCH_EVENT_ENDED)

    self:addEventListener(function()
        self:onTouchCancelled(x, y)
        end,TOUCH_EVENT_CANCELED)

end


function GuildExitViewPanel:onTouchBegan(x, y)
    self:removeAllChildren()
    return true
end

function GuildExitViewPanel:onTouchMoved(x, y)
         
end

function GuildExitViewPanel:onTouchEnded(x, y)
    -- self:close()
    self:removeFromParentAndCleanup(true)
end

function GuildExitViewPanel:onTouchCancelled(x, y)

end


return GuildExitViewPanel