-- 战斗船
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local AttackDirRange = require("gameobj/battle/AttackDirRange")

local ClsBattleClient = require("gameobj/battle/clsBattleClient")
local ClsBattleServer = require("gameobj/battle/clsBattleServer")

local Boat = require("gameobj/ship3d")
local ClsBattleShip3d = class("ClsBattleShip3d", Boat)

local SHIP_ROTATE_DT_COUNT = FRAME_CNT_PER_SEC

local BOAT_STAR_MIN, BOAT_STAR_MAX = 1, 3

local ATTACK_RANGE_ALPHA = 0.4
local ATTACK_RANGE_OFFSET = 150
local ATTACK_RANGE_COLOR = Vector4.new(1, 1, 1, ATTACK_RANGE_ALPHA)

function ClsBattleShip3d:ctor(ship_mt)
	local battleData = getGameData():getBattleDataMt()
	local ship_data = ship_mt.baseData
	local ship_cfg = boat_info[ship_data.ship_id]

	self.gen_id = ship_mt.id or 0
	self.id = tonumber(ship_data.ship_id)
	self.speed = ship_mt.values.speed
	self.turn_speed = 360 --boat_attr[ship_data.ship_id].angle or 60
	self.ship_ui = battleData:GetLayer("ship_ui")
	self.dialog_node = battleData:GetLayer("dialog_node")
	self.kind = ship_cfg.kind or "smallShip"
	
	self.is_oar = ship_cfg.is_oar
	self.pos = ship_data.pos
	
	self.star_level = Math.clamp(BOAT_STAR_MIN, BOAT_STAR_MAX, ship_data.boatTransStar + 1)

	self.far_range = 0
	self.attack_range_tick = 0
	self.show_attack_range = false
	self.parent = BattleInit3D:getLayerShip3d()

	ClsBattleShip3d.super.ctor(self, self)

	self.target_pos = nil
	self.at_land_flg = false
	self.at_bound_flg = false
	self.at_collision_flg = 0

	self:resetPath()
end

function ClsBattleShip3d:showGuanquan()
	local battle_data = getGameData():getBattleDataMt()
	if battle_data:getShowShipUI() then
		self.super.showGuanquan(self)
	end
end

function ClsBattleShip3d:setPos(x, y)
	self:resetPath()
	self.super.setPos(self, x, y)
end

function ClsBattleShip3d:setBanTurn(value)
	self.is_ban_turn = value

	if value then
		self:resetPath()
	end
end

function ClsBattleShip3d:update(dt) --此时间是每帧时间的1000分之一
	if self.is_pause then 
		self:updateUI(dt)
		return
	end

	local battle_data = getGameData():getBattleDataMt()
	local ship_obj = battle_data:getShipByGenID(self.gen_id)

	if not ship_obj or ship_obj:is_deaded() then return end
	
	self:updateAngle(dt)
	self:updatePath(dt)

	self:updateUI(dt)           -- 刷新位置再刷新UI
	self:updateAttackRange(dt)
end

function ClsBattleShip3d:resetPath()
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

function ClsBattleShip3d:updatePath(dt)
	if self:getBanTurn() then return end

	if self:getSpeed() <= 0 then return end

	if self.move_type == DYNAMIC_REFRESH then
		if ClsBattleServer.dynamicRefresh(self, dt) then return end
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

function ClsBattleShip3d:updateAngle(dt)
	if self.is_ban_rotate then return end

	if self.rotate_angle == 0 then return end

	ClsBattleClient.updataAngle(self, dt)

	self:setMoveAction()
end

function ClsBattleShip3d:setRotateAngle(angle)
	if self.is_ban_rotate then return end

	if angle > 180 then
		angle = angle - 360
	end

	self.rotate_angle = angle
end

-- 攻击范围刷新 --------------------------------------------------------------------------------------------------------
function ClsBattleShip3d:createAttackRange(far_range)
	if far_range <= 0 then return end

	self:delAttackRange()

	self.far_range = far_range

	local battle_data = getGameData():getBattleDataMt()
	if battle_data:isCurClientControlShip(self.gen_id) then 
		local color = Vector4.new(1, 1, 1, 0)
		self.fanNode = AttackDirRange.showAttackRange(self.node, far_range, self.range_depth, color, 0.1)
		self.fanNode:setInheritedRotation(true)
	else 
		self.fanNode = AttackDirRange.showAttackDirection(self.node, far_range, self.range_depth, 1)
		self.fanNode:setInheritedRotation(false)
	end
	self.fanNode:setInheritedScale(false)
end

function ClsBattleShip3d:showAttackRange(show_attack_range, far_range, dt)
	if self.show_attack_range == show_attack_range and self.attack_range_tick == 0 then return end

	self.show_attack_range = show_attack_range

	if show_attack_range and (far_range ~= self.far_range or not self.fanNode) then 
		self:createAttackRange(far_range)
	end

	local beginAlpha, endAlpha, base = 0, ATTACK_RANGE_ALPHA, 1
	if show_attack_range == false then 
		beginAlpha, endAlpha, base = ATTACK_RANGE_ALPHA, 0, -1
	end
	
	local alpha = self.attack_range_tick*base

	if (base == 1 and beginAlpha + alpha - endAlpha > 0.001) 
		or (base == -1 and beginAlpha + alpha - endAlpha < -0.001) then
			alpha = endAlpha - beginAlpha
	end

	if self.fanNode then 
		SetSpriteModelAlpha(self.fanNode, Vector4.new(1, 1, 1, beginAlpha + alpha))	
		if beginAlpha + alpha == 0 then self.fanNode:setActive(false) end
		if beginAlpha + alpha == ATTACK_RANGE_ALPHA then self.fanNode:setActive(true) end
	end

	if alpha == (endAlpha - beginAlpha) then 
		self.attack_range_tick = 0
	else
		self.attack_range_tick = self.attack_range_tick + dt
	end
end

function ClsBattleShip3d:updateAttackRange(dt)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:isShowDamageRange() or self.is_show_skill_range or self.is_show_boss_skill_range then
		if self.fanNode then
			self.fanNode:setActive(false)
		end 
		return 
	end

	if battle_data:isDemo() then return end

	local own_ship = battle_data:getShipByGenID(self.gen_id)

	local control_ship = battle_data:getCurClientControlShip()

	local is_current_ship = control_ship == own_ship

	if own_ship:getTeamId() == battle_config.neutral_team_id or 
		(not is_current_ship and own_ship:getTeamId() == control_ship:getTeamId()) then 
		return 
	end

	local dis, ship
	local show_attack_range = false

	local target = own_ship:getTarget()

	if is_current_ship then
		ship, dis = own_ship:getNearestShip()
	elseif not own_ship:is_deaded() and target and target == control_ship and not control_ship:is_deaded() then
		local tb_dis = battle_data:GetData("dis_of_ships") or {}

		local first, second = own_ship:getId(), control_ship:getId()
		if first > second then
			first, second = second, first
		end
		local key = string.format("%d_%d", first, second)

		dis = tb_dis[key]

		if not dis then
			local self_pos = own_ship:getPosition3D()
			local target_pos = control_ship:getPosition3D()

			local offset_x = target_pos:x() - self_pos:x()
			local offset_y = target_pos:z() - self_pos:z()
			dis = offset_x*offset_x + offset_y*offset_y

			tb_dis[key] = dis

			battle_data:SetData("dis_of_ships", tb_dis)
		end
	end

	local far_range = own_ship:getFarRange()
		
	if dis and dis > 0 and dis < (far_range + ATTACK_RANGE_OFFSET)*(far_range + ATTACK_RANGE_OFFSET) then
		show_attack_range = true
	end

	self:showAttackRange(show_attack_range, far_range, dt)

	if not target or not target.body then return end

	if self.fanNode and self.fanNode:isActive() and not battle_data:isCurClientControlShip(self.gen_id) then 
		AttackDirRange.setAttackDirectionTarget(self.fanNode, target.body)			
	end
end
-- 攻击范围刷新 --------------------------------------------------------------------------------------------------------

function ClsBattleShip3d:moveTo(pos, reason, move_type)
	ClsBattleClient.moveTo(self, pos, reason, move_type)
end

return ClsBattleShip3d