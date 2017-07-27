local composite_effect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsNewBieMissionUI = class("ClsNewBieMissionUI", ClsBaseView)
local ui_word = require("game_config/ui_word")

ClsNewBieMissionUI.getViewConfig = function(self)
	return {
		name = "ClsNewBieMissionUI",
		type = UI_TYPE.TIPS,
	}
end

ClsNewBieMissionUI.onEnter = function(self, call_back)
	self.bg = getChangeFormatSprite("ui/story/story_19.jpg")
	self.bg_action = getChangeFormatSprite("ui/story/story_21.jpg")
	--self.bg:setPosition(display.cx, display.cy)
	--self.bg_action:setPosition(display.cx, display.cy)
	self.bg:setAnchorPoint(ccp(0, 0))
	self.bg:setScale(0.8)
	self.bg_action:setAnchorPoint(ccp(0, 0))
	self.bg_action:setScale(0.8)
	self:addChild(self.bg)
	self:addChild(self.bg_action)
	self.call_back = call_back
	self:showNewBieView()
end

ClsNewBieMissionUI.showNewBieView = function(self)
	local effect_id = "tx_blink"
	local func = function()
		self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(function( )
			
			self:closeView()
			if type(self.call_back) == "function" then
				self.call_back()
			end
		
			
		end)))
		
	end
	self.blink_effect = composite_effect.new(effect_id, display.cx, display.cy, self, 6.5, func)

	self.blink_effect:setZOrder(1)
	

	self.bg_action:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(6), CCFadeOut:create(0.5)))
end

ClsNewBieMissionUI.closeView = function(self)
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(6), CCCallFunc:create(function ( )
		self:close()
	end)))
end

return ClsNewBieMissionUI