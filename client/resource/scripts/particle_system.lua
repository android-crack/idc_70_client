local ParticleSystem = class()
local particleSystemDataCache = {}

function ParticleSystem:ctor(file, t)
	self.file_path = file
	self.root_node = Node.create()
	self.root_node:setIdentity()
	self.emitters = {}
	self.model_nodes = {}
	if particleSystemDataCache[file] then
		for k, v in pairs(particleSystemDataCache[file]) do
			if v.type == "Model" then
				self:createEffectNodeFormTable(self.root_node, v)
			elseif v.type == "Emitter" then
				local emitterFileName = v["file"]
				local emitterOrder = v["order"]
				--local position = Vector3.new(v["position"]["x"], v["position"]["y"], v["position"]["z"])
				--local rotation = Vector4.new(v["rotate"]["x"], v["rotate"]["y"], v["rotate"]["z"], v["rotate"]["w"])
				local emitter =  ResourceManager:LoadParticleEmitter(emitterFileName, emitterOrder)
				local emitterNode = Node.create()
				self.root_node:addChild(emitterNode)
				self.root_node:setTranslation(Vector3.zero())
				emitterNode:setIdentity()
				--emitterNode:setTranslation(position)
				emitterNode:setTranslation(v["position"]["x"], v["position"]["y"], v["position"]["z"])
				--emitterNode:setRotation(rotation:x(), rotation:y(), rotation:z(), rotation:w())
				emitterNode:setRotation(v["rotate"]["x"], v["rotate"]["y"], v["rotate"]["z"], v["rotate"]["w"])
				emitterNode:setParticleEmitter(emitter)

				if v["not_scale_by_parent"] and v["not_scale_by_parent"] == 1 then
					emitterNode:setInheritedScale(false)
				end

				self.emitters[#self.emitters + 1] = emitter
			end
		end
	else
		local root = ResourceManager:LoadPropertiesFile(file)
		assert(root ~= nil, "ParticleSystem Load Properties File "..file.." Fail")
		local configs = root:getNamespace("ParticleSystem", true, false)
		configs:rewind()
		particleSystemDataCache[file] = {}
		while true do
			local emitterConfig = configs:getNextNamespace()
			if emitterConfig == nil then break end
			local config_data = {}
			if emitterConfig:getNamespace() == "Model" then --模型
				config_data["type"] = "Model"
				self:createEffectNode(self.root_node, emitterConfig, config_data)
			elseif emitterConfig:getNamespace() == "Emitter" then --特效
				config_data["type"] = "Emitter"
				local emitterFileName = emitterConfig:getPath("file")
				config_data["file"] = emitterFileName
				local emitterOrder = emitterConfig:getInt("order")
				config_data["order"] = emitterOrder
				local position = Vector3.new()
				local rotation = Vector4.new()
				emitterConfig:getVector3("position", position)
				emitterConfig:getVector4("rotate", rotation)
				config_data["position"] = {["x"] = position:x(), ["y"] = position:y(), ["z"] = position:z()}
				config_data["rotate"] = {["x"] = rotation:x(), ["y"] = rotation:y(), ["z"] = rotation:z(), ["w"] = rotation:w()}
				local emitter =  ResourceManager:LoadParticleEmitter(emitterFileName, emitterOrder)
				local emitterNode = Node.create()
				self.root_node:addChild(emitterNode)
				self.root_node:setTranslation(Vector3.zero())
				emitterNode:setIdentity()
				emitterNode:setTranslation(position)
				emitterNode:setRotation(rotation:x(), rotation:y(), rotation:z(), rotation:w())
				emitterNode:setParticleEmitter(emitter)

				config_data["not_scale_by_parent"] = emitterConfig:getInt("not_scale_by_parent")
				if config_data["not_scale_by_parent"] and config_data["not_scale_by_parent"] == 1 then
					emitterNode:setInheritedScale(false)
				end

				self.emitters[#self.emitters + 1] = emitter
			end
			table.insert(particleSystemDataCache[file], config_data)
		end
	end
	
	if t then 
		self:SetDuration(t)
	end
end

function ParticleSystem:createEffectNodeFormTable(parent, config)
	local model_name = config["model_name"]
	local animation_name = config["animation_name"] or "move"
	local action_name = config["action_name"]
	local liuguang_name = config["liuguang"]
	local not_scale_by_parent = config["not_scale_by_parent"]
	local fire_effect = config["fire_effect"]
	local body = nil
	if model_name and model_name ~= "" then
		local ClsModel3D = require("gameobj/model3d")
		body = ClsModel3D.new({path = MODEL_3D_PATH, node_name = model_name, parent = parent})
	else
		return
	end
	
	if fire_effect then
		local file = EFFECT_3D_PATH..fire_effect..MODELPARTICLE_EXT
		local effect_control = require( "gameobj/effect/effect" ).new(body.node)
		effect_control:preload( file )
		effect_control:showAll()
	end
	
	local node = body.node
	node:setIdentity()
	--local position = Vector3.new(config["position"]["x"], config["position"]["y"], config["position"]["z"])
	--node:setTranslation(position)
	node:setTranslation(config["position"]["x"], config["position"]["y"], config["position"]["z"])
	
	node:setScale(config["scale"] and config["scale"]["x"] or 1,
				  config["scale"] and config["scale"]["y"] or 1,
				  config["scale"] and config["scale"]["z"] or 1)
	
	--local rotate = Quaternion.new(config["rotate"]["x"], config["rotate"]["y"], 
	--							  config["rotate"]["z"], config["rotate"]["w"])
	--node:rotate(rotate)
	node:rotate(config["rotate"]["x"], config["rotate"]["y"], config["rotate"]["z"], config["rotate"]["w"])
	self.model_nodes[#self.model_nodes + 1] = node
	
	-- 处理动作
	if action_name and action_name ~= "" then
		local action_data = require(string.format("game_config/u3d_data/action/%s", action_name))
		require("module/u3dAnimationParse"):loadAnimation(body, action_data, false)
	end
	
	-- 流光
	if liuguang_name and liuguang_name ~= "" then 
		body:setFlowState(liuguang_name)
	end
	
	-- animation
	if animation_name then 
		body:playAnimation(animation_name, false)
	end 
	if tonumber(not_scale_by_parent) == 1 then
		node:setInheritedScale(false)
	end
end

function ParticleSystem:createEffectNode(parent, config, config_data)
	local model_name = config:getString("model_name")
	config_data["model_name"] = model_name
	local animation_name = config:getString("animation_name") or "move"
	config_data["animation_name"] = animation_name
	local action_name = config:getString("action_name")
	config_data["action_name"] = action_name
	local liuguang_name = config:getString("liuguang")
	config_data["liuguang"] = liuguang_name
	local not_scale_by_parent = config:getString("not_scale_by_parent")
	config_data["not_scale_by_parent"] = not_scale_by_parent
	local fire_effect = config:getString("fire_effect")
	config_data["fire_effect"] = fire_effect 
	local body = nil 
	if model_name and model_name ~= "" then 
		local ClsModel3D = require("gameobj/model3d")
		body = ClsModel3D.new({path = MODEL_3D_PATH, node_name = model_name, parent = parent})
	else 
		return
	end 
	if fire_effect then
		local file = EFFECT_3D_PATH..fire_effect..MODELPARTICLE_EXT

		
		local effect_control = require( "gameobj/effect/effect" ).new(body.node);
		
		effect_control:preload( file );
		
		effect_control:showAll()
	end

	local node = body.node
	node:setIdentity()
	local position = Vector3.new()
	config:getVector3("position", position)
	config_data["position"] = {["x"] = position:x(), ["y"] = position:y(), ["z"] = position:z()}
	node:setTranslation(position)
	
	local scale = Vector3.new(1,1,1)
	config:getVector3("scale", scale)
	config_data["scale"] = {["x"] = scale:x(), ["y"] = scale:y(), ["z"] = scale:z()}
	node:setScale(scale)
	
	local rotate = Quaternion.new()
	config:getQuaternionFromAxisAngle("rotate", rotate)
	config_data["rotate"] = {["x"] = rotate:x(), ["y"] = rotate:y(), ["z"] = rotate:z(), ["w"] = rotate:w()}
	node:rotate(rotate)
	self.model_nodes[#self.model_nodes + 1] = node
	
	-- 处理动作
	if action_name and action_name ~= "" then
		local action_data = require(string.format("game_config/u3d_data/action/%s", action_name))
		require("module/u3dAnimationParse"):loadAnimation(body, action_data, false)
	end
	
	-- 流光
	if liuguang_name and liuguang_name ~= "" then 
		body:setFlowState(liuguang_name)
	end
	
	-- animation
	if animation_name then 
		body:playAnimation(animation_name, false)
	end 
	if tonumber(not_scale_by_parent) == 1 then
		node:setInheritedScale(false)
	end
end


function ParticleSystem:GetNode()
	return self.root_node
end

function ParticleSystem:Show()
	self.root_node:setActive(true)
	self:Start()
end 

function ParticleSystem:Hide()
	self.root_node:setActive(false)
	self:Stop()
end 

function ParticleSystem:Start()
	if self.emitters == nil then return end 
	for k, v in ipairs(self.emitters) do
		v:start()
	end
end

function ParticleSystem:Stop()
	if self.emitters == nil then return end 
	for k, v in ipairs(self.emitters) do
		v:stop()
	end
end

--判断是否有粒子在发射
function ParticleSystem:IsPlaying()
	if self.emitters == nil then return end 
	for k, v in ipairs(self.emitters) do
		if v:isStarted() then 
			return true
		end
	end
	return false
end

--判断粒子是否存在
function ParticleSystem:IsParticleAlive()
	if self.emitters == nil then return end 
	for k, v in ipairs(self.emitters) do
		local count = v:getParticlesCount() 
		if count > 0 then
			return true 
		end 
	end
	return false
end

function ParticleSystem:Release(dt)
	if self.emitters == nil then return end 
	local duration = dt or 0.5
	
	local function release()
		local parent = self.root_node:getParent()
		if parent then 
			parent:removeChild(self.root_node)
		end 
		self.model_nodes = nil
		self.emitters = nil
		self.file_path = nil
		self.root_node = nil
	end 

	if #self.model_nodes > 0 then 
		for k ,v in ipairs(self.model_nodes) do
			Model3DFadeOut(v, duration)
		end 
		require("framework.scheduler").performWithDelayGlobal(release, duration)
	else
		release()
	end 	
end

function ParticleSystem:SetDuration(t)
	for k, v in ipairs(self.emitters) do
		v:setSystemDuration(t)
	end	
end

function ParticleSystem:GetDuration()
	local duration = 0
	for k, v in ipairs(self.emitters) do
		local t = v:getSystemDuration()
		if duration < t then 
			duration = t
		end 
	end
	return duration
end

function ParticleSystem:SetEndEvent(endEvent)
	self.endEvent = endEvent
end

function ParticleSystem:CheckParticleEndCall()
	if not self:IsParticleAlive() then
		if self.endEvent then
			self.endEvent()
		end
	end
end

return ParticleSystem
