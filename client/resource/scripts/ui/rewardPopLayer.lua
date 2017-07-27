local collectCommon = require("ui.collectCommon")
local achieveInfo = require("game_config/collect/achievement_info")
local uiWord = require("game_config/ui_word")


rewardPopLayer = class("rewardPopLayer")
local math_floor = math.floor
function rewardPopLayer:ctor()
	self.stack = {}
	self.index = 0
	self.run = true
	self.isshowing = false
end

function rewardPopLayer:push(id)
	self.index = self.index + 1
	table.insert(self.stack,{ id = id, index = self.index })
end

function rewardPopLayer:showLayer(id)
	self.isHide = EventTrigger(EVENT_SHOW_MAIN_LAYER, true)
	
	EventTrigger(EVENT_SHOW_PORT_NAME, true)

	self.isshowing = true
	local rewardLayer = CCLayer:create()

	local backgr = display.newSprite("#common_achieve.png")
	rewardLayer:addChild(backgr)
	
	local backgrSize = backgr:getContentSize()
	local bWidth  = backgrSize.width
	local bHeight = backgrSize.height
	
	backgr:setPosition(display.width*0.5,display.height + bHeight)

	local line = display.newSprite("#common_line4.png")
	backgr:addChild(line)
	line:setScaleX(bWidth / line:getContentSize().width)
	line:setPosition(bWidth * 0.5, bHeight * 0.5)

	local offset = 10
	local tx, ty = bWidth*0.5, 50

	local title = createBMFont({text = uiWord.NEW_ACHIEVE_NAME .. achieveInfo[id].name, fontFile = FONT_TITLE, size = 18,color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
	title:setPosition(tx, ty)
	backgr:addChild(title)
	
	local titleSize = title:getContentSize()
	
	local left = display.newSprite("#common_figure8.png")
	left:setAnchorPoint(ccp(1.0,0.5))
	left:setPosition(tx - titleSize.width*0.5, ty)
	local right = display.newSprite("#common_figure8.png")
	right:setAnchorPoint(ccp(0.0,0.5))
	right:setPosition(tx + titleSize.width*0.5, ty)
	right:setFlipX(true)

	local rewardItem = {}
	rewardItem.bgNode = backgr
	rewardItem.data = achieveInfo[id]
	rewardItem.direction = DIRECTION_HORIZONTAL
	rewardItem.picSize = 0.75
	rewardItem.posX = 0
	achieveCurrentKind = achieveInfo[id]
	if achieveInfo[id].promote and string.len(achieveInfo[id].promote) > 0 then rewardItem.posX = 25 end
	fontSet = {}
	fontSet.strFont = FONT_CFG_1
	fontSet.numFont = FONT_CFG_1
	fontSet.strSize = 16
	fontSet.numSize = 20
	fontSet.strColor = COLOR_CREAM_STROKE
	fontSet.numColor = COLOR_CREAM_STROKE
	rewardItem.fontSet = fontSet
	rewardItem.picType = 1
	
	local posX, node, widthCount = collectCommon:createReward(rewardItem)
	node:setPosition(math.floor(bWidth/2 - widthCount/2), 17)
	
	local function clearRewardLayer()		
		rewardLayer:removeFromParentAndCleanup(true)
		self.isshowing = false
		if #self.stack < 1 then
			if not self.isHide then
				EventTrigger(EVENT_SHOW_MAIN_LAYER, true)
			end			
			EventTrigger(EVENT_SHOW_PORT_NAME, true)
			self.isHide = nil
		end
		local id = self:pop()
	end

	backgr:addChild(left)
	backgr:addChild(right)
	rewardLayer:setTouchEnabled(true)
	rewardLayer:registerScriptTouchHandler(function(event, x, y)
		local pos = rewardLayer:convertToNodeSpace(ccp(x,y))
		local touchInPoint = backgr:boundingBox():containsPoint(pos)
		if touchInPoint then
			local running_scene = GameUtil.getRunningScene()
			if getMainScene() == running_scene then
                --createAchieveUI()
                clearRewardLayer()
			else
                backgr:stopAllActions()
				local act = CCSequence:createWithTwoActions(CCMoveBy:create(0.5, ccp(0, bHeight * 1.5)), 
								CCCallFunc:create(function()
									clearRewardLayer()
								end))		
				backgr:runAction(act)
			end
			
		end
		return false
	end,false, -129, true)

	local ac1 = CCMoveBy:create(0.5, ccp(0, -bHeight * 1.5))
	local ac2 = CCDelayTime:create(2)
	local ac3 = CCMoveBy:create(0.5, ccp(0, bHeight * 1.5))
	local ac4 = CCCallFunc:create(function()
		clearRewardLayer()
	end)
	local array = CCArray:create()
	array:addObject(ac1)
	array:addObject(ac2)
	array:addObject(ac3)
	array:addObject(ac4)
	backgr:runAction(CCSequence:create(array))

	local running_scene = GameUtil.getRunningScene()
	running_scene:addChild(rewardLayer, ZORDER_UI_LAYER) 
end

function rewardPopLayer:externalCallFunc()
	if self.callFunc and type(self.callFunc) == "function" then
		self.callFunc()
		self.callFunc = nil
	end
end

function rewardPopLayer:pop()
	function done()
		local k = nil
		local id = nil 
		for key,value in pairs(self.stack) do
			id = value.id 
			return id, key
		end
	end
	if self.run == true then
		local id,key = done()
		if id then 
			if self.isshowing == false then
				table.remove(self.stack, 1)
				self:showLayer(id)
			end
		else
			self:externalCallFunc()
		end
	end
end

function rewardPopLayer:start(callFunc)
	self.run = true
	self.callFunc = callFunc
	self:pop()
end

function rewardPopLayer:stop()
	self.run = false
end



