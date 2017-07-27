-- 修改自 framework.client.ui

local ui = {}

ui.USE_PLIST = false   -- 是否开启plist 文件读取， false 直接文件读取的

ui.COLOR_WHITE = ccc3(255, 255, 255)
ui.COLOR_BLACK = ccc3(0, 0, 0)

ui.DEFAULT_TTF_FONT      = "Arial"
ui.DEFAULT_TTF_FONT_SIZE = 14

ui.TEXT_ALIGN_LEFT    = kCCTextAlignmentLeft
ui.TEXT_ALIGN_CENTER  = kCCTextAlignmentCenter
ui.TEXT_ALIGN_RIGHT   = kCCTextAlignmentRight
ui.TEXT_VALIGN_TOP    = kCCVerticalTextAlignmentTop
ui.TEXT_VALIGN_CENTER = kCCVerticalTextAlignmentCenter
ui.TEXT_VALIGN_BOTTOM = kCCVerticalTextAlignmentBottom

function ui.setUsePlist(useplist) --是否开启plist
	if useplist == true then
		ui.USE_PLIST = true
	else
		ui.USE_PLIST = false
	end
end

-- create menu
function ui.newMenu(items)
    local menu = CCMenu:create()
	if  type(items) == "table" then
		for k, item in pairs(items) do
			if not tolua.isnull(item) then
				menu:addChild(item, 0, item:getTag())
			end
		end
	else
		if not tolua.isnull(items) then
			menu:addChild(items, 0, items:getTag())
		end
	end
    menu:setPosition(0, 0)
    return menu
end

--create imagemenuitem

function ui.newImageMenuItem(params)
    local imageNormal   = params.image
    local imageSelected = params.imageSelected
    local imageDisabled = params.imageDisabled
    local listener      = params.listener
    local tag           = params.tag or 0
    local x             = params.x 
    local y             = params.y 
	local sound         = params.sound

    if type(imageNormal) == "string" then
        imageNormal = display.newSprite(imageNormal)
    end
    if type(imageSelected) == "string" then
        imageSelected = display.newSprite(imageSelected)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newSprite(imageDisabled)
    end

	-- 增加 imagebutton 的点击效果
	if not imageSelected and imageNormal then
		imageSelected = display.newSprite(params.image)
		imageSelected:setOpacity(180)
	end
	
    local item = CCMenuItemSprite:create(imageNormal, imageSelected, imageDisabled)
    if item then
        CCNodeExtend.extend(item)
        if type(listener) == "function" then
            item:registerScriptTapHandler(function(tag)
                if sound then audio.playSound(sound) end
                listener(tag)
            end)
        end
        if x and y then item:setPosition(x, y) end
        if tag then item:setTag(tag) end
    end
    return item
end

-- create ttfmenuitem
function ui.newTTFLabelMenuItem(params)
    local label    = ui.newTTFLabel(params)
    local listener = params.listener
    local tag      = params.tag
    local x        = params.x
    local y        = params.y

    local item = CCMenuItemLabel:create(label)
    if item then
        if type(listener) == "function" then
            item:registerScriptTapHandler(function(tag)
                listener(tag)
            end)
        end
        if x and y then item:setPosition(x, y) end
        if tag then item:setTag(tag) end
    end
    return item
end


function ui.newBMFontLabel(params)
    assert(type(params) == "table", "ui newBMFontLabel() invalid params")

    local text      = tostring(params.text)
    local font      = params.font
    local textAlign = params.align or ui.TEXT_ALIGN_CENTER
    local x, y      = params.x, params.y
    assert(font ~= nil, "ui.newBMFontLabel() - not set font")

    local label = CCLabelBMFont:create(text, font, kCCLabelAutomaticWidth, textAlign)
    if not label then return end
	
    if type(x) == "number" and type(y) == "number" then
        label:setPosition(x, y)
    end
	
	if textAlign == ui.TEXT_ALIGN_LEFT then
        label:align(display.LEFT_CENTER)
    elseif textAlign == ui.TEXT_ALIGN_RIGHT then
        label:align(display.RIGHT_CENTER)
    else
        label:align(display.CENTER)
    end
    return label
end


