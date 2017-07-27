-- 所有的3D 模型基类
-- 基础属性，如光照、贴图、流光等

require("resource_manager")
local model_info = require("game_config/model_info")
local boat_info = require("game_config/boat/boat_info")

local ClsModel3d = class("ClsModel3d")


function ClsModel3d:ctor(param)
	self.is_ship = param.is_ship or false       -- 是否船模型
	self.star_level = param.star_level or 1 -- 星级
	self.path = param.path 
	self.node_name = param.node_name
	self.id = param.id 
	self.cur_flow = nil
	self.material = param.material

	local gpb_name = string.format("%s%s/%s.gpb",self.path, self.node_name, self.node_name)

	self.node = ResourceManager:LoadModel(gpb_name, self.node_name)
	local parent = param.parent
	parent:addChild(self.node)
	
	self.animation = self.node:getAnimation("animations")
	
	if self.material then 
		self:setMaterial(self.material)
	else
		self:updateStatus(self.star_level)
	end 
end 

function ClsModel3d:updateStatus(star_level)
	local model_cfg = model_info[self.node_name]
	if model_cfg == nil then return end 
	
	if self.is_ship then 
		local light_folder = model_cfg["low_lightmap"]     --默认光
		local boat_base = boat_info[self.id]
		
		if boat_base.bt_color_res and boat_base.bt_color_res[star_level] then
			local flow = boat_base.bt_color_res[star_level].flow 
			local texture = boat_base.bt_color_res[star_level].texture
			local light = boat_base.bt_color_res[star_level].light

			local flow_name = "default"
			if flow and flow ~= "" then
				flow_name = model_cfg[flow] 
			end
			self:setFlowState(flow_name)

			if texture and texture ~= "" then
				local texture_tab = model_cfg[texture]
				if texture_tab then 
					self.unbroken_tex_res = string.format("%s%s/%s.fbm/%s_%0.3d.png", self.path, self.node_name, self.node_name, self.node_name, texture_tab[1])
					self.broken_tex_res = string.format("%s%s/%s.fbm/%s_%0.3d.png", self.path, self.node_name, self.node_name, self.node_name, texture_tab[2])
					self:changeTexture(self.unbroken_tex_res)
				end 
			end
			
			if light and light ~= "" then 
				light_folder = model_cfg[light]
			end 
		end
		self:mappingLight(light_folder)
		
	else 
		-- 流光
		local flow_name = model_cfg["flow"]
		if flow_name and flow_name ~= "" then 
			self:setFlowState(flow_name)
		end 
		
		-- 光照
		local light_folder = model_cfg["low_lightmap"]
		self:mappingLight(light_folder)
		
		-- 特效
		local effect_name = model_cfg["effect"]
		if effect_name and effect_name ~= "" then 
			self:initEffect(effect_name)
		end 
	end 
end 

function ClsModel3d:resetStatus()
	self:updateStatus(self.star_level)
end 

local material_param_value_type = 
{
	u_texSpeed = "Vector4",
	u_mainIntensity = "number",
	u_mainColor = "Vector4",
	u_diffuseTextureST = "Vector4",
	u_diffuseTexture = "texture",
	u_maskTexST = "Vector4",
	u_maskTex = "texture",
	u_flowTexColor = "Vector4",
	u_flowTexST = "Vector4",
	u_flowTex = "texture",
	u_flowIntensity = "number",
	cullFace = "renderstate",
	depthTest = "renderstate",
	blend = "renderstate",
	blendSrc = "renderstate",
	blendDst = "renderstate",
}

function ClsModel3d:setFlowStateParam(tech, param)
	local material = self.node:getModel():getFirstMaterial()
	local technique = self:getTechnique(tech)
	local pass = technique:getPass("texture_flow")
	if not pass then return end 
		
	for k, v in pairs(param) do 
		local para = pass:getParameter(k)
		if para then 
			local value_type = material_param_value_type[k]
			if value_type == "Vector4" then 			
				para:setValue(Vector4.new(v[1], v[2], v[3], v[4]))
			elseif value_type == "Vector3" then 
				para:setValue(Vector3.new(v[1], v[2], v[3]))
			elseif value_type == "number" then 
				para:setValue(v)
			elseif value_type == "texture" then 
				local samplername = v.path 
				if string.find(v.path, ".png") then
					local model_path = SHIP_3D_PATH
					if not self.is_ship then 
						model_path = MODEL_3D_PATH 
					end 
					samplername = get3DSamplePath(model_path, self.node_name, v.path)
				end 

				local sampler = para:setValue(samplername, v.mipmap == "true")
				if sampler then
					sampler:setWrapMode(v.wrapS, v.wrapT);
					sampler:setFilterMode(v.minFilter, v.magFilter);
				end
			elseif value_type == "renderstate" then 
				pass:getStateBlock():setState(k, v)
			end
		end
	end
end

