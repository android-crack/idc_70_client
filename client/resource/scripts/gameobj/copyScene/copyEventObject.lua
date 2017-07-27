--事件对象
local copySceneConfig = require("gameobj/copyScene/copySceneConfig") 
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local cfg_music_info = require("game_config/music_info")

local ClsCopySceneEventObject = class("ClsCopySceneEventObject")

function ClsCopySceneEventObject:ctor(sid, ...)
    self.sid = sid
    self.skill_id = 0
    self.m_is_need_salvage = false
    self.m_salvage_state = false
    self.m_attr = {}
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_copy_scene_layer = ClsSceneManage:getSceneLayer()
    self.m_ships_layer = self.m_copy_scene_layer:getShipsLayer()
    self.m_effect_layer = getUIManager():get("clsCopySceneEffectLayer")
    self.m_event_layer = self.m_copy_scene_layer:getEventLayer()
    self:initEvent(...)
    self:initUI()
    self.m_is_delete = nil
end

function ClsCopySceneEventObject:getEventId()
    return self.event_id
end

function ClsCopySceneEventObject:getEventType()
    return self.event_type or ""
end

function ClsCopySceneEventObject:getSkillId()
    return self.skill_id
end

-- 初始化event
function ClsCopySceneEventObject:initEvent(...)

end

function ClsCopySceneEventObject:initUI()
    --有些事件上要显示，图标，比如：鲨鱼，要在模型上面显示血量进度条

end

--延时调用函数
function ClsCopySceneEventObject:removeTimer()
    self.m_timer = nil
end

function ClsCopySceneEventObject:setVisible(is_visible)
    if self.item_model.node then
        self.item_model.node:setActive(is_visible)
    end
    if self.item_model.ui then
        self.item_model.ui:setVisible(is_visible)
    end
end

function ClsCopySceneEventObject:addTimer(delay_time_n, callback, is_loop)
    is_loop = is_loop or false
    self.m_timer = {time = delay_time_n, cur_time = 0, callback = callback, is_loop = is_loop}
end

function ClsCopySceneEventObject:updateTimerHander(dt)
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

function ClsCopySceneEventObject:createHpProgress()
    local posY = -30
    local valuePercent = 0
    local hpProgressBg = display.newSprite("#common_bar_bg1.png")
    local hpProgress =  CCProgressTimer:create(display.newSprite("#common_bar1.png"))
    hpProgress:setType(kCCProgressTimerTypeBar)
    hpProgress:setMidpoint(ccp(0,1))
    hpProgress:setBarChangeRate(ccp(1, 0))
    hpProgress:setPercentage(100)
    hpProgressBg:addChild(hpProgress)

    self.hpProgress = hpProgress

    hpProgressBg:setPositionY(posY)
    
    self.hpProgress:setPercentage(valuePercent)

    --透明的血条
    local progresBar = CCProgressTimer:create(display.newSprite("#common_bar1.png"))
    progresBar:setType(kCCProgressTimerTypeBar)
    progresBar:setMidpoint(ccp(0,1))
    progresBar:setBarChangeRate(ccp(1, 0))
    progresBar:setPercentage(100)
    progresBar:setVisible(false)
    self.transparentProgressBar = progresBar
    hpProgressBg:addChild(progresBar)
    self.transparentProgressBar:setZOrder(1)
    self.hpProgress:setZOrder(2)
    local size = hpProgressBg:getContentSize()
    progresBar:setPosition(ccp(size.width / 2, size.height / 2))
    hpProgress:setPosition(ccp(size.width / 2, size.height / 2))
    hpProgressBg:setScaleX(0.47)
    hpProgressBg:setScaleY(0.56)
    return hpProgressBg
end


function ClsCopySceneEventObject:__endEvent()
    self.m_is_delete = true
end

function ClsCopySceneEventObject:touch(node)
    if not node then return end
end

function ClsCopySceneEventObject:releaseTouch()
    --释放触摸
end


function ClsCopySceneEventObject:update(dt)
    --子类继承，更新，不同的事件update不同，比如：宝箱要在300范围内：播放特效
end

