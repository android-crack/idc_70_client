local ClsSyncMoveTo = class("ClsSyncMoveTo", require("gameobj/battle/view/base"))

function ClsSyncMoveTo:ctor(id, path)
    self:InitArgs(id, path)
end

function ClsSyncMoveTo:InitArgs(id, path)
    self.id = id
    self.path = path

    self.args = {id, path}
end

function ClsSyncMoveTo:GetId()
    return "sync_move_to"
end

-- 播放
function ClsSyncMoveTo:Show()
	local battle_data = getGameData():getBattleDataMt()
    local ship = battle_data:getShipByGenID(self.id)

    if not ship or ship:is_deaded() then return end

    local OFFSET_DISTANCE = 50

    local pos = ship:getPosition3D()

    if not pos then return end

    x = self.path[1]/FIGHT_SCALE
    y = self.path[2]/FIGHT_SCALE

    local body = ship:getBody()

    -- if not ship:hasBuff("tuji_self") and not ship:hasBuff("chaofeng") and
    --     math.abs(pos:x() - x) > OFFSET_DISTANCE or math.abs(pos:z() - y) > OFFSET_DISTANCE then

    --     body.node:setTranslation(Vector3.new(x, 0, y))
    --     body:updateUI()
    -- end

    local index = 3
    local tmp_table = {}
    while true do
        if index > #self.path then break end

        tmp_table[#tmp_table + 1] = Vector3.new(self.path[index]/FIGHT_SCALE, 0, self.path[index + 1]/FIGHT_SCALE)

        index = index + 2
    end

    body:moveToByPath(tmp_table, FV_MOVE_SERVER)
end

return ClsSyncMoveTo
