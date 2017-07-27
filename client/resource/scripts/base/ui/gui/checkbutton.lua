-- check button 右边带有文本
-- 第一图标是选中状态，第二个是非选中状态

module("ui_ext", package.seeall)


CheckButton = class("CheckButton",function()
    return display.newNode()
end)

CheckButton.ctor = function(self,itemParams,labelParams)
	
	local x = itemParams.x
	local y = itemParams.y
 
	self.toggleItem = self:newMenuItemToggle(itemParams)
	self.toggleItem:setAnchorPoint(ccp(0,1))
	self.button =ui.newMenu(self.toggleItem)
	self:addChild(self.button)
	
	if labelParams then 
		self.label = ui_ext.Label.new(labelParams)
		self.label:setAnchorPoint(ccp(0,0.5))
		
		local labelX = self.toggleItem:getContentSize().width + 3
		local labelY = self.toggleItem:getContentSize().height/2 
		self.label:setPosition(ccp(labelX, labelY))
		self.toggleItem:addChild(self.label)
	end	
	self:setPosition(ccp(x,y))	
end

--事件响应
CheckButton.registerCallback = function(self,selectListener, disselectListener)
	self.selectListener = selectListener
	self.toggleItem:registerScriptTapHandler(function(tag)
		if self.toggleItem:selectedItem() == self.selectedItem and type(selectListener) == "function"then
			selectListener(tag)    --选中回调
		elseif type(disselectListener) == "function" then
			disselectListener(tag)
		end
	end)
end


-- privite function
CheckButton.newMenuItemToggle = function(self, params)
	
	local selectedSprite = display.newSprite(params.imageSelected)
	local disselectedSprite = display.newSprite(params.imageUnselected)	
	self.selectedItem   = CCMenuItemSprite:create(selectedSprite, selectedSprite)
	self.unselectedItem = CCMenuItemSprite:create(disselectedSprite, disselectedSprite)
	
	local toggleItem = CCMenuItemToggle:create(self.unselectedItem)
	toggleItem:addSubItem(self.selectedItem)
	return toggleItem
end

CheckButton.setChecked = function(self, isCheck)
	if isCheck then
		self.toggleItem:setSelectedIndex(1)
	else
		self.toggleItem:setSelectedIndex(0)
	end
end

CheckButton.isChecked = function(self)
	return self.toggleItem:getSelectedIndex() == 1
end

return CheckButton



