local TAG_VALUE_IMAGE = 221	
local highlightTag = 2

local MatrixControl = class("MatrixControl", function (dimension)
	local width = dimension.width
	local height = dimension.height
	return CCLayerColor:create(ccc4(111, 111, 111, 0), width, height)
end)

function MatrixControl:ctor(dimension, bgRes, rows, cols, offsetX, offsetY, isFlipable, bgWidth, bgHeight)
	local width = dimension.width
	local height = dimension.height
	self.rows = rows
	self.cols = cols
	self.items = {}
	self.backItems = {} -- 如果isFlipable is true， 用来存放back sprite item
	self.curSelectedItem = nil
	
	self.selected = false
	self.normal = true
	self.isFlipable = isFlipable
	self.isface = true
	local spriteSize
	if bgRes then
		local sprite = display.newSprite(bgRes)
		spriteSize = sprite:getContentSize()

	else
		spriteSize = CCSize(bgWidth, bgHeight)
	end
	if offsetX ~= 0 then 
		baseXLeft = (width - (offsetX+spriteSize.width)*(cols -1 ))/2
	else
		baseXLeft = width * 0.1 + spriteSize.width/2--贴图其实位置
	end
	--if offsetY then 
		baseYTop = height - ((height - (offsetY + spriteSize.height)*(rows - 1))/2)
	--else 
		--baseYTop = height * 0.9 - spriteSize.height/2
	--end
	local gapX = 10
	local gapY = 10
	for col = 1, cols do
		for row = 1, rows do
			local control 
			if bgRes then 
				control = display.newSprite(bgRes)	
			else	
				control = CCLayerColor:create(ccc4(1.0, 1.0, 0.0, 0.0))
				control:ignoreAnchorPointForPosition(false)
				control:setAnchorPoint(ccp(0.5, 0.5))
				control:setContentSize(spriteSize)
			end
			control:setPosition(ccp(baseXLeft + (spriteSize.width + offsetX)*(col - 1), baseYTop - ((offsetY+spriteSize.height)*(row-1))))
			self:addChild(control)
			self.items[#self.items + 1] = control
		end
	end

	-- function onTouch(event, x, y)
		-- if event == "began" then
			-- return self:onTouchBegan(x, y)
		-- elseif event == "ended" then
			-- self:onTouchEnded(x, y)
		-- end
	-- end
	self:setTouchEnabled(true)
	--self:registerScriptTouchHandler(self:onTouch)
	
end

function MatrixControl:onTouch(event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	elseif event == "ended" then
		self:onTouchEnded(x, y)
	end
end

function MatrixControl:onTouchBegan(x, y)
	return true
end

function MatrixControl:onTouchEnded(x, y)
	local _item = self:getItemByPosition(ccp(x, y))
	if _item ~= nil and not tolua.isnull(_item) and self.selectFunc ~= nil then 
		self.selectFunc(_item, x, y, self)
	end
end

function MatrixControl:regSelectItemEvent(func)
	self.selectFunc = func
end
-- local function MatrixControl:setItemselected(item)
-- 	item:addChild()
-- end

-- function MatrixControl:onTouchBegan()
-- 	local item = self:getItemByPosition(x, y)
-- 	if item then 
-- 		self:setItemselected(item)
-- 	end
-- end


function MatrixControl:getItem(row, col)
	--cclog("MatrixControl:getItem row col:%d, %d", row, col)
	
	local index
	if col == nil then
		index = row
	else 
		index = (row - 1)*self.cols + col
	end
	return self.items[index]
end


function MatrixControl:setItemTag(row, col, tag)
	local item = self:getItem(row, col)
	if item then 
		item:setTag(tag)
	end
end

function MatrixControl:getItemByPosition(pt) --pt 世界坐标
	pt = self:convertToNodeSpace(pt)
	for i,item in ipairs(self.items) do
		if item:boundingBox():containsPoint(pt) then
			return item
		end
	end
end

function MatrixControl:setItemValue(row, col, image)
	local sprite = self:getItem(row, col)
	if sprite == nil then 
		cclog("MatrixControl:setItemValue error, item(%d, %d) cannot found.", row, col)
	end
	
	--sprite:removeChildByTag(TAG_VALUE_IMAGE, true)
	--删除原来的item val sprite
	local size = sprite:getContentSize()
	local child =  sprite:getChildByTag(TAG_VALUE_IMAGE)
	if child then 
		child:removeFromParentAndCleanup(true)
	end
	
	if type(image) == "string" then 
		if string.sub(image, 1, 1) ~= "#" then
			image = "#"..image
		end
		child = display.newSprite(image)	
	elseif type(image) == "userdata" then
		--local a = tolua.type(image)
		--print("toluatype", a )
		child = image
	else 
		--cclog("MatrixControl:setItemValue error, unclear type:%s", type(image))
		return
	end
	child:setPosition(size.width/2, size.height/2)
	sprite:addChild(child, 0, TAG_VALUE_IMAGE)
end

function MatrixControl:getItemValue(item)
	local child = item:getChildByTag(TAG_VALUE_IMAGE)
	child = tolua.cast(child, "CCSprite")

	if child ~= nil or (not tolua.isnull(child)) then
		return child:displayFrame()
	end
end

function MatrixControl:selectItem(item, highlightImageRes)
	if item == nil then return end
	if self.curSelectedItem then
		self.curSelectedItem:removeChildByTag(highlightTag, true)
	end
	selectedImage = display.newSprite(highlightImageRes, item:getContentSize().width/2, item:getContentSize().height/2)
	item:addChild(selectedImage, -1, highlightTag)
	self.curSelectedItem = item
end
    
function MatrixControl:addImageAtCurSelectedItem(spriteFrame)
	if self.curSelectedItem == nil then return end
	self.curSelectedItem:removeChildByTag(TAG_VALUE_IMAGE, true)
	local size = self.curSelectedItem:getContentSize()
	local image = display.newSpriteWithFrame(spriteFrame, size.width/2, size.height/2)
	local imageSize = image:getContentSize()
	image:setScale(size.width/imageSize.width - 0.08) -- 适配背景图
	self.curSelectedItem:addChild(image, 0, TAG_VALUE_IMAGE)
end

return MatrixControl