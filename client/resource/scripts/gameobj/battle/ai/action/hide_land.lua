local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionHideLand = class("ClsAIActionHideLand", ClsAIActionBase)

function ClsAIActionHideLand:getId()
	return "hide_land"
end

function ClsAIActionHideLand:initAction(is_visible)
	self.is_visible = is_visible
end

function ClsAIActionHideLand:__dealAction(target_id, delta_time)
	local battle_data = getGameData():getBattleDataMt()

	local map_layer = battle_data:GetLayer("map_layer")

	if tolua.isnull(map_layer) then return end

	map_layer:setVisible(self.is_visible == "true")
end

return ClsAIActionHideLand