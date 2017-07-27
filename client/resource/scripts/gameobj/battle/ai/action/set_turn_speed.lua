-- 设置船转角速度
-- Author: Ltian
-- Date: 2016-09-12 11:02:51
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionSetTurnSpeed = class("ClsAIActionSetTurnSpeed", ClsAIActionBase)

function ClsAIActionSetTurnSpeed:getId()
	return "set_turn_speed"
end

function ClsAIActionSetTurnSpeed:initAction(ai_ids)
	self.ai_ids = ai_ids
end

function ClsAIActionSetTurnSpeed:__dealAction(target_id, speed)
	if not self.ai_ids then return false end

	local battle_data = getGameData():getBattleDataMt()
	local target_obj = battle_data:getShipByGenID(target_id)

	if not target_obj then return false end

	if self.target_obj.body and type(self.target_obj.body.setTurnSpeed) == "function" then
		self.target_obj.body:setTurnSpeed(speed)
	end
	
end

return ClsAIActionSetTurnSpeed