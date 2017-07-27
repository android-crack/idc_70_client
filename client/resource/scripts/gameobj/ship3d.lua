require("resource_manager")
require("gameobj/battle/globalDef")
require("gameobj/battle/cameraFollow")

local sceneEffect = require("gameobj/battle/sceneEffect")
local AttackDirRange = require("gameobj/battle/AttackDirRange")
local battleRecording = require("gameobj/battle/battleRecording")
local sceneEffect = require("gameobj/battle/sceneEffect")
local boat_info = require("game_config/boat/boat_info")

local GUANG_QUAN_NAME = "guangquan"

ShipDirToRota = {
	[0] = 0,
	[1] = 0,
	[2] = 45,
	[3] = 90,
	[4] = 135,
	[5] = 180,
	[6] = 225,
	[7] = 270,
	[8] = 315,
}

local SHIP_ROTATE_DT_COUNT = FRAME_CNT_PER_SEC

local fireRes_pos = 
{
	["smallShip"] = {0, 15, 0},
	["middleShip"] = {0, 25, 0},
	["bigShip"] = {0, 50, 0},
}

local ClsModel3D = require("gameobj/model3d")
local Boat = class("Boat", ClsModel3D)

-- gen_id 和 ship_id 不同, gen_id 唯一索引
function Boat:ctor(param)
	self.gen_id = param.gen_id or 0
	self.id = tonumber(param.id)
	self.speed = param.speed
	self.ship_ui = param.ship_ui
	self.dialog_node = param.dialog_node
	self.kind = param.kind or "smallShip"
	self.turn_speed = param.turn_speed
	self.pos = param.pos
	self.is_oar = param.is_oar
	self.star_level = param.star_level
	self.parent = param.parent
	self.speed_rate = 1
	self.is_ship = true 
	self.pathIndex = 0
	self.turn_type = 0  -- -1, 0 , 1 左转， 不转 ， 右转
	self.is_ban_rotate = false
	self.rotate_angle = 0
	self.target_pos = Vector3.new()
	self.is_pause = false 
	self.isBroken = false
	self.ani_post_fix = ""
	self.cur_ani_name = ""
	--TODO：remove
	self.eff_model = {} --记录挂在船上的特效模型，由于船舶死亡后移除这些模型
	self.show_attack_range = false
	self.range_depth = 3
	self.near_state = false
	self.cur_near_state = false
	if self.kind == "smallShip" then
		self.near_dist = battle_config.near_dist_min
	elseif self.kind == "middleShip" then
		self.near_dist = battle_config.near_dist_mid
	else
		self.near_dist = battle_config.near_dist_max
	end

	local tmp_id = boat_info[self.id].res_3d_id

	self.node_name = string.format("boat%.2d", tmp_id)
	self.path = SHIP_3D_PATH
	
	self.unbroken_tex_res = string.format("%s%s/%s.fbm/%s_%0.3d.png", self.path, self.node_name, self.node_name, self.node_name, 1)
	self.broken_tex_res = string.format("%s%s/%s.fbm/%s_%0.3d.png", self.path, self.node_name, self.node_name, self.node_name, 2)
	
	Boat.super.ctor(self, self)
	
	self.node:setId(tostring(self.gen_id))
	self.node:setTag("node_name", self.node_name)
	self.shootNode = self.node:findNode("center", true)
	
	self.animation = self.node:getAnimation("animations")
	if self.animation then 
		self.curAni = self.animation:getClip(ani_name_t.move)
		if self.curAni then 
			self.curAni:play()
		end
	end
	self:initUI()
	
	self:setPos(self.pos.x, self.pos.y)
	if self.pos.rota then 
		self:setAngle(ShipDirToRota[self.pos.rota])
	end

	self:initEffect(tmp_id)
	self:initCollision()
end

function Boat:getNode()
	return self.node
end

function Boat:getNodeName()
	return self.node_name
end

function Boat:getIsShip()
	return self.is_ship
end

function Boat:getShipTurnSpeed()
    return self.turn_speed
end

function Boat:setShipTurnSpeed(turnSpeed)
    assert(type(turnSpeed)=="number")

    self.turn_speed = turnSpeed
end

function Boat:showConfigAnimation()
	local animationData = require("game_config/u3dAnimationData/zhaozinew")
	local Animation = require("module/u3dAnimationParse")
	Animation:parse(self, animationData)
end

function Boat:initTexture()
	if self.unbroken_tex_res then
		self:changeTexture(self.unbroken_tex_res)
	end
end

-- 获取船只的特效
function Boat:getEffectControl()
	return self.effect_control
end

-- 初始化船只特效
function Boat:initEffect(id)
	self.scene_effect = {}  -- 场景特效

	-- 如果特效控制器不存在，则创建
	if self.effect_control == nil then
		self.effect_control = require( "gameobj/effect/effect" ).new(self.node)
	end
	
	self.boat_effect_id = id
	self:initBoatEffect()

	if self.is_oar == 1 then
		self.effect_control:trigger("tx_guiji", function(effect_name)
			self.effect_control:show(nil, effect_name)
		end, 1.5, true, true )
	end
end

-- 播放特效
function Boat:playEffect(effect_name, duration, position, speed, callback)
	if self.effect_control ~= nil then
		self.effect_control:show(nil, effect_name, {}, duration, position, speed, callback)
	end
end

function Boat:initBoatEffect()
		-- 初妈化本船特效
	if self.effect_control ~= nil then
		-- 船体公共特效配置
		self.effect_control:preload(string.format("%sboat.modelparticles", EFFECT_3D_PATH))
		-- 加载本船特效配置
		self.effect_control:preload(string.format("%sboat%0.2d.modelparticles", EFFECT_3D_PATH, self.boat_effect_id))
	else
		assert( false, "error: effect controller was empty!!!!" )
	end

	-- 将默认的特效开启
	self.effect_control:show(nil, "wave")
	self.effect_control:show(nil, "shadow")
