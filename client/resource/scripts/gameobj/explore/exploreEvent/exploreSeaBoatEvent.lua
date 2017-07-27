---悬赏海底沉船
---fmy0570

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local explore_event = require("game_config/explore/explore_event")
local explore_skill = require("game_config/explore/explore_skill")
local music_info = require("game_config/music_info")

local ClsExploreSeaBoatEvent = class("ClsExploreSeaBoatEvent", ClsExploreEventBase)

local DIS = 50*50
local explore_event_judian = 28 
local explore_event_baocang = 18
local explore_event_seaboat = 17
local BATTON_ID = 1070   ---按钮id
local TREASURE_ID = 80   ---藏宝图id
local TREASURE_VIP_ID = 164   ---高级藏宝图

function ClsExploreSeaBoatEvent:initEvent()

    self.explore_event_id = 0
    self.explore_event_id = explore_event_seaboat       


	local event_config_item = explore_event[self.explore_event_id]
	self.m_event_type = event_config_item.event_type
	--self.m_active_skill_item = explore_skill[event_config_item.effective_skill_id]
	local param = {}
    param.res = event_config_item.res
    param.animation_res = event_config_item.animation_res
    param.water_res = event_config_item.water_res
    param.sea_level = event_config_item.sea_level
    param.type = self.m_event_type
    param.item_id = self.m_eid
    param.sea_down = event_config_item.sea_down
    param.hit_radius = event_config_item.hit_radius

    self.m_item_model = propEntity.new(param)
    self.m_item_model.node:setTag("explore_event_id", tostring(self.m_eid))

    self.m_skill_id = BATTON_ID

    self.m_stop_reason = string.format("%s_ExploreSeaBoatEvent_id%s_getReward", self.m_event_type, tostring(self.m_eid))
    
	local missionDataHandler = getGameData():getMissionData()
	local cur_daily_mission_data = missionDataHandler:getHotelRewardAccept()

	local pos = cur_daily_mission_data.json_info.wreckInfo
    local item = self.m_explore_layer:getLand():cocosToTile2(ccp(pos["position_x"], pos["position_y"]))
    
    self.m_item_model:setPos(item.x, item.y)
end

function ClsExploreSeaBoatEvent:isCreateSeaBoat()
	local missionDataHandler = getGameData():getMissionData()
	local daily_mission = missionDataHandler:getHotelRewardAccept()
	if daily_mission and daily_mission.json_info["wreckInfo"] and daily_mission.status ~= MISSION_STATUS_COMPLETE then
		return true
	end
    return false
end

function ClsExploreSeaBoatEvent:update(dt)
    if self.m_is_end or self.m_is_firing then
        return
    end

    local x, y = self.m_item_model:getPos()
    local px, py = self.m_player_ship:getPos()
    local dis2 = self:getDistance2(x, y, px, py)
    if dis2 < DIS and not self.m_is_firing then
        self:showEventEffect()
    end       
end

function ClsExploreSeaBoatEvent:showEventEffect()
    local team_data = getGameData():getTeamData()
    if team_data:isLock() then
        return
    end
    
    self.m_is_firing = true 
    local function tip_callBack()
        if self.m_item_model then
            self.m_item_model:setVisible(false)
        end
    end

    local function end_callBack()

        self.m_event_layer:removeCustomEventById(self.m_eid)
        self.m_is_end = true
        self.m_is_firing = false

        local missionDataHandler = getGameData():getMissionData()
        local mission_type = "explore_wreck"
        local win_status = 1
        missionDataHandler:askMissionSeaBoat(mission_type, win_status)
    end
    
    local ClsExploreSalvageSkill = require("gameobj/explore/exploreSalvageSkill")
    local target = {spItem = self.m_item_model}
    local params = {
        ship_id = self.m_player_ship.id,
        anim_call = "scripts/gameobj/gameplayFunc.lua#animationClipPlayEnd", 
        targetNode = target.spItem.node,
        targetData = target,
        ship = self.m_player_ship,
        num = 1,
        modelFile = "ex_salvage",
        animationFile = "ex_salvage",
        targetCallBack = end_callBack,
        tipCallBack = tip_callBack,
    }

    self.m_salvage_animation = ClsExploreSalvageSkill.new(params)
    self.m_ships_layer:setStopShipReason(self.m_stop_reason)
    --audioExt.playEffect(music_info[self.m_active_skill_item.fire_sound].res)
end

function ClsExploreSeaBoatEvent:release()
    if self.m_ships_layer then
        self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)   
    end

	if self.m_item_model then
		self.m_item_model:release()
		self.m_item_model = nil
	end
end

return ClsExploreSeaBoatEvent