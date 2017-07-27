local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionAddEffectToShip = class("ClsAIActionAddEffectToShip", ClsAIActionBase) 

function ClsAIActionAddEffectToShip:getId()
	return "add_effect_to_ship"
end

function ClsAIActionAddEffectToShip:initAction(id, filename, dx, dy, time, follow_flg)
	self.id = id	
	self.filename = filename
	self.dx = dx
	self.dy = dy
	self.time = time 
	self.follow_flg =  follow_flg
end

function ClsAIActionAddEffectToShip:__dealAction(target_id, delta_time)
	local battleData = getGameData():getBattleDataMt()
	local target_obj = battleData:getShipByGenID(target_id)

	if not target_obj or target_obj:is_deaded() then
		return false 
	end

	target_obj:addEffect(self.id, self.filename, self.dx, self.dy, self.time, self.follow_flg)

	require("gameobj/battle/battleRecording"):recordVarArgs("add_ship_effect", target_id, self.id, self.filename, 
		self.dx, self.dy, self.time, self.follow_flg)

	return true
end

return ClsAIActionAddEffectToShip
