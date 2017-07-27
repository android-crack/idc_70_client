local ClsBattleShowMiss = class("ClsBattleShowMiss", require("gameobj/battle/view/base"))

function ClsBattleShowMiss:ctor(ship_id)
	self:InitArgs(ship_id)
end

function ClsBattleShowMiss:InitArgs(ship_id)
    self.ship_id = ship_id

    self.args = {ship_id}
end

function ClsBattleShowMiss:GetId()
    return "battle_show_miss"
end

-- 播放
function ClsBattleShowMiss:Show()
	local battle_data = getGameData():getBattleDataMt()
    local ship_obj = battle_data:getShipByGenID(self.ship_id)

    if ship_obj and not ship_obj:is_deaded() then
    	require("gameobj/battle/shipEffectLayer").showMiss(ship_obj)
    end
end

return ClsBattleShowMiss
