-- battle_pvp_kill_tips
-- Author: Ltian
-- Date: 2016-10-14 18:50:38
--
local battle_pvp_kill_tips = class("battle_pvp_kill_tips", require("gameobj/battle/view/base"))

function battle_pvp_kill_tips:ctor(attacker, be_attacker)
	self:InitArgs(attacker, be_attacker)
end

function battle_pvp_kill_tips:InitArgs(attacker_id, be_attacker_id)
	self.attacker_id = attacker_id
	self.be_attacker_id = be_attacker_id
	self.args = {self.attacker_id, self.be_attacker_id }
	
end

function battle_pvp_kill_tips:GetId()
    return "battle_pvp_kill_tips"
end

function battle_pvp_kill_tips:Show()
	local battle_data = getGameData():getBattleDataMt()
	local battle_ui = battle_data:GetLayer("battle_ui")
	local attacker = battle_data:getShipByGenID(self.attacker_id)
	local be_attacker = battle_data:getShipByGenID(self.be_attacker_id)

	if not attacker or not be_attacker then return end

	local my_control_ship = battle_data:getCurClientControlShip()
	local attacker_name, attacker_name_is_null, attacker_is_enemy, attacker_sailor_id = my_control_ship:getPvpKillInfo(attacker)
	local be_attacker_name, be_attacker_name_is_null, be_attacker_is_enemy, be_attacker_sailor_id = my_control_ship:getPvpKillInfo(be_attacker)
	if attacker and not attacker:is_deaded() then
		if not tolua.isnull(battle_ui) then
			if not attacker_name_is_null  and not be_attacker_name_is_null and 
				attacker_sailor_id > 0 and 
				be_attacker_sailor_id > 0 
			then
				local attacker = {
					name = attacker_name,
					is_enemy = attacker_is_enemy,
					sailor_id = attacker_sailor_id
				}
				local be_attacker = {
					name = be_attacker_name,
					is_enemy = be_attacker_is_enemy,
					sailor_id = be_attacker_sailor_id
				}
				battle_data:GetLayer("battle_ui"):showPvPKillTip(attacker, be_attacker )
		    	
		    end
			
		end
	end

	
	
		

end

return battle_pvp_kill_tips