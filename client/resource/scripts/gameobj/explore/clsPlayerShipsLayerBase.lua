--2016/05/23
--create by wmh0497
--用于显示在探索里同步的玩家船

local TILE_SIZE = 64
local WIDTH_BLOCK =  8--15 + 4
local HEIGHT_BLOCK = 5--9 + 3 --8.4375

local WIDTH_OUT_BLOCK =  10
local HEIGHT_OUT_BLOCK = 7

local MAX_SHIP_COUNT = 10 --每个排序分类的同屏显示人数

local WAIT_SEND_STOP_FOOD_TIME = 2

local shipEntity = require("gameobj/explore/exploreShip3d")
local ClsExploreShipsTouchManage = require("gameobj/explore/exploreShipsTouchManage")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")

local ClsPlayerShipsLayerBase = class("ClsPlayerShipsLayerBase", function() return CCLayer:create() end)

function ClsPlayerShipsLayerBase:ctor(parent)
	self.m_player_ships = {}
	self.m_ship_pool = {}
	self.m_parent = parent
	self.m_player_ship = parent:getPlayerShip()   -- 玩家船
	self.m_player_ship.land = self.m_parent:getLand()
	self.m_ship_data = getGameData():getExplorePlayerShipsData()
	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
	self.m_my_player_ship_pos = {x = 0, y = 0, tx = -1, ty = -1}
	self.m_teleporting_limit_dis = 330
	self:registerScriptHandler(function(event)
		if event == "enter" then
			self:onEnter()
		elseif event == "exit" then
			self:onExit()
		end
	end)
	self:initMapConfig()
	self.m_land_height = self.m_tile_height * TILE_SIZE
	self.m_max_show_ship_count = MAX_SHIP_COUNT

	self.m_my_ship_up_pos_info = {}
	self.m_my_ship_up_pos_info.time = 1
	local ptx, pty = self:cocosToTile(self.m_player_ship:getPos())
	self.m_my_ship_up_pos_info.last_target_tpos = {tx = ptx, ty = pty}
	self.m_my_ship_up_pos_info.tpos_record = {}
	self.m_my_ship_up_pos_info.touch_pos = nil
	self.m_my_ship_up_pos_info.is_arrive_point_stop = false

	self.m_my_ship_stop_info = {}
	self.m_my_ship_stop_info.is_waiting_touch = true
	self.m_my_ship_stop_info.stop_reason_count = 0
	self.m_my_ship_stop_info.stop_reasons = {}

	self.m_food_stop_info = {}
	self.m_food_stop_info.is_open = false
	self.m_food_stop_info.is_send_stop = false
	self.m_food_stop_info.send_waiting_time = 0
	self.m_food_stop_info.stop_reason_count = 0
	self.m_food_stop_info.stop_reasons = {}

	self.m_player_attr = {}

	self.m_touch_manage = ClsExploreShipsTouchManage.new()
	self.m_touch_manage:init(self.m_parent, self)
	self.m_player_ship:setSpeedRate(0)
	self.m_player_ship:setPause(true)
	self:updateMyShipAllStatus()
	self.m_ship_data:askMyShipInfo()
	self.m_dt_time = 0
	
	if getGameData():getSceneDataHandler():isInExplore() then
		getGameData():getSupplyData():askIsStopFood(false)
	end
end

function ClsPlayerShipsLayerBase:initMapConfig()
	self.m_tile_width  = 1695
	self.m_tile_height = 960
end

function ClsPlayerShipsLayerBase:getTouchManage()
	return self.m_touch_manage
end

function ClsPlayerShipsLayerBase:touchShip(node)
	if not node then return end
	local index = node:getTag("playerShipsLayerBase")
	if not index then return end
	local uid = tonumber(index)
	local ship = self:getShipWithMyShip(uid)
	if ship then
		return self.m_touch_manage:touchShip(uid, ship)
	end
end

function ClsPlayerShipsLayerBase:onEnter()
end

function ClsPlayerShipsLayerBase:onExit()
	for _, v in pairs(self.m_player_ships) do
		v:release()
	end
	self.m_player_ships = {}
	for _, list in pairs(self.m_ship_pool) do
		for _, v in pairs(list) do
			v:release()
		end
	end
	self.m_ship_pool = {}
	self.m_player_ship = nil
	self.m_touch_manage:release()
	self.m_touch_manage = nil
