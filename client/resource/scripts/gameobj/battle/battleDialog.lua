-- 战斗对话

local sailor_info = require("game_config/sailor/sailor_info")
local commonBase = require("gameobj/commonFuns")
local ui_word=require("game_config/ui_word")

local Dialog = class("Dialog",function()return CCLayer:create()end)

function Dialog:ctor(cfg)
	self.cfg = cfg
	local x = cfg.x or 0
	local y = cfg.y or 0
	self.cfg.x = x
	self.cfg.y = y
	self.call_back = cfg.call_back
	self.seaman_id = cfg.seaman_id
	self.name = cfg.name
	--不能通过点击取消播放
	if cfg.isTouchRemove ~= nil then
		self.isTouchRemove = cfg.isTouchRemove
	end

	local txt = cfg.txt or ""
	local scaleY = cfg.scaleY or 1
	local scaleX = cfg.scaleX or 1
	self.txt = commonBase:repString(txt)
	
	self:setPosition(ccp(x,y))

	self.bg = display.newSprite("#common_dialog_sea.png", 0, 0)
	self:addChild(self.bg)

	local gapY = -18
	if scaleY==-1 then
		gapY = 18
	end
	self.bg:setScaleX(scaleX)
	self.bg:setScaleY(scaleY)

	local bgW = self.bg:getContentSize().width
	local bgH = self.bg:getContentSize().height

	local x = 0
	local anchor_point = ccp(0.5, 1)

	if sailor_info[self.seaman_id] then  --用角色信息代替
		local seaman_res = sailor_info[self.seaman_id].res
		self.seaman = display.newSprite(seaman_res, -145, gapY)
		self:addChild(self.seaman)	
		local seaman_width = self.seaman:getContentSize().width
		local show_width = 80
		local scale = show_width/seaman_width
		self.seaman:setScale(scale)

		local name = commonBase:repString(self.name)..ui_word.SIGN_COLON
		self.name_label = createBMFont({text = name, size = 16, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), 
			fontFile = FONT_CFG_1, x = -90, y = gapY + 37})
		self.name_label:setAnchorPoint(ccp(0, 0.5))
		self:addChild(self.name_label)

		x = -90
		anchor_point = ccp(0, 1)
	end
	
	self.txt = cfg.txt
	self.label = createBMFont({text =self.txt, size = 16, width = 260, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), 
		fontFile = FONT_CFG_1, x = x, y = 0})
	self.label:setAnchorPoint(anchor_point)
	self:addChild(self.label)
	
	--touch
	local touch_priority = -128
    self:registerScriptTouchHandler(function(eventType,x,y)
		if eventType =="began" then 
			return self:onTouchBegan(x,y)
		end
	end, false, touch_priority, true)
	self:setTouchEnabled(true)
	self:init()
end

function Dialog:onTouchBegan(x,y)
	local touchPoint = self.bg:getParent():convertToNodeSpace(ccp(x,y))
	if self.bg:boundingBox():containsPoint(touchPoint) then
		
		if self.isTouchRemove ~= nil and self.isTouchRemove then
             cclog("Dialog:onTouchBegan isTouchRemove is true")
		else
			if type(self.call_back) == "function" then
				self.call_back()
			end 
			self:removeFromParentAndCleanup(true) 
		end

		return true
	end
	return false
end

function Dialog:init()
	local actions = {}
	actions[1] = CCDelayTime:create(3.0) -- 3秒后自动消失
	actions[2] = CCCallFunc:create(function() 	
		self:removeFromParentAndCleanup(true) 
	end)
	local action = transition.sequence(actions)
	self:runAction(action)
end



---------------- 对话框形式 ------------------
local battleDialog = {}

-- cfg = {txt = "", seaman_id = ,x= , y= , call_back = function() }
function battleDialog:showBox(cfg)  --显示对话框 
	local dialog_box = Dialog.new(cfg)
	local parent = cfg.parent
	if not tolua.isnull(parent) then
		parent:addChild(dialog_box)
		return dialog_box
	end
end  

return battleDialog