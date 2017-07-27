local battle_data_util = {}
local skill_info = require("game_config/skill/skill_info")
local skill_site = require("game_config/skill/skill_site")
function battle_data_util:getOpponentLeaderSkills(boat_info, is_leader)
	local skills = {}
	if is_leader then
		for i, sailor in ipairs(boat_info.sailors) do -- 如果是leader,则从船舶的sailor字段获取技能数据
			for i, skill in ipairs(sailor.skills) do
				skills[skill.id] = skill.level
			end
		end
	else	
		for i, skill in ipairs(boat_info.leader.skills) do
			skills[skill.id] = skill.level
		end
	end
	
	local main_skill = {}
	for id,lv in pairs(skills) do
		--计算航海术以外的大技能最高级
		local keyStr=string.sub(skill_info[id].site,1,2)
		local keyStrId=string.sub(skill_info[id].site,3,3)
		if tonumber(keyStrId) == 1 then 
			if not main_skill[keyStr] then main_skill[keyStr]={} end
			local site=skill_site[keyStr][id].site
			main_skill[keyStr][site] = lv
		end
	end
	for id,_ in pairs(skills) do
		local keyStr=string.sub(skill_info[id].site,1,2)
		local keyStrId=string.sub(skill_info[id].site,3,3)
		if tonumber(keyStrId) >  1 then 
			local lv = main_skill[keyStr][1]
			skills[id] = lv
		end
	end
	return skills
end


function battle_data_util:getHeadId(ret, fightType)
	if ret.is_leader == 1 then 
		if (ret.sailor_id and ret.sailor_id ~= 0) or (ret.role and ret.role ~= 0) then 
			return 1
		end
		return 3
	elseif fightType ~= nil and fightType == battle_config.fight_type_portPve and ret.is_pirate ~= nil and ret.is_pirate == 1 then
		return 3
	elseif ret.isFormation == 1 then  
		if ret.sailor_id and ret.sailor_id ~= 0 then 
			return 2
		end 	
		return 3
	end 
	
	return 4
end

return battle_data_util