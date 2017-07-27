--鲨鱼和海怪事件
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local propEntity = require("gameobj/copyScene/copySceneProp")
local music_info = require("game_config/music_info")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local ui_word = require("game_config/ui_word")

local ClsCopyFishEventObject = class("ClsCopyFishEventObject", ClsCopySceneEventObject);

function ClsCopyFishEventObject:initEvent(prop_data)
    self.event_data = prop_data
    self.event_create_time = prop_data.create_time
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    self.m_attr = prop_data.attr

    local name = self.event_data.name
    local config = ClsSceneConfig[prop_data.type]

    if (device.platform == "windows") then
        print("config--------鲨鱼和海怪事件血量------------")
        table.print(self.event_data)
    end

    self.radis = 300
    self.config = config
    local item = ClsSceneManage.model_objects:getModel(self.event_type)
    item.id = prop_data.id 
    item.node:setTag("scene_event_id", tostring(self.event_id))
    self.start_pos = ccp(prop_data.x, prop_data.y) --在两个位置之间来回游动
    self.end_pos = ccp(prop_data.x, prop_data.y)
    item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.item_model = item
    self.item_model.land = ClsSceneManage:getSceneMapLayer()
    self.item_model:setSpeedRate(1)
    self.hp = self.m_attr.hp
    self.max_hp = self.m_attr.max_hp
    self.hit_radius = 50--config.hit_radius
    self.skill_id = 1078
    --[[47 有只鲨鱼追着我们不放，快撒网把它抓住！什么？没人知道怎么弄？该死！快撤！
        48 这是什么东西？船上的渔网居然没人会用，还是离这个怪物远一点吧！]]
    if config.event_type == "biteBoat" then
        self.tips_id = 47
        self.biteBoat = true
        self.hit_sound = "EX_SHARK_CRASH"
    elseif config.event_type == "monster" then
        self.tips_id = 48
        self.monster = true
        self.hit_sound = "EX_MONSTER_CRASH"
    end
    --技能图标
    self:createSkillIcon()
    self.end_auto = false
    self.start_auto = true
    self.is_lock_touch = nil
    self.m_stop_reason = string.format("ClsCopyFishEventObject_id_%d", self.event_id)
    self.m_scene_layer = ClsSceneManage:getSceneLayer()
    self.m_ships_layer = self.m_scene_layer:getShipsLayer()
    self.m_player_ship = self.m_scene_layer:getPlayerShip()
end

function ClsCopyFishEventObject:__endEvent()
    if self.item_model then
        self.item_model:stopAutoHandler()
        ClsSceneManage.model_objects:removeModel(self.item_model)
        self.item_model = nil
    end
    self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
    if self.bullet then
        self.bullet:Release()
        self.bullet = nil
    end
end

function ClsCopyFishEventObject:update(dt)
    if self.isHiting then
        self:animationPlay(0)
        return
    end 
    
    local x, y = self.item_model:getPos()
    if self.m_scene_layer:getMapState(x, y, true) == MAP_LAND then 
        --碰到陆地消失
        if not self.m_kill then
            self:sendKillMyselfMessage()
            self.m_kill = true
        end
        
        return
    end
    self.item_model:update(dt)
    
    -- 跟随处理
    local target_uid = self.m_my_uid
    local is_follow_some_one = false
    if self.m_attr.follow_user and self.m_attr.follow_user > 0 then
        is_follow_some_one = true
        target_uid = self.m_attr.follow_user
    end

    if self.m_attr.canrao and self.m_attr.canrao > 0 then
        target_uid = self.m_attr.canrao
        self:animationPlay(0)
        is_follow_some_one = true
    end
    
    local target_ship = self.m_ships_layer:getShipWithMyShip(target_uid)

    if not target_ship then
        return
    end
    
    local px, py = target_ship:getPos()
    local dis = Math.distance(px, py, x, y)
    
    self:animationPlay(dis)

    if dis < self.hit_radius then --和玩家船碰到了
        if target_uid == self.m_my_uid then
            self:hit()
        elseif is_follow_some_one then
            self.isHiting = true
        end
        return
    end
    --进入了鲨鱼和海怪的攻击范围
    if dis < self.radis then --300攻击范围,通知后端
        if not self.is_send then
            if target_uid == self.m_my_uid then
                self.is_send = true
                self:sendFollowMessage()
            end
        end
    else
        self.is_send = false
        self.isHiting = false
    end
    
    if is_follow_some_one then --后端通知鲨鱼在追某个玩家
        self.m_is_check_auto_move = true
        if dis > self.radis then
            --回到刚开始的两个位置坐标
            self.item_model:stopFindPath()
            self.end_auto = false
            self.start_auto = false
            local function back()
                self.end_auto = true
                self.start_auto = false
            end

            if not self.m_send_unfollow then
                if target_uid == self.m_my_uid then
                    self.m_send_unfollow = true
                    self:sendUNFollowMessage()
                end
            end
            self.item_model:goToDesitinaion(self.end_pos, back)
        else
            self.item_model:stopFindPath()
            local translate1 = target_ship.node:getTranslationWorld()
            local translate2 = self.item_model.node:getTranslationWorld()
            local dir = Vector3.new()
            Vector3.subtract(translate1, translate2, dir)
            LookForward(self.item_model.node, dir)
        end
    else
        --------------
        self.m_send_unfollow = false
        if self.m_is_check_auto_move then
            self.item_model:stopFindPath()
            self.end_auto = true
            self.start_auto = false
        end
        self.m_is_check_auto_move = false
        self:reversePath()
    end
