local ClsBattleAddStatus = class("ClsBattleAddStatus", require("gameobj/battle/view/base"))

function ClsBattleAddStatus:ctor(a_id, t_id, skill_id, idx, x, y, combo)
	self:InitArgs(a_id, t_id, skill_id, idx, x, y, combo)
end

function ClsBattleAddStatus:InitArgs(a_id, t_id, skill_id, idx, x, y, combo)
    self.a_id = a_id
    self.t_id = t_id
    self.skill_id = skill_id
    self.idx = idx
    self.x = x/FIGHT_SCALE
    self.y = y/FIGHT_SCALE
    self.combo = combo == FV_BOOL_TRUE

    self.args = {a_id, t_id, skill_id, idx, x, y, combo}
end

function ClsBattleAddStatus:GetId()
    return "battle_add_status"
end

function ClsBattleAddStatus:Show()
	local battle_data = getGameData():getBattleDataMt()
    local attacker = battle_data:getShipByGenID(self.a_id)
    local target = battle_data:getShipByGenID(self.t_id)

    if not target or target:is_deaded() then return end
end

return ClsBattleAddStatus
