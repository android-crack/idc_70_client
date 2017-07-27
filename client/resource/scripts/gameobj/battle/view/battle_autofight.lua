local ClsBattleAutofight = class("ClsBattleAutofight", require("gameobj/battle/view/base"))

function ClsBattleAutofight:ctor(id, auto_flg)
	self:InitArgs(id, auto_flg)
end

function ClsBattleAutofight:InitArgs(id, auto_flg)
	self.id = id

	if auto_flg == 1 then
		auto_flg = true
	elseif auto_flg == 0 then
		auto_flg = false
	end

	self.auto_flg = auto_flg

	self.args = {id, auto_flg and 1 or 0}
end

function ClsBattleAutofight:GetId()
    return "battle_autofight"
end

function ClsBattleAutofight:gotProtcol()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		ship_obj:setAutoFight(self.auto_flg, true)
	else
		battle_data:setAutoShip(self.id, self.auto_flg)
	end
end

function ClsBattleAutofight:Show()
end

return ClsBattleAutofight
