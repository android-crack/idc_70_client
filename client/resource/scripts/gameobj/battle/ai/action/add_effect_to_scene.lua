local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionAddEffectToScene = class("ClsAIActionAddEffectToScene", ClsAIActionBase) 

function ClsAIActionAddEffectToScene:getId()
	return "add_effect_to_scene"
end

function ClsAIActionAddEffectToScene:initAction(id, filename, dx, dy, time, angle, follow)
	
	self.id = id	
	self.filename = filename
	self.dx = dx
	self.dy = dy
	self.time = time
	self.angle = angle
	self.is_follow = follow
end

function ClsAIActionAddEffectToScene:__dealAction(target_id, delta_time)
	local battleData = getGameData():getBattleDataMt()

	local target_obj = nil
	if self.is_follow then
		target_obj = battleData:getShipByGenID(target_id)
	end
	
	battleData:addEffect(self.id, self.filename, self.dx, self.dy, self.time, self.angle, target_obj)

	require("gameobj/battle/battleRecording"):recordVarArgs("add_scene_effect", self.id, self.filename, 
		self.dx, self.dy, self.time, self.angle)

	return true
end

return ClsAIActionAddEffectToScene
