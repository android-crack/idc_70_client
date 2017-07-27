local ClsAddSceneEffect = class("ClsAddSceneEffect", require("gameobj/battle/view/base"))

function ClsAddSceneEffect:ctor(id, filename, dx, dy, time, angle)
    self:InitArgs(id, filename, dx, dy, time, angle)
end

function ClsAddSceneEffect:InitArgs(id, filename, dx, dy, time, angle)
    self.id = id
    self.filename = filename
    self.dx = dx
    self.dy = dy
    self.time = time
    self.angle = angle

    self.args = {id, filename, dx, dy, time, angle}
end

function ClsAddSceneEffect:GetId()
    return "add_scene_effect"
end

-- 播放
function ClsAddSceneEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	battle_data:addEffect(self.id, self.filename, self.dx, self.dy, self.time, self.angle)
end

return ClsAddSceneEffect
