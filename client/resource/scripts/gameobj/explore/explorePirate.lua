-- 探索船
local boat_info = require("game_config/boat/boat_info")
local progressTimer = require("ui/tools/ProgressTimer")
local exploreWalk = require("gameobj/explore/exploreWalk")
local ExploreUtil = require("module/explore/exploreUtils")
local ClsExploreShip3D = require("gameobj/explore/exploreShip3d")

local ClsExplorePirate = class("ExplorePirate", ClsExploreShip3D)

function ClsExplorePirate:ctor(item)
	item.pirate_icon = "#explore_boss.png"	
	self.is_boss = item.is_boss
	self.start_time = item.start_time
	self.event_id = item.event_id
	self.config = item.config
	self.end_auto = false
    self.start_auto = true
    self.pirate_id = item.pirate_id
    self.pirate_icons = {}
    self.is_child = item.is_child
    self.childs = {}
    ClsExplorePirate.super.ctor(self, item)
end

function ClsExplorePirate:createMapIcon()
	local ui = getExploreUI()
	local head_icon = ui.world_map:addPirateHeadIcon(self.event_id, self:posMap(), self.is_boss)
	if not self.is_boss then
		head_icon.boss_label:setVisible(false)
	end
end

function ClsExplorePirate:initPos()
	local px, py = self:getPos()
	self.last_px = px
	self.last_py = py
end

function ClsExplorePirate:posMap()
	local ui = getExploreUI()
	local x, y = self:getPos()
	local pos_info = {x = x, y = y}
	local dx = pos_info.x or 0
	local dy = pos_info.y or 0
	local pos_rate = 30
	dx = dx / pos_rate
	dy = dy / pos_rate
	local ship_next_x = dx
	local ship_next_y = dy

	local dx = 15
	if ship_next_x >= ui.world_map.map_width - dx then
		ship_next_x = ui.world_map.map_width - dx
	end

	if ship_next_y >= ui.world_map.map_height - dx then
		ship_next_y = ui.world_map.map_height - dx
	end
	return ccp(ship_next_x, ship_next_y)
end

function ClsExplorePirate:updateMapUI(dt)
	----update 
	if self.is_child then
		return
	end
	local ui = getExploreUI()
	if self.land and not tolua.isnull(ui) and not tolua.isnull(ui.world_map)  then
		local head_icon = nil
		if self.is_boss then
			head_icon = ui.world_map:getBossHeadIcon(self.pirate_id)
		else
			head_icon = ui.world_map:getPirateHeadIcon(self.pirate_id)
		end
		if head_icon and (not self.is_child) then
			head_icon:stopUpdate()
			local pos = self:posMap()
			head_icon:setHeadIconPos(pos)
		end
	end
end

function ClsExplorePirate:goToDesitinaion(end_pos, call_back, param)
	--print("position ", end_pos.x, end_pos.y)
	local p = ccp(self:getPos())
	local pos_st = self.land:tileToCocos(p) -- 开始坐标
	--print("开始位置-------------------", pos_st.x, pos_st.y)
	local pos_end = end_pos           -- 目标点
	
	local path = self.land:getSearchPath(pos_st, pos_end)
	if not path then
		print("寻路不到------------------------")
		return
	end 
	local path_len = #path
	local index = 3

	local auto
	auto = function()
		---print("path_len, ---", path_len)
		if index > path_len then
			if call_back then
				call_back(param)
				self:rotateStop()
			end
			return
		end
		local x = path[index]
		local y = path[index + 1]
		index = index + 2
		local pos = self.land:cocosToTile2(ccp(x, y))
		self:autoMoveToPos(pos, auto)
	end
	auto()
end

