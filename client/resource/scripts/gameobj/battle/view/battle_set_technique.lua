local ClsBattleSetTechnique = class("ClsBattleSetTechnique", require("gameobj/battle/view/base"))

function ClsBattleSetTechnique:ctor(id, technique)
    self:InitArgs(id, technique)
end

function ClsBattleSetTechnique:InitArgs(id, technique)
    self.id = id
    self.technique = technique

    self.args = {id, technique}
end

function ClsBattleSetTechnique:GetId()
    return "battle_set_technique"
end

function ClsBattleSetTechnique:Show()
    local battle_data = getGameData():getBattleDataMt()
    local target_obj = battle_data:getShipByGenID(self.id)

    if not target_obj or target_obj:is_deaded() then return false end

    target_obj:getBody():setFlowState(self.technique)
end

return ClsBattleSetTechnique
