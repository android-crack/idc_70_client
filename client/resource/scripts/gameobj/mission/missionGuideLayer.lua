--创建指引层
local CompositeEffect = require("gameobj/composite_effect")
local on_off_info = require("game_config/on_off_info")
local ui_word = require("game_config/ui_word")

local GuideLayer = class("missionGuideLayer", function() return CCLayer:create() end)

local FINGER_CIRCLE_EFFECT = "tx_1042_1"
local CIRCLE_EFFECT = "tx_1042_5"
local LEVEL_LIMIT = 10

function GuideLayer:ctor(guideItem)
	self:init(guideItem)
end

local need_finger_effect = {
	[on_off_info.PORT_UNION.value] = true,
	[on_off_info.GUILD_DONATE.value] = true,
	[on_off_info.GUILD_DEPOT.value] = true,
	[on_off_info.QUICK_EQUIPMENT.value] = true,
	[on_off_info.HALL_BUTTON.value] = true,
	[on_off_info.CLOSED_BUTTON.value] = true,
	[on_off_info.ARMOR_SELECT.value] = true,
	[on_off_info.TREASURE_WAREHOUSE.value] = true,
}

function GuideLayer:init(guideItem)
	self.child_widgets = {}
	self.key = guideItem.key
	self.guideType = guideItem.guideType or 0				--等于0时不加遮盖层，1则加遮盖
	local fRadius = guideItem.radius or 30						--半径
	local circlePos = guideItem.pos								--位置
	local isDelay = guideItem.isDelay							--手指是否延迟出现
	self.effectName = guideItem.effectName or FINGER_CIRCLE_EFFECT		--手指特效
	if string.len(self.effectName) < 1 then
		self.effectName = FINGER_CIRCLE_EFFECT
	end
	
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

	self.virtual_touch_begin_pos = ccp(0, 0)
	self.virtual_touch_end_pos = ccp(0, 0)
	self.virtual_touch_real_flag = 10
	table.insert(self.child_widgets, self.virtual_touch_layer)
	self:addChild(self.virtual_touch_layer)

	local onOffData = getGameData():getOnOffData()

	if need_finger_effect[self.key] then
		self.effectName = FINGER_CIRCLE_EFFECT
	end
	
	if self.effectName == FINGER_CIRCLE_EFFECT then
		--如果已经开启了战役按钮，则指引特效去掉手指(另一特效)
		if onOffData:isOpen(on_off_info.PORT_QUAY_FIGHT.value) then
			self.effectName = CIRCLE_EFFECT
		end
	end

	local diameter = fRadius * 2
	if guideItem.size then
		local size = guideItem.size
		self.rect = CCRect(circlePos.x - size.width / 2, circlePos.y - size.height / 2, size.width, size.height)
	else
		self.rect = guideItem.rect or CCRect(circlePos.x - fRadius, circlePos.y - fRadius, diameter, diameter)
	end
	self:event(guideItem)	

	self:addFinger(circlePos, isDelay)	
end

function GuideLayer:event(guideItem)
	local base_view = getUIManager():get(guideItem.baseView)
	if not base_view then return end
	base_view:regGuildTouchEvent(self, function(eventType, x, y) 
		if eventType =="began" then
			local pos = self:convertToNodeSpace(ccp(x,y))
			local touchInPoint = self.rect:containsPoint(pos)
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
		local touchInPoint = self.rect:containsPoint(pos)
		if eventType =="began" then
			self.virtual_touch_begin_pos = pos
			if self.guideType == 1 then
				if touchInPoint then
					return true
				else
					return false
				end
			else
				return true
			end
		elseif eventType == "ended" then
			self.virtual_touch_end_pos = pos
			if self.guideType == 1 then
				if touchInPoint then
					self:clearGuideLayer(true)
				end
			else
				if touchInPoint then
					self:clearGuideLayer(true)
				-- else
					-- self:clearGuideLayer(false)
				end
			end
		end
	end, 2)
end

--添加点击特效
function GuideLayer:addFinger(pos, isDelay)	
	local delayTime = 0.6
	if not isDelay then delayTime = 0 end
	local act1 = CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(function()
		CompositeEffect.bollow(self.effectName, pos.x or 0, pos.y or 0, self)
	end))
	self:runAction(act1)
end

--点击关闭后回调
function GuideLayer:setExitCallFunc(callFn)
	self.exitCallFunc = callFn
end

--点击关闭后回调
function GuideLayer:setCallFunc(callFn)
	self.callFunc = callFn
end

--清除指引层
function GuideLayer:clearGuideLayer(needTryGuide)
	if tolua.isnull(self) then return end
	if self.exitCallFunc ~= nil then
		self.exitCallFunc()
	end
	self:removeFromParentAndCleanup(true)
	self.child_widgets = {}
	if type(self.callFunc) == "function" then
		self.callFunc(self.key, needTryGuide)
	end
end

--创建手指指引层
function createMissionGuideLayer(guideItem)
	return GuideLayer.new(guideItem)
end