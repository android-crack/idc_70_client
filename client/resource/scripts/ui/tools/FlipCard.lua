------翻牌效果卡片---------
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

FlipCard = class("FlipCard", ClsScrollViewItem)

function FlipCard:initUI( itemParams )
	local image1 = itemParams.image
	local image2 = itemParams.imagebg or image1
	self.tap_call_back = itemParams.call_back
	self.test_data = itemParams.data
	self.test_index = itemParams.index
	
	self.isface = true  --正面
	self.image1 = string.format("#%s.png", image1)
    self.image2 = string.format("#%s.png", image2)
	
	self.sprite1 = display.newSprite(self.image1)
	self.sprite2 = display.newSprite(self.image2)
	self.sprite1:setPosition(ccp(self.sprite1:getContentSize().width/2, self.sprite1:getContentSize().height/2))
	self.sprite2:setPosition(ccp(self.sprite2:getContentSize().width/2, self.sprite2:getContentSize().height/2))
	self:addChild(self.sprite1)
	self:addChild(self.sprite2)
	self.sprite2:setScaleX(0)
	
	if itemParams.create_node1 then
		self.node1 = itemParams.create_node1()
		self.sprite1:addChild(self.node1)
	end
	
	if itemParams.create_node2 then
		self.sprite2:addChild(itemParams.create_node2())
	end
	
	self.btn = itemParams.create_btn()
	self.btn:regCallBack(function() 
			self:callBack()
		end)
	self.sprite1:addChild(self.btn)
	
	-- self:setContentSize(self.sprite1:getContentSize())
	-- self:setPosition(ccp(x,y))
end

--[[
-消耗人民币或者金币
]]
function FlipCard:updateCostMoneyView( newNode )
	if self.node1 then
		self.node1:removeFromParentAndCleanup(true)
	end
	self.sprite1:addChild(newNode)
	self.node1 = newNode
end

function FlipCard:callBack()
	local scale1 = CCScaleTo:create(0.2, 0, 1.0)
	local function changeTexture()
		local scale2 = CCScaleTo:create(0.2, 1.0, 1.0)
		if self.isface then 
			self.sprite1:runAction(scale2)
		else 
			self.sprite2:runAction(scale2)
		end
	end
	local call_back= CCCallFunc:create(changeTexture)
	
	if self.isface then  --当前是正面
		self.isface = false
		self.sprite1:runAction(CCSequence:createWithTwoActions(scale1,call_back))	
	else
		self.isface = true
		self.sprite2:runAction(CCSequence:createWithTwoActions(scale1,call_back))
		
	end
end

function FlipCard:isFace()
	return self.isface
end

function FlipCard:onTap(x, y)
	if not self:isFace() then
		self:callBack()
	else
		self.tap_call_back(x, y, self)
	end
end