end

------------------------------------------------------------------
-- FIX: By Hal 2015-08-05,暂时不管，以后处理
function Boat:showFireRes( pos )
	if self.is_ship then
		local pos_t = fireRes_pos[ self.kind ]
		pos = pos or Vector3.new( pos_t[ 1 ], pos_t[ 2 ], pos_t[ 3 ] )
		self:showEffect( "tx_kaihuo", nil, pos )
		self.effect_control:show( nil, "tx_kaihuo", {}, nil, pos, nil );
	end
end

function Boat:_showFireRes( pos, point, eff_name )
	eff_name = eff_name or "tx_kaihuo02"
	local particle = sceneEffect.createEffect({file = EFFECT_3D_PATH..eff_name..PARTICLE_3D_EXT,
												followNode = self.node})

	if not particle then return end

	local node = particle:GetNode()
	node:setTranslation(pos)
	particle:Start()
	LookAtPoint(particle:GetNode(), point)
end

function Boat:showEffect(ef_name, t, pos, endCall)
	if self.effect_control ~= nil then
		self.effect_control:show(nil, ef_name, {}, t, pos, nil, endCall)
	end	
end

function Boat:hideAllEffect()
	if self.effect_control ~= nil then
		self.effect_control:hide();
	end
end

function Boat:hideEffect(ef_name)
	if self.effect_control ~= nil then
		self.effect_control:hide(ef_name)
	end
end

function Boat:showSmoke()
	if self.effect_control ~= nil then
		self.isSmoke = true
		self.effect_control:show(nil, "tx_qihuo")
	end
end

function Boat:hideSmoke()
	if self.effect_control ~= nil then
		self.isSmoke = false
		self.effect_control:hide("tx_qihuo")
	end
end

-- 挂在场景的特效
function Boat:showSceneEffect(name, params)
	if self.scene_effect[name] then 
		self.scene_effect[name]:Show()
	elseif params then  
		self.scene_effect[name] = sceneEffect.createEffect(params)
		self.scene_effect[name]:Show()
	end 
end 

function Boat:hideSceneEffect(name)
	if self.scene_effect and self.scene_effect[name] then 
		self.scene_effect[name]:Hide()
	end 
end 

function Boat:setPathNode(isVisible)
	if self.pathNode and self.pathClickParticle then
		self.pathClickParticle:GetNode():setActive(isVisible)
		self.pathNode:setActive(isVisible)
	end
end

function Boat:closePathNodeFunc(isVisible)
	self.pathNodeVisible = isVisible
	if isVisible then
		self:setPathNode(false)
	end
end