function ui.newTTFLabel(params)
    assert(type(params) == "table", "ui newTTFLabel() invalid params")
    local text       = tostring(params.text)
    local font       = params.font or ui.DEFAULT_TTF_FONT
    local size       = params.size or ui.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or ui.COLOR_WHITE
    local textAlign  = params.align or ui.TEXT_ALIGN_LEFT
    local textValign = params.valign or ui.TEXT_VALIGN_CENTER
    local x          = params.x or 0
    local y          = params.y or 0
    local dimensions = params.dimensions
    assert(type(size) == "number","ui newTTFLabel() invalid params.size")

    local label 
    if dimensions then
        label = CCLabelTTF:create(text, font, size, dimensions, textAlign, textValign)
    else
        label = CCLabelTTF:create(text, font, size)
    end
	label:setPosition(x, y)
	label:setColor(color)
    return label
end

function ui.newTTFLabelWithShadow(params)
    assert(type(params) == "table","newTTFLabelWithShadow() invalid params")

    local color       = params.color or display.COLOR_WHITE
    local shadowColor = params.shadowColor or display.COLOR_BLACK
    local x, y        = params.x, params.y

    local g = display.newNode()
    params.size = params.size
    params.color = shadowColor
    params.x, params.y = 0, 0
    g.shadow1 = ui.newTTFLabel(params)
    local offset = 1 / (display.widthInPixels / display.width)
    g.shadow1:realign(offset, -offset)
    g:addChild(g.shadow1)

    params.color = color
    g.label = ui.newTTFLabel(params)
    g.label:realign(0, 0)
    g:addChild(g.label)

    function g:setString(text)
        g.shadow1:setString(text)
        g.label:setString(text)
    end

    function g:realign(x, y)
        g:setPosition(x, y)
    end

    function g:getContentSize()
        return g.label:getContentSize()
    end

    function g:setColor(...)
        g.label:setColor(...)
    end

    function g:setShadowColor(...)
        g.shadow1:setColor(...)
    end

    function g:setOpacity(opacity)
        g.label:setOpacity(opacity)
        g.shadow1:setOpacity(opacity)
    end
    if x and y then
        g:setPosition(x, y)
        g:pixels()
    end
    return g
end


function ui.newTTFLabelWithOutline(params)
    assert(type(params) == "table","newTTFLabelWithShadow() invalid params")

    local color        = params.color or display.COLOR_WHITE
    local outlineColor = params.outlineColor or display.COLOR_BLACK
    local x, y         = params.x, params.y

    local g = display.newNode()
    params.size  = params.size
    params.color = outlineColor
    params.x, params.y = 0, 0
    g.shadow1 = ui.newTTFLabel(params)
    g.shadow1:realign(1, 0)
    g:addChild(g.shadow1)
    g.shadow2 = ui.newTTFLabel(params)
    g.shadow2:realign(-1, 0)
    g:addChild(g.shadow2)
    g.shadow3 = ui.newTTFLabel(params)
    g.shadow3:realign(0, -1)
    g:addChild(g.shadow3)
    g.shadow4 = ui.newTTFLabel(params)
    g.shadow4:realign(0, 1)
    g:addChild(g.shadow4)

    params.color = color
    g.label = ui.newTTFLabel(params)
    g.label:realign(0, 0)
    g:addChild(g.label)

    function g:setString(text)
        g.shadow1:setString(text)
        g.shadow2:setString(text)
        g.shadow3:setString(text)
        g.shadow4:setString(text)
        g.label:setString(text)
    end

    function g:getContentSize()
        return g.label:getContentSize()
    end

    function g:setColor(...)
        g.label:setColor(...)
    end

    function g:setOutlineColor(...)
        g.shadow1:setColor(...)
        g.shadow2:setColor(...)
        g.shadow3:setColor(...)
        g.shadow4:setColor(...)
    end

    function g:setOpacity(opacity)
        g.label:setOpacity(opacity)
        g.shadow1:setOpacity(opacity)
        g.shadow2:setOpacity(opacity)
        g.shadow3:setOpacity(opacity)
        g.shadow4:setOpacity(opacity)
    end

    if x and y then
        g:setPosition(x, y)
        g:pixels()
    end
    return g
end

--------------------------------------------------------------------