end

function ClsPlayerShipsLayerBase:tileToCocos(x, y)
	return x*TILE_SIZE + TILE_SIZE/2, self.m_land_height - y*TILE_SIZE - TILE_SIZE/2
end

function ClsPlayerShipsLayerBase:cocosToTile(x, y)
	return Math.floor(x/TILE_SIZE), Math.floor((self.m_land_height - y)/TILE_SIZE)
end

function ClsPlayerShipsLayerBase:isInMyShipsView(ptx, pty, pos_info)
	if (pos_info.tx <= (ptx + WIDTH_BLOCK)) and (pos_info.tx >= (ptx - WIDTH_BLOCK))
		and (pos_info.ty <= (pty + HEIGHT_BLOCK)) and (pos_info.ty >= (pty - HEIGHT_BLOCK)) then

		return true
	end

	if (pos_info.dx <= (ptx + WIDTH_BLOCK)) and (pos_info.dx >= (ptx - WIDTH_BLOCK))
		and (pos_info.dy <= (pty + HEIGHT_BLOCK)) and (pos_info.dy >= (pty - HEIGHT_BLOCK)) then

		return true
	end
	return false
end

ClsPlayerShipsLayerBase.update = function(self, dt)
	if not self.m_player_ship then
		return
	end
	local px, py = self.m_player_ship:getPos()
	local ptx, pty = self:cocosToTile(px, py)
	
	local is_tpos_change = false
	if ptx ~= self.m_my_player_ship_pos.tx or pty ~= self.m_my_player_ship_pos.ty then
		is_tpos_change = true
	end
	
	self.m_my_player_ship_pos.x = px
	self.m_my_player_ship_pos.y = py
	self.m_my_player_ship_pos.tx = ptx
	self.m_my_player_ship_pos.ty = pty
	self.m_dt_time = dt
	
	self:updateMyShipHander(dt)
	if is_tpos_change then self:updateBolck(ptx, pty) end
	
	local my_pos_info = self.m_ship_data:getPosInfo(self.m_my_uid)
	local ship_count = 0
	local out_ship_ids = {}
	self.m_ship_data:checkShowListAllUid(function(uid, is_in_team, is_leader)
			local pos_info = self.m_ship_data:getPosInfo(uid)
			if not pos_info then return end
			local ship = self.m_player_ships[uid]
			local is_in_screen = self:isInMyShipsView(ptx, pty, pos_info)
			if not ship then
				if is_in_screen then
					--检查是否存在了用户的数据
					self.m_ship_data:checkPlayerDetailInfo(uid)
				end
			end
			
			if (not is_in_screen) and my_pos_info then
				if my_pos_info.leader_uid and my_pos_info.leader_uid > 0 then
					if my_pos_info.leader_uid == pos_info.leader_uid then
						is_in_screen = true
					end
				end
			end
			
			if is_in_screen and (ship_count < self.m_max_show_ship_count) then
				if not ship then
					ship = self:createShip(uid)
				end
				ship:update(dt)
				self:updateShipInfo(uid, ship, is_in_team, is_leader)
				ship_count = ship_count + 1
			else
				self:removeUselessShip(uid)
			end
			if my_pos_info then
				self:checkIsFarRemove(out_ship_ids, ptx, pty, my_pos_info, pos_info, uid, is_in_team, is_leader)
			end
		end)
	for _, remove_uid in ipairs(out_ship_ids) do
		print("remove_uid ====", remove_uid)
		self.m_ship_data:removeShipInfo(nil, remove_uid)
	end
end

function ClsPlayerShipsLayerBase:isRemoveShipInfo(my_pos_info, pos_info)
	if (pos_info.dx <= (my_pos_info.dx + WIDTH_OUT_BLOCK)) and (pos_info.dx >= (my_pos_info.dx - WIDTH_OUT_BLOCK))
		and (pos_info.dy <= (my_pos_info.dy + HEIGHT_OUT_BLOCK)) and (pos_info.dy >= (my_pos_info.dy - HEIGHT_OUT_BLOCK)) then
		return false
	end
	return true
