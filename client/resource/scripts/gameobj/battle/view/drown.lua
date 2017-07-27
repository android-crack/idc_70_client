local ClsDrown = class("ClsDrown", require("gameobj/battle/view/base"))

function ClsDrown:ctor(id)
    self:InitArgs(id)
end

function ClsDrown:InitArgs(id)
    self.id = id

    self.args = {id}
end

function ClsDrown:GetId()
    return "drown"
end

-- 播放
function ClsDrown:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj and not ship_obj:is_deaded() then
		ship_obj:release(true)
	end
end

return ClsDrown
