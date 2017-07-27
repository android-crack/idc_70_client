--2016/06/20
--create by wmh0497
--鲸鱼事件

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local ClsSceneUtil = require("gameobj/explore/sceneUtil")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")
local ClsCommonBase = require("gameobj/commonFuns")

local function createDelayArray(time, callback)
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(time))
    array:addObject(CCCallFunc:create(callback))
    return array
end

local ClsExploreWhaleEvent = class("ClsExploreWhaleEvent", ClsExploreEventBase)

function ClsExploreWhaleEvent:initEvent(event_date)
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

    self.m_item_model = propEntity.new(param)
    self.m_item_model.node:setTag("explore_event_id", tostring(self.m_eid))
    
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
        self.m_item_model:setPos(item_x, item_y)
    else --没有的话，直接清除
        self:sendRemoveEvent(self.m_far_remove_flag)
        self.m_is_end = true
        return
    end
    self:playWhaleEff()
end

function ClsExploreWhaleEvent:playWhaleEff()
    audioExt.playEffect(music_info[self.m_event_config_item.sound_id[1]].res)
    local angle = Math.random(360)
    self.m_item_model:setAngle(angle)
    self.m_item_model:playAnimation(self.m_event_config_item.animation_res[1], false, true)
    local start_vec3 = self.m_item_model.node:getTranslationWorld()
    local function createAction(time, callBack)
        local actions = CCArray:create()
        actions:addObject(CCDelayTime:create(time))
        local funcCallBack = CCCallFunc:create(callBack)
        actions:addObject(funcCallBack)
        return actions
    end
    local clip = self.m_item_model:getAnimationClip(self.m_event_config_item.animation_res[1])
    local duration = clip:getDuration()
    duration = duration / 1000
    self.m_item_model.ui:stopAllActions()
    
    local vec3_scale = 110
    local water_particles = {}
    
    local again_arr = createDelayArray(duration, function()
            local forward = self.m_item_model.node:getForwardVector()
            local target_forward = Vector3.new()
            target_forward:set(forward:x(), forward:y(), forward:z())
            target_forward:scale(vec3_scale)
            self.m_item_model.node:translate(target_forward)
            self.m_item_model:playAnimation(self.m_event_config_item.animation_res[1], false, true)
        end)

    local remove_arr = createDelayArray(duration, function()
            self:sendRemoveEvent(self.m_success_flag)
            self:release()
        end)
    local all_arr = CCArray:create() 
    all_arr:addObjectsFromArray(again_arr)
    all_arr:addObjectsFromArray(remove_arr)
    
    local water_particles = {}
    local remove_res_arr = createDelayArray(1.0, function()
            local len_n = #water_particles
            for i = 1, len_n do
                local item = water_particles[i]
                item:Stop() --删除水花特效
                local water_node = item:GetNode()
                water_node:getParent():removeChild(water_node)
                item = nil
                water_particles[i] = nil
            end
        end)
    all_arr:addObjectsFromArray(remove_res_arr)

    local all_act = CCSequence:create(all_arr)
    
    local water_array1 = createDelayArray(0.02, function()
            local particle = self:createWaterEffect(10, start_vec3)
            water_particles[#water_particles + 1] = particle
        end)
    local water_array2 = createDelayArray(1.2, function()
            local particle = self:createWaterEffect(100, start_vec3)
            water_particles[#water_particles + 1] = particle
        end)

    local water_array3 = createDelayArray(1.2 + duration, function()
            local particle = self:createWaterEffect(vec3_scale + 100, start_vec3)
                water_particles[#water_particles + 1] = particle
        end)

    local water_array = CCArray:create() 
    water_array:addObjectsFromArray(water_array1)
    water_array:addObjectsFromArray(water_array2)
    
    local spawn_array = CCArray:create() 
    spawn_array:addObject(CCSequence:create(water_array3))
    spawn_array:addObject(CCSpawn:createWithTwoActions(CCSequence:create(water_array), all_act))
    self.m_item_model.ui:runAction(CCSpawn:create(spawn_array))
end

function ClsExploreWhaleEvent:createWaterEffect(width, start_vec3)
    local vec3 = Vector3.new(start_vec3:x(), 0, start_vec3:z())
	local parent = Explore3D:getLayerSea3d()
    local water_node, particle = ClsCommonBase:addNodeEffect(parent, "tx_shuihua", vec3)
    local forward = self.m_item_model.node:getForwardVector()
    local target_forward = Vector3.new()
    target_forward:set(forward:x(), forward:y(), forward:z())
    target_forward:scale(width)
    water_node:translate(target_forward)
    particle:Start()
    return particle
end

function ClsExploreWhaleEvent:release()
    if self.m_item_model then
        self.m_item_model:release()
        self.m_item_model = nil
    end
end

return ClsExploreWhaleEvent