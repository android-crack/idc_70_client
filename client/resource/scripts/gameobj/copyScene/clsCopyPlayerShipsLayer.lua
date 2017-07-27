--2016/07/22
--create by wmh0497
--用于显示在副本里同步的玩家船

local MAX_SHIP_COUNT = 10

local ORG_SPEED_RATE = 1

local ui_word = require("game_config/ui_word")
local rpc_down_info = require("game_config/rpc_down_info")
local copySceneConfig = require("gameobj/copyScene/copySceneConfig")
local UiCommon= require("ui/tools/UiCommon")
local ClsAlert = require("ui/tools/alert")
local ClsPlayerShipsLayerBase = require("gameobj/explore/clsPlayerShipsLayerBase")

local ClsCopyPlayerShipsLayer = class("ClsCopyPlayerShipsLayer", ClsPlayerShipsLayerBase)

function ClsCopyPlayerShipsLayer:ctor(parent)

	ClsCopyPlayerShipsLayer.super.ctor(self, parent)
	self.m_my_ship_up_pos_info.is_arrive_point_stop = true
	self.m_drop_info = {}
	self.m_drop_info.is_droping = false
	self.m_drop_info.cur_speed_rate = 1
	self.m_drop_info.drop_speed = 1
	
	self.m_is_check_ghost = false
	self.m_teleporting_limit_dis = 250

	self.m_my_ship_speed_info = {}
	self.m_my_ship_speed_info.buff_up_speed_rate = SPEED_RATE_BUFF_UP
	self.m_my_ship_speed_info.supply_speed_rate = 0

	self.m_event_speed_info = {}
	self.m_event_speed_info.buff_up_end_time = 0 --加速buff
	self.m_event_speed_info.is_buff_up = false 
	self.m_event_speed_info.is_supply = false
end

function ClsCopyPlayerShipsLayer:onEnter()
	ClsCopyPlayerShipsLayer.super.onEnter(self)
end

function ClsCopyPlayerShipsLayer:onExit()
	ClsCopyPlayerShipsLayer.super.onExit(self)
end

function ClsCopyPlayerShipsLayer:initMapConfig()
	self.m_tile_width  = self.m_parent:getLand():getTileWidth()
	self.m_tile_height = self.m_parent:getLand():getTileHeight()
end

function ClsCopyPlayerShipsLayer:isInMyShipsView(ptx, pty, pos_info)
	if self.m_is_check_ghost then
		if self.m_ship_data:isJionCamp() and (not self.m_ship_data:isSameCamp(pos_info.uid)) then
			if self.m_ship_data:isGhostStatus(pos_info.uid) then
				return false
			end
		end
		return ClsCopyPlayerShipsLayer.super.isInMyShipsView(self, ptx, pty, pos_info)
	else
		return true
	end
end

--副本做特殊处理
function ClsCopyPlayerShipsLayer:checkIsFarRemove()
end

