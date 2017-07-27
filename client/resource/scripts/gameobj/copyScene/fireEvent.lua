--浮冰和礁石事件
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local propEntity = require("gameobj/copyScene/copySceneProp")
local music_info = require("game_config/music_info")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
local ui_word = require("game_config/ui_word")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local ClsElementMgr = require("base/element_mgr")

local ClsCopyFireEventObject = class("ClsCopyFireEventObject", ClsCopySceneEventObject);

function ClsCopyFireEventObject:getEventId()
	return self.event_id
end

function ClsCopyFireEventObject:initEvent(prop_data)
    self.event_data = prop_data
    self.event_create_time = prop_data.create_time
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    
    local name = self.event_data.name
    local config = ClsSceneConfig[prop_data.type]

    if (device.platform == "windows") then
        print("config--------浮冰和礁石事件血量------------")
        table.print(self.event_data)
    end

    self.event_name = config.event_type
    local item = ClsSceneManage.model_objects:getModel(self.event_type)
    item.id = prop_data.id
    item.node:setTag("scene_event_id", tostring(self.event_id))
    item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.item_model = item
    self.radis = 300
    self.hp = self.event_data.attr.hp
    self.max_hp = self.event_data.attr.max_hp
    --[[41 小心前面的暗礁！快闪开！下次我们一定要找个会清除障碍的家伙，来炸掉这块该死的礁石！
    42 这里到处是坚硬的浮冰，在没人会清除障碍之前，我们得小心绕过去。]]
    if config.event_type == "rock" then
        self.tips_id = 41
        self.hit_sound = "EX_ROCK_CRASH"
    elseif config.event_type == "ice" then
        self.tips_id = 42
        self.hit_sound = "EX_ICE_CRASH"
    end
    self.hit_radius = config.hit_radius
    --技能图标
    self.skill_id = 1066
    self.m_attr = self.event_data.attr
    self:createSkillIcon()
    
    self.m_stop_reason = string.format("ClsCopyBoxEventObject_id_%d", self.event_id)
    self.m_ships_layer = ClsSceneManage:getSceneLayer():getShipsLayer()
end

function ClsCopyFireEventObject:__endEvent()
    if self.item_model then
        ClsCopyFireEventObject.super.__endEvent(self)
        ClsSceneManage.model_objects:removeModel(self.item_model)
        self.is_delete = true
        self.item_model = nil
    end
    self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
end

function ClsCopyFireEventObject:startFire()
    local playerShipsData = getGameData():getExplorePlayerShipsData()
    playerShipsData:setAttr(self.m_my_uid, "touch_something", self.event_id)
    local timer_callback = function()
        local event_id = playerShipsData:getAttr(self.m_my_uid, "touch_something") or 0
        if event_id ~= self.event_id then
            self:removeTimer()
            return
        end
        self:showEventEffect()
    end
    self:addTimer(1, timer_callback, true)
    timer_callback()
        
    local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
    if not tolua.isnull(copy_scene_layer) then
        local copy_ship_layer = copy_scene_layer:getShipsLayer()    
        if not tolua.isnull(copy_ship_layer) then
            copy_ship_layer:tryToBreakMove(true)
        end
    end
end

function ClsCopyFireEventObject:update(dt)
    if self.isHiting then
        return
    end
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()
    self:updateTimerHander(dt)
    local x, y = self.item_model:getPos()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y) 
    if dis < self.hit_radius then
        self:hit()
    end

end

function ClsCopyFireEventObject:release()
    if self.is_delete then
        return
    end
    if self.bullet then
        self.bullet:Release()
        self.bullet = nil
    end
    self:__endEvent()
end

function ClsCopyFireEventObject:updataAttr(key, value) --更新属性
    --更新事件属性
    print("礁石浮冰事件更新前的血量", self.hp)
    self.m_attr[key] = value
    if "hp" == key then
        self.is_lock_touch = nil
        self.hp = value
    end
    --更新ui显现
    print("礁石浮冰事件更新后的血量", self.hp)
    local valuePercent = self.hp / self.max_hp * 100
    self.hpProgress:setPercentage(valuePercent)

    local ClsSceneUtil = require("gameobj/explore/sceneUtil")
    ClsSceneUtil:sceneFire(self.hp, self.max_hp, self.item_model, self.item_model.ui, self.event_name)
end

function ClsCopyFireEventObject:hit()
    
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()
    local ClsSceneUtil = require("gameobj/explore/sceneUtil")
    local function beganCall()
        self.isHiting = true
        self.m_ships_layer:setStopShipReason(self.m_stop_reason)
        --发送协议
        ClsSceneManage:showDialogBoxWithCrash(self.event_type)
        self:sendCollisionMessage()
        audioExt.playEffect(music_info[self.hit_sound].res)
    end
    local function endCall()
        self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
    end
    local function checkFunc()
        local scene_layer = ClsSceneManage:getSceneLayer()
        if scene_layer and scene_layer.player_ship then
            scene_layer.player_ship:checkBoundOut()
        end
    end
    ClsSceneUtil:sceneShake(10, beganCall, endCall, scene_layer.player_ship.node, checkFunc)
end

function ClsCopyFireEventObject:initUI()
    local hpProgressBg = self:createHpProgress()
    local valuePercent = self.hp / self.max_hp * 100
    self.hpProgress:setPercentage(valuePercent)
    self.item_model.ui:addChild(hpProgressBg)

    ClsSceneManage:doLogic("tryToShowGuildArrow", self, ui_word.STR_COPY_SCENE_FIRE_EVENT_TIP)
end

function ClsCopyFireEventObject:showEventEffect()
    self.isFiring = true
    self.is_lock_touch = true
   
    local function eff_action()
        self.isFiring = nil
        self.is_lock_touch = true
        if self.event_name == "ice" then
            audioExt.playEffect(music_info.EX_ICE_HIT.res)
        else
            audioExt.playEffect(music_info.EX_ROCK_HIT.res)
        end
        self:sendSalvageMessage()
        self.bullet = nil
    end

    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()

    local down = 30
    local ExploreBulletCls = require("gameobj/copyScene/copySceneBullet")
    local bullet_param = {
        targetNode = self.item_model.node,
        ship = scene_layer.player_ship,
        targetCallBack = eff_action,
        down = down --炮弹打中的位置下移down单位
    }
    
    self.bullet = ExploreBulletCls.new(bullet_param)
end

function ClsCopyFireEventObject:touch(node)
    if not node then return end
    local event_id = node:getTag("scene_event_id")
    if not event_id then
        return
    end
    
     print("点击礁石浮冰 =======================", event_id, self:getEventId())
    event_id = tonumber(event_id)
    if event_id ~= self:getEventId() then
        return nil
    end
    if self.isFiring or self.is_lock_touch then --正在发射火炮
        return true
    end

    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()

    local x, y = self.item_model:getPos()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y) 
    if dis < self.radis then
        self:startFire()
    end
    
    return true
end


return ClsCopyFireEventObject
