--2016/05/23
--create by wmh0497
--用于显示在探索里同步的玩家船

local TILE_SIZE = 64
local WIDTH_BLOCK =  8--15 + 4
local HEIGHT_BLOCK = 5--9 + 3 --8.4375
local TILE_HEIGHT = 960
local TILE_WIDTH  = 1695
local LAND_HEIGHT = TILE_SIZE * TILE_HEIGHT --地图的高度，像素单位
local on_off_info = require("game_config/on_off_info")

local MAX_SHIP_COUNT = 10

local ORG_SPEED_RATE = 1
local MAX_SPEED_RATE = 2

local HEAD_WIND_ANGLE = {    -- 逆风区夹角
	[WIND_NORTH_EAST] = {0, 90},        --东北风
	[WIND_SOUTH_EAST] = {90, 180},      --东南风
	[WIND_SOUTH_WEST] = {180, 270},     --西南风
	[WIND_NORTH_WEST] = {270, 360},     --西北风
}

local UiCommon = require("ui/tools/UiCommon")
local dataTools = require("module/dataHandle/dataTools")
local rpc_down_info = require("game_config/rpc_down_info")
local ui_word = require("game_config/ui_word")
local ClsExploreMyShipLogicHander = require("gameobj/explore/clsExploreMyShipLogicHander")
local ClsPlayerShipsLayerBase = require("gameobj/explore/clsPlayerShipsLayerBase")

local ClsExplorePlayerShipsLayer = class("ExplorePlayerShipsLayer", ClsPlayerShipsLayerBase)

ClsExplorePlayerShipsLayer.ctor = function(self, parent)

	ClsExplorePlayerShipsLayer.super.ctor(self, parent)

	self.m_drop_info = {}
	self.m_drop_info.is_droping = false
	self.m_drop_info.cur_speed_rate = 1
	self.m_drop_info.drop_speed = 1

	self.m_my_ship_speed_info = {}
	self.m_my_ship_speed_info.is_lock_speed = false
	self.m_my_ship_speed_info.lock_speed = 0
	self.m_my_ship_speed_info.lock_speed_rate = 0
	self.m_my_ship_speed_info.org_speed = self.m_player_ship:getSpeed()
	self.m_my_ship_speed_info.result_rate = -1
	self.m_my_ship_speed_info.test_change_speed_rate = ORG_SPEED_RATE
	self.m_my_ship_speed_info.sailor_speed_rate = ORG_SPEED_RATE
	self.m_my_ship_speed_info.wind_speed_rate = ORG_SPEED_RATE
	self.m_my_ship_speed_info.down_wind_speed_rate = ORG_SPEED_RATE
	self.m_my_ship_speed_info.storm_speed_rate = ORG_SPEED_RATE
	self.m_my_ship_speed_info.mermain_up_speed_rate = SPEED_RATE_DOWNWIND

	self.m_my_ship_wind_info = {}
	self.m_my_ship_wind_info.wind_follow_state = WIND_NO_EFFECT
	self.m_my_ship_wind_info.sail_state = SAIL_UP
	self.m_my_ship_wind_info.is_play_storm = false

	self.m_event_speed_info = {}
	self.m_event_speed_info.is_mermaid_up = false
	
	self.m_food_stop_info.is_open = true

	self.m_my_ship_logic = ClsExploreMyShipLogicHander.new(parent, self)

	self:initShipForwardUpdateCallback()
	self.m_player_ship.node:setTag("playerShipsLayerBase", tostring(self.m_my_uid))
end

--地图更新回调
ClsExplorePlayerShipsLayer.initShipForwardUpdateCallback = function(self)
	self.m_player_ship:setShipUpdateForwardCallback(function(pos)
			local pos_info = {angle = self.m_player_ship:getAngle(), x = pos.x, y = pos.y}
			local explore_ui = getExploreUI()
			if not tolua.isnull(explore_ui) then
				explore_ui:shipUIRotate(pos_info)
			end
		end)
