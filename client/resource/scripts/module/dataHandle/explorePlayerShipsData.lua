
local on_off_info = require("game_config/on_off_info")
local port_info = require("game_config/port/port_info")
local ui_word = require("game_config/ui_word")
local error_info = require("game_config/error_info")
local ClsAlert = require("ui/tools/alert")

local ClsExplorePlayerShipsData = class("explorePlayerShipsData")

local LIST_ID = {
	TEAM = 1,
	ENEMY_CAMP = 2,
	FRIEND = 3,
	GUILD = 4,
	ROBBERY = 5,
	LV = 6,
	NONE = 7,
}

local SHIP_INFO_NO = 0
local SHIP_INFO_WAIT = 1
local SHIP_INFO_OLD = 2
local SHIP_INFO_OK = 3

local SHIP_STATE = {
	NONE = 0,
	FIGHTING = 1,
	HAS_PLUNDER_MISSION = 1,
}

local GHOST_STATE = {
	NONE = 0,
	GHOST = 1,
}

local RED_NAME_STATE = {
	NONE = 0,
	RED = 1,
}

local CAMP_STATE = {
	NONE = 0,
	CAMP1 = 1,
	CAMP2 = 2,
}

local TEAMMATE_STATE = {
	NONE = 0,
	TEAMMATE = 1    
}

local OPEN_LOOT = {
	NONE = 0,
	OPEN = 1,
}

local VIP_WAVE = {
	TRUE = 1,
	FALSE = 0,
}

ClsExplorePlayerShipsData.ctor = function(self)
	self.m_area_id = nil
	self.m_enter_area = nil
	self.m_before_area = nil
	self.m_save_path_info = true
	self.m_is_active_enemy_first = false
	self:cleanInfo()
end

ClsExplorePlayerShipsData.cleanInfo = function(self)
	self.m_pos_info = {}
	self.m_show_player_lists = {}
	self.m_team_info_list = {}
	self.m_is_active_enemy_first = false
	for k, v in pairs(LIST_ID) do
		self.m_show_player_lists[v] = {}
	end
end

ClsExplorePlayerShipsData.initInfo = function(self)
	local sceneDataHandler = getGameData():getSceneDataHandler()
	self.m_my_uid = sceneDataHandler:getMyUid()
	local my_camp = sceneDataHandler:getMyCamp()
	self.m_is_join_camp = false
	self.m_camp_area_id = 0
	self.m_is_in_explore = sceneDataHandler:isInExplore()
	self.m_my_camp = my_camp
	if my_camp > 0 then
		self.m_is_join_camp = true
		self.m_camp_area_id = port_info[my_camp].areaId
	end
end

ClsExplorePlayerShipsData.upPosToServer = function(self, dx, dy)
	-- self:savePatchInfo(nil, dx, dy)
	GameUtil.callRpc("rpc_server_move", {dx, dy})
end

--录制场景走路包, 请勿乱用
ClsExplorePlayerShipsData.savePatchInfo = function(self, area_id, dx, dy)
	local file, file_error = io.open("explorePathInfo.txt", "a+")
	if file_error then
		file = io.output("explorePathInfo.txt")
	end

	if not area_id then
		area_id = self.m_enter_area or self.m_area_id
	end

	file:write(tostring(area_id) .. "," .. tostring(dx) .. "," .. tostring(dy) .. "\n")
	file:flush()
	file:close()
end

ClsExplorePlayerShipsData.setAreaId = function(self, area_id)
	self.m_area_id = area_id
end

ClsExplorePlayerShipsData.setIsActiveEnemyRule = function(self, is_active_enemy_first)
	self.m_is_active_enemy_first = is_active_enemy_first
end

ClsExplorePlayerShipsData.updatePlayerDetailInfo = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		pos_info.info_state = SHIP_INFO_OK
		local explore_layer = getExploreLayer()
		local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
		local ships_layer = nil
		if not tolua.isnull(explore_layer) then
			ships_layer = explore_layer:getShipsLayer()
		elseif not tolua.isnull(copy_scene_layer) then
			ships_layer = copy_scene_layer:getShipsLayer()
		end
		if not tolua.isnull(ships_layer) then
			ships_layer:updateShipUi(uid)
		end
		self:removeFromShowList(uid)
		self:addToShowList(uid)
	end
end

ClsExplorePlayerShipsData.getPosInfo = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	return pos_info
end

