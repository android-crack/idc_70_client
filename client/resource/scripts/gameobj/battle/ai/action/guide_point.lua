local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionGuidePoint = class("ClsAIActionGuidePoint", ClsAIActionBase) 

function ClsAIActionGuidePoint:getId()
	return "guide_point"
end

function ClsAIActionGuidePoint:initAction(x, y)
	self.x = x				-- 2维屏幕的坐标
	self.y = y				-- 2维屏幕的坐标
end

function ClsAIActionGuidePoint:__dealAction(target_id, delta_time)
	local filename = "plane002"

	local battleData = getGameData():getBattleDataMt()
	local target_obj = battleData:getShipByGenID(target_id)

	if not target_obj then return false end
	if target_obj.isDeaded then return false end
	local point = {x = self.x, y = self.y} 

	-- 设置特效
	target_obj.body:addTargetPathEffect(cocosToGameplayWorld(point), filename, true)

	require("gameobj/battle/battleRecording"):recordVarArgs("battle_guide_point", target_id, true, self.x, self.y, filename)

	return true
end

return ClsAIActionGuidePoint
