local model_info = require("game_config/model_info")

local ParticleSystem = require("particle_system")

ResourceManager = {
	models = {},
	--particleSystems = {},
	compositeEffects = {},
    emitters = {},
	propertiesFiles = {},
	extralight = {},
	textures = {}
}

ResourceManager.debug_mode = false

local texture_shader =  MODEL_3D_PATH.."texture.material"
local texture_flow_shader =  MODEL_3D_PATH.."texture_flow.material"
local texture_flow_light_shader =  MODEL_3D_PATH.."texture_flow_light.material"
local texture_light_shader =  MODEL_3D_PATH.."texture_light.material"

local texture_skin_shader =  MODEL_3D_PATH.."texture_skin.material"
local texture_skin_flow_shader =  MODEL_3D_PATH.."texture_skin_flow.material"
local texture_skin_flow_light_shader =  MODEL_3D_PATH.."texture_skin_flow_light.material"
local texture_skin_light_shader =  MODEL_3D_PATH.."texture_skin_light.material"

local ship_shader = SHIP_3D_PATH.."shipModel.material"
local zhaozi02_shader = MODEL_3D_PATH.."zhaozi02Model.material"

local SKINNING = "SKINNING;SKINNING_JOINT_COUNT 64"


-- 特殊处理
local materialTab = {
	["ship"] = {shader = ship_shader , define = SKINNING},
	["zhaozi"] = {shader = "", define = ""},
	["zhaozi02"] = {shader = zhaozi02_shader, define = ""},
	["tiegou1"] = {shader = "", define = ""},
	["plane001"] = {shader = "", define = ""},
}

local function getMaterial(filename, node_name)
    local is_ship = filename:find("ship_3d")
	if is_ship then 
		node_name = "ship"
	end 
	local material = materialTab[node_name]
	if material then 
		return material
	end 
	
	local model_cfg = model_info[node_name]
	if model_cfg == nil then 
		return {shader = "" , define = ""}
	end 
	
	-- 有骨骼
	if model_cfg.skinning == 1 then
		if model_cfg.low_lightmap ~= "" then 
			if model_cfg.flow ~= "" then 
				return {shader = texture_skin_flow_light_shader , define = SKINNING}
			else 
				return {shader = texture_skin_light_shader , define = SKINNING}
			end 
		else 
			if model_cfg.flow ~= "" then 
				return {shader = texture_skin_flow_shader , define = SKINNING}
			else 
				return {shader = texture_skin_shader , define = SKINNING}
			end 
		end 
	else 
		if model_cfg.low_lightmap ~= "" then 
			if model_cfg.flow ~= "" then 
				return {shader = texture_flow_light_shader , define = ""}
			else 
				return {shader = texture_light_shader , define = ""}
			end 
		else 
			if model_cfg.flow ~= "" then 
				return {shader = texture_flow_shader , define = ""}
			else 
				return {shader = texture_shader , define = ""}
			end 
		end 
	end
	
	return {shader = texture_shader , define = ""} 	
end

function ResourceManager:printCacheFilename(file_name, file_type)
	if not self.debug_mode then return end

	local str = string.format("==========ResourceManager Cache========== file_name:%s, file_type:%s", file_name, file_type)

	print(str)
end

function ResourceManager:CacheTexute3d(filename)
	self:printCacheFilename(filename, "texture3d")

	self.textures[#self.textures + 1] = Texture.create(filename, true)
end

function ResourceManager:CacheModel(filename, nodeName)
	self:printCacheFilename(filename, "model")

	-- 模型不存在，用cube代替
	if not FileSystem.fileExists(filename) then 
		nodeName = "Cube"
		filename = string.format("%s%s/%s.gpb", MODEL_PATH, nodeName, nodeName)
	end 
	
	local material = getMaterial(filename, nodeName)
	local key = filename..":"..nodeName
	
	local bundle = Bundle.create(filename)	
    bundle:setExtModelMaterial(material.shader, material.define)
	local node = bundle:loadNode(nodeName)
   	self.models[key] = node
	local model_cfg = model_info[nodeName]
	
	if model_cfg and model_cfg.scale then 
		node:setScale(unpack(model_cfg.scale))
	end 
	
    if model_cfg and model_cfg.ani_model ~= '' then
		local ani_model = model_cfg.ani_model
		local ani_file = model_cfg.ani_file
		ani_model = string.format("%s%s%s", ANI_3D_PATH,ani_model,GPB_EXT)
		ani_file = string.format("%s%s%s", ANI_3D_PATH,ani_file, ANIMATION_3D_EXT)
        self:CacheAnimation(filename, nodeName, node, ani_model, ani_file)
    else
        local  _animation = node:getAnimation("animations")
        if _animation then 
            local ani_file = string.gsub(filename, GPB_EXT, ANIMATION_3D_EXT)
            _animation:createClips(ani_file)
        end
    end

	return self.models[key]
end

function ResourceManager:CacheAnimation(filename, nodeName, replace_node, ani_model, ani_file)
	self:printCacheFilename(filename, "animation")

    local newAnimation = nil
    local bone_bundle = Bundle.create(ani_model) 
    local bone_node = bone_bundle:loadNode("Bip001")
    local bone_animation = bone_node:getAnimation("animations")
	
    if bone_animation then
		bone_animation:createClips(ani_file)
		newAnimation = replace_node:getModel():getSkin():addSkeletonAnimation(bone_animation)
		bone_node = nil
		return newAnimation
	else
		echoError("the animation gpb file(%s) has not animation", ani_model)
	end
end

function ResourceManager:CacheParticleEmitter(filename, order)
	self:printCacheFilename(filename, "particle_emitter")

	self.emitters[filename] = ParticleEmitter.create( filename, order )
	return self.emitters[filename]
end

function ResourceManager:CachePropertiesFile(filename)
	self:printCacheFilename(filename, "properties_file")

	self.propertiesFiles[filename] = Properties.create(filename)
	return self.propertiesFiles[filename]
end


function ResourceManager:LoadModel(filename, nodeName)
	local key = filename..":"..nodeName
	local modelNode = self.models[key]
	
	if modelNode == nil then
		modelNode = ResourceManager:CacheModel(filename, nodeName)
	end 
	
	if modelNode ~= nil then 
		modelNode = modelNode:clone()
	end
	
	return modelNode
end


function ResourceManager:LoadParticleEmitter(filename, order)
	local cache = self.emitters[filename]
	if cache == nil then 
		cache = ResourceManager:CacheParticleEmitter(filename, order)
	end 
	
	if cache ~= nil then 
		--TODO: order?
		cache = cache:clone()
	end
	return cache
end

function ResourceManager:LoadCompositeEffect(filename, target)
	local cache = self.compositeEffects[filename]
	
	if cache == nil then
		cache = ResourceManager:CacheCompositeEffect(filename)
	end 
	
	if cache ~= nil then
		--TODO:order?
		cache = cache:clone()
	end
	
	if target then 
		cache:setTarget(target)
	end
	return cache
end


function ResourceManager:LoadPropertiesFile(filename)
	local cacheFile = self.propertiesFiles[filename]
	if cacheFile == nil then
		cacheFile = ResourceManager:CachePropertiesFile(filename)
	end 
	
	if cacheFile ~= nil then
		cacheFile = cacheFile:clone()
	end
	return cacheFile
end


function ResourceManager:ClearCache()
	self.models = {}
	--self.particleSystems = {}
	self.compositeEffects = {}
	self.propertiesFiles = {}
    self.emitters = {}
	self.textures = {}
end
