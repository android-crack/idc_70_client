local ClsBattleAddSkill = class("ClsBattleAddSkill", require("gameobj/battle/view/base"))

function ClsBattleAddSkill:ctor(ship_id, skill_id, level, passive, ord)
	self:InitArgs(ship_id, skill_id, level, passive, ord)
end

function ClsBattleAddSkill:InitArgs(ship_id, skill_id, level, passive, ord)
    self.ship_id = ship_id
    self.skill_id = skill_id
    self.level = level
    self.passive = passive
    self.ord = ord

    self.args = {ship_id, skill_id, level, passive, ord}
end

function ClsBattleAddSkill:GetId()
    return "battle_add_skill"
end

-- 播放
function ClsBattleAddSkill:Show()
	local battle_data = getGameData():getBattleDataMt()
    local shipObj = battle_data:getShipByGenID(self.ship_id)

    if shipObj and not shipObj:is_deaded() then
    	shipObj:addSkill(self.skill_id, self.level, self.passive, nil, true, self.ord)
    end
end

return ClsBattleAddSkill
