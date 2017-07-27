--2016/06/16
--create by wmh0497
--海上装饰用的石头

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")

local ClsExploreSeaRockEvent = class("ClsExploreSeaRockEvent", ClsExploreEventBase)

function ClsExploreSeaRockEvent:initEvent(event_date)
    self.m_event_data = event_date
    local event_config_item = explore_event[self.m_event_data.evType]
    self.m_event_config_item = event_config_item
    self.m_event_type = event_config_item.event_type
    
    self.m_item_models = {}
    
    local show_radius_n = event_config_item.show_radius
    if show_radius_n > 0 then
        self.m_create_distance = event_config_item.show_radius
    end
    
    local item_x, item_y = nil,nil
	if self.m_event_data.createPos then
		item_x = self.m_event_data.createPos.x
		item_y = self.m_event_data.createPos.y
	else
		item_x, item_y = self:getCreateItemPos()
	end
	
    if item_x then
        local pos = {ccp(0,0), ccp(30, 0), ccp(40, -36), ccp(30, 20), ccp(0, 30), ccp(0, -50), ccp(-60, 20), ccp(-45, -50), ccp(-80, -10)}
        for i = 1, #pos do
            local model = propEntity.new(self:getParams(i ~= 1))
            local down = 0
            if i == 1 then
                down = 20
            end
            model:setPos(item_x + pos[i].x, item_y + pos[i].y, down)
            self.m_item_models[i] = model
        end  
    else --没有的话，直接清除
        self:sendRemoveEvent(self.m_bad_pos_remove_flag)
        self.m_is_end = true
        return
    end
    
end

--is_coral 是否返回海底珊瑚模型（默认返回礁石）
function ClsExploreSeaRockEvent:getParams(is_coral)
    local param = {}
    if not is_coral then
        param.res = self.m_event_config_item.res
        param.animation_res = self.m_event_config_item.animation_res
        param.water_res = self.m_event_config_item.water_res
        param.sea_level = self.m_event_config_item.sea_level
        param.type = self.m_event_type
        param.item_id = self.m_eid
        param.sea_down = self.m_event_config_item.sea_down
        param.hit_radius = self.m_event_config_item.hit_radius
    else
        local event_config = explore_event[SCENE_OBJECT_TYPE_CORAL]
        param.res = event_config.res
        param.animation_res = event_config.animation_res
        param.water_res = event_config.water_res
        param.sea_level = event_config.sea_level
        param.type = SCENE_OBJECT_TYPE_CORAL
        param.item_id = self.m_eid
        param.sea_down = event_config.sea_down
        param.hit_radius = event_config.hit_radius
    end
    return param
end

--Math.distance(x, y, px, py)
function ClsExploreSeaRockEvent:update(dt)
    if self.m_is_end then
        return
    end
    if self.m_item_models[1] then
        local x, y = self.m_item_models[1]:getPos()
        local px, py = self.m_player_ship:getPos()
        local dis2 = self:getDistance2(x, y, px, py)
        if dis2 > self.m_max_distance2 then
            self:sendRemoveEvent(self.m_far_remove_flag)
            self.m_is_end = true
        end
    end
end

function ClsExploreSeaRockEvent:release()
    if self.m_item_models then
        for k, v in pairs(self.m_item_models) do
            v:release()
        end
        self.m_item_models = {}
    end
end

return ClsExploreSeaRockEvent