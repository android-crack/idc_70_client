local ClsChangTeam = class("ClsChangTeam", require("gameobj/battle/view/base"))

function ClsChangTeam:ctor(shipId, teamId)
	self:InitArgs(shipId, teamId)
end

function ClsChangTeam:InitArgs(shipId, teamId)
    self.shipId = shipId
    self.teamId = teamId 

    self.args = {shipId, teamId}
end

function ClsChangTeam:GetId()
    return "change_team"
end

function ClsChangTeam:gotProtcol()
	local battle_data = getGameData():getBattleDataMt()
    local shipObj = battle_data:getShipByGenID(self.shipId)
    if not shipObj or shipObj:is_deaded() then return end
	battle_data:changeTeam(shipObj, self.teamId, true)
end

-- 播放
function ClsChangTeam:Show()
end

return ClsChangTeam
