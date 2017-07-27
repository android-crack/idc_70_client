--2016/10/24
--create by wmh0497
--页面按钮

local ClsViewButton = class("ClsViewButton", function()
    local node = display.newNode()
    require("framework.api.EventProtocol").extend(node)
    return node
end)

--[[
参数
x,y
sound
scale
image
imageSelected
imageDisabled == "" 用 image 的灰白图， imageDisabled == "#xxx.png" 则用它自己 --]]
function ClsViewButton:ctor(item)
	self.m_is_enabled = true
	self.m_is_select = false
	self.m_scale_spr = nil
	self.m_btn_sound = nil
	self.m_remove_callback = nil
	self.m_touch_callback = nil
	self.m_is_touch_enable = true
	self.m_is_accapt_touch_callback = nil
	self:initBtn(item)

	self:registerScriptHandler(function(event)
		if event == "exit" then
			if type(self.m_remove_callback) == "function" then
				self.m_remove_callback()
			end
		end
	end)
end

function ClsViewButton:setButtonOpacity(num)
    self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)
    self.m_scale_spr:setCascadeColorEnabled(true)
    self.m_scale_spr:setCascadeOpacityEnabled(true)
    self:setOpacity(num)
end

function ClsViewButton:initBtn(item)
    if item.x and item.y then
        self:setPosition(ccp(item.x,item.y))
    end
    self.m_select_scale = item.selectScale
    self.m_scale_spr = display.newSprite()
    self:addChild(self.m_scale_spr)
    if item.image then
        self.m_normal_spr = display.newSprite(item.image)
    else
        if item.labelNode then
            self.m_normal_lab = item.labelNode
            self.m_normal_spr = item.labelNode
        else
            self.m_normal_spr = CCSprite:create()
        end
    end
    if tolua.isnull(self.m_normal_spr) then
        return
    end

    self.m_normal_spr:setPosition(ccp(0, 0))
    self.m_scale_spr:addChild(self.m_normal_spr)
    
    local size = self.m_normal_spr:getContentSize()
    self.m_touch_width = size.width    -- 触摸宽高
    self.m_touch_height = size.height
    self:setContentSize(size)
    
    self.m_btn_sound = item.sound
    if item.imageSelected ~= nil and item.imageSelected ~= "" then
        self.m_select_spr = display.newSprite(item.imageSelected, 0, 0)
        self.m_scale_spr:addChild(self.m_select_spr)
        self.m_select_spr:setVisible(false)
    end 

    -- imageDisabled == "" 用 image 的灰白图， imageDisabled == "#xxx.png" 则用它自己
    if item.imageDisabled then
        if #item.imageDisabled > 0 then
            self.m_disable_spr = display.newSprite(item.imageDisabled)
        else
            if string.byte(item.image) == 35 then -- first char is #
                self.m_disable_spr = CCGraySprite:createWithSpriteFrameName(string.sub(item.image, 2))
            else
                self.m_disable_spr = CCGraySprite:create(item.image)
            end 
            self.m_disable_spr:setNormal(false)
        end
        self.m_disable_spr:setPosition(ccp(0, 0))
        self.m_scale_spr:addChild(self.m_disable_spr)
        self.m_disable_spr:setVisible(false)
    end

    --添加文本框
    if item.text and item.image then
        self:createTitleLabel(item)
    end
    
    self:setBtnSprScale(item.scale or 1)
end

--创建文本框
function ClsViewButton:createTitleLabel(item)
    local target_spr = self.m_normal_spr
    if nil == target_spr then return end

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
    self.m_title_label = createBMFont({text = ftext, size = fsize, x = fx,y = fy, color = fcolor, anchor = fanchor, opacity = fopacity})
    self.m_title_label:setScale(fscale)
    self.m_title_label.fpading = fpading
    self.m_title_label.ignore_auto_scale = ignore_auto_scale
    self.m_scale_spr:addChild(self.m_title_label, ftag, ftag)
    self:fillBtnSize()
end

--自适应缩小的函数缩
function ClsViewButton:fillBtnSize()
    local target_spr = self.m_normal_spr
    if nil == target_spr then return end
    if nil == self.m_title_label then return end
    if self.m_title_label.ignore_auto_scale then return end
    fillLabelSize(target_spr, self.m_title_label,self.m_title_label.fpading)
end

--获取显示label
function ClsViewButton:getTitleLabel()
    return self.m_title_label
end

--设置显示内容并自动缩放适应
function ClsViewButton:setTitleText(text_str, items)
    if items and "table" == type(items) then
        if self.m_title_label then
            self.m_title_label:removeFromParentAndCleanup(true)
            self.m_title_label = nil
        end
        items.text = text_str
        self:createTitleLabel(items)
    else
        self.m_title_label:setString(text_str)
        self:fillBtnSize()
    end
end

function ClsViewButton:setRemoveCallback(callback)
	self.m_remove_callback = callback
end

function ClsViewButton:setIsAcceptTouchCallback(callback)
	self.m_is_accapt_touch_callback = callback
end

function ClsViewButton:getContentSize()
    return self.m_normal_spr:getContentSize()
end

function ClsViewButton:getNormalImageSpr()
    return self.m_normal_spr
end

function ClsViewButton:regCallBack(listener)
    self:unregCallBack()
    self.m_touch_callback = listener
