local ClsBattleSetTarget = class("ClsBattleSetTarget", require("gameobj/battle/view/base"))

function ClsBattleSetTarget:ctor(id, target_id)
	self:InitArgs(id, target_id)
end

function ClsBattleSetTarget:InitArgs(id, target_id)
	self.id = id
	self.target_id = target_id

	self.args = {id, target_id}
end

function ClsBattleSetTarget:GetId()
    return "battle_set_target"
end

function ClsBattleSetTarget:gotProtcol()
	local battle_data = getGameData():getBattleDataMt()

	if battle_data:IsPlaying() then return end

	local ship = battle_data:getShipByGenID(self.id)
	if ship and ship:getTeamId() ~= battle_config.default_team_id then
		local target = battle_data:getShipByGenID(self.target_id)
		ship.target = target
	end
end

function ClsBattleSetTarget:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(self.id)
	if ship then
		local target = battle_data:getShipByGenID(self.target_id)

		if battle_data:isCurClientControlShip(self.id) and target and not target:is_deaded() then
			if ship.target and not ship.target:is_deaded() then
				ship.target:getBody():hideGuanquan()
			end
			target.body:showGuanquan()
		end
		ship.target = target
	end
end

return ClsBattleSetTarget
