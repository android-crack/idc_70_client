-- 界面过度效果
local missionGuide = require("gameobj/mission/missionGuide")
local MyTransition = {}


function MyTransition:moveAndScale(target, args)
    assert(not tolua.isnull(target), "MyTransition:moveAndScale() - target is not CCNode")

    if args and type(args) == "table" then
        if args.beginPos then
            target:setPosition(args.beginPos)
        end
        if args.beginScale then
            target:setScale(args.beginScale)
        end
        local action1 = CCScaleTo:create(args.time, args.endScale)
        local tx, ty = target:getPosition()
        local pos = args.endPos or ccp(tx,ty)
        local action2 = CCMoveTo:create(args.time, pos)

        local actions = CCSpawn:createWithTwoActions(action1, action2)
        if args.callBack then
            action3 = CCCallFuncN:create(args.callBack)
            actions = CCSequence:createWithTwoActions(actions, action3)
        end

        target:runAction(actions)
    end
end

function MyTransition:moveAndScale2(target, args)
    assert(not tolua.isnull(target), "MyTransition:moveAndScale() - target is not CCNode")

    if args and type(args) == "table" then
        local action1 = CCScaleTo:create(args.time, args.scale)
        local tx, ty = target:getPosition()
        local pos = args.pos or ccp(tx,ty)
        local action2 = CCMoveTo:create(args.time, pos)
        local spawn = CCSpawn:createWithTwoActions(action1, action2)
        local callBack = CCCallFuncN:create(args.callBack)
        target:runAction(CCSequence:createWithTwoActions(spawn, callBack))
    end
end

function MyTransition:bookTransition(target, args)
    assert(not tolua.isnull(target), "MyTransition:moveAndScale() - target is not CCNode")

    if args and type(args) == "table" then
        local scale = args.scale or 1
        local action1 = CCScaleTo:create(args.time, scale)
        local tx, ty = target:getPosition()
        local x = args.x or tx
        local y = args.y or ty
        local action2 = CCMoveTo:create(args.time, ccp(x, y))
        local angle = args.angle or 0
        local action3 = CCRotateBy:create(args.time , args.angle)

        local array = CCArray:create()
        array:addObject(action1)
        array:addObject(action2)
        array:addObject(action3)
        target:runAction(CCSpawn:create(array))
    end
end

function MyTransition:bookTransition2(target, args) --reverse
    assert(not tolua.isnull(target), "MyTransition:moveAndScale() - target is not CCNode")

    if args and type(args) == "table" then
        local scale = args.scale or 1
        local action1 = CCScaleTo:create(args.time, scale)
        local tx, ty = target:getPosition()
        local x = args.x or tx
        local y = args.y or ty
        local action2 = CCMoveTo:create(args.time, ccp(x, y))
        local angle = args.angle or 0
        local action3 = CCRotateBy:create(args.time , args.angle)
        local callBack = CCCallFuncN:create(args.callBack)

        local arr = CCArray:create()
        arr:addObject(CCCallFunc:create(function()

            local array = CCArray:create()
            array:addObject(action1)
            array:addObject(action2)
            array:addObject(action3)
            local spawn = CCSpawn:create(array)
            target:runAction(spawn)
        end))
        arr:addObject(CCDelayTime:create(args.time + 0.1))
        arr:addObject(callBack)
        target:runAction(CCSequence:create(arr))
    end
end

function MyTransition:menuTransition(target, args)
    assert(not tolua.isnull(target), "MyTransition:moveAndScale() - target is not CCNode")

    if args and type(args) == "table" then
        local action1 = CCScaleTo:create(args.time, args.scaleX, 1)
        local x = args.x or 0
        local y = args.y or 0
        local action2 = CCMoveTo:create(args.time, ccp(x, y))
        target:runAction(CCSpawn:createWithTwoActions(action1, action2))
    end
end


function MyTransition:menuTransition2(target, args)
    assert(not tolua.isnull(target), "MyTransition:moveAndScale() - target is not CCNode")

    if args and type(args) == "table" then
        local action1 = CCScaleTo:create(args.time, args.scaleX, 1)
        local x = args.x or 0
        local y = args.y or 0
        local action2 = CCMoveTo:create(args.time, ccp(x, y))
        local spawn = CCSpawn:createWithTwoActions(action1, action2)
        local callBack = CCCallFuncN:create(args.callBack)
        target:runAction(CCSequence:createWithTwoActions(spawn, callBack))
    end
end

function MyTransition:transitView(callBack) -- 战斗视觉切换
    if type(callBack) ~= "function" then return end

    local running_scene = GameUtil.getRunningScene()
    local layerColor = CCLayerColor:create(ccc4(0,0,0,255))
    running_scene:addChild(layerColor, ZORDER_TRANSIT_VIEW)
    local t = 1.5
    local actions = {}
    local Alert  = require("ui/tools/alert")
    local ui_word = require("game_config/ui_word")
    Alert:warning({msg = ui_word.BATTLE_TRANSITVIEW, color = ccc3(0,255,0)})
    layerColor:setOpacity(0)
    actions[1] = CCFadeIn:create(t)
    actions[2] = CCCallFunc:create( function()
        callBack()
    end)
    actions[3] = CCFadeOut:create(t)
    actions[4] = CCCallFunc:create(function()
        layerColor:removeFromParentAndCleanup(true)
    end)
    local action = transition.sequence(actions)
    layerColor:runAction(action)
