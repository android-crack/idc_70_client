--2016/05/23
--create by wmh0497
--风事件

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local ClsCommonBase = require("gameobj/commonFuns")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")

local ClsExploreWindEvent = class("ClsExploreWindEvent", ClsExploreEventBase)

-- WIND_DOWN = 1  -- 顺
-- WIND_HEAD = 2  -- 逆
-- WIND_NO_EFFECT = 3  -- 无风标志

local type_cfg = {
	["no_wind"] = WIND_NO_EFFECT,
	["down_wind"] = WIND_DOWN,
	["head_wind"] = WIND_HEAD,
}

local voice_cfg = {
	[WIND_DOWN] = {m = "VOICE_EXPLORE_1013", f = "VOICE_EXPLORE_1033"},
	[WIND_HEAD] = {m = "VOICE_EXPLORE_1014", f = "VOICE_EXPLORE_1034"},
}

function ClsExploreWindEvent:initEvent(event_date)
	self.m_event_data = event_date
	self.m_event_config_item = explore_event[self.m_event_data.evType]
	self.m_event_type = self.m_event_config_item.event_type
	self.m_wind_dir = type_cfg[self.m_event_type]
	self.m_explore_data = getGameData():getExploreData()
	self.m_during_time = self.m_event_config_item.time
	self.m_count_time = 0
	
	self.m_stop_reason_wait = string.format("%s_ExploreWindEvent_id%s_wait_1s", self.m_event_type, tostring(self.m_eid))
	self.m_active_key = string.format("%s_ExploreWindEvent_id%s_qte_key", self.m_event_type, tostring(self.m_eid))
	if self.m_wind_dir ~= WIND_NO_EFFECT then
		if not self.m_event_layer:hasActiveKey(self.m_active_key) then
			self.m_event_layer:addActiveKey(self.m_active_key, function() return self:getWindQteBtn() end)
		end
		self:playEventVoice(self.m_event_config_item.voice_appear)
	end
	self:createWindModel()
	
	if self.m_wind_dir == WIND_DOWN then
		self.m_ships_layer:setDownWindSpeedRate(1)
	end
end

local wind_btn_pic = {
	[WIND_DOWN] = "#explore_sail_down.png",
	[WIND_HEAD] = "#explore_sail_up.png",
}
function ClsExploreWindEvent:getWindQteBtn()
	local btn = self:getQteBtn(nil, 1, function() self.m_event_layer:removeActiveKey(self.m_active_key) end)
	
	local skill_spr = display.newSprite(wind_btn_pic[self.m_wind_dir])
	local size = btn:getNormalImageSpr():getContentSize()
	skill_spr:setPosition(ccp(size.width / 2, size.height / 2))
	btn:getNormalImageSpr():addChild(skill_spr)
	
	return btn
end

function ClsExploreWindEvent:update(dt)
	self.m_explore_data:setWindInfo(self.m_wind_dir)
	if self.m_wind_dir ~= WIND_NO_EFFECT then
		self:updatePos()
	end
	
	if self.m_is_end then
		return
	end
	self.m_count_time = self.m_count_time + dt
	if self.m_count_time > self.m_during_time then
		self:sendRemoveEvent(self.m_success_flag)
		self.m_is_end = true
	end
end

local wind_to_sial = {
	[WIND_DOWN] = SAIL_UP,
	[WIND_HEAD] = SAIL_DOWN,
}
function ClsExploreWindEvent:touch()
	if self.m_is_touch_qte_btn then return end
	self.m_is_touch_qte_btn = true
	
	local explore_ui = getExploreUI()
	if not tolua.isnull(explore_ui) then
		explore_ui:setSailState(wind_to_sial[self.m_wind_dir])
	end
	if self.m_wind_dir == WIND_DOWN then
		self.m_ships_layer:setDownWindSpeedRate(SPEED_RATE_DOWNWIND)
	end
end

function ClsExploreWindEvent:createWindModel()
    self:removeWindModel()
    if self.m_wind_dir ~= WIND_NO_EFFECT then
		local parent = Explore3D:getLayerShip3d()
        local _, particle = ClsCommonBase:addNodeEffect(parent, "tx_wind", Vector3.new(0, 0, 0))
        self.m_item_model = particle
        self.m_item_model_node = self.m_item_model:GetNode()
        self.m_item_model:Start()
        audioExt.playEffect(music_info.EX_WIND.res, false)
        
        local angle = self:getWindAngle(self.m_wind_dir)
        local axis = self.m_item_model_node:getUpVector()
        self.m_item_model_node:setRotation(axis, math.rad(angle))
    end
end

function ClsExploreWindEvent:getWindAngle(wind_dir)
    local angle_n = self.m_player_ship:getAngle()
    if wind_dir == WIND_HEAD then
        angle_n = angle_n - 180
    end
    if angle_n > 180 then
        angle_n = angle_n - 360
    end
    if angle_n < -180 then
        angle_n = angle_n + 360
    end
    angle_n = angle_n * -1
    return angle_n
end

function ClsExploreWindEvent:removeWindModel()
    if self.m_item_model then
        self.m_item_model:Release()
        self.m_item_model = nil
        self.m_item_model_node = nil
    end
end

function ClsExploreWindEvent:updatePos()
    if self.m_item_model then
        local px, py = self.m_player_ship:getPos()
        local pos = CameraFollow:cocosToGameplayWorld(ccp(px, py))
        --local vec = Vector3.new(pos:x(), 11, pos:z())
        --self.m_item_model_node:setTranslation(vec)
        self.m_item_model_node:setTranslation(pos:x(), 11, pos:z())
        if not self.m_item_model:IsPlaying() then
            self.m_item_model:Stop()
            self.m_item_model:Start()
        end

    end
end

function ClsExploreWindEvent:release()
	self.m_explore_data:setWindInfo(WIND_NO_EFFECT)
	self.m_event_layer:removeActiveKey(self.m_active_key)
	self:removeWindModel()
	if self.m_wind_dir == WIND_DOWN then
		self.m_ships_layer:setDownWindSpeedRate(1)
	end
	if self.m_is_touch_qte_btn and self.m_wind_dir == WIND_HEAD then
		local explore_ui = getExploreUI()
		if not tolua.isnull(explore_ui) then
			if explore_ui:getSailState() ~= SAIL_UP then
				explore_ui:setSailState(SAIL_UP)
			end
		end
	end
end

return ClsExploreWindEvent