local pathcolor = {0.04579367, 0.5405006, 0.8897059}
function Boat:addPathEffect(touchPos)
	if self.pathNodeVisible then return end

	local battle_data = getGameData():getBattleDataMt()
	if battle_data:isDemo() then return end 

	self.pathTouchPos = touchPos
	local  pos = self.node:getTranslation()
	local dist = GetVectorDistance(pos, touchPos)
	local commonBase = require("gameobj/commonFuns")
	if self.pathClickParticle then
		self.pathClickParticle:GetNode():setActive(true)
		self.pathClickParticle:GetNode():setTranslation(touchPos)
		self.pathClickParticle:Start()
	else
		local parent = BattleInit3D:getLayerShip3d()
		local _, particle = commonBase:addNodeEffect(parent, "tx_dianji", touchPos)
		particle:Start()
		self.pathClickParticle = particle
		self.eff_model["pathClickParticle"] = self.pathClickParticle:GetNode()
	end

	local function showAlphaAnimation( ... )
		if self.pathAlpha then
			local keyCount = 2
			local keyTimes = {0, 100 * 10}
			local keyValues = {pathcolor[1],pathcolor[2],pathcolor[3],1, pathcolor[1],pathcolor[2],pathcolor[3],0}
			self.pathAlpha:setValue(Vector4.new(pathcolor[1],pathcolor[2],pathcolor[3],1))
			local anim = self.pathAlpha:createAnimation("aplhpa", MaterialParameter.ANIMATE_UNIFORM(),
					keyCount, keyTimes, keyValues, "LINEAR")
			anim:play()
		end
	end
	if self.pathNode then
		self.pathNode:setActive(true)
		showAlphaAnimation()
		self.pathNode:setTranslation(pos:x(), 0, pos:z())
		return
	end

	local pathStr = "plane001"
	local pathGpb = string.format("%s%s/%s.gpb", MODEL_3D_PATH, pathStr, pathStr)
	local pathName = string.format("%s", pathStr)

	local pathNode = ResourceManager:LoadModel(pathGpb, pathName)
	self.pathNode = pathNode
	
	local material = pathNode:getModel():getMaterial(0)
	material:setTechnique("plane001")
	
	local updateMainTexST = nil
	local updateFlowTexST = nil
	local u_texSpeed = nil
	local u_modulateAlphaHandel = nil
	local function getShaderParam(node)
		local model = node:getModel()
		local mesh = model:getMesh()
		local partCount = mesh:getPartCount()
		local paramHandle = {}

		for j = 0, partCount - 1 do
			local tempNodeMaterial = model:getMaterial(j)
			if tempNodeMaterial then
				local tempTech = tempNodeMaterial:getTechnique("plane001")
				local parmCount = tempTech:getParameterCount()
				for n = 0, parmCount - 1 do
					local tempParam = tempTech:getParameterByIndex(n)
					local paramName = tempParam:getName()
					paramHandle[paramName] = tempParam
				end
			end
		end
		return paramHandle
	end
	--
	local tempHandles = getShaderParam(self.pathNode)
	updateMainTexST = tempHandles["u_diffuseTextureST"]
	updateFlowTexST = tempHandles["u_flowTexST"]
	u_texSpeed = tempHandles["u_texSpeed"]
	u_modulateAlphaHandel = tempHandles["u_mainColor"]

	local boundingSphere = pathNode:getBoundingSphere()
	local scale = dist / boundingSphere:radius() / 2
	self.initBoundingRadius = boundingSphere:radius()
	pathNode:setScaleZ(scale)
	updateMainTexST:setValue(Vector4.new(1, scale, 0, 0))
	updateFlowTexST:setValue(Vector4.new(1, scale, 0, 0))
	pathNode:setTranslation(pos:x(), 0, pos:z())

	local layer3dShip = BattleInit3D:getLayerShip3d()
	layer3dShip:addChild(pathNode)
	self.eff_model["pathNode"] = pathNode
	--
	local directionZ = Vector3.new(0, 0, 1)
	local direction = Vector3.new()
	Vector3.subtract(Vector3.new(self.pathTouchPos:x(), 0,self.pathTouchPos:z()), Vector3.new(pos:x(), 0, pos:z()), direction)
	direction:normalize()
	local lastAngle = self.anglePath or 0
	local angle = Vector3.angle(direction, directionZ)
	if pos:x() < self.pathTouchPos:x() then
		angle = angle
	else
		angle = -angle
	end
	self.anglePath = angle
	self.pathNode:rotateY(self.anglePath - lastAngle)
	self.pathAlpha = u_modulateAlphaHandel
	showAlphaAnimation()
	if self.pathUpdateItemHander then
		return
	end

    local function updateTime(dt)
    	local playShipPos = self.node:getTranslation()
    	local dist = GetVectorDistance(playShipPos, self.pathTouchPos)
    	local isActive = self.pathNode:isActive()
    	local minDis = 20
    	if dist <= minDis or (isActive == false) then
    		self.pathNode:setScaleZ(1)
			self.pathNode:setActive(false)
			self.pathClickParticle:GetNode():setActive(false)
			return
		end
		local posConfig = {
			[1] = {start = 700, endDist = 1000, dx = 40},
			[2] = {start = 1000, endDist = 1600, dx = 60},
			[3] = {start = 1800, endDist = 2000, dx = 130},
			[4] = {start = 2000, endDist = 2500, dx = 105},
			[5] = {start = 2500, endDist = 9999, dx = 150},
		}
		for key, value in pairs(posConfig) do
			if dist >= value.start and dist < value.endDist then
				dist = dist + value.dx
			end
		end
		local directionZ = Vector3.new(0, 0, 1)
		local direction = Vector3.new()
		Vector3.subtract(Vector3.new(self.pathTouchPos:x(), 0,self.pathTouchPos:z()), Vector3.new(playShipPos:x(), 0, playShipPos:z()), direction)
		direction:normalize()
		
		local lastAngle = self.anglePath or 0
		local angle = Vector3.angle(direction, directionZ)
		if playShipPos:x() < self.pathTouchPos:x() then
			angle = angle
		else
			angle = -angle
		end
		self.anglePath = angle
		self.pathNode:rotateY(self.anglePath - lastAngle)
		--
    	self.pathNode:setTranslation(playShipPos:x(), 0, playShipPos:z())
		local scale = dist / self.initBoundingRadius / 2
		self.pathNode:setScaleZ(scale)
		updateMainTexST:setValue(Vector4.new(1, scale, 0, 0))
		updateFlowTexST:setValue(Vector4.new(1, scale, 0, 0))
		local speedVector = Vector4.new(0, 3, 0, 3)
		speedVector:scale(1 / scale)
		u_texSpeed:setValue(speedVector)
    end

    local scheduler = CCDirector:sharedDirector():getScheduler()
	self.pathUpdateItemHander = scheduler:scheduleScriptFunc(updateTime, 0, false)
end

function Boat:closeShipYellowPathNode(isVisible)
	if self.pathIndex > 0 then
		if self["pathNode"..self.pathIndex] and self["pathClickParticle"..self.pathIndex] then
			self["pathClickParticle"..self.pathIndex]:GetNode():setActive(isVisible)
			self["pathNode"..self.pathIndex]:setActive(isVisible)
		end
	end
end

