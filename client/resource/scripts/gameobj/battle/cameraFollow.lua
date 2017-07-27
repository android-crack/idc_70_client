-- 镜头相关

-- 摄像机角度
COCOS_SCREEN_WIDTH = display.cx
COCOS_SCREEN_HEIGHT = display.cy
CAMERA_ANGLE = -30 
UNIT_TO_PIXEL_RATE = 480 / display.cx
CameraFollow = {}

SCENE_RATE = 1/math.sin(math.rad(math.abs(CAMERA_ANGLE)))

RATE_PER_PIXEL = SCENE_RATE * UNIT_TO_PIXEL_RATE

local scheduler = CCDirector:sharedDirector():getScheduler()
function CameraFollow:getSceneRate()
	return SCENE_RATE
end 

function CameraFollow:GetSceneBound()
	local pixel2dX = self.cocosLayerWidth
	local pixel2dY = self.cocosLayerHeight 
	return pixel2dX * UNIT_TO_PIXEL_RATE, pixel2dY * RATE_PER_PIXEL
end

function CameraFollow:cocosToGameplayWorld(pos)
	local x = pos.x
	local y = 0
	local z = - pos.y * RATE_PER_PIXEL
	return Vector3.new(x,y,z)
end

function CameraFollow:gameplayToCocosWorld(pos)
	local x = pos:x()
	local y = - pos:z() / RATE_PER_PIXEL
	return ccp(x,y)
end

function CameraFollow:init(scene_id, cocosLayer, cocosLayerWidth, cocosLayerHeight)
	self.scene_id = scene_id 
	self.scale = 1
	self.cameraBound3d = {}
	self.cameraBound2d = {}
    self.camera_node = nil
	self.freeMoveCenter = nil
	self.lockTarget = nil
	self.lastTarget = nil 
	self.customBound = false
	self.isIgnoreBound = false
	self.cocosLayer = cocosLayer
	self.cocosLayerWidth = cocosLayerWidth
	self.cocosLayerHeight = cocosLayerHeight
	self.extandSize = 256
	self.rotation_angle = 0

	self.shake_switch = true

	self:InitCamera()
	CameraFollow:Reset3dCamera()
end 

function CameraFollow:Reset3dCamera()
	if self.customBound then
		local bound = self.cameraBound3d
		CameraFollow:SetCameraBound(bound.left, bound.right, bound.bottom, bound.top)
	else	
        CameraFollow:CalcCameraBoundExtand(self.extandSize)
	end
	local pos = self.camera_node:getTranslationWorld()
	CameraFollow:Set3dCameraPosition( pos )
end

function CameraFollow:DelCocosLayer()
	self.cocosLayer = nil

	self:Reset3dCamera()
end

function CameraFollow:Set3dCameraPosition(pos)
	local bound3d = self.cameraBound3d
	local z = pos:z()
	local x = pos:x()
	if not self.isIgnoreBound then 
		z = Math.clamp(bound3d.top, bound3d.bottom, z)
		x = Math.clamp(bound3d.left, bound3d.right, x)
	end 
	self.camera_node:setTranslationX(x) 
	self.camera_node:setTranslationZ(z)
end

function CameraFollow:CalcCameraBoundExtand(_size)
    local size = _size or 0
	local pixel2dX = self.cocosLayerWidth + size
	local pixel2dY = self.cocosLayerHeight + size
	local sceneRate = CameraFollow:getSceneRate()

	local camera3d = self.camera_node:getCamera()
	local camera3dZoomX = camera3d:getZoomX() / 2
	local camera3dZoomY = camera3d:getZoomY() / 2
	local left = camera3dZoomX * UNIT_TO_PIXEL_RATE - size * UNIT_TO_PIXEL_RATE
	local right = pixel2dX * UNIT_TO_PIXEL_RATE - camera3dZoomX
	local top = -( pixel2dY * UNIT_TO_PIXEL_RATE - camera3dZoomY ) * sceneRate
	local bottom = (-camera3dZoomY  + size)* sceneRate 
	if left > right then 
		left = pixel2dX * UNIT_TO_PIXEL_RATE / 2
		right = left
	end
	if top > bottom then
		top = -pixel2dY * UNIT_TO_PIXEL_RATE * sceneRate / 2
		bottom = top
	end
	self.cameraBound3d = {
		left = left,
		right = right,
		top = top,
		bottom = bottom
	}
   
    
	left = -size  * self.scale
	right = pixel2dX * self.scale - COCOS_SCREEN_WIDTH * 2
	bottom =  -size  * self.scale
	top = pixel2dY  * self.scale - COCOS_SCREEN_HEIGHT * 2
    

	if left > right then 
		right = left
	end
	if bottom > top then
		top = bottom	
	end

	self.cameraBound2d = {
		left = left,
		right = right,
		bottom = bottom,
		top = top
	}
	self.customBound = false