function ClsExplorePirate:beginFindPath(goal_pos, call_back)
	
	local p = ccp(self:getPos())
	local pos_st = self.land:tileToCocos(p) -- 开始坐标
	local pos_end = ccp(goal_pos[1], goal_pos[2])
	local par_st = ExploreUtil:getPartitionId(pos_st)
	local par_end = ExploreUtil:getPartitionId(pos_end)

	local tmp_goal_pos = ccp(goal_pos[1], goal_pos[2])
	self:goToDesitinaion(tmp_goal_pos, call_back)

	-- local map_partition = require("game_config/explore/explore_map_partition")

	-- if par_st and par_end then 
	-- 	local pass_tab = map_partition[par_st].pass_partition[par_end]
	-- 	if pass_tab and #pass_tab > 0 then 
	-- 		local loopMove
	-- 		loopMove = function(index)
	-- 			if index == nil then
	-- 				print("is_boss======pirate_id===name===", self.is_boss, self.pirate_id, self.config.name)
	-- 			end
	-- 			index = index + 1
	-- 			local partition_id = pass_tab[index]
	-- 			if not partition_id then
	-- 				local tmp_goal_pos = ccp(goal_pos[1], goal_pos[2])
	-- 				self:goToDesitinaion(tmp_goal_pos, call_back)
	-- 			else
	-- 				local pos = map_partition[partition_id].key_pos
	-- 				local tmp_goal_pos = ccp(pos[1], pos[2])
	-- 				self:goToDesitinaion(tmp_goal_pos, loopMove, index)
	-- 			end
	-- 		end 
	-- 		loopMove(0)
	-- 	else
	-- 		local tmp_goal_pos = ccp(goal_pos[1], goal_pos[2])
	-- 		self:goToDesitinaion(tmp_goal_pos, call_back)
	-- 	end 
	-- else
	-- 	local tmp_goal_pos = ccp(goal_pos[1], goal_pos[2])
	-- 	self:goToDesitinaion(tmp_goal_pos, call_back)
	-- end 	
end

function ClsExplorePirate:release()
	self:stopAutoHandler()
	if not tolua.isnull(self.map_icon) then
		self.map_icon:removeFromParentAndCleanup(true)
		self.map_icon = nil
	end
	ClsExplorePirate.super.release(self)
	self.childs = nil
	--TODO 
	self.land = nil
end

function ClsExplorePirate:createSailorName(parent, icon_pos)
	local label_name = createBMFont({text = self.item_info.name, fontFile = FONT_CFG_1, size = 14,
							color = ccc3(dexToColor3B(COLOR_GREEN)), x = icon_pos.x, y = icon_pos.y})
	parent:addChild(label_name)
	label_name:setAnchorPoint(ccp(0, 0.5))
	label_name:setColor(ccc3(dexToColor3B(COLOR_RED)))
	
	return label_name
end

function ClsExplorePirate:createName(item)
	local posX = -25
	local posY = 80
	if item.pirate_icon then
		self:createPirateIcon(self.ui, ccp(posX, posY))
	end

	self:createBossSailorIcon()

	posX = -5
	posY = 80
	if item.name then
		local label_name = self:createSailorName(self.ui, ccp(posX, posY))
		posY = posY + label_name:getContentSize().height/2 + 5
	end
end

function ClsExplorePirate:createPirateIcon(parent, icon_pos)
	local captain_bg = display.newSprite("#explore_captain_head_bg.png")
	captain_bg:setPosition(ccp(icon_pos.x, icon_pos.y))
	parent:addChild(captain_bg)
	
	local icon_sprite = display.newSprite("#explore_boss.png")
	local size = captain_bg:getContentSize()
	icon_sprite:setPosition(ccp(size.width / 2, size.height / 2))
	captain_bg:addChild(icon_sprite)		
	captain_bg:setScale(0.7)
end

function ClsExplorePirate:showShipDialog()
	if self.is_boss and not self.is_dialog then
		self.is_dialog = true
		local function back( )
			self.is_dialog = nil
		end
		EventTrigger(EVENT_EXPLORE_SHOW_SHIP_DIALOG, {txt = self.config.tips, seaman_id = self.config.sailor_id, duration = 6,
		ui_parent = self.ui,
		pos = ccp(90, -70),
		call_back = back})
	end
end

function ClsExplorePirate:createBossSailorIcon()
	if self.is_boss then
		local _bg, _sprite = self:createSailorIcon(self.ui, ccp(-40, 110))
		_bg:setZOrder(-1)
		_sprite:setZOrder(-1)
	end
end

function ClsExplorePirate:autoPath()
	if self.start_auto then
		self.end_auto = false
		self.start_auto = false
		local function back()
        	self.end_auto = true
        	self.start_auto = false
    	end
		self:beginFindPath({self.config.path[2][1], self.config.path[2][2]}, back)
	elseif self.end_auto then
		self.end_auto = false
		self.start_auto = false
		local function back()
        	self.end_auto = false
        	self.start_auto = true
    	end
		self:beginFindPath({self.config.path[1][1], self.config.path[1][2]}, back)
	end
