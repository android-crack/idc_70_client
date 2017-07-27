-- 震屏效果
-- Author: Ltian
-- Date: 2016-09-12 16:34:53
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionSceneShake = class("ClsAIActionSceneShake", ClsAIActionBase) 

function ClsAIActionSceneShake:getId()
	return "scene_shake"
end

function ClsAIActionSceneShake:initAction(offset, time)
	self.time = time
	self.offset = offset
end

function ClsAIActionSceneShake:__dealAction(target, delta_time)
    CameraFollow:SceneShake(self.time, self.offset)

    local battleRecording = require("gameobj/battle/battleRecording")
    battleRecording:recordVarArgs("battle_scene_shake", self.time, self.offset)
end

return ClsAIActionSceneShake
