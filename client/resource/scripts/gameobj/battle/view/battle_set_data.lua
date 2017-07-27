local ClsBattleSetData = class("ClsBattleSetData", require("gameobj/battle/view/base"))

-- data目前为int数据
function ClsBattleSetData:ctor(name, data)
	self:InitArgs(name, data)
end

function ClsBattleSetData:InitArgs(name, data)
	self.name = name
	self.data = data

	self.args = {name, data}
end

function ClsBattleSetData:GetId()
    return "battle_set_data"
end

function ClsBattleSetData:Show()
	local battle_data = getGameData():getBattleDataMt()
	battle_data:SetData(self.name, self.data)
end

return ClsBattleSetData
