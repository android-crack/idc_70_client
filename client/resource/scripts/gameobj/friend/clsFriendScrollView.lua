--好友的基类
local ClsScrollView = require("ui/view/clsScrollView")

local ClsFriendScrollView = class("ClsFriendScrollView", ClsScrollView)
function ClsFriendScrollView:updateLayerMove()
    if not self.m_drag then return end
    if self.m_drag.is_tap then return end
    if type(self.move_call) == "function" then
    	self.move_call(self.m_drag)
    end
    if not self.m_is_vertical then
        self.m_inner_layer:setPosition(ccp(self.m_drag.end_x - self.m_drag.start_x + self.m_drag.start_layer_x, self.m_drag.start_layer_y))
    else
        self.m_inner_layer:setPosition(ccp(self.m_drag.start_layer_x, self.m_drag.end_y - self.m_drag.start_y + self.m_drag.start_layer_y))
    end
    self:openUpdateTimer()
end

function ClsFriendScrollView:setMoveCall(call)
	if type(call) == "function" then
		self.move_call = call
	end
end

return ClsFriendScrollView