local ClsBattleSetTime = class("ClsBattleSetTime", require("gameobj/battle/view/base"))

function ClsBattleSetTime:ctor()
end

function ClsBattleSetTime:InitArgs(time)
	self.time = time
end

function ClsBattleSetTime:GetId()
    return "battle_set_time"
end

function ClsBattleSetTime:Show()
	local battle_data = getGameData():getBattleDataMt()

	local battle_time = math.floor(self.time/1000 + 0.5)
	battle_data:SetData("battle_time", battle_time)
	getUIManager():get("FightUI"):Timer(battle_time)
end

return ClsBattleSetTime
