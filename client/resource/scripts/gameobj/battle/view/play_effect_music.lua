local ClsPlayEffectMusci = class("ClsPlayEffectMusci", require("gameobj/battle/view/base"))

function ClsPlayEffectMusci:ctor(res, id, uid)
    self:InitArgs(res, id, uid)
end

function ClsPlayEffectMusci:InitArgs(res, id, uid)
    self.res = res
    self.id = id
    self.uid = uid

    self.args = {res, id, uid}
end

function ClsPlayEffectMusci:GetId()
    return "play_effect_music"
end

-- 播放
function ClsPlayEffectMusci:Show()
    local battle_data = getGameData():getBattleDataMt()

    local ship = battle_data:getShipByGenID(self.id)
    if ship and not ship:is_deaded() and ship:getBody() and 
        ship:getBody():getNode() and ship:getBody():getNode():isInFrustum() then

        local is_player = battle_data:isCurClientControlShip(id)
        audioExt.playEffect(self.res, false, is_player)
    end
end

function ClsPlayEffectMusci:serialize(frame)
    return json.encode({frame, self.res, self.id, self.uid})  
end

function ClsPlayEffectMusci:unserialize(str)
    local frame, res, id, uid = unpack(json.decode(str))
    self:InitArgs(res, id, uid)
    return self.args
end

return ClsPlayEffectMusci
