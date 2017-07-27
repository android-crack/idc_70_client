---- 探索陆地
local commonBase  = require("gameobj/commonFuns")
local port_info = require("game_config/port/port_info")
local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
local explore_whirlpool = require("game_config/explore/explore_whirlpool")
local astar     = require("gameobj/explore/qAstar")
local UI_WORD = require("game_config/ui_word")
local tips = require("game_config/tips")
local relic_star_info = require("game_config/collect/relic_star_info")
local explore_map_event = require("game_config/explore/explore_map_event")
local explore_event = require("game_config/explore/explore_event")
local map_partition = require("game_config/explore/explore_map_partition")
local relicPanelView = require("gameobj/relic/relicInfoPanel")
local relic_info = require("game_config/collect/relic_info")
local explorePveItem = require("gameobj/explore/explorePveItemEntity")
local on_off_info=require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsExplorePortObject = require("gameobj/explore/explorePortObject")
local exploreObjectMgr = require("gameobj/explore/exploreObjectMgr")
local area_info = require("game_config/port/area_info")
local exploreMapUtil = require("module/explore/exploreMapUtil")

---------- ExploreLand -------------
local ITEM_INIT_DISTANCE  = 1.2*display.width  -- 事件初始距离

local shGuidePos = {
		[(UI_WORD.PVE_CP_SH_ONOFF_KEY)..1] = ccp(800, 183),
	}

local TIPS_POS = ccp(display.cx, 0.9 * display.cy)

local ClsBaseLand = require("gameobj/explore/baseLand")

local ExploreLand = class("ExploreLand", ClsBaseLand)

ExploreLand.ctor = function(self, parent)
	local param = {
		map_res = "explorer/map/land/land.tmx",
		bit_res = "explorer/map.bit",
		map_height = 960,
		map_width = 1695,
		parent = parent}
	self.super.ctor(self, param) --父类调用
	self.portObjects = {}
	self.shPveNodes = {}
    self.relicNodes = {}
	self.is_pause = false

	self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
		end
	end)
	
	self.decorate_layer = require("gameobj/explore/clsExploreLandDecorateLayer").new(self, parent)
	self:addChild(self.decorate_layer)

	self.pve_item_layer = explorePveItem.new(self.ship)
	self:addChild(self.pve_item_layer)

	self.port_pos = require("game_config/explore/port_pos")
	self.whirlpool_pos = require("game_config/explore/whirlpool_map_pos")
	self.relic_pos = require("game_config/explore/relic_map_pos")
	self.strongHold_pos = require("game_config/portPve/strongHold_pos")
	self.mineral_pos = require("game_config/explore/mineral_map_pos")

	self.map_event_mark = {} -- 保存 explore_map_event 中是否出现（包括已清除）
	self.map_event_item = {}

	self.pve_port_mark = {}
	self.pve_port_item = {}

	self.pve_sh_mark = {}
	self.pve_sh_item = {}

	self.pve_sh_astar_mark = {}
	self.pre_new_port = nil --上一次发现的新港口
	--self:calKeyPoint()
	--self:TestAstarAll()
end

local scheduler = CCDirector:sharedDirector():getScheduler()

-- 开始的一些初始化
ExploreLand.init = function(self)
	self:createPortNode(0,0)
	self:createExploreRelic()
	self:createPveExploreNode()

	self.pve_item_layer:update(0)
	self:updatePveExploreNode()

	self:updatePveExploreNodeGuilde()
	exploreObjectMgr.getInstance():update(0)

end

function ExploreLand:changeMapType(x,y,width,height,_type)
	if self.AStar then
		self.AStar:fixMap(x,y,width,height,_type)
	end
end


ExploreLand.pause = function(self, is_pause)
	self.is_pause = is_pause
	self.pve_item_layer:pause(is_pause)
	exploreObjectMgr.getInstance():setPause(is_pause)
end

ExploreLand.addToEffectLayer = function(self, node)
	local effect_layer = getUIManager():get("ClsExploreEffectLayer")
	if not tolua.isnull(effect_layer) then
		effect_layer:getAutoTipsLayer():addChild(node)
	end
end

ExploreLand.removeItem3D = function(self)
	self.ship = nil
	self.pve_item_layer:removeItem3D()

	UnRegTrigger(EVENT_EXPLORE_AUTO_SEARCH)
	UnRegTrigger(EVENT_EXPLORE_QUICK_ENTER_PORT)
	UnRegTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE)
	UnRegTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE_STATUS)
	UnRegTrigger(EVENT_EXPLORE_PVE_CPDATA_PORT_UPDATE)
	UnRegTrigger(EVENT_EXPLORE_PVE_CPDATA_SH_UPDATE)
end

ExploreLand.selectPortIcon = function(self, portId)
	local portPveData = getGameData():getPortPveData()
	if portPveData:isPortOpen(portId) then
		local port_object = self.portObjects[portId]
		if port_object then
			port_object:selectPveIcon()
		end
	end
end

ExploreLand.unSelectPortIcon = function(self, portId)
	local portPveData = getGameData():getPortPveData()
	if portPveData:isPortOpen(portId) then
		local port_object = self.portObjects[portId]
		if port_object then
			port_object:unSelectPveIcon()
		end
	end
end

-- 创建港口名字
ExploreLand.createPortNode = function(self, x, y)
	self.name_layer = CCLayer:create()
	self.name_layer:setPosition(x, y)
	self:addChild(self.name_layer)
	local name_size = 5
	local portPveData = getGameData():getPortPveData()
	local pveIcons = {}
	local camera = self.parent:getCamera()
	local explore_port_object = nil
	for k, v in pairs(port_info) do
		explore_port_object = ClsExplorePortObject.new(k)
		explore_port_object:setMenuCamera(camera)
		exploreObjectMgr.getInstance():addExploreObject(explore_port_object)
		self.portObjects[k] = explore_port_object
		self.name_layer:addChild(explore_port_object:getNode())
	end
