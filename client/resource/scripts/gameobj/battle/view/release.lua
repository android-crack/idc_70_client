local ClsRelease = class("ClsRelease", require("gameobj/battle/view/base"))

function ClsRelease:ctor(id)
    self:InitArgs(id)
end

function ClsRelease:InitArgs(id)
    self.id = id

    self.args = {id}
end

function ClsRelease:GetId()
    return "release"
end

-- 播放
function ClsRelease:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj and not ship_obj:is_deaded() then
		ship_obj:release()
	end
end

return ClsRelease
