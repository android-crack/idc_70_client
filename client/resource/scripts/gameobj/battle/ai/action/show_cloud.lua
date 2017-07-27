-- 出云
-- Author: Ltian
-- Date: 2016-07-16 16:41:28
--

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionShowCloud = class("ClsAIActionShowCloud", ClsAIActionBase) 

function ClsAIActionShowCloud:getId()
	return "show_cloud"
end

 
function ClsAIActionShowCloud:initAction(time, begin_x, begin_y, end_x, end_y)
	self.time = time
    self.begin_x = begin_x
    self.begin_y = begin_y
    self.end_x = end_x
    self.end_y = end_y
end

function ClsAIActionShowCloud:__dealAction( target, delta_time )
	local battleData = getGameData():getBattleDataMt()
	local battleEffectLayer = battleData:GetLayer("effect_layer")
	if tolua.isnull(battleEffectLayer) then 
		return 
	end
	battleEffectLayer:showCloud({self.time, {self.begin_x, self.begin_y}, {self.end_x, self.end_y}})

	require("gameobj/battle/battleRecording"):recordVarArgs("show_cloud", self.time, self.begin_x, self.begin_y, self.end_x, self.end_y)
end

return ClsAIActionShowCloud