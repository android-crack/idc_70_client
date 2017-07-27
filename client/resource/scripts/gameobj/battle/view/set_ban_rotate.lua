local ClsSetBanRotate = class("ClsSetBanRotate", require("gameobj/battle/view/base"))

function ClsSetBanRotate:ctor(id, value)
    self:InitArgs(id, value)
end

function ClsSetBanRotate:InitArgs(id, value)
    self.id = id
    self.value = value

    self.args = {id, value}
end

function ClsSetBanRotate:GetId()
    return "set_ban_rotate"
end

-- 播放
function ClsSetBanRotate:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		ship_obj.body:setBanRotate(self.value)
	end
end

return ClsSetBanRotate
