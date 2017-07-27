local ClsUtilEffect = class("ClsUtilEffect", require("gameobj/battle/view/base"))

function ClsUtilEffect:ctor(owner_id, eff_name, eff_type, duration)
    self:InitArgs(owner_id, eff_name, eff_type, duration)
end

function ClsUtilEffect:InitArgs(owner_id, eff_name, eff_type, duration)
    self.owner_id = owner_id
    self.eff_type = eff_type
    self.eff_name = eff_name
    self.duration = duration

    self.args = {owner_id, eff_name, eff_type, duration}
end

function ClsUtilEffect:GetId()
    return "util_effect"
end

-- 播放
function ClsUtilEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.owner_id)
	local attacker, target = nil, nil
	if self.attacker_id then
		attacker = battle_data:getShipByGenID(self.attacker_id)
	end
	if self.target_id then
		target = battle_data:getShipByGenID(self.target_id)
	end
	if ship_obj then
		local skill_effect_util = require("module/battleAttrs/skill_effect_util")
		skill_effect_util.effect_funcs[self.eff_type]({id = self.eff_name, owner = ship_obj, 
			duration = self.duration, attacker = attacker, target = target, x = self.x, z = self.z})
	end
end

return ClsUtilEffect
