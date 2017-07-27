local ClsBattleFenShen = class("ClsBattleFenShen", require("gameobj/battle/view/base"))

function ClsBattleFenShen:ctor(id, duration, skills, ship_id, gen_id, x, z)
	self:InitArgs(id, duration, skills, ship_id, gen_id, x, z)
end

function ClsBattleFenShen:InitArgs(id, duration, skills, ship_id, gen_id, x, z)
	self.id = id
	self.duration = duration
	self.skills = skills
	self.ship_id = ship_id
	self.gen_id = gen_id
	self.x = x
	self.z = z

	self.args = {id, duration, skills, ship_id, gen_id, x, z}
end

function ClsBattleFenShen:GetId()
    return "battle_fenshen"
end

function ClsBattleFenShen:gotProtcol()
	require("module/battleAttrs/skill_effect_util").real_fenshen_effect(self.id, self.duration, 
		self.skills, self.ship_id, self.gen_id, self.x/FIGHT_SCALE, self.z/FIGHT_SCALE)
end

function ClsBattleFenShen:Show()
end

return ClsBattleFenShen
