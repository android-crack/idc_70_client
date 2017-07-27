-- 战斗3d 初始化相关内容
local walkManager = require("gameobj/battle/walkManager")
local bulletCls = require("gameobj/battle/bullet")
local GousuoMgr = require("gameobj/battle/GousuoManager")
local sceneEffect = require("gameobj/battle/sceneEffect")
local shipEntity = require("gameobj/battle/newShipEntity")
local battleEffect = require("gameobj/battle/battleEffectLayer")
local ui_word = require("game_config/ui_word")
local alert =  require("ui/tools/alert")
local Game3d = require("game3d")

require("gameobj/battle/cameraFollow")


BattleInit3D = {}

function BattleInit3D:initScene3D(layer)
	local battle_data = getGameData():getBattleDataMt()
	local cocosLayer = layer or battle_data:GetLayer("battle_scene_layer")
	local cocosLayerWidth, cocosLayerHeight = battle_data:GetTable("battle_layer").getSceneSize()
	
	local scene_id = SCENE_ID.BATTLE
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
	
	CameraFollow:init(scene_id, cocosLayer, cocosLayerWidth, cocosLayerHeight)
	walkManager.init()
	self.is_start = true
end

function BattleInit3D:getLayerSea3d()
	return self.layer3d_sea
end 

function BattleInit3D:getLayerShip3d()
	return self.layer3d_ship
end

function BattleInit3D:getScene()
	return self.scene3d
end  

function BattleInit3D:removeScene3D()
	if self.is_start then
		CameraFollow:DelCocosLayer()
		sceneEffect.Release()
		GousuoMgr:releaseGouSuo()
		bulletCls:releaseAll()
		shipEntity.releaseAllShips()
		
		self.layer3d_ship = nil
		self.layer3d_sea = nil
		self.scene3d = nil
		self.is_start = false
		Game3d:releaseScene(SCENE_ID.BATTLE)
	end
end

function BattleInit3D:updateScene3D(elapsedTime)
    local battle_data = getGameData():getBattleDataMt()
    if not battle_data then return end

    if battle_data:BattleIsRunning() then

        sceneEffect.update(elapsedTime)
        GousuoMgr:updateGouSuos(elapsedTime)

        battle_data:SetData("dis_of_ships", {})

        local dt = elapsedTime/1000
        local SHIPS = battle_data:GetShips()
        for k, ship_data in pairs(SHIPS) do
            if not ship_data.isDeaded and ship_data.body then
                ship_data.body:update(dt)
            end
        end
    end

    battle_data:update()

    bulletCls:update(elapsedTime)
    local ship = battle_data:getCurClientControlShip()
    if ship then
        CameraFollow:update(ship.body)
    end
end

function BattleInit3D:touchScene3D(x, y)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:BattleIsRunning() then return end

	if battle_data:GetShipsDead() then
		alert:battleWarning({msg = ui_word.ALREADY_DEAD})
		return
	end

	if shipEntity.selectTarget(x, y) then
		return
	end

	local battleUI = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battleUI) and not battleUI:isCanTouch() then return end

	local pos = ScreenToVector3(x, y, self.scene3d:getActiveCamera())
	if pos then
		local ship = battle_data:getCurClientControlShip()

		if ship and not ship:is_deaded() then
			local node = BattleInit3D:clickObject(x, y)
			if not node then
				battleEffect.showClickCallBack(x, y)

				ship.body:addPathEffect(pos)
			end

			if not tolua.isnull(battleUI) then
				battleUI:setHand()
			end

			ship:touchScene(pos)
		end
	end
end

function BattleInit3D:clickObject(x, y)
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