end

local table_insert = table.insert
function ClsPlayerShipsLayerBase:checkIsFarRemove(remove_tabs, ptx, pty, my_pos_info, pos_info, uid, is_in_team, is_leader)
	if my_pos_info.leader_uid and my_pos_info.leader_uid > 0 then
		if my_pos_info.leader_uid == pos_info.leader_uid then
			return
		end
	end
	
	local is_data_out = false
	if is_in_team then
		if is_leader then
			if self:isRemoveShipInfo(my_pos_info, pos_info) then
				is_data_out = true
			end
		end
	else
		if self:isRemoveShipInfo(my_pos_info, pos_info) then
			is_data_out = true
		end
	end
	
	if is_data_out then
		local far_auto_remove_count = self.m_ship_data:getAttr(uid, "far_auto_remove_count")
		if not far_auto_remove_count then
			self.m_ship_data:setAttr(uid, "far_auto_remove_count", 0)
		end
	end
	local far_auto_remove_count = self.m_ship_data:getAttr(uid, "far_auto_remove_count")
	if far_auto_remove_count then
		--更新移除时间
		far_auto_remove_count = far_auto_remove_count + self.m_dt_time
		self.m_ship_data:setAttr(uid, "far_auto_remove_count", far_auto_remove_count)
		--一秒后开移啦
		if far_auto_remove_count > 1 then
			if self:isInRemoveState(uid) then
				if is_in_team then
					local member_uids = self.m_ship_data:getTeamMemberUids(uid)
					table_insert(remove_tabs, uid)
					for _, member_uid in pairs(member_uids) do
						table_insert(remove_tabs, member_uid)
					end
				else
					table_insert(remove_tabs, uid)
				end
			end
		end
	end
end

function ClsPlayerShipsLayerBase:isInRemoveState(uid)
	local ship = self:getShipByUid(uid)
	if ship then
		return ship:isPause()
	end
	return true
end

--给子类重写
function ClsPlayerShipsLayerBase:updateShipInfo(uid, ship, is_in_team, is_leader)

end

function ClsPlayerShipsLayerBase:getShipByUid(uid)
	return self.m_player_ships[uid]
end

function ClsPlayerShipsLayerBase:getShipWithMyShip(uid)
	if uid == self.m_my_uid then
		return self.m_player_ship
	end
	return self:getShipByUid(uid)
end

--创建进入视野的船
function ClsPlayerShipsLayerBase:createShip(uid)
	local ship_id = self.m_ship_data:getShipId(uid)
	local ship = self:getShipFromPool(ship_id)
	local param = self:getShipParam(uid)
	if not ship then
		ship = shipEntity.new(param)
	else
		ship:setPos(param.pos.x, param.pos.y)
		ship:resetNameInfo(param)
		ship:setActive(true)
	end

	if self.m_ship_data:isJionCamp() then
		ship:setIsGhost(false)	
	end

	ship.land = self.m_parent:getLand()
	ship.create_ship_id = ship_id
	ship.node:setTag("playerShipsLayerBase", tostring(uid))
	local pos_info = self.m_ship_data:getPosInfo(uid)
	if pos_info then
		local pos_x, pos_y = self:tileToCocos(pos_info.dx, pos_info.dy)
		ship:setPos(pos_x, pos_y)
	end
	ship:setPause(true)
	ship:setSpeed(param.speed)
	ship:updateStatus(param.star_level)

	self.m_player_ships[uid] = ship
	self:updateShipStatus(uid)
	self:updateTeamStatus(uid)

	return ship
end

