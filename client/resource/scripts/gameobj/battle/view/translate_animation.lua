local ClsTranslateAnimation = class("ClsTranslateAnimation", require("gameobj/battle/view/base"))

function ClsTranslateAnimation:ctor(id, x, z)
    self:InitArgs(id, x, z)
end

function ClsTranslateAnimation:InitArgs(id, x, z)
    self.id = id
    self.x = x
    self.z = z

    self.args = {id, x, z}
end

function ClsTranslateAnimation:GetId()
    return "translate_animation"
end

-- 播放
function ClsTranslateAnimation:Show()
	local battle_data = getGameData():getBattleDataMt()
	local target = battle_data:getShipByGenID(self.id)
	if target and target.body and target.body.node then
        local pos = target:getPosition3D()

        local key_values = {pos:x(), pos:y(), pos:z(), self.x/FIGHT_SCALE, 0, self.z/FIGHT_SCALE}

		local skill_effect_util = require("module/battleAttrs/skill_effect_util")
		skill_effect_util.translateAnimation(target, key_values)
	end
end

return ClsTranslateAnimation