-- TODO:应该可简化
function Boat:addTargetPathEffect(touchPos, textureName, loopFlag)
    local index = 0
	self.pathIndex = self.pathIndex + 1
	index = self.pathIndex

	if self.pathNodeVisible then
		return
	end

    self["pathTouchPos"..index] = touchPos
	local pos = self.node:getTranslation()
	local dist = GetVectorDistance(pos, touchPos)
	local commonBase = require("gameobj/commonFuns")
	if self["pathClickParticle"..index] then
		self["pathClickParticle"..index]:GetNode():setActive(true)
		self["pathClickParticle"..index]:GetNode():setTranslation(touchPos)
		self["pathClickParticle"..index]:Start()
	else
		local parent = BattleInit3D:getLayerShip3d()
		local _, particle = commonBase:addNodeEffect(parent, DIANJI_YELLOW, touchPos)
		particle:Start()
		self["pathClickParticle"..index] = particle
		--self.eff_model["pathClickParticle"..index] = self["pathClickParticle"..index]:GetNode()
	end
	local function showAlphaAnimation( )
		if self["pathAlpha"..index] then
			local keyCount = 2
			local keyTimes = {0, 100 * 10}
			local keyValues = {pathcolor[1],pathcolor[2],pathcolor[3],1, pathcolor[1],pathcolor[2],pathcolor[3],0}
			self["pathAlpha"..index]:setValue(Vector4.new(pathcolor[1],pathcolor[2],pathcolor[3],1))
			local anim = self["pathAlpha"..index]:createAnimation("aplhpa", MaterialParameter.ANIMATE_UNIFORM(),
					keyCount, keyTimes, keyValues, "LINEAR")
            
            if loopFlag then
                anim:getClip():setRepeatCount(0)
            end
            
			anim:play()
		end
	end
	if self["pathNode"..index] then
		self["pathNode"..index]:setActive(true)
		showAlphaAnimation()
		self["pathNode"..index]:setTranslation(pos:x(), 0, pos:z())
		return
	end

    local pathStr = "plane001"
	local pathGpb = string.format("%s%s/%s.gpb", MODEL_3D_PATH, pathStr, pathStr)
	local pathName = string.format("%s", pathStr)
	local pathNode = ResourceManager:LoadModel(pathGpb, pathName)
	
	local material = pathNode:getModel():getMaterial(0)
	material:setTechnique(textureName)

	self["pathNode"..index] = pathNode
	
	local updateMainTexST = nil
	local updateFlowTexST = nil
	local u_texSpeed = nil
	local u_modulateAlphaHandel = nil
	
	local function getShaderParam(node)
		local model = node:getModel()
		local mesh = model:getMesh()
		local partCount = mesh:getPartCount()
		local paramHandle = {}
		
		for j = 0, partCount - 1 do
			local tempNodeMaterial = model:getMaterial(j)
			if tempNodeMaterial then
				local tempTech = tempNodeMaterial:getTechnique(textureName)
				local parmCount = tempTech:getParameterCount()
				for n = 0, parmCount - 1 do
					local tempParam = tempTech:getParameterByIndex(n)
					local paramName = tempParam:getName()
					paramHandle[paramName] = tempParam
				end	
			end
		end
		return paramHandle
	end
	--
	local tempHandles = getShaderParam(self["pathNode"..index])
	updateMainTexST = tempHandles["u_diffuseTextureST"]
	updateFlowTexST = tempHandles["u_flowTexST"]
	u_texSpeed = tempHandles["u_texSpeed"]
	u_modulateAlphaHandel = tempHandles["u_mainColor"]

	local boundingSphere = pathNode:getBoundingSphere()
	self["initBoundingRadius"..index] = 38--boundingSphere:radius()

	local scale = dist / self["initBoundingRadius"..index] / 2
	pathNode:setScaleZ(scale)
	updateMainTexST:setValue(Vector4.new(1, scale, 0, 0))
	updateFlowTexST:setValue(Vector4.new(1, scale, 0, 0))
	pathNode:setTranslation(pos:x(), 0, pos:z())

	local layer3dShip = BattleInit3D:getLayerShip3d()
	layer3dShip:addChild(pathNode)
	self.eff_model["pathNode"..index] = pathNode
	--
	local directionZ = Vector3.new(0, 0, 1)
	local direction = Vector3.new()
	Vector3.subtract(Vector3.new(self["pathTouchPos"..index]:x(), 0,self["pathTouchPos"..index]:z()), Vector3.new(pos:x(), 0, pos:z()), direction)
	direction:normalize()
	local lastAngle = self["anglePath"..index] or 0
	local angle = Vector3.angle(direction, directionZ)
	if pos:x() < self["pathTouchPos"..index]:x() then
		angle = angle
	else
		angle = -angle
	end
	self["anglePath"..index] = angle
	self["pathNode"..index]:rotateY(self["anglePath"..index] - lastAngle)
	self["pathAlpha"..index] = u_modulateAlphaHandel
	showAlphaAnimation()

	local scheduler = CCDirector:sharedDirector():getScheduler()
    if self["pathUpdateItemHander"..index] then 
		scheduler:unscheduleScriptEntry(self["pathUpdateItemHander"..index]) 
		self["pathUpdateItemHander"..index] = nil
	end

    local function updateTime(dt)
    	local playShipPos = self.node:getTranslation()
    	local dist = GetVectorDistance(playShipPos, self["pathTouchPos"..index])
    	local isActive = self["pathNode"..index]:isActive()
    	local minDis = 40
    	if dist <= minDis or (isActive == false)then
    		self["pathNode"..index]:setScaleZ(1)
			self["pathNode"..index]:setActive(false)
			self["pathClickParticle"..index]:GetNode():setActive(false)
			return
		end
		local posConfig = {
			[1] = {start = 700, endDist = 1000, dx = 40},
			[2] = {start = 1000, endDist = 1600, dx = 60},
			[3] = {start = 1800, endDist = 2000, dx = 130},
			[4] = {start = 2000, endDist = 2500, dx = 105},
			[5] = {start = 2500, endDist = 9999, dx = 150},
		}
		for key, value in pairs(posConfig) do
			if dist >= value.start and dist < value.endDist then
				dist = dist + value.dx
			end
		end
		local directionZ = Vector3.new(0, 0, 1)
		local direction = Vector3.new()
		Vector3.subtract(Vector3.new(self["pathTouchPos"..index]:x(), 0, self["pathTouchPos"..index]:z()), 
			Vector3.new(playShipPos:x(), 0, playShipPos:z()), direction)
		direction:normalize()
		
		local lastAngle = self["anglePath"..index] or 0
		local angle = Vector3.angle(direction, directionZ)
		if playShipPos:x() < self["pathTouchPos"..index]:x() then
			angle = angle
		else
			angle = -angle
		end
		self["anglePath"..index] = angle
		self["pathNode"..index]:rotateY(self["anglePath"..index] - lastAngle)
		--
    	self["pathNode"..index]:setTranslation(playShipPos:x(), 0, playShipPos:z())
		local scale = dist / self["initBoundingRadius"..index] / 2
		self["pathNode"..index]:setScaleZ(scale)
		updateMainTexST:setValue(Vector4.new(1, scale, 0, 0))
		updateFlowTexST:setValue(Vector4.new(1, scale, 0, 0))
		local speedVector = Vector4.new(0, 3, 0, 3)
		speedVector:scale(1 / scale)
		u_texSpeed:setValue(speedVector)
    end

	self["pathUpdateItemHander"..index] = scheduler:scheduleScriptFunc(updateTime, 0, false)
end


