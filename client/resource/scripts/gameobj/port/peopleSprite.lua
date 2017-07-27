
local function getSprite(people,pos1,pos2)
    local res="#"..people.front
    
    local isFlip=false
    if pos1 and pos2 then
        if pos1[2]<pos2[2] then
            res=string.format("#"..people.reverse_config.res,1)
            if pos1[1]<pos2[1] then isFlip=true end
        else
            res=string.format("#"..people.front_config.res,1)
            if pos1[1]>pos2[1] then isFlip=true end
        end
    end

    local sprite=display.newSprite(res)
    if pos1 then sprite:setPosition(ccp(pos1[1],pos1[2])) end
    sprite:setFlipX(isFlip)
    return sprite
end

local PeopleSprite = class("PeopleSprite",getSprite)

function PeopleSprite:ctor(people)
    self:setZOrder(1)
    people.delay=people.delay or 0.1
    --正反面静止图
    local size=self:getContentSize()
    self.shade=display.newSprite("#port_shadow.png",size.width/2,size.height*0.45)
    self:addChild(self.shade)
    self.frontFrame=display.newSpriteFrame(people.front)
    self.reverseFrame=display.newSpriteFrame(people.reverse)
    
    --正反面动画
    self.frontAnimation=CCRepeatForever:create(getAnimate(people.front_config.res,people.front_config.count,people.delay))
    self.frontAnimation:retain()
    self.reverseAnimation=CCRepeatForever:create(getAnimate(people.reverse_config.res,people.reverse_config.count,people.delay))
    self.reverseAnimation:retain()

    self:registerScriptHandler(function(event)
        if event == "exit" then self:onExit() end
    end)
end

function PeopleSprite:onExit()
    self.frontAnimation:release()
    self.reverseAnimation:release()
end

return PeopleSprite