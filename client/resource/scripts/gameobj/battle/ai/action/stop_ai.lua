
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionStopAI = class("ClsAIActionStopAI", ClsAIActionBase) 

function ClsAIActionStopAI:getId()
	return "delete_ai"
end

-- 
function ClsAIActionStopAI:initAction( ai_ids )
	self.ai_ids = ai_ids;						-- AIID
end

function ClsAIActionStopAI:__dealAction( target_id, delta_time )

	if self.ai_ids == nil then return false end

	local battleData = getGameData():getBattleDataMt()
	local target_obj = battleData:getShipByGenID(target_id)

	if (target_id == -1) then
		target_obj =  getGameData():getAutoTradeAIHandler()
	end

	if ( not target_obj ) then return false end

	-- 停止
	for _, ai_id in pairs(self.ai_ids) do
		local target_ai_obj = target_obj.running_ai[ai_id] 
		
		if target_ai_obj then 
			target_obj:completeAI( target_ai_obj )
		end
	end

	--if target_obj:getId() == 1 then
	--	for ai_id, target_ai_obj in pairs(target_obj.new_ai) do
	--		print("tryRun: stop left ai:", ai_id)
	--	end
	--end

	return true
end

return ClsAIActionStopAI
