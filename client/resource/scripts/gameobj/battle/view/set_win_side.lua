local ClsSetWinSide = class("ClsSetWinSide", require("gameobj/battle/view/base"))

function ClsSetWinSide:ctor(side)
	self:InitArgs(side)
end

function ClsSetWinSide:InitArgs(side)
	self.side = side

	self.args = {side}
end

function ClsSetWinSide:GetId()
    return "set_win_side"
end

return ClsSetWinSide
