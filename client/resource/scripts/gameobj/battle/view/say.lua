local ClsSay = class("ClsSay", require("gameobj/battle/view/base"))

function ClsSay:ctor(shipId, name ,word)
    self:InitArgs(shipId, name, word)
end

function ClsSay:InitArgs(shipId, name, word)
    self.shipId = shipId
    self.name = name 
    self.word = word 

    self.args = {shipId, name, word}
end

function ClsSay:GetId()
    return "say"
end

function ClsSay:gotProtcol()
    local battle_data = getGameData():getBattleDataMt()
    local shipObj = battle_data:getShipByGenID(self.shipId) 
    if shipObj then
    	shipObj:say(self.name, self.word, true)
    end
    
end

return ClsSay
