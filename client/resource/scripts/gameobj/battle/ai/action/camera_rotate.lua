-- 镜头绕Y轴旋转角度
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionCameraRotate = class("ClsAIActionCameraRotate", ClsAIActionBase)

function ClsAIActionCameraRotate:getId()
	return "camera_rotate"
end

function ClsAIActionCameraRotate:initAction(angle, time)
	self.angle = angle
	self.time = time or 0
end

function ClsAIActionCameraRotate:rotateCamera(angle)
	local scene3D = BattleInit3D:getScene()
	if not scene3D then return end
	local cameraNode = scene3D:getActiveCamera():getNode()
	if not cameraNode then return end
	local rotateAxis = WorldVector2Local(cameraNode, Vector3.new(0,1,0))
	if not rotateAxis then return end

	cameraNode:rotate(rotateAxis, math.rad(angle))
end

function ClsAIActionCameraRotate:__dealAction(target_id, delta_time)
	if not self.angle then return false end

	if self.time == 0 then
		self:rotateCamera(self.angle)
		return
	end

	local delta_angle = self.angle/self.time

	local function rotateCamera(dt)
		local delta_time = dt*1000
		self.heart_time = (self.heart_time or 0) + delta_time
		if self.heart_time >= self.time then
			delta_time = delta_time - (self.heart_time - self.time)

			local battle_data = getGameData():getBattleDataMt()
			battle_data:StopScheduler("rotateCamera")
		end
		self:rotateCamera(delta_angle*delta_time)
	end

	local battle_data = getGameData():getBattleDataMt()
	battle_data:SetScheduler("rotateCamera", rotateCamera, 0, false)
end

return ClsAIActionCameraRotate
