local ClsBattleSetServer = class("ClsBattleSetServer", require("gameobj/battle/view/base"))

function ClsBattleSetServer:ctor()
end

function ClsBattleSetServer:InitArgs(uid)
	self.uid = uid
end

function ClsBattleSetServer:GetId()
    return "battle_set_server"
end

function ClsBattleSetServer:gotProtcol()
	local battle_data = getGameData():getBattleDataMt()

	local is_record = self.uid == battle_data:getCurClientUid()

	if battle_data:IsRecording() and is_record then return end

	battle_data:setLastRpcTime()

	battle_data:SetRecording(is_record)
	battle_data:SetPlaying(not is_record)
end

return ClsBattleSetServer
