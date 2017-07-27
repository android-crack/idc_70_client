--2016/07/13
--create by wmh0497
--时段海盗
local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsCommonBase = require("gameobj/commonFuns")
local propEntity = require("gameobj/explore/exploreProp")
local ClsAlert = require("ui/tools/alert")
local UiCommon= require("ui/tools/UiCommon")
local ui_word = require("scripts/game_config/ui_word")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local dataTools = require("module/dataHandle/dataTools")
local sailor_info = require("game_config/sailor/sailor_info")

local ClsExplorePirateEventNpc = class("ClsExplorePirateEventNpc", ClsExploreNpcBase)

function ClsExplorePirateEventNpc:initNpc(data)
    self.m_npc_data = data
    self.m_cfg_item = data.cfg_item
    self.go_pos_index = 1
    self.m_create_tpos = {x = self.m_cfg_item.sea_pos[1], y = self.m_cfg_item.sea_pos[2]}
    local pos = self.m_explore_layer:getLand():cocosToTile2(self.m_create_tpos)
    self.m_create_pos = {x = pos.x, y = pos.y}
    self.m_pirate = nil
    -- self.m_is_send_msg = false
    self.m_stop_reason = string.format("ExplorePirateEventNpc_id_%d", self.m_npc_data.cfg_id)
end

local CREATE_DIS2 = 1400*1400
local REMOVE_DIS2 = 1600*1600
local BATTLE_DIS2 = 100*100
function ClsExplorePirateEventNpc:update(dt)
	local px, py = self:getPlayerShipPos()
	local dis2 = self:getDistance2(self.m_create_pos.x, self.m_create_pos.y, px, py)
	if self.m_pirate then
		if dis2 > REMOVE_DIS2 then
			self:removeModel()
			return
		end
		
		-- local pirateEventDataHander = getGameData():getExplorePirateEventData()
		-- if dis2 < BATTLE_DIS2 and self:isAutoCanFight() then
		-- 	if not self.m_is_send_msg then
		-- 		self.m_is_send_msg = true
		-- 		local pirateEventDataHander = getGameData():getExplorePirateEventData()
		-- 		if pirateEventDataHander:getPirateCd(self.m_npc_data.cfg_id) <= 0 then
		-- 			pirateEventDataHander:askFightPirate(self.m_npc_data.cfg_id)
		-- 		end
		-- 	end
		-- else
		-- 	self.m_is_send_msg = false
		-- end
	elseif dis2 < CREATE_DIS2 then
		self:createModel()
	end
end

function ClsExplorePirateEventNpc:isAutoCanFight()
	local pirateEventDataHander = getGameData():getExplorePirateEventData()
	
	--是否等级开放
	local is_level_open = pirateEventDataHander:isLvOpen()
	
	--是否是队员
	local is_team_lock  = getGameData():getTeamData():isLock() 
	
	--是否在自动经商
	local is_auto_trade = getGameData():getAutoTradeAIHandler():inAutoTradeAIRun() 
	
	--是否在自动悬赏
	local is_auto_port_reward = getGameData():getMissionData():getAutoPortRewardStatus() 

	--导航的目的是否导航到这里
	local explore_data = getGameData():getExploreData()
	local auto_info = explore_data:getAutoPos()
	local is_go_target = true
	if auto_info then
		is_go_target = false
		if auto_info.timePirateId then
			is_go_target = true
		end
	end

	return is_level_open and not is_team_lock and not is_auto_trade and not is_auto_port_reward and is_go_target
end

local TOUCH_DIS2 = 140*140
function ClsExplorePirateEventNpc:touch()
	local px, py = self.m_npc_layer:getTouchXY()
	local dis2 = self:getDistance2(self.m_create_pos.x, self.m_create_pos.y, px, py)
	if dis2 >= TOUCH_DIS2 then return end
	self:touchCallback()
end

function ClsExplorePirateEventNpc:touchCallback()
	if getGameData():getTeamData():isLock(true) then return end
	local pirateEventDataHander = getGameData():getExplorePirateEventData()
	if pirateEventDataHander:getPirateCd(self.m_npc_data.cfg_id) > 0 then
		ClsAlert:warning({msg = string.format(ui_word.PIRATE_CD_TIP, pirateEventDataHander:getPirateCd(self.m_npc_data.cfg_id))})
		return
	end
	if not pirateEventDataHander:isLvOpen(true) then
		return
	end

	local ships_layer = self.m_explore_layer:getShipsLayer()
	if not tolua.isnull(ships_layer) then
		ships_layer:setStopShipReason(self.m_stop_reason)
		local tips_str = string.format(ui_word.EXPLORE_PIRATE_BATTLE_TIP, self.m_npc_data.cfg_item.name)
		ClsAlert:showAttention(tips_str, function()
				ships_layer:releaseStopShipReason(self.m_stop_reason)
				if pirateEventDataHander:getPirateByCfgId(self.m_npc_data.cfg_id) then
					pirateEventDataHander:askFightPirate(self.m_npc_data.cfg_id)
				else
					ClsAlert:showAttention(ui_word.THIS_POINT_IS_MISS, nil, nil, nil, {hide_cancel_btn = true})
				end
			end, function()
				ships_layer:releaseStopShipReason(self.m_stop_reason)
			end, function()
				ships_layer:releaseStopShipReason(self.m_stop_reason)
			end)
	end
	return true
