local ui = require("base/ui/ui")

local ProgressEx = class("ProgressEx",function(bgRes,res,flagRes)
	return display.newSprite(bgRes)
end)

function ProgressEx:ctor(bgRes,res,flagRes)
	local selfSize=self:getContentSize()
	self.progressY=selfSize.height/2

	self.progress=ui.newProgressTimer({image = res, types = kCCProgressTimerTypeBar, x = 0, y = 0})
	self.progress:setPosition(selfSize.width/2,self.progressY)
	self.progress:setPercentage(0)
	self:addChild(self.progress)

	self.flagSprite=display.newSprite(flagRes)
	self.flagSprite:setVisible(false)
	self.flagSprite:setAnchorPoint(ccp(0,0.5))
	self:addChild(self.flagSprite)

	local progressSize=self.progress:getContentSize()
	local flagSize=self.flagSprite:getContentSize()
	self.percentPix=(progressSize.width-self.flagSprite:getContentSize().width)/100
	self.maxPix=progressSize.width-flagSize.width
	self.minPercent=flagSize.width/self.percentPix
end

function ProgressEx:setPercentage(percent)
	if percent>0 then
		if percent<self.minPercent then percent=self.minPercent end

		self.progress:setPercentage(percent)
		local x=self.percentPix*percent
		if x> self.maxPix then x=self.maxPix end
		if not self.flagSprite:isVisible() then
			self.flagSprite:setVisible(true)
		end
		self.flagSprite:setPosition(x,self.progressY)
	end
end

return ProgressEx
