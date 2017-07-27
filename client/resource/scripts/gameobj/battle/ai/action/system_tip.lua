local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionSystemTip = class("ClsAIActionSystemTip", ClsAIActionBase) 

function ClsAIActionSystemTip:getId()
	return "system_tip"
end

function ClsAIActionSystemTip:initAction(txt)
	self.txt = txt
end

function ClsAIActionSystemTip:__dealAction(target_id, delta_time)
	local battle_data = getGameData():getBattleDataMt()

	local target_obj = battle_data:getShipByGenID(target_id)
	if not target_obj then return false end
	
	if target_obj:getUid() == battle_data:getCurClientUid() then
		local alert = require("ui/tools/alert")
		alert:battleWarning({msg = self.txt})
	end
end

return ClsAIActionSystemTip
