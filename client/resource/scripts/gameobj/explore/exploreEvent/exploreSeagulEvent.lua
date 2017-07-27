--2016/06/20
--create by wmh0497
--海鸥

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local ClsSceneUtil = require("gameobj/explore/sceneUtil")
local ClsSkillCalc = require("module/battleAttrs/skill_calc")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")

local RANDOM_COUNT = {[1] = 3, [2] = 4, [3] = 5, [4] = 6}
local RANDOM_POS = {[1] = ccp(0, 0), [2] = ccp(50, -50), [3] = ccp(-100, -60), [4] = ccp(-50, -100), [5] = ccp(70, -150), [6] = ccp(-70, -200)}

local ClsExploreSeagulEvent = class("ClsExploreSeagulEvent", ClsExploreEventBase)

function ClsExploreSeagulEvent:initEvent(event_date)
    self.m_event_data = event_date
    local event_config_item = explore_event[self.m_event_data.evType]
    self.m_event_config_item = event_config_item
    self.m_event_type = event_config_item.event_type
    self.m_sound_radius = event_config_item.sound__radius
    
    self.m_start_x = 0
    self.m_start_y = 0
    self.m_direction = nil
    self.m_is_play_sound = true
    self.m_delay_call = nil
    
    local index = Math.random(#RANDOM_COUNT)
    local count = RANDOM_COUNT[index]
    local angle = self:initRandomPos()
    self.m_item_models = {}
    for i = 1, count do
        local model = propEntity.new(self:getParams())

        local pos_x = self.m_start_x + RANDOM_POS[i].x
        local pos_y = self.m_start_y + RANDOM_POS[i].y

        --local vec3 = Vector3.new(pos_x, 120 + i * 5, pos_y)
        --model.node:setTranslation(vec3)
        model.node:setTranslation(pos_x, 120 + i * 5, pos_y)
        model.node:setScale(0.5)
        model.node:rotateY(-Math.rad(angle))
        self.m_item_models[i] = model
    end
end

function ClsExploreSeagulEvent:getParams()
    local param = {}
    param.res = self.m_event_config_item.res
    param.animation_res = self.m_event_config_item.animation_res
    param.water_res = self.m_event_config_item.water_res
    param.sea_level = self.m_event_config_item.sea_level
    param.type = self.m_event_type
    param.item_id = self.m_eid
    param.hit_radius = self.m_event_config_item.hit_radius
    return param
end

function ClsExploreSeagulEvent:checkDelayCall(dt)
    --延时回调
    if self.m_delay_call then
        self.m_delay_call.time = self.m_delay_call.time - dt
        if self.m_delay_call.time < 0 then
            if self.m_delay_call.callback then
                self.m_delay_call.callback()
            end
            self.m_delay_call = nil
        end
    end
end

--Math.distance(x, y, px, py)
function ClsExploreSeagulEvent:update(dt)
    if self.m_is_end then
        return
    end
    
    self:checkDelayCall(dt)
    
    local ship_vec3 = self.m_player_ship.node:getTranslationWorld()
    for key, model in pairs(self.m_item_models) do
        local model_vec3 = model.node:getTranslationWorld()
        if self.m_is_play_sound then
            if GetVectorDistance(ship_vec3, model_vec3) < self.m_sound_radius then
                self.m_delay_call = {time = 0.2, callback = function()
                        audioExt.playEffect(music_info[self.m_event_config_item.sound_id[1]].res)
                    end}
                self.m_is_play_sound = false
            end
        end
        if GetVectorDistance(ship_vec3, model_vec3) > 1600 then
            self:release()
            self:sendRemoveEvent(self.m_success_flag)
            self.m_is_end = true
            return
        end 
        local target_forward = Vector3.new()
        target_forward:set(self.m_direction:x(), self.m_direction:y(), self.m_direction:z())
        target_forward:scale(100 * dt)
        model.node:translate(target_forward)
    end
end

function ClsExploreSeagulEvent:initRandomPos()
    local angle = Math.random(360)
    local angleTa = 0
    local x = 0
    local z = 0
    local w = 520
    local h = 820
    local angleSource = w / h
    if angle < 90 and angle > 0 then
        angleTa = angle
        local tan = Math.tan(Math.rad(angleTa))
        if tan < angleSource then
            x = h * tan
            z = -h
        else
            x = w
            z = -w / tan
        end
    elseif angle < 180 and angle > 90 then
        angleTa = angle - 90
        local tan = Math.tan(Math.rad(angleTa))
        local angleSource = h / w
        if tan < angleSource then
            x = w
            z = w * tan
        else
            x = h / tan
            z = h
        end

    elseif  angle < 270 and angle > 180 then
        angleTa = angle - 180
        local tan = Math.tan(Math.rad(angleTa))
        if tan < angleSource then
            x = -h * tan
            z = h
        else
            x = -w
            z = w / tan
        end
    elseif  angle < 360 and angle > 270 then
        angleTa = angle - 270
        local tan = Math.tan(Math.rad(angleTa))
        local angleSource = h / w
        if tan < angleSource then
            x = -w
            z = -w * tan
        else
            x = -h / tan
            z = -h
        end
    end
    if angle == 0 or angle == 360 then
        x = 0
        z = -h
    elseif angle == 90 then
        x = w
        z = 0
    elseif  angle == 180 then
        x = 0
        z = h
    elseif  angle == 270 then
        x = -w
        z = 0
    end
    local ship_pos = self.m_player_ship.node:getTranslationWorld()
    self.m_start_x = ship_pos:x() + x
    self.m_start_y = ship_pos:z() + z

    local x = -1 * Math.sin(Math.rad(angle))
    local z = Math.cos(Math.rad(angle))
    local direction = Vector3.new(x, 0, z)
    self.m_direction = direction
    return angle
end

function ClsExploreSeagulEvent:release()
    if self.m_item_models then
        for k, v in pairs(self.m_item_models) do
            v:release()
        end
        self.m_item_models = nil
    end
end

return ClsExploreSeagulEvent