end

function CameraFollow:AddCameraBound(dLeft, dRight, dBottom, dTop)
	local bound = self.cameraBound3d
	local leftBound3d = bound.left + dLeft 
	local rightBound3d = bound.right + dRight 
	local bottomBound3d = bound.bottom + dBottom 
	local topBound3d = bound.top + dTop 
	CameraFollow:SetCameraBound(leftBound3d, rightBound3d, bottomBound3d, topBound3d)
end 

function CameraFollow:SetCameraBound(leftBound3d, rightBound3d, bottomBound3d, topBound3d)
	assert(leftBound3d < rightBound3d, "scene bound error")
	assert(bottomBound3d > topBound3d, "scene bound error")

	self.cameraBound3d = {
		left = leftBound3d,
		right = rightBound3d,
		top = topBound3d,
		bottom = bottomBound3d
	}

	local sceneRate = CameraFollow:getSceneRate()
	local left = leftBound3d / UNIT_TO_PIXEL_RATE * self.scale
	local right = rightBound3d / UNIT_TO_PIXEL_RATE  * self.scale - COCOS_SCREEN_WIDTH * 2
	local bottom = -bottomBound3d / UNIT_TO_PIXEL_RATE * self.scale / sceneRate
	local top = -topBound3d / UNIT_TO_PIXEL_RATE * self.scale / sceneRate - COCOS_SCREEN_HEIGHT * 2
	if left > right then 
		right = left
	end
	if bottom > top then
		top = bottom	
	end

	self.cameraBound2d = {
		left = left,
		right = right,
		bottom = bottom,
		top = top
	}	
	self.customBound = true
end

function CameraFollow:InitCamera()
	local pixel2dX = self.cocosLayerWidth
	local pixel2dY = self.cocosLayerHeight
	
	local screenWidthCount = pixel2dX / (COCOS_SCREEN_WIDTH*2)
	local scene3dWidth = pixel2dX * UNIT_TO_PIXEL_RATE
	local cameraWidthZoom = scene3dWidth / screenWidthCount
	local cameraHeightZoom = cameraWidthZoom * COCOS_SCREEN_HEIGHT / COCOS_SCREEN_WIDTH
	local cam = Camera.createOrthographic(cameraWidthZoom, cameraHeightZoom, COCOS_SCREEN_WIDTH/COCOS_SCREEN_HEIGHT, 0, 5000)
	local scene3D = require("game3d"):getScene(self.scene_id)
	local camNode = scene3D:addNode("camera")
    camNode:setCamera(cam)
    scene3D:setActiveCamera(cam)
    self.camera_node = scene3D:getActiveCamera():getNode()
	self.camera_node:rotateX(math.rad(CAMERA_ANGLE))
end

function CameraFollow:Release3dCamera()
	local scene3D = require("game3d"):getScene(self.scene_id)
	scene3D:setActiveCamera(nil)
	scene3D:removeNode(self.camera_node)
	self.camera_node = nil
	self.freeMoveCenter = nil
	self.lockTarget = nil
	self.lastTarget = nil 
	if CameraFollow.scaleTimer then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(CameraFollow.scaleTimer)
		CameraFollow.scaleTimer = nil
	end	
	if self.shake_hander_time then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.shake_hander_time)
		self.shake_hander_time = nil
	end
end

function CameraFollow:GetMinScale()
	local pixel2dX = self.cocosLayerWidth
	local pixel2dY = self.cocosLayerHeight
	local minScaleX = COCOS_SCREEN_WIDTH / pixel2dX
	local minScaleY = COCOS_SCREEN_HEIGHT / pixel2dY
	if minScaleX > minScaleY then 
		return minScaleX 
	else
		return minScaleY
	end
end

