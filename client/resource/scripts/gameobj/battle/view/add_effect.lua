local ClsAddEffect = class("ClsAddEffect", require("gameobj/battle/view/base"))

function ClsAddEffect:ctor(owner_id, attacker_id, target_id, eff_type, eff_name, duration, buff_icon)
    self:InitArgs(owner_id, attacker_id, target_id, eff_type, eff_name, duration, buff_icon)
end

function ClsAddEffect:InitArgs(owner_id, attacker_id, target_id, eff_type, eff_name, duration, buff_icon)
    self.owner_id = owner_id
    self.attacker_id = attacker_id
    self.target_id = target_id
    self.eff_type = type(eff_type) == "table" and eff_type or {eff_type}
    self.eff_name = type(eff_type) == "table" and eff_name or {eff_name}
    self.duration = duration
    self.buff_icon = buff_icon

    self.args = {owner_id, attacker_id, target_id, eff_type, eff_name, duration, buff_icon}
end

function ClsAddEffect:GetId()
    return "add_effect"
end

-- 播放
function ClsAddEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.owner_id)
	local attacker, target = nil, nil
	if self.attacker_id then
		attacker = battle_data:getShipByGenID(self.attacker_id)
	end
	if self.target_id then
		target = battle_data:getShipByGenID(self.target_id)
	end
	
	if ship_obj then
		local skill_effect_util = require("module/battleAttrs/skill_effect_util")

		if type(self.eff_type) == "table" and #self.eff_type > 0 then
			for k, effect_type in ipairs(self.eff_type) do
				local func = skill_effect_util.effect_funcs[effect_type]
				local eff_name = self.eff_name[k]
				if func and eff_name and eff_name ~= "" then
					skill_effect_util.effect_funcs[effect_type]({id = eff_name, owner = ship_obj, 
						duration = self.duration, attacker = attacker, target = target})
				end
			end
		end

		if self.buff_icon and ship_obj:getBody() and ship_obj:getBody().ui and ship_obj:getBody().ui.buffIconsBar then
			ship_obj:getBody().ui.buffIconsBar:InsertBuffIcon(self.buff_icon)
		end
	end
end

function ClsAddEffect:serialize(frame)
    return json.encode({frame, self.owner_id, self.attacker_id, self.target_id, self.eff_type, self.eff_name, self.duration, self.buff_icon})  
end

function ClsAddEffect:unserialize(str)
    local frame, owner_id, attacker_id, target_id, eff_type, eff_name, duration, buff_icon = unpack(json.decode(str))
    self:InitArgs(owner_id, attacker_id, target_id, eff_type, eff_name, duration, buff_icon)
    return self.args
end


return ClsAddEffect
