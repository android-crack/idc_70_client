-- 3D UI摄像机相关

CameraUI = {}

function CameraUI:init(width, height, angleX)
	local cameraWidthZoom =  width or display.width
	local cameraHeightZoom =  height or display.height
	local cam = Camera.createOrthographic(cameraWidthZoom, cameraHeightZoom, display.width / display.height, 0, 5000)
	local scene3D = GetScene3D()
	local camNode = scene3D:addNode("camera")
    camNode:setCamera(cam)
    scene3D:setActiveCamera(cam)
    self.camera_node = scene3D:getActiveCamera():getNode()
	local angle = angleX or 30
	self.camera_node:rotateX(math.rad(-angle))
end

function CameraUI:Release()
	local scene3D = GetScene3D()
	scene3D:setActiveCamera(nil)
	scene3D:removeNode(self.camera_node)
	self.camera_node = nil
end
