local ClsSetBanTurn = class("ClsSetBanTurn", require("gameobj/battle/view/base"))

function ClsSetBanTurn:ctor(params)
	self.args = {}

	if not params then return end

    self:InitArgs(params.id, params.value)
end

function ClsSetBanTurn:InitArgs(id, value)
    self.id = id
    self.value = value

    self.args = {id, value}
end

function ClsSetBanTurn:GetId()
    return "set_ban_turn"
end

-- 播放
function ClsSetBanTurn:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		ship_obj.body:setBanTurn(self.value)
	end
end

return ClsSetBanTurn