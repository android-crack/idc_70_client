--港口小地图的主线战的图标

local ExploreUtil = require("module/explore/exploreUtils")
local pirate_info = require("game_config/explore/pirate_main_info")
local boss_info = require("game_config/explore/patrol_boss_info")


local ClsPortMapPirateIcon = class("PortMapPirateIcon")

function ClsPortMapPirateIcon:ctor(ui_parent, id, start_time, is_boss)
	start_time = start_time or 0
	self.ui_parent = ui_parent
	self.config_id = id
	self.is_boss = is_boss
	if is_boss then
		self.config = boss_info[id]
	else
		self.config = pirate_info[id]
	end
	local playerData = getGameData():getPlayerData()
	self.dx_time = os.time() - start_time + playerData:getTimeDelta()
	
	self.icons = {}
	self:initPathConfig()
	self:createHeadIcon()
	--self:createPathIcons()
	self:createHandleCD()
	
end

function ClsPortMapPirateIcon:addPathIcon(x, y)
	local icon = display.newSprite("#common_point.png")
	local pos = ExploreUtil:cocosToTile2(ccp(x, y))
	icon:setPosition(ccp(pos.x / 30, pos.y / 30))
	self.ui_parent.map:addChild(icon, 19)
	self.icons[#self.icons + 1] = icon
end

function ClsPortMapPirateIcon:setIconScale()
	for _, item in pairs(self.icons) do
		item:setScale(1 / self.ui_parent.map_layer:getScale())
	end
	if self.is_boss then
		self.head_icon:setScale(1 / self.ui_parent.map_layer:getScale())
		--self.head_icon:setScaleY(self.ui_parent.ship:getScaleY())
	else
		self.head_icon:setScale(1 / self.ui_parent.map_layer:getScale() * 0.8)
		--self.head_icon:setScaleY(self.ui_parent.ship:getScaleY() * 0.7)
	end
end

function ClsPortMapPirateIcon:setHeadIconPos(pos)
	self.head_icon:setPosition(pos)
end

function ClsPortMapPirateIcon:setWorldIconScale()
	
	if self.is_boss then
		self.head_icon:setScaleX(self.ui_parent.ship:getScaleX())
		self.head_icon:setScaleY(self.ui_parent.ship:getScaleY())
	else
		self.head_icon:setScaleX(self.ui_parent.ship:getScaleX() * 0.7)
		self.head_icon:setScaleY(self.ui_parent.ship:getScaleY() * 0.7)
	end
end


function ClsPortMapPirateIcon:createPathIcons()
	local path_len = #self.path

	local dx = ExploreUtil:getPosNum(path_len)
	local index = 1
	
	while(true)
	do
		if index > path_len then
			break;
		end
		local x = self.path[index]
		local y = self.path[index + 1]
		if x and y then
			self:addPathIcon(x, y)
		end
		index = index + dx
	end
end

function ClsPortMapPirateIcon:createHandleCD()
	local function update(dt)
        self:update(dt)
    end
    local scheduler = CCDirector:sharedDirector():getScheduler()
    self.hander_time = scheduler:scheduleScriptFunc(update, 0, false)
end

function ClsPortMapPirateIcon:stopUpdate()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
end

function ClsPortMapPirateIcon:release()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end
	self.head_icon:removeFromParentAndCleanup(true)
	self.path = nil
end

function ClsPortMapPirateIcon:createHeadIcon()

	self.head_icon = self.ui_parent:createHeadIcon(self.start_pos.x / 30, self.start_pos.y / 30)
	if not self.is_boss then
		self.head_icon.boss_label:setVisible(false)
	end
end

function ClsPortMapPirateIcon:initPathConfig()
	local pos_st = ccp(self.config.path[1][1], self.config.path[1][2])
	local pos_end = ccp(self.config.path[2][1], self.config.path[2][2])
	local path = ExploreUtil:createPathPoints(self.ui_parent.AStar, pos_st, pos_end)
	self.path = path
	self.max_index = #self.path / 2
	local init_pos = ExploreUtil:cocosToTile2(pos_st)
	local init_end = ExploreUtil:cocosToTile2(pos_end)
	self.init_pos = init_pos
	self.init_end = init_end
	local dis = Math.distance(init_pos.x / 30, init_pos.y / 30, self.init_end.x / 30, self.init_end.y / 30)
	self.distance = dis
	self.speed = self.config.speed / 35
	self.total_time = Math.floor(self.distance / self.speed + 0.5)
	self.max_index = #path / 2
	self.current_index = 1

	local remainder = self.dx_time % self.total_time
	local n = (self.dx_time - remainder) / self.total_time
	if n >= 1 then
		if remainder > 0 then
			local per = remainder / self.total_time
			local index = Math.floor(per * self.max_index + 0.5)
			if n % 2 == 0 then
				self.front = true
				self.back = false
			else
				self.front = false
				self.back = true
				index = self.max_index - index
			end
			self.current_index = index
		else
			if n % 2 == 0 then
				self.front = true
				self.back = false
				self.current_index = 1
			else
				self.front = false
				self.back = true
				self.current_index = self.max_index - 1
			end			
		end
	else
		local m = self.dx_time / self.total_time
		local index = Math.floor(m * self.max_index + 0.5)
		self.current_index = index
		self.front = true
		self.back = false
	end
	if self.current_index <= 0 then
		self.current_index = 1
	end
	self.start_pos = ExploreUtil:cocosToTile2(ccp(self.path[2 * self.current_index - 1], self.path[2 * self.current_index]))
end

function ClsPortMapPirateIcon:getEndPos()
	local x, y = self.head_icon:getPosition()
	local pos = ccp(x, y)
	pos = ccp(pos.x * 30, pos.y * 30)
	pos = ExploreUtil:cocosToTile(pos)
	return pos
end

function ClsPortMapPirateIcon:update(dt)
	if self.stop then
		--stop---------------
	else
		self.stop = true
		local cur_pos_x, cur_pos_y = self.head_icon:getPosition()
		local x = self.path[2 * self.current_index - 1]
		local y = self.path[2 * self.current_index]
		local config_pos = ExploreUtil:cocosToTile2(ccp(x, y))
		config_pos = ccp(config_pos.x / 30, config_pos.y / 30)
		local dis = Math.distance(cur_pos_x, cur_pos_y, config_pos.x, config_pos.y)

		local array = CCArray:create()
		local time = dis / self.distance * self.total_time
		array:addObject(CCMoveTo:create(time, config_pos))
		array:addObject(CCCallFunc:create(function()
			self.stop = false
			if self.front then
				self.current_index = self.current_index + 1
			elseif self.back then
				self.current_index = self.current_index - 1
			end
			if self.current_index >= self.max_index then
				self.front = false
				self.back = true
				self.current_index = self.max_index - 1
			elseif self.current_index <= 1 then
				self.front = true
				self.back = false
				self.current_index = 1
			end
		end))

		self.head_icon:runAction(CCSequence:create(array))
	end
end

return ClsPortMapPirateIcon