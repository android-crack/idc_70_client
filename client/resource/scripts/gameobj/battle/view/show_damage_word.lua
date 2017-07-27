local ClsShowDamageWord = class("ClsShowDamageWord", require("gameobj/battle/view/base"))

function ClsShowDamageWord:ctor(id, value, isCure, tbResult)
    self:InitArgs(id, value, isCure, tbResult)
end

function ClsShowDamageWord:InitArgs(id, value, isCure, tbResult)
    self.id = id
    self.value = value
    self.isCure = isCure
    self.tbResult = tbResult

    self.args = {id, value, isCure, tbResult}
end

function ClsShowDamageWord:GetId()
    return "show_damage_word"
end

-- 播放
function ClsShowDamageWord:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		require("gameobj/battle/shipEffectLayer").showDamageWord(ship_obj, self.value, self.isCure, nil, 
			self.tbResult)
	end
end

return ClsShowDamageWord