ClsExplorePlayerShipsData.getTeamFollowUid = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	local leader_uid = nil
	if pos_info then
		leader_uid = pos_info.leader_uid
	end
	if leader_uid then
		local team_info = self.m_team_info_list[leader_uid]
		if team_info then
			local index = team_info.team_by_uid[uid] - 2
			local target_uid = team_info.leader
			if index >= 1 then
				target_uid = team_info.member[index]
			end
			return target_uid
		end
	end
end

ClsExplorePlayerShipsData.getTeamMemberUids = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	local leader_uid = nil
	if pos_info then
		leader_uid = pos_info.leader_uid
	end
	if leader_uid then
		local team_info = self.m_team_info_list[leader_uid]
		if team_info then
			return team_info.member
		end
	end
	return {}
end

ClsExplorePlayerShipsData.getTeamMemberUidsByLeaderUid = function(self, uid)
	local team_info = self.m_team_info_list[uid]
	if team_info then
		return team_info.member
	end

	return {}
end

ClsExplorePlayerShipsData.updatePosInfo = function(self, new_pos_info)
	local pos_info = self.m_pos_info[new_pos_info.uid]
	if pos_info then
		self:setAttr(new_pos_info.uid, "far_auto_remove_count", nil)
		local leader_uid = pos_info.leader_uid
		if leader_uid then
			local team_info = self.m_team_info_list[leader_uid]
			self:copyPosFromData(self.m_pos_info[leader_uid], new_pos_info)
			for _, uid in ipairs(team_info.member) do
				self:copyPosFromData(self.m_pos_info[uid], new_pos_info)
			end
			return
		end
		self:copyPosFromData(pos_info, new_pos_info)
	end
end

ClsExplorePlayerShipsData.copyPosFromData = function(self, pos_info, new_pos_info)
	if pos_info and new_pos_info then
		pos_info.tx = new_pos_info.x
		pos_info.ty = new_pos_info.y
		pos_info.dx = new_pos_info.dx
		pos_info.dy = new_pos_info.dy
	end
end

ClsExplorePlayerShipsData.getShipId = function(self, uid)
	local ship_id = 0
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		ship_id = pos_info.ship_id
	end
	if device.platform ~= "windows" or true then --发布的时候添加保护，测试阶段不加
		if ship_id <= 0 then
			ship_id = 1
		end
	end
	return ship_id
end

ClsExplorePlayerShipsData.getShipStarLevel = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		return pos_info.status.ship_color
	end
	return 1
end

ClsExplorePlayerShipsData.isInTeam = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.leader_uid and pos_info.leader_uid > 0 then
			return true
		end
	end
	return false
end

ClsExplorePlayerShipsData.isTeamLeader = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.leader_uid == uid then
			return true
		end
	end
	return false
end

ClsExplorePlayerShipsData.getTeamLeaderUid = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.leader_uid then
			return pos_info.leader_uid
		end
	end
end

ClsExplorePlayerShipsData.isJionCamp = function(self)
	if self.m_is_join_camp and self.m_is_in_explore then
		return false
	end
	return self.m_is_join_camp
end

ClsExplorePlayerShipsData.isSameCamp = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if self.m_my_camp == pos_info.status.camp then
			return true
		else
			return false
		end
	end
	return false
end

ClsExplorePlayerShipsData.isInCamp = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if self.m_is_in_explore then
			if (pos_info.status.camp > 0) and (pos_info.status.camp_area_id > 0) and (pos_info.status.camp_area_id == self.m_camp_area_id) then
				return true
			end
		else
			return true
		end
	end
	return false
end

ClsExplorePlayerShipsData.getCampNameColor = function(self, uid)
	if self:isJionCamp() then
		if self:isInCamp(uid) then
			if self:isSameCamp(uid) then
				return COLOR_BLUE_STROKE
			else
				return COLOR_RED_STROKE
			end
		end
	end
	return COLOR_WHITE_STROKE
end

ClsExplorePlayerShipsData.isSameCampByValue = function(self, camp_n)
	if self.m_my_camp == camp_n then
		return true
	end
	return false
end

ClsExplorePlayerShipsData.isInCampByValue = function(self, camp_n)
	if self.m_is_in_explore then
		if camp_n > 0 then
			if self.m_camp_area_id == port_info[camp_n].areaId then
				return true
			end
		end
		return false
	end
	return true
end

