--
-- Author: lzg0496
-- Date: 2016-12-04 21:45:34
-- Function: 流水事件

local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")

local ClsParticleProp = require("gameobj/copyScene/copySceneParticle")

local ClsCopyWaterEventObject = class("ClsCopyWaterEventObject", ClsCopySceneEventObject);

function ClsCopyWaterEventObject:initEvent(prop_data)
    self.event_data = prop_data
    self.event_create_time = prop_data.create_time
    self.event_id = prop_data.id
    self.event_type = prop_data.type

    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local config = ClsSceneConfig[self.event_type]
    local item = ClsSceneManage.model_objects:getModel(self.event_type)
    item.id = prop_data.id
    item.node:setTag("scene_event_id", tostring(self.event_id))
    item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.item_model = item
    self.action_radius =  80
    self.m_ships_layer = ClsSceneManage:getSceneLayer():getShipsLayer()
    table.print(prop_data)
end

function ClsCopyWaterEventObject:__endEvent()
    ClsCopyWaterEventObject.super.__endEvent(self)
    if self.item_model then
        local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
        print("del model ============================")
        ClsSceneManage.model_objects:removeModel(self.item_model)
        self.item_model = nil
    end
end

function ClsCopyWaterEventObject:update(dt)
    local x, y = self.item_model:getPos()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_layer = ClsSceneManage:getSceneLayer()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y)
    if dis < self.action_radius / 2 then
        self:showEventEffect()
    end
end

function ClsCopyWaterEventObject:release()
    self:__endEvent()
end

function ClsCopyWaterEventObject:updataAttr(key, value)
end

function ClsCopyWaterEventObject:updataInteractiveResult(interactive_type, result)
end

function ClsCopyWaterEventObject:showEventEffect()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_layer = ClsSceneManage:getSceneLayer()
    local ship_layer = scene_layer:getShipsLayer()
    ship_layer:setIsBuffUp(true, os.time() + 30)
    print("add buff ========================")
end

function ClsCopyWaterEventObject:touch(node)
    if not node then return end
    local event_id = node:getTag("scene_event_id")
    if not event_id then
        return
    end
    event_id = tonumber(event_id)
    if event_id ~= self:getEventId() then
        return
    end
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_layer = ClsSceneManage:getSceneLayer()

    local x, y = self.item_model:getPos()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y)
    if dis < self.action_radius / 2 then
        self:showEventEffect()
    else
        local news = require("game_config/news")
        local Alert = require("ui/tools/alert")
        Alert:warning({msg = news.COPY_TREASURE_BOX_EVENT_TIP.msg})
    end
    return true
end


return ClsCopyWaterEventObject