function ClsModel3d:setFlowState(name)
	if not name or name == "" then return end
	local material = self.node:getModel():getFirstMaterial()
	local model_flow = require("game_config/model_flow/"..name)
	if model_flow then 
		self.cur_flow = name
		local param = model_flow[name]
		if param then 
			local tech = material:getTechnique():getId()
			self:setFlowStateParam(tech, param)
		end
	end	
end

function ClsModel3d:getCurFlowState()
	return self.cur_flow
end

function ClsModel3d:setMaterial(path)
	self.material = path
	local material_ext = nil
	local define_ext = nil
	
	if self.node:getModel():getSkin() then 
		material_ext = string.format("%sskinning.material", MATERIAL_PATH)
		local skin_count = self.node:getModel():getSkin():getJointCount()
		if skin_count > 64 then 
			local str = string.format("%s SKINNING_JOINT_COUNT > 64", path)
			assert(false, str)
		end
		define_ext = string.format("SKINNING;SKINNING_JOINT_COUNT %d", skin_count)
	end 
	
	self.node:getModel():setMaterialExt(path, material_ext, define_ext)
end 

function ClsModel3d:getMaterial()
	return self.material
end 

function ClsModel3d:setTechnique(id)
	local material = self.node:getModel():getFirstMaterial()
	material:setTechnique(id)
end

function ClsModel3d:getTechnique(id)
	local material = self.node:getModel():getFirstMaterial()
	return material:getTechnique(id)
end

function ClsModel3d:changeTexture(path)
	local model = self.node:getModel()
	local material = model:getFirstMaterial()
	local parameter = material:getParameter("u_diffuseTexture")
	local sampler = parameter:getSampler(0)
	local lastPath = sampler:getTexture():getPath()
	if path == lastPath then 
		return 
	end 
	parameter:setValue(path, false)
end

function ClsModel3d:mappingLight(folder)
	if not folder or folder == '' then return end
	
	local path = string.format("scripts/game_config/lighting/%s/light_mapping", folder)
	local lightmap = require(path)
	if not lightmap then
		assert(false, path .. "is not exist")
		return 
	end 
	local model = self.node:getModel()
	local material = model:getFirstMaterial()			
	local light_config = lightmap[self.node_name]
	local tech = material:getTechnique()
	
	if light_config then 
		local offset = light_config.offset
		local index = light_config.index
		for i = 0, tech:getPassCount() - 1 do
			local pass = tech:getPassByIndex(i)
			local lightmap_name = string.format("res/lightmapping_3d/%s/LightmapFar-%d.png",folder, index)
			local sampler = pass:getParameter("u_lightmapTexture"):setValue(lightmap_name, true)

			local lightmap_st = Vector4.new(unpack(offset))
			if sampler then
				sampler:setWrapMode( "REPEAT", "REPEAT" )
				sampler:setFilterMode( "LINEAR_MIPMAP_LINEAR", "LINEAR")
			end
			pass:getParameter("u_lightmapST"):setValue(lightmap_st)
			--TODO:写死4.5,应该在客户端基础上让美术可调，或者unity工具提供参数可调
			pass:getParameter("u_lightmapIntensity"):setValue(4.5)
		end
	else
		for i = 0, tech:getPassCount() - 1 do
			local pass = tech:getPassByIndex(i)
			local sampler = pass:getParameter("u_lightmapTexture"):setValue("WHITE", true)
			local lightmap_st = Vector4.new(1,1,0,0)
			pass:getParameter("u_lightmapST"):setValue(lightmap_st)
			pass:getParameter("u_lightmapIntensity"):setValue(1.0)
			if sampler then
				sampler:setWrapMode( "REPEAT", "REPEAT" )
				sampler:setFilterMode( "LINEAR_MIPMAP_LINEAR", "LINEAR")
			end
		end
	end
end

function ClsModel3d:initEffect(effect_name)
	if self.effect_control == nil then
		self.effect_control = require( "gameobj/effect/effect" ).new(self.node)
	end
	
	self.effect_control:preload(string.format("%s%s.modelparticles", EFFECT_3D_PATH, effect_name))
	self.effect_control:showAll(self.node)
end 

function ClsModel3d:playAnimation(name, is_repeat, cross_fade)
	if not self.animation then return end
	if self.cur_ani_name == name then 
		return 
	end 
	self.cur_ani_name = name 
    local clip = self.animation:getClip(name)
	if not clip then return end

	if is_repeat then
		clip:setRepeatCount(0)
	else
		clip:setRepeatCount(1)
	end
	
    if self.cur_ani then
    	if not cross_fade then
	   		clip:play()
	   	else
	   		self.cur_ani:crossFade(clip, 300)
	   	end
    else
        clip:play()
    end
	self.cur_ani = clip
end

function ClsModel3d:getNode()
    return self.node
end

function ClsModel3d:release()
	if self.effect_control then
		self.effect_control:release()
		self.effect_control = nil
	end
	
	if self.node:getParent() then 
		self.node:getParent():removeChild(self.node)
	end 
	
	if self.cur_ani then
		self.cur_ani:stop()
		self.cur_ani = nil
	end 
	self.node = nil
	self.animation = nil	
end 

return ClsModel3d