end

ExploreLand.createPveExploreNode = function(self)
	local portPveData = getGameData():getPortPveData()
	for k, v in pairs(portPveData.strongHoldInfoDics) do
		self:updateShPveExploreNode(k)
	end
end

ExploreLand.updatePveExploreNode = function(self)
	local portPveData = getGameData():getPortPveData()
	for k, v in pairs(portPveData.openShInfoDics) do
		self:updateShPveExploreNode(k)
	end
end

ExploreLand.updatePveExploreNodeGuilde = function(self)
	for k, v in pairs(pve_stronghold_info) do
		self:updateShPveExploreNodeGuilde(k)
	end
end

ExploreLand.updateRelicPlaceNode = function(self)
	local function toPos(position)
	    local pos = self:cocosToTile2(position)
	    return pos
	end
    local ship_x, ship_y = self.ship:getPos()
    relicPanelView:updateExploreRelic(self.relicNodes, toPos, ship_x, ship_y, self.relic_icon_parent)
end

-- 创建遗迹icon
ExploreLand.createExploreRelic = function(self)
	self.relic_layer = CCLayer:create()
	self.relic_layer:setPosition(0, 0)
	self:addChild(self.relic_layer)
	self.relic_icon_parent = display.newSprite()
	self.relic_layer:addChild(self.relic_icon_parent)
    self:updateRelicPlaceNode()
end

function ExploreLand:eachBolckUpdate(dt) --
	--pve
	
	self.pve_item_layer:update(dt)
	self:updatePveExploreNode()
	self:updateRelicEvent()
	exploreObjectMgr.getInstance():update(dt)
	self:checkFindNewPort()
end

function ExploreLand:checkFindNewPort() --检测发现新港口
	local DIST = 400 / 64 --300像素换算成格子
	local ship_x, ship_y = self.ship:getPos()
	local ship_tile_pos = self:tileToCocos(ccp(ship_x,ship_y))
	for k, v in pairs(port_info) do
		local port_pos = ccp(v.name_pos[1],v.name_pos[2])
		local dist = Math.distance(ship_tile_pos.x, ship_tile_pos.y, port_pos.x, port_pos.y)
		local mapAttrs = getGameData():getWorldMapAttrsData()
		local can_find = true --是否可以发现新港口
		if not mapAttrs:isMapOpenPort(id) then --判断是否开启了
			if dist <= DIST then
				--在自动导航的时候 需要判断是否为目标港口，是才可以被发现，自动寻路过程中的其他港口都忽略不计
				-- if IS_AUTO == true then
				-- 	if (self.auto_info.navType == EXPLORE_NAV_TYPE_PORT and self.auto_info.id == k) then
				-- 		can_find = true
				-- 	end
				-- else -- 不是自动导航的时候都可以被发现
				-- 	can_find = true
				-- end
				if can_find then
					if self.pre_new_port ~= k then
						self.pre_new_port = k
						getGameData():getExploreData():sendFindNewPort(self.pre_new_port) -- 发送发现新港口
						--print("发现新港口",v.name,k)
						break
					end
				end

			end
		end
	end
end

ExploreLand.updateRelicEvent = function(self)
	local function toPos(position)
		local pos = self:cocosToTile2(position)
		return pos
	end
	local x, y = self.ship:getPos()
	local shipPos = ccp(x, y)
	local relicDataHandle = getGameData():getRelicData()
	local minDis, minRelicData, target_pos = relicDataHandle:findMinDistance(shipPos, toPos)
	if minDis > 0 and minDis < 960 then
		local on_off_info = require("game_config/on_off_info")
    	local is_relic_open = getGameData():getOnOffData():isOpen(on_off_info.YIJI_EXPLORE.value)
    	if is_relic_open then
			relicPanelView:createRelicAirBubbles(minRelicData, self.ship.ui, ccp(-25, 0), target_pos, self.ship)
		end
	else
		local relicActionLayer = relicPanelView:getActionLayer()
		if not tolua.isnull(relicActionLayer) then
			relicActionLayer:removeFromParentAndCleanup(true)
			relicActionLayer = nil
		end
	end
	self:updateRelicPlaceNode()
end

-- 检测碰撞 ：true 不能通过， false 能通过
function ExploreLand:checkHit(pos, d_pos)
	local pos = self.land:convertToNodeSpace(pos)
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	pos.x = pos.x + ex
	pos.y = pos.y + ey

	if not self:checkPoint(pos) then -- 边缘
		return true
	end

	local p = self:tileToCocos(pos)
	--pve海上据点
	local portPveData = getGameData():getPortPveData()
	local strongHold_key = p.x+p.y*self:getTitleWidth()
	local strongHold_ids = self.strongHold_pos[strongHold_key]
	if strongHold_ids ~= nil then
		for k,v in ipairs(strongHold_ids) do
			if portPveData:isStrongHoldOpen(v) then
				return true
			elseif portPveData:isStrongHoldCool(v) then
				return true
			elseif portPveData:isStrongHoldImmortal(v) then
				return true
			end
		end
	end

	local blockWeight = self.AStar:getWeight(p.x, p.y)
	if blockWeight ~= MAP_SEA then
		if blockWeight == MAP_LAND then  -- 陆地
			pos.x = pos.x + d_pos.x
			pos.y = pos.y + d_pos.y
			local p = self:tileToCocos(pos)
			if self.AStar:getWeight(p.x, p.y) == MAP_LAND then
				return true
			end
		end
	end
end

