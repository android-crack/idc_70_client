--  重写menu,实现按钮效果
local music_info=require("game_config/music_info")

MyMenuItem = class("MyMenuItem", function()
	local node = display.newNode()
	require("framework.api.EventProtocol").extend(node)
	return node
end)

-- 添加字体的设置 text = "6666", fontFile = FONT_COMMON, scale = 2, fsize = 20, fx = 10, fy = -10 , fcolor = 
MyMenuItem.ctor = function(self, item)
	if item.isNeedVoiceEffect == nil then
		self.isNeedVoiceEffect = true
	else
		self.isNeedVoiceEffect = item.isNeedVoiceEffect
	end
	self.m_bEnabled = true
	self.m_bIsSelected = false
	self.not_run_most_func = false --设置成false时不走按钮功能流程
	if item.x and item.y then
		self:setPosition(ccp(item.x,item.y))
	end
	item.scale = item.scale or 1
	item.scaleX = item.scaleX
	item.scaleY = item.scaleY

	self.select_label_color = item.select_color
	self.fcolor = item.fcolor
	if item.image then
		self.m_pNormalImage = display.newSprite(item.image)
	else
		if item.labelNode then
			self.labelNode = item.labelNode
			self.m_pNormalImage = item.labelNode
		else
			self.m_pNormalImage = CCSprite:create()
		end
	end
	if tolua.isnull(self.m_pNormalImage) then --TODO self.m_pNormalImage 如果为空就返回
		return
	end
	--选中图片比正常图片大
	if item.select_big then
		self.select_big = true
	end

	if item.effect == nil then
		self.isEffect = true
	else
		self.isEffect = item.effect
	end
	if item.selectScale == nil then
		self.selectScale = 0.9
	else
		self.selectScale = item.selectScale
	end

	if item.unSelectScale == nil then
		self.unSelectScale = 1.0
	else
		self.unSelectScale = item.unSelectScale
	end

	if item.selectCallBack then
		self.selectCallBack = item.selectCallBack --在selected函数里调用
	end

	if item.unSelectCallBack then
		self.unSelectCallBack = item.unSelectCallBack --在selected函数里调用
	end

	if item.nonAcceptTouchEventCallBack then
		self.nonAcceptTouchEventCallBack = item.nonAcceptTouchEventCallBack
	end

	self.select_call_back_parameters = item.selectCallBackParameters or {}
	self.unselect_call_back_parameters = item.unselectCallBackParameters or {}
	if item.isAudio == nil then
		self.isAudio = true
	else
		self.isAudio= item.isAudio
	end

	if item.labelNode == nil then
		self.m_pNormalImage:setScale(item.scale)
		if item.scaleX then
			self.m_pNormalImage:setScaleX(item.scaleX)
		end
		if item.scaleY then
			self.m_pNormalImage:setScaleY(item.scaleY)
		end
	end

	if item.batchRender then
		self.imageParent = item.batchRender
		self.imageX = item.x
		self.imageY = item.y
	else
		self.imageParent = self
		self.imageX = 0
		self.imageY = 0
	end

	self.m_pNormalImage:setPosition(ccp(self.imageX, self.imageY))
	self.imageParent:addChild(self.m_pNormalImage)
	
	self.size = self.m_pNormalImage:getContentSize()
	self.size.width = self.size.width * item.scale
	if item.scaleX then
		self.size.width = self.size.width * item.scaleX
	end
	self.size.height = self.size.height * item.scale
	if item.scaleY then
		self.size.height = self.size.height * item.scaleY
	end
	self.touch_width = self.size.width    -- 触摸宽高
	self.touch_height = self.size.height
	self:setContentSize(self.size)
	self.strMark = item.strMark or ""
	self.sound = item.sound or music_info.COMMON_BUTTON.res
	if item.imageSelected~=nil and item.imageSelected~="" then
		self.m_pSelectedImage = display.newSprite(item.imageSelected)
		self.m_pSelectedImage:setScale(item.scale)
		if item.scaleX then
			self.m_pSelectedImage:setScaleX(item.scaleX)
		end
		if item.scaleY then
			self.m_pSelectedImage:setScaleY(item.scaleY)
		end
		self.m_pSelectedImage:setPosition(ccp(self.imageX, self.imageY))
		self.imageParent:addChild(self.m_pSelectedImage)
		self.m_pSelectedImage:setVisible(false)
	end 
	
	-- imageDisabled == "" 用 image 的灰白图， imageDisabled == "#xxx.png" 则用它自己
	if item.imageDisabled then
		if #item.imageDisabled > 0 then
			self.m_pDisabledImage = display.newSprite(item.imageDisabled)
		else
			if string.byte(item.image) == 35 then -- first char is #
				self.m_pDisabledImage = CCGraySprite:createWithSpriteFrameName(string.sub(item.image, 2))
			else
				self.m_pDisabledImage = CCGraySprite:create(item.image)
			end 
			self.m_pDisabledImage:setNormal(false)
		end
		self.m_pDisabledImage:setPosition(ccp(self.imageX, self.imageY))
		self.imageParent:addChild(self.m_pDisabledImage)
		self.m_pDisabledImage:setVisible(false)
		if item.labelNode == nil then
			self.m_pDisabledImage:setScale(item.scale)
			if item.scaleX then
				self.m_pDisabledImage:setScaleX(item.scaleX)
			end
			if item.scaleY then
				self.m_pDisabledImage:setScaleY(item.scaleY)
			end
		end
	end
	
	--添加文本框
	if item.text and item.image then
		self:createTitleLabel(item)
	end

	self:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