ClsExplorePlayerShipsData.updateShipStatus = function(self, uid, status)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		pos_info.status = self:getStatusTab(status)
		local explore_layer = getExploreLayer()
		local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
		local ships_layer = nil
		if not tolua.isnull(explore_layer) then
			ships_layer = explore_layer:getShipsLayer()
		elseif not tolua.isnull(copy_scene_layer) then
			ships_layer = copy_scene_layer:getShipsLayer()
		end
		if not tolua.isnull(ships_layer) then
			-- 如果是自己，要更新所有人的状态
			if uid == getGameData():getPlayerData():getUid() then
				for uid, v in pairs(self.m_pos_info) do
					ships_layer:updateShipStatus(uid)
				end
			-- 如果不是，那只要更新这个人的状态
			else
				ships_layer:updateShipStatus(uid)
			end
		end
	end
end

ClsExplorePlayerShipsData.isFighting = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.status.is_fight == SHIP_STATE.FIGHTING then
			return true
		end
	end
	return false
end

ClsExplorePlayerShipsData.isTeammate = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.status.is_teammate_n == TEAMMATE_STATE.TEAMMATE then
			return true
		end
	end
	return false
end

ClsExplorePlayerShipsData.isOpenLootSwitch = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.status.is_open_loot == OPEN_LOOT.OPEN then
			return true
		end
	end
	return false
end

ClsExplorePlayerShipsData.isPlunderMission = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.status.is_plunder_mission == SHIP_STATE.HAS_PLUNDER_MISSION then
			return true
		end
	end
	return false
end

--红白名
ClsExplorePlayerShipsData.isRedNameStatus = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.status.is_red_name == RED_NAME_STATE.RED then
			return true
		end 
	end
	return false
end

ClsExplorePlayerShipsData.isGhostStatus = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.status.is_ghost == GHOST_STATE.GHOST then
			return true
		end 
	end
	return false
end

ClsExplorePlayerShipsData.isVipWave = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if pos_info.status.is_vip_wave == VIP_WAVE.TRUE then
			return true
		end 
	end
	return false
end

ClsExplorePlayerShipsData.hasTeamMember = function(self, uid, num_n)
	local pos_info = self.m_pos_info[uid]
	if pos_info and pos_info.leader_uid then
		local team_info = self.m_team_info_list[pos_info.leader_uid]
		if team_info then
			if #team_info.member >= (num_n - 1) then
				return true
			end
		end
	end
	return false
end

local math_floor = math.floor
ClsExplorePlayerShipsData.getStatusTab = function(self, num)
	local is_fight_n = num%2
	num = math_floor(num/2)
	
	local is_plunder_mission_n = num%2
	num = math_floor(num/2)
	
	local ship_color_n = num%4 + 1
	num = math_floor(num/4)
	
	local camp_n = num%128
	num = math_floor(num/128)
	
	local is_red_name_n = num%2
	num = math_floor(num/2)
	
	local is_ghost_n = num%2
	num = math_floor(num/2)

	local is_teammate_n = num%2
	num = math_floor(num/2)

	local is_contend_status = num % 2
	num = math_floor(num / 2)

	local is_open_loot = num % 2
	num = math_floor(num / 2)
	
	local is_vip_wave = num % 2
	num = math_floor(num / 2)

	local ship_scale_n = num%4
	num = math_floor(num / 4)

	local kill_title_n = num % 16 --连杀称号
	num = math_floor(num / 16)

	local camp_area_id = 0
	if self.m_is_in_explore then
		if camp_n > 0 then
			camp_area_id = port_info[camp_n].areaId
		end
	end

	local status = {is_fight = is_fight_n, 
					is_plunder_mission = is_plunder_mission_n, 
					ship_color = ship_color_n, 
					camp = camp_n, 
					camp_area_id = camp_area_id, 
					is_red_name = is_red_name_n, 
					is_ghost = is_ghost_n, 
					is_teammate_n = is_teammate_n,
					is_contend_status = is_contend_status,
					is_open_loot = is_open_loot,
					is_vip_wave = is_vip_wave,
					ship_scale = ship_scale_n,
					kill_title_n = kill_title_n,
				}   
	
	return status
end

