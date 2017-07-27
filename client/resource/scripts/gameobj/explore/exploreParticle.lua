--particle
local ClsParticleProp = class("ParticleProp")

function ClsParticleProp:ctor(cfg)
	self.res = cfg.res
	self.parentNode = cfg.parent
	self.isSea = cfg.isSea
	self.is_dead = false
	local ParticleSystem = require("particle_system")
	local particle = ParticleSystem.new(EFFECT_3D_PATH .. self.res .. PARTICLE_3D_EXT)
	if not particle	then return end
	self.particle = particle
	self.particle:Start()
    local sphereNode = particle:GetNode()
    if self.parentNode then
    	self.parentNode:addChild(sphereNode)
    else
    	local mountNode = nil
    	if self.isSea then
    		mountNode = Explore3D:getLayerSea3d()
    	else
    		mountNode = Explore3D:getLayerShip3d()
    	end
    	mountNode:addChild(sphereNode)
    end
	self:initUI()
end

function ClsParticleProp:release()
	self.is_dead = true
	self.particle:Stop()
	if self.particle then
        self.particle:Release()
    end
	self.particle = nil
	if not tolua.isnull(self.ui) then
		self.ui:removeFromParentAndCleanup(true)
	end
    self.ui = nil
end

function ClsParticleProp:setPos(x, y)
	local pos = CameraFollow:cocosToGameplayWorld(ccp(x, y))
	self.particle:GetNode():setTranslation(pos)
	self.ui:setPosition(x, y)
end

function ClsParticleProp:getPos()
    local translation = self.particle:GetNode():getTranslationWorld()
    local pos = gameplayToCocosWorld(translation)
    return pos.x, pos.y
end

function ClsParticleProp:initUI()
	self.ui = CCNode:create()
	local exploreData = getGameData():getExploreData()
	local shipUI = getShipUI()
	if not tolua.isnull(shipUI) then
		shipUI:addChild(self.ui)
	end
end

function ClsParticleProp:update(dt)
	self:updateUI(dt)
	if self.is_pause then return end

	self:updatePosition(dt)
	self:updateForward(dt)
	self:updateRotate(dt)
end

function ClsParticleProp:updatePosition(dt)
	local tran = self.particle:GetNode():getForwardVectorWorld():normalize()
	tran:scale(self.speed*dt*self.speed_rate)
	self.particle:GetNode():translate(tran)
end

function ClsParticleProp:updateUI(dt)
	if tolua.isnull(self.ui) then
		return
	end
	local translate = self.particle:GetNode():getTranslationWorld()
	local pos = gameplayToCocosWorld(translate)
	self.ui:setPosition(pos)
end

function ClsParticleProp:setVisible(is_visible)
	------------------------------------------------------
	-- modify By Hal 2015-09-07, Type(BUG) - gameplay self.particle not exist
	if not self.particle then return end  -- self.particle type is table
	------------------------------------------------------
    if self.is_dead then return end
	self.particle:GetNode():setActive(is_visible)
    if not tolua.isnull(self.ui) then
        self.ui:setVisible(is_visible)
    end
end

return ClsParticleProp