-- 检测此点是否在海面上/港口
function ExploreLand:checkPos(x, y, is_world)
    local blockWeight, pos = self.super.checkPos(self, x, y, is_world) --调用父类的
    if blockWeight == MAP_LAND then
    	local key = pos.x + pos.y * self:getTitleWidth()
        local port_id = self.port_pos[key]
        if port_id then  -- 对应的港口id
            return blockWeight, port_id
        end
        local relic_id = self.relic_pos[key]
        if relic_id then
            return blockWeight, nil, relic_id
        end
        local mineral_id = self.mineral_pos[key]
        if mineral_id then
            return blockWeight, nil, nil, nil, mineral_id
        end
    elseif pos then
    	local key = pos.x + pos.y * self:getTitleWidth()
        local whirlPool_id = self.whirlpool_pos[key]
        if whirlPool_id then
            return blockWeight, nil, nil, whirlPool_id
        end
    end

    return blockWeight
end


--------------------寻路------------------------

-- 根据位置返回区域id
local function getPartitionId(pos)
	for k, v in ipairs(map_partition) do
		local rect = CCRect(v.start_pos[1], v.start_pos[2], v.width, v.height)
		if rect:containsPoint(pos) then
			return k
		end
	end
end

ExploreLand.showDropAnchorTips = function(self, isCancle, isTreasure) --抛锚中字体
	local tipStr = tips[63].msg
	if isTreasure then
		tipStr = tips[75].msg
	end
	if tolua.isnull(self.dropShowLable) then
		self.dropShowLable = createBMFont({text = tipStr, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),fontFile = FONT_CFG_1, size = 16, x = TIPS_POS.x, y = TIPS_POS.y})
		self:addToEffectLayer(self.dropShowLable)
	else
		self.dropShowLable:setString(tipStr)
	end
	self.dropShowLable:setVisible(false)
	if isCancle then
		if not tolua.isnull(self.auto_lable) then
			self.auto_lable:setVisible(true)
		end
		if not tolua.isnull(self.dropShowLable) then
			self.dropShowLable:setVisible(false)
		end
	else
		if not tolua.isnull(self.auto_lable) then
			self.auto_lable:setVisible(false)
		end
		if not tolua.isnull(self.dropShowLable) then
			self.dropShowLable:setVisible(true)
		end
	end
end

-- 找到关键点
-- return nil 表示不经过任何关键点，直接导航
ExploreLand.findKeyPoint = function(self, pos_st, pos_end)
	local par_st = getPartitionId(pos_st)
	local par_end = getPartitionId(pos_end)
	if not par_st or not par_end then return end

	local is_inverse = false
	local map_key_point = require("game_config/explore/map_key_point")
	local key_tab = nil
	if map_key_point[par_st][par_end] then
		key_tab = map_key_point[par_st][par_end]
	elseif map_key_point[par_end][par_st] then
		key_tab = map_key_point[par_end][par_st]
		is_inverse = true
	else
		return
	end

	local key_tab_st = {}
	local key_tab_end = {}

	local index_st = nil
	local index_end = nil

	-- 找最佳关键点 （起始点和终点）
	if is_inverse then
		for k, pos in ipairs(key_tab) do
			local point = ccp(pos[1], pos[2])
			local par_id = getPartitionId(point)
			if par_id == par_st then
				if index_st == nil or index_st > k then
					index_st = k
				end
			elseif par_id == par_end then
				if index_end == nil or index_end < k then
					index_end = k
				end
			end
		end
		if index_st == nil or index_end == nil then return end
		index_st = index_st - 1
		index_end = index_end + 1
		if index_st < index_end then return end

	else
		for k, pos in ipairs(key_tab) do
			local point = ccp(pos[1], pos[2])
			local par_id = getPartitionId(point)
			if par_id == par_st then
				if index_st == nil or index_st < k then
					index_st = k
				end
			elseif par_id == par_end then
				if index_end == nil or index_end > k then
					index_end = k
				end
			end
		end
		if index_st == nil or index_end == nil then return end
		index_st = index_st + 1
		index_end = index_end - 1
		if index_st > index_end then return end
	end

	local key_path = {}

	if not is_inverse then
		for k = index_st, index_end, 1 do
			local pos = key_tab[k]
			table.insert(key_path, pos)
		end
	else
		for k = index_st, index_end, -1 do
			local pos = key_tab[k]
			table.insert(key_path, pos)
		end
	end

	return key_path
end

-- 导航寻路（包括计算关键点，把世界地图划分不同区域）
ExploreLand.beginFindPath = function(self, goal_pos, call_back)

	IS_AUTO = true   -- 是否自动导航
	local ui = getExploreUI()
	if not tolua.isnull(ui) then
		ui:releaseDropAchnor()
	end
	local p = self.land:convertToNodeSpace(ccp(display.cx, display.cy))  --把世界坐标转当前坐标系
	local cam = self.parent:getCamera()
	local ex, ey, ez = cam:getEyeXYZ(0,0,0)
	p.x = p.x + ex
	p.y = p.y + ey
	p = ccp(self.ship:getPos())
	local pos_st = self:tileToCocos(p) -- 开始坐标
	local pos_end = ccp(goal_pos[1], goal_pos[2])--ccp(port_info[port_id].ship_pos[1], port_info[port_id].ship_pos[2]) -- 港口位置
	local key_path = self:findKeyPoint(pos_st, pos_end)

	if key_path and #key_path > 0 then

		local loopMove
		loopMove = function(index)
			index = index + 1
			local pos = key_path[index]
			if not pos then
				local tmp_goal_pos = ccp(goal_pos[1], goal_pos[2])
				self:moveToPos(tmp_goal_pos, call_back)
			else
				local tmp_goal_pos = ccp(pos[1], pos[2])
				self:moveToPos(tmp_goal_pos, loopMove, index)
			end
		end
		loopMove(0)

	else
		local tmp_goal_pos = ccp(goal_pos[1], goal_pos[2])
		self:moveToPos(tmp_goal_pos, call_back)
	end
end

-- 自动跑到某个点
-- goal_pos目标点坐标（已经是land的坐标，无需转）
ExploreLand.moveToPos = function(self, goal_pos, call_back, param)
	local function searchPathStartCall()
		EventTrigger(EVENT_EXPLORE_PAUSE)
	end
	local function searchPathEndCall()
		if not tolua.isnull(getExploreLayer()) then
			getExploreLayer():endPauseExploreAndShip()
		end
	end
	self.super.moveToPos(self, goal_pos, call_back, param, searchPathStartCall, searchPathEndCall)
