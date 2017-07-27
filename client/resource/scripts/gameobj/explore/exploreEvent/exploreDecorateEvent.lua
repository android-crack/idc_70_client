--2016/06/16
--create by wmh0497
--海上装饰用的事件 海底珊瑚 海底鲨鱼 海底沉船 宝物

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")

local ClsExploreDecorateEvent = class("ClsExploreDecorateEvent", ClsExploreEventBase)

function ClsExploreDecorateEvent:initEvent(event_date)
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
    param.sea_down = event_config_item.sea_down
    param.hit_radius = event_config_item.hit_radius
    param.auto_speed = Math.abs(event_config_item.auto_speed)

    self.m_item_model = propEntity.new(param)
    self.m_item_model.node:setTag("explore_event_id", tostring(self.m_eid))
    
    self.m_time_count = 0
    
    local show_radius_n = event_config_item.show_radius
    if show_radius_n > 0 then
        self.m_create_distance = event_config_item.show_radius
    end
    
	local item_x, item_y = nil,nil
	if self.m_event_data.createPos then
		item_x = self.m_event_data.createPos.x
		item_y = self.m_event_data.createPos.y
	else
		item_x, item_y = self:getCreateItemPos(true)
	end
	
    if item_x then
        self.m_item_model:setPos(item_x, item_y)
        if self.m_event_type == "sea_shark" then
            local angle = Math.random(360)
            local vec3_x = Math.cos(Math.rad(angle))
            local vec3_z = Math.sin(Math.rad(angle))
            self.m_start_dir_vec3 = Vector3.new(vec3_x, 0, vec3_z) --刚开始的方向
            self.m_item_model:setSpeedRate(1)
            LookForward(self.m_item_model.node, self.m_start_dir_vec3)
        end
    else --没有的话，直接清除
        self:sendRemoveEvent(self.m_bad_pos_remove_flag)
        self.m_is_end = true
        return
    end
end

--Math.distance(x, y, px, py)
function ClsExploreDecorateEvent:update(dt)
	if self.m_is_end then
		return
	end

	local x, y = self.m_item_model:getPos()
	local px, py = self.m_player_ship:getPos()
	local dis2 = self:getDistance2(x, y, px, py)
	if dis2 > self.m_max_distance2 then
		self:sendRemoveEvent(self.m_far_remove_flag)
		self.m_is_end = true
	end
	if self.m_start_dir_vec3 then
		self.m_time_count = self.m_time_count + dt
		if self.m_time_count > 1 then
			self.m_time_count = 0
			local state_n = self.m_explore_layer:getMapState(x, y, true)
			if state_n == MAP_LAND or state_n == MAP_EDGE then
				self.m_is_end = true
				self:sendRemoveEvent(self.m_bad_pos_remove_flag)
				return
			end
		end
		if self.m_item_model then
			self.m_item_model:update(dt)
		end
	end
end

function ClsExploreDecorateEvent:release()
    if self.m_item_model then
        self.m_item_model:release()
        self.m_item_model = nil
    end
end

return ClsExploreDecorateEvent