function Boat:initCollision()
	--[todo]:放大1.2倍碰撞区域
	local scale = 1.2
	--SPHERE
	local boundingSphere = self.node:getBoundingSphere()
	self.node:setCollisionObject("GHOST_OBJECT", PhysicsCollisionShape.sphere(boundingSphere:radius()/2*1.2, Vector3.new(0,0,0), false))
    self.node:getCollisionObject():addCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
	--BOX
	-- local boundingBox = self.node:getModel():getMesh():getBoundingBox()
	-- local center = boundingBox:getCenter()
	-- center:scale(2)
	-- local extent = boundingBox:getExtent()
	-- self.node:setCollisionObject("GHOST_OBJECT", PhysicsCollisionShape.box(extent, Vector3.new(0,-35,-32), false))
	-- self.node:getCollisionObject():addCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
	--MESH
	-- collisionObject duck
-- {
    -- type = RIGID_BODY
    -- shape = MESH
    -- mass = 5.0
    -- friction = 1.0
    -- restitution = 0.0
    -- linearDamping = 0.5
    -- angularDamping = 0.5
-- }
	-- local mesh = self.node:getModel():getMesh() 
	-- self.node:setCollisionObject("GHOST_OBJECT", PhysicsCollisionShape.mesh(mesh))
	-- self.node:getCollisionObject():addCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
end

function Boat:removeCollision()
	if not self.node then return end
	local collsionObject = self.node:getCollisionObject()
	if collsionObject then 
		collsionObject:removeCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
		self.node:setCollisionObject("NONE")
	end 
end

function Boat:initUI()
	self.ui = CCNode:create()
	self.ship_ui:addChild(self.ui)
	self.acSp = CCNode:create()
	self.ui:addChild(self.acSp)
	self.dialog = CCNode:create()
	self.dialog_node:addChild(self.dialog)
end 

function Boat:update(dt) --此时间是每帧时间的1000分之一
	if self.is_pause then 
		self:updateUI(dt)
		return 
	end
	
	self:updateAngle(dt)
	self:updatePosition(dt)
	self:updateUI(dt)           -- 刷新位置再刷新UI
	self:updateAttackRange(dt)
end 

function Boat:calcSpeed(speed, dt, speed_rate)
	if speed < 0 then 
		speed = 0
	end
	return speed * dt * speed_rate
end

function Boat:updatePosition(dt)
	if self.is_ban_turn then return end
	local tran = self.node:getForwardVectorWorld():normalize()
	local dist = self:calcSpeed(self.speed, dt, self.speed_rate)
	tran:scale(dist)
	self.node:translate(tran)
end

-- 限制转向
function Boat:setBanRotate(value)
	if self.is_ban_rotate == value then return end
	
	self.is_ban_rotate = value
end

function Boat:getBanRotate()
	return self.is_ban_rotate
end

-- 限制移动
function Boat:setBanTurn(value)
	self.is_ban_turn = value
end

function Boat:getBanTurn()
	return self.is_ban_turn
end

-- 转动
function Boat:rotateAngle(target_delta_angle, stop_rotate_flg)
	-- 真实的角度转动
	self.rotate_angle = self.rotate_angle - target_delta_angle
	local rad = math.rad(- target_delta_angle)
	self.node:rotateY(rad)

	if stop_rotate_flg or math.abs(self.rotate_angle) < 5 then
		self:setMoveAction()
	else
		if target_delta_angle > 0 then
			self:setTurnLeftAction()
		else
			self:setTurnRightAction()
		end
	end
end

function Boat:updateUI(dt)
	if not self.node then return end
	
	local translate = self.node:getTranslationWorld()
	local pos = gameplayToCocosWorld(translate)
	if not tolua.isnull(self.ui) then 
		self.ui:setPosition(pos)
	end
	if not tolua.isnull(self.dialog) then 
		self.dialog:setPosition(pos)
	end
end

function Boat:checkTurnStop(dangle)
	local forward = self.node:getForwardVectorWorld()
	local boat_pos = self.node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(self.target_pos, boat_pos, dir)
	local angle = math.deg(Vector3.angle(forward, dir))
	
	if angle < dangle then 
		LookForward(self.node, dir)
		self.is_need_turn = false 
		self.turn_type = 0
		self:playAnimation(ani_name_t["move"..self.ani_post_fix], true)
		return true 
	end
end 

function Boat:updateForward(dt)
	if self.is_ban_rotate then return end
	if not self.is_need_turn then return end 
	
	local dangle = dt*self.turn_speed
	if not self:checkTurnStop(dangle) then
		if self.turn_type == 1 then 
			self.node:rotateY(math.rad(-dangle))
		else 
			self.node:rotateY(math.rad(dangle))
		end 
	end
end 

-- 用于原地转
function Boat:updateRotate(dt)
	if self.is_ban_rotate then return end
	if not self.is_need_rotate then return end 

	local dangle = dt*self.turn_speed
	if self.rotate_angle < 0 then 
		self.rotate_angle = self.rotate_angle + dangle
		if self.rotate_angle >= 0 then 
			dangle = dangle - self.rotate_angle
			self.node:rotateY(math.rad(-dangle))
			self:rotateStop()
		else
			self.node:rotateY(math.rad(-dangle))
		end
		
	else 
		self.rotate_angle = self.rotate_angle - dangle
		if self.rotate_angle <= 0 then 
			dangle = dangle + self.rotate_angle
			self.node:rotateY(math.rad(dangle))
			self:rotateStop()
		else
			self.node:rotateY(math.rad(dangle))
		end
	end 	
end

function Boat:rotateStop()
	self.is_need_rotate = false 
	self.is_need_turn = false 
	self.rotate_angle = 0
	self:playAnimation(ani_name_t["move"..self.ani_post_fix], true)	
end

local function isNearAngle(angle1, angle2)
	
end

function Boat:setRotateAngle(angle, reason)
	if self.is_ban_rotate then return end

	if not reason then reason = "unknow" end
	
	if angle > 180 then
		angle = angle - 360
	end

	self.rotate_angle = angle