end

-- 层切换效果
function MyTransition:transitLayer(newLayer, oldLayer, callBack, time)
    if tolua.isnull(newLayer) then return end
    local running_scene = getMainScene()

    local tranLayerColor = CCLayerColor:create(ccc4(0,0,0,255))
	local touch_priority = TOUCH_PRIORITY_BTN - 1
	tranLayerColor:registerScriptTouchHandler(function(event, x, y)
		if event == "began" then return true end 
	end, false, touch_priority, true)
	tranLayerColor:setTouchEnabled(true)
    running_scene:addChild(tranLayerColor, ZORDER_TRANSIT_VIEW)
    local t = time or 0.4
   
    if tolua.isnull(oldLayer) then
        local actions = {}
        actions[1] = CCFadeOut:create(t)
        actions[2] = CCCallFunc:create(function()
            if not tolua.isnull(tranLayerColor) then
                tranLayerColor:removeFromParentAndCleanup(true)
            end
            if not tolua.isnull(newLayer) then
                if type(newLayer.setTouch)=="function" and newLayer.tag ~= TYPE_LAYER_PORT then newLayer:setTouch(true) end
                if type(newLayer.playOpenSound)=="function" then newLayer:playOpenSound() end
            end
            if type(callBack)=="function" then
                callBack()
            end
        end)
        local action = transition.sequence(actions)
        tranLayerColor:runAction(action)

    else
        if type(oldLayer.setTouch)=="function" then oldLayer:setTouch(false) end
        local actions = {}
        tranLayerColor:setOpacity(0)
        newLayer:setVisible(false)
        actions[1] = CCFadeIn:create(t)
        actions[2] = CCCallFunc:create( function()
            if not tolua.isnull(oldLayer) then
                oldLayer:removeFromParentAndCleanup(true)
            end
            if not tolua.isnull(newLayer) then
                newLayer:setVisible(true)
                if type(newLayer.setTouch)=="function" and newLayer.tag ~= TYPE_LAYER_PORT then newLayer:setTouch(true) end
                if type(newLayer.playOpenSound)=="function" then newLayer:playOpenSound() end
            end
            if type(callBack)=="function" then
                callBack()
            end
        end)
        actions[3] = CCFadeOut:create(t)
        actions[4] = CCCallFunc:create(function()
            if not tolua.isnull(tranLayerColor) then
                tranLayerColor:removeFromParentAndCleanup(true)
            end
        end)
        local action = transition.sequence(actions)
        tranLayerColor:runAction(action)
    end
end

-- 2个层之间过渡替换
function MyTransition:replaceLayer(newLayer, oldLayer, callBack, time)
	if tolua.isnull(oldLayer) then return end
	
	if not tolua.isnull(newLayer) then 
		newLayer:setVisible(false)
	end 

	local bgColor = CCLayerColor:create(ccc4(0,0,0,255))
	local touch_priority = TOUCH_PRIORITY_BTN - 1
	bgColor:registerScriptTouchHandler(function(event, x, y)
		if event == "began" then return true end 
	end, false, touch_priority, true)
	bgColor:setTouchEnabled(true)
	oldLayer:getParent():addChild(bgColor, oldLayer:getZOrder()-1)
	local t = time or 0.4
   
	local tranLayerColor = CCLayerColor:create(ccc4(0,0,0,255))
    oldLayer:getParent():addChild(tranLayerColor, ZORDER_TRANSIT_VIEW)
   
	local actions = {}
	tranLayerColor:setOpacity(0)
	
	actions[1] = CCFadeIn:create(t)
	actions[2] = CCCallFunc:create( function()
		oldLayer:removeFromParentAndCleanup(true)
		
		if not tolua.isnull(newLayer) then
			newLayer:setVisible(true)
			if type(newLayer.setTouch)=="function" and newLayer.tag ~= TYPE_LAYER_PORT then newLayer:setTouch(true) end
			if type(newLayer.playOpenSound)=="function" then newLayer:playOpenSound() end
		end
		if type(callBack)=="function" then
			callBack()
		end
		
	end)
	actions[3] = CCFadeOut:create(t)
	actions[4] = CCCallFunc:create(function()
		if not tolua.isnull(tranLayerColor) then
			tranLayerColor:removeFromParentAndCleanup(true)
		end
		
		if not tolua.isnull(bgColor) then
			bgColor:removeFromParentAndCleanup(true)
		end
	end)
	
	local action = transition.sequence(actions)
	tranLayerColor:runAction(action)	
