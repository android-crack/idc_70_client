local ClsBattleChangeControlShip = class("ClsBattleChangeControlShip", require("gameobj/battle/view/base"))

function ClsBattleChangeControlShip:ctor(id)
	self:InitArgs(id)
end

function ClsBattleChangeControlShip:InitArgs(id)
	self.id = id

	self.args = {id}
end

function ClsBattleChangeControlShip:GetId()
    return "battle_change_control_ship"
end

function ClsBattleChangeControlShip:gotProtcol()
	local battle_data = getGameData():getBattleDataMt()
	battle_data:changeControlShip(self.id, true)
end

function ClsBattleChangeControlShip:Show()
end

return ClsBattleChangeControlShip
