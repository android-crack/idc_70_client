--场景中一些特效

local ClsSceneUtil = class("ClsSceneUtil");

function ClsSceneUtil:sceneFire(curHp, maxHp, model, ui, event_name)

    local fireEffectParticle
    local function addHitEffect(parentNode)
        local effect
        local vec
        if event_name == "ice" then
            effect = "tx_HitIce"
            vec = Vector3.new(0, 10, 0)
        else
            effect = "tx_HitRock"
            vec = Vector3.new(0, 60, 0)
        end
        local commonBase = require("gameobj/commonFuns")
         _, fireEffectParticle = commonBase:addNodeEffect(parentNode, effect, vec)
        fireEffectParticle:Start()
    end
    addHitEffect(model.node)
    local borken1_clip = model:getAnimationClip("broken1")
    local borken2_clip = model:getAnimationClip("broken2")
    local borken3_clip = model:getAnimationClip("broken3")
    local borken4_clip = model:getAnimationClip("broken4")
    model:stopAnimation("move")
    local startTime_1 = borken1_clip:getStartTime()
    local endTime_1 = borken1_clip:getEndTime()

    local startTime_2 = borken2_clip:getStartTime()
    local endTime_2 = borken2_clip:getEndTime()

    local startTime_3 = borken3_clip:getStartTime()
    local endTime_3 = borken3_clip:getEndTime()

    local startTime_4 = borken4_clip:getStartTime()
    local endTime_4 = borken4_clip:getEndTime()

    local startTime = 0
    local endTime = 0

    if curHp >= maxHp then
                
    elseif curHp >= 0.75 * maxHp and curHp < maxHp then
        startTime = 0
        endTime = endTime_1
        playClip = borken1_clip
    elseif curHp >= 0.5 * maxHp and curHp < 0.75 * maxHp then
        startTime = startTime_2
        endTime = endTime_2       
        playClip = borken2_clip
    elseif curHp >= 0.25 * maxHp and curHp < 0.5 * maxHp then
        startTime = startTime_3
        endTime = endTime_3
        playClip = borken3_clip
    else        
        startTime = startTime_4
        endTime = endTime_4        
        playClip = borken4_clip
    end
    if playClip then
        playClip:play()
    end

    local function removeFireEffect()
        fireEffectParticle:Stop()
        fireEffectParticle:Release()
        fireEffectParticle = nil
    end

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create((endTime - startTime) / 1000 + 0.1))
    local funcCallBack = CCCallFunc:create(removeFireEffect)
    arr:addObject(funcCallBack)
    local action = CCSequence:create(arr)
    ui:runAction(action)
end


-- 震屏效果
function ClsSceneUtil:sceneShake(offset, beganCallBack, endCallBack, node, check_func)
    if beganCallBack and type(beganCallBack) == "function" then
        beganCallBack()
    end
    offset = offset or 0
    local scheduler = CCDirector:sharedDirector():getScheduler()
    local end_shake_func = function()
        if not self.shake_info then
            return
        end
        if self.shake_info.hander_time then
            scheduler:unscheduleScriptEntry(self.shake_info.hander_time)
            self.shake_info.hander_time = nil
        end
        if self.shake_info.endCallBack and type(self.shake_info.endCallBack) == "function" then
            self.shake_info.endCallBack()
        end
        CameraFollow:LockTarget(self.shake_info.node)
        --检查边界的条件
        if self.shake_info.check_func then
            self.shake_info.check_func()
        end
    end
    
    if self.shake_info then
        end_shake_func()
        self.shake_info = nil
    end
    self.shake_info = {}
    self.shake_info.endCallBack = endCallBack
    self.shake_info.node = node
    self.shake_info.check_func = check_func
    self.count = 0
    local shake_num = 12
    local function step(dt)
        self.count = self.count + 1
        if self.count > shake_num then
            end_shake_func()
            self.shake_info = nil
            return
        end
        local tran = Vector3.new(self.shake_info.node:getTranslationWorld())
        local off = (-1)^self.count * 2 + offset
        tran:set(tran:x() + off, tran:y() + offset, tran:z() + off)
        CameraFollow:SetFreeMove(tran)

    end
    self.shake_info.hander_time = scheduler:scheduleScriptFunc(step, 0.05, false)
end


--渐变效果
function ClsSceneUtil:showFadeEffect(beganCallBack, endCallBack)
    local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
    colorLayer:setOpacity(0)
    local function onTouch(eventType, x, y)
        
    end
    colorLayer:registerScriptTouchHandler(onTouch, false, -500, true)
    if beganCallBack then
        beganCallBack()
    end
    local scene = display.getRunningScene()
    if tolua.isnull(scene) then return end
    scene:addChild(colorLayer, 1001)

    local array = CCArray:create()
    local time = 0.2
    local dx_time = 0.2
    array:addObject(CCFadeIn:create(time))
    array:addObject(CCFadeOut:create(dx_time))

    local arrayTemp = CCArray:create()
    arrayTemp:addObject(CCDelayTime:create(time - 0.1))
    arrayTemp:addObject(CCCallFunc:create(function()
        print("移除---------------------")
        if endCallBack then
            endCallBack()
        end
    end))
    arrayTemp:addObject(CCDelayTime:create(0.1 + dx_time))
    arrayTemp:addObject(CCCallFunc:create(function()
        colorLayer:removeFromParentAndCleanup(true)
    end))
    local actionFade = CCSequence:create(array)
    local createAction = CCSequence:create(arrayTemp)
    local spawn = CCSpawn:createWithTwoActions(actionFade, createAction)
    colorLayer:runAction(spawn)
end

return ClsSceneUtil
