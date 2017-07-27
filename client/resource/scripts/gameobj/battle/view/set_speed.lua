local ClsSetSpeed = class("ClsSetSpeed", require("gameobj/battle/view/base"))

function ClsSetSpeed:ctor(params)
	self.args = {}

	if not params then return end

    self:InitArgs(params.id, params.speed)
end

function ClsSetSpeed:InitArgs(id, speed)
    self.id = id
    self.speed = speed

    self.args = {id, speed}
end

function ClsSetSpeed:GetId()
    return "set_speed"
end

-- 播放
function ClsSetSpeed:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		ship_obj.body:setSpeed(self.speed)
	end
end

return ClsSetSpeed