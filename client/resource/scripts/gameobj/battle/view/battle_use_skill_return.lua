local skill_map = require("game_config/battleSkill/skill_map")

local ClsBattleUseSkillReturn = class("ClsBattleUseSkillReturn", require("gameobj/battle/view/base"))

function ClsBattleUseSkillReturn:ctor(attacker_id, skill_id, error)
    self:InitArgs(attacker_id, skill_id, error)
end

function ClsBattleUseSkillReturn:InitArgs(attacker_id, skill_id, error)
    self.attacker_id = attacker_id 
    self.skill_ex_id = skill_id
    self.error = error

    self.args = {attacker_id, skill_id, error}
end

function ClsBattleUseSkillReturn:GetId()
    return "battle_use_skill_return"
end

function ClsBattleUseSkillReturn:Show()
    local battle_data = getGameData():getBattleDataMt()
    local attacker = battle_data:getShipByGenID(self.attacker_id)

    attacker.common_skill_cd = getCurrentLogicTime()
	attacker:set_skill_cd(self.skill_ex_id, 0)

    if self.skill_ex_id == "sk1" or self.skill_ex_id == "sk2" then return end

    if not battle_data:isCurClientControlShip(self.attacker_id) then return end

	local battle_ui = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		battle_ui:setCommonSkillCD()
	end
end

return ClsBattleUseSkillReturn
