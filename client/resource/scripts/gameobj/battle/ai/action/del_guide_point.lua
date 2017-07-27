local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDelGuidePoint = class("ClsAIActionDelGuidePoint", ClsAIActionBase) 

function ClsAIActionDelGuidePoint:getId()
	return "del_guide_point"
end

function ClsAIActionDelGuidePoint:__dealAction(target_id, delta_time)
	local battleData = getGameData():getBattleDataMt()
	local target_obj = battleData:getShipByGenID(target_id)

	if not target_obj or not target_obj.body then return false end

	-- 设置特效
	target_obj.body:closeShipYellowPathNode(false)

	require("gameobj/battle/battleRecording"):recordVarArgs("battle_guide_point", target_id, false)

	return true
end

return ClsAIActionDelGuidePoint
