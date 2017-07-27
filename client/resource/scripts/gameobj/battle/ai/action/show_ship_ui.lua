local shipEffectLayer = require("gameobj/battle/shipEffectLayer")

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionShowShipUI = class("ClsAIActionShowShipUI", ClsAIActionBase) 

function ClsAIActionShowShipUI:getId()
	return "show_ship_ui"
end

function ClsAIActionShowShipUI:initAction()
end

function ClsAIActionShowShipUI:__dealAction(target_id, delta_time)
	shipEffectLayer.showShipUI() 

	local battle_data = getGameData():getBattleDataMt()
	battle_data:setShowShipUI(true)

	local cur_ship = battle_data:getCurClientControlShip()
	local target = cur_ship:getTarget()
	if target and not target:is_deaded() then
		target:getBody():showGuanquan()
	end
end

return ClsAIActionShowShipUI
