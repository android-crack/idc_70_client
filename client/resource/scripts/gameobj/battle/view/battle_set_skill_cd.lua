local ClsBattleSetSkillCD = class("ClsBattleSetSkillCD", require("gameobj/battle/view/base"))

function ClsBattleSetSkillCD:ctor(ship_id, skill_ex_id, cd)
	self:InitArgs(ship_id, skill_ex_id, cd)
end

function ClsBattleSetSkillCD:InitArgs(ship_id, skill_ex_id, cd)
	self.ship_id = ship_id 
	self.skill_ex_id = skill_ex_id
	self.cd = cd

	self.args = {ship_id, skill_ex_id, cd}
end

function ClsBattleSetSkillCD:GetId()
	return "battle_set_skill_cd"
end

function ClsBattleSetSkillCD:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(self.ship_id)

	ship:set_skill_cd(self.skill_ex_id, self.cd/1000.0)

	if self.skill_ex_id == "sk1" or self.skill_ex_id == "sk2" then return end

	if not battle_data:isCurClientControlShip(self.ship_id) then return end

	local battle_ui = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		battle_ui:showSkillCD(self.skill_ex_id)
	end
end

return ClsBattleSetSkillCD
