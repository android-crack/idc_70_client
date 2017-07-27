local ClsBattleFleetAi = class("ClsBattleFleetAi", require("gameobj/battle/view/base"))

function ClsBattleFleetAi:ctor(base_id, is_prop, is_radar_hide, is_leader, dir, boat_trans_star)
	self:InitArgs(base_id, is_prop, is_radar_hide, is_leader, dir, boat_trans_star)
end

function ClsBattleFleetAi:InitArgs(base_id, is_prop, is_radar_hide, is_leader, dir, boat_trans_star)
	self.base_id = base_id
	self.is_prop = is_prop
	self.is_radar_hide = is_radar_hide
	self.is_leader = is_leader
	self.dir = dir
	self.boat_trans_star = boat_trans_star

	self.args = {base_id, is_prop, is_radar_hide, is_leader, dir, boat_trans_star}
end

function ClsBattleFleetAi:GetId()
    return "battle_enter_scene"
end

return ClsBattleFleetAi