function ClsPlayerShipsLayerBase:getShipParam(uid)
	local ship_id = self.m_ship_data:getShipId(uid)
	local playersDetailData = getGameData():getPlayersDetailData()
	local pos_info = self.m_ship_data:getPosInfo(uid)
	local param = {
			id = ship_id,
			pos = ccp(self:tileToCocos(pos_info.tx, pos_info.ty)),
			speed = EXPLORE_BASE_SPEED,
			name = playersDetailData:getPlayerName(uid),
			turn_speed = boat_attr[ship_id].angle,
			ship_ui = self:getPlayerShipUI(),
			player_uid = uid,
			icon = playersDetailData:getPlayerIcon(uid),
			role_id = playersDetailData:getPlayerRoleId(uid),
			player_level = playersDetailData:getPlayerLv(uid),
			title = playersDetailData:getPlayerTitle(uid),
			prosper_level = playersDetailData:getPlayerInfoNobility(uid),
			star_level = self.m_ship_data:getShipStarLevel(uid),
			guild_name = playersDetailData:getPlayerGuildName(uid),
			guild_job = playersDetailData:getPlayerGuildJob(uid),
			guild_icon = playersDetailData:getPlayerGuildIcon(uid),
			is_vip_wave = self.m_ship_data:isVipWave(uid),
		}
	param.name_color = self.m_ship_data:getCampNameColor(uid)
	return param
end

function ClsPlayerShipsLayerBase:getPlayerShipUI()
	return getShipUI()
end

function ClsPlayerShipsLayerBase:updateShipUi(uid)
	local ship = self.m_player_ships[uid]
	if ship then
		local param = self:getShipParam(uid)
		ship:resetNameInfo(param)
		ship:setSpeed(param.speed)
		self:updateShipStatus(uid)
		self:updateTeamStatus(uid)
	elseif self.m_my_uid == uid then
		self:updateMyShipAllStatus()
	end
end

--更新船状态
function ClsPlayerShipsLayerBase:updateShipStatus(uid)
	local ship = self:getShipWithMyShip(uid)
	if ship then
		ship:setIsFighting(self.m_ship_data:isFighting(uid))
		if self.m_ship_data:isJionCamp() then
			ship:setIsGhost(self.m_ship_data:isGhostStatus(uid))
			ship:updatePlayerNameColor(self.m_ship_data:getCampNameColor(uid))
		else
			ship:setIsRedNameStatus(self.m_ship_data:isRedNameStatus(uid))
		end
		ship:setIsShowVipWave(self.m_ship_data:isVipWave(uid))
		--更新玩家自己船的流光状态， 其他船的不更，太消耗性能
		if self.m_my_uid == uid then
			ship:updateStatus(self.m_ship_data:getShipStarLevel(uid))
		end
	end
end

function ClsPlayerShipsLayerBase:updateAllShipStatus()
	for uid, _ in pairs(self.m_player_ships) do
		self:updateShipStatus(uid)
	end
	self:updateShipStatus(self.m_my_uid)
end

function ClsPlayerShipsLayerBase:updateTeamStatus(uid)
	local ship = self:getShipWithMyShip(uid)
	local pos_info = self.m_ship_data:getPosInfo(uid)
	if ship and pos_info then
		local is_in_team = false
		local is_leader = false
		if pos_info.leader_uid then
			is_in_team = true
			if pos_info.leader_uid == uid then
				is_leader = true
			end
		end
		--判断是否加ai
		if is_in_team and not is_leader then
			if ship:isAddAI() then
				ship:initAI()
			end
			local target_uid = self.m_ship_data:getTeamFollowUid(uid)
			if target_uid then
				ship:setFollowAI(target_uid, function(uid)
					return self:getShipWithMyShip(uid)
				end, function()
					return self:tryUpdateShipPos(uid)
				end)
			end
		else --清除ai
			if ship:isAddAI() then
				ship:initAI()
			end
		end

		if is_in_team and is_leader then
			ship:createLeaderIcon()
		else
			ship:clearLeaderIcon()
		end
	end
end

function ClsPlayerShipsLayerBase:getShipFromPool(ship_id)
	local target_ship_list = self.m_ship_pool[ship_id]
	if target_ship_list and #target_ship_list > 0 then
		local index = #target_ship_list
		local ship = target_ship_list[index]
		table.remove(target_ship_list, index)
		return ship
	end
end

