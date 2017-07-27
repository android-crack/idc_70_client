--
-- Author: lzg0496
-- Date: 2016-12-04 22:20:07
-- Function: 探索遮罩层

local clsExploreBlankLayer = class("clsExploreBlankLayer", require("ui/view/clsBaseView"))

function clsExploreBlankLayer:getViewConfig()
    return {is_swallow = false}
end

function clsExploreBlankLayer:onEnter()
    self.m_reason = {}
    self.reason_count = 0
end

function clsExploreBlankLayer:setBlankReason(reason)
    if self.m_reason[reason] then
        self.m_reason[reason] = true
        self.reason_count = self.reason_count + 1
    end

    self:setSwallowTouch(true)
end

function clsExploreBlankLayer:releaseBlankReason(reason)
    if self.m_reason[reason] then
        self.m_reason[reason] = nil
        self.reason_count = self.reason_count - 1
    end

    if self.reason_count == 0 then
        self:setSwallowTouch(false)
    end
end

return clsExploreBlankLayer