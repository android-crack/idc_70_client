---- 战斗道具
---- 例如 漩涡、宝箱等，赋予属性，相当于特别造型的船，并且有属性
local ParticleSystem = require("particle_system")
local walkManager = require("gameobj/battle/walkManager")
local sceneEffect = require("gameobj/battle/sceneEffect")
local prop_info = require("game_config/battle/prop_info")

local ClsBattleClient = require("gameobj/battle/clsBattleClient")
local ClsBattleServer = require("gameobj/battle/clsBattleServer")

local Boat = require("gameobj/ship3d")

local BattleProp = class("BattleProp", Boat)

function BattleProp:ctor(shipData, gen_id)
	self.id = shipData.prop_id
	self.cfg = prop_info[self.id]
	self.gen_id = gen_id
	self.speed = shipData[FV_SPEED] or 0
	self.speed_rate = 1
	self.turn_speed = 60  -- 每秒转角度
	self.rotate_angle = 0
	self.target_pos = nil
	self.is_pause = false 
	self.type = self.cfg.type
	self.is_ship = false
	self.range_depth = 3
	self.effect = {}
	self.path = self.cfg.path 
	self.node_name = self.cfg.res 
	self.effect_control = nil
	self.scene_effect = {}      -- 场景特效
	
	if self.cfg.sea_level ~= 1 then 
		self.parent = BattleInit3D:getLayerShip3d()
	else 
		self.parent = BattleInit3D:getLayerSea3d()
	end 
	
	if self.type == 1 then
		self.node_name = "particle_system:"..self.path
		local particle = sceneEffect.createEffect({file = self.path})
		if particle then 
			particle:Start()
			self.node = particle:GetNode()
			self.parent:addChild(self.node)
		end
	
	elseif self.type == 0 then
		Boat.super.ctor(self, self)
		self.shootNode = self.node:findNode("center", true)
		
		local path = string.format("%s%s%s", EFFECT_3D_PATH, self.node_name, MODELPARTICLE_EXT) 
		if FileSystem.fileExists(path) then
			self.effect_control = require("gameobj/effect/effect").new(self.node)
			self.effect_control:preload( path );
			self.effect_control:showAll()
		end
	end 

	self.node:setId(tostring(gen_id))
	self.node:setTag("node_name", self.node_name)

	if self.cfg.scale then
		self.node:setScale(self.cfg.scale)
	end
	
	self:initUI()
	
	local pos = shipData.pos
	self:setPos(pos.x, pos.y)
	self:setAngle(ShipDirToRota[pos.rota])
	
	if self.cfg.hit > 0 then 
		self:initCollision()
	end
	
	self:playAnimation("move", true)
end 

function BattleProp:showGuanquan()
	local battle_data = getGameData():getBattleDataMt()
	if battle_data:getShowShipUI() then
		self.super.showGuanquan(self)
	end
end

function BattleProp:initEffect(effect_name)
	Boat.super.initEffect(self, effect_name)
end

function BattleProp:getIsShip()
	return self.is_ship
end

function BattleProp:initCollision()	
	local scale = 1.2
	local add_radius = self.cfg.add_radius
	local boundingSphere = self.node:getBoundingSphere()
	self.node:setCollisionObject("GHOST_OBJECT", PhysicsCollisionShape.sphere(boundingSphere:radius()/2*scale + add_radius))
	self.node:getCollisionObject():addCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
end

function BattleProp:removeCollision()
	if not self or not self.node then return end

	local collsionObject = self.node:getCollisionObject()
	if collsionObject then 
		collsionObject:removeCollisionListener("scripts/gameobj/gameplayFunc.lua#shipCollisionEvent")
		self.node:setCollisionObject("NONE")
	end 
end

function BattleProp:initUI()
	self.ui = CCNode:create()
	local battleData = getGameData():getBattleDataMt()
	battleData:GetLayer("ship_ui"):addChild(self.ui)
	self.acSp = CCNode:create()
	self.ui:addChild(self.acSp)

	self.dialog = CCNode:create()
	battleData:GetLayer("dialog_node"):addChild(self.dialog)
end 

function BattleProp:updateUI(dt)
	local translate = self.node:getTranslationWorld()
	local pos = gameplayToCocosWorld(translate)
	if not tolua.isnull(self.ui) then 
		self.ui:setPosition(pos)
	end
	if not tolua.isnull(self.dialog) then 
		self.dialog:setPosition(pos)
	end
end

function BattleProp:broken()
end 

function BattleProp:showOutline()
end

function BattleProp:moveTo(pos, reason, move_type)
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.gen_id)

	if not ship_obj or ship_obj:is_deaded() then return end

	-- 炮塔
	if self:getSpeed() == 0 and ship_obj:hasBuff("unspeedable") then
		move_type = DYNAMIC_REFRESH
	end

	ClsBattleClient.moveTo(self, pos, reason, move_type)
end

function BattleProp:setPos(x, y)
	self:resetPath()
	self.super.setPos(self, x, y)
end

function BattleProp:setBanTurn(value)
	self.is_ban_turn = value

	if value then
		self:resetPath()
	end
end

function BattleProp:update(dt) --此时间是每帧时间的1000分之一
	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.gen_id)

	if not ship_obj or ship_obj:is_deaded() then return end

	if self.is_pause then 
		self:updateUI(dt)
		return
	end
	
	self:updateAngle(dt)
	self:updatePath(dt)
	self:updateUI(dt)           -- 刷新位置再刷新UI
end

function BattleProp:resetPath()
	self.path_index = 1
	self.move_path = {}
	self.target_pos = nil
	self.check_dist = CHECK_DIST + self.gen_id

	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.gen_id)
	if ship_obj then
		ship_obj:resetAllMoveStatus()
	end
end

function BattleProp:updatePath(dt)
	if self:getBanTurn() then return end

	if self:getSpeed() <= 0 then return end

	if self.move_type == DYNAMIC_REFRESH then
		ClsBattleServer.dynamicRefresh(self, dt)
	end

	local already_arrive = ClsBattleClient.updatePositon(self, dt)

	if already_arrive then
		self.path_index = self.path_index + 1
		if self.move_path and self.move_path[self.path_index] then
			self.target_pos = self.move_path[self.path_index]

			self:setRotateAngle(GetAngleBetweenNodeAndPoint(self.node, self.target_pos))
		else
			self:resetPath()
		end
	end

	ClsBattleServer.updatePosition(self, dt)
end

function BattleProp:updateAngle(dt)
	if self.is_ban_rotate then return end

	if self.cfg.is_rotate ~= 1 then return end

	if self.rotate_angle == 0 then return end

	ClsBattleClient.updataAngle(self, dt)
end

function BattleProp:setRotateAngle(angle)
	if self.is_ban_rotate then return end

	if angle > 180 then
		angle = angle - 360
	end

	self.rotate_angle = angle
end

return BattleProp 