end

ClsExplorePlayerShipsLayer.onEnter = function(self)
	ClsExplorePlayerShipsLayer.super.onEnter(self)
end

ClsExplorePlayerShipsLayer.onExit = function(self)
	ClsExplorePlayerShipsLayer.super.onExit(self)
end

ClsExplorePlayerShipsLayer.getShipParam = function(self, uid)
	local params = ClsExplorePlayerShipsLayer.super.getShipParam(self, uid)
	params.speed = params.speed*2
	return params
end

local DIS2 = 320*320
ClsExplorePlayerShipsLayer.updateShipInfo = function(self, uid, ship, is_in_team, is_leader)
	if is_in_team and is_leader then
		if getGameData():getAreaCompetitionData():isOpen() and self.m_ship_data:isJionCamp() and self.m_ship_data:isTeamLeader(self.m_my_uid)  then --如果开了
			if self.m_ship_data:isInCamp(uid) and (not self.m_ship_data:isSameCamp(uid)) and self.m_ship_data:hasTeamMember(uid, 2) then
				local sx, sy = ship:getPos()
				local dis2 = (self.m_my_player_ship_pos.x - sx)*(self.m_my_player_ship_pos.x - sx) + (self.m_my_player_ship_pos.y - sy)*(self.m_my_player_ship_pos.y - sy)
				if dis2 < DIS2 then
					self:checkIsPutAttackBtn(uid, ship, true)
					return
				end
			end
		end
	end
	self:checkIsPutAttackBtn(uid, ship, false)
end

