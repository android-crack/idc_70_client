

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionRotateScene = class("ClsAIActionRotateScene", ClsAIActionBase) 

function ClsAIActionRotateScene:getId( delay, angle, scale, target_id)
	return "rotate_scene"
end

-- delay:旋转持续时间,单位秒数
-- angle:旋转角度
function ClsAIActionRotateScene:initAction( delay, angle, scale, target_id )
	-- 记录毫秒数
	self.delay = delay * 1000
	-- 角度
	self.angle = angle
	-- 缩放
	self.scale = scale
	-- 绕谁旋转
	self.target_id = target_id

	self.duration = self.delay 
end

local function setVisibleUI(isVisible)
	local battleData = getGameData():getBattleDataMt()
	local battle_layer = battleData:GetLayer("battle_scene_layer")
	battle_layer:setTouchEnabled(isVisible)

	local ship_ui = battleData:GetLayer("ship_ui")
	ship_ui:setVisible(isVisible)

	local map_layer = battleData:GetLayer("map_layer")
	map_layer:setVisible(isVisible)

	local battle_area = battleData:GetLayer("battle_area")
	battle_area:setVisible(isVisible)

	-- local battleUi = battleData:GetLayer("battle_ui")
	-- battleUi:setVisible(isVisible)
end

function ClsAIActionRotateScene:__beginAction( target )
	print("ClsAIActionRotateScene:__beginAction")
	--
	local battleData = getGameData():getBattleDataMt()
	local battleLayer = battleData:GetTable("battle_layer")

	--battleLayer.setBattlePaused(true)
	CameraFollow:StopShake()
	
	setVisibleUI(false)
	
	CameraFollow:RetainLockTarget()

	local scene3D = BattleInit3D:getScene()
	local cameraNode = scene3D:getActiveCamera():getNode()
	local rotateAxis = WorldVector2Local(cameraNode, Vector3.new(0,1,0))

	self.cameraNode = cameraNode
	self.rotateAxis = rotateAxis

	CameraFollow:IgnoreBound(true)

	self.start_scale = CameraFollow:getScale()
	self.scale_per_ms = (self.scale -  self.start_scale )  / self.delay 
	print("ClsAIActionRotateScene:__dealAction:", self.scale_per_ms, self.scale, self.start_scale, self.delay)
	self.run_time = 0
end


function ClsAIActionRotateScene:__dealAction( target, delta_time )

	local battleData = getGameData():getBattleDataMt()
	local target_obj = battleData:getShipByGenID( self.target_id )
	
	if not target_obj or target_obj.isDeaded then return false end

	local rotateAxis = self.rotateAxis

	-- 每毫秒旋转焦距 
	local angle_per_ms = self.angle / self.delay

	local delta_angle = delta_time * angle_per_ms

	self.run_time = self.run_time + delta_time

	if ( math.abs(self.run_time * angle_per_ms) > math.abs(self.angle) ) then
		delta_angle = self.angle - ( self.run_time -  delta_time ) * angle_per_ms		
	end

	self.cameraNode:rotate(rotateAxis, math.rad(delta_angle))
	CameraFollow:ScaleByScreenPos( (self.start_scale + self.scale_per_ms * self.run_time), ccp(display.cx, display.cy))
	CameraFollow:SetFreeMove(target_obj.body.node:getTranslationWorld())
	return true
end

function ClsAIActionRotateScene:__endAction( target )
	print("ClsAIActionRotateScene:__endAction")
	CameraFollow:IgnoreBound(false)
	--battleLayer.setBattlePaused(false)
	CameraFollow:ResetLockTarget()

	self.cameraNode = nil 
	self.rotateAxis = nil 
end

return ClsAIActionRotateScene