function ClsPlayerShipsLayerBase:removeUselessShip(uid)
	if self.m_player_ships[uid] then
		--放到pool里
		local ship = self.m_player_ships[uid]
		local ship_id = ship.create_ship_id
		if not self.m_ship_pool[ship_id] then
			self.m_ship_pool[ship_id] = {}
		end
		local target_ship_list = self.m_ship_pool[ship_id]
		target_ship_list[#target_ship_list + 1] = ship
		ship:setActive(false)
		ship:setIsFighting(false)
		ship:initAI()
		ship:removeScheduler()
		self.m_player_ships[uid] = nil

		local explore_ui = getExploreUI()
		if not tolua.isnull(explore_ui) then
			local explore_player_ui = explore_ui:getExplorePlayerUI()
			if not tolua.isnull(explore_player_ui) then
				explore_player_ui:hideSelectUiByUid(uid) --通知ui，有船被移除啦
			end
		end
	end
end

function ClsPlayerShipsLayerBase:moveToTPos(move_pos_info)
	local my_uid = getGameData():getPlayerData():getUid() or 0
	if my_uid == move_pos_info.uid then
		self:myShipMoveEvent(move_pos_info)
		return
	end
	local ship = self.m_player_ships[move_pos_info.uid]
	if ship then
		ship:setPause(false)
		ship:moveToTPos(move_pos_info.dx, move_pos_info.dy, true, TILE_SIZE, function()
				local ship = self.m_player_ships[move_pos_info.uid]
				if ship then
					ship:setPause(true)
				end
			end)
	end
end

function ClsPlayerShipsLayerBase:reEnterLayer(uid)
	self:tryUpdateShipPos(uid, self.m_teleporting_limit_dis)
	if self.m_my_uid == uid then
		self:updateMyShipAllStatus()
	end
	self:updateTeamStatus(uid)
end

function ClsPlayerShipsLayerBase:tryUpdateShipPos(uid, keep_dis)
	keep_dis = keep_dis or 100
	local pos_info = self.m_ship_data:getPosInfo(uid)
	if not pos_info then
		return
	end
	local ship = self.m_player_ships[uid]
	local target_x, target_y = self:tileToCocos(pos_info.tx, pos_info.ty)
	if ship then
		ship:stopAutoHandler()
		local px, py = ship:getPos()
		if Math.distance(target_x, target_y, px, py) > keep_dis then
			ship:stopAutoHandler()
			ship:setPos(target_x, target_y)
			ship:setPause(true)
		end
	elseif self.m_my_uid == uid then
		local px, py = self.m_player_ship:getPos()
		if Math.distance(target_x, target_y, px, py) > keep_dis then
			self:myShipChangePos(pos_info.tx, pos_info.ty)
		end
	end
end

--下面的函数是我自己的船的控制
function ClsPlayerShipsLayerBase:updateBolck(tx, ty)
end

function ClsPlayerShipsLayerBase:updateMyShipHander(dt)
	--下面的发位置数据的东东
	self:updateMyShipSpeedHander(dt)
	self:updateMyShipFoodStopHander(dt)
	self:updateMyShipUpPosHander(dt)
end

function ClsPlayerShipsLayerBase:updateMyShipSpeedHander(dt)
	if not getGameData():getTeamData():isLock() then
		self.m_player_ship:setSpeedRate(self:getMyShipNormalSpeedRate())
	end
end

--触发了这个功能之后，延迟两秒发送暂停补给
function ClsPlayerShipsLayerBase:updateMyShipFoodStopHander(dt)
	if getGameData():getTeamData():isLock() then return end
	if self.m_food_stop_info.is_open then
		if self.m_food_stop_info.stop_reason_count > 0 then
			if not self.m_food_stop_info.is_send_stop then
				if self.m_food_stop_info.send_waiting_time >= WAIT_SEND_STOP_FOOD_TIME then
					self.m_food_stop_info.is_send_stop = true
					getGameData():getSupplyData():askIsStopFood(true)
					self.m_food_stop_info.send_waiting_time = 0
				else
					self.m_food_stop_info.send_waiting_time = self.m_food_stop_info.send_waiting_time + dt
				end
			end
		else
			self.m_food_stop_info.send_waiting_time = 0
			if self.m_food_stop_info.is_send_stop then
				self.m_food_stop_info.is_send_stop = false
				getGameData():getSupplyData():askIsStopFood(false)
			end
		end
	end
end

function ClsPlayerShipsLayerBase:updateMyShipUpPosHander(dt)
	self.m_my_ship_up_pos_info.time = self.m_my_ship_up_pos_info.time + dt
	if self.m_my_ship_up_pos_info.time >= 1 then
		self.m_my_ship_up_pos_info.time = 0
		self:askToMoveForward()
	end
end

function ClsPlayerShipsLayerBase:fastUpMyShipPos(is_force_up)
	if true == is_force_up then
		self.m_my_ship_up_pos_info.time = 0
		self:askToMoveForward(is_force_up)
	else
		self.m_my_ship_up_pos_info.time = 1
		self:updateMyShipUpPosHander(0)
	end
end

--获取当前应该正常的船的速度
function ClsPlayerShipsLayerBase:getMyShipNormalSpeedRate()
	if self.m_my_ship_stop_info.is_waiting_touch then
		return 0
	end
	if self.m_my_ship_stop_info.stop_reason_count > 0 then
		return 0
	end
	return 1
end

function ClsPlayerShipsLayerBase:setMyShipMoveDir(screen_x, screen_y)
	local target_x, target_y = self.m_parent:getLand():getPosInLand(screen_x, screen_y)
	local pos_x, pos_y = self.m_player_ship:getPos()
	local dis_n = Math.distance(pos_x, pos_y, target_x, target_y)
	if dis_n < TILE_SIZE then
		return false
	end

	if self.m_my_ship_stop_info.stop_reason_count > 0 then
		local log_str = "!!!!!!!!!!!! lock_touch-----------".. self.m_my_ship_stop_info.stop_reason_count .. "---------"
		for k, v in pairs(self.m_my_ship_stop_info.stop_reasons) do
			log_str = log_str .. tostring(k) .. ", "
		end
		print(log_str)
	end

	if not getGameData():getTeamData():isLock() then
		self.m_player_ship:setPause(false)
	end

	if self.m_my_ship_up_pos_info.is_arrive_point_stop then
		self.m_player_ship:moveToVec3(cocosToGameplayWorld(ccp(target_x, target_y)))
	else
		self.m_player_ship:moveTo(cocosToGameplayWorld(ccp(target_x, target_y)))
	end

	--立马上传位置上去
	if self.m_my_ship_up_pos_info.time >= 0.5 then
		self.m_my_ship_up_pos_info.time = 0
		self.m_my_ship_up_pos_info.touch_pos = {x = target_x, y = target_y}
		local target_tx, target_ty = self:getNextTPos(self.m_my_ship_up_pos_info.is_arrive_point_stop)
		self:upMyShipPosToServer(target_tx, target_ty)
	end
	return true
end

function ClsPlayerShipsLayerBase:askToMoveForward(is_force_up)
	local target_tx, target_ty = self:getNextTPos()
	self:upMyShipPosToServer(target_tx, target_ty, is_force_up)
end

function ClsPlayerShipsLayerBase:getNextTPos(is_use_touch_pos)
	local pos_x, pos_y = self.m_player_ship:getPos()
	local target_tx, target_ty = self:cocosToTile(pos_x, pos_y)
	if (self:getMyShipNormalSpeedRate() > 0) and (not getGameData():getTeamData():isLock()) and (not self.m_player_ship:isPause()) and (not self.m_player_ship:getIsLockMove()) then
		local forward_x, forward_y = self.m_player_ship:getForwardPos()
		local run_dis = Math.distance(pos_x, pos_y, forward_x, forward_y)

		if self.m_my_ship_up_pos_info.is_arrive_point_stop and self.m_my_ship_up_pos_info.touch_pos then
			local touch_dis = Math.distance(pos_x, pos_y, self.m_my_ship_up_pos_info.touch_pos.x, self.m_my_ship_up_pos_info.touch_pos.y)
			if is_use_touch_pos then
				if touch_dis < run_dis then
					forward_x, forward_y = self.m_my_ship_up_pos_info.touch_pos.x, self.m_my_ship_up_pos_info.touch_pos.y
					run_dis = touch_dis
				else
					local rate_n = run_dis/touch_dis
					forward_x = pos_x + rate_n*(self.m_my_ship_up_pos_info.touch_pos.x - pos_x)
					forward_y = pos_y + rate_n*(self.m_my_ship_up_pos_info.touch_pos.y - pos_y)
				end
			elseif (touch_dis < run_dis) and (not IS_AUTO) then
				local rate_n = touch_dis/run_dis
				forward_x = pos_x + rate_n*(forward_x - pos_x)
				forward_y = pos_y + rate_n*(forward_y - pos_y)
			end
		end

		if run_dis >= 1 then
			local check_dis_xy = 0
			local finish_x = pos_x
			local finish_y = pos_y
			local is_loop = true
			--检查是否是合法的路径
			while(is_loop) do
				check_dis_xy = check_dis_xy + TILE_SIZE/2
				if check_dis_xy >= run_dis then
					check_dis_xy = run_dis
					is_loop = false
				end
				local rate_n = check_dis_xy / run_dis
				local check_x = pos_x + rate_n*(forward_x - pos_x)
				local check_y = pos_y + rate_n*(forward_y - pos_y)
				local check_pos = self.m_parent:getLand():checkPos(check_x, check_y, true)
				if check_pos == MAP_LAND then
					is_loop = false
				else
					finish_x = check_x
					finish_y = check_y
				end
			end
			target_tx, target_ty = self:cocosToTile(finish_x, finish_y)
		end
	end
	return target_tx, target_ty
end

function ClsPlayerShipsLayerBase:upMyShipPosToServer(target_tx, target_ty, is_force_up)
	if getGameData():getTeamData():isLock() then
		self.m_my_ship_up_pos_info.touch_pos = nil
		return
	end
	local pre_target_tx = self.m_my_ship_up_pos_info.last_target_tpos.tx
	local pre_target_ty = self.m_my_ship_up_pos_info.last_target_tpos.ty
	--发啦
	if (target_tx ~= pre_target_tx) or (target_ty ~= pre_target_ty) or (true == is_force_up) then
		self.m_ship_data:upPosToServer(target_tx, target_ty)
		local info = {tx = target_tx, ty = target_ty}
		local tpos_record = self.m_my_ship_up_pos_info.tpos_record
		tpos_record[#tpos_record + 1] = info
	end
	self.m_my_ship_up_pos_info.last_target_tpos.tx = target_tx
	self.m_my_ship_up_pos_info.last_target_tpos.ty = target_ty
end

function ClsPlayerShipsLayerBase:myShipMoveEvent(move_pos_info)
	if getGameData():getTeamData():isLock() then
		self.m_my_ship_up_pos_info.tpos_record = {}
	else --校验数据
		local tpos_record = self.m_my_ship_up_pos_info.tpos_record
		local info = tpos_record[1]
		if info then
			table.remove(tpos_record, 1)
			if info.tx == move_pos_info.dx and info.ty == move_pos_info.dy then
				return
			end
			print("error pos!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", move_pos_info.dx, move_pos_info.dy)
			--做拉回，先不弄
			if not IS_AUTO then
				-- self.m_player_ship:moveToTPos(move_pos_info.dx, move_pos_info.dy, false, TILE_SIZE, function()end)
			end
			self.m_my_ship_up_pos_info.tpos_record = {}
		end
	end
end

function ClsPlayerShipsLayerBase:updateMyShipAllStatus()
	if self.m_ship_data:getPosInfo(self.m_my_uid) then
		self.m_player_ship:updateStatus(self.m_ship_data:getShipStarLevel(self.m_my_uid))
		local param = self:getShipParam(self.m_my_uid)
		param.speed = self.m_player_ship:getSpeed()
		self.m_player_ship:resetNameInfo(param, true)
		self:updateTeamStatus(self.m_my_uid)
		self:updateShipStatus(self.m_my_uid)
	end
end

function ClsPlayerShipsLayerBase:myShipChangePos(dx, dy)
	self.m_player_ship:setPause(true)
	local target_x, target_y = self:tileToCocos(dx, dy)
	self.m_player_ship:setPos(target_x, target_y)
	self.m_parent:getSeaNode():setTranslation(self.m_player_ship.node:getTranslationWorld())
	self.m_parent:getLand():initLandField()
	CameraFollow:update(self.m_player_ship)
	self.m_parent:getLand():update(1 / 60)

	local explore_ui = getExploreUI()
	if not tolua.isnull(explore_ui) then
		local angle = self.m_player_ship:getAngle()
		local area_id = getGameData():getSceneDataHandler():getMapId()
		local explore_map_data = getGameData():getExploreMapData()
		if area_id ~= explore_map_data:getCurAreaId() then
			explore_ui.world_map:setChangeFirstAreaId(area_id)
			explore_ui.world_map:setShipPosInfo({angle = angle, x = target_x, y = target_y})
			explore_ui.world_map:setChangeFirstAreaId(nil)
		else
			explore_ui.world_map:setShipPosInfo({angle = angle, x = target_x, y = target_y})
		end
	end
end

function ClsPlayerShipsLayerBase:tryToBreakMove(is_break_auto)
	if is_break_auto then
		if IS_AUTO then
			self.m_parent:getLand():breakAuto(true)
		end
	end
	if not IS_AUTO then
		self.m_player_ship:breakTouchMove(true)
	end
end

--显示探索船的聊天气泡
function ClsPlayerShipsLayerBase:showShipChatBubble(chat_parameter)
	local ship = self:getShipWithMyShip(chat_parameter.sender)
	if ship then
		local tips_ui = ship:getTipsUI()
		if not tolua.isnull(tips_ui.chat_bubble) then
			tips_ui.chat_bubble:removeFromParentAndCleanup(true)
		end

		local chat_bubble = require("gameobj/explore/clsExploreChatBubble").new(chat_parameter)
		chat_bubble:setPosition(ccp(35, -45))
		tips_ui:addChild(chat_bubble)
		tips_ui.chat_bubble = chat_bubble
		local z_order = tips_ui:getZOrder()
		tips_ui:setZOrder(z_order) --保证同层中最高的显示
	end
end

------------------------------------------------------------------------------------------
--下面全是get, set方法
function ClsPlayerShipsLayerBase:isWaitingTouch()
	return self.m_my_ship_stop_info.is_waiting_touch
end

function ClsPlayerShipsLayerBase:setIsWaitingTouch(is_waiting)
	self.m_my_ship_stop_info.is_waiting_touch = is_waiting
end

function ClsPlayerShipsLayerBase:setStopShipReason(reason_str)
	local stop_reasons = self.m_my_ship_stop_info.stop_reasons
	if not stop_reasons[reason_str] then
		stop_reasons[reason_str] = true
		self.m_my_ship_stop_info.stop_reason_count = self.m_my_ship_stop_info.stop_reason_count + 1
	end
end

function ClsPlayerShipsLayerBase:releaseStopShipReason(reason_str)
	local stop_reasons = self.m_my_ship_stop_info.stop_reasons
	if stop_reasons[reason_str] then
		stop_reasons[reason_str] = nil
		self.m_my_ship_stop_info.stop_reason_count = self.m_my_ship_stop_info.stop_reason_count - 1
	end
end

function ClsPlayerShipsLayerBase:setPlayerAttr(key, value)
	self.m_player_attr[key] = value
end

function ClsPlayerShipsLayerBase:getPlayerAttr(key)
	return self.m_player_attr[key]
end

function ClsPlayerShipsLayerBase:setStopFoodReason(reason_str)
	if not self.m_food_stop_info.is_open then return end
	local stop_reasons = self.m_food_stop_info.stop_reasons
	if not stop_reasons[reason_str] then
		stop_reasons[reason_str] = true
		self.m_food_stop_info.stop_reason_count = self.m_food_stop_info.stop_reason_count + 1
	end
end

function ClsPlayerShipsLayerBase:releaseStopFoodReason(reason_str)
	local stop_reasons = self.m_food_stop_info.stop_reasons
	if stop_reasons[reason_str] then
		stop_reasons[reason_str] = nil
		self.m_food_stop_info.stop_reason_count = self.m_food_stop_info.stop_reason_count - 1
	end
end

function ClsPlayerShipsLayerBase:setMaxShowShipCount(count)
	self.m_max_show_ship_count = count
end

function ClsPlayerShipsLayerBase:getMyShipPosInfo()
	return self.m_my_player_ship_pos
end

function ClsPlayerShipsLayerBase:getShipStopReasons()
	return self.m_my_ship_stop_info.stop_reasons
end

return ClsPlayerShipsLayerBase
