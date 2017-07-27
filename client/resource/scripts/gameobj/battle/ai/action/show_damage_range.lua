local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionShowDamageRange = class("ClsAIActionShowDamageRange", ClsAIActionBase) 

function ClsAIActionShowDamageRange:getId()
	return "show_damage_range"
end

function ClsAIActionShowDamageRange:initAction(is_show)
	self.is_show = is_show == "true"
end

function ClsAIActionShowDamageRange:__dealAction(target_id, delta_time)
	local battle_data = getGameData():getBattleDataMt()
	battle_data:setShowDamageRange(self.is_show)
end

return ClsAIActionShowDamageRange
