-- 主场景3d 初始化相关内容

local Game3d = require("game3d")

local Main3d = {}

function Main3d:createScene(scene_id, width, height, angle)
	Game3d:createScene(scene_id)
	self:initCamera(scene_id, width, height, angle)
end 

function Main3d:initCamera(scene_id, width, height, angle)
	local camera_width =  width or display.width
	local camera_height =  height or display.height
	local cam = Camera.createOrthographic(camera_width, camera_height, display.width / display.height, 0, 5000)
	local scene = Game3d:getScene(scene_id)
	local cam_node = scene:addNode("camera")
    cam_node:setCamera(cam)
    scene:setActiveCamera(cam)
    local camera_node = scene:getActiveCamera():getNode()
	local angle = angleX or 30
	camera_node:rotateX(math.rad(-angle))
end 

function Main3d:removeScene(scene_id)
	Game3d:releaseScene(scene_id)
end

return Main3d