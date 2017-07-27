local ClsSetPos = class("ClsSetPos", require("gameobj/battle/view/base"))

function ClsSetPos:ctor(id, x, y)
    self:InitArgs(id, x, y)
end

function ClsSetPos:InitArgs(id, x, y)
    self.id = id
    self.x = x
    self.y = y

    self.args = {id, x, y}
end

function ClsSetPos:GetId()
    return "set_pos"
end

-- 播放
function ClsSetPos:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(self.id)

	if not ship or ship:is_deaded() then return end
    
    ship:setPosition(self.x, self.y)
end

return ClsSetPos