local DIS2 = 320*320
function ClsCopyPlayerShipsLayer:updateShipInfo(uid, ship, is_in_team, is_leader)
	if self.m_is_check_ghost then
		local has_attack = false
		local is_has_attack = not self.m_ship_data:isFighting(uid)
		if not self.m_ship_data:isSameCamp(uid) and is_has_attack then  --如果是敌对阵营才显示  
			local px, py = self.m_player_ship:getPos()
			local sx, sy = ship:getPos()
			local dis2 = (px - sx)*(px - sx) + (py - sy)*(py - sy)
			if dis2 < DIS2 then
				has_attack = true
			end
		end
		
		if has_attack then
			if tolua.isnull(ship.ui.attack_btn) then
				local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
				local attack_btn = copy_scene_layer:createButton({image = "#explore_plunder.png"})
				local show_text_lab = createBMFont({text = ui_word.STR_ATTACK, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
				attack_btn:addChild(show_text_lab)
				attack_btn:regCallBack(function() 
					if self.m_ship_data:isGhostStatus(self.m_my_uid) then
						ClsAlert:warning({msg = ui_word.GUILD_STRONGHOLD_GHOST_CAN_NOT_FIGHT})
						return
					end
					
					if self.m_ship_data:isFighting(uid) then
						ClsAlert:warning({msg = rpc_down_info[142].msg})
						return
					end

					local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
					if ClsSceneManage:doLogic("isNotCanInteractive") then
						return
					end
					
					self:askAttack(uid)
				end)
				attack_btn:setPosition(ccp(0, -30))
				attack_btn:setTouchEnabled(true)
				ship.ui:addChild(attack_btn)
				ship.ui.attack_btn = attack_btn
			end
		else
			if not tolua.isnull(ship.ui.attack_btn) then
				ship.ui.attack_btn:removeFromParentAndCleanup(true)
			end
			ship.ui.attack_btn = nil
		end
	end
end

function ClsCopyPlayerShipsLayer:touchShip(node)
	if not node then return end
	local index = node:getTag("playerShipsLayerBase")
	if not index then return end
	local uid = tonumber(index)
	local ship = self.m_player_ships[uid]
	if ship then
		if self.m_ship_data:isJionCamp() and (not self.m_ship_data:isSameCamp(uid)) then
			return false
		else
			return self.m_touch_manage:touchShip(uid, ship)
		end
	end
end

function ClsCopyPlayerShipsLayer:askAttack(uid)
	GameUtil.callRpc("rpc_server_object_interactive", {uid, copySceneConfig.INTERACTIVE_TYPE.ATTACK, {}})
end

function ClsCopyPlayerShipsLayer:createShip(uid)
	local ship = ClsCopyPlayerShipsLayer.super.createShip(self, uid)
	self:updateAttr(uid)
	return ship
end

function ClsCopyPlayerShipsLayer:getShipParam(uid)
	local params = ClsCopyPlayerShipsLayer.super.getShipParam(self, uid)
	
	params.speed = params.speed * self.m_parent:getSpeedRate()
	return params
end

function ClsCopyPlayerShipsLayer:updateShipUi(uid)
	ClsCopyPlayerShipsLayer.super.updateShipUi(self, uid)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:doLogic("updateMissions")
end

function ClsCopyPlayerShipsLayer:updateShipStatus(uid)
	ClsCopyPlayerShipsLayer.super.updateShipStatus(self, uid)
	local pos_info = self.m_ship_data:getPosInfo(uid)
	if pos_info then
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
		ClsSceneManage:doLogic("setCampShipName", self:getShipWithMyShip(uid), pos_info.status.camp)
		ClsSceneManage:doLogic("setShipKillTitle", self:getShipWithMyShip(uid), pos_info.status.kill_title_n)
	end
end

function ClsCopyPlayerShipsLayer:getPlayerShipUI()
	return getSceneShipUI()
end

function ClsCopyPlayerShipsLayer:getAllShips()
	return self.m_player_ships
end

function ClsCopyPlayerShipsLayer:updateAttr(uid)
	local pos_info = self.m_ship_data:getPosInfo(uid)
	local ship = self:getShipWithMyShip(uid)
	if pos_info and ship then
		local is_lock = (pos_info.attr["forbiden_move"] == 1)
		ship:setLockMove(is_lock)
		local is_has_supply = (pos_info.attr["supply"] == 1)
		ship:showOrHideSupplyIcon(is_has_supply)
	end
end

function ClsCopyPlayerShipsLayer:getCampColor(is_same)
	if is_same then
		return COLOR_BLUE_STROKE
	else
		return COLOR_RED_STROKE
	end
end

function ClsCopyPlayerShipsLayer:updateMyShipSpeedHander(dt)
	if getGameData():getTeamData():isLock() then
		return
	end
	local ship_result_rate = self:getMyShipNormalSpeedRate()
	if self.m_drop_info.is_droping then
		local pre_rate = self.m_drop_info.cur_speed_rate
		local now_rate = pre_rate - dt*self.m_drop_info.drop_speed
		if now_rate < 0 then
			now_rate = 0
		end
		self.m_drop_info.cur_speed_rate = now_rate
		ship_result_rate = ship_result_rate * now_rate
	end
	self.m_player_ship:setSpeedRate(ship_result_rate)
end

function ClsCopyPlayerShipsLayer:setMyShipMoveDir(screen_x, screen_y)
	if self.m_player_ship:getIsLockMove() then
		return true
	end
	
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")

	local is_pass = ClsSceneManage:doLogic("checkPassPos", screen_x, screen_y)
	if not is_pass then
		return false
	end

	local result_b = ClsCopyPlayerShipsLayer.super.setMyShipMoveDir(self, screen_x, screen_y)
	if result_b then
		self.m_ship_data:setAttr(self.m_my_uid, "touch_something", nil)
	end
	return result_b
end

--获取当前应该正常的船的速度
function ClsCopyPlayerShipsLayer:getMyShipNormalSpeedRate()
	if self.m_my_ship_stop_info.is_waiting_touch then
		return 0
	end
	if self.m_my_ship_stop_info.stop_reason_count > 0 then
		return 0
	end

	if self.m_event_speed_info.is_supply then
		return self.m_my_ship_speed_info.supply_speed_rate
	end

	local speed_info = self.m_my_ship_speed_info
	if self.m_event_speed_info.is_buff_up then
		return speed_info.buff_up_speed_rate
	end
	return 1
end

------------------------------------------------------------------------------------------
--下面全是get, set方法
function ClsCopyPlayerShipsLayer:setIsDroping(is_droping)
	self.m_drop_info.is_droping = is_droping
	if is_droping then
		self.m_drop_info.cur_speed_rate = 1
	end
end

function ClsCopyPlayerShipsLayer:setIsCheckGhost(status_b)
	self.m_is_check_ghost = status_b
end

function ClsCopyPlayerShipsLayer:setIsBuffUp(is_up)
	self.m_event_speed_info.is_buff_up = is_up
end

function ClsCopyPlayerShipsLayer:setIsSupply(is_has_supply)
	self.m_event_speed_info.is_supply = is_has_supply
	self.m_my_ship_speed_info.supply_speed_rate = SPEED_RATE_BUFF_UP * 0.7
	self:setIsBuffUp(not is_has_supply)
end

return ClsCopyPlayerShipsLayer