
local CompositeEffect = require("gameobj/composite_effect")
local music_info=require("game_config/music_info")
local ui_word = require("game_config/ui_word")

local UiCommon = {}

function UiCommon:getBgSprite(res,x,y,scale,format)  --获取缩放的背景图精灵
	if format then CCTexture2D:setDefaultAlphaPixelFormat(format) end
	local sprite=display.newSprite(res,x or display.cx,y or display.cy)
	if format then CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"]) end
	sprite.scale=display.width/sprite:getContentSize().width
	sprite:setScale(sprite.scale*(scale or 1))
	return sprite
end

--界面大标题制作
function UiCommon:createSecondUiTitle(parent, text, xOffset, yOffset,res,fontSize,fontFile,color,opacity,zorder)   --只保留左边的资源
	xOffset = xOffset or 0
	yOffset = yOffset or -28
	local zorder = zorder or 0
	local y = display.top  + yOffset
	local x=display.cx + xOffset
    fontSize=fontSize or 20
    local res = res or "#common_figure8.png"
    local labelName
    local userFontFile = fontFile or FONT_TITLE
    local userColor = color or COLOR_CREAM_STROKE
    labelName=createBMFont({text = text, size = fontSize ,fontFile = userFontFile, x = x+2, y = y,color = ccc3(dexToColor3B(userColor))})
	parent.secondUiTitleLabel = labelName
	parent:addChild(labelName,zorder)
	
	local halfWidth=labelName:getScaledContentSize().width/2
	
	local spriteSideLeft= display.newSprite(res, x-halfWidth, y)
	spriteSideLeft:setAnchorPoint(ccp(1,0.5))
	parent:addChild(spriteSideLeft,zorder)

	local spriteSideRight= display.newSprite(res, x+halfWidth+2, y)
	spriteSideRight:setAnchorPoint(ccp(0,0.5))
	spriteSideRight:setFlipX(true)
	parent:addChild(spriteSideRight,zorder)
	
	labelName.setText = function(self,text)
	   labelName:setString(text)
        local halfWidth=labelName:getScaledContentSize().width/2
        spriteSideLeft:setPosition(x-halfWidth, y)
        spriteSideRight:setPosition(x+halfWidth+2, y)
	end
	if opacity then 
		labelName:setOpacity(opacity)
		spriteSideLeft:setOpacity(opacity)
		spriteSideRight:setOpacity(opacity)
	end
    return labelName,spriteSideLeft,spriteSideRight
end

function UiCommon:setSecondUiTitle(parent, text)
	if parent.secondUiTitleLabel == nil then return end
	parent.secondUiTitleLabel:setString(text)
end


-- 数字动态变化效果 开始数字  结束数字
function UiCommon:numberEffect(label, begin_num, end_num, delta, callBackFunc, prefixStr, suffixStr, num_change_func)
	prefixStr = prefixStr or ""
	suffixStr = suffixStr or ""

	if type(label.setString) ~= "function" then
		function label:setString(str)
			label:setText(str)
		end
	end

	local scheduler=CCDirector:sharedDirector():getScheduler()

	if label._num_change_timer_handle then
		scheduler:unscheduleScriptEntry(label._num_change_timer_handle)
		label._num_change_timer_handle = nil
	end

	if begin_num == end_num and not label._num_change_timer_handle then
		label:setString(prefixStr..begin_num..suffixStr)
        if num_change_func and type(num_change_func) == "function" then
            num_change_func(begin_num, end_num)
        end
        if callBackFunc and type(callBackFunc) == "function" then
            callBackFunc()
        end
		return
	end

	delta = delta or 60 
	local dir = (begin_num < end_num) and 1 or -1				--递增或是递减
	local num_interval = math.abs( begin_num - end_num)			--变化区间
	local tick_num = num_interval / delta --用来控制不同变化区间步长相应改变

	--初始控件
	label:setString(prefixStr..begin_num..suffixStr)
    if num_change_func and type(num_change_func) == "function" then
        num_change_func(begin_num, end_num)
    end
	
	local on_tick = function(dt)
		---------------------------------------
		-- modify By Hal 2015-10-30, 内存泄漏 
		-- 既然对象都不存在，触发器也没有存在的必要
		if tolua.isnull(label) then 
			print( "remove ------------------- label._num_change_timer_handle" )
			scheduler:unscheduleScriptEntry( label._num_change_timer_handle )
            label._num_change_timer_handle = nil
			return
		end
		---------------------------------------
		--if tolua.isnull(label) then return end
		begin_num = begin_num + tick_num * dir
		local tempNum = math.floor(begin_num+0.5)
		label:setString(prefixStr..tempNum..suffixStr)
        if num_change_func and type(num_change_func) == "function" then
            num_change_func(tempNum, end_num)
        end
		if dir == 1 and tempNum >= end_num then
			scheduler:unscheduleScriptEntry(label._num_change_timer_handle)
            label._num_change_timer_handle = nil
			label:setString(prefixStr..end_num..suffixStr)
            if num_change_func and type(num_change_func) == "function" then
                num_change_func(tempNum, end_num)
            end
			if type(callBackFunc) == "function" then
				callBackFunc()
			end
		end

		if dir == -1 and tempNum <= end_num then
			scheduler:unscheduleScriptEntry(label._num_change_timer_handle)
            label._num_change_timer_handle = nil
			label:setString(prefixStr..end_num..suffixStr)
            if num_change_func and type(num_change_func) == "function" then
                num_change_func(end_num, end_num)
            end
			if type(callBackFunc) == "function" then
				callBackFunc()
			end
		end
	end
	label._num_change_timer_handle = scheduler:scheduleScriptFunc(on_tick, 0.00012, false)
