local ClsDelUtilEffect = class("ClsDelUtilEffect", require("gameobj/battle/view/base"))

function ClsDelUtilEffect:ctor(params)
	self.args = {}

	if not params then return end

    self:InitArgs(params.target_id, params.eff_type, params.eff_name)
end

function ClsDelUtilEffect:InitArgs(target_id, eff_type, eff_name)
    self.target_id = target_id
    self.eff_type = eff_type
    self.eff_name = eff_name

    self.args = {target_id, eff_type, eff_name}
end

function ClsDelUtilEffect:GetId()
    return "del_util_effect"
end

-- 播放
function ClsDelUtilEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.target_id)
	if ship_obj then
		local skill_effect_util = require("module/battleAttrs/skill_effect_util")
		skill_effect_util.del_effect_funcs[self.eff_type]({id = self.eff_name, target = ship_obj})
	end
end

return ClsDelUtilEffect