end

function ExploreLand:autoAfterUpdateUI(is_break)  --子类继承这个函数去更新界面
	--在 父类 的 breakAuto 中调用
	if not tolua.isnull(self.auto_lable) then
		self.auto_lable:removeFromParentAndCleanup(true)
		self.auto_lable = nil

		if is_break then -- 中断导航提示文字
			if not getGameData():getTeamData():isLock() then
				getExploreUI():lightBtnHelm()
        	end

			self.break_lable = createBMFont({text = tips[27].msg, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), size = 18, x = TIPS_POS.x, y = TIPS_POS.y - 22})
			self:addToEffectLayer(self.break_lable)
			local actions = {}
			actions[1] = CCDelayTime:create(3.0)
			actions[2] = CCCallFunc:create( function()
				self.break_lable:removeFromParentAndCleanup(true)
				self.break_lable = nil
			end)
			local action = transition.sequence(actions)
			self.break_lable:runAction(action)

			EventTrigger(EVENT_EXPLORE_CANCEL_GOAL_PORT)  --点击水纹中断
		end
	end
end

function ExploreLand:autoAfterRemoveResource()  --中断导航的事调用
	--在 父类 的 breakAuto 中调用
end

ExploreLand.updatePortExploreNode = function(self, portId)
	local port_object = self.portObjects[portId]
	if not port_object then
		port_object:updateUIByPve()
	end
end

function ExploreLand:updateAllPortExploreNode()
	for k, port_object in pairs(self.portObjects) do
		port_object:updateUIByPve()
	end
end

ExploreLand.updateShPveExploreNode = function(self, strongHoldId)
	local item_layer = self.pve_item_layer
	if not item_layer then return end
	local portPveData = getGameData():getPortPveData()
	local cpInfo = portPveData:getStrongHoldCpInfo(strongHoldId)

	if portPveData:isStrongHoldImmortal(strongHoldId) then
		if not self.pve_sh_astar_mark[strongHoldId] then
			self.pve_sh_astar_mark[strongHoldId] = true
			self.AStar:fixMap(cpInfo.name_pos[1]-1, cpInfo.name_pos[2], 3, 1, 0)
		end

		if self.pve_sh_item[strongHoldId] ~= nil and not self.pve_sh_item[strongHoldId].isOver then
			if not self.pve_sh_item[strongHoldId].isBroken then
				item_layer:brokenItem(self.pve_sh_item[strongHoldId])
			end
		else
			self.pve_sh_mark[strongHoldId] = false
			self.pve_sh_item[strongHoldId] = nil

			if not self.pve_sh_mark[strongHoldId] then
				local land_pos = self:cocosToTile2(ccp(cpInfo.name_pos[1], cpInfo.name_pos[2]))
				local x, y = self.ship:getPos()
				local dis = Math.distance(x, y, land_pos.x, land_pos.y)
				local needCreate = false
				if dis < ITEM_INIT_DISTANCE then
					needCreate = true
				end
				if needCreate then
					self.pve_sh_mark[strongHoldId] = true
					self.pve_sh_item[strongHoldId] = item_layer:createShItem(strongHoldId, land_pos, self.parent)
					item_layer:brokenItem(self.pve_sh_item[strongHoldId])
				end
			end
		end
	elseif portPveData:isStrongHoldFree(strongHoldId) then
		if self.pve_sh_astar_mark[strongHoldId] then
			self.pve_sh_astar_mark[strongHoldId] = false
			self.AStar:fixMap(cpInfo.name_pos[1]-1, cpInfo.name_pos[2], 3, 1, 1)
		end

		if self.pve_sh_item[strongHoldId] ~= nil then
			if not self.pve_sh_item[strongHoldId].isOver then
				item_layer:releaseItem(self.pve_sh_item[strongHoldId])
			end
			self.pve_sh_mark[strongHoldId] = false
			self.pve_sh_item[strongHoldId] = nil
		end
	elseif portPveData:isStrongHoldCool(strongHoldId) then
		if not self.pve_sh_astar_mark[strongHoldId] then
			self.pve_sh_astar_mark[strongHoldId] = true
			self.AStar:fixMap(cpInfo.name_pos[1]-1, cpInfo.name_pos[2], 3, 1, 0)
		end

		if self.pve_sh_item[strongHoldId] ~= nil and not self.pve_sh_item[strongHoldId].isOver then
			if not self.pve_sh_item[strongHoldId].isBroken then
				item_layer:brokenItem(self.pve_sh_item[strongHoldId])
			end
		else
			self.pve_sh_mark[strongHoldId] = false
			self.pve_sh_item[strongHoldId] = nil

			if not self.pve_sh_mark[strongHoldId] then
				local land_pos = self:cocosToTile2(ccp(cpInfo.name_pos[1], cpInfo.name_pos[2]))
				local x, y = self.ship:getPos()
				local dis = Math.distance(x, y, land_pos.x, land_pos.y)
				local needCreate = false
				if dis < ITEM_INIT_DISTANCE then
					needCreate = true
				end
				if needCreate then
					self.pve_sh_mark[strongHoldId] = true
					self.pve_sh_item[strongHoldId] = item_layer:createShItem(strongHoldId, land_pos, self.parent)
					item_layer:brokenItem(self.pve_sh_item[strongHoldId])
				end
			end
		end
	elseif portPveData:isStrongHoldOpen(strongHoldId) then
		if not self.pve_sh_astar_mark[strongHoldId] then
			self.pve_sh_astar_mark[strongHoldId] = true
			self.AStar:fixMap(cpInfo.name_pos[1]-1, cpInfo.name_pos[2], 3, 1, 0)
		end

		if self.pve_sh_item[strongHoldId] ~= nil and not self.pve_sh_item[strongHoldId].isOver then
			if self.pve_sh_item[strongHoldId].isBroken then
				item_layer:unBrokenItem(self.pve_sh_item[strongHoldId])
			end
		else
			self.pve_sh_mark[strongHoldId] = false
			self.pve_sh_item[strongHoldId] = nil

			if not self.pve_sh_mark[strongHoldId] then
				local land_pos = self:cocosToTile2(ccp(cpInfo.name_pos[1], cpInfo.name_pos[2]))
				local x, y = self.ship:getPos()
				local dis = Math.distance(x, y, land_pos.x, land_pos.y)
				local needCreate = false
				if dis < ITEM_INIT_DISTANCE then
					needCreate = true
				end
				if needCreate then
					self.pve_sh_mark[strongHoldId] = true
					self.pve_sh_item[strongHoldId] = item_layer:createShItem(strongHoldId, land_pos, self.parent)
				end
			end
		end
	end