end

--创建文本框
MyMenuItem.createTitleLabel = function(self, item)
	local target_spr = self.m_pNormalImage
	if nil == target_spr then return end
	
	local font = item.fontFile or FONT_COMMON
	local fsize = item.fsize or 18
	local fx = item.fx or 0
	local fy = item.fy or 2
	local fcolor = item.fcolor
	local ftext = item.text or 0
	local fpading = item.fpading or 8
	local ftag = item.ftag or 2
    local fanchor = item.fanchor
    local fopacity = item.fopacity
    local fscale = item.fscale or 1
    local ignore_auto_scale = item.ignoreAuto or false
	self.m_title_label = createBMFont({text = ftext, fontFile = font,size = fsize, x = fx,y = fy, color = fcolor, anchor = fanchor, opacity = fopacity})
	self.m_title_label:setScale(fscale)
    self.m_title_label.fpading = fpading
    self.m_title_label.ignore_auto_scale = ignore_auto_scale
	self:addChild(self.m_title_label, ftag, ftag)
    self:fillBtnSize()
end

--自适应缩小的函数缩
MyMenuItem.fillBtnSize = function(self)
    local target_spr = self.m_pNormalImage
    if nil == target_spr then return end
    if nil == self.m_title_label then return end
    if self.m_title_label.ignore_auto_scale then return end
    fillLabelSize(target_spr, self.m_title_label,self.m_title_label.fpading)
end

--获取显示label
MyMenuItem.getTitleLabel = function(self)
    return self.m_title_label
end

--设置显示内容并自动缩放适应
MyMenuItem.setTitleText = function(self, text_str, items)
    if items and "table" == type(items) then
        if self.m_title_label then
            self.m_title_label:removeFromParentAndCleanup(true)
            self.m_title_label = nil
        end
        items.text  = text_str
        self:createTitleLabel(items)
    else
        self.m_title_label:setString(text_str)
        self:fillBtnSize()
    end
end

MyMenuItem.setAllAnchorPoint = function(self, x, y)
	if self.m_pNormalImage then
		self.m_pNormalImage:setAnchorPoint(ccp(x, y))
	end
	if self.m_pSelectedImage then
		self.m_pSelectedImage:setAnchorPoint(ccp(x, y))
	end
	if self.m_pDisabledImage then
		self.m_pDisabledImage:setAnchorPoint(ccp(x, y))
	end
end

MyMenuItem.getContentSize = function(self)
	return self.m_pNormalImage:getContentSize()
end

MyMenuItem.getNormalImageSpr = function(self)
    return self.m_pNormalImage