end

-- 数字动态变化效果 开始数字  结束数字(千位加逗号隔开)
function UiCommon:numberCommaEffect(label, begin_num, end_num, delta)
	local function getAddCommaTxt(number)
		local num_txt = tostring(number)
		if number >= 1000 then
			local kilobit = math.floor(number / 1000)
			local hundreds = string.sub(num_txt, -3)
			num_txt = tostring(kilobit) .. "," .. hundreds
		end
		return num_txt
	end

	if begin_num == end_num then
		label:setString(getAddCommaTxt(begin_num))
		return
	end

	local scheduler = CCDirector:sharedDirector():getScheduler()

	if label._num_change_timer_handle then
		scheduler:unscheduleScriptEntry(label._num_change_timer_handle)
		label._num_change_timer_handle = nil
	end

	delta = delta or 60
	local dir = (begin_num < end_num) and 1 or -1				--递增或是递减
	local num_interval = math.abs( begin_num - end_num)			--变化区间
	local tick_num = math.ceil( num_interval / delta )			--用来控制不同变化区间步长相应改变

	--初始控件
	label:setString(getAddCommaTxt(begin_num))

	local on_tick = function()
		if tolua.isnull(label) then return end
		begin_num = begin_num + tick_num*dir
		label:setString(getAddCommaTxt(begin_num))
		if dir == 1 and begin_num >= end_num then
			scheduler:unscheduleScriptEntry(label._num_change_timer_handle)
			label:setString(getAddCommaTxt(end_num))
		end

		if dir == -1 and begin_num <= end_num then
			scheduler:unscheduleScriptEntry(label._num_change_timer_handle)
			label:setString(getAddCommaTxt(end_num))
		end
	end
	label._num_change_timer_handle = scheduler:scheduleScriptFunc(on_tick, 0.00013, false)
end

function UiCommon:mkLoadingRudder(x, y)
	local nodeRudder = display.newSprite()
	nodeRudder:setCascadeOpacityEnabled(true)
	local rudderAction= CCRotateBy:create(6, 720)
	local rudder = getChangeFormatSprite("ui/loading/loading_helm.png")
	rudder:runAction(CCRepeatForever:create(rudderAction))
	rudder:setPosition(x, y)
	nodeRudder:addChild(rudder)
	rudder:setCascadeOpacityEnabled(true)

	local compassAction = CCRotateBy:create(20, -720)
	local compass = getChangeFormatSprite("ui/loading/loading_helm_bg.png")
	compass:setPosition(x, y)
	compass:runAction(CCRepeatForever:create(compassAction))
	nodeRudder:addChild(compass)
	compass:setCascadeOpacityEnabled(true)

	return nodeRudder
end

function UiCommon:floatRewardEf(start_pt, end_pt, kind, callBackFunc)
	local ef_tab = {
		[TYPE_INFOR_CASH] = "tx_1010.plist", --银币
		[TYPE_INFOR_COLD] = "tx_1011.plist", --金币
		[TYPE_INFOR_HONOUR] = "tx_1013.plist",  --荣誉
		[TYPE_INFOR_POWER] = "tx_1012.plist",  --体力

		}
	local eff_path = "effects/"
	local ef = CCParticleSystemQuad:create(eff_path..ef_tab[kind])
	local angel = Math.getAngle(start_pt.x, start_pt.y, end_pt.x, end_pt.y)
	local distance = Math.distance(start_pt.x, start_pt.y, end_pt.x, end_pt.y)
	ef:setAngle(angel)
	ef:setStartRadius(distance)
	ef:setPosition(end_pt)
	local life_base = 0.0015
	local particles_base = 10
	
	local liftTime = life_base*distance
	
	
	ef:setLife(liftTime)
	--ef:setTotalParticles(particles_base*distance)
	ef:setZOrder(ZORDER_UI_LAYER)
	ef:setAutoRemoveOnFinish(true)
	
	if type(callBackFunc) == "function" then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		local function callFunc()
			scheduler:unscheduleScriptEntry(ef.schedulerTime)
			callBackFunc()
		end
		ef.schedulerTime = scheduler:scheduleScriptFunc(callFunc, liftTime, false)
	end

	return ef
end

function UiCommon:floatRewardEfOnScene(start_pt, end_pt, kind, callBackFunc)
	local eff_spr = self:floatRewardEf(start_pt, end_pt, kind, callBackFunc)
	display.getRunningScene():addChild(eff_spr)
end

function UiCommon:getDelayAction(delay_time_n, callback)
    delay_time_n = delay_time_n or 1
    local ac1 = CCDelayTime:create(delay_time_n)
    local ac2 = CCCallFunc:create(function()
            if callback and type(callback) == "function" then
                callback()
            end
        end)
    return CCSequence:createWithTwoActions(ac1, ac2)
end

function UiCommon:getRepeatAction(cut_time_n, callback)
    cut_time_n = cut_time_n or 1
    local ac1 = CCDelayTime:create(cut_time_n)
    local ac2 = CCCallFunc:create(function()
            if callback and type(callback) == "function" then
                callback()
            end
        end)
    return CCRepeatForever:create(CCSequence:createWithTwoActions(ac1, ac2))
end
return UiCommon