end

ExploreLand.updateShPveExploreNodeGuilde = function(self, strongHoldId)
	local item_layer = self.pve_item_layer
	if not item_layer then return end
	local portPveData = getGameData():getPortPveData()
	if not portPveData:isStrongHoldOpen(strongHoldId) then
		return
	end

	local cpInfo = portPveData:getStrongHoldCpInfo(strongHoldId)

	--local pos = self:cocosToTile2(ccp(cpInfo.name_pos[1], cpInfo.name_pos[2]))

	local guildKey = UI_WORD.PVE_CP_SH_ONOFF_KEY..strongHoldId
	local runningScene = GameUtil.getRunningScene()
	if not tolua.isnull(runningScene) and on_off_info[guildKey] and shGuidePos[guildKey] then
		missionGuide:addGuideLayer(on_off_info[guildKey].value,
            {radius = 40 * 0.5, pos = {x = shGuidePos[guildKey].x, y = shGuidePos[guildKey].y}},
            {layer = runningScene, zorder = ZORDER_MISSION})
	end
end

ExploreLand.setMyShipWaiting = function(self, is_wait)
	if getGameData():getTeamData():isLock() then
		return
	end
	local explore_layer = getUIManager():get("ExploreLayer")
	if not tolua.isnull(explore_layer) then
		explore_layer:getPlayerShip():setPause(is_wait)
		explore_layer:getShipsLayer():setIsWaitingTouch(is_wait)
	end
end

ExploreLand.getDecorateLayer = function(self)
	return self.decorate_layer
end

