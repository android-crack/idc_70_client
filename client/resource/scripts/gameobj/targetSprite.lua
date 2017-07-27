-- CCRenderTarget3D 用到的sprite

local TargetSprite = class("TargetSprite", 
	function(size) 
		local texture = CCTextureCache:sharedTextureCache():addImage("ui/NULL.png")
		return CCSprite:createWithTexture(texture, CCRect(0, 0, size.width, size.height))
	end
)

function TargetSprite:ctor(size, touchSize)
	self.size = touchSize or size 
	self:setFlipY(true)
	self:QTZSetTextureCoords(CCRect(0, 0, size.width, size.height))
end 

function TargetSprite:getTouchRect()
	if not self.size then
		return CCRect(0,0,0,0)
	end 
	local x, y = self:getPosition()
	return CCRect(x-self.size.width/2, y-self.size.height/2, self.size.width, self.size.height)
end

return TargetSprite