function ui.newImage(params)

    assert(type(params) == "table", "ui newImage invalid params")
	local x          = params.x or 0
	local y          = params.y or 0
	local width      = params.width or 0
	local height     = params.height or 0
	local visible    = params.visible or true
	local scaleX     = params.scaleX or 1.0
	local imageRes   = params.image

	local sprite = display.newSprite(imageRes)
    assert(sprite, "ui newImage invalid params")
    sprite:setPosition(x, y)
	sprite:setScaleX(scaleX)
	sprite:setVisible(visible)
	if width ~= 0 and height ~=0 then 
		sprite:setScaleX(width/sprite:getContentSize().width)
		sprite:setScaleY(height/sprite:getContentSize().height)
	end
    return sprite
end

function ui.newPanel(params)
    assert(type(params) == "table", "ui newPanel invalid params")
	local x          = params.x or 0
	local y          = params.y or 0
	local width      = params.width or 0
	local height     = params.height or 0
	local imageRes   = params.image
	local alpha      = params.alpha or 255
	
	local panel
	
	if imageRes then	
		if ui.USE_PLIST then
            panel = CCScale9Sprite:createWithSpriteFrame(convertResources(imageRes))
		else
			panel = CCScale9Sprite:create(imageRes) 
		end
	else 
		panel = display.newSprite()
	end
    assert(panel, "ui newPanel invalid params")
	if width ~= 0 and height ~=0 then 
		panel:setContentSize(CCSize(width, height))
	end	
    panel:setPosition(x, y)
	panel:setOpacity(alpha)
    return panel
end


function ui.newProgressTimer(params)
	assert(type(params) == "table", "ui newProgressTimer invalid params")
	local x          = params.x or 0
	local y          = params.y or 0
	local dir        = params.dir or 0  -- 0左到右 ，1右到左，2下到上 , 3上到下 
	local barX       = params.barX or 0
	local barY       = params.barY or 0
	local types      = params.types or kCCProgressTimerTypeBar --默认是条形进度条
	local imageRes   = params.image
	
	local sprite = display.newSprite(imageRes)
	assert(sprite, "ui newProgressTimer invalid params")
	local pross = CCProgressTimer:create(sprite)
	pross:setType(types)       --样式
	--pross:setPosition()
	if types == kCCProgressTimerTypeBar then
		if dir == 0 then  -- 水平
			pross:setMidpoint(ccp(0,1))
			pross:setBarChangeRate(ccp(1,0))
		elseif dir == 1 then
			pross:setMidpoint(ccp(1,0))
			pross:setBarChangeRate(ccp(1,0))
			
		elseif dir == 2 then --垂直
			pross:setMidpoint(ccp(0,1))
			pross:setBarChangeRate(ccp(0,1))
		elseif dir == 3 then
			pross:setMidpoint(ccp(1,0))
			pross:setBarChangeRate(ccp(0,1))
		end	
		pross:setPercentage(50)	 --初始化
		
	else  --扇形
		pross:setPercentage(50)
	end
	
	return pross
end


function ui.newEditBox(params)
    assert(type(params) == "table", "ui newEditBox invalid params")
	local imageBg       = params.image
	local x             = params.x 
	local y             = params.y 
	local width         = params.width
	local height        = params.height
	local password      = params.password or false
	local text          = params.text or ""
	local textColor     = params.textColor or ui.COLOR_WHITE
	local maxLength     = params.maxChars 
	
	local editBoxBg
	if ui.USE_PLIST then
		local frame = display.newSpriteFrame(convertResources(imageBg))
		editBoxBg = CCScale9Sprite:createWithSpriteFrame(frame)
	else
		editBoxBg = CCScale9Sprite:create(imageBg)
	end

	local editBox = CCEditBox:create(CCSize(width, height), editBoxBg)
	
	editBox:setPlaceHolder(text)     --默认
	editBox:setFontColor(textColor)
	if maxLength then 
		editBox:setMaxLength(maxLength)
	end
	
	if x and y then
		editBox:setPosition(ccp(x,y))
	end
	
	if password == true then
		editBox:setInputFlag(kEditBoxInputFlagPassword) --密码形式
	end
		
	return editBox
end



return ui

