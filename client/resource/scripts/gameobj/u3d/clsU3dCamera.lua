--2016/09/06
--create by wmh0497
--用于模型的

local ClsModel3D = require("gameobj/model3d")
local ClsU3dNodeBase = require("gameobj/u3d/clsU3dNodeBase")
local ClsU3dAnimationParse = require("gameobj/u3d/u3dAnimationParse")

local ClsU3dCamera = class("ClsU3dCamera", ClsU3dNodeBase)

--[[ params:
node_path_str = "root/11/33"
root_anim_cfg = "boat03"
--]]
function ClsU3dCamera:init()
    self.m_type = "camera"
    self.m_camera = nil
    self:initCamera()
end

function ClsU3dCamera:initCamera()
    local camera
    if self.m_cfg.cameraType == "Orthographic" then 
        local camera_width = display.width
        local camera_height = display.height
        local near_plane = self.m_cfg.nearClipPlane
        local far_plane = self.m_cfg.farClipPlane
        camera = Camera.createOrthographic(camera_width, camera_height, display.width / display.height, near_plane, far_plane)
    else 
        local near_plane = self.m_cfg.nearClipPlane
        local far_plane = self.m_cfg.farClipPlane
        local aspect = self.m_cfg.aspect
        local field = self.m_cfg.fieldOfView
        camera = Camera.createPerspective(field, display.width / display.height, near_plane, far_plane)
    end 
    
    self.m_node = Node.create()
    self.m_node:setCamera(camera)
    self.m_parent_node:addChild(self.m_node)
    
    local transform = self.m_cfg.transform
    if transform then 
        self:setScale(unpack(transform.scale))
        self:setRotation(unpack(transform.rotation))
        self:setTranslation(unpack(transform.position))
    end
    self:initModelAnim()
    
    self.m_camera = camera
end

function ClsU3dCamera:setActiveCamera()
	local scene = self.m_params.scene
    scene:setActiveCamera(self.m_camera)
end

function ClsU3dCamera:playAnimation(is_repeat)
    for key, animation in pairs(self.m_animations) do
        local clip = animation:getClip()
        if is_repeat then
            clip:setRepeatCount(0)
        else
            clip:setRepeatCount(1)
        end
        if clip:isPlaying() then
            clip:stop()
        end
        clip:play()
    end
    -- self:initModelAnim()
end

return ClsU3dCamera