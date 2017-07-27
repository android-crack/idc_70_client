module("ui_ext", package.seeall)

local function initNumberTextures(res)
    for i = 0, 9 do
        textureName = res.."_"..i..".png"
        textureNum = CCTextureCache:sharedTextureCache():addImage(textureName)
    end
end

local function getNumberTexture(res, number)
    textureKey = res.."_"..number..".png"
    texture = CCTextureCache:sharedTextureCache():textureForKey(textureKey)
    if texture == nil then
        initNumberTextures(res)
    end
    return CCTextureCache:sharedTextureCache():textureForKey(textureKey)
end

ImageNumber = class("ImageNumber", function()
	return CCSprite:create()
end)

ImageNumber.ctor = function(self, params)
    local x = params.x or 0
    local y = params.y or 0
    local res = params.res or "number"
    local currNum = params.num or 0
    local dx = params.dx or 0
    
    self.res = res
	self.currNum = currNum 
    self.dx = dx
	self:setPosition(ccp(x, y))
	self:reDraw()
end

ImageNumber.reDraw = function(self)
    self:removeAllChildrenWithCleanup(true)
    for i = 1, string.len(self.currNum) do
        oneNum = string.sub(self.currNum, i, i)
        oneNum = tonumber(oneNum)
        oneNumTexture = getNumberTexture(self.res, oneNum)
        local oneNumSprite = CCSprite:createWithTexture(oneNumTexture)
		local width = oneNumTexture:getPixelsWide()
		oneNumSprite:setAnchorPoint(ccp(0,1))
        oneNumSprite:setPosition(ccp((i - 1) * (width + self.dx), 0))
        self:addChild(oneNumSprite)
    end
end

ImageNumber.setNumber = function(self, number)
	self.currNum = number
	self:reDraw()
end
