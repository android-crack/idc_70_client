local ClsSetSpeedRate = class("ClsSetSpeedRate", require("gameobj/battle/view/base"))

function ClsSetSpeedRate:ctor(id, speed)
    self:InitArgs(id, speed)
end

function ClsSetSpeedRate:InitArgs(id, speed)
    self.id = id
    self.speed = speed

    self.args = {id, speed}
end

function ClsSetSpeedRate:GetId()
    return "set_speed_rate"
end

-- 播放
function ClsSetSpeedRate:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		ship_obj.body:setSpeedRate(self.speed)
	end
end

return ClsSetSpeedRate