function CameraFollow:update(ship)
	if tolua.isnull(self.cocosLayer) then 
		return 
	end
	local vec1 = nil 
	if self.freeMoveCenter ~= nil then 
		vec1 = self.freeMoveCenter
	elseif self.lockTarget ~= nil then
		vec1 = self.lockTarget:getTranslationWorld()
	elseif ship.node then
		vec1 = ship.node:getTranslationWorld()
	else 
		return 
	end
	
	local bound3d = self.cameraBound3d
	
	local height = vec1:z()
	local width = vec1:x()
	if not self.isIgnoreBound then 
		height = Math.clamp(bound3d.top, bound3d.bottom, height)
		width = Math.clamp(bound3d.left, bound3d.right, width)
	end 
	
	self.camera_node:setTranslationX(width) 
	self.camera_node:setTranslationZ(height)
	
	local bound2d = self.cameraBound2d
	local cocoPos = CameraFollow:gameplayToCocosWorld(vec1)

	local cocoWorldPos = self.cocosLayer:convertToWorldSpace(cocoPos)
	local cameraX = cocoWorldPos.x - COCOS_SCREEN_WIDTH
	local cameraY = cocoWorldPos.y - COCOS_SCREEN_HEIGHT
	if not self.isIgnoreBound then 
		cameraX = Math.clamp(bound2d.left, bound2d.right, cameraX)
		cameraY = Math.clamp(bound2d.bottom, bound2d.top, cameraY)
	end 
	local cameraPos = self.cocosLayer:convertToNodeSpace(ccp(cameraX,cameraY))
	local cam = self.cocosLayer:getCamera()
	local x, y, z = cam:getEyeXYZ(0,0,0)
	cam:setEyeXYZ(cameraPos.x, cameraPos.y, z)
	local cx, cy, cz = cam:getCenterXYZ(0,0,0)
	cam:setCenterXYZ(cameraPos.x, cameraPos.y, cz)	
end

--[[
--缩放之后，两个相机平铺到场景里的个数应该要一致，才不会出现不对齐的情况
--]]
function CameraFollow:Scale(val)
	if not self or tolua.isnull(self.cocosLayer) then return end
	if val == nil then return end 
	local minScale =  CameraFollow:GetMinScale()
	if val < minScale then val = minScale end
	self.cocosLayer:setScale(val)

	local pixel2dX = self.cocosLayerWidth
	local pixel2dY = self.cocosLayerHeight
	local screenWidthCount = pixel2dX * val / (COCOS_SCREEN_WIDTH * 2)
	local scene3dWidth = pixel2dX * UNIT_TO_PIXEL_RATE
	local xZoom = scene3dWidth / screenWidthCount
	local camera = self.camera_node:getCamera()
	local yZoom = xZoom * COCOS_SCREEN_HEIGHT / COCOS_SCREEN_WIDTH
	camera:setZoomX(xZoom)
	camera:setZoomY(yZoom)
	self.scale = val
end

function CameraFollow:ScaleAnimation(scaleBegin, scaleEnd, duration, callback)
	local tick = 0
	local interval = (scaleEnd - scaleBegin)
	local function scaleFunc(dt)
		tick = tick + dt
		local scale = scaleBegin + tick/duration*interval
		if math.abs(tick/duration*interval) > math.abs(interval) then
			scale = scaleEnd
			if CameraFollow.scaleTimer then
				local scheduler = CCDirector:sharedDirector():getScheduler()
				scheduler:unscheduleScriptEntry(CameraFollow.scaleTimer)
				CameraFollow.scaleTimer = nil
				if callback then
					callback()
				end
			end
			
		end
		CameraFollow:Scale(scale)
	end
	local scheduler = CCDirector:sharedDirector():getScheduler()
	CameraFollow.scaleTimer = scheduler:scheduleScriptFunc(scaleFunc, 0, false)
end

function CameraFollow:getScale()
	return self.scale
end 

function CameraFollow:IgnoreBound(isIgnore)
	self.isIgnoreBound = isIgnore
end 

