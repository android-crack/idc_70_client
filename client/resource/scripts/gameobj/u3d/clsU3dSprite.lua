--2016/09/06
--create by wmh0497
--用于模型的

local ClsModel3D = require("gameobj/model3d")
local ClsU3dNodeBase = require("gameobj/u3d/clsU3dNodeBase")
local ClsU3dAnimationParse = require("gameobj/u3d/u3dAnimationParse")

local ClsU3dSprite = class("ClsU3dSprite", ClsU3dNodeBase)

function ClsU3dSprite:init()
    self.m_type = "sprite"
    self:initModel()
end

function ClsU3dSprite:initModel()
    local width = self.m_cfg.width
    local height = self.m_cfg.height
    local pivot = self.m_cfg.pivot or {0, 0}
    local img_str = self.m_cfg.sprite
    local material_str = self.m_cfg.material or "sprite"

    -- uv 设置
    local s1, t1 = 0, 0   -- uv
    local s2, t2 = 1, 1
    if self.m_cfg.flipX then 
        s1, s2 = s2, s1
    end 
    if self.m_cfg.flipY then 
        t1, t2 = t2, t1
    end 

    local mesh = Mesh.createQuad(-1*pivot[1] , -1*pivot[2], width, height, s1, t1, s2, t2)
    mesh:setBoundingBox(BoundingBox.new(-width/2, -height/2, 1, width/2, height/2 , 1))
    mesh:setBoundingSphere(BoundingSphere.new(Vector3.zero(), width));
    local model = Model.create(mesh)

    local material_path_str = string.format("%s%s.material", MATERIAL_PATH, material_str)
    local material = Material.create(material_path_str)
    model:setMaterial(material) 

    if img_str and img_str ~= "" then 
        local image_path_str = string.format("%s%s.png", TEXTURE_PATH, img_str)
        material:getParameter("u_diffuseTexture"):setValue(image_path_str, false)
    end

    self.m_node = Node.create()
    self.m_node:setModel(model)
    self.m_parent_node:addChild(self.m_node)
    
    local transform = self.m_cfg.transform
    if transform then 
        self:setScale(unpack(transform.scale))
        self:setRotation(unpack(transform.rotation))
        self:setTranslation(unpack(transform.position))
    end
    
end

return ClsU3dSprite