end

function ClsExplorePirate:stopFindPath()
	self:stopAutoHandler()
end

function ClsExplorePirate:createEachPoint(path)
	
	if not path then
		return
	end 
	local path_len = #path
	
	local pos_len = path_len / 2
	local dx = ExploreUtil:getPosNum(path_len)
	local index = 1
	local ui = getExploreUI()
	
	while(true)
	do
		if index > path_len then
			break;
		end
		local x = path[index]
		local y = path[index + 1]
		if x and y then
			ui.world_map:createPiratePathIcons(ccp(x, y), self.event_id)
		end
		index = index + dx
	end
end

function ClsExplorePirate:createPathPoints()
	--common_point.png
	-- local pos_st = ccp(self.config.path[1][1], self.config.path[1][2])
	-- local pos_end = ccp(self.config.path[2][1], self.config.path[2][2])

	-- local path = ExploreUtil:createPathPoints(self.land.AStar, pos_st, pos_end)
	-- self:createEachPoint(path)
end

function ClsExplorePirate:addBossChild(child)
	self.childs[#self.childs + 1] = child
end

function ClsExplorePirate:childPirateMoveTo(child)
	local angle = self:getAngle()
	angle = angle + self.rotate_angle
	angle = Math.rad(angle)
	local distance = 200
	local tX, tY = child:getPos()

	local x, y = tX + distance * Math.sin(angle), tY + distance * Math.cos(angle)
	
	local pos_st = self.land:tileToCocos(ccp(x, y)) 

	child:stopAutoHandler()

	child:beginFindPath({pos_st.x, pos_st.y})
end

function ClsExplorePirate:updateChildPirate(dt)
	if self.is_boss then
		local size = 64
		local px , py = self:getPos()
		for _, ship in pairs(self.childs) do
			--ship:update(dt)
			self:childPirateMoveTo(ship)
		end
	end
end

function ClsExplorePirate:updateChildsPos(dt)
	--TODO 子类去重写---------------
	self:updateChildPirate(dt)
end

function ClsExplorePirate:setChildShipSpeed()
	if self.is_boss then
		for _, ship in pairs(self.childs) do
			ship:setSpeed(200)
		end
	end
end

function ClsExplorePirate:initPiratePos()
	print("time --------------", os.time(), self.start_time)
	local playerData = getGameData():getPlayerData()
	local dx_time = os.time() - self.start_time + playerData:getTimeDelta()
	--dx_time = Math.abs(dx_time)
	local pos_st = ccp(self.config.path[1][1], self.config.path[1][2])
	local pos_end = ccp(self.config.path[2][1], self.config.path[2][2])
	local path = ExploreUtil:createPathPoints(self.land.AStar, pos_st, pos_end)

	local init_pos = ExploreUtil:cocosToTile2(pos_st)
	local init_end = ExploreUtil:cocosToTile2(pos_end)

	local dis = Math.distance(init_pos.x / 30, init_pos.y / 30, init_end.x / 30, init_end.y / 30)
	local speed = self.config.speed / 35
	local total_time = Math.floor(dis / speed + 0.5)
	local max_index = #path / 2
	local current_index = 1

	local remainder = dx_time % total_time
	local n = (dx_time - remainder) / total_time

	if n >= 1 then
		if remainder > 0 then
			local per = remainder / total_time
			local index = Math.floor(per * max_index + 0.5)
			if n % 2 == 0 then
				self.end_auto = false
				self.start_auto = true
			else
				self.end_auto = true
				self.start_auto = false
				index = max_index - index
			end
			current_index = index
		else
			if n % 2 == 0 then
				self.end_auto = false
				self.start_auto = true
				current_index = 1
			else
				self.end_auto = true
				self.start_auto = false
				current_index = max_index - 1
			end			
		end
	else
		local m = dx_time / total_time
		local index = Math.floor(m * max_index + 0.5)
		current_index = index
		self.end_auto = false
		self.start_auto = true
	end
	if current_index <= 0 then
		current_index = 1
	end
	
	self.start_pos = ExploreUtil:cocosToTile2(ccp(path[2 * current_index - 1], path[2 * current_index]))
	self:setPos(self.start_pos.x, self.start_pos.y)
	path = nil
end

return ClsExplorePirate