end

function ClsCopyFishEventObject:reversePath()
    if self.start_auto then
        self.end_auto = false
        self.start_auto = false
        local function back()
            self.end_auto = true
            self.start_auto = false
        end
        self.item_model:goToDesitinaion(self.end_pos, back)
    elseif self.end_auto then
        self.end_auto = false
        self.start_auto = false
        local function back()
            self.end_auto = false
            self.start_auto = true
        end
        self.item_model:goToDesitinaion(self.start_pos, back)
    end
end

function ClsCopyFishEventObject:release()
    self:__endEvent()
end

function ClsCopyFishEventObject:updataAttr(key, value) --更新属性
    --更新事件属性
    --follow_user
    print("鲨鱼和海怪事件更新前的血量", self.hp)
    self.m_attr[key] = value
    if key == "hp" then
        self.is_lock_touch = nil
        self.hp = value
    end


    --更新ui显现
    print("鲨鱼和海怪事件更新后的血量", self.hp)

    local valuePercent = self.hp / self.max_hp * 100
    self.hpProgress:setPercentage(valuePercent)
end

function ClsCopyFishEventObject:hit()
    
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()
    local ClsSceneUtil = require("gameobj/explore/sceneUtil")
    local function beganCall()
        self.isHiting = true
        self.m_ships_layer:setStopShipReason(self.m_stop_reason)
        --发送协议,碰撞
        ClsSceneManage:showDialogBoxWithCrash(self.event_type)
        self:sendCollisionMessage()
        audioExt.playEffect(music_info[self.hit_sound].res)
    end

    local function endCall()
        if self.biteBoat then
            self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
        end
    end
    local function checkFunc()
        local scene_layer = ClsSceneManage:getSceneLayer()
        if scene_layer and scene_layer.player_ship then
            scene_layer.player_ship:checkBoundOut()
        end
    end
    ClsSceneUtil:sceneShake(0, beganCall, endCall, scene_layer.player_ship.node, checkFunc)
end

function ClsCopyFishEventObject:initUI()
    local hpProgressBg = self:createHpProgress()
    local valuePercent = self.hp / self.max_hp * 100
    self.hpProgress:setPercentage(valuePercent)
    self.item_model.ui:addChild(hpProgressBg)

    ClsSceneManage:doLogic("tryToShowGuildArrow", self, ui_word.STR_COPY_SCENE_FISH_EVENT_TIP)
end

function ClsCopyFishEventObject:showEventEffect()
    self.isFishing = true
    self.is_lock_touch = true
    local function eff_action() -- 撒网完
        self.isFishing = nil
        self.is_lock_touch = true
        audioExt.playEffect(music_info.EX_STICK.res)
        self:sendSalvageMessage()
        self.bullet = nil
    end
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()

    local target = {spItem = self.item_model}
  
    local ExploreNetSkill = require("gameobj/explore/exploreNetSkill")
    local bullet_param = {
        skill_id = self.skill_id,
        targetNode = self.item_model.node,
        targetData = target,
        ship = scene_layer.player_ship,
        num = 1,
        modelFile = "ex_net",
        animationFile = "ex_net",
        targetCallBack = eff_action,
    }
    
    self.bullet = ExploreNetSkill.new(bullet_param)
    audioExt.playEffect(music_info.EX_THROW.res)
end

function ClsCopyFishEventObject:touch(node)
    if not node then return end
    local event_id = node:getTag("scene_event_id")
    if not event_id then
        return
    end
    print("点击鲨鱼海怪 =======================", event_id, self:getEventId())
    event_id = tonumber(event_id)
    if event_id ~= self:getEventId() then
        return nil
    end
    if self.isFishing or self.is_lock_touch then --正在撒网
        return true
    end
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()

    local x, y = self.item_model:getPos()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y) 

    if dis < self.radis then
        self:showEventEffect()
    end
    return true
end

function ClsCopyFishEventObject:animationPlay(distance)
    local function playItemAnimation(dis, skillDistance)
        if dis == 0 then
            if self.playAction == nil then
                self.playAction = true
                self.item_model:stopAnimation(self.config.animation_res[1])
                if not self.item_model:animationIsPlaying(self.config.animation_res[2]) then
                    self.item_model:playAnimation(self.config.animation_res[2], false, true)
                end
            end
        else
            self.playAction = nil
            if not self.item_model:animationIsPlaying(self.config.animation_res[1]) then
                self.item_model:playAnimation(self.config.animation_res[1], true, true)
            end
        end
    end

    if self.biteBoat then --鲨鱼咬船动画
        if distance < self.hit_radius * 2 then
            if self.playAction == nil then
                self.playAction = true
                self.item_model:playAnimation(self.config.animation_res[2], false, true)
            else
                if self.item_model:animationIsPlaying(self.config.animation_res[2]) then
                    --不用播放
                else
                    self.item_model:playAnimation(self.config.animation_res[1], true, true)
                end
            end
        else
            self.playAction = nil
            self.item_model:playAnimation(self.config.animation_res[1], true, true)
        end
    end

    if self.monster then --海怪动画
        playItemAnimation(distance, self.radis)
    end
end

return ClsCopyFishEventObject
