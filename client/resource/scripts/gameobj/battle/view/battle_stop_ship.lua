local ClsBattleStopShip = class("ClsBattleStopShip", require("gameobj/battle/view/base"))

function ClsBattleStopShip:ctor(id)
    self:InitArgs(id)
end

function ClsBattleStopShip:InitArgs(id)
    self.id = id

    self.args = {id}
end

function ClsBattleStopShip:GetId()
    return "battle_stop_ship"
end

-- 播放
function ClsBattleStopShip:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(self.id)
	if ship and not ship:is_deaded() and ship:getBody() then
        ship:tryRunAI(SYS_CLEAR)
        ship:getBody():resetPath()
	end
end

return ClsBattleStopShip