--2017/02/13
--create by wmh0497
--用于粒子特效

local ParticleSystem = require("particle_system")
local ClsU3dFollowParticle = class("ClsU3dFollowParticle", require("gameobj/u3d/clsU3dParticle"))

function ClsU3dFollowParticle:init()
    self.m_type = "particleSystem"
    self.m_particle = nil
    self:initParticle()
    self:initModelAnim()
end

function ClsU3dFollowParticle:initParticle()
	self.m_node = Node.create()
    self.m_parent_node:addChild(self.m_node)
	if self.m_cfg.res then
		self.m_particle = ParticleSystem.new(string.format("%s%s%s", EFFECT_PATH, self.m_cfg.res, PARTICLE_3D_EXT))
		self.m_node:addChild(self.m_particle:GetNode())
		self.m_particle:Start()
	end 

	if self.m_params.follow_node then
		self:addUpdateTimer()
	end
end

function ClsU3dFollowParticle:addUpdateTimer()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	local transform = self.m_cfg.transform
	
	local local_rotate_vec4 = Quaternion.new(unpack(transform.rotation))
	local rotate180_vec4 = Quaternion.new(Vector3.new(0, 1, 0), math.rad(-180))
	
	local function updateTimer()
		local node_vec3 = self.m_params.follow_node:getTranslation()
		self:setTranslation(node_vec3:x(), node_vec3:y(), node_vec3:z())
		
		local org_rotate_vec4 = self.m_params.follow_node:getRotation()
		local follow_rotate_vec4 = Quaternion.new(org_rotate_vec4:x(), org_rotate_vec4:y(), org_rotate_vec4:z(), org_rotate_vec4:w())
		follow_rotate_vec4:multiply(rotate180_vec4)
		self:setRotation(follow_rotate_vec4:x(), follow_rotate_vec4:y(), follow_rotate_vec4:z(), follow_rotate_vec4:w())
	end
	self.m_update_timer_hamder = scheduler:scheduleScriptFunc(updateTimer, 0.01, false)
	updateTimer()
	
	self.m_particle:GetNode():setScale(unpack(transform.scale))
	self.m_particle:GetNode():setTranslation(unpack(transform.position))
	
	local follow_scale_vec3 = self.m_params.follow_node:getScale()
	self.m_node:setScale(follow_scale_vec3:x(), follow_scale_vec3:y(), follow_scale_vec3:z())
	
	self.m_particle:GetNode():setRotation(local_rotate_vec4:x(), local_rotate_vec4:y(), local_rotate_vec4:z(), local_rotate_vec4:w())
end

function ClsU3dFollowParticle:release()
	self.m_params = nil
	if self.m_update_timer_hamder then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_update_timer_hamder)
	end
end

return ClsU3dFollowParticle