end

function Boat:getRotateAngle()
	return self.rotate_angle
end

-- 朝某个方向
function Boat:turnTo(dir, reason)
	local forward = self.node:getForwardVectorWorld()
	local rotate_angle = math.deg(Vector3.angle(forward, dir))
	
	reason = reason or "unknow"
	
	if rotate_angle > 1 then 
		if IsVectorAtRight(self.node, dir) then 
			self:setRotateAngle(-rotate_angle, "turn_to_" .. reason)
		else
			self:setRotateAngle(rotate_angle, "turn_to_" .. reason)
		end 
	end 
end 

function Boat:setMoveAction()
	if (self.playing_animantion == "move") then return end
	self:playAnimation(ani_name_t["move"..self.ani_post_fix], true)
	self.playing_animantion = "move"
end

function Boat:setTurnRightAction()
	if (self.playing_animantion == "turnRight") then return end
	self:playAnimation(ani_name_t["turnRight"..self.ani_post_fix], true)
	self.playing_animantion = "turnRight"
end

function Boat:setTurnLeftAction()
	if (self.playing_animantion == "turnLeft") then return end
	self:playAnimation(ani_name_t["turnLeft"..self.ani_post_fix], true)
	self.playing_animantion = "turnLeft"
end

function Boat:playAnimation(name, isRepeat, notDelay)
	if not self.animation then return end
	if self.cur_ani_name == name then 
		return 
	end 
	self.cur_ani_name = name 
    local clip = self.animation:getClip(name)
	if not clip then return end

	if isRepeat then
		clip:setRepeatCount(0)
	else
		clip:setRepeatCount(1)
	end
    if self.curAni then
    	if notDelay then
	   		clip:play()
	   	else
	   		self.curAni:crossFade(clip, 300)
	   	end
    else
        clip:play()
    end
	self.curAni = clip
end

function Boat:setSpeed(speed)
	self.speed = speed
end

function Boat:getSpeed()
	return self.speed
end

function Boat:getSpeedRate()
	return self.speed_rate
end 

function Boat:setSpeedRate(rate)
	if self.speed_rate == rate then return end
	
	self.speed_rate = rate
end

function Boat:setPause(pause)
	self.is_pause = pause
end 

function Boat:isPause()
	return self.is_pause
end 

function Boat:setPos(x, y)
	if not self.node then return end
	local pos = CameraFollow:cocosToGameplayWorld(ccp(x, y))
	self.node:setTranslation(pos)
	if not tolua.isnull(self.ui) then
		self.ui:setPosition(x, y)
	end
end 

function Boat:getPos()
	local translation = self.node:getTranslationWorld()
	local pos = gameplayToCocosWorld(translation)
	return pos.x, pos.y
end 

-- 直接设置角度（规定顺时针为正）
function Boat:setAngle(angle, vector)
	if not self.node then return end
	local axis = vector or self.node:getUpVector()
	self.node:setRotation(axis, math.rad(-angle))
end 

function Boat:getAngle() 
	local forward = self.node:getForwardVectorWorld()
	local originVec3 = Vector3.new(0,0,-1)
	local angle = math.deg(Vector3.angle(forward, originVec3))
	
	if IsVectorAtRight(self.node, originVec3) then 
		angle = -angle 
	end
	return angle
end

function Boat:unBroken()
	self:changeTexture(self.unbroken_tex_res)
	self.isBroken = false
	self.ani_post_fix = ""
end

function Boat:broken()
	self:changeTexture(self.broken_tex_res)
	self.isBroken = true
    -- 如果船体broken，则播放broken的动画
	self.ani_post_fix = "Broken"
end

function Boat:changeTexture(path)
	local model = self.node:getModel()
	local material = model:getMaterial(0)
	local parameter = material:getParameter("u_diffuseTexture")
	--print("changeTexture:", path)
	parameter:setValue(path, false)
end

-- Note:不能单独在外部使用，所有船的释放都应该用ship_mt:Release(),
-- ship:Release()会调用这个函数进行船只的释放
function Boat:release()
	if self.effect_control then
		self.effect_control:release()
		self.effect_control = nil
	end
	
	if self.curAni then 
		self.curAni:stop()
		self.curAni = nil
	end 
	
	self:removeEffModel()
	self:hideAllEffectAndPic()
	self:stopAutoHandler()
	self.impact_obj = nil
	self.animation = nil
	self.target_pos = nil
	self.name = nil
	self.parent = nil
	self.shootNode = nil

	if self.pathUpdateItemHander then 
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.pathUpdateItemHander)
		self.pathUpdateItemHander = nil
	end

    --jingz
    if self.pathIndex and self.pathIndex > 0 then
        local index = 1
        while index <= self.pathIndex do
            if self["pathNode"..index] and self["pathNode"..index]:getParent() then
		        self["pathNode"..index]:getParent():removeChild(self["pathNode"..index])
		        self["pathNode"..index] = nil
	        end
			
            if 	self["pathClickParticle"..index] then 
		        local scheduler = CCDirector:sharedDirector():getScheduler()
		        scheduler:unscheduleScriptEntry(self["pathUpdateItemHander"..index])
		        self["pathUpdateItemHander"..index] = nil
				self["pathClickParticle"..index]:Release()
				self["pathClickParticle"..index] = nil
				self["anglePath"..index] = angle
				self["pathAlpha"..index] = nil
	        end
            index = index + 1
        end
    end
	self.pathTouchPos = nil

    if self.pathClickParticle then
    	self.pathClickParticle:Release()
    	self.pathClickParticle = nil
    end
	if self.showRangeTimer then 
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.showRangeTimer)
		self.showRangeTimer = nil
	end
	self:removeCollision()
	
	if not tolua.isnull(self.ui) then 
		self.ui:removeFromParentAndCleanup(true)
		self.ui = nil
	end 

	if self.pathNode and self.pathNode:getParent() then
		self.pathNode:getParent():removeChild(self.pathNode)
		self.pathNode = nil
	end
	
	if self.node and self.node:getParent() then 
		self.node:getParent():removeChild(self.node)
		self.node = nil
	end 
	
	self = nil