ExploreLand.regFuns = function(self)
	local function autoSearch(goalInfo, is_keep_touch_info)  -- 自动导航
		local explore_layer = getUIManager():get("ExploreLayer")
		if not tolua.isnull(explore_layer) and (true ~= is_keep_touch_info) then
			explore_layer:getShipsLayer():setPlayerAttr("touch_something", nil)
			explore_layer:getShipsLayer():cleanMyShipMoveAttr()
		end

		if not goalInfo or not goalInfo.navType then
			return
		end
        if getGameData():getTeamData():isLock() then
            return
        end

        -- self.auto_info = goalInfo
		local exploreData = getGameData():getExploreData()

		local goalId = goalInfo.id
		local goalType = goalInfo.navType
		local goalCallBackTmp = goalInfo.callBack
		local _click = goalInfo.click
		local goalPos = nil
		local goalName = ""
		local goalCallBack = nil
		exploreData:setAutoPos({ })

		if goalType == EXPLORE_NAV_TYPE_PORT then
			goalCallBack = function()
				self:breakAuto()
				local auto_pos = exploreData:getAutoPos()
				local after_auto_pos = exploreData:getAfterAutoPos()
				if (not tolua.isnull(explore_layer)) and auto_pos and after_auto_pos and auto_pos.after_auto_key and (auto_pos.after_auto_key == after_auto_pos.after_auto_key) then
					after_auto_pos.after_auto_key = nil
					exploreData:setAutoPos(after_auto_pos)
					exploreData:setAfterAutoPos(nil)
					--补给完就自动下个港口
					local supplyData = getGameData():getSupplyData()
					supplyData:getSupplyConsumeCash()
					supplyData:askSupplyFull()
					explore_layer:continueAutoNavigation(true)
					return
				end
				local team_data = getGameData():getTeamData()
				if not team_data:isInTeam() or team_data:isTeamLeader() then -- 组队情况下，不触发战斗任务的完成和战斗
					--任务到港，不弹框
					local mission_data_handler = getGameData():getMissionData()
					mission_data_handler:askIfHaveBattle(nil, goalId)
					local is_mission_to_port = mission_data_handler:enterBattlePort(goalId)
					if is_mission_to_port then
						self:setMyShipWaiting(true)
						return
					end
				end
				
				local missionDataHandler = getGameData():getMissionData()
				missionDataHandler:askTeamMissionComplateStatus(goalId)

				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				self:setMyShipWaiting(true)
			end
			EventTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT, goalId, goalType)
			goalPos = port_info[goalId].ship_pos -- 港口位置
			goalName = port_info[goalId].name

			exploreData:setAutoPos({portId = goalId})
		elseif goalType == EXPLORE_NAV_TYPE_SH then
			goalCallBack = function()
				self:breakAuto()
				local portPveData = getGameData():getPortPveData()
				if not portPveData:isStrongHoldFree(goalId) then
					EventTrigger(EVENT_EXPLORE_SHOW_STRONGHOLD_INFO, goalId)
				else
					-- missionGuide:clearGuideMaskLayer()
				end
				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				self:setMyShipWaiting(true)
			end
			EventTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT, goalId, goalType)
			goalPos = pve_stronghold_info[goalId].ship_pos -- 海上据点位置
			goalName = pve_stronghold_info[goalId].name
			exploreData:setAutoPos({stronghoId = goalId})
		elseif goalType == EXPLORE_NAV_TYPE_LOOT then
			goalCallBack = function()
				self:breakAuto()
				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				self:setMyShipWaiting(true)
			end
			goalPos = goalInfo.pos -- 被掠夺船位置
			exploreData:setAutoPos({lootAuto = goalPos, lootAutoCallBack = goalCallBackTmp})
		elseif goalType == EXPLORE_NAV_TYPE_WHIRLPOOL then
			goalCallBack = function()
				self:breakAuto()
				EventTrigger(EVENT_EXPLORE_SHOW_WHIRLPOOL_INFO, goalId)
				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				self:setMyShipWaiting(true)
			end
			EventTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT, goalId, goalType)
			goalPos = explore_whirlpool[goalId].sea_pos -- 漩涡位置
			goalName = explore_whirlpool[goalId].name
			exploreData:setAutoPos({whirlPoolId = goalId})
		elseif goalType == EXPLORE_NAV_TYPE_POS then
			goalCallBack = function()
				self:breakAuto()
				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				self:setMyShipWaiting(true)
			end
			goalPos = goalInfo.pos -- 某个位置
			goalName = goalInfo.name
			if not goalName and goalPos then
				goalName = goalPos[1]..UI_WORD.SIGN_COMMA..goalPos[2]
			end
			exploreData:setAutoPos({pos = goalPos, name = goalInfo.name, callBack = goalCallBackTmp})
		elseif goalType == EXPLORE_NAV_TYPE_RELIC then
			goalCallBack = function()
				self:breakAuto()
				local auto_pos = exploreData:getAutoPos()
				local after_auto_pos = exploreData:getAfterAutoPos()
				if (not tolua.isnull(explore_layer)) and auto_pos and after_auto_pos and auto_pos.after_auto_key and (auto_pos.after_auto_key == after_auto_pos.after_auto_key) then
					after_auto_pos.after_auto_key = nil
					exploreData:setAutoPos(after_auto_pos)
					exploreData:setAfterAutoPos(nil)
					--补给完就自动下个港口
					local supplyData = getGameData():getSupplyData()
					supplyData:getSupplyConsumeCash()
					supplyData:askSupplyFull()
					explore_layer:continueAutoNavigation(true)
					return
				end
				
				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				local ClsExploreMap = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
				if ClsExploreMap and (not tolua.isnull(ClsExploreMap)) then
					if true == ClsExploreMap:isShowMax() then
						return
					end
				end

				local is_direct_show_relic = true
				local explore_layer = getExploreLayer()
				if not tolua.isnull(explore_layer) then
					local touch_info = explore_layer:getShipsLayer():getPlayerAttr("touch_something")
					if touch_info and (type(touch_info) == "table") and (touch_info.type == "touch_land_relic") and (touch_info.relic_id == goalId) then
						is_direct_show_relic = false
					end
				end

				local relic_data_handler = getGameData():getRelicData()
				local collect_data = getGameData():getCollectData()
				local cur_info = collect_data:getRelicInfoById(goalId)
				relic_data_handler:askCollectRelicArrive(goalId)
				if is_direct_show_relic then
					--自动导航
					if cur_info then
						require("gameobj/relic/RelicEnterAndSuplyView"):showDiscoverUi(cur_info)
					else
						if not cur_info then
							cur_info = collect_data:getConfigInfo(goalId)
						end
						getUIManager():create("gameobj/relic/RelicEnterAndSuplyView", nil, cur_info)
					end
				else
					if not cur_info then
						cur_info = collect_data:getConfigInfo(goalId)
					end
					getUIManager():create("gameobj/relic/RelicEnterAndSuplyView", nil, cur_info)
				end
				self:setMyShipWaiting(true)
			end
			EventTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT, goalId, goalType)
			goalPos = relic_info[goalId].ship_pos
			goalName = relic_info[goalId].name
			exploreData:setAutoPos({relicId = goalId})
        elseif goalType == EXPLORE_NAV_TYPE_TIME_PIRATE then
            goalCallBack = function()
                self:breakAuto()
                if goalCallBackTmp ~= nil then
                    goalCallBackTmp()
                end
                self:setMyShipWaiting(true)
            end
            EventTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT, goalId, goalType)
            local time_pirate_config = getGameData():getExplorePirateEventData():getTimePirateConfig()
            goalPos = time_pirate_config[goalId].sea_pos -- 遗迹位置
            goalName = time_pirate_config[goalId].name
            exploreData:setAutoPos({timePirateId = goalId})
        -- elseif goalType == EXPLORE_NAV_TYPE_MINERAL_POINT then
        --     goalCallBack = function()
        --         self:breakAuto()
        --         if goalCallBackTmp ~= nil then
        --             goalCallBackTmp()
        --         end
        --         self:setMyShipWaiting(true)
        --     end
        --     EventTrigger(EVENT_EXPLORE_SHOW_GOAL_PORT, goalId, goalType)
        --     local mineral_point_config =  getGameData():getAreaCompetitionData():getMineralPointConfig()
        --     goalPos = mineral_point_config[goalId].sea_pos
        --     goalName = mineral_point_config[goalId].name
        --     exploreData:setAutoPos({mineralId = goalId})
        elseif goalType == EXPLORE_NAV_TYPE_REWARD_PIRATE then
        	goalCallBack = function()
				self:breakAuto()
				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				self:setMyShipWaiting(true)
			end
			goalPos = goalInfo.pos
			goalName = UI_WORD.EXPLORE_REWARD_PIRATE_NAME
			exploreData:setAutoPos({pos = goalPos, name = goalInfo.name, callBack = goalCallBackTmp, is_reward_pirate = true})

        elseif goalType == EXPLORE_NAV_TYPE_SALVE_SHIP then
        	goalCallBack = function()
				self:breakAuto()
				if goalCallBackTmp ~= nil then
					goalCallBackTmp()
				end
				self:setMyShipWaiting(true)
			end
			goalPos = goalInfo.pos
			goalName = UI_WORD.EXPLORE_SALVE_SHIP_NAME
			exploreData:setAutoPos({pos = goalPos, name = goalInfo.name, callBack = goalCallBackTmp, is_salve_ship = true})
        end

		self:showDropAnchorTips(true)

		if not goalPos then
			return
		end

		-- print(goalPos[1],goalPos[2])

		-- local THUMB_TILE_SIZE = 15 --小地图的格子大小
		-- local THUMB_MULTIPLE = 32 --缩略图和大图的倍数关系
		-- local THUMB_TILE_MAX = 63 --小地图的最大列格子数

		-- local pos_point = ccp(math.floor(goalPos[1]/THUMB_TILE_SIZE*THUMB_MULTIPLE),math.floor((THUMB_TILE_MAX-goalPos[2]/THUMB_TILE_SIZE)*THUMB_MULTIPLE)) --转成ccp

		exploreData:setGoalInfo(table.clone(goalInfo))
		
		local pos_point = exploreMapUtil.landTileToThumbTile(ccp(goalPos[1],goalPos[2]))

		local area_id = getGameData():getExploreMapData():getSeaArea(pos_point)

		-- print("area_id:",area_id)
		if area_info[area_id] then
			local area_name = area_info[area_id].name
			goalName = area_name.."."..goalName
		end
		-- print("输出名字:",goalName)

		self:breakAuto() -- 先中断原先的寻路

		if not tolua.isnull(self.break_lable) then
			self.break_lable:removeFromParentAndCleanup(true)
			self.break_lable = nil
		end

		if tolua.isnull(self.auto_lable) then  -- 导航提示文字
			local tipStr = string.format(tips[10].msg,goalName)
			self.auto_lable = self:createEffectLabel(tipStr, TIPS_POS.x + 8, display.height - 87, "...")
			self:addToEffectLayer(self.auto_lable)
		end
		self:setMyShipWaiting(false)
		self:beginFindPath(goalPos, goalCallBack)
		getExploreUI():stopLightBtnHelm()
		getExploreUI():updateFood()
	end

	local function getAreaNameByPos(pos) -- 根据坐标位置获得所在的海域

	end

	local function quickEnterPort(port_id)  -- 直接进入港口
		if tolua.isnull(self) or not port_id then return end
		self:breakAuto()
		local exploreData = getGameData():getExploreData()
		exploreData:exploreOver()
		require("ui/dialogLayer").hideAllDialog()
		-- audioExt.stopMusic()
		getGameData():getWorldMapAttrsData():tryToEnterPort(port_id)
	end

	local function cpAllPveDataUdate(portDatas, strongHoldDatas)  -- 探索pve数据更新
		if tolua.isnull(self) then return end
		for k, v in pairs(portDatas) do
			self:updatePortExploreNode(v.portId)
		end
		for k, v in pairs(strongHoldDatas) do
			self:updateShPveExploreNode(v.strongholdId)
			self:updateShPveExploreNodeGuilde(v.strongholdId)
		end
	end

	local function cpAllPveDataStatus()
		if tolua.isnull(self) then return end
		self:updateAllPortExploreNode()
	end

	local function cpPortPveDataUdate(portId)
		if tolua.isnull(self) then return end
		self:updatePortExploreNode(portId)
	end

	local function cpShPveDataUdate(strongholdId)
		if tolua.isnull(self) then return end
		self:updateShPveExploreNode(strongholdId)
		self:updateShPveExploreNodeGuilde(strongholdId)
	end



	RegTrigger(EVENT_EXPLORE_AUTO_SEARCH, autoSearch)
	RegTrigger(EVENT_EXPLORE_QUICK_ENTER_PORT, quickEnterPort)
	RegTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE, cpAllPveDataUdate)
	RegTrigger(EVENT_EXPLORE_PVE_CPDATA_ALL_UPDATE_STATUS, cpAllPveDataStatus)
	RegTrigger(EVENT_EXPLORE_PVE_CPDATA_PORT_UPDATE, cpPortPveDataUdate)
	RegTrigger(EVENT_EXPLORE_PVE_CPDATA_SH_UPDATE, cpShPveDataUdate)
