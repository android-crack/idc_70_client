-- for test
local sea3d = require("gameobj/sea3d")
local model3d = require("gameobj/model3d")
local battleSceneCfg = require("gameobj/battle/battleSceneCfg")

local ClsBattleTest = class("ClsBattleTest", function() return CCLayer:create() end)

function ClsBattleTest:ctor()
	self:createLayer()

	GameUtil.runScene(function() GameUtil.getRunningScene():addChild(self) end, 0)
end

function ClsBattleTest:createLayer()
	local layer_id = 1
	local map_layer = battleSceneCfg.new(layer_id)
	self:addChild(map_layer, 10)

	CreateScene3D()
	CameraFollow:init(self, map_layer:getContentSize().width, map_layer:getContentSize().height)
	local root3D = GetRootNode3D()
	
	local layerSeaIdx = 0
	local layer3d_sea = CCLayer3D:create(layerSeaIdx)
	self:addChild(layer3d_sea, 0)

	local layer3dSea = Node.create("layerSea")
	layer3dSea:setLayer(layerSeaIdx)
	root3D:addChild(layer3dSea)

	local width, height = CameraFollow:GetSceneBound()
	local sea = sea3d.new("res/sea_3d/battleSea.conf", Vector3.new(width/2, 0, -height/2))
	layer3dSea:addChild(sea.node)
	local seaCfg = map_layer:getSeaCfg()
	if seaCfg then
		sea:setUniforms(seaCfg)
	end

	for i = 1, 30, 1 do
		local params =
		{
			parent = layer3dSea,
			is_ship = true,
			path = SHIP_3D_PATH,
			node_name = string.format("boat%.2d", 1),
			id = 1,
		}

		local node = model3d.new(params)
		local animation = node.animation
		if animation then 
			local clip = animation:getClip(ani_name_t.move)
			if clip then 
				clip:play()
			end
		end

		node.node:setTranslation( (i%6)*150 - 200, 0, 300 - math.floor(i/6)*150)
	end
end

return ClsBattleTest
