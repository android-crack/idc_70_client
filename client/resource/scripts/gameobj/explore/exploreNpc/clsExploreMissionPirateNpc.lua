--
-- Author: lzg0496
-- Date: 2016-11-15 22:38:39
-- Function: 任务海盗追击

local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsExploreShip3d = require("gameobj/explore/exploreShip3d")
local UiCommon= require("ui/tools/UiCommon")
local ui_word = require("scripts/game_config/ui_word")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local dataTools = require("module/dataHandle/dataTools")
local ClsAlert = require("ui/tools/alert")
local sailor_info = require("game_config/sailor/sailor_info")
local music_info = require("game_config/music_info")
local DialogQuene = require("gameobj/quene/clsDialogQuene")
local clsMissionPiratePlot = require("gameobj/quene/clsMissionPritateQuene")

local clsExploreMissionPirateNpc = class("clsExploreMissionPirateNpc", ClsExploreNpcBase)

function clsExploreMissionPirateNpc:initNpc(data)
	self.m_npc_data = data
	self.m_cfg_item = data.cfg_item
	self.m_cfg_id = self.m_npc_data.cfg_id
	self.m_is_guild = (self.m_cfg_item.guide == 1)
	self.m_ship = nil
	self.m_is_send_msg = false
	self.m_is_can_fight = false
	self.m_stop_reason = string.format("ExploreMissionPirateEventNpc_id_%d", self.m_npc_data.cfg_id)
	self.m_wait_reason = string.format("NPC_ExploreBoxEvent_id_%s_wait_1s", tostring(self.m_npc_data.cfg_id))
	self.m_active_key = string.format("NPC_ExploreMissionPirateEventNpc_id_%s_qte_key", tostring(self.m_npc_data.cfg_id))
	self.m_status = "waiiting_show"
	self.m_is_lock = nil
	self:setLockMoveStatus(false)
end

function clsExploreMissionPirateNpc:setLockMoveStatus(is_lock)
	if self.m_is_lock ~= is_lock then
		self.m_is_lock = is_lock
		getGameData():getMissionPirateData():setIslockTimeById(self.m_cfg_id, self.m_is_lock)
	end
end

local CREATE_DIS2 = 1000*1000
local REMOVE_DIS2 = 1100*1100
local BATTLE_DIS2 = 100*100
local SHOW_DIS2 = 250*250
local CLOSEING_MAX_DIS2 = 600*600

function clsExploreMissionPirateNpc:update(dt)
	self.m_cur_x, self.m_cur_y = getGameData():getMissionPirateData():getPosInLand(self.m_npc_data.cfg_id)

	if self.m_status == "waiiting_show" then
		self:setLockMoveStatus(false)
		self:tryToCreate(dt)
	elseif self.m_status == "waiting_closeing" then
		self:setLockMoveStatus(false)
		self:walkOwnPath()
	elseif self.m_status == "go_closing" then
		self:setLockMoveStatus(true)
		self:goClosing(dt)
	end
end

function clsExploreMissionPirateNpc:tryToCreate(dt)
	local px, py = self:getPlayerShipPos()
	local dis2 = self:getDistance2(self.m_cur_x, self.m_cur_y, px, py)
	if dis2 < CREATE_DIS2 then
		self:createShip()
		self.m_status = "waiting_closeing"
	end
end

function clsExploreMissionPirateNpc:walkOwnPath()
	local px, py = self:getPlayerShipPos()
	local dis2 = self:getDistance2(self.m_cur_x, self.m_cur_y, px, py)
	if dis2 > REMOVE_DIS2 then
		self:removeShip()
		self.m_status = "waiiting_show"
		return
	end
	local translate1 = self.m_ship.node:getTranslationWorld()
	self.m_ship:setPos(self.m_cur_x, self.m_cur_y)
	local translate2 = self.m_ship.node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(translate2, translate1, dir)
	LookForward(self.m_ship.node, dir)
	
	if dis2 <= SHOW_DIS2 then
		if self:tryShowDialog() then
			self.m_status = "go_closing"
		end
	end
