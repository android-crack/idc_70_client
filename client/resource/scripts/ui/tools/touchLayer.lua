--  点击非按钮地方，消失这个层

local portButtonEffect = require("gameobj/port/portButtonEffect")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")

local TouchLayer = class("TouchLayer", function() return CCLayer:create() end)

--层类型
local LAYER_TYPE = {
	PORT = 1,
}

local QUAY_KEY = {
	[1] = on_off_info.PORT_QUAY_EXPLORE.value,
	[2] = on_off_info.PORT_QUAY_FIGHT.value,
	[3] = on_off_info.PORT_QUAY_ROB.value,
	[4] = on_off_info.PORT_QUAY_JJC.value,
	[5] = on_off_info.TRUSTEESHIP.value,
}

TouchLayer.ctor = function(self, item)

	self.btn = item.btn
	self.callBack = item.callBack
	self.startY   = item.startY  or -50
	self.targetY  = item.targetY or 100
	self.layerType= item.layerType
	self.autodisappear = not item.noDisapper

	if #self.btn < 1 then return end
	self.menu=MyMenu.new(self.btn)
	self:addChild(self.menu)

	self:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
	self:registerScriptTouchHandler(function(event, x, y)
		return self:onTouch(event, x, y) end, false, -128, false)
	self:setTouchEnabled(true)

	self:init()
end

TouchLayer.init = function(self)
	for k, v in ipairs(self.btn) do
		local action = CCMoveTo:create(0.3, ccp(v:getPositionX(), self.targetY))
		local args = {
			delay = 0.1 * (k - 1),
			easing = "CCEaseBackInOut",
		}
		if self.layerType == LAYER_TYPE.PORT then
			args = {
				delay = 0.1 * (k - 1),
				easing = "CCEaseBackInOut",
				onComplete = function()
					local lx, ly = v:getPositionX(), self.targetY
					local btnKey = v.key
					portButtonEffect:playButtonEffect(v, btnKey, EFFECT_TYPE.QUAY)
					missionGuide:addGuideLayer(btnKey, {radius = v:getContentSize().width * 0.5, pos = {x = lx, y = ly}},
						{layer = self, zorder = 10})
				end,
			}
		end
		transition.execute(v, action, args)
	end
end

TouchLayer.onTouch = function(self, event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	elseif event == "moved" then
		self:onTouchMoved(x, y)
	elseif event == "ended" then
		self:onTouchEnded(x, y)
	end
end


TouchLayer.onTouchBegan = function(self, x, y)
	self.drag = {
		startX = x,
		startY = y,
		isTap = true,
	}
	return true
end

TouchLayer.onTouchMoved = function(self, x, y)
	if self.drag.isTap then
		if math.abs(y - self.drag.startY) >= 5 or math.abs(x - self.drag.startX)>= 5 then
			self.drag.isTap = false
		end
	end
	return true
end

TouchLayer.disappear =function(self)
	for k, v in ipairs(self.btn) do
		local action = CCMoveTo:create(0.4, ccp(v:getPositionX(), self.startY))
		if k==1 then
			action = CCSequence:createWithTwoActions(action, CCCallFuncN:create(function()
				if self.callBack then
					self.callBack()
				end
				self:removeFromParentAndCleanup(true)
			end))
		end
		local args = {
			delay = 0.1 * (-k + #self.btn),
			easing = "CCEaseBackInOut"
		}
		transition.execute(v, action, args)
	end
	
end

TouchLayer.onTouchEnded = function(self, x, y)
	--点击才有效
	local touchPos=ccp(x,y)
	for k, button in ipairs(self.btn) do
		if button:boundingBox():containsPoint(touchPos) then
			return
		end
	end
	if self.autodisappear then
		self:disappear()
	end
end

TouchLayer.onExit = function(self)

end

return TouchLayer
