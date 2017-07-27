local ClsHideEffect = class("ClsHideEffect", require("gameobj/battle/view/base"))

function ClsHideEffect:ctor(id, effect_name)
    self:InitArgs(id, effect_name)
end

function ClsHideEffect:InitArgs(id, effect_name)
    self.id = id
    self.effect_name = effect_name

    self.args = {id, effect_name}
end

function ClsHideEffect:GetId()
    return "hide_effect"
end

-- 播放
function ClsHideEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj and ship_obj.body and ship_obj.body.effect_control then
		ship_obj.body.effect_control:hide(self.effect_name)
	end
end

return ClsHideEffect