end

function ClsExplorePirateEventNpc:createModel()
	if self.m_pirate then
		return
	end
	local pirateEventDataHander = getGameData():getExplorePirateEventData()
	local time_pirate_config = getGameData():getExplorePirateEventData():getTimePirateConfig()
	time_pirate_config = time_pirate_config[self.m_npc_data.cfg_id]

	local model_cfg = self.m_npc_data.cfg_item.model_cfg
	
	local params = {}
	params.res = model_cfg.res
	params.animation_res = {model_cfg.amin[1]}
	params.water_res = {}
	params.sea_level = model_cfg.sea_level or 1
	params.hit_radius = 1

	self.m_pirate = propEntity.new(params)
	self.m_pirate:setPos(self.m_create_pos.x, self.m_create_pos.y)
	local id_str = tostring(self.m_id)
	self.m_pirate.node:setTag("exploreRewardPirateEventNpc", id_str)
	self.m_pirate.node:setTag("exploreNpcLayer", id_str)
	
	local _, particle = ClsCommonBase:addNodeEffect(self.m_pirate.node, "tx_shuibo", Vector3.new(0, 0, -50))--Vector3.new(self.m_create_pos.x, 0, self.m_create_pos.y))
	self.m_pirate_part = particle
	self.m_pirate_part_node = particle:GetNode()
	self.m_pirate_part:Start()
	
	local axis = self.m_pirate.node:getUpVector()
	self.m_pirate.node:setRotation(axis, math.rad(-180))

	local attack_btn = self.m_explore_layer:createButton({image = "#explore_plunder.png"})
	local show_text_lab = createBMFont({text = ui_word.STR_ATTACK, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
	attack_btn:addChild(show_text_lab)
	attack_btn:regCallBack(function() 
		self:touchCallback()
	end)
	attack_btn:setPosition(ccp(8, -65))
	self.m_pirate.ui:addChild(attack_btn)
	self.m_pirate.ui.attack_btn = attack_btn
	
	local name_lab = createBMFont({text = self.m_npc_data.cfg_item.name, size = 18, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), x = 8, y = 97})
	self.m_pirate.ui:addChild(name_lab)
	
	local red_name_cd_ui = display.newSprite("#explore_plunder_cd.png")
	local cd_lab = createBMFont({text = "", size = 16, color = ccc3(dexToColor3B(COLOR_RED))})
	local size = red_name_cd_ui:getContentSize()
	cd_lab:setPosition(ccp(size.width / 2, size.height / 2 - 2))

	red_name_cd_ui:addChild(cd_lab)
	red_name_cd_ui.cd_lab = cd_lab

	self.m_pirate.ui:addChild(red_name_cd_ui)
	self.m_pirate.ui.red_name_cd_ui = red_name_cd_ui

	local repeat_act = UiCommon:getRepeatAction(1, function() self:updateCdTime() end)
	self.m_pirate.ui:stopAllActions()
	self.m_pirate.ui:runAction(repeat_act)
	self:updateCdTime()
end

function ClsExplorePirateEventNpc:updateCdTime()
    local pirateEventDataHnader = getGameData():getExplorePirateEventData()
    local cd_time = pirateEventDataHnader:getPirateCd(self.m_npc_data.cfg_id)
    local red_name_cd_ui = self.m_pirate.ui.red_name_cd_ui
    local attack_btn = self.m_pirate.ui.attack_btn
    
    if cd_time > 0 then
        red_name_cd_ui:setVisible(true)
        attack_btn:setVisible(false)
        red_name_cd_ui.cd_lab:setString(tostring(dataTools:getTimeStrNormal(cd_time, true)))
    else
        red_name_cd_ui:setVisible(false)
        attack_btn:setVisible(true)
    end
end


function ClsExplorePirateEventNpc:removeModel()
	if self.m_pirate_part then
		self.m_pirate_part:Release()
		self.m_pirate_part = nil
		self.m_pirate_part_node = nil
	end
	if self.m_pirate then
		self.m_pirate:release()
	end
	self.m_pirate = nil
end

function ClsExplorePirateEventNpc:release()
    self:removeModel()
end

return ClsExplorePirateEventNpc