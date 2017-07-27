--漩涡事件
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local propEntity = require("gameobj/copyScene/copySceneProp")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
local ClsParticleProp = require ("gameobj/copyScene/copySceneParticle")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

local ClsWuanWoEventObject = class("ClsWuanWoEventObject", ClsCopySceneEventObject);

function ClsWuanWoEventObject:initEvent(prop_data)
    self.event_data = prop_data
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    local name = self.event_data.name
    local config = ClsSceneConfig[prop_data.type]
    
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local particle = ClsSceneManage.model_objects:getModel(self.event_type)
    particle:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.item_model = particle
    self.hit_radius = 80--config.hit_radius
end

function ClsWuanWoEventObject:initUI()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    if not ClsSceneManage:doLogic("isXuanWoName") then
        return 
    end

    self.m_name_ui = display.newSprite("#explore_name1.png")
    local ui_size = self.m_name_ui:getContentSize()
    getSceneShipUI():addChild(self.m_name_ui, 2)
 
    self.m_name_ui:setPosition(ccp(self.event_data.sea_pos.x, self.event_data.sea_pos.y - 10))
    local name_lab = createBMFont({text = ui_word.STR_ENTER_SCENE, size = 24, x = ui_size.width/2, y = ui_size.height/2 + 7})
    self.m_name_ui:addChild(name_lab)
end

function ClsWuanWoEventObject:__endEvent()
    if self.item_model then
        local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
        ClsSceneManage.model_objects:removeModel(self.item_model)
        self.item_model = nil
    end
end

function ClsWuanWoEventObject:update(dt)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()
    local x, y = self.item_model:getPos()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y) 
    if dis < self.hit_radius then
        if self.isHiting then
            return
        end
        self:hit()
    else
        self.isHiting = false
    end
end

function ClsWuanWoEventObject:release()
    self:__endEvent()
end

function ClsWuanWoEventObject:updataAttr(keys, values) --更新属性
    --更新事件属性
end

function ClsWuanWoEventObject:hit()
    self.isHiting = true
    
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    if ClsSceneManage:doLogic("isXuanWoJoinTips") then
        ClsAlert:warning({msg = ui_word.YOU_JOINED_SCENE})
    end
    self:sendSalvageMessage()
end

function ClsWuanWoEventObject:showEventEffect()
   
end

function ClsWuanWoEventObject:touch(node)
    return nil
end


return ClsWuanWoEventObject
