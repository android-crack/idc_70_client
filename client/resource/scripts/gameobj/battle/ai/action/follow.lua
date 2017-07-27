local battleRecording = require("gameobj/battle/battleRecording")

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionFollow = class("ClsAIActionFollow", ClsAIActionBase) 

function ClsAIActionFollow:getId()
	return "follow"
end

function ClsAIActionFollow:initAction(range, duration)
	local battleData = getGameData():getBattleDataMt()

	local ai_obj = self:getOwnerAI()

	local owner_obj = ai_obj:getOwner()

	self.range = range or owner_obj:getFarRange()*0.8

	self.duration = duration or 99999999 

	local follow_id = ai_obj:getData("__follow_target_id")
	
	self.follow_id = follow_id

	self.begin_follow = true
end

function ClsAIActionFollow:__dealAction(target, delta_time)
	if not self.follow_id then return false end

	local ai_obj = self:getOwnerAI()
	local owner_obj = ai_obj:getOwner()

	if not owner_obj:hasBuff("tuji_self") and not owner_obj:checkMoveAction(FV_MOVE_FOLLOW) then return true end
	
	local battleData = getGameData():getBattleDataMt()

	local follow_obj = battleData:getShipByGenID(self.follow_id)

	if not follow_obj or follow_obj:is_deaded() then
		return false
	end

	local distance = GetDistanceFor3D(owner_obj.body.node, follow_obj.body.node)

	if distance < self.range then
		if not self.begin_follow then 
			owner_obj:getBody():resetPath()
			battleRecording:recordVarArgs("battle_stop_ship", owner_obj:getId())
		end
		return false 
	end

	self.begin_follow = false

	local move_type = ASTAR_FIND_PATH
	if owner_obj:hasBuff("tuji_self") then
		move_type = nil
	end

	owner_obj:moveTo(follow_obj:getPosition3D(), FV_MOVE_FOLLOW, move_type)

	return true
end

return ClsAIActionFollow
