local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionForgeWeather = class("ClsAIActionForgeWeather", ClsAIActionBase) 

local shipEntity = require("gameobj/battle/newShipEntity")

function ClsAIActionForgeWeather:getId()
	return "forge_weather"
end

function ClsAIActionForgeWeather:initAction(delay_time)
	self.delay_time = delay_time
end

function ClsAIActionForgeWeather:__dealAction(target_id, delta_time)
	if not self.delay_time then return end
	
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data then return end
	
	local battle_effect_layer = battle_data:GetLayer("effect_layer")
	if tolua.isnull(battle_effect_layer) then 
		return 
	end

	battle_effect_layer:showStome(self.delay_time)

	require("gameobj/battle/battleRecording"):recordVarArgs("battle_forge_weather", self.delay_time)
end

return ClsAIActionForgeWeather
