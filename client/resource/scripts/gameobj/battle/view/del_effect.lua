local ClsDelEffect = class("ClsDelEffect", require("gameobj/battle/view/base"))

function ClsDelEffect:ctor(target_id, eff_type, eff_name, buff_icon)
    self:InitArgs(target_id, eff_type, eff_name, buff_icon)
end

function ClsDelEffect:InitArgs(target_id, eff_type, eff_name, buff_icon)
    self.target_id = target_id
    self.eff_type = eff_type
    self.eff_name = eff_name
    self.buff_icon = buff_icon

    self.args = {target_id, eff_type, eff_name, buff_icon}
end

function ClsDelEffect:GetId()
    return "del_effect"
end

-- 播放
function ClsDelEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.target_id)
	
	if ship_obj then
		local skill_effect_util = require("module/battleAttrs/skill_effect_util")
		if type(self.eff_type) == "table" and #self.eff_type > 0 then
			for k, effect_type in ipairs(self.eff_type) do
				local func = skill_effect_util.del_effect_funcs[effect_type]
				local eff_name = self.eff_name[k]
				if func and eff_name and eff_name ~= "" then
					func({id = eff_name, owner = ship_obj})
				end
			end
		end

		if self.buff_icon and ship_obj:getBody() and ship_obj:getBody().ui and ship_obj:getBody().ui.buffIconsBar then
			ship_obj:getBody().ui.buffIconsBar:RemoveBuffIcon(self.buff_icon)
		end
	end
end

function ClsDelEffect:serialize(frame)
    return json.encode({frame, self.target_id, self.eff_type, self.eff_name, self.buff_icon})  
end

function ClsDelEffect:unserialize(str)
    local frame, target_id, eff_type, eff_name, buff_icon = unpack(json.decode(str))
    self:InitArgs(target_id, eff_type, eff_name, buff_icon)
    return self.args
end

return ClsDelEffect