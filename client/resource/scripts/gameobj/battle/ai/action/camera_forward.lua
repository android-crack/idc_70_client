-- 镜头绕Y轴旋转角度
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionCameraForward = class("ClsAIActionCameraForward", ClsAIActionBase)

function ClsAIActionCameraForward:getId()
	return "camera_forward"
end

function ClsAIActionCameraForward:initAction(distance, time)
	self.distance = distance
	self.time = time or 0
end

function ClsAIActionCameraForward:__dealAction(target_id, delta_time)
	if not self.distance then return false end

	local scene3D = BattleInit3D:getScene()
	if not scene3D then return end
	local cameraNode = scene3D:getActiveCamera():getNode()
	if not cameraNode then return end

	local battle_data = getGameData():getBattleDataMt()
	local target_obj = battle_data:getShipByGenID(target_id)

	if not target_obj or target_obj:is_deaded() then return end

	local target = target_obj.body.node

	if not target then return end

	local forward = target:getForwardVectorWorld():normalize()
	forward:scale(self.distance)

	CameraFollow:LockTarget(cameraNode)

	local position = target:getTranslationWorld()

	local keyCount = 2
	local keyTimes = {0, self.time}
	local keyValues = {position:x(), position:y(), position:z(), 
						position:x() + forward:x(), position:y() + forward:y(), position:z() + forward:z()}

	local last_anim = cameraNode:getAnimation("camMove")
	if last_anim then
		last_anim:stop()
	end

	local anim = cameraNode:createAnimation("camMove", Transform.ANIMATE_TRANSLATE(),
		keyCount, keyTimes, keyValues, "LINEAR")
	anim:play()
end

return ClsAIActionCameraForward
