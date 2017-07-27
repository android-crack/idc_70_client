-- 3d 相关常用接口
local lookAtPointTimer = {}
local lookAtPointTimerCount = 0

MATERIAL_PARAM_TYPE = 
{
	NONE = 0,
	FLOAT = 1,
	FLOAT_ARRAY = 2,
	INT = 3,
	INT_ARRAY = 4,
	VECTOR2  = 5,
	VECTOR3 = 6,
	VECTOR4 = 7,
	MATRIX = 8,
	SAMPLER = 9,
	SAMPLER_ARRAY = 10,
	METHOD = 11,
} 
function IsPointAtRight(node, point)
	local rightVector = node:getRightVectorWorld()
	local boat_pos = node:getTranslationWorld()
	local point_dir = Vector3.new()
	Vector3.subtract(point, boat_pos, point_dir)
	local result = Vector3.dot(rightVector, point_dir)
	return result > 0
end

function IsVectorAtRight(node, vector)
	local rightVector = node:getRightVectorWorld()
	local result = Vector3.dot(rightVector, vector)
	return result > 0
end

function IsPointAtForward(node, point)
	local forwardVector = node:getForwardVectorWorld()
	local boat_pos = node:getTranslationWorld()
	local point_dir = Vector3.new()
	Vector3.subtract(point, boat_pos, point_dir)
	local result = Vector3.dot(forwardVector, point_dir)
	return result > 0
end

function IsVectorHorizontal(vector1, vector2)
	local result = Vector3.dot(vector1:normalize(), vector2:normalize())
	return result >= 0.999
end 

function GetAngleBetweenNodeAndPoint(node, pos)
	if not node or not pos then return 0 end

	local boat_pos = node:getTranslationWorld()
	local forward = node:getForwardVectorWorld()
	
	local dir = Vector3.new()
	Vector3.subtract(pos, boat_pos, dir)
	
	local angle = math.deg(Vector3.angle(dir, forward))

	if not IsPointAtRight(node, pos) then
		angle = - angle
	end

	return angle
end

function GetVectorBetween(node1, node2, isNormalize)	
	local pos1 = node1:getTranslation()
	local pos2 = node2:getTranslation()
	local vec = Vector3.new()
	Vector3.subtract(pos1, pos2, vec)
	if isNormalize then
		vec:normalize()
	end
	return vec
end

function LookAtPoint(node, point)
	local translate = node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(point, translate, dir)
	LookForward(node, dir)
end

function LookForward(node, dir)
	local forward = node:getForwardVectorWorld()
	local result = Vector3.dot(forward:normalize(), dir:normalize())
	local rotate_angle = Vector3.angle(forward, dir) 
	
	-- 平行 ，旋转轴为Y
	if math.abs(result) > 0.999 then 
		if IsVectorAtRight(node, dir) then 
			node:rotateY(-rotate_angle)
		else 
			node:rotateY(rotate_angle)
		end 
	else 
		local rotateAxis = Vector3.new() 
		Vector3.cross(forward, dir, rotateAxis)
		node:rotate(WorldVector2Local(node, rotateAxis), rotate_angle)
	end 
	
end

function StopLookAtPointAnimation(node)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if lookAtPointTimer[lookAtPointTimerCount] then
		scheduler:unscheduleScriptEntry(lookAtPointTimer[lookAtPointTimerCount])
		lookAtPointTimer[lookAtPointTimerCount] = nil
		lookAtPointTimerCount = lookAtPointTimerCount - 1
	end
end

function LookAtPointAnimation(node, point, interval, dt)
	local translate = node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(point, translate, dir)
	LookForwardAnimation(node, dir, interval, dt)
end

