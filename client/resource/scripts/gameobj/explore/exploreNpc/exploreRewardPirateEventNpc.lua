--
-- Author: lzg0946
-- Date: 2016-07-20 20:36:24
-- Function: 悬赏海盗pveNpc

local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsParticleProp = require ("gameobj/explore/exploreParticle")
local propEntity = require("gameobj/explore/exploreProp")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")

local ClsExploreRewardPirateEventNpc = class("ClsExploreRewardPirateEventNpc", ClsExploreNpcBase)

function ClsExploreRewardPirateEventNpc:initNpc(data)
    self.m_pirate = nil
    self.m_cfg_item = data.attr
    self.m_cfg_battle_id = 1300001
    self.m_create_tpos = {x = self.m_cfg_item.position_x, y = self.m_cfg_item.position_y}
    local pos = self.m_explore_layer:getLand():cocosToTile2(self.m_create_tpos)
    self.m_create_pos = {x = pos.x, y = pos.y}
    self.m_stop_reason = string.format("ExploreRewardPirateEventNpc_id_%d", self.m_cfg_battle_id)
    self.m_is_send_msg = false
end

local CREATE_DIS2 = 1400*1400
local REMOVE_DIS2 = 1600*1600
local HIT_DIS2 = 100*100
function ClsExploreRewardPirateEventNpc:update(dt)
    local px, py = self:getPlayerShipPos()
    local dis2 = self:getDistance2(self.m_create_pos.x, self.m_create_pos.y, px, py)
    if self.m_pirate then
        if dis2 > REMOVE_DIS2 then
            self:removePirate()
        elseif dis2 <= HIT_DIS2 then
            if not self.m_is_send_msg then
                self.m_is_send_msg = true
                self:touch()
            end
        else
            self.m_is_send_msg = false
        end
    elseif dis2 < CREATE_DIS2 then
        self:createPirate()
    end
end

function ClsExploreRewardPirateEventNpc:touch()
    if getGameData():getTeamData():isLock() then
        return false
    end

    local explore_layer = getExploreLayer()
    local ships_layer = explore_layer:getShipsLayer()
    if not tolua.isnull(ships_layer) then
        ships_layer:setStopShipReason(self.m_stop_reason)
        getGameData():getExploreRewardPirateEventData():askFightPirate(self.m_cfg_battle_id)
    end
    return true
end

function ClsExploreRewardPirateEventNpc:createPirate()
    if self.m_pirate then
        return
    end
    
    local params = {}
    params.res = "bt_base_001"
    params.animation_res = {"move"}
    params.water_res = {"meshwave00"}
    params.sea_level = 0
    params.hit_radius = 1
    
    self.m_pirate = propEntity.new(params)
    self.m_pirate:setPos(self.m_create_pos.x, self.m_create_pos.y)
    local id_str = tostring(self.m_id)
    self.m_pirate.node:setTag("exploreRewardPirateEventNpc", id_str)
    self.m_pirate.node:setTag("exploreNpcLayer", id_str)
end

function ClsExploreRewardPirateEventNpc:removePirate()
    if self.m_pirate then
        self.m_pirate:release()
    end
    self.m_pirate = nil
end

function ClsExploreRewardPirateEventNpc:release()
    self:removePirate()
end

return ClsExploreRewardPirateEventNpc