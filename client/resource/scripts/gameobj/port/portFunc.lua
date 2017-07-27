local animationCache=CCAnimationCache:sharedAnimationCache()
local cache=CCSpriteFrameCache:sharedSpriteFrameCache()

function getAnimate(str,count,delay,key)
    local animation=nil

    if key then
        animation=animationCache:animationByName(key)
    end

    if tolua.isnull(animation) then
        local animFrames=CCArray:createWithCapacity(count)
        for i=1,count do
            local frame=cache:spriteFrameByName(string.format(str,i))
            animFrames:addObject(frame)
        end
        delay=delay or 0.2
        animation = CCAnimation:createWithSpriteFrames(animFrames,delay)
    end

    if key then
        animationCache:addAnimation(animation,key)
    end
    return CCAnimate:create(animation)
end

--小人的跑动一些处理函数

function getTime(x1,y1,x2,y2,v)
    v=v or 20
    return math.sqrt(math.pow(x2-x1,2)+math.pow(y2-y1,2))/v
end

function getX(x)
    local portData = getGameData():getPortData()
    if portData:getPortFlipX()==1 then return display.right-x end
    return x
end