end 

-- 层切换效果
function MyTransition:addLayer(target,newLayer,zOrder,callBack,delayTime,params,layer_tag, shake)
    if tolua.isnull(target) or tolua.isnull(newLayer) then return end

    if type(target.setTouch)=="function" then target:setTouch(false) end

    missionGuide:disableGuideByPanel(target)
    newLayer:setVisible(false)
    if type(newLayer.setTouch)=="function" then newLayer:setTouch(false) end
    if layer_tag then
        target:addChild(newLayer,zOrder or 1, layer_tag)
    else
        target:addChild(newLayer,zOrder or 1)
    end
    
    local addLayerColor = CCLayerColor:create(ccc4(0,0,0,255))
    target:addChild(addLayerColor, ZORDER_INDEX_TWENTY)

    addLayerColor:setOpacity(0)
    local arr=CCArray:create()
    arr:addObject(CCFadeIn:create(delayTime or 0.4))
    arr:addObject(CCCallFunc:create(function()
        if not tolua.isnull(newLayer) then
            newLayer:setVisible(true)
        end
    end))
    arr:addObject(CCFadeOut:create(delayTime or 0.4))
    arr:addObject(CCCallFunc:create(function()
        if not tolua.isnull(addLayerColor) then
            addLayerColor:removeFromParentAndCleanup(true)
        end
        if tolua.isnull(newLayer) then
            return
        end
        if not tolua.isnull(target) then
            if type(target.setTouch)=="function" then target:setTouch(false) end
        end

        if type(callBack)=="function" then callBack(params) end
        if not tolua.isnull(newLayer) then
            if type(newLayer.setTouch)=="function" then newLayer:setTouch(true) end
            if type(newLayer.playOpenSound)=="function" then newLayer:playOpenSound() end
        end

        if shake then
            local Tips = require("ui/tools/Tips")
            local shake_layer = newLayer
            if type(newLayer.getShakeLayer) == "function" then
                shake_layer = newLayer:getShakeLayer()
            end
            Tips:runAction(shake_layer)
        end
    end))
    addLayerColor:runAction(CCSequence:create(arr))
end

function MyTransition:skipLayer(call_back, show_call_back, delay_time) --call_back淡入之后进行的回调，show_call_back淡出的时候同时执行的方法
    local running_scene = GameUtil.getRunningScene()
    local layer_color = CCLayerColor:create(ccc4(0, 0, 0, 255))
    running_scene:addChild(layer_color, ZORDER_SKIP_LAYER)
    layer_color:setOpacity(0)

    local arr = CCArray:create()
    arr:addObject(CCFadeIn:create(delay_time or 0.4))
    arr:addObject(CCCallFunc:create(function() 
        if type(call_back) == "function" then call_back() end
    end))
    local fade_out = CCFadeOut:create(delay_time or 0.4)
    if type(show_call_back) == "function" then
        arr:addObject( CCSpawn:createWithTwoActions(fade_out, CCCallFunc:create(show_call_back)) )
    else
        arr:addObject(fade_out)
    end
    
    arr:addObject(CCCallFunc:create(function()
        if not tolua.isnull(layer_color) then
            layer_color:removeFromParentAndCleanup(true)
        end
    end))

    layer_color:runAction(CCSequence:create(arr))
end

function MyTransition:delLayer(oldLayer, callBack, notRunAction, delayTime)
    local delayTime = delayTime or 0.4
    if tolua.isnull(oldLayer) then return end
    if type(oldLayer.setTouch) == "function" then oldLayer:setTouch(false) end
    local running_scene = GameUtil.getRunningScene()

    local delLayerColor = CCLayerColor:create(ccc4(0,0,0,255))
    running_scene:addChild(delLayerColor, ZORDER_SKIP_LAYER)

    delLayerColor:setOpacity(0)
    local arr = CCArray:create()
    if not notRunAction then
        arr:addObject(CCFadeIn:create(delayTime))
    end
    local parent = oldLayer:getParent()
    arr:addObject(CCCallFunc:create(function()
        if not tolua.isnull(oldLayer) then
            oldLayer:removeFromParentAndCleanup(true)
            oldLayer = nil
		end
        
        local port_layer = getUIManager():get("ClsPortLayer")

        if not tolua.isnull(port_layer) and tolua.isnull(port_layer.portItem) then --退回港口
            getGameData():getPortData():popSailorAppiont()
        end
    end))
    if not notRunAction then
        arr:addObject(CCFadeOut:create(delayTime))
    end
    arr:addObject(CCCallFunc:create(function()
        if not tolua.isnull(parent) and type(parent.setTouch) == "function" then
            parent:setTouch(true)
        end
        if type(callBack)=="function" then callBack() end
        if not tolua.isnull(delLayerColor) then
            delLayerColor:removeFromParentAndCleanup(true)
        end
        missionGuide:enableAllGuide()
    end))
    delLayerColor:runAction(CCSequence:create(arr))
end

return MyTransition