end

function Boat:getShootPos()
	if self.shootNode then 
		return self.shootNode:getTranslation()
	end
	return Vector3.new()
end

function Boat:beHit()	
end

-- 沉船反向
local function drownDir()
	local idx = math.random(1,3)
	local dir = 1
	if math.random(-1, 1) < 0 then dir = -1 end
	if math.random(-1, 1) > 0 then dir = 1 end
	local axi

	if idx == 1 then
		axi = "x"
	elseif idx == 2 then 
		axi = "y"
	else
		axi = "z"
	end
	return axi, dir
end

------------------------------------------------------------------------------------------------------------------------

--显示技能射程
function Boat:showSkillRange(range, skill_series)
	self.is_show_skill_range = true
	self.show_attack_range = false
	if self.fanNode then
		self.fanNode:setActive(false)
	end
	local def_range = 400
	if not self.skill_node then
		local node = AttackDirRange.showAttackRange(self.node, def_range, self.range_depth, Vector4.new(1, 1, 1, 0.8), 0.1)		
		node:setInheritedRotation(true)
		node:setInheritedScale(false)
		self.skill_node = node
	
	end
	self.skill_node:setScale(range/def_range)
	self.skill_node:setActive(true)
	-- if skill_series > 0 then
	-- 	self:showUnSelectSkillRank(range)
	-- end
end

--boss技能射程
function Boat:showBossSkillRange(range, skill_series, dir)
	self.is_show_boss_skill_range = true
	self.show_attack_range = false
	if self.fanNode then
		self.fanNode:setActive(false)
	end
	
	self:showBossSkillBox(range, dir, skill_series)
end

function Boat:showBossSkillBox(range, dir, skill_series)
	if not self.boss_skill_box then
		local node = AttackDirRange.showUnSelectSkillRank(self.node, range, self.range_depth, skill_series)
		--node:setInheritedRotation(false)
		self.boss_skill_box = node
		node:setInheritedRotation(false)
		node:setInheritedScale(false)
	end
	self.boss_skill_box:setActive(true)
	self.boss_skill_box:rotateX(math.rad(90))  
	print("dir", dir:x(), dir:y(), dir:z())  
	LookForward(self.boss_skill_box, dir)
	self.boss_skill_box:rotateX(math.rad(-90))
end


function Boat:showUnSelectSkillRank(range)
	
	if not self.unselect_skill_rank then
		local node = AttackDirRange.showUnSelectSkillRank(self.node, range, self.range_depth, Vector4.new(1, 1, 1, 0.8))
		node:setInheritedRotation(false)
		self.unselect_skill_rank = node
	end
	self.unselect_skill_rank:setActive(true)
end

function Boat:updateSkillRankDirection(dir)
	if self.unselect_skill_rank then
		self.unselect_skill_rank:rotateX(math.rad(90))    
		self.unselect_skill_rank:setTranslation(0, 0, 0)
		LookForward(self.unselect_skill_rank, dir)
		self.unselect_skill_rank:rotateX(math.rad(-90))
	end

end

function Boat:dismissSkillRange()
	self.is_show_skill_range = false
	if self.skill_node then
		self.skill_node:setActive(false)
	end
	if self.unselect_skill_rank and not tolua.isnull(self.unselect_skill_rank) then
		local parent = self.unselect_skill_rank:getParent()
		parent:removeChild(self.unselect_skill_rank)
		self.unselect_skill_rank = nil
	end
end

function Boat:dismissBossSkillRange()
	self.is_show_boss_skill_range = false
	if self.boss_skill_box and not tolua.isnull(self.boss_skill_box) then
		local parent = self.boss_skill_box:getParent()
		if parent then
			parent:removeChild(self.boss_skill_box)
			self.boss_skill_box = nil
		end
		
	end
end
------------------------------------------------------------------------------------------------------------------------

function Boat:delAttackRange()
	if not self.fanNode then return end
	local parent = self.fanNode:getParent()
	parent:removeChild(self.fanNode)
	self.fanNode = nil
end

function Boat:hideAllEffectAndPic()
	self:dismissSkillRange()
	self:dismissBossSkillRange()
	self:hideAllEffect()	
	self:hideGuanquan()
	self:delAttackRange()
end

function Boat:removeEffModel()
	if not self.eff_model then return end 
	for k, v in pairs(self.eff_model) do
		if v.node then 
			self.node:removeChild(v.node)
		end
		self.eff_model[k] = nil
	end
end

