-- 
-- Author: Ltian
-- Date: 2016-07-27 10:22:45
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionAddStatus = class("ClsAIActionAddStatus", ClsAIActionBase) 

function ClsAIActionAddStatus:getId()
	return "add_status"
end

function ClsAIActionAddStatus:initAction(status_id)
	self.status_id = status_id
end

function ClsAIActionAddStatus:__dealAction(target_id, delta_time)
	if not self.status_id then return end
	local target = nil
	if target_id then
		local battle_data = getGameData():getBattleDataMt()
		target = battle_data:getShipByGenID(target_id)
	end
	local ai_obj = self:getOwnerAI()
	if not ai_obj then return end
	if not target then
		target = ai_obj:getOwner()
	end
	
	local status_map = require("game_config/buff/status_map")
	local clz = status_map[self.status_id]
	if clz then 
		local dTime = battle_config.battle_time
		local dHeartBreak = 0
		local objStatus = clz.new( target, target, dTime, dHeartBreak, nil, nil, 
			function(attacker, target, skillLv)
				local tbResult = {}
			 	return tbResult
			end)
		objStatus:add()
	end
end

return ClsAIActionAddStatus
