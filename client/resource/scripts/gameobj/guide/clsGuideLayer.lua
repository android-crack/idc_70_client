local CompositeEffect = require("gameobj/composite_effect")
local ClsGuideLayer = class("ClsGuideLayer", function() return CCLayer:create() end)

local FINGER_CIRCLE_EFFECT = "tx_1042_1"
local CIRCLE_EFFECT = "tx_1042_5"

function ClsGuideLayer:ctor(guideItem)
	self:init(guideItem)
end

function ClsGuideLayer:init(guideItem)
	self.child_widgets = {}
	self.guideType = guideItem.guideType --等于0时不加遮盖层，1则加遮盖强制
	self.posX, self.posY = guideItem.x, guideItem.y	--位置

	local rect = guideItem.rect
	if rect.w and rect.h then
		self.touch_rect = CCRect(self.posX - rect.w / 2, self.posY - rect.h / 2, rect.w, rect.h)
	else
		self.touch_rect = rect
	end
	-- print("指引中心点位置：#######################：：",self.posX, self.posY)
	-- print("相对于父节点的触摸区域###----------------：",self.touch_rect.origin.x, self.touch_rect.origin.y, self.touch_rect.size.width, self.touch_rect.size.height)

	-- local isDelay = guideItem.isDelay		--手指是否延迟出现
	self.effectName = (guideItem.effectName > 0 and FINGER_CIRCLE_EFFECT) or CIRCLE_EFFECT  --手指特效
	
	self.virtual_touch_layer = CCLayer:create()
	local old_func = self.setVisible
	function self:setVisible(enable)
		old_func(self, enable)
		self:setTouchEnabled(enable)

		for k, v in pairs(self.child_widgets) do
			if type(v.setTouchEnabled) == "function" then
				v:setVisible(enable)
				v:setTouchEnabled(enable)
			end
		end
	end

	table.insert(self.child_widgets, self.virtual_touch_layer)
	self:addChild(self.virtual_touch_layer)

	self:event(guideItem)	

	self:addFinger()	
end

function ClsGuideLayer:event(guideItem)
	local base_view = getUIManager():get(guideItem.baseView)
	base_view:regGuildTouchEvent(self, function(eventType, x, y) 
		if eventType =="began" then
			local pos = self:convertToNodeSpace(ccp(x,y))
			local touchInPoint = self.touch_rect:containsPoint(pos)
			if self.guideType == 1 then
				if touchInPoint then
					return false
				else
					return true
				end
			else
				return false
			end
		end
	end, 1)
	
	base_view:regGuildPassTouchEvent(self.virtual_touch_layer, function(eventType, x, y) 
		if not self:isVisible() then
			return
		end
		local pos = self:convertToNodeSpace(ccp(x,y))
		local touchInPoint = self.touch_rect:containsPoint(pos)
		if eventType =="began" then
			if touchInPoint then
				return true
			else
				return false
			end
		elseif eventType == "ended" then
			if touchInPoint then
				-- print("点中指引区域，清掉指引---------------------------------")
				self:clearGuideLayer(true)
			end
		end
	end, 2)
end

--添加点击特效
function ClsGuideLayer:addFinger()	
	local delayTime = 0.6
	if not isDelay then delayTime = 0 end
	local act1 = CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(function()
		CompositeEffect.bollow(self.effectName, self.posX or 0, self.posY or 0, self)
	end)) 
	self:runAction(act1)
end

function ClsGuideLayer:setExitCallFunc(callFn)
	self.exitCallFunc = callFn
end

--点击关闭后回调
function ClsGuideLayer:setCallFunc(callFn)
	self.callFunc = callFn
end

--清除指引层
function ClsGuideLayer:clearGuideLayer(needTryGuide)
	if tolua.isnull(self) then return end
	if self.exitCallFunc ~= nil then
		self.exitCallFunc()
	end
	self:removeFromParentAndCleanup(true)
	self.child_widgets = {}
	if type(self.callFunc) == "function" then
		self.callFunc(needTryGuide)
	end
end

return ClsGuideLayer