--沉船
function Boat:drown()
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(self.gen_id)

	self:removeEffModel()
	self:hideAllEffectAndPic()
	if not tolua.isnull(self.ui) then 
		self.ui:removeFromParentAndCleanup(true)
	end
	
	if not self.node then 
		print("ERROR!!!", self.gen_id)
		return 
	end

	local parent = self.node:getParent()
	parent:removeChild(self.node)

	local layer3dSea = BattleInit3D:getLayerSea3d()
	if layer3dSea then 
		layer3dSea:addChild(self.node)
	end
	--local boat_pos = Vector3.new(self.node:getTranslation())
	local pos = Vector3.new(0, 30, 0)
	self:showEffect("tx_die", nil, pos)
	local music_info = require("game_config/music_info")
	audioExt.playEffect(music_info.UI_SKIN.res, false)
	self:showSuipian03()	
	local delay_tm = 1.5
	local drownTm = 3.5
	-- 沉船时间要少于转镜头时间，避免沉船没有释放
	--assert(delay_tm + drownTm < battle_config.battle_end_rotate_cam_tm - 0.2) 
	local array = CCArray:create()
	local delay = CCDelayTime:create(delay_tm)
	local callFunc = CCCallFunc:create(function()
		local scheduler = CCDirector:sharedDirector():getScheduler()
		local tick_count = 0
		--TODO:使用这个接口mainColor直接会被设置成1，1，1，
		SetTranslucent(self.node, nil, 1)
		local axi, dir = drownDir()
		local totalRotate = 0

		self.drownTimer = scheduler:scheduleScriptFunc(function(dt)		
			if self.node then 
				SetTranslucent(self.node, nil, (1 - tonumber(string.format("%0.1f",(tick_count/drownTm)))))
				tick_count = tick_count + dt
				self.node:setTranslationY(-40*tick_count/drownTm)
				local base = 2
				if totalRotate < math.rad(60) then
					if axi == "x" then 
						self.node:rotateX(dt/base*dir)
					elseif axi == "y" then
						self.node:rotateY(dt/base*dir)
					else
						self.node:rotateZ(dt/base*dir)
					end
				end
				totalRotate = totalRotate + dt/base
				if tick_count >= drownTm then
					local scheduler = CCDirector:sharedDirector():getScheduler()					
					local battleData = getGameData():getBattleDataMt()
					battleData:removeDrownShip(self.gen_id)
				end
			end
		end,0.02,false) 
		local battleData =	getGameData():getBattleDataMt()
		battleData:addDrownShip(self.gen_id, self)
	end)
	
	array:addObject(delay)
	array:addObject(callFunc)
	display.getRunningScene():runAction(CCSequence:create(array))
end

function Boat:showGuanquan()
	if self.scene_effect[GUANG_QUAN_NAME] then 
		self:showSceneEffect(GUANG_QUAN_NAME)
	else 
		local res_name = "tx_selected"
		local file_name = EFFECT_3D_PATH..res_name..".particlesystem"
		local offset = Vector3.new(0, 100, 100)
		local pos = self.node:getTranslationWorld()
		Vector3.add(pos, offset, pos)

		local item = {file = file_name, followNode = self.node, offset = offset, is_retain = true, pos = pos}
		self:showSceneEffect(GUANG_QUAN_NAME, item)
	end 
end

function Boat:hideGuanquan()
	self:hideSceneEffect(GUANG_QUAN_NAME)
end

function Boat:showSuipian01()
	self.isSuipian01 = true
	self.isSuipian02 = false
	self.isSuipian03 = false
	self:showEffect("tx_shoujisuipian01")
end

function Boat:showSuipian02()
	self.isSuipian01 = false
	self.isSuipian02 = true
	self.isSuipian03 = false
	self:showEffect("tx_shoujisuipian02")
end

function Boat:showSuipian03()
	self.isSuipian01 = false
	self.isSuipian02 = false
	self.isSuipian03 = true
	self:showEffect("tx_shoujisuipian03")
end

function Boat:setMaterialParam(name, val)
	local material = self.node:getModel():getFirstMaterial()
	material:getParameter(name):setValue(val)
end

--------------------------------------------------

-- 是否描边
function Boat:setOutlineStyle( isOutline )
	-- body
	self.outline = isOutline
	self:updateRenderStyle()
end


-- 更新状态
function Boat:updateRenderStyle()
	if not self.node then return end
	local model = self.node:getModel()
	if not model then return end

	local material = model:getFirstMaterial()
	local original_tech = material:getTechnique()
	local original_tech_name = original_tech:getId()
	local tech_name = string.gsub(original_tech_name, "_outline", "")

	if self.outline then
		material:setTechnique(tech_name .. "_outline")
	else
		material:setTechnique(tech_name)
	end
	self:resetStatus()
	local flow_name = self:getCurFlowState()
	if flow_name then 
		self:setFlowState(flow_name)
	end 
end 

--以下三个函数是寻路,每搜船要有自己的寻路
function Boat:goToDesitinaion(end_pos, call_back, param)
	local p = ccp(self:getPos())
	local pos_st = self.land:tileToCocos(p) -- 开始坐标
	local pos_end = end_pos           -- 目标点
	
	local path = self.land:getSearchPath(pos_st, pos_end)
	if not path then
		return
	end 
	local path_len = #path
	local index = 3

	local auto
	auto = function()
		if index > path_len then
			if call_back then
				self:stopAutoHandler()
				call_back(param)
				self:rotateStop()
			end
			return
		end
		local x = path[index]
		local y = path[index + 1]
		index = index + 2
		local pos = self.land:cocosToTile2(ccp(x, y))
		self:autoMoveToPos(pos, auto)
	end
	auto()
end

function Boat:autoMoveToPos(next_pos, call_back)
	local pos = next_pos  -- 目标点
	local ver = cocosToGameplayWorld(pos)
	--self.node:setNextTranslation(ver)
	local boat_pos = self.node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(ver, boat_pos, dir)
	LookForward(self.node, dir)
	local lastx, lasty = self:getPos()

	local function isArrive()
		local tx, ty = self:getPos()
		local cur_dis = Math.distance(pos.x, pos.y, tx, ty)
		local last_dis = Math.distance(lastx, lasty, tx, ty)
		lastx, lasty = tx, ty
		--print("cur_dis---------", cur_dis, last_dis, self.node)
		if cur_dis < last_dis then
			self:stopArriveTimer()
			call_back()
		end
	end

	if not self.ship_auto_hander then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		self.ship_auto_hander = scheduler:scheduleScriptFunc(isArrive, 0, false)
	end
end

function Boat:isAutoRunning()
	if self.ship_auto_hander then
		return true
	end
	return false
end

function Boat:stopArriveTimer()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.ship_auto_hander then
		scheduler:unscheduleScriptEntry(self.ship_auto_hander)
		self:rotateStop()
	end
	self.ship_auto_hander = nil
end

function Boat:stopAutoHandler()
	self:stopArriveTimer()
end

return Boat 