end

function ClsViewButton:unregCallBack()
    self.m_touch_callback = nil
end

function ClsViewButton:setSelected(is_select)
    if not self.m_is_enabled then
        is_select = false
    end
    if is_select ~= self.m_is_select then
        self.m_is_select = is_select
        if self.m_normal_spr then
            self.m_normal_spr:setVisible(false)
        end
        if self.m_select_spr then
            self.m_select_spr:setVisible(true)
        else
            self.m_normal_spr:setVisible(true)
        end
        if is_select then
            self.m_scale_spr:setScale(self.m_select_scale or 0.9)
        else
            self.m_scale_spr:setScale(1)
        end
    end
end

function ClsViewButton:isSelected()
    return self.m_is_select
end

function ClsViewButton:activate()
    if tolua.isnull(self) then return end

    if self.m_is_enabled and self:isVisible() then --第三个参数表示不可见但是可以接收事件
        if self.m_btn_sound then
            audioExt.playEffect(self.m_btn_sound)
        end
        self:touchEndEvent()
    end
end

function ClsViewButton:setEnabled(is_touch)
    if self.m_is_enabled ~= is_touch then
        self.m_is_enabled = is_touch
        if (not value) and self:isSelected() then 
            self:setSelected(false)
        end
        if is_touch then
            if not tolua.isnull(self.m_normal_spr) then self.m_normal_spr:setVisible(true) end
            if not tolua.isnull(self.m_select_spr) then  self.m_select_spr:setVisible(false) end
            if not tolua.isnull(self.m_disable_spr) then self.m_disable_spr:setVisible(false) end
        elseif tolua.isnull(self.m_normal_lab) then
            if not tolua.isnull(self.m_normal_spr) then self.m_normal_spr:setVisible(false) end
            if not tolua.isnull(self.m_select_spr) then  self.m_select_spr:setVisible(false) end
            if not tolua.isnull(self.m_disable_spr) then self.m_disable_spr:setVisible(true) end
        end
    end
end

function ClsViewButton:isEnabled(is_touch)
    return self.m_is_enabled
end

function ClsViewButton:setTouchEnabled(is_touch)
	self.m_is_touch_enable = is_touch
end

function ClsViewButton:isTouchEnabled()
	return self.m_is_touch_enable
end

function ClsViewButton:setBtnSprScale(scale_n)
    scale_n = scale_n or 1
    if not tolua.isnull(self.m_normal_spr) then self.m_normal_spr:setScale(scale_n) end
    if not tolua.isnull(self.m_select_spr) then  self.m_select_spr:setScale(scale_n) end
    if not tolua.isnull(self.m_disable_spr) then self.m_disable_spr:setScale(scale_n) end
end

function ClsViewButton:touchEndEvent()
    if type(self.m_touch_callback) == "function" then
        self.m_touch_callback()
    end
end


-- self.user_touch_width = width
-- self.touch_height = height
-- self.user_touch_x = x
-- self.user_touch_y = y
function ClsViewButton:touchRect()
    local x, y = self.m_normal_spr:getPosition()
    local scale_x = self.m_normal_spr:getScaleX()
    local scale_y = self.m_normal_spr:getScaleY()
    local anchor_pos = self.m_normal_spr:getAnchorPoint()
    
    local width = self.user_touch_width or (self.m_touch_width * scale_x)
    local height = self.user_touch_height or (self.m_touch_height * scale_y)
    local touch_x = self.user_touch_x or (x - width * scale_x * anchor_pos.x)
    local touch_y = self.user_touch_y or (y - height * scale_y * anchor_pos.y)
    local touch_rect = CCRect(touch_x, touch_y, width, height)
    return touch_rect
end

function ClsViewButton:onTouch(event, x, y)
    local pos = self:convertToNodeSpace(ccp(x,y))
    if event == "began" then
        return self:onTouchBegan(pos.x, pos.y)
    elseif event == "moved" then
        self:onTouchMoved(pos.x, pos.y)
    elseif event == "ended" then
        self:onTouchEnded(pos.x, pos.y)
    else -- cancelled
        self:onTouchCancelled(pos.x, pos.y)
    end
end

function ClsViewButton:onTouchBegan(x, y)
	if not self.m_is_enabled or not self:isVisible() or not self:isTouchEnabled() then
		return false
	end
	if self.m_is_accapt_touch_callback then
		if not self.m_is_accapt_touch_callback() then
			return false
		end
	end
	if self:touchRect():containsPoint(ccp(x,y)) then
		self:setSelected(true)
		return true
	end
	return false
end

function ClsViewButton:onTouchMoved(x, y)
    if self:isSelected() and (not self:touchRect():containsPoint(ccp(x,y))) then
        self:setSelected(false)
    end
end

function ClsViewButton:onTouchEnded(x, y)
    if self:isSelected() then
        self:setSelected(false)
        self:activate()
    end
end

function ClsViewButton:onTouchCancelled(x, y)
    if self:isSelected() then
        self:setSelected(false)
    end
end

function ClsViewButton:setTouchRect(width, height, x, y)  -- 设置触摸的宽高，默认是图片的宽高
    local boolValue = width and height
    if boolValue then
        self.user_touch_width = width
        self.user_touch_height = height
        self.user_touch_x = x
        self.user_touch_y = y
    end
end

return ClsViewButton