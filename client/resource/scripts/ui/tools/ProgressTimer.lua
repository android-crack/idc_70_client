----水平进度条

local ui = require("base/ui/ui")
local ProgressTimer = class("ProgressTimer", function() return CCNode:create() end)

function ProgressTimer:ctor(res)
	self.progressBg = display.newSprite(res.backgr)
	self:addChild(self.progressBg)
	self.pw = self.progressBg:getContentSize().width
	local ph = self.progressBg:getContentSize().height
	
	local precent = 100.0
	self.progress = ui.newProgressTimer({image = res.progress, types = kCCProgressTimerTypeBar})
	self.progress:setPercentage(precent)
	self:addChild(self.progress)
	
	self.endProgress = display.newSprite(res.endProgress)
	self.endProgress:setAnchorPoint(ccp(0.0,0.5))
	self.ew = self.endProgress:getContentSize().width
	local eh = self.endProgress:getContentSize().height
	self.initEndPosX = self.pw * 0.5 - self.ew * 1.5
	self.endProgress:setPosition(self.initEndPosX, 0)
	self:addChild(self.endProgress)
end

function ProgressTimer:setPercentage(percentage)
	if percentage > 100 or percentage < 0 then return end
	self.progress:setPercentage(percentage)
	local precent = percentage / 100
	local dw = math.floor(self.pw * precent)
	if dw <= self.ew then 
		----当百分比很小时隐藏这个光标，因为效果不太好，不好看
		self.endProgress:setVisible(false)
		return
	else
		self.endProgress:setVisible(true)
	end
	
	local dx = math.floor(self.pw * (1 - precent))
	local sew = self.ew
	dx = dx - sew
	local ex = self.initEndPosX - dx
	if ex > self.initEndPosX then ex = self.initEndPosX end
	self.endProgress:setPosition(ex, 0)
end

function ProgressTimer:runProgressAction(action)
	self.progress:runAction(action)
end

function ProgressTimer:getProgressBgSize()
	return self.progressBg:getContentSize()
end

return ProgressTimer