end

MyMenuItem.isEnabled = function(self)
	return self.m_bEnabled
end

MyMenuItem.setNodeSize = function(self, size)
	self.size = size
	self.touch_width = size.width    -- 触摸宽高
	self.touch_height = size.height
	self:setContentSize(size)
end

--设置是否接收事件(伴随显示变化)
MyMenuItem.setEnabled = function(self, value)
	if tolua.isnull(self) then return end
	if self.m_bEnabled ~= value then
		--处理点击之后又被设置为不可点后的处理
		if (self.m_bIsSelected) and (not value) and (self.m_bEnabled) then
			self.m_bIsSelected = false
			if self.isEffect then
				self:setScale(self.unSelectScale)
			end
		end
		self.m_bEnabled = value
		self:updateImages()
	end
end

--设置接收事件但是走其他逻辑
MyMenuItem.setNotRunMostFuncEvent = function(self, enable)
	print("调用了-----------------------------", enable)
	self.not_run_most_func = enable
end

MyMenuItem.getNotRunMostFuncEvent = function(self)
	return self.not_run_most_func
end

MyMenuItem.regNonAcceptTouchEventCallBack = function(self, call_back)
	self.nonAcceptTouchEventCallBack = call_back
end

MyMenuItem.activeNonAcceptTouchEventCallBack = function(self)
	if type(self.nonAcceptTouchEventCallBack) == "function" then
		self.nonAcceptTouchEventCallBack()
	end
end

MyMenuItem.setEnabledAndNoChange = function(self, value)
	if tolua.isnull(self) then return end
	if self.m_bEnabled ~= value then
		self.m_bEnabled = value
	end
end

MyMenuItem.setFocused = function(self) --取得焦点的时候这个时候不可以点击
	self.m_bEnabled = false
	if self.m_pNormalImage  then self.m_pNormalImage:setVisible(false) end
	if self.m_pSelectedImage then  self.m_pSelectedImage:setVisible(true) end
	if self.m_pDisabledImage then self.m_pDisabledImage:setVisible(false) end
end

MyMenuItem.touchRect = function(self)
	local x, y = self:getPosition()
	local anchorPoint = self.m_pNormalImage:getAnchorPoint()
	local touch_x = self.touch_x or (x-self.touch_width * anchorPoint.x)
	local touch_y = self.touch_y or (y-self.touch_height * anchorPoint.y)
	local touchRect = CCRect(touch_x, touch_y, self.touch_width, self.touch_height)
	return touchRect
end

MyMenuItem.setTouchRect = function(self, width, height, x, y)  -- 设置触摸的宽高，默认是图片的宽高
	local boolValue = width and height
	if boolValue then
		self.touch_width = width
		self.touch_height = height
		self.touch_x = x
		self.touch_y = y
	end
end

MyMenuItem.selected = function(self)
	self.m_bIsSelected = true
	if not tolua.isnull(self.m_pNormalImage) and self.m_bEnabled then
		if self.m_pDisabledImage then
			self.m_pDisabledImage:setVisible(false)
		end
		if self.m_pSelectedImage and not self.select_big then
			self.m_pSelectedImage:setVisible(true)
		else
			self.m_pNormalImage:setVisible(true)
		end
		if self.isEffect then
			self:setScale(self.selectScale)
		end
		if type(self.selectCallBack) == "function" then
			self.selectCallBack(unpack(self.select_call_back_parameters))
		end
	end
	if not tolua.isnull(self.m_title_label) and self.select_label_color then
		self.m_title_label:setColor(self.select_label_color)
	end
end

MyMenuItem.isSelected = function(self)
	return self.m_bIsSelected
end

