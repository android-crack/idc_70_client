--2016/10/09
--create by wmh0497
--用于粒子特效

local ParticleSystem = require("particle_system")
local ClsModel3D = require("gameobj/model3d")
local ClsU3dNodeBase = require("gameobj/u3d/clsU3dNodeBase")
local ClsU3dAnimationParse = require("gameobj/u3d/u3dAnimationParse")

local ClsU3dParticle = class("ClsU3dParticle", ClsU3dNodeBase)

--[[ params:
node_path_str = "root/11/33"
root_anim_cfg = "boat03"
--]]
function ClsU3dParticle:init()
    self.m_type = "particleSystem"
    self.m_particle = nil
    self:initParticle()
    self:initModelAnim()
end

function ClsU3dParticle:initParticle()
    if self.m_cfg.res then
        self.m_particle = ParticleSystem.new(string.format("%s%s%s", EFFECT_PATH, self.m_cfg.res, PARTICLE_3D_EXT))
        self.m_node = self.m_particle:GetNode()
        self.m_parent_node:addChild(self.m_node)
        self.m_particle:Start()
    else 
        self.m_node = Node.create()
        self.m_parent_node:addChild(self.m_node)
    end
	
	local transform = self.m_cfg.transform
	if transform then 
		self:setScale(unpack(transform.scale))
		self:setRotation(unpack(transform.rotation))
		self:setTranslation(unpack(transform.position))
	end
end

function ClsU3dParticle:start()
    if self.m_particle then
        self.m_particle:Start()
        self:playU3dCfgAnimation()
    end
end

function ClsU3dParticle:stop()
    if self.m_particle then
        self.m_particle:Stop()
        self:stopU3dCfgAnimation()
    end
end

return ClsU3dParticle