ClsExplorePlayerShipsData.addPosShipInfo = function(self, server_info)
	local pos_info = {uid = server_info.uid, 
					tx = server_info.x, 
					ty = server_info.y, 
					dx = server_info.x, 
					dy = server_info.y, 
					ship_id = server_info.shipid, 
					area_id = server_info.mapId,
					status = self:getStatusTab(server_info.status),
					attr = {}}
	local uid = pos_info.uid
	local player_info = getGameData():getPlayersDetailData():getPlayerInfo(uid)
	pos_info.info_state = SHIP_INFO_NO
	if player_info then
		pos_info.info_state = SHIP_INFO_OLD
	end
	local re_enter_b = false
	if self.m_pos_info[uid] then --防止后端发送重复的进场协议导致报错
		self:removeFromShowListWithTeamInfo(uid)
		re_enter_b = true
	end
	self.m_pos_info[uid] = pos_info
	self:addToShowList(uid)
	
	if self.m_my_uid == uid then
		if CAMP_STATE.NONE ~= pos_info.status.camp then
			self.m_is_join_camp = true
		end
	end
	
	local explore_layer = getExploreLayer()
	local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
	local ships_layer = nil
	if not tolua.isnull(explore_layer) then
		ships_layer = explore_layer:getShipsLayer()
	elseif not tolua.isnull(copy_scene_layer) then
		ships_layer = copy_scene_layer:getShipsLayer()
	end
	if not tolua.isnull(ships_layer) then
		ships_layer:updateShipStatus(uid)
		if re_enter_b or (self.m_my_uid == uid) then
			ships_layer:reEnterLayer(uid)
		end
	end
end

