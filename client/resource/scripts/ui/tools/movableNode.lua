local movableNode = class("movableNode", function (node, rect)
	local size = node:getContentSize()
	local layer = CCLayerColor:create(ccc4(255,255,255,255), rect.size.width, rect.size.height)	
	layer:setPosition(rect.origin)
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(ccp(0.5, 0.5))
	return layer
end
)

function movableNode:ctor(node, rect)
	local nodeSize = node:getContentSize()
	if nodeSize.width <= 0 or nodeSize.height <= 0 then
		cclog("create movableNode error, then node size is (0, 0)")
		return
	end
	
	self.movableInterval = nodeSize.height - rect.size.height -- 可以移动的总范围，超过此范围不可向上移动
	self.curInterval = 0
	self.node = node
	
	self:addChild(self.node)
	self.node:setAnchorPoint(ccp(0, 1))
	self.node:setPosition(0, rect.size.height)
	
	local function onTouch(event, x, y)
		if event == "began" then
		
			self:onTouchBegan(x, y)
		elseif event == "moved" then
			self:onTouchMoved(x, y)
		elseif event == "ended" then
			self:onTouchEnded(x, y)
		end
	end
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(onTouch, false, -128, true)
	
end

function movableNode:onTouchBegan(x, y)
	self.beginPos = ccp(x, y)
	return true
end

function movableNode:onTouchMoved(x, y)
	self.intervalPos = ccpSub(ccp(x, y), self.beginPos)
	self.curInterval = self.curInterval + self.intervalPos
	if self.curInterval < 0 or self.curInterval > self.movableInterval then 
		return
	end
	self.node:setPosition(ccpAdd(ccp(self.node:getPosition()), self.intervalPos))
	
end

function movableNode:onTouchEnd(x, y)
	
end

return movableNode