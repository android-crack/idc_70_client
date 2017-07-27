--2016/07/13
--create by wmh0497
--所有npc的基类

local ClsExploreNpcBase = class("ClsExploreNpcBase")
local composite_effect = require("gameobj/composite_effect")
local music_info = require("game_config/music_info")

function ClsExploreNpcBase:ctor(npc_layer, id, type_str, ...)
    self.m_npc_layer = npc_layer
    self.m_explore_layer = getExploreLayer()
    self.m_event_layer = self.m_explore_layer:getExploreEventLayer()
    self.m_effect_layer = getUIManager():get("ClsExploreEffectLayer")
    self.m_player_ship = self.m_explore_layer:getPlayerShip()
    self.m_ships_layer = self.m_explore_layer:getShipsLayer()
    self.m_id = id
    self.m_type = type_str
    self.m_timer = nil
    self:initNpc(...)
end

function ClsExploreNpcBase:getId()
    return self.m_id
end

function ClsExploreNpcBase:getType()
    return self.m_type
end

--尽量使用这个接口来获取位置信息，提高效率
function ClsExploreNpcBase:getPlayerShipPos()
    return self.m_npc_layer:getPlayerShipPos()
end

--子类重写
function ClsExploreNpcBase:initNpc(...)
end

function ClsExploreNpcBase:touch()
end

function ClsExploreNpcBase:update(dt)
end

function ClsExploreNpcBase:updateAttr(key, value, old_value)
end

function ClsExploreNpcBase:release()
end

--延时调用函数
function ClsExploreNpcBase:removeTimer()
    self.m_timer = nil
end

function ClsExploreNpcBase:addTimer(delay_time_n, callback, is_loop)
    is_loop = is_loop or false
    self.m_timer = {time = delay_time_n, cur_time = 0, callback = callback, is_loop = is_loop}
end

function ClsExploreNpcBase:updateTimerHander(dt)
    if self.m_timer then
        self.m_timer.cur_time = self.m_timer.cur_time + dt
        if self.m_timer.cur_time >= self.m_timer.time then
            if self.m_timer.callback then
                self.m_timer.callback()
            end
            if self.m_timer then --假如在callback中没有被删掉
                if self.m_timer.is_loop then
                    self.m_timer.cur_time = self.m_timer.cur_time - self.m_timer.time
                else
                    self:removeTimer()
                end
            end
        end
    end
end

--基础函数
function ClsExploreNpcBase:getDistance2(x1, y1, x2, y2)
    return (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)
end

function ClsExploreNpcBase:isInDistance(dis, x1, y1, x2, y2)
    local dis2 = dis*dis
    local now2 = self:getDistance2(x1, y1, x2, y2)
    if dis2 >= now2 then
        return true
    end
    return false
end

function ClsExploreNpcBase:getSkillBtn(touch_view, skill_res)
    local touch_view = touch_view or self.m_explore_layer
    local btn = touch_view:createButton({image = "#explore_skill.png", isAudio = false, unSelectScale = 0.7, selectScale = 0.6})
    local skill_spr = display.newSprite(skill_res)
    local posY = 60
    local size = btn:getNormalImageSpr():getContentSize()

    skill_spr:setPosition(ccp(size.width / 2, size.height / 2))
    btn:getNormalImageSpr():addChild(skill_spr)
    btn:setPositionY(posY)

    btn:regCallBack(function()
            self:touch()
        end)
    getUIManager():get("clsExploreBlankLayer"):regTouchEvent(btn, function(...) 
        return btn:onTouch(...)
    end)
    return btn
end

function ClsExploreNpcBase:getQteBtn(wait_reason_str, wait_time_n, end_callback, is_guild, skill_res)
    wait_time_n = wait_time_n or 0
    local explore_task_cloud = getUIManager():get("exploreTaskCloud")
    local btn = nil
    if (not tolua.isnull(explore_task_cloud)) then
        btn = self:getSkillBtn(explore_task_cloud, skill_res)
    else
        btn = self:getSkillBtn(self.m_effect_layer, skill_res)
    end
    btn:setScale(1)
    if wait_reason_str then
        self.m_ships_layer:setStopShipReason(wait_reason_str)
    end
    if is_guild then
        self.guild_effect = composite_effect.bollow("tx_1042_1", 0, 0, btn)
    end
    local release_callback = function()
            if not tolua.isnull(self.m_ships_layer) and wait_reason_str then
                self.m_ships_layer:releaseStopShipReason(wait_reason_str)
            end
        end
    btn:setRemoveCallback(function() release_callback() end)
    btn:getNormalImageSpr():setCascadeOpacityEnabled(true)
    btn:regCallBack(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            btn:setTouchEnabled(false)
            local actions = CCArray:create()
            actions:addObject(CCFadeTo:create(0.5, 0))
            actions:addObject(CCCallFunc:create(function()
                    btn:setVisible(false)
                    if type(end_callback) == "function" then
                        end_callback()
                    end
                end))
            btn:getNormalImageSpr():runAction(CCSequence:create(actions))
            release_callback()
            if not tolua.isnull(self.guild_effect) then
                self.guild_effect:removeFromParentAndCleanup(true)
            end
            self:touch("qte")
        end)
    
    local size = btn:getNormalImageSpr():getContentSize()
    local eff_spr = display.newSprite()
    eff_spr:setCascadeOpacityEnabled(true)
    eff_spr:setPosition(size.width/2 + 2, size.height/2)
    btn:getNormalImageSpr():addChild(eff_spr, 10)
    
    local effect_arm = CCArmature:create("tx_explore_qte")
    effect_arm:setCascadeOpacityEnabled(true)
    effect_arm:getAnimation():playByIndex(0)
    eff_spr:addChild(effect_arm)
    
    if wait_reason_str then
        local delay_act = require("ui/tools/UiCommon"):getDelayAction(wait_time_n, function() release_callback() end)
        btn:runAction(delay_act)
    end
    return btn
end

return ClsExploreNpcBase