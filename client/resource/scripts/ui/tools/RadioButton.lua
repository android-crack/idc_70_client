local music_info=require("game_config/music_info")
local RadioButton = class("RadioButton", function(items, direction, texts, x, y,sound) --CCMenuItem
	-- return ui.newMenu(items)

	local x, y = x or 0, y or 0
	local menu
    menu = CCNodeExtend.extend(CCMenu:create())

    for k, item in pairs(items) do
        if not tolua.isnull(item) then
			menu:addChild(item, 0, item:getTag())
			
        end
    end
	
	if direction == DIRECTION_HORIZONTAL then
		menu:alignItemsHorizontally()
	elseif direction == DIRECTION_VERTICAL then 
		menu:alignItemsVertically()
	end
	
    menu:setPosition(x, y)
    return menu
end)

function RadioButton:ctor(items, direction, textsInfo,x,y,sound)
	self.selEvent = nil
	self.unSelEvent = nil
	self.items = items
	if textsInfo then 
		self.texts = textsInfo.texts
		self.textSize = textsInfo.size
		self.textColor = textsInfo.color
		self.textFont = textsInfo.font or FONT_COMMON
	end
	self.curHighlighted = nil
	self.selectedItem = nil
	self.lastItem = nil
	self.sound = sound or music_info.COMMON_BUTTON.res
	self.direction = direction or DIRECTION_HORIZON
	for k, v in pairs(self.items) do
		--文字标签位置
		if self.texts ~= nil then 
			v.labelpos = ccp(v:getContentSize().width/2, v:getContentSize().height/2)		
			v.label = createBMFont({text = self.texts[k], x = v.labelpos.x, y = v.labelpos.y, size = self.size, font = self.font, color = self.color})		
			v:addChild(v.label)
		end
		v:registerScriptTapHandler(function()
			audioExt.playEffect(self.sound)
			if self.texts then
				if self.lastItem and self.lastItem.label then
					self.lastItem.label:setPosition(self.lastItem.labelpos.x, self.lastItem.labelpos.y)
					self.lastItem.label:setOpacity(128)
				end
				
				if self.direction == DIRECTION_HORIZONTAL and v.label ~= nil then 
					v.label:setPosition(v.labelpos.x, v.labelpos.y + 3)
					v.label:setOpacity(255)
				elseif self.direction == DIRECTION_VERTICAL then 
					v.label:setPosition(v.labelpos.x + 3, v.labelpos.y)
					v.label:setOpacity(255)
				end
			end
			
			self:setSelectedItem(v, self.lastItem)		
		end
	)
	end
end

function RadioButton:addSeletedEvent(func) -- func prototype: function xxx(selectedItem)  end 
	self.selEvent = func
end

function RadioButton:addUnSeletedEvent(func)
	self.unSelEvent = func
end

function RadioButton:setSelectedItem(item)
	item:selected()
	if self.selectedItem and item == self.selectedItem then return end
 	-- 是否重新触发选择事件
	if self.selectedItem ~= nil and item ~= self.selectedItem then
		self.selectedItem:unselected()
		if self.unSelEvent then
			self.unSelEvent(self.selectedItem)
		end
	end
	self.selectedItem = item
	if self.selEvent then
		self.selEvent(item, self.lastItem)
	end
	self.lastItem = item
end

function RadioButton:clearSelectedItem()
	self.selectedItem:unselected()
	if self.unSelEvent then
		self.unSelEvent(self.selectedItem)
	end
end

function RadioButton:getSelectedItem()
	return self.selectedItem
end


return RadioButton