end

function clsExploreMissionPirateNpc:goClosing(dt)
	local ships_layer = self.m_ships_layer
	if not self:tryOpenTouch() then
		return
	end
	local sx, sy = self.m_ship:getPos()
	local px, py = self:getPlayerShipPos()
	local true_dis2 = self:getDistance2(sx, sy, px, py)
	if true_dis2 < BATTLE_DIS2 then
		self.m_ship:setPause(true)
		if self.m_is_can_fight then
			if not self:tryOpenTouch() then
				return
			end
			self.m_event_layer:addActiveKey(self.m_active_key, function() 
				local qte_btn = self:getQteBtn(self.m_wait_reason, 1, nil, self.m_is_guild, self.m_cfg_item.qte_icon)
				-- self:tryAutoFight(qte_btn)
				ships_layer:setIsWaitingTouch(true)
				return qte_btn
			end, true)
			return
		end
	end

	if true_dis2 > SHOW_DIS2 then
		self.m_event_layer:removeActiveKey(self.m_active_key)
		self.m_ship:setPause(false)
	end
	
	if true_dis2 > REMOVE_DIS2 then
		self:removeShip()
		self.m_status = "waiiting_show"
		return
	end
	local explore_layer = getExploreLayer() 
	if not self.m_is_send_msg then
		self.m_is_send_msg = true
		self.m_is_can_fight = true
		local mission_pirate_data = getGameData():getMissionPirateData()
		if self.m_cfg_item.diaolog and self.m_npc_data.attr.isMeet == 0 then
			local func = function()
				if not self:tryOpenTouch() then
					if DialogQuene.doing_task then
						DialogQuene.doing_task:TaskEnd()
					end
					return
				end
				self.m_is_can_fight = false
				ships_layer:setStopShipReason(self.m_stop_reason)
				ships_layer:setStopShipReason("mission_pirate_stop")
				self.m_ship:setPause(true)
				local dialog_tab = table.clone(self.m_cfg_item.diaolog)
				dialog_tab.call_back = function()
					if DialogQuene.doing_task then
						DialogQuene.doing_task:TaskEnd()
					end
					if not self:tryOpenTouch() then
						return
					end
					self.m_is_can_fight = true
					self.m_ship:setPause(false)
					ships_layer:releaseStopShipReason(self.m_stop_reason)
					if not self.m_event_layer:hasActiveKey(self.m_active_key) then
						self.m_event_layer:addActiveKey(self.m_active_key, function() 
							local qte_btn = self:getQteBtn(self.m_wait_reason, 1, nil, self.m_is_guild, self.m_cfg_item.qte_icon)
							-- self:tryAutoFight(qte_btn)
							return qte_btn
						end, true)
					end
				end
				getUIManager():create("gameobj/mission/plotDialog", nil, dialog_tab)
				self.m_npc_data.attr.isMeet = 1
	        	mission_pirate_data:askPirateMeet(self.m_npc_data.cfg_id)
	        end
	        DialogQuene:insertTaskToQuene(clsMissionPiratePlot.new({plot_func = func}))
		end
	else
		if self.m_is_can_fight then
			if not self:tryOpenTouch() or true_dis2 > SHOW_DIS2 then
				return
			end

			self.m_ship:setPause(true)
			self.m_event_layer:addActiveKey(self.m_active_key, function() 
				local qte_btn = self:getQteBtn(self.m_wait_reason, 1, nil, self.m_is_guild, self.m_cfg_item.qte_icon ) 
				ships_layer:setIsWaitingTouch(true)
				-- self:tryAutoFight(qte_btn)
				return qte_btn
			end, true)
		end
	end
	
	local dis2 = self:getDistance2(self.m_cur_x, self.m_cur_y, sx, sy)
	local player_dis2 = self:getDistance2(self.m_cur_x, self.m_cur_y, px, py)
	if dis2 > CLOSEING_MAX_DIS2 and (player_dis2 > CLOSEING_MAX_DIS2)  then
		return
	end
	local translate1 = self.m_player_ship.node:getTranslationWorld()
	local translate2 = self.m_ship.node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(translate1, translate2, dir)
	LookForward(self.m_ship.node, dir)
	self.m_ship:update(dt)
