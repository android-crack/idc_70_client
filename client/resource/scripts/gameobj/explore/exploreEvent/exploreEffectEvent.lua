--2016/05/23
--create by wmh0497
--其他的特效事件，就是那种界面显示下的东东

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local ClsCommonBase = require("gameobj/commonFuns")
local music_info = require("game_config/music_info")

local ClsExploreEffectEvent = class("ClsExploreEffectEvent", ClsExploreEventBase)

function ClsExploreEffectEvent:initEvent(params)
    self.m_params = params
    self.m_add_pos_x = params.add_pos.x
    self.m_add_pos_y = params.add_pos.y
    self.m_down = params.down
    self.m_res_str = params.res
    self.m_during_time = params.during
    self.m_count_time = 0
	local parent = Explore3D:getLayerShip3d()
    local _, particle = ClsCommonBase:addNodeEffect(parent, self.m_res_str, Vector3.new(0, 0, 0))
    self.m_item_model = particle
    self.m_item_model_node = particle:GetNode()
    self.m_item_model:Start()
    self:update(0)
end


function ClsExploreEffectEvent:update(dt)
    self.m_count_time = self.m_count_time + dt
    if self.m_count_time > self.m_during_time then
        self.m_event_layer:removeCustomEventById(self.m_eid)
        return
    end
    local px, py = self.m_player_ship:getPos()
    local pos = CameraFollow:cocosToGameplayWorld(ccp(px, py))
    --local vec = Vector3.new(pos:x() + self.m_add_pos_x, self.m_down, pos:z() + self.m_add_pos_y)
    --self.m_item_model_node:setTranslation(vec)
    self.m_item_model_node:setTranslation(pos:x() + self.m_add_pos_x, self.m_down, pos:z() + self.m_add_pos_y)
end

function ClsExploreEffectEvent:removeModel()
    if self.m_item_model then
        self.m_item_model:Release()
        self.m_item_model = nil
        self.m_item_model_node = nil
    end
end

function ClsExploreEffectEvent:release()
    self:removeModel()
end

return ClsExploreEffectEvent