function CameraFollow:ScaleByScreenPos(val, pos)
	local cameraNode = self.camera_node
	if not cameraNode or not cameraNode:getCamera() then return end
	local oldPoint = ScreenToVector3(pos.x, pos.y, cameraNode:getCamera())
	CameraFollow:Scale(val)
	local newPoint = ScreenToVector3(pos.x, pos.y, cameraNode:getCamera())
	local cameraPos = cameraNode:getTranslation()
	--local newCameraPos = Vector3.new()
	local moveVector = Vector3.new()
	Vector3.subtract(newPoint, oldPoint, moveVector)
	Vector3.subtract(cameraPos, moveVector, cameraPos)
	cameraNode:setTranslation(cameraPos)
	CameraFollow:Reset3dCamera()

	local screenCenterX = COCOS_SCREEN_WIDTH
	local screenCenterY = COCOS_SCREEN_HEIGHT
	local screenCenter = ScreenToVector3(screenCenterX, screenCenterY, cameraNode:getCamera())

	CameraFollow:SetFreeMove(screenCenter)
end

function CameraFollow:SetFreeMove(centerPos, is_shake)
	if not is_shake and self.lock_lock_target then return end
	self.freeMoveCenter = centerPos
	self.lockTarget = nil
end

function CameraFollow:LockTarget(node)
	if self.lock_lock_target then return end
	self.freeMoveCenter = nil
	self.lockTarget = node
end

function CameraFollow:getLockTarget()
	return self.lockTarget
end

function CameraFollow:setLockLockTarget(time)
	self.lock_lock_target = true
	self.timer = scheduler:scheduleScriptFunc(function ()
		self:cancelLockLockTarget()
	end, time, false)
end

function CameraFollow:cancelLockLockTarget()
	self.lock_lock_target = false
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

function CameraFollow:GetLastTarget()
	return self.lastTarget
end 

function CameraFollow:RetainLockTarget(target)
	self.lastTarget = target or self.lockTarget
end 

function CameraFollow:ResetLockTarget()
	if self.lastTarget then 
		CameraFollow:LockTarget(self.lastTarget)
	elseif self.freeMoveCenter == nil then 
		CameraFollow:ResetCenter()
	end 
end 

function CameraFollow:getSceneScale()
	return BATTLE_SCALE_RATE or 1
end

function CameraFollow:ResetCenter()
	self.freeMoveCenter = nil
	self.lockTarget = nil
	self.lastTarget = nil 
    CameraFollow:CalcCameraBoundExtand(self.extandSize)
	CameraFollow:Scale(1*self:getSceneScale())
	CameraFollow:Reset3dCamera()
end

-- 震屏效果
function CameraFollow:SceneShake(times, range, isNotDec)
	if not self.shake_switch then return end
	if self.isIgnoreBound and BattleInit3D.is_start then return end 
	if self.is_shaking_scene then return end
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.shake_hander_time then
		scheduler:unscheduleScriptEntry(self.shake_hander_time)
		self.shake_hander_time = nil
		CameraFollow:ResetLockTarget()
	end
	
	CameraFollow:RetainLockTarget()
	
	--local cam_pos = Vector3.new(self.camera_node:getTranslationWorld())
	local cam_pos = self.camera_node:getTranslationWorld()
	local count = 0
	local shake_num = times or 8
	local shake_range = range or 8
	local function step(dt)
		count = count + 1
		if count > shake_num then	
			if self.shake_hander_time then
				scheduler:unscheduleScriptEntry(self.shake_hander_time)
				self.shake_hander_time = nil
				self.is_shaking_scene = false
                CameraFollow:ResetLockTarget()
			end
			return 
		end 
		if not isNotDec then
			shake_range = shake_range - 1
		end

		if shake_range < 1 then shake_range = 1 end 
		local _range = (-1)^count*shake_range
		local tran = Vector3.new(cam_pos:x() + _range, cam_pos:y(), cam_pos:z() + _range*-2)
		CameraFollow:SetFreeMove(tran, true)
	end
	self.shake_hander_time = scheduler:scheduleScriptFunc(step, 0.05, false)
	self.is_shaking_scene = true
end 

function CameraFollow:StopShake()	
	if self.shake_hander_time then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.shake_hander_time)
		self.shake_hander_time = nil
		CameraFollow:ResetLockTarget()
		------------------------------------------------------
		-- modify By Hal 2015-08-28, Type(BUG) - redmine 19143
		self.is_shaking_scene = false
		------------------------------------------------------
	end
end 

function CameraFollow:setShakeSwitch(value)
	self.shake_switch = value
end
