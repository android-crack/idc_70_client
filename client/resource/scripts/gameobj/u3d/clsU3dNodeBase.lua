--2016/09/06
--create by wmh0497
--用于模型基类
local ClsU3dAnimationParse = require("gameobj/u3d/u3dAnimationParse")

local ClsU3dNodeBase = class("ClsU3dNodeBase")

function ClsU3dNodeBase:ctor(parent_node, name_str, cfg, params)
    self.m_type = nil
    self.m_name_str = nil
    self.m_node = nil
    self.m_body = nil
    self.m_cfg = cfg
    self.m_name_str = name_str
    self.m_params = params
    self.m_parent_node = parent_node
    self.m_child_nodes = {}
    self.m_clip_name = nil
    self.m_load_clip_animation = false
    
    self.m_animations = {}
    self.m_animations_reset_info = nil
    self:init()
end

--重载这个方法初始化
function ClsU3dNodeBase:init()
end

function ClsU3dNodeBase:getName()
    return self.m_name_str
end

function ClsU3dNodeBase:getType()
    return self.m_type
end

function ClsU3dNodeBase:getNode()
    return self.m_node
end

function ClsU3dNodeBase:setScale(x,y,z)
    if self.m_node then
        self.m_node:setScale(x,y,z)
    end
end

function ClsU3dNodeBase:setRotation(x,y,z,w)
    if self.m_node then
        self.m_node:setRotation(x,y,z,w)
    end
end

function ClsU3dNodeBase:setTranslation(x,y,z)
    if self.m_node then
        self.m_node:setTranslation(x,y,z)
    end
end

function ClsU3dNodeBase:setActive(is_active)
    if self.m_node then
        self.m_node:setActive(is_active)
    end
end

function ClsU3dNodeBase:initModelAnim()
    local params = {}
    if self.m_node and self.m_params.root_anim_cfg then
        local anim_cfg = require(string.format("game_config/u3d_data/u3d_anim/%s", self.m_params.root_anim_cfg))
        local anim_data = anim_cfg[self.m_params.node_path_str]
        if anim_data then
            params.is_loop = anim_cfg.loop
            params.type = self:getType()
            params.body = self.m_body
            self.m_animations = {}
            self.m_animations_reset_info = ClsU3dAnimationParse:loadAnimation(self.m_node, anim_data, self.m_animations, params)
        end
    end
end

function ClsU3dNodeBase:resetU3dCfgAnimation()
    if self.m_node and self.m_animations_reset_info then
        
        if self.m_animations then
            for _, animation in pairs(self.m_animations) do
                local clip = animation:getClip(self.m_clip_name)
                if clip:isPlaying() then
                    clip:stop()
                end
            end
        end
    
        local transform_cfg = self.m_animations_reset_info.transform
        --位置
        local p_x = transform_cfg.PositionX
        local p_y = transform_cfg.PositionY
        local p_z = transform_cfg.PositionZ
        if p_x or p_y or p_z then
            local pos_vec3 = self.m_node:getTranslation()
            p_x = p_x or pos_vec3:x()
            p_y = p_y or pos_vec3:y()
            p_z = p_z or pos_vec3:z()
            self:setTranslation(p_x, p_y, p_z)
        end
        
        --缩放
        local s_x = transform_cfg.ScaleX
        local s_y = transform_cfg.ScaleY
        local s_z = transform_cfg.ScaleZ
        if s_x or s_y or s_z then
            local scale_vec3 = self.m_node:getScale()
            s_x = s_x or scale_vec3:x()
            s_y = s_y or scale_vec3:y()
            s_z = s_z or scale_vec3:z()
            self:setScale(s_x, s_y, s_z)
        end
        
        --旋转
        if transform_cfg.Rotation then
            self:setRotation(unpack(transform_cfg.Rotation))
        end
        
        local material_cfg = self.m_animations_reset_info.material
        if material_cfg.u_mainColor then
            self:setShaderParam("u_mainColor", Vector4.new(material_cfg.u_mainColor[1], material_cfg.u_mainColor[2], material_cfg.u_mainColor[3], material_cfg.u_mainColor[4]))
        end
        if material_cfg.u_flowTexColor then
            self:setShaderParam("u_flowTexColor", Vector4.new(material_cfg.u_flowTexColor[1], material_cfg.u_flowTexColor[2], material_cfg.u_flowTexColor[3], material_cfg.u_flowTexColor[4]))
        end
        if material_cfg.u_lightmapAlpha then
            self:setShaderParam("u_lightmapAlpha", material_cfg.u_lightmapAlpha)
        end
        if material_cfg.u_effectAlpha then
            self:setShaderParam("u_effectAlpha", material_cfg.u_effectAlpha)
        end
    end
end

function ClsU3dNodeBase:getTrueModelNode()
    local node = self.m_node
    if node then
        if self.m_body and self.m_body:getNode() then
            node = self.m_body:getNode()
        end
    end
    return node
end

function ClsU3dNodeBase:setShaderParam(key, value)
    local node = self:getTrueModelNode()
    if node then
        local param_handle = GetShaderParam(node, key, self:getType())
        if param_handle then 
            param_handle:setValue(value)
        end
    end
end

function ClsU3dNodeBase:playU3dCfgAnimationByClip(ani_name, clip_name)
    if not self.m_load_clip_animation then
        self.m_load_clip_animation = true
        local ani_file = string.format("%s%s%s", ANIMATION_PATH, ani_name, ANIMATION_3D_EXT)
        for _, animation in pairs(self.m_animations) do
            animation:createClips(ani_file)
        end
    end
    if not clip_name then
        self:resetU3dCfgAnimation()--先重置再赋值
        self.m_clip_name = clip_name 
    else
        self.m_clip_name = clip_name --先赋值再决定播放
        self:playU3dCfgAnimation()
    end
end

function ClsU3dNodeBase:getAnimationDuration(name)
	local duration = 0	
	for key, animation in pairs(self.m_animations) do
        local clip = animation:getClip(name)
        if clip then
            local dt = clip:getDuration()
			if dt > duration then 
				duration = dt
			end 
        end
    end
	return duration
end 

function ClsU3dNodeBase:playU3dCfgAnimation()
    for key, animation in pairs(self.m_animations) do
        local clip = animation:getClip(self.m_clip_name)
        if clip:isPlaying() then
            clip:stop()
        end
        clip:play()
    end
end

function ClsU3dNodeBase:stopU3dCfgAnimation()
    for key, animation in pairs(self.m_animations) do
        local clip = animation:getClip(self.m_clip_name)
        if clip:isPlaying() then
            clip:stop()
        end
    end
end

function ClsU3dNodeBase:addChildNode(key, node_obj)
    self.m_child_nodes[key] = node_obj
end

function ClsU3dNodeBase:getChildNode(key)
    return self.m_child_nodes[key]
end

function ClsU3dNodeBase:getAllChildNode()
    return self.m_child_nodes
end

function ClsU3dNodeBase:release()
end

return ClsU3dNodeBase