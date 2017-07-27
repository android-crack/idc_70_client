-- battle_sailor_slogan
-- Author: Ltian
-- Date: 2016-10-17 19:27:48
--
local battle_sailor_slogan = class("battle_sailor_slogan", require("gameobj/battle/view/base"))

function battle_sailor_slogan:ctor(ship_id, skill_id)
	self:InitArgs(ship_id, skill_id)
end

function battle_sailor_slogan:InitArgs(ship_id, skill_id)
	self.ship_id = ship_id
	self.skill_id = skill_id
	self.args = {self.ship_id, self.skill_id }
	
end

function battle_sailor_slogan:GetId()
    return "battle_sailor_slogan"
end

function battle_sailor_slogan:Show()
	local battle_data = getGameData():getBattleDataMt()
	local battle_ui = battle_data:GetLayer("battle_ui")

	if tolua.isnull(battle_ui) then return end
	
	battle_ui:setSlogan(self.ship_id, self.skill_id)
end

return battle_sailor_slogan