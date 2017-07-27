local ClsDelSceneEffect = class("ClsDelSceneEffect", require("gameobj/battle/view/base"))

function ClsDelSceneEffect:ctor(id)
    self:InitArgs(id)
end

function ClsDelSceneEffect:InitArgs(id)
    self.id = id

    self.args = {id}
end

function ClsDelSceneEffect:GetId()
    return "del_scene_effect"
end

-- 播放
function ClsDelSceneEffect:Show()
	local battle_data = getGameData():getBattleDataMt()
	battle_data:delEffect(self.id)
end

return ClsDelSceneEffect