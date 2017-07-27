local ClsBattleSceneShake = class("ClsBattleSceneShake", require("gameobj/battle/view/base"))

function ClsBattleSceneShake:ctor(time, range)
	self:InitArgs(time, range)
end

function ClsBattleSceneShake:InitArgs(time, range)
	self.time = time
	self.range = range

	self.args = {time, range}
end

function ClsBattleSceneShake:GetId()
    return "battle_scene_shake"
end

function ClsBattleSceneShake:Show()
	CameraFollow:SceneShake(self.time, self.range)
end

return ClsBattleSceneShake
