local shipEffectLayer = require("gameobj/battle/shipEffectLayer")

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionHideShipUI = class("ClsAIActionHideShipUI", ClsAIActionBase) 

function ClsAIActionHideShipUI:getId()
	return "hide_ship_ui"
end

function ClsAIActionHideShipUI:initAction()
end

function ClsAIActionHideShipUI:__dealAction(target_id, delta_time)
	shipEffectLayer.hideShipUI() 

	local battle_data = getGameData():getBattleDataMt()
	battle_data:setShowShipUI(false)

	local cur_ship = battle_data:getCurClientControlShip()
	local target = cur_ship:getTarget()
	if target and not target:is_deaded() then
		target:getBody():hideGuanquan()
	end
end

return ClsAIActionHideShipUI
