-- 探索3d 初始化相关内容
require("gameobj/battle/cameraFollow")
local Game3d = require("game3d")

Explore3D = {}

function Explore3D:initScene3D(cocosLayer)
	self.cocosLayer = cocosLayer
	
	local scene_id = SCENE_ID.EXPLORE
    local layer_sea_id = 0
    local layer_ship_id = 10
	
	-- scene
	Game3d:createScene(scene_id)
	-- layerSea
	Game3d:createLayer(scene_id, layer_sea_id, cocosLayer, 0)
	-- layerShip
	Game3d:createLayer(scene_id, layer_ship_id, cocosLayer, 15)
    
	self.scene3d = Game3d:getScene(scene_id)
    self.layer3d_sea = Game3d:getLayer3d(scene_id, layer_sea_id)
	self.layer3d_ship = Game3d:getLayer3d(scene_id, layer_ship_id)
	
	CameraFollow:init(scene_id, cocosLayer, display.width, display.height)
	-- 无限大
	CameraFollow:IgnoreBound(true)

	self.is_start = true 
	isExplore = true 
end

function Explore3D:getLayerSea3d()
	return self.layer3d_sea
end 

function Explore3D:getLayerShip3d()
	return self.layer3d_ship
end

function Explore3D:getScene()
	return self.scene3d
end 

function Explore3D:removeScene3D()
	if self.is_start then 
		CameraFollow:Release3dCamera()
		self.cocosLayer:removeScene3D()
		CameraFollow.cocosLayer = nil
		self.cocosLayer = nil 
		self.layer3d_ship = nil
		self.layer3d_sea = nil
		self.scene3d = nil
		self.is_start = false
		Game3d:releaseScene(SCENE_ID.EXPLORE)
		
		isExplore = false
	end 
end 


function Explore3D:updateScene3D(elapsedTime)
	local dt = elapsedTime/1000
	if self.cocosLayer.player_ship then
		self.cocosLayer.player_ship:update(dt)
		CameraFollow:update(self.cocosLayer.player_ship)
	end
end


function Explore3D:clickObject(x, y)
	local viewport = Game.getInstance():getViewport()
	x = viewport:width()  / (display.cx * 2) * x
	y = viewport:height() / (display.cy * 2) * y
	y = y + viewport:y()
	x = x + viewport:x()
	y = display.heightInPixels - y
    local ray = Ray.new()
    self.scene3d:getActiveCamera():pickRay(viewport, x, y, ray)
    local distance = ray:intersects(Plane.new(0, 1, 0, 0))
    if distance ~= Ray.INTERSECTS_NONE() then
        local  result = PhysicsController.HitResult.new()
        if Game.getInstance():getPhysicsController():rayTest(ray, distance, result) then 
            return result:object():getNode()
        end 
    end 
end
