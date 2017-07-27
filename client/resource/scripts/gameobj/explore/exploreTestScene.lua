--探索测试用的
local ExploreTest = class("ExploreTest")

function ExploreTest:ctor()
	self.ship_pool = {}
	--self:createCD()
end

function ExploreTest:createShip() 
	
	local ship_pos = {}
	local function getPos()
		local px, py = getExploreLayer().player_ship:getPos()
		for i = 0, 7 do   -- 尝试每个位置
			local angle = 45
			local xAngle = angle + i * angle
			local x = 300 * math.sin(math.rad(xAngle)) + px
			local y = 300 * math.cos(math.rad(xAngle)) + py
			ship_pos[i] = ccp(x, y)
		end
	end
	getPos()
	--local testid = {sea_coral = "sea_coral", ex_ice = "ex_ice", sea_shark = "sea_shark", ex_mermaid = "ex_mermaid", ex_box = "ex_box"}
	local testid = {ex_fat = "ex_fat", ex_rock = "ex_rock"}
	--local testid = {sea_shark = "sea_shark", ex_box = "ex_box", sea_shipwreck = "sea_shipwreck", ex_monster = "ex_monster"}
	local testid = {bt_base_001 = "bt_base_001"}
	local index = 1
	for file_name, name in pairs(testid) do
		local gpb_name = string.format("%s%s/%s.gpb", MODEL_3D_PATH, file_name, file_name)
		local node_name = string.format("%s", name)
		local node = ResourceManager:LoadModel(gpb_name, node_name, true, true)
		local pos = ship_pos[index] 
		pos = CameraFollow:cocosToGameplayWorld(pos)
		node:setTranslation(pos)
		local layer3dShip = Explore3D:getLayerShip3d()
		self.ship_pool[#self.ship_pool + 1] = node
		layer3dShip:addChild(node)
		index = index + 1
	end
end

function ExploreTest:createCD()   
	local scheduler = CCDirector:sharedDirector():getScheduler()
	
	local function doStep(dt)
		self:update(dt)
	end
	self.effect_time = scheduler:scheduleScriptFunc(doStep, 0, false)
end

function ExploreTest:update(dt)  --刷新
	if self.ship_pool then
		for _, node in pairs(self.ship_pool) do
			local angle_speed = 25
			if node then
				node:rotateY(math.rad(angle_speed*dt))
			end
		end
	end
end

-- local function ss( ... )
-- 	function Boat:updateRenderStyle( ... )
-- 	-- body
-- 	local model = self.node:getModel();
-- 	if not model then return ; end

-- 	local material = model:getFirstMaterial();
-- 	local original_tech = material:getTechnique();
-- 	local original_tech_name = original_tech:getId();
-- 	local tech_name = string.gsub( original_tech_name, "_outline", "" );

-- 	local tech = material:getTechnique( tech_name );
-- 	if tech then 
-- 		material:setTechnique( tech_name );
-- 	end

-- 	if self.effect_control then
-- 		if self.outline then
-- 			self.effect_control:setParameters( "texture", "outline", self.outline );
-- 		end
-- 		if self.star_level then
-- 			self.effect_control:setParameters( "#liuguang", "flow_name", self.node_name );
-- 			self.effect_control:refresh( self.star_level, "liuguang", "display", true );
-- 		end
-- 	end
-- end

function ExploreTest:testPlane()
	--res/ship_3d/plane001.gpb
	local gpb_name = "res/ship_3d/plane001.gpb"--string.format("%s%s/%s.gpb", MODEL_3D_PATH, res, res)
	local node_name = "plane001"
	local node = ResourceManager:LoadModel(gpb_name, node_name)

	node:setTranslation(getExploreLayer().player_ship.node:getTranslationWorld())
	node:setTranslationY(200)
	node:setScale(5)
	local layer3dShip = Explore3D:getLayerShip3d()
	layer3dShip:addChild(node)

	local model = node:getModel()
	local material = model:getMaterial(0)
	local parameter = material:getParameter("u_diffuseTexture")
	print("change ---------------------------")
	parameter:setValue("res/ship_3d/plane001.fbm/ocean_EdgeFoam02.png", false)

	-- local particle_res = "ocean_wave.modelparticles"--string.format("%s.modelparticles",  self.cfg.res)

	-- local effect_control = require( "gameobj/effect/effect" ).new( node );

	-- effect_control:preload( EFFECT_3D_PATH .. particle_res);
	-- --effect_control:showAll()
	-- effect_control:show( nil, "ocean_wave",  { "Model", "Emitter"});
	-- effect_control:setParameters( "#liuguang", "flow_name", node_name );
	-- effect_control:refresh( node_name, "liuguang", "display", true );
	
	self.ship_pool[#self.ship_pool + 1] = node
	self:createCD() 
end

function ExploreTest:initEffect()
	local particle_res = "ocean_wave.modelparticles"
	local effect_control = require( "gameobj/effect/effect" ).new(getExploreLayer().player_ship.node)
	effect_control:preload( EFFECT_3D_PATH .. particle_res)
	effect_control:showAll()
end

function ExploreTest:onExit()
	
end

return ExploreTest