-- 不能同时用于多个对象，如果想同时用于多个对象，请修改实现
function LookForwardAnimation(node, dir, interval, dt)
	local forward = node:getForwardVectorWorld()
	local rotate_angle = Vector3.angle(forward, dir) 
	local rotateAxis = Vector3.new() 
	Vector3.cross(forward, dir, rotateAxis)
	local axisVec = WorldVector2Local(node, rotateAxis)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	local rotatedAngle = 0
	local function animate(dt)
		local sub_angle = dt/interval*rotate_angle
		node:rotate(axisVec, sub_angle)	
		rotatedAngle = rotatedAngle + sub_angle
		if rotatedAngle >= rotate_angle and lookAtPointTimer[lookAtPointTimerCount]	then
			scheduler:unscheduleScriptEntry(lookAtPointTimer[lookAtPointTimerCount])
			lookAtPointTimer[lookAtPointTimerCount] = nil
			lookAtPointTimerCount = lookAtPointTimerCount - 1
		end
	end
	lookAtPointTimerCount = lookAtPointTimerCount+1
	lookAtPointTimer[lookAtPointTimerCount] = scheduler:scheduleScriptFunc(animate, dt, false) 	
end

function WorldVector2Local(node, worldVector)
	local world2LocalMatrix = Matrix.new()
	node:getWorldMatrix():invert(world2LocalMatrix)
	local localVector = Vector3.new()
	world2LocalMatrix:transformVector(worldVector, localVector)
	return localVector
end

function WorldPoint2Local(node, worldPoint)
	local world2LocalMatrix = Matrix.new()
	node:getWorldMatrix():invert(world2LocalMatrix)
	local localPoint = Vector3.new()
	world2LocalMatrix:transformPoint(worldPoint, localPoint)
	return localPoint
end

function LocalVector2World(node, localVector)
	local node_matrix = node:getWorldMatrix()
	node_matrix:transformPoint(localVector)
	return localVector
end

function LocalVector2Parent(node, localVector)
	local node_matrix = node:getMatrix()
	node_matrix:transformPoint(localVector)
	return localVector
end

-- 屏幕坐标转换,一律用COCOS坐标系
function ScreenToVector3(x, y, camera)
	local viewport = Game.getInstance():getViewport()
	x = viewport:width()  / display.width * x
	y = viewport:height() / display.height * y
	y = y + viewport:y()
	x = x + viewport:x()
	y = display.heightInPixels - y
	local ray = Ray.new()
	camera:pickRay(viewport, x, y, ray)
	local collisionDistance = ray:intersects(Plane.new(0, 1, 0, 0))
	if collisionDistance ~= Ray.INTERSECTS_NONE() then 	
		local target_pos = Vector3.new(ray:getOrigin())
		local dir = Vector3.new(ray:getDirection())
		dir:scale(collisionDistance)
		target_pos:add(dir)
		return target_pos
	end
	return nil
end 

--返回COCOS坐标系
function Vector3ToScreen(vec3, camera)
	local viewport = Game.getInstance():getViewport()
    local vec2 = Vector2.new()
    camera:project(viewport, vec3, vec2)
	local x = vec2:x()
	local y = vec2:y()
	y = display.heightInPixels - y
	x = x - viewport:x()
	y = y - viewport:y()
	x = display.width / viewport:width() * x	
	y = display.height / viewport:height() * y
	vec2:set(x, y)
    return vec2
end

-- 世界坐标转换
function cocosToGameplayWorld(pos)
	return CameraFollow:cocosToGameplayWorld(pos)
end

function gameplayToCocosWorld(pos)
	return CameraFollow:gameplayToCocosWorld(pos)
end 

function GetVectorDistance(v1, v2)
	local dv = Vector3.new()
	Vector3.subtract(v1, v2, dv)
	return dv:length()
end

function GetDistanceFor3D(node1, node2)
	if not node1 then return 999999 end
	if not node2 then return 999999 end
	local point1 = node1:getTranslationWorld()
	local point2 = node2:getTranslationWorld()
	return GetVectorDistance(point1, point2)
end

function GetTwoNodeVector(node1, node2)
	local point1 = node1:getTranslationWorld()
	local point2 = node2:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(point2, point1, dir)
	dir:normalize()
	return dir
end 

-- 向量旋转 angle 左负数
function RotateVector3(axis, angle, originVec3)
    local mat = Matrix.new()
    Matrix.createRotation(axis, math.rad(angle), mat)
    local rotateVec3 = Vector3.new()
    mat:transformVector(originVec3, rotateVec3)
    return rotateVec3