ClsExplorePlayerShipsData.putPosInfoLeaderUid = function(self, uid, leader_uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		pos_info.leader_uid = leader_uid
	end
end

ClsExplorePlayerShipsData.updateTeamInfo = function(self, team_info)
	local is_my_team = false
	local leader_uid = team_info.leader
	self:removeFromShowList(leader_uid)
	team_info.team_by_uid = {}
	team_info.team_by_uid[leader_uid] = 1
	self:putPosInfoLeaderUid(leader_uid, leader_uid)
	if self.m_my_uid == leader_uid then
		is_my_team = true
	end
	for i, uid in ipairs(team_info.member) do
		self:removeFromShowList(uid)
		team_info.team_by_uid[uid] = i + 1
		self:putPosInfoLeaderUid(uid, leader_uid)
		if self.m_my_uid == uid then
			is_my_team = true
		end
	end
	team_info.is_my_team = is_my_team
	self.m_team_info_list[leader_uid] = team_info
	
	self:addToShowList(leader_uid)
	local explore_layer = getExploreLayer()
	local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
	local ships_layer = nil
	if not tolua.isnull(explore_layer) then
		ships_layer = explore_layer:getShipsLayer()
	elseif not tolua.isnull(copy_scene_layer) then
		ships_layer = copy_scene_layer:getShipsLayer()
	end
	if not tolua.isnull(ships_layer) then
		ships_layer:updateTeamStatus(leader_uid)
		for _, uid in ipairs(team_info.member) do
			ships_layer:updateTeamStatus(uid)
		end
	end
end

ClsExplorePlayerShipsData.moveToTPos = function(self, pos_info)
	self:updatePosInfo(pos_info)
	local explore_layer = getExploreLayer()
	local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
	local ships_layer = nil
	if not tolua.isnull(explore_layer) then
		ships_layer = explore_layer:getShipsLayer()
	elseif not tolua.isnull(copy_scene_layer) then
		ships_layer = copy_scene_layer:getShipsLayer()
	end
	if not tolua.isnull(ships_layer) then
		ships_layer:moveToTPos(pos_info)
	end
end

ClsExplorePlayerShipsData.removeShipInfo = function(self, area_id, uid)
	if self.m_pos_info[uid] then
		if uid == self.m_my_uid then
			if area_id ~= getGameData():getSceneDataHandler():getMapId() then
				return --保护，防止发出不同mapid之后会把自己的信息清掉
			end
		end
		local explore_layer = getExploreLayer()
		local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
		local ships_layer = nil
		if not tolua.isnull(explore_layer) then
			ships_layer = explore_layer:getShipsLayer()
		elseif not tolua.isnull(copy_scene_layer) then
			ships_layer = copy_scene_layer:getShipsLayer()
		end
		if not tolua.isnull(ships_layer) then
			ships_layer:removeUselessShip(uid)
		end
		self:removeFromShowListWithTeamInfo(uid)
		self.m_pos_info[uid] = nil
	end
end

ClsExplorePlayerShipsData.askMyShipInfo = function(self)
	GameUtil.callRpc("rpc_server_get_uid_info", {self.m_my_uid, -1})
end

ClsExplorePlayerShipsData.checkPlayerDetailInfo = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		if SHIP_INFO_OK == pos_info.info_state then
			return true
		end
		if SHIP_INFO_OLD == pos_info.info_state then
			local version_n = getGameData():getPlayersDetailData():getPlayerInfoVersion(uid)
			GameUtil.callRpc("rpc_server_get_uid_info", {uid, version_n})
			pos_info.info_state = SHIP_INFO_OK
			return true
		end
		if SHIP_INFO_NO == pos_info.info_state then
			GameUtil.callRpc("rpc_server_get_uid_info", {uid, -1})
			pos_info.info_state = SHIP_INFO_WAIT
			return false
		end
	end
	return false
end

ClsExplorePlayerShipsData.addToShowList = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		local list_key = self:getOrderKeyFromUid(uid)
		if not list_key then
			return
		end
		--添加不同判断，有优先级
		local list = self.m_show_player_lists[list_key]
		if list_key == LIST_ID.LV then
			local level = getGameData():getPlayersDetailData():getPlayerLv(uid) or 0
			if level > 0 then
				if not list[level] then
					list[level] = {}
				end
				list = list[level]
			else
				--报错，不应该运行到这里
				print(debug.traceback())
				return
			end
		end
		for _, v in ipairs(list) do
			if v == uid then
				return
			end
		end
		if list_key == LIST_ID.TEAM then
			if self.m_team_info_list[uid].is_my_team then
				table.insert(list, 1, uid)
			else
				list[#list + 1] = uid
			end
		else
			list[#list + 1] = uid
		end
	end
end

ClsExplorePlayerShipsData.getOrderKeyFromUid = function(self, uid)
	if self.m_team_info_list[uid] then
		if self.m_team_info_list[uid].leader == uid then
			return LIST_ID.TEAM
		end
		return nil
	end
	--队员当然不能重新加入啦
	local pos_info = self.m_pos_info[uid]
	if pos_info and pos_info.leader_uid then
		if self.m_team_info_list[pos_info.leader_uid] then
			return nil
		end
	end
	if self.m_is_active_enemy_first then
		if self:isJionCamp() and (not self:isSameCamp(uid)) and (not self:isFighting(uid)) then
			return LIST_ID.ENEMY_CAMP
		end
	end
	if getGameData():getFriendDataHandler():isMyFriend(uid) then
		return LIST_ID.FRIEND
	end

	if getGameData():getGuildInfoData():getGuildInfoMemberByUid(uid) then
		return LIST_ID.GUILD
	end

	if self:isRedNameStatus(uid) then
		return LIST_ID.ROBBERY
	end

	local pos_info = self:getPosInfo(uid)
	if pos_info then
		if pos_info.info_state == SHIP_INFO_OK then
			return LIST_ID.LV
		end
	end
	return LIST_ID.NONE
end

ClsExplorePlayerShipsData.removeFromShowList = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		for key, list in ipairs(self.m_show_player_lists) do
			if key == LIST_ID.LV then
				for _, lv_list in pairs(list) do
					for k, v in ipairs(lv_list) do
						if v == uid then
							table.remove(lv_list, k)
							return
						end
					end
				end
			else
				for k, v in ipairs(list) do
					if v == uid then
						table.remove(list, k)
						return
					end
				end
			end
		end
	end
end

ClsExplorePlayerShipsData.removeFromShowListWithTeamInfo = function(self, uid)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		local leader_uid = pos_info.leader_uid
		if leader_uid then
			self:putPosInfoLeaderUid(leader_uid)
			local team_info = self.m_team_info_list[leader_uid]
			if team_info then
				if team_info.member then
					for _, uid in ipairs(team_info.member) do
						self:putPosInfoLeaderUid(uid)
					end
				end
			end
			self.m_team_info_list[leader_uid] = nil
			self:removeFromShowList(leader_uid)
		else
			self:removeFromShowList(uid)
		end
	end
end

ClsExplorePlayerShipsData.checkShowListAllUid = function(self, call_back)
	local playerData = getGameData():getPlayerData()
	local my_level = playerData:getLevel()
	local max_level = playerData:getMaxLevel()
	local check_call_back = function(uid, is_in_team, is_leader)
			if (uid ~= self.m_my_uid) and call_back then
				call_back(uid, is_in_team, is_leader)
			end
		end
	for key, list in ipairs(self.m_show_player_lists) do
		if key == LIST_ID.LV then
			--优化，减少内存分配
			local bigger_lv = 0
			local lv_list = nil
			local smaller_lv = 0
			--取离自己最近等级的uid
			for i = 0, max_level do
				bigger_lv = my_level + i
				--先取比自己大的
				if (1 <= bigger_lv) and (bigger_lv <= max_level) then
					lv_list = list[bigger_lv]
					if lv_list then
						for _, uid in ipairs(lv_list) do
							check_call_back(uid)
						end
					end
				end
				smaller_lv = my_level - i
				if (smaller_lv ~= bigger_lv) and (1 <= smaller_lv) and (smaller_lv <= max_level) then
					lv_list = list[smaller_lv]
					if lv_list then
						for _, uid in ipairs(lv_list) do
							check_call_back(uid)
						end
					end
				end
				--减少遍历的次数
				if smaller_lv <= 0 and bigger_lv > max_level then
					break
				end
			end
		elseif key == LIST_ID.TEAM then
			for _, leader_uid in ipairs(list) do
				local team_info = self.m_team_info_list[leader_uid]
				check_call_back(leader_uid, true, true)
				for _, uid in ipairs(team_info.member) do
					check_call_back(uid, true, false)
				end
			end
		else
			for _, uid in ipairs(list) do
				check_call_back(uid)
			end
		end
	end
end

ClsExplorePlayerShipsData.getPortPos = function(self)
	local portData = getGameData():getPortData()
	local port_info = require("game_config/port/port_info")
	local port_id = portData:getPortId() -- 当前港口id
	local px, py = port_info[port_id].ship_pos[1], port_info[port_id].ship_pos[2] -- 海面港口位置
	return ccp(px, py), port_id
end

ClsExplorePlayerShipsData.askEnterArea = function(self, area_id, pos_x, pos_y, is_check_area_id)
	if is_check_area_id then
		local sceneDataHander = getGameData():getSceneDataHandler()
		if sceneDataHander:isInExplore() and (area_id == sceneDataHander:getMapId()) then
			return
		end
	end
	self.m_before_area = self.m_enter_area
	self.m_enter_area = area_id
	-- self:savePatchInfo(area_id, pos_x, pos_y)
	GameUtil.callRpc("rpc_server_enter_area", {area_id, pos_x, pos_y})
end

ClsExplorePlayerShipsData.tryToShowWarningTips = function(self)
	if nil == self.m_enter_area then
		self.m_enter_area = getGameData():getSceneDataHandler():getMapId()
		return
	end
	if self.m_before_area and self.m_enter_area and (self.m_enter_area ~= self.m_before_area) then
		local port_data = getGameData():getPortData()
		local before_is_safe = port_data:getIsProtectArea(self.m_before_area)
		local now_is_safe = port_data:getIsProtectArea(self.m_enter_area)
		if before_is_safe ~= now_is_safe then
			local tips_str = error_info[690].message
			if now_is_safe then
				tips_str = error_info[689].message
			end
			ClsAlert:warning({msg = tips_str})
		end
	end
end

ClsExplorePlayerShipsData.setCdTime = function(self, cd_n)
	local pos_info = self.m_pos_info[self.m_my_uid]
	if pos_info then
		pos_info.attr["red_name_cd"] = cd_n
		local explore_layer = getExploreLayer()
		local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
		local ships_layer = nil
		if not tolua.isnull(explore_layer) then
			ships_layer = explore_layer:getShipsLayer()
		elseif not tolua.isnull(copy_scene_layer) then
			ships_layer = copy_scene_layer:getShipsLayer()
		end
		if not tolua.isnull(ships_layer) then
			ships_layer:updateShipStatus(self.m_my_uid)
		end
	end
end

ClsExplorePlayerShipsData.getShipByUid = function(self, uid)
	local explore_layer = getExploreLayer()
	local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
	local ships_layer = nil
	if not tolua.isnull(explore_layer) then
		ships_layer = explore_layer:getShipsLayer()
	elseif not tolua.isnull(copy_scene_layer) then
		ships_layer = copy_scene_layer:getShipsLayer()
	end
	if not tolua.isnull(ships_layer) then
		return ships_layer:getShipWithMyShip(uid)
	end
end

ClsExplorePlayerShipsData.getAttr = function(self, uid, key)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		return pos_info.attr[key]
	end
end

ClsExplorePlayerShipsData.setAttr = function(self, uid, key, value)
	local pos_info = self.m_pos_info[uid]
	if pos_info then
		pos_info.attr[key] = value
	end
end

return ClsExplorePlayerShipsData