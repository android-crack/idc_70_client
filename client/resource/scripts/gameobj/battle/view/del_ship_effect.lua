local ClsDelShipEffect = class("ClsDelShipEffect", require("gameobj/battle/view/base"))

function ClsDelShipEffect:ctor(id, eff_id)
    self:InitArgs(id, eff_id)
end

function ClsDelShipEffect:InitArgs(id, eff_id)
    self.id = id
    self.eff_id = eff_id

    self.args = {id, eff_id}
end

function ClsDelShipEffect:GetId()
    return "del_ship_effect"
end

-- 播放
function ClsDelShipEffect:Show()
	local battle_data = getGameData():getBattleDataMt()

    local ship = battle_data:getShipByGenID(self.id)

    if not ship or ship:is_deaded() then return end

    ship:delEffect(self.eff_id)
end

return ClsDelShipEffect