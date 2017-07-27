--2017/02/28
--create by wmh0497
--用于创建装饰用事件

local explore_event = require("game_config/explore/explore_event")
local ClsDecorateEventCreateHander = class("clsDecorateEventCreateHander")

--页面创建时调用
function ClsDecorateEventCreateHander:ctor(event_layer, explore_layer)
	self.m_event_layer = event_layer
	self.m_explore_layer = explore_layer
	
	self.m_type = nil
	self.m_create_event_id = -1000
	self.m_decorate_info = {
		is_init = false,
	}
	self.m_random_create_info = {
		interval_time = 3,
		cur_time = 0,
	}
	
	self:initChangeMissionFlag()
end

function ClsDecorateEventCreateHander:initChangeMissionFlag()
	self.m_change_update_mission_id = "150"
	self.m_type = "random_create"
	local mission_data = getGameData():getMissionData()
	local cur_mission_id = mission_data:getMainLineMission()
	if cur_mission_id and mission_data:comparemMissionIdSize(cur_mission_id, self.m_change_update_mission_id) < 0 then
		self.m_type = "config_create"
	end
end

local change_dic = {
	[SCENE_OBJECT_TYPE_SEA_ROCK] = "explore_sea_rock",
	[SCENE_OBJECT_TYPE_SEA_DOWN_FISH] = "explore_down_fish",
	[SCENE_OBJECT_TYPE_SEA_SHARK] = "explore_sea_shark",
	[SCENE_OBJECT_TYPE_WERCK] = "explore_sea_werck",
	[SCENE_OBJECT_TYPE_CLOUD] = "explore_cloud",
	[SCENE_OBJECT_TYPE_WHALE] = "explore_whale",
	[SCENE_OBJECT_TYPE_SEAGULL] = "explore_seagull",
}
function ClsDecorateEventCreateHander:initDecorateConfig()
	if self.m_decorate_info.is_init then return end
	self.m_decorate_info.is_init = true
	local decorate_cfg = {}
	local explore_new_player = require("game_config/explore/explore_new_player")
	for k, cfg_item in pairs(explore_new_player) do
		local x = cfg_item.pos[1]
		local y = cfg_item.pos[2]
		if not decorate_cfg[x] then
			decorate_cfg[x] = {}
		end
		decorate_cfg[x][y] = {type = change_dic[cfg_item.eventId], event_id = 0, is_create = false}
	end
	self.m_decorate_info.decorate_cfg = decorate_cfg
end


local RANDOM_EVENTS = {
    "explore_sea_rock",
    "explore_down_fish", 
    "explore_sea_shark",
    "explore_sea_werck",
    "explore_cloud",
    "explore_whale",
    "explore_seagull",
}

local TITLE_X_OFFSET = 8
local TITLE_Y_OFFSET = 6
local math_abs = math.abs
function ClsDecorateEventCreateHander:updateBolck(tx, ty)
	if self.m_type ~= "config_create" then return end
	self:initDecorateConfig()
	local decorate_cfg = self.m_decorate_info.decorate_cfg
	for k_tx, config_tx in pairs(decorate_cfg) do
		for k_ty, config_item in pairs(config_tx) do
			if (math_abs(k_tx - tx) <= TITLE_X_OFFSET) and (math_abs(k_ty - ty) <= TITLE_Y_OFFSET) then
				if not config_item.is_create then
					if config_item.event_id ~= 0 then
						if not self.m_event_layer:getIsCustomEventLive(config_item.event_id) then
							config_item.event_id = 0
						end
					end
					if 0 == config_item.event_id then
						config_item.is_create = true
						self.m_create_event_id = self.m_create_event_id - 5
						config_item.event_id = self.m_create_event_id
						local pos_x, pos_y = self.m_explore_layer:getShipsLayer():tileToCocos(k_tx, k_ty)
						self.m_event_layer:createCustomEventByName(config_item.type, self.m_create_event_id, {createPos = {x = pos_x, y = pos_y}})
					end
				end
			else
				if config_item.is_create then
					config_item.is_create = false
				end
			end
		end
	end
end

function ClsDecorateEventCreateHander:randomCreateUpdate(dt)
	if self.m_type ~= "random_create" then return end
	if not getGameData():getExploreData():getRandomEvent() then return end
	
	self.m_random_create_info.cur_time = self.m_random_create_info.cur_time + dt
	if self.m_random_create_info.cur_time >= self.m_random_create_info.interval_time then
		self.m_random_create_info.cur_time = 0
		if self.m_event_layer:isCanCreateEvent() then
			self.m_create_event_id = self.m_create_event_id - 5
			local event_str = RANDOM_EVENTS[math.random(#RANDOM_EVENTS)]
			self.m_event_layer:createCustomEventByName(event_str, self.m_create_event_id)
		end
	end
end

return ClsDecorateEventCreateHander