MyMenuItem.unselected = function(self)
	self.m_bIsSelected = false
	if not tolua.isnull(self.m_pNormalImage) and self.m_bEnabled then
		if not tolua.isnull(self.m_pDisabledImage) then
			self.m_pDisabledImage:setVisible(false)
		end
		if not tolua.isnull(self.m_pSelectedImage) then
			self.m_pSelectedImage:setVisible(false)
		end
		self.m_pNormalImage:setVisible(true)
		if self.isEffect then
			self:setScale(self.unSelectScale)
		end
		if self.unSelectCallBack and type(self.unSelectCallBack) == "function" then
			self.unSelectCallBack(unpack(self.unselect_call_back_parameters))
		end
	end

	if not tolua.isnull(self.m_title_label) and self.fcolor then
		self.m_title_label:setColor(self.fcolor)
	end
end

MyMenuItem.activate = function(self, is_mute)
	if not self or tolua.isnull(self) then return end

	if self.m_bEnabled and (self:isVisible() or self.not_visible_but_touch) then --第三个参数表示不可见但是可以接收事件
		if  self.sound ~= nil then
		  	if #self.sound ~= 0 and not is_mute then
				if self.isAudio and self.isNeedVoiceEffect then
					local res = audioExt.playEffect(self.sound)
				end
		  	end
		end
		self:dispatchEvent({name = "CALL_BACK"})
	end
end

MyMenuItem.touchEndEvent = function(self)
	self:dispatchEvent({name = "CALL_BACK"})
end

MyMenuItem.updateImages = function(self)
	if self.m_bEnabled then
		if self.m_pNormalImage  then self.m_pNormalImage:setVisible(true) end
		if self.m_pSelectedImage then  self.m_pSelectedImage:setVisible(false) end
		if self.m_pDisabledImage then self.m_pDisabledImage:setVisible(false) end
	elseif not self.labelNode then
		if self.m_pNormalImage  then  self.m_pNormalImage:setVisible(false) end
		if self.m_pSelectedImage then  self.m_pSelectedImage:setVisible(false) end
		if self.m_pDisabledImage then self.m_pDisabledImage:setVisible(true) end
	end
end

MyMenuItem.regCallBack = function(self, listener)
	self:unregCallBack()
	self:addEventListener("CALL_BACK", listener)
end

MyMenuItem.unregCallBack = function(self, listener)
	self:removeEventListener("CALL_BACK", listener)
end

MyMenuItem.onExit = function(self)
	self:removeAllEventListeners()
end

MyMenuItem.setNormalImage = function(self, res)
	local _res = string.gsub(res, "#","")
	local frame = display.newSpriteFrame(_res)
	self.m_pNormalImage:setDisplayFrame(frame)
end


MyMenuItem.getStrMark = function(self)
	return self.strMark
end

MyMenuItem.setStrMark = function(self, value)
	self.strMark = value
end

MyMenuItem.setOpacity = function(self, value)
	self.m_pNormalImage:setOpacity(value)
	if self.m_pDisabledImage then
		self.m_pDisabledImage:setOpacity(value)
	end
	if self.m_pSelectedImage then
	   self.m_pSelectedImage:setOpacity(value) 
	end
end

MyMenuItem.getOpacity = function(self)
	return self.m_pNormalImage:getOpacity()
end

MyMenuItem.setDisabledImageOpacity = function(self, value)
	if self.m_pDisabledImage then
		self.m_pDisabledImage:setOpacity(value)
	end
end

MyMenuItem.setFlipX = function(self, value)
	self.m_pNormalImage:setFlipX(value)
	if self.m_pDisabledImage then
		self.m_pDisabledImage:setFlipX(value)
	end
	if self.m_pSelectedImage then
	   self.m_pSelectedImage:setFlipX(value) 
	end
end
MyMenuItem.setFlipY = function(self, value)
	self.m_pNormalImage:setFlipY(value)
	if self.m_pDisabledImage then
		self.m_pDisabledImage:setFlipY(value)
	end
	if self.m_pSelectedImage then
	   self.m_pSelectedImage:setFlipY(value) 
	end
end

MyMenuItem.setVisibleEx = function(self, isVisible)
	self:setVisible(isVisible)
	self.m_pNormalImage:setVisible(isVisible)
	if self.m_pDisabledImage then
		self.m_pDisabledImage:setVisible(isVisible)
	end
	if self.m_pSelectedImage then
	   self.m_pSelectedImage:setVisible(isVisible) 
	end
end