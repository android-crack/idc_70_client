local music_info = require("game_config/music_info")
local skill_effect_util = require("module/battleAttrs/skill_effect_util")

local skill_initiative = require("module/battleAttrs/skill_initiative")
local clsSkillAura = class("clsSkillAura", skill_initiative)

clsSkillAura.do_use = function() end

clsSkillAura.do_use_per_second = skill_initiative.do_use

function clsSkillAura:use_effect_display(attacker, targets, callback)
	local eff_dt = self:get_before_effect_time()/1000
	local eff_names = self:get_before_effect_name()
	local eff_types = self:get_before_effect_type()

	local call_back = function()
		if type(callback) == "function" then
			callback(targets)
		end
	end
 
	if type(eff_names) == "table" and #eff_names > 0 then
		for i, eff_name in ipairs(eff_names) do
			-- 施法前特效不能是proj类型的
			eff_type = eff_types[i]
			assert(eff_type ~= "proj")
			
			local func = skill_effect_util.effect_funcs[eff_type]
			if func and eff_name and eff_name ~= "" then
				func({id = eff_name, owner = attacker, duration = eff_dt, callback = call_back})

				call_back = nil
			end
		end
	else
		call_back()
	end

	local sound = self:get_effect_music()
	if sound ~= nil and sound ~= "" and music_info[sound] then	
        local sound_res = music_info[sound].res
        local battle_data = getGameData():getBattleDataMt()
		audioExt.playEffect(sound_res, false, battle_data:isCurClientControlShip(attacker:getId()))
	end
end

-- 技能类型
function clsSkillAura:get_skill_type()
	return "aura"
end

return clsSkillAura
