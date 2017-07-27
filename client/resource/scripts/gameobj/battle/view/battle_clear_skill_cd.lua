local ClsAddEffect = class("ClsAddEffect", require("gameobj/battle/view/base"))

function ClsAddEffect:ctor(ship_id, skill_ex_id)
    self:InitArgs(ship_id, skill_ex_id)
end

function ClsAddEffect:InitArgs(ship_id, skill_ex_id)
    self.ship_id = ship_id
    self.skill_ex_id = skill_ex_id

    self.args = {ship_id, skill_ex_id}
end

function ClsAddEffect:GetId()
    return "battle_clear_skill_cd"
end

return ClsAddEffect