ClsExplorePlayerShipsLayer.checkIsPutAttackBtn = function(self, uid, ship, is_show)
	if not is_show then
		if ship.ui.attack_btn then--提高一点点性能
			if not tolua.isnull(ship.ui.attack_btn) then
				ship.ui.attack_btn:removeFromParentAndCleanup(true)
			end
			ship.ui.attack_btn = nil
		end
	else
		if tolua.isnull(ship.ui.attack_btn) then
			local explore_layer = getExploreLayer()
			local attack_btn = explore_layer:createButton({image = "#explore_plunder.png"})
			local show_text_lab = createBMFont({text = ui_word.STR_ATTACK, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
			attack_btn:addChild(show_text_lab)
			attack_btn:regCallBack(function()
				if not self.m_ship_data:isInTeam(self.m_my_uid) then
					ClsAlert:warning({msg = rpc_down_info[134].msg})
					return
				end
				if not self.m_ship_data:isInTeam(uid) then
					ClsAlert:warning({msg = rpc_down_info[135].msg})
					return
				end

				if self.m_ship_data:isFighting(uid) then
					ClsAlert:warning({msg = rpc_down_info[142].msg})
					return
				end

				if not self.m_ship_data:hasTeamMember(self.m_my_uid, 2) then
					ClsAlert:warning({msg = rpc_down_info[134].msg})
					return false
				end

				self:askAttack(uid)
			end)
			attack_btn:setPosition(ccp(0, -30))
			ship.ui:addChild(attack_btn)
			ship.ui.attack_btn = attack_btn
		end
	end
end

ClsExplorePlayerShipsLayer.askAttack = function(self, uid)
	getGameData():getExploreData():askLootPlayer(uid)
end

ClsExplorePlayerShipsLayer.updateShipStatus = function(self, uid)
	ClsExplorePlayerShipsLayer.super.updateShipStatus(self, uid)
	local ship = self:getShipWithMyShip(uid)

	if ship and self.m_my_uid ~= uid then --添加掠夺按钮
		local is_trade_att, is_show_gray, show_gray_reason = self:getTradeAttactStatus(uid)
		ship:setTradeAttackStatus(is_trade_att, is_show_gray, show_gray_reason)
		if is_trade_att then
			ship:setRedNameAttackStatus(false)
		else
			ship:setRedNameAttackStatus(self:getRedNameAttactStatus(uid))
		end
	end
	if ship then
		local is_red_name = self.m_ship_data:isRedNameStatus(uid)
		ship:setIsRedNameStatus(is_trade_red or is_red_name)
	end
end

--玩家自身是否需要给船加运镖图标
ClsExplorePlayerShipsLayer.isNeedPlunderIcon = function(self, uid)
	local is_teammate = self.m_ship_data:isTeammate(uid)
	if self.m_my_uid == uid then --玩家自己
		local team_data_handle = getGameData():getTeamData()
		if not team_data_handle:isInTeam() or not is_teammate then
			return true
		end
	else --玩家自己队伍的队长
		local ship_leader_id = self.m_ship_data:getTeamLeaderUid(uid)
		local my_leader_id = self.m_ship_data:getTeamLeaderUid(self.m_my_uid)
		if my_leader_id == ship_leader_id and not is_teammate then
			return true
		end
	end
end

local LEVEL_LIMIT = 5
ClsExplorePlayerShipsLayer.getTradeAttactStatus = function(self, uid)
	if self.m_my_uid == uid then 
		return false 
	end

	if not self.m_ship_data:isPlunderMission(uid) then 
		return false 
	end

	local in_my_team = getGameData():getTeamData():getTeamUserInfoByUid(uid)
	local is_teammate = self.m_ship_data:isTeammate(uid)

	if in_my_team or is_teammate then 
		return false 
	end

	local ship_leader_id = self.m_ship_data:getTeamLeaderUid(uid)
	local my_leader_id = self.m_ship_data:getTeamLeaderUid(self.m_my_uid)
	if ship_leader_id and my_leader_id and ship_leader_id == my_leader_id then
		return false
	end

	local is_show_gray = false
	local show_gray_reason = nil

	local ship_lv = getGameData():getPlayersDetailData():getPlayerLv(uid)
	if not ship_lv then
		return false
	end

	local explore_player_ships_data = getGameData():getExplorePlayerShipsData()
	local member = explore_player_ships_data:getTeamMemberUidsByLeaderUid(uid)
	for k, v in pairs(member) do
		local lv = getGameData():getPlayersDetailData():getPlayerLv(v)
		if lv and lv > ship_lv then
			ship_lv = lv
		end
	end

	local my_level = getGameData():getPlayerData():getLevel()
	local offset = my_level - ship_lv
	if math.abs(offset) > LEVEL_LIMIT then
		is_show_gray = true
		if offset > 0 then
			show_gray_reason = "LOOT_TIP_MY_LEVEL_H"
		else
			show_gray_reason = "LOOT_TIP_OTHER_LEVEL_H"
		end
	end

	return true, is_show_gray, show_gray_reason
end

local PROTECT_AREA = {
	[1] = true, 
	[2] = true, 
	[4] = true, 
	[6] = true
}

ClsExplorePlayerShipsLayer.getRedNameAttactStatus = function(self, uid)
	local is_my_name_red = self.m_ship_data:isRedNameStatus(self.m_my_uid)
	local is_ship_name_red = self.m_ship_data:isRedNameStatus(uid)
	local in_my_team = getGameData():getTeamData():getTeamUserInfoByUid(uid)
	local is_teammate = self.m_ship_data:isTeammate(uid)--判断是否是其他队伍中的队长或者队员
	
	--先判断显示还是不显示
	if (not is_my_name_red) and (not is_ship_name_red) then return false end
	if in_my_team or is_teammate then return false end
	if not getGameData():getOnOffData():isOpen(on_off_info.PORT_QUAY_ROB.value) then return false end
	
	local ship_lv = getGameData():getPlayersDetailData():getPlayerLv(uid)
	local my_level = getGameData():getPlayerData():getLevel()
	if (not ship_lv) or (not my_level) then return false end
	
	local ship_leader_id = self.m_ship_data:getTeamLeaderUid(uid)
	local my_leader_id = self.m_ship_data:getTeamLeaderUid(self.m_my_uid)
	if ship_leader_id and my_leader_id then
		if ship_leader_id == my_leader_id then
			return false
		end
	end
	
	--再判断是否显灰
	local is_show_gray = false
	local show_gray_reason = nil
	
	local getGrayReason
	getGrayReason = function()
		if getGameData():getGuildInfoData():isGuildMember(uid) then
			is_show_gray = true
			show_gray_reason = "LOOT_TIP_OTHER_GUILD"
		elseif getGameData():getFriendDataHandler():isMyFriend(uid) then
			is_show_gray = true
			show_gray_reason = "LOOT_TIP_OTHER_FRIEND"
		end
	end

	local offset = my_level - ship_lv
	if is_my_name_red then
		if math.abs(offset) > LEVEL_LIMIT then
			is_show_gray = true
			if offset > 0 then
				show_gray_reason = "LOOT_TIP_MY_LEVEL_H"
			else
				show_gray_reason = "LOOT_TIP_OTHER_LEVEL_H"
			end
		else
			if not self.m_ship_data:isOpenLootSwitch(uid) then
				is_show_gray = true
				show_gray_reason = "LOOT_TIP_NOT_OPEN"
			else
				if not is_ship_name_red then
					local is_protect_area = PROTECT_AREA[getGameData():getSceneDataHandler():getMapId()] or false
					if is_protect_area then -- cclog("处于保护海域的白名玩家")
						is_show_gray = true
						show_gray_reason = "LOOT_TIP_PROTECT_AREA"
					else
						getGrayReason()
					end
				else
					getGrayReason()
				end
			end
		end
	else
		if math.abs(offset) > LEVEL_LIMIT then
			is_show_gray = true
			if offset > 0 then
				show_gray_reason = "LOOT_TIP_MY_LEVEL_H"
			else
				show_gray_reason = "LOOT_TIP_OTHER_LEVEL_H"
			end
		else
			getGrayReason()
		end
	end
	
	--如果按钮正常显示那么该显示什么对应弹框？
	local normal_tip = nil
	if not is_show_gray then
		if not is_my_name_red then
			normal_tip = "LOOT_TIP_OTHER_PIRATTE"
		end
	end
	
	return true, is_show_gray, show_gray_reason, normal_tip
end

ClsExplorePlayerShipsLayer.updateBolck = function(self, tx, ty)
	self.m_parent:getLand():getDecorateLayer():updateBolck(tx, ty)
	self.m_parent:getExploreEventLayer():updateBolck(tx, ty)
end

ClsExplorePlayerShipsLayer.updateMyShipHander = function(self, dt)
	ClsExplorePlayerShipsLayer.super.updateMyShipHander(self, dt)
	self.m_my_ship_logic:update(dt)
end

ClsExplorePlayerShipsLayer.updateMyShipSpeedHander = function(self, dt)
	if getGameData():getTeamData():isLock() then
		return
	end

	self:updateWindSpeedHander(dt) --顺，逆风更新
	local ship_result_rate = self:getMyShipNormalSpeedRate()
	if self.m_drop_info.is_droping then
		if IS_AUTO then
			--如果是在导航中点下了抛锚，则会中断导航，并且给一个默认的移动方向
			self.m_parent:getLand():breakAuto(true)
		end
		local pre_rate = self.m_drop_info.cur_speed_rate
		local now_rate = pre_rate - dt*self.m_drop_info.drop_speed
		if now_rate < 0 then
			now_rate = 0
		end
		self.m_drop_info.cur_speed_rate = now_rate
		ship_result_rate = ship_result_rate * now_rate
	end
	self.m_player_ship:setSpeedRate(ship_result_rate)

	--更新界面上的速度显示
	if ship_result_rate ~= self.m_my_ship_speed_info.result_rate then --优化，减少调用次数
		self.m_my_ship_speed_info.result_rate = ship_result_rate
		local explore_ui = getExploreUI()
		explore_ui:changeSpeed(ship_result_rate)
	end
end

ClsExplorePlayerShipsLayer.updateWindSpeedHander = function(self, dt)
	local wind_info = getGameData():getExploreData():getWindInfo()
	local wind_speed_rate = ORG_SPEED_RATE
	local wind_follow_state = WIND_NO_EFFECT
	if wind_info.dir ~= WIND_NO_EFFECT then
		local sail_state = self.m_my_ship_wind_info.sail_state
		wind_follow_state = wind_info.dir
		if wind_info.dir == WIND_HEAD then  --逆风
			if sail_state == SAIL_UP then
				wind_speed_rate = SPEED_RATE_HEADWIND
			end
		else    --顺风
			if sail_state == SAIL_UP then
				wind_speed_rate = self.m_my_ship_speed_info.down_wind_speed_rate
			end
		end

	end

	self.m_my_ship_speed_info.wind_speed_rate = wind_speed_rate
	if wind_follow_state ~= self.m_my_ship_wind_info.wind_follow_state then --优化，减少调用次数
		self.m_my_ship_wind_info.wind_follow_state = wind_follow_state
		local explore_ui = getExploreUI()
		explore_ui:changeWindHeadDown(wind_follow_state)
	end
end


ClsExplorePlayerShipsLayer.updateMyShipAllStatus = function(self)
	ClsExplorePlayerShipsLayer.super.updateMyShipAllStatus(self)
	if self.m_ship_data:getPosInfo(self.m_my_uid) then
		local touch_bg_spr = self.m_player_ship:getCaptainBgSpr()
		if not tolua.isnull(touch_bg_spr) and not touch_bg_spr.is_reg_touch then
			touch_bg_spr.is_reg_touch = true
			self.m_parent:regTouchEvent(touch_bg_spr, function(event, x, y)
				if event == "began" or event == "ended" then
					local pos = touch_bg_spr:convertToNodeSpace(ccp(x,y))
					local size = touch_bg_spr:getContentSize()
					local touch_rect = CCRect(0, 0, size.width, size.height)
					if touch_rect:containsPoint(ccp(pos.x, pos.y)) then
						if event == "ended" then
							self:tryToAddShowInfoBtn()
						end
						return true
					else
						return false
					end
				end
			end)
		end
	end
end

ClsExplorePlayerShipsLayer.tryToAddShowInfoBtn = function(self)
	local ui = self.m_player_ship.ui
	if tolua.isnull(ui.my_player_info_btn) then
		local my_player_info_btn = self.m_parent:createButton({image = "#explore_player_btn.png"})
		local icon = display.newSprite("#explore_player_view.png")
		local txt = createBMFont({fontFile = FONT_CFG_1, text = ui_word.CAMP_LOOK_FOR, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), size = 14, anchor = ccp(0.5,0.5), x = 0, y = -20})
		my_player_info_btn:addChild(icon)
		my_player_info_btn:addChild(txt, 1)
		my_player_info_btn:setPosition(ccp(-80, 45))
		ui:addChild(my_player_info_btn)
		ui.my_player_info_btn = my_player_info_btn

		my_player_info_btn:regCallBack(function()
			if not tolua.isnull(my_player_info_btn) then
				my_player_info_btn:removeFromParentAndCleanup(true)
			end
			getUIManager():create("gameobj/playerRole/clsRoleInfoView", nil, self.m_my_uid)
		end)


		local arr_action = CCArray:create()
		arr_action:addObject(CCDelayTime:create(5))
		arr_action:addObject(CCCallFunc:create(function()
			if not tolua.isnull(my_player_info_btn) then
				my_player_info_btn:removeFromParentAndCleanup(true)
			end
		end))
		my_player_info_btn:runAction(CCSequence:create(arr_action))
	end
end

ClsExplorePlayerShipsLayer.setMyShipMoveDir = function(self, screen_x, screen_y)
	local result_b = ClsExplorePlayerShipsLayer.super.setMyShipMoveDir(self, screen_x, screen_y)
	if result_b then
		self:cleanMyShipMoveAttr()
	end
	return result_b
end

ClsExplorePlayerShipsLayer.cleanMyShipMoveAttr = function(self)
	self.m_ship_data:setAttr(self.m_my_uid, "touch_something", nil)
	self.m_ship_data:setAttr(self.m_my_uid, "firing_mineral_id", nil)
end

--获取当前应该正常的船的速度
ClsExplorePlayerShipsLayer.getMyShipNormalSpeedRate = function(self)
	if self.m_my_ship_stop_info.is_waiting_touch then
		return 0
	end
	if self.m_my_ship_stop_info.stop_reason_count > 0 then
		return 0
	end
	local speed_info = self.m_my_ship_speed_info
	if speed_info.is_lock_speed then
		return speed_info.lock_speed_rate
	end
	local speed = speed_info.sailor_speed_rate * speed_info.wind_speed_rate
	if self.m_my_ship_wind_info.is_play_storm and (self.m_my_ship_wind_info.sail_state == SAIL_UP) then --如果是升帆和暴风雨，则加上暴风雨的影响
		speed = speed * speed_info.storm_speed_rate
	end
	if self.m_event_speed_info.is_mermaid_up then --如果是升帆和暴风雨，则加上暴风雨的影响
		speed = speed * speed_info.mermain_up_speed_rate
	end
	if speed > MAX_SPEED_RATE then
		speed = MAX_SPEED_RATE
	end
	speed = speed * speed_info.test_change_speed_rate
	return speed
end

------------------------------------------------------------------------------------------
--下面全是get, set方法
ClsExplorePlayerShipsLayer.setMyShipTestChangeSpeedRate = function(self, rate_n)
	self.m_my_ship_speed_info.test_change_speed_rate = rate_n
end

--获取当前应该正常的船的速度
ClsExplorePlayerShipsLayer.setLockSpeed = function(self, is_lock, speed)
	speed = speed or 0
	self.m_my_ship_speed_info.is_lock_speed = is_lock
	self.m_my_ship_speed_info.lock_speed = speed
	self.m_my_ship_speed_info.lock_speed_rate = speed / self.m_my_ship_speed_info.org_speed
end

ClsExplorePlayerShipsLayer.setMyShipSailorSpeedRate = function(self, rate_n)
	self.m_my_ship_speed_info.sailor_speed_rate = rate_n
end

ClsExplorePlayerShipsLayer.setSailState = function(self, state_n)
	self.m_my_ship_wind_info.sail_state = state_n
	self:updateWindSpeedHander(0) --更新是否逆风的信息
end

ClsExplorePlayerShipsLayer.getSailState = function(self, state_n)
	return self.m_my_ship_wind_info.sail_state
end

ClsExplorePlayerShipsLayer.getWindFollowState = function(self)
	return self.m_my_ship_wind_info.wind_follow_state
end

ClsExplorePlayerShipsLayer.setDownWindSpeedRate = function(self, rate_n)
	self.m_my_ship_speed_info.down_wind_speed_rate = rate_n
end

ClsExplorePlayerShipsLayer.setIsDroping = function(self, is_droping)
	self.m_drop_info.is_droping = is_droping
	if is_droping then
		self.m_drop_info.cur_speed_rate = 1
	end
end

ClsExplorePlayerShipsLayer.getIsDroping = function(self)
	return self.m_drop_info.is_droping
end

ClsExplorePlayerShipsLayer.setIsPlayStorm = function(self, is_play)
	self.m_my_ship_wind_info.is_play_storm = is_play
	if is_play then
		self.m_my_ship_speed_info.storm_speed_rate = SPEED_STROM_SAIL
	else
		self.m_my_ship_speed_info.storm_speed_rate = ORG_SPEED_RATE
	end
end

ClsExplorePlayerShipsLayer.setIsMermaidUp = function(self, is_up)
	self.m_event_speed_info.is_mermaid_up = is_up
end

return ClsExplorePlayerShipsLayer