end

ExploreLand.calculateShipToPosDistance = function(self, goal_pos)
	local p = ccp(self.ship:getPos())
	local st_pos = self:tileToCocos(p) -- 开始坐标
	return self:calculatePosToPosDistance({st_pos.x, st_pos.y}, goal_pos)
end

--计算两个坐标之间的像素距离（已计算关键点）
--start_pos：开始点的格子坐标，例如start_pos = {10, 10}
--end_pos：结束点的格子坐标，例如end_pos = {100, 100}
ExploreLand.calculatePosToPosDistance = function(self, start_pos, end_pos)
	if not start_pos or not end_pos then return 0 end
	if #start_pos ~= 2 or #end_pos ~= 2 then return 0 end

	local calculateDistance = function(pos1, pos2)
		local path_index = 1
		local distance = 0
		-- wmh todo 要去掉兼容
		local path = self.AStar:searchPath(pos1[1], pos1[2], pos2[1], pos2[2], 1) or {}  --路径
		local path_len = #path
		local tmp_pos1 = nil
		local tmp_pos2 = nil

		for k=1,path_len do
			if (path_index + 3) > path_len then
				break
			end
			tmp_pos1 = self:cocosToTile2(ccp(path[path_index], path[path_index + 1]))
			tmp_pos2 = self:cocosToTile2(ccp(path[path_index + 2], path[path_index + 3]))
			distance = distance + Math.distance(tmp_pos1.x, tmp_pos1.y, tmp_pos2.x, tmp_pos2.y)
			path_index = path_index + 2
		end
		return distance
	end

	local all_distance = 0
	local pos_st = ccp(start_pos[1], start_pos[2])
	local pos_end = ccp(end_pos[1], end_pos[2])
	local key_path = self:findKeyPoint(pos_st, pos_end)

	local cur_pos = start_pos
	local next_pos = end_pos

	if key_path and #key_path > 0 then
		for index = 1 , #key_path do
			next_pos = key_path[index]
			all_distance = all_distance + calculateDistance(cur_pos, next_pos)
			cur_pos = next_pos
		end
		all_distance = all_distance + calculateDistance(cur_pos, end_pos)
	else
		all_distance = calculateDistance(start_pos, end_pos)
	end

	return all_distance
