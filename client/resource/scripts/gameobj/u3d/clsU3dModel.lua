--2016/09/06
--create by wmh0497
--用于模型的

local ClsModel3D = require("gameobj/model3d")
local ClsU3dNodeBase = require("gameobj/u3d/clsU3dNodeBase")
local ClsU3dAnimationParse = require("gameobj/u3d/u3dAnimationParse")

local ClsU3dModel = class("ClsU3dModel", ClsU3dNodeBase)

--[[ params:
node_path_str = "root/11/33"
root_anim_cfg = "boat03"
--]]
function ClsU3dModel:init()
    self.m_type = "model"
    self.m_body = nil
    self.m_material_name_str = nil
    self:initModel()
	self:initModelAnim()
end

function ClsU3dModel:initModel()
    self.m_node = Node.create()
    self.m_parent_node:addChild(self.m_node)
    if self.m_cfg.materials and #self.m_cfg.materials > 0 then
        --先注释掉，不用原来的方法
        self.m_body = ClsModel3D.new({path = MODEL_PATH, node_name = self.m_cfg.res, parent = self.m_parent_node, 
            material = string.format("%s%s.material", MATERIAL_PATH, self.m_cfg.materials[1])})
        self.m_material_name_str = self.m_cfg.materials[1]
        local node = self.m_body:getNode()
        local axis = node:getUpVector()
        node:setRotation(axis, math.rad(-180))
        node:setScale(1,1,1)
        node:setTranslation(0,0,0)
        self:initCollision()
        self.m_node:addChild(node)
    end 
    
    local transform = self.m_cfg.transform
    if transform then 
        self:setScale(unpack(transform.scale))
        self:setRotation(unpack(transform.rotation))
        self:setTranslation(unpack(transform.position))
    end
    
end

function ClsU3dModel:initCollision()
end

function ClsU3dModel:setMaterial(material_name_str)
    if self.m_material_name_str == material_name_str then return end
    
    if self.m_body then
        local material_path = string.format("%s%s.material", MATERIAL_PATH, material_name_str)
        self.m_body:setMaterial(material_path)
        self.m_material_name_str = material_name_str
    end
end

function ClsU3dModel:setTag(tag_str, value_str)
    if self.m_node then
        self.m_node:setTag(tag_str, value_str)
    end
end

function ClsU3dModel:setAngle(angle)
    if not self.m_node then return end
    local axis = vector or self.m_node:getUpVector()
    self.m_node:setRotation(axis, math.rad(-angle))
end 

function ClsU3dModel:playAnimation(name, is_repeat, cross_fade)
    local node = self.m_node
    if self.m_body then
        node = self.m_body:getNode()
    end
    local animations = node:getAnimation("animations")
    if not animations then return end
    
    if self.m_anim_name_str == name and self.m_cur_ani:isPlaying() then
        return
    end
    
    local clip = animations:getClip(name)
    if not clip then return end

    self.m_anim_name_str = name
    if is_repeat then
        clip:setRepeatCount(0)
    else
        clip:setRepeatCount(1)
    end
    
    if self.m_cur_ani and self.m_cur_ani:isPlaying() then
        if not cross_fade then
            self.m_cur_ani:stop()
            clip:play()
        else
            self.m_cur_ani:crossFade(clip, 300)
        end
    else
        clip:play()
    end
    self.m_cur_ani = clip
end

function ClsU3dModel:isPlayAnimation(name)
    if (self.m_anim_name_str == name) and self.m_cur_ani and self.m_cur_ani:isPlaying() then
        return true
    end
    return false
end

function ClsU3dModel:isPlayAnimationEnd(name)
    if (self.m_anim_name_str == name) and self.m_cur_ani and (not self.m_cur_ani:isPlaying()) then
        return true
    end
    return false
end

return ClsU3dModel