function ClsCopySceneEventObject:release()
    ----子类继承    删除
end

function ClsCopySceneEventObject:showEventEffect()
    --显示特效
end

function ClsCopySceneEventObject:hit() --船撞到了
    --撞到了执行的逻辑

end

function ClsCopySceneEventObject:getDistance2(x1, y1, x2, y2)
    return (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)
end

function ClsCopySceneEventObject:updataInteractiveResult(interactive_type, result)
end

function ClsCopySceneEventObject:updataAttr(key, value)
    --更新事件属性
end

function ClsCopySceneEventObject:getAttr(key)
    return self.m_attr[key]
end

function ClsCopySceneEventObject:btnClickCallBack()
    if self.item_model then
        self:touch(self.item_model.node)
    end
end

function ClsCopySceneEventObject:showSkillTips()
    ClsSceneManage:showDialogBox({tip_id = self.tips_id})
end

function ClsCopySceneEventObject:setTimeLableColor(remain_time)
     --30-10为绿色字，9-1为红色字。
        --COLOR_GREEN, COLOR_RED
    if remain_time >= 10 then
        self.time_label:setColor(ccc3(dexToColor3B(COLOR_GREEN)))
    else
        self.time_label:setColor(ccc3(dexToColor3B(COLOR_RED)))
    end
end

function ClsCopySceneEventObject:setSalvage(status)
    self.m_salvage_state = status
    if self.m_salvage_state and self.m_salvage_tip_spr then
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("explore_light_red.png")
        self.m_salvage_tip_spr:setDisplayFrame(frame)
    end
end

