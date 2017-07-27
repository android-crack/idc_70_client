local ClsSetShipHp = class("ClsSetShipHp", require("gameobj/battle/view/base"))

function ClsSetShipHp:ctor(id, value, md_value, not_show, baoji, is_near_attack)
    self:InitArgs(id, value, md_value, not_show, baoji, is_near_attack)
end

function ClsSetShipHp:InitArgs(id, value, md_value, not_show, baoji, is_near_attack)
    self.id = id
    self.value = value
    self.md_value = md_value

    self.not_show = tonumber(not_show) == 1
    self.baoji = tonumber(baoji) == 1
    self.is_near_attack = tonumber(is_near_attack) == 1

    self.args = {id, value, md_value, not_show, baoji, is_near_attack}
end

function ClsSetShipHp:GetId()
    return "set_ship_hp"
end

-- 播放
function ClsSetShipHp:gotProtcol()
	local battle_data = getGameData():getBattleDataMt()

	local ship_obj = battle_data:getShipByGenID(self.id)
	if ship_obj then
		ship_obj.values.hp = self.value

        require("gameobj/battle/shipEffectLayer").updateShipHp(ship_obj, self.not_show and 0 or self.md_value)

        if self.not_show then return end

        local tbResult = {}
        if self.baoji then
            tbResult.baoji_flag = true
        end
        if self.is_near_attack then
            tbResult.is_near_attack = true
        end

        local shipEffectLayer = require("gameobj/battle/shipEffectLayer")
        shipEffectLayer.showDamageWord(ship_obj, self.md_value, self.md_value > 0, tbResult)
	end
end

return ClsSetShipHp