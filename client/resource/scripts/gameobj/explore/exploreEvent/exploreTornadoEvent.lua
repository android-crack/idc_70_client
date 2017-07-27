--2016/05/23
--create by wmh0497
--龙卷风

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local ClsCommonBase = require("gameobj/commonFuns")
local propEntity = require("gameobj/explore/exploreProp")
local ClsSceneUtil = require("gameobj/explore/sceneUtil")
local ClsSkillCalc = require("module/battleAttrs/skill_calc")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")

local ClsExploreTornadoEvent = class("ClsExploreTornadoEvent", ClsExploreEventBase)

function ClsExploreTornadoEvent:initEvent(event_date)
	self.m_event_data = event_date
	local event_config_item = explore_event[self.m_event_data.evType]
	self.m_event_config_item = event_config_item
	self.m_event_type = event_config_item.event_type

	local param = {}
	param.res = event_config_item.res
	param.animation_res = event_config_item.animation_res
	param.water_res = event_config_item.water_res
	param.sea_level = event_config_item.sea_level
	param.type = self.m_event_type
	param.item_id = self.m_eid
	param.hit_radius = event_config_item.hit_radius

	self.m_count_time = 0
	self.m_go_port_id = 0

	self.m_stop_reason = string.format("%s_ExploreTornadoEvent_id%s_stop_ship", self.m_event_type, tostring(self.m_eid))
	self.m_black_lock_touch_view_name_str = string.format("ClsEventBlackTouchLockView_%s", self.m_eid)

	if IS_AUTO then
		self:sendRemoveEvent(self.m_bad_pos_remove_flag)
		self.m_is_end = true
		return
	end

	self:createModel()
end

function ClsExploreTornadoEvent:createModel()
	local px, py = self.m_player_ship:getPos()
	local x, z, angle = ClsCommonBase:getShipNearPos()
	local ship_pos = self.m_player_ship.node:getTranslationWorld()
	local start_x = ship_pos:x() + x
	local start_y = ship_pos:z() + z
	local parent = Explore3D:getLayerShip3d()
    local _, particle = ClsCommonBase:addNodeEffect(parent, "tx_longjuanfeng")
    self.m_tornado_particle = particle
    particle:Start()
    self.m_tornado_node = particle:GetNode()
    self.m_tornado_node:setTranslation(start_x, 0, start_y)
    self.m_state = "closing"
    self.m_speed = 300
    self.m_is_stop_ship = false
    self.m_direction = Vector3.new(-x, 0, -z)
end

--Math.distance(x, y, px, py)
function ClsExploreTornadoEvent:update(dt)
    if self.m_is_end then
        return
    end
    
    if getGameData():getBattleDataMt():GetBattleSwitch() then
        self:sendRemoveEvent(self.m_hit_remove_flag)
        self.m_is_end = true
        return
    end
    
    local tornado_vec3 = self.m_tornado_node:getTranslationWorld()
    local player_vec3 = self.m_player_ship.node:getTranslationWorld()
    local dis = GetVectorDistance(player_vec3, tornado_vec3)
    
    if self.m_state == "closing" then
        self.m_direction:set(player_vec3:x() - tornado_vec3:x(), self.m_direction:y(), player_vec3:z() - tornado_vec3:z())
        self.m_direction:normalize()
        if dis < 40 then
            self.m_speed = 0
            self.m_ships_layer:setStopShipReason(self.m_stop_reason)
            self.m_is_stop_ship = true
            self.m_state = "touching_pre"
            self:showMoveEffect()
            return
        end
    elseif self.m_state == "touching_pre" then
        return
    elseif self.m_state == "touching_after" then
        return
    elseif self.m_state == "outing" then
        if self.m_is_stop_ship then
            self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
            self.m_is_stop_ship = false
            self.m_is_delay_delete = true
        end
        self.m_speed = 500
        if dis > 1200 then
            self.m_is_end = true
            self.m_event_layer:forceDeleteById(self.m_eid)
            return
        end
    end
    
    local target_forward = Vector3.new()
    target_forward:set(self.m_direction:x(), self.m_direction:y(), self.m_direction:z())
    target_forward:scale(self.m_speed * dt)
    self.m_tornado_node:translate(target_forward)
end

function ClsExploreTornadoEvent:showMoveEffect()
	getGameData():getMissionData():clearPlot()

	local lock_view = getUIManager():create("gameobj/explore/exploreEvent/clsEventBlackTouchLockView", nil, self.m_black_lock_touch_view_name_str)
	lock_view:getBlackLayer():setOpacity(0)

	local array = CCArray:create()
	local time = 1.0
	local to_port_id = 0
	local port_info = require("game_config/port/port_info")
	--
	local port_list = getGameData():getExploreData():getCurrentAreaPorts() --已开
	local index = Math.random(1, #port_list)
	to_port_id = port_list[index]
	self.m_go_port_id = to_port_id
	array:addObject(CCFadeIn:create(time))
	array:addObject(CCCallFunc:create(function()
		local pos = ccp(port_info[to_port_id].ship_pos[1], port_info[to_port_id].ship_pos[2])
		local posConfigs = {pos = self.m_explore_layer:getLand():cocosToTile2(ccp(pos.x, pos.y)),
							portId =  to_port_id}
		local t_pos = posConfigs.pos
		self.m_player_ship:setPos(t_pos.x, t_pos.y)
		self.m_explore_layer:getLand():initLandField()
		CameraFollow:update(self.m_player_ship)
		self.m_explore_layer:getLand():update(1 / 60)
		local vec3 = self.m_player_ship.node:getTranslationWorld()
		self.m_tornado_node:setTranslation(vec3)
		local explore_ui = getExploreUI()

		local angle = port_info[posConfigs.portId].ship_dir 
		self.m_explore_layer:shipRotate(angle)
		explore_ui.world_map:setShipPosInfo({angle = angle, x = t_pos.x, y = t_pos.y})
		explore_ui.world_map:showMin()
		self.m_state = "touching_after"
		self.m_explore_layer:getShipsLayer():fastUpMyShipPos()
	end))
	array:addObject(CCFadeOut:create(time + 0.01))
	array:addObject(CCCallFunc:create(function()
		--对话框
		local name = port_info[to_port_id].name
		local function began_call()
			audioExt.playEffect(music_info[self.m_event_config_item.sound_id[1]].res)
			self.m_state = "outing"
			local x, z = ClsCommonBase:getShipNearPos()
			self.m_direction:set(x, 0, z)
			self.m_direction:normalize()
			self:sendRemoveEvent(self.m_go_port_id)
		end
		local function end_call()
		end
		getUIManager():close(self.m_black_lock_touch_view_name_str)
		self:playEventVoice(self.m_event_config_item.voice_fail)
		EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {beganCallBack = began_call, call_back = end_call, tip_id = self.m_event_config_item.tip_id[1]}, name)
	end))
	lock_view:getBlackLayer():runAction(CCSequence:create(array))
end

function ClsExploreTornadoEvent:release()
	self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
	if self.m_tornado_particle then
		self.m_tornado_particle:Release()
		self.m_tornado_particle = nil
		self.m_tornado_node = nil
	end
end

return ClsExploreTornadoEvent