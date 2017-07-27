--2016/07/13
--create by wmh0497
--任务添加的npc
local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsParticleProp = require ("gameobj/explore/exploreParticle")
local ClsAlert = require("ui/tools/alert")

local ClsExploreCustomXuanwoNpc = class("ClsExploreCustomXuanwoNpc", ClsExploreNpcBase)

function ClsExploreCustomXuanwoNpc:initNpc(data)
    self.m_npc_data = data
    self.m_attr = data.attr
    self.m_create_tpos = {x = self.m_attr.sea_pos[1], y = self.m_attr.sea_pos[2]}
    local pos = self.m_explore_layer:getLand():cocosToTile2(self.m_create_tpos)
    self.m_create_pos = {x = pos.x, y = pos.y}
    self.m_item_model = nil
    self.m_is_send_msg = false
end

local CREATE_DIS2 = 1000*1000
local REMOVE_DIS2 = 1200*1200
local TOUCH_DIS2 = 180*180
function ClsExploreCustomXuanwoNpc:update(dt)
    if self.m_is_send_msg then
        return
    end
    local px, py = self:getPlayerShipPos()
    local dis2 = self:getDistance2(self.m_create_pos.x, self.m_create_pos.y, px, py)
    if self.m_item_model then
        if dis2 > REMOVE_DIS2 then
            self:removeXuanwo()
        end
    elseif dis2 < CREATE_DIS2 then
        self:createXuanwo()
    end
    if dis2 < TOUCH_DIS2 then
        self.m_is_send_msg = true
        local mission_data_handler = getGameData():getMissionData()
        mission_data_handler:completetoEndWorld()
    end
end

function ClsExploreCustomXuanwoNpc:createXuanwo()
    if self.m_item_model then
        return
    end
    self.m_item_model = ClsParticleProp.new({res = "tx_xuanwo"})
    self.m_item_model:setPos(self.m_create_pos.x, self.m_create_pos.y)
end

function ClsExploreCustomXuanwoNpc:removeXuanwo()
    if self.m_item_model then
        self.m_item_model:release()
    end
    self.m_item_model = nil
end

function ClsExploreCustomXuanwoNpc:release()
    self:removeXuanwo()
end

return ClsExploreCustomXuanwoNpc