end 


-------------------------------------------------------
local tabel_3D = {}

function CreateScene3D()
	if tabel_3D.scene3D then return end 
	tabel_3D.scene3D = Scene.create()
	tabel_3D.rootNode = tabel_3D.scene3D:addNode("root3d")
	tabel_3D.rootNode:setLayer(0)
	CCPlatform3D:resume()
	return tabel_3D.scene3D
end 

function GetScene3D()
	return tabel_3D.scene3D
end 

function GetRootNode3D()
	return tabel_3D.rootNode
end 

function RemoveScene3D()
	CCPlatform3D:pause()
	tabel_3D.scene3D:removeAllNodes()
	tabel_3D = {}
	ResourceManager:ClearCache()
end 

function SetLayer3D(key, layer)
	tabel_3D[key] = layer
end 

function GetLayer3D(key)
	return tabel_3D[key]
end

-- 创建多个3D层
function CreateLayer3D()

end

--------------------------

function SetTranslucent(node, color, alpha)
	if not node then 
		cclog("SetTranslucent fail!")
		return
	end
	color = color or Vector3.one()
	alpha = alpha or 0
	local material = node:getModel():getFirstMaterial()
	material:getStateBlock():setBlend(true)
    material:getStateBlock():setBlendSrc("BLEND_SRC_ALPHA")
    material:getStateBlock():setBlendDst("BLEND_ONE_MINUS_SRC_ALPHA")
	local technique = material:getTechnique() 
	for i = 0, technique:getPassCount() - 1 do
        local pass = technique:getPassByIndex(i)
		pass:getParameter("u_mainColor"):setValue( Vector4.new(color:x(), color:y(), color:z(), alpha))	
	end
end


function GetShaderParam(node, param_name, type)
	local material
	if type == TYPE_SEA then 
		material = node:getSea():getMaterial()
	else
		material = node:getModel():getFirstMaterial() 
	end
	local param = material:getParameter(param_name)
	if param and param:getType() > 0 then 
		return param 
	end
end

function Model3DFadeOut(node, duration, alpha)
	local alpha = alpha or 0
	local param_handle = GetShaderParam(node, "u_mainColor")

	if param_handle then 
		local keyCount = 2
		local keyTimes = {0, duration*1000}
		local keyValues = {1, 1, 1, 1, 1, 1, 1, alpha}
		SetTranslucent(node, nil, 1)
		local anim = param_handle:createAnimation("alpha", MaterialParameter.ANIMATE_UNIFORM(),
				keyCount, keyTimes, keyValues, "LINEAR")

		anim:play()
	end 
end 

function Model3DFadeIn(node, duration, alpha)
	local alpha = alpha or 1
	local param_handle = GetShaderParam(node, "u_mainColor")

	if param_handle then 
		local keyCount = 2
		local keyTimes = {0, duration*1000}
		local keyValues = {1, 1, 1, 0, 1, 1, 1, alpha}
		SetTranslucent(node, nil, 0)
		local anim = param_handle:createAnimation("alpha", MaterialParameter.ANIMATE_UNIFORM(),
				keyCount, keyTimes, keyValues, "LINEAR")

		anim:play()
	end 
end 

function SetGameTimeScale(scale)
	Game.getInstance():setTimeScale(scale)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	scheduler:setTimeScale(scale)
end

function ResetGameTimeScale()
	Game.getInstance():setTimeScale(1)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	scheduler:setTimeScale(1)
end

function get3DSamplePath(basepath, node_name, samplername)
	local paths = {}
	
	local path = string.format("%s%s/%s.fbm/%s", basepath, node_name, node_name, samplername)
	paths[#paths + 1] = path
	
	local path = string.format("%s%s/%s", basepath, node_name, samplername)
	paths[#paths + 1] = path
	
	path = string.format("%s/%s",FLOW_TEXTURE_PATH, samplername)
	paths[#paths + 1] = path
	
	-- local path = string.format("%s%s", basepath, samplername)
	-- paths[#paths + 1] = path
		
	for _, v in ipairs(paths) do
		if FileSystem.fileExists(v) then
			return v
		end
	end
end