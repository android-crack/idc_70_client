local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionMoveTo = class("ClsAIActionMoveTo", ClsAIActionBase) 

function ClsAIActionMoveTo:getId()
	return "move_to"
end

function ClsAIActionMoveTo:initAction(x, y, range)
	self.position = {x, y}
	self.range = range or 200

	-- 设置持续时间无限长
	self.duration = 99999999
end

function ClsAIActionMoveTo:__dealAction(target, delta_time)
	local battleData = getGameData():getBattleDataMt()

	local target_obj = battleData:getShipByGenID(target)

	if not target_obj or target_obj:is_deaded() then
		return false
	end

	if not target_obj:checkMoveAction(FV_MOVE_MOVETO) then return true end

	local x, y = target_obj:getPosition()

	local pos = self.position
	if not pos then return false end

	if Math.distance(pos[1], pos[2], x, y) <= self.range then
		return false
	else
		target_obj:moveTo(cocosToGameplayWorld(ccp(pos[1], pos[2])), FV_MOVE_MOVETO, ASTAR_FIND_PATH)
	end

	return true
end

return ClsAIActionMoveTo