function ClsCopySceneEventObject:createSkillIcon()
    --技能图标--------------------
    local skill_cfg = require("game_config/skill/skill_info")
    local skill_config = skill_cfg[self.skill_id]
    local skill_res = skill_config.res
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()
    local btn = scene_layer:createButton({image = "#explore_skill.png", isAudio = false, unSelectScale = 0.7, selectScale = 0.6})
    local skillSprite = display.newSprite(skill_res)
    local posY = 60
    local size = btn:getNormalImageSpr():getContentSize()

    skillSprite:setPosition(ccp(size.width / 2, size.height / 2))
    btn:getNormalImageSpr():addChild(skillSprite)
    btn:setPositionY(posY)
    btn:setScale(0.7)
    local isAction = self.btn_action
    if isAction then
        local fadeIn = CCFadeTo:create(0.5, 255 * 0.5)
        local fadeOut = CCFadeTo:create(0.5, 255)
        local actions = CCArray:create()
        actions:addObject(fadeIn)
        actions:addObject(fadeOut)
        local action = CCSequence:create(actions)
        btn:getNormalImageSpr():setCascadeOpacityEnabled(true)
        btn:getNormalImageSpr():runAction(CCRepeatForever:create(action))
    end
    local function btnCallBack()
        self:btnClickCallBack()
    end
    btn:regCallBack(btnCallBack)
    self.item_model.ui:addChild(btn)
    --
    local time_label = createBMFont({text = "0", x = 0, y = posY + 45, size = 14, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
    self.item_model.ui:addChild(time_label, 2)
    self.time_label = time_label
    self.time_label:setVisible(false)

    if self.m_is_need_salvage then
        self.m_salvage_tip_spr = display.newSprite("#explore_light_green.png")
        self.m_salvage_tip_spr:setPosition(ccp(0, 85))
        self.item_model.ui:addChild(self.m_salvage_tip_spr)
    end 
end

--事件对某事件开火
function ClsCopySceneEventObject:fireForObject(params)
    if self.m_is_delect then return end
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local target_id = params.target
    if not target_id then return end
    local target_event_obj = ClsSceneManage:getEvenObjById(target_id)
    if not target_event_obj then return end

    if ClsSceneManage:doLogic("isNeedLookForward", self.event_type) then
        local translate1 = target_event_obj.item_model.node:getTranslationWorld()
        local translate2 = self.item_model.node:getTranslationWorld()
        local dir = Vector3.new()
        Vector3.subtract(translate1, translate2, dir)
        LookForward(self.item_model.node, dir)
    end

    local function eff_action()
        if type(self.fireCallBack) == "function" then
            self:fireCallBack()
        end
        self.bullet_node = nil
    end

    local down = 30
    if self.item_model.event_type == SCENE_OBJECT_TYPE_BATTERY then
        down = 0
    end
    local ExploreBulletCls = require("gameobj/copyScene/copySceneBullet")
    local bullet_param = {
        targetNode = target_event_obj.item_model.node,
        ship = self.item_model,
        targetCallBack = eff_action,
        down = down --炮弹打中的位置下移down单位
    }

    for key, value in pairs(params) do
        target_event_obj:updataAttr(key, value)
    end

    --限制开火的数量
    if not self.bullet_node then
        self.bullet_node = ExploreBulletCls.new(bullet_param)
    end
end

function ClsCopySceneEventObject:getSkillBtn(touch_view, skill_res)
    local touch_view = touch_view or self.m_copy_scene_layer
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
    return btn
end

function ClsCopySceneEventObject:getQteBtn(wait_reason_str, wait_time_n, end_callback, skill_res, is_hide_qte_btn, qte_name)
    wait_time_n = wait_time_n or 0
    local btn = nil
    btn = self:getSkillBtn(self.m_effect_layer, skill_res)
    btn:setScale(1)
    if wait_reason_str then
        self.m_ships_layer:setStopShipReason(wait_reason_str)
    end

    local release_callback = function()
        if not tolua.isnull(self.m_ships_layer) and wait_reason_str then
            self.m_ships_layer:releaseStopShipReason(wait_reason_str)
        end
    end
    btn:setRemoveCallback(function() release_callback() end)
    btn:getNormalImageSpr():setCascadeOpacityEnabled(true)
    btn:regCallBack(function()
        if not is_hide_qte_btn then
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
        else
            if type(end_callback) == "function" then
                end_callback()
            end
        end
        release_callback()
        self:btnClickCallBack()
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

    if type(qte_name) == "string" then
        local name_label = createBMFont({text = qte_name, size = 16, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), 
             fontFile = FONT_CFG_1, x = size.width/2 + 2, y = size.height/2 - 30})
        btn:getNormalImageSpr():addChild(name_label, 10)
    end
    
    if wait_reason_str then
        local delay_act = require("ui/tools/UiCommon"):getDelayAction(wait_time_n, function() release_callback() end)
        btn:runAction(delay_act)
    end
    return btn
end

function ClsCopySceneEventObject:createLeadActionAndTip(str_tip)
    local composite_effect = require("gameobj/composite_effect")
    composite_effect.new("tx_0136", 5, 110, self.item_model.ui)

    local label = createBMFont({text = str_tip, size = 16,fontFile = FONT_COMMON, 
    color = ccc3(dexToColor3B(COLOR_GREEN_STROKE)), x = 5, y = 140})
    self.item_model.ui:addChild(label)
end


function ClsCopySceneEventObject:sendCollisionMessage()
    self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.CRASH, {})
end

--得到允许后，打捞
function ClsCopySceneEventObject:sendSalvageMessage()
    self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.END, {})
end

function ClsCopySceneEventObject:sendFollowMessage() --发送跟随的协议
self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.FOLLOW, {})
end

function ClsCopySceneEventObject:sendUNFollowMessage()
    self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.UNFOLLOW, {})
end

function ClsCopySceneEventObject:sendDefenseMessage()
    self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.DEFENSE, {})
end

function ClsCopySceneEventObject:sendKillMyselfMessage()
    self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.KILL_MYSELF, {})
end

function ClsCopySceneEventObject:sendAttackMessage()
    self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.ATTACK, {})
end


--交互协议--接触
function ClsCopySceneEventObject:sendInteractiveMessage()
    self:sendInteractive(copySceneConfig.INTERACTIVE_TYPE.START, {})
end

function ClsCopySceneEventObject:sendInteractive(type_n, params)
    GameUtil.callRpc("rpc_server_object_interactive", {tonumber(self:getEventId()), type_n, params})
end

return ClsCopySceneEventObject
