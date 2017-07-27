--为了配合蛋疼的策划水手学习部分 要单独提取技能出来也就是与水手无关
--航海术技能除外 这个与水手有关
local skill_info=require("game_config/skill/skill_info")


SKILL_MAX_LEVEL=3  --技能学习提升的等级上限

local ClsSkillData = class("shopData")

function ClsSkillData:ctor()
	self.skillLevels = {} --key  skillId	value level
end

function ClsSkillData:setSkillLevel(id,sailorId,level)
	if not self.skillLevels[id] then
        self.skillLevels[id]={}
    end
    self.skillLevels[id][sailorId]=level
end

function ClsSkillData:getSkillLevel(id,sailorId)
    if not self.skillLevels[id] then return nil end
	return self.skillLevels[id][sailorId]
end

function ClsSkillData:getAllSkillLevels()
	return self.skillLevels
end

function ClsSkillData:sortSkill(skills) 
    --默认按房间排序
    local roomSkills={}
    for index,skill_id in pairs(skills) do
		local skd = skill_info[skill_id]
        local job = skd.kind
		if roomSkills[job] and roomSkills[job] ~= skill_id then 
			local id = roomSkills[job]
			local skill_site = require("game_config/skill/skill_site")
			local cur_skd = skill_info[id]
			local keyStr=string.sub(cur_skd.site,1,2)	
			if skill_site[keyStr][id].site == 1 then -- 主技能
				roomSkills[job] = skill_id --用子技能替代主技能
			end
		else
			roomSkills[job]=skill_id
		end
    end
    return roomSkills
    
 --[[   {
        [1]=skillId,
        [2]=nil,
        [3]=skillId,
    }]]
end

return ClsSkillData

