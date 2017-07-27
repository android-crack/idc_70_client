local ClsAddShipEffect = class("ClsAddShipEffect", require("gameobj/battle/view/base"))

function ClsAddShipEffect:ctor(id, eff_id, filename, dx, dy, time, follow_ship)
    self:InitArgs(id, eff_id, filename, dx, dy, time, follow_ship)
end

function ClsAddShipEffect:InitArgs(id, eff_id, filename, dx, dy, time, follow_ship)
    self.id = id
    self.eff_id = eff_id
    self.filename = filename
    self.dx = dx
    self.dy = dy
    self.time = time
    self.follow_ship = follow_ship

    self.args = {id, eff_id, filename, dx, dy, time, follow_ship}
end

function ClsAddShipEffect:GetId()
    return "add_ship_effect"
end

-- 播放
function ClsAddShipEffect:Show()
	local battle_data = getGameData():getBattleDataMt()

    local ship = battle_data:getShipByGenID(self.id)

    if not ship or ship:is_deaded() then return end

    ship:addEffect(self.eff_id, self.filename, self.dx, self.dy, self.time, self.follow_ship)
end

return ClsAddShipEffect
