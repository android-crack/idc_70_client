local skill_map = require("game_config/battleSkill/skill_map")

local ClsBattleUseSkill = class("ClsBattleUseSkill", require("gameobj/battle/view/base"))

function ClsBattleUseSkill:ctor(attacker_id, targets_id, skill_id, x, z)
    self:InitArgs(attacker_id, targets_id, skill_id, x, z)
end

function ClsBattleUseSkill:InitArgs(attacker_id, targets_id, skill_id, x, z)
    self.attacker_id = attacker_id 
    self.targets_id = targets_id
    self.skill_id = skill_id
    self.x = x
    self.z = z

    self.args = {attacker_id, targets_id, skill_id, x, z}
end

function ClsBattleUseSkill:GetId()
    return "battle_use_skill"
end

function ClsBattleUseSkill:Show()
    local battle_data = getGameData():getBattleDataMt()
    local attacker = battle_data:getShipByGenID(self.attacker_id)

    if not attacker or attacker:is_deaded() then return end

    local cls_skill = skill_map[self.skill_id]

    if not cls_skill then return end

    -- local cd = cls_skill:get_skill_cd(attacker)
    -- attacker:set_skill_cd(self.skill_id, cd)

    -- if cls_skill:get_skill_type() ~= "auto" then 
    --     local common_cd = cls_skill:get_common_cd()
    --     attacker:set_common_skill_cd(common_cd, self.skill_id)
    -- end

    -- if battle_data:isCurClientControlShip(self.attacker_id) then
    --     local battle_ui = battle_data:GetLayer("battle_ui")
    --     if not tolua.isnull(battle_ui) then 
    --         battle_ui:updateSkillUI(self.skill_id)
    --     end
    -- end

    if cls_skill:get_skill_series() > 0 then
        attacker:setData(self.skill_id, {x = self.x/FIGHT_SCALE, z = self.z/FIGHT_SCALE})
    end

    cls_skill:perfromSkillDisplay(attacker, self.targets_id)
end

return ClsBattleUseSkill