end


ExploreLand.onExit = function(self)
	exploreObjectMgr.pure()
	self.super.remove2dResource(self)
end

-------------------------------------------------------------------------
-- 测试

ExploreLand.portEnterPort = function(self, pos_st, pos_end)
	local last_pos = pos_st
	local goal_pos = pos_st

	local key_path = self:findKeyPoint(pos_st, pos_end)
	if key_path and #key_path > 0 then
		local loopMove
		loopMove = function(index)
			index = index + 1
			local pos = key_path[index]
			if not pos then
				self:moveToPortExt(goal_pos, pos_end)
			else
				last_pos = goal_pos
				goal_pos = ccp(pos[1], pos[2])
				self:moveToPosExt(last_pos, goal_pos, loopMove, index)
			end
		end
		loopMove(0)

	else
		self:moveToPortExt(last_pos, pos_end)
	end
end

-- 导航到某个港口
ExploreLand.moveToPortExt = function(self, start_pos, end_pos)
	local pos_st = start_pos
	local pos_end = end_pos
	local path = self.AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1)  --路径
end

-- 自动跑到某个点
-- goal_pos目标点坐标（已经是land的坐标，无需转）
ExploreLand.moveToPosExt = function(self, start_pos, goal_pos, call_back, index)
	local pos_st = start_pos
	local pos_end = goal_pos
	local path = self.AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1)  --路径
	if call_back then
		call_back(index)
	end
end

ExploreLand.TestAstar = function(self)

	local max_i, max_j
	local max_time = 0

	local log_str = {}

	for i = 1, #port_info do
		for j = i+1 , #port_info do
			local time_temp = os.clock()

			local pos_st = ccp(port_info[i].ship_pos[1], port_info[i].ship_pos[2])
			local pos_end = ccp(port_info[j].ship_pos[1], port_info[j].ship_pos[2])

			self:portEnterPort(pos_st, pos_end)
			local dtime = os.clock() - time_temp
			if max_time < dtime then
				max_time = dtime
				max_i = i
				max_j = j
			end
			local str = string.format(T("港口 %d 到 港口 %d 寻路花费时间：%f\n"), i,j,dtime)
			table.insert(log_str, str)
			print(str)
		end
	end

	local str = string.format(T("最坏情况：港口 %d 到 港口 %d 寻路花费时间：%f\n"), max_i,max_j,max_time)
	print(str)
	table.insert(log_str, str)
	require("transfrom/tableTrans")
	table.save_map(log_str, "scripts/TestAstar.lua")
end

ExploreLand.TestAstarAll = function(self)

	local max_i, max_j
	local max_time = 0

	local log_str = {}

	local port_len = #port_info
	local relic_len = #relic_info
	local data = {}
	for k, v in ipairs(port_info) do
		table.insert(data, v)
	end
	for k, v in ipairs(relic_info) do
		table.insert(data, v)
	end

	for i = 1, #data do
		for j = i+1 , #data do
			local time_temp = os.clock()

			local pos_st = ccp(data[i].ship_pos[1], data[i].ship_pos[2])
			local pos_end = ccp(data[j].ship_pos[1], data[j].ship_pos[2])

			self:portEnterPort(pos_st, pos_end)
			local dtime = os.clock() - time_temp
			if max_time < dtime then
				max_time = dtime
				max_i = i
				max_j = j
			end

			local s1 = ""
			local s2 = ""
			if i > port_len then
				s1 = string.format("遗迹 %d", i - port_len)
			else
				s1 = string.format("港口 %d", i)
			end

			if j > port_len then
				s2 = string.format("遗迹 %d", j - port_len)
			else
				s2 = string.format("港口 %d", j)
			end


			local str = string.format(T("%s 到	%s 寻路花费时间：%f\n"), s1,s2,dtime)
			table.insert(log_str, str)
			print(str)
		end
	end

	if max_i > port_len then
		s1 = string.format("遗迹 %d", max_i - port_len)
	else
		s1 = string.format("港口 %d", max_i)
	end

	if max_j > port_len then
		s2 = string.format("遗迹 %d", max_j - port_len)
	else
		s2 = string.format("港口 %d", max_j)
	end

	local str = string.format(T("%s 到	%s 寻路花费时间：%f\n"), s1,s2,max_time)
	print(str)
	table.insert(log_str, str)
	require("transfrom/tableTrans")
	table.save_map(log_str, "scripts/TestAstar.lua")
end



-- 导出关键点
ExploreLand.calKeyPoint = function(self)
	require("transfrom/tableTrans")
	local key_tab = {}
	local key_step = 80
	local part_num = #map_partition

	for key , v in ipairs(map_partition) do
		key_tab[key] = {}
		for k = key+1, part_num do
			print("正在导关键点中...", key, k)
			if map_partition[key].nest_partition[k] then

			else
				key_tab[key][k] = {}
				local pos_st = map_partition[key].key_pos
				local pos_end = map_partition[k].key_pos
				table.insert(key_tab[key][k], pos_st)
				local path = self.AStar:searchPath(pos_st[1], pos_st[2], pos_end[1], pos_end[2], 1)
				local len = #path
				local i = key_step*2
				while(i < len) do
					table.insert(key_tab[key][k], {path[i-1], path[i]})
					i = i + key_step*2
				end
				table.insert(key_tab[key][k], pos_end)
			end
		end
	end

	table.print(key_tab)
	table.save(key_tab, "scripts/game_config/explore/map_key_point.lua")
end

return ExploreLand
