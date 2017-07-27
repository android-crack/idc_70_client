local battleLayer = require("gameobj/battle/battleLayer")

local ClsStateClientAllReady = class("ClsStateClientAllReady", require("gameobj/battle/view/base"))

function ClsStateClientAllReady:ctor()
end

function ClsStateClientAllReady:InitArgs(time)
	self.time = time
end

function ClsStateClientAllReady:GetId()
    return "state_client_all_ready"
end

-- 播放
function ClsStateClientAllReady:Show()
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:GetBattleSwitch() then return end

	local time = math.floor(self.time/1000 + 0.5)

	battle_data:SetData("battle_time", time)

	local ui = getUIManager():get("FightUI")
	if not tolua.isnull(ui) then
		ui:Timer(time)
	end

	if battle_data:isAlreadyLoad() then
		require("gameobj/ClsbattleLoadingUI"):remove()
	end

	local ships = battle_data:GetShips()
	for k, v in pairs(ships) do
		if battle_data:isUpdateShip(v:getId()) then
			v:tryOpportunity(AI_OPPORTUNITY.BEFORE_FIGHT_START)
		end
	end

	battleLayer.StartBattle()
end

return ClsStateClientAllReady