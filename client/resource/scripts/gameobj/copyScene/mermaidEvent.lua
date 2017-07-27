--美人鱼
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local propEntity = require("gameobj/copyScene/copySceneProp")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")

local ClsCopyMermaidEventObject = class("ClsCopyMermaidEventObject", ClsCopySceneEventObject);

function ClsCopyMermaidEventObject:getEventId()
	return self.event_id
end

function ClsCopyMermaidEventObject:initEvent(prop_data)
    self.event_data = prop_data
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    local name = self.event_data.name
    local config = ClsSceneConfig[prop_data.type]

    self.event_name = config.event_type
    self.animation_res = config.animation_res
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local item = ClsSceneManage.model_objects:getModel(self.event_type)
    item.id = prop_data.id
    item.node:setTag("scene_event_id", tostring(self.event_id))
    item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.item_model = item
    self.hp = self.event_data.hp
    self.max_hp = self.event_data.max_hp
    self.hit_radius = 50--config.hit_radius
    self.action_radius = 150
end

function ClsCopyMermaidEventObject:__endEvent()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    ClsSceneManage.model_objects:removeModel(self.item_model)
end

function ClsCopyMermaidEventObject:update(dt)
    self.item_model:update(dt)
    if self.isHiting then
        return
    end
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()

    local x, y = self.item_model:getPos()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y) 
    if dis < self.hit_radius then
        self:hit()
    elseif dis < self.action_radius then
        if scene_layer:getMapState(x, y, true) == MAP_LAND  then 
            --碰到岸边移除
            print("碰到岸边移除---------------------------")
        else
            self.item_model:stopAnimation(self.animation_res[1]) --停止游动动画
            local translate1 = scene_layer.player_ship.node:getTranslationWorld() --船
            local translate2 = self.item_model.node:getTranslationWorld() --美人鱼
            local dir = Vector3.new()
            Vector3.subtract(translate2, translate1, dir)
            LookForward(self.item_model.node, dir) 
            self.item_model:setSpeedRate(1)
            if self.item_model:animationIsPlaying(self.animation_res[2]) then
                --self.action_radius
            else                    
                if self.item_model.playAction == nil then
                    self.item_model.playAction = true
                    self.item_model:playAnimation(self.animation_res[2], false, true)
                else
                    if self.item_model.firstPosition == nil then
                        self.item_model.firstPosition = true
                        local tmpForward = self.item_model.node:getForwardVectorWorld():normalize()
                        tmpForward:scale(130)
                        self.item_model.node:translate(tmpForward)
                    end
                    self.item_model:playAnimation(self.animation_res[3], true, true)
                end
            end
        end
    else
        if self.item_model:animationIsPlaying(self.animation_res[2]) then

        else
            if (self.item_model.firstPosition == nil) and self.item_model.playAction then
                self.item_model.firstPosition = true
                local tmpForward = self.item_model.node:getForwardVectorWorld():normalize()
                tmpForward:scale(130)
                self.item_model.node:translate(tmpForward)
                self.item_model:playAnimation(self.animation_res[3], true, true)
            end
        end
        self.item_model:setSpeedRate(0)
    end

end

function ClsCopyMermaidEventObject:release()
    self:__endEvent()
end

function ClsCopyMermaidEventObject:updataAttr(keys, values) --更新属性

end

function ClsCopyMermaidEventObject:hit()
    self.isHiting = true
    self:sendCollisionMessage()
end

function ClsCopyMermaidEventObject:touch(node)
    if not node then return end
    return nil
end


return ClsCopyMermaidEventObject
