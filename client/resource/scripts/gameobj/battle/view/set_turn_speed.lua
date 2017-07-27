local ClsSetTurnSpeed = class("ClsSetTurnSpeed", require("gameobj/battle/view/base"))

function ClsSetTurnSpeed:ctor(id, speed)
    self:InitArgs(id, speed)
end

function ClsSetTurnSpeed:InitArgs(id, speed)
    self.id = id
    self.speed = speed

    self.args = {id, speed}
end

function ClsSetTurnSpeed:GetId()
    return "set_turn_speed"
end

-- 播放
function ClsSetTurnSpeed:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		ship_obj.body:setShipTurnSpeed(self.speed)
	end
end

return ClsSetTurnSpeed