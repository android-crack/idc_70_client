-- 探索事件道具

local ParticleSystem = require("particle_system")
local sceneEffect = require("gameobj/battle/sceneEffect")

local Boat = require("gameobj/ship3d")

local ExploreProp = class("ExploreProp", Boat)

function ExploreProp:ctor(cfg)

	self.cfg = cfg
	self.id = cfg.item_id
	self.gen_id = cfg.gen_id
	local speed = cfg.auto_speed or 0
	self.speed = Math.abs(speed)
	self.speed_rate = 1
	self.turn_speed = 60  -- 每秒转角度
	self.turn_type = 0    -- -1, 0 , 1 左转， 不转 ， 右转
	self.is_need_turn = false
	self.is_need_rotate = false
	self.rotate_angle = 0
	self.target_pos = Vector3.new()
	self.is_pause = false
	self.type = cfg.type
	self.effect = {}
	self.sea_level = cfg.sea_level
	self.isBroken = false
	self.sea_down = cfg.sea_down
	self.effectName = cfg.water_res
	self.ani_post_fix = ""
	self.animationNames = cfg.animation_res --按配置里填的顺序播放
	if cfg.isRepeat == false then
		self.isRepeat = cfg.isRepeat
	else
		self.isRepeat = true
	end

	if cfg.isPlay == false then
		self.isPlay = cfg.isPlay
	else
		self.isPlay = true
	end
	
	if self.sea_level == 1 then
		self.parent = Explore3D:getLayerSea3d()
	else
		self.parent = Explore3D:getLayerShip3d()
	end

	-- local res = cfg.res
	-- local gpb_name = string.format("%s%s/%s.gpb", MODEL_3D_PATH, res, res)
	-- local node_name = string.format("%s", res)
	-- self.node = ResourceManager:LoadModel(gpb_name, node_name)
	self.path = MODEL_3D_PATH
	self.node_name = cfg.res

	Boat.super.ctor(self, self)

	self.shootNode = self.node:findNode("center", true)
	
	self.node:setId(tostring(gen_id))
	
	if self.effectName then
		self:initEffect()
	end
	self:loadAnimation()
	if self.animationNames then
		self:playAnimation(self.animationNames[1], self.isRepeat, self.isPlay)
	end
	self:initUI()

	if self.cfg.hit_radius > 0 then
		self:initCollision()
	end
end

function ExploreProp:initEffect()
	self.scene_effect = {}  -- 场景特效
	if self.effect_control == nil then
		self.effect_control = require( "gameobj/effect/effect" ).new( self.node )
	end
	local particle_res = string.format("%s.modelparticles",  self.cfg.res)
	self.effect_control:preload( EFFECT_3D_PATH .. particle_res)
	-- self.effect_control:showAll(self.node)
end

function ExploreProp:setPos(x, y, downY)
	local pos = CameraFollow:cocosToGameplayWorld(ccp(x, y))
	local down = self.sea_down or 0
	downY = downY or 0
	down = down - downY
	--local vec = Vector3.new(pos:x(), down, pos:z())
	--self.node:setTranslation(vec)
	self.node:setTranslation(pos:x(), down, pos:z())
	self.ui:setPosition(x, y)
end

function ExploreProp:initCollision()
	local boundingSphere = self.node:getBoundingSphere()
	self.node:setCollisionObject("GHOST_OBJECT", PhysicsCollisionShape.sphere(boundingSphere:radius()))
end


function ExploreProp:removeCollision()
	local collsionObject = self.node:getCollisionObject()
	if collsionObject then
		self.node:setCollisionObject("NONE")
	end
end

function ExploreProp:initUI()
	self.ui = CCNode:create()
	local exploreData = getGameData():getExploreData()
	local shipUI = getShipUI()
	if not tolua.isnull(shipUI) then
		shipUI:addChild(self.ui)
	end
end

function ExploreProp:update(dt)
	self:updateUI(dt)
	if self.is_pause then return end

	self:updatePosition(dt)
	self:updateForward(dt)
	self:updateRotate(dt)
end

function ExploreProp:updatePosition(dt)
	local tran = self.node:getForwardVectorWorld():normalize()
	tran:scale(self.speed*dt*self.speed_rate)
	self.node:translate(tran)
end

function ExploreProp:updateUI(dt)
	if tolua.isnull(self.ui) then
		return
	end
	local translate = self.node:getTranslationWorld()
	local pos = gameplayToCocosWorld(translate)
	self.ui:setPosition(pos)
end

function ExploreProp:loadAnimation()
	local res = self.cfg.res

	local anim_name = string.format("%s%s/%s.animation", MODEL_3D_PATH, res, res)
	local animation = self.node:getAnimation("animations")
	if not animation then return end

	animation:createClips(anim_name)
	--TODO: Animation release
	self.nodeAnimation = animation
end

function ExploreProp:animationIsPlaying(name)
	if tolua.isnull(self.nodeAnimation) then
		return
	end
	local clip = self.nodeAnimation:getClip(name)
	return clip:isPlaying()
end

function ExploreProp:stopAnimation(name)
	if tolua.isnull(self.nodeAnimation) then
		return
	end
	local clip = self.nodeAnimation:getClip(name)
	if clip:isPlaying() then
		clip:stop()
	end
end

function ExploreProp:playAnimation(name, isRepeat, isPlay)
	if tolua.isnull(self.nodeAnimation) then
		return
	end

	local clip = self.nodeAnimation:getClip(name)
	if isRepeat then
		clip:setRepeatCount(0)
	else
		clip:setRepeatCount(1)
	end

    if isPlay then
    	if clip:isPlaying() then

    	else
    		clip:play()
    	end
    end

    self.curAni = clip
end

function ExploreProp:getAnimationClip(name)
	if tolua.isnull(self.nodeAnimation) then
		return
	end
	local clip = self.nodeAnimation:getClip(name)
	return clip
end

function ExploreProp:unBroken()
	local res = self.cfg.res
	local brokenRes = self.cfg.brokenRes
	local unbroken_res_id = 1
	local texturePath = string.format("%s%s/%s.fbm/%s_%0.3d.png", MODEL_3D_PATH, res, res, res, unbroken_res_id)
	self:changeTexture(texturePath)
	self.isBroken = false
end

function ExploreProp:broken()
	local res = self.cfg.res
	local brokenRes = self.cfg.brokenRes
	local broken_res_id = 2
	local texturePath = string.format("%s%s/%s.fbm/%s_%0.3d.png", MODEL_3D_PATH, res, res, res, broken_res_id)
	self:changeTexture(texturePath)
	self.isBroken = true
end

function ExploreProp:setVisible(is_visible)
	if not tolua.isnull(self.node) then
		self.node:setActive(is_visible)
	end
	if not tolua.isnull(self.ui) then
		self.ui:setVisible(is_visible)
	end
end


return ExploreProp
