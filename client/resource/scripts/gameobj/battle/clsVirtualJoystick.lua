local skill_warning = require("game_config/skill/skill_warning")
local battleRecording = require("gameobj/battle/battleRecording")

local ClsVirtualJoystick = class("ClsVirtualJoystick", function() return CCLayer:create() end)

local DEFAULT_OPACITY = 80
local POS_X, POS_Y = 120, 105

function ClsVirtualJoystick:ctor()
	self:initUI()

	self:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y)
	end, false, 1, true)
	self:setTouchEnabled(true)
end

function ClsVirtualJoystick:giveUp()
	self.btn_bg:setOpacity(DEFAULT_OPACITY)
	self.btn_bg:setPosition(POS_X, POS_Y)
	self.btn:setPosition(POS_X, POS_Y)

	self.in_area = false
	self.click_btn = false
	self.touch_move_mark = false
	self.user_touch_scene = true
end

function ClsVirtualJoystick:initUI()
	self.btn = display.newSprite("#battle_control.png")
	self:addChild(self.btn, 1)

	self.btn_bg = display.newSprite("#battle_control_bg.png")
	self:addChild(self.btn_bg, 0)

	self.btn_bg_half_width = self.btn_bg:getContentSize().width/2
	self.width_square = self.btn_bg_half_width*self.btn_bg_half_width

	self:giveUp()
end

function ClsVirtualJoystick:getUserTouchScene()
	return self.user_touch_scene
end

function ClsVirtualJoystick:onTouch(event, x, y)
	if event == "began" then
		return self:onTouchBegan(ccp(x, y))
	end

	if event == "moved" then
		self:onTouchMoved(ccp(x, y))
	else
		local battle_data = getGameData():getBattleDataMt()
		local ship = battle_data:getCurClientControlShip()

		if event == "ended" and not self.touch_move_mark then
			BattleInit3D:touchScene3D(x, y)
			return
		else
			if ship then
				if battle_data:getJoyStickPos() then
					battle_data:setJoyStickPos(nil)
					battle_data:setJoyStickTime(0)
				end
				ship:tryRunAI(SYS_CLEAR)
			end
		end

		self:giveUp()

		if not ship or ship:is_deaded() then return end

		if ship:getBody() then
			ship:getBody():resetPath()
		end

		battleRecording:recordVarArgs("battle_stop_ship", ship:getId())
	end
end

function ClsVirtualJoystick:onTouchBegan(pos)
	local battle_data = getGameData():getBattleDataMt()

	local ship = battle_data:getCurClientControlShip()
	if not ship or ship:is_deaded() then return false end

	local rect_2 = CCRect(0, 0, display.width/3, display.height/3)

	self.in_area = rect_2:containsPoint(ccp(pos.x, pos.y))

	if self.in_area then
		self.last_touch_pos = pos
		return true
	end

	return false
end

local function calcDestination(offset_x, offset_y, ship_x, ship_y)
	local height = BATTLE_SCENE_HEIGHT * 2

	local x, y = 0, 0
	if offset_x == 0 then
		x = ship_x
		if offset_y > 0 then
			y = BATTLE_SCENE_HEIGHT * 2
		end
	else
		local k = offset_y/offset_x

		local b = ship_y - ship_x*k

		if offset_x > 0 then
			x = BATTLE_SCENE_WIDTD
			y = x*k + b

			if y > height or y < 0 then
				if y > height then
					y = height
				else
					y = 0
				end

				x = (y - b)/k
			end
		else
			x = 0
			y = x*k + b

			if y > height or y < 0 then
				if y > height then
					y = height
				else
					y = 0
				end

				x = (y - b)/k
			end
		end
	end

	x = math.floor(x + 0.5)
	y = - math.floor(y + 0.5)

	return Vector3.new(x, 0, y)
end

function ClsVirtualJoystick:onTouchMoved(pos)
	local battle_data = getGameData():getBattleDataMt() 
	local ship = battle_data:getCurClientControlShip()
	if not ship or ship:is_deaded() then return end

	if not (math.abs(pos.x - self.last_touch_pos.x) > 5 or math.abs(pos.y - self.last_touch_pos.y) > 5) then return end

	if not self.touch_move_mark then
		if self.user_touch_scene and self.in_area then
			self.btn_bg:setPosition(self.last_touch_pos.x, self.last_touch_pos.y)
			self.btn:setPosition(pos.x, pos.y)
		end

		ship:setAutoFight(false)

		local battle_ui = battle_data:GetLayer("battle_ui")
		if not tolua.isnull(battle_ui) then
			battle_ui:lockPlayerShip()
			battle_ui:setHand()
		end

		self.user_touch_scene = false
	end

	local ship_pos = ship:getPosition3D()
	local ship_x, ship_y = ship_pos:x(), - ship_pos:z()  -- z轴为反方向

	local pos_bg_x, pos_bg_y = self.btn_bg:getPositionX(), self.btn_bg:getPositionY()

	local offset_x = pos.x - pos_bg_x
	local offset_y = pos.y - pos_bg_y

	local touch_pos = calcDestination(offset_x, offset_y, ship_x, ship_y)

	if not self.touch_move_mark then
		self.touch_move_mark = true
	else
		battle_data:setJoyStickPos(touch_pos)
	end

	ship:touchScene(touch_pos)

	offset_x = pos.x - self.last_touch_pos.x
	offset_y = pos.y - self.last_touch_pos.y

	if offset_x*offset_x + offset_y*offset_y <= self.width_square then
		self.btn:setPosition(pos.x, pos.y)
		return
	end

	local vec = Vector2.new(offset_x, offset_y)
	vec:normalize()
	vec:scale(self.btn_bg_half_width)

	self.btn:setPosition(pos_bg_x + vec:x(), pos_bg_y + vec:y())
end

return ClsVirtualJoystick