end

--特殊活动的特殊处理
function clsExploreMissionPirateNpc:tryShowDialog()
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	local team_is_lock = getGameData():getTeamData():isLock()
	local missionDataHandler = getGameData():getMissionData()
	if team_is_lock then
		return false
	end

	--是否自动悬赏
    local is_auto_reward = missionDataHandler:getAutoPortRewardStatus() 
    --是否自动经商
    local is_auto_trade = auto_trade_data:getIsAutoTrade()

	return (not is_auto_trade and not is_auto_reward)
end

function clsExploreMissionPirateNpc:tryOpenTouch()
	if not self.m_ship then
        return false
    end

    return true
end

function clsExploreMissionPirateNpc:tryAutoFight(qte_btn)
	-- if tolua.isnull(qte_btn) or getGameData():getTeamData():isLock() then
	-- 	return
	-- end

	-- local arr_action = CCArray:create()
	-- arr_action:addObject(CCDelayTime:create(3))
	-- arr_action:addObject(CCCallFunc:create(function() self:touch() end)) 
	-- qte_btn:runAction(CCSequence:create(arr_action))
end

function clsExploreMissionPirateNpc:touch()
	if getGameData():getTeamData():isLock() then
		ClsAlert:warning({msg = ui_word.STR_COPY_QTE_TEAM_TIP})
		self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
		self.m_event_layer:removeActiveKey(self.m_active_key)
		return 
	end
	audioExt.playEffect(music_info.BATTLE_BEGIN.res)
	local explore_layer = getExploreLayer() 
	local ships_layer = explore_layer:getShipsLayer()
	if not tolua.isnull(ships_layer) then
		ships_layer:setStopShipReason(self.m_stop_reason)
		local enter_battle_func = function()
				local mission_pirate_data = getGameData():getMissionPirateData()
				mission_pirate_data:askFightPirate(self.m_cfg_item.battle_id, self.m_npc_data.cfg_id)
			end
		if self.m_cfg_item.mission3d_scene > 0 then
			--模拟调用rpc的内容来进入一个任务场景
			local sceneDataHandler = getGameData():getSceneDataHandler()
			sceneDataHandler:cleanInfo()
			sceneDataHandler:setMissionScene(self.m_cfg_item.mission3d_scene)
			startMission3dScene(self.m_cfg_item.mission3d_scene, {close_callback = enter_battle_func})
		else
			enter_battle_func()
		end
	end
	return true
end

function clsExploreMissionPirateNpc:createShip()
    if self.m_ship then
        return
    end

    local ship_id = self.m_cfg_item.ship_id
    self.m_ship = ClsExploreShip3d.new({
            id = ship_id,
            pos = ccp(self.m_cur_x, self.m_cur_y),
            speed = boat_attr[ship_id].speed + EXPLORE_ADD_SPEED,
            name = self.m_cfg_item.name,
            name_color = COLOR_RED_STROKE,
            ship_ui = getShipUI(),
            force_power_res = self.m_npc_data.attr.flag,
        })
    local id_str = tostring(self.m_id)
    self.m_ship.land = self.m_explore_layer:getLand()
    self.m_ship.node:setTag("explorePirateEventNpc", id_str)
    self.m_ship.node:setTag("exploreNpcLayer", id_str)

    
end

function clsExploreMissionPirateNpc:removeShip()
	self.m_event_layer:removeActiveKey(self.m_active_key)
    if self.m_ship then
        self.m_ship:release()
    end
    self.m_ship = nil
    self.m_is_send_msg = false
    self.m_is_can_fight = false
end

function clsExploreMissionPirateNpc:release()
	self:removeShip()
	self:setLockMoveStatus(false)
	self.m_is_send_msg = false
	self.m_is_can_fight = false
end

return clsExploreMissionPirateNpc