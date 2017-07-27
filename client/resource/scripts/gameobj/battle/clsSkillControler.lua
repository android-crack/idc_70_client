-- 技能摇杆
-- Author: Ltian
-- Date: 2016-09-06 10:20:30
--

local ClsSkillControler = class("clsSkillControler", function( ) return display.newLayer() end)

function ClsSkillControler:ctor(x, y)
	self.center_pos = {x = x, y = y}
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	
	local tran = ship.body.node:getForwardVectorWorld():normalize()

	self.old_dir = ship.body:getAngle()
	
	
	self:initUI(x, y)
end

function ClsSkillControler:onTouch(x, y)

	local width = (x - self.center_pos.x)
	local height = (y - self.center_pos.y)
	if (math.abs(width) < 15 and math.abs(height) < 15) or x < 400 then return end
	
	local pos_3d = Vector3.new(width, 0, -2*height):normalize()

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	ship.body:updateSkillRankDirection(pos_3d)
	self.pos_3d = pos_3d
	local rad = self:getRad(width, height)
	local offset_y = 60 * math.sin(math.rad(rad))
	local offset_x = 60 * math.cos(math.rad(rad))
	local pos_x, pos_y = x, y
	if math.abs(x - self.center_pos.x) > math.abs(offset_x) then
		pos_x = self.center_pos.x + offset_x
	end
	if math.abs(y - self.center_pos.y) > math.abs(offset_y) then
		pos_y = self.center_pos.y + offset_y
	end
	self.btn:setPosition(pos_x, pos_y)
end

function ClsSkillControler:onTouchBegin()
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	local target = ship:getTarget()
	local dir
	if not target then
		dir = ship:getBody().node:getForwardVectorWorld():normalize()
	else
		local v1 = ship:getBody().node:getTranslationWorld()
		local v2 = target:getBody().node:getTranslationWorld()
		local forward = Vector3.new()
		Vector3.subtract(v2, v1, forward)
		dir = forward:normalize()
	end
	
	print(dir:x(), dir:y(),dir:z())
	ship.body:updateSkillRankDirection(dir)
end

function ClsSkillControler:getRad(width, height)
	local dir = math.deg(math.atan(height/width))
	
	if height >= 0 then
		if dir < 0 then
			dir = 180 + dir
		end
	else
		if dir < 0 then
			dir = 360 + dir
		else
			dir = 180 + dir
		end

	end
	return dir
end

function ClsSkillControler:initUI(x, y)
	self.btn_bg = display.newSprite("#battle_control_skill.png")
	self.btn_bg:setScale(0.48)
	self.btn = display.newSprite("#battle_control.png")
	self.btn:setScale(0.6)
	self:addChild(self.btn_bg, 1)
	self:addChild(self.btn, 2)
	self.btn:setPosition(x, y)
	self.btn_bg:setPosition(x, y)
end

function ClsSkillControler:useSkill()
	self:removeFromParentAndCleanup(true)
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	local ship_pos = nil
	if not ship.isDeaded then
		ship_pos = ship.body.node:getTranslation()
	end
	
	return {self.pos_3d, ship_pos}
end
return ClsSkillControler