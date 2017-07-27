
--[[港口按钮特效]]

local CompositeEffect = require("gameobj/composite_effect")
local on_off_info = require("game_config/on_off_info")

local STATUS_TYPE = {
	NEED_OPEN = 1,
	NEED_LOOP = 2,
	NEED_CLOSE = 3,
}

--新航海士解锁(打开相应的按钮特效)
local sailorBtnTable = {
	on_off_info.PORT_HOTEL_ENLIST.value,
}

local buttonStatus = {}

--创建按钮特效
local function createButtonEffect(effectName, target, effectName2, btnAttribute)
	if tolua.isnull(target) then return end
	target.buttonEffect = nil
	
	local function setScale(effect)
		if btnAttribute == nil then return end
		if btnAttribute.scale ~= nil then
			if type(btnAttribute.scale) == "table" then
				effect:setScaleX(btnAttribute.scale[1])
				effect:setScaleY(btnAttribute.scale[2])
			else
				effect:setScale(btnAttribute.scale)
			end
		end
	end
	
	local function setPos(effect)
		if btnAttribute == nil then return end
		if btnAttribute.pos ~= nil then
			effect:setPosition(ccp(btnAttribute.pos[1], btnAttribute.pos[2]))
		end
	end
	
	if effectName2 then
		local btnEffect = CompositeEffect.bollow(effectName, 0, 0, target, 1)
		setScale(btnEffect)
		setPos(btnEffect)
		
		target.buttonEffect = CompositeEffect.new(effectName2, 0, 0, target, 3)
		setScale(target.buttonEffect)
		setPos(target.buttonEffect)
	else
		target.buttonEffect = CompositeEffect.new(effectName, 0, 0, target)
		setScale(target.buttonEffect)
		setPos(target.buttonEffect)
	end	
end

--用于码头中的4个按钮
-- local function squareButtonEffect(target, key, btnAttribute)
-- 	if buttonStatus[key] == STATUS_TYPE.NEED_OPEN then
-- 		createButtonEffect("tx_1014_1", target, "tx_1014", btnAttribute)
-- 		buttonStatus[key] = STATUS_TYPE.NEED_CLOSE
-- 	else
-- 		createButtonEffect("tx_1014", target, nil, btnAttribute)
-- 	end
-- end

--右下角一级按钮中的好友按钮
-- local function circleButtonEffect(target, isFirstOpen, btnAttribute)
	-- if isFirstOpen then
		-- createButtonEffect("tx_1015_1", target, "tx_1015", btnAttribute)
	-- else
		-- createButtonEffect("tx_1015", target, nil, btnAttribute)
	-- end
-- end

--用于较长的长条文字按钮底框
-- local function longButtonEffect(target, isFirstOpen, btnAttribute)
	-- if isFirstOpen then
		-- createButtonEffect("tx_1016_2", target, "tx_1016", btnAttribute)
	-- else
		-- createButtonEffect("tx_1016", target, nil, btnAttribute)
	-- end
-- end

--用于较短的长条文字按钮底框
local function shortButtonEffect(target, isFirstOpen, btnAttribute)	
	if isFirstOpen then
		createButtonEffect("tx_1025", target, "tx_1025_1", btnAttribute)
	else
		createButtonEffect("tx_1025_1", target, nil, btnAttribute)
	end
end

--好友按钮
-- local function friendButtonEffect(target, isFirstOpen, btnAttribute)
	-- if isFirstOpen then
		-- createButtonEffect("tx_1030", target, "tx_1031", btnAttribute)
	-- else
		-- createButtonEffect("tx_1031", target, nil, btnAttribute)
	-- end
-- end

--用于好友界面左侧二级页签开启时
-- local function trapeziformButtonEffect(target, isFirstOpen, btnAttribute)
	-- if isFirstOpen then
		-- createButtonEffect("tx_1017_1", target, "tx_1017", btnAttribute)
	-- else
		-- createButtonEffect("tx_1017", target, nil, btnAttribute)
	-- end
-- end

--用于水手任命开启时
-- local function sailorButtonEffect(target, key, btnAttribute)
	-- if buttonStatus[key] == STATUS_TYPE.NEED_OPEN then
		-- createButtonEffect("tx_1032_1", target, "tx_1032", btnAttribute)
	-- else
		-- createButtonEffect("tx_1032", target, nil, btnAttribute)
	-- end
-- end

--用于港口中的6个建筑按钮
local function runButtonEffect(target, key, buttonEffect)
	if tolua.isnull(target) then return end
	
	-- if buttonStatus[key] == STATUS_TYPE.NEED_LOOP then
		-- buttonEffect(false)
		-- return
	-- end
	
	target:stopAllActions()
	target:setScale(0)

	local callFunc = CCCallFunc:create(function()
		buttonEffect(true)
		local arr=CCArray:create()
		arr:addObject(CCScaleTo:create(0.1, 1.0, 1.0))
		arr:addObject(CCScaleTo:create(0.1, 0.8, 1.0))
		arr:addObject(CCScaleTo:create(0.1, 1.0, 1.0))
		target:runAction(CCSequence:create(arr))
	end)
	
	local act1 = CCSequence:createWithTwoActions(CCDelayTime:create(0.6), CCScaleTo:create(0.3, 0.8, 1.1))
	local act2 = CCSequence:createWithTwoActions(act1, callFunc)
	target:runAction(act2)
	
	buttonStatus[key] = STATUS_TYPE.NEED_CLOSE
end

--开启按钮特效
local function openNewButtonEffect(button, key, isNewOpen, effectType, btnAttribute)
	if isNewOpen and not tolua.isnull(button) then
		
		if effectType == EFFECT_TYPE.SHORT then
			runButtonEffect(button, key, function(isFirstOpen)
				shortButtonEffect(button, isFirstOpen, btnAttribute)
			end)
		-- elseif effectType == EFFECT_TYPE.QUAY then
		-- 	squareButtonEffect(button, key, btnAttribute)
		end
	end
end

--循环播放按钮特效
local function loopButtonEffect(button, key, effectType, btnAttribute)
	if not tolua.isnull(button) then
		if effectType == EFFECT_TYPE.SHORT then
			shortButtonEffect(button, false, btnAttribute)
		-- elseif effectType == EFFECT_TYPE.QUAY then
		-- 	squareButtonEffect(button, key, btnAttribute)
		end
	end
end

-------------------------------外部调用接口----------------------------------------
local ButtonEffectSet = {}

function ButtonEffectSet:playButtonEffect(button, key, effectType, btnAttribute)
--	print("---------------------------->播放按钮特效")
	local btnStatus = buttonStatus[key]
	local isNewOpen = btnStatus ~= nil and btnStatus ~= STATUS_TYPE.NEED_CLOSE
	if not isNewOpen then return end
	if btnStatus == STATUS_TYPE.NEED_OPEN then
		openNewButtonEffect(button, key, isNewOpen, effectType, btnAttribute)
	elseif btnStatus == STATUS_TYPE.NEED_LOOP then
		loopButtonEffect(button, key, effectType, btnAttribute)
	end
end

--关闭按钮特效
function ButtonEffectSet:closeButtonEffect(target, key)
	if tolua.isnull(target) or tolua.isnull(target.buttonEffect) then return end
	target.buttonEffect:clearAll()
	target.buttonEffect = nil
	buttonStatus[key] = STATUS_TYPE.NEED_CLOSE
end

--判断按钮状态
function ButtonEffectSet:isOpenButtonEffect(key)
	local btnStatus = buttonStatus[key]
	local isNewOpen = btnStatus ~= nil and btnStatus ~= STATUS_TYPE.NEED_CLOSE
	return isNewOpen
end

--设置按钮状态
function ButtonEffectSet:setButtonStatus(key, status)
	buttonStatus[key] = status
end

function ButtonEffectSet:openButtonEffectStatus(key)
	buttonStatus[key] = STATUS_TYPE.NEED_OPEN
end

function ButtonEffectSet:setButtonEffectLoop(key)
	buttonStatus[key] = STATUS_TYPE.NEED_LOOP
end

function ButtonEffectSet:closeButtonEffectStatus(key)
	buttonStatus[key] = STATUS_TYPE.NEED_CLOSE
end

function ButtonEffectSet:getButtonStatus(key)
	return buttonStatus[key]
end

--新航海士解锁
function ButtonEffectSet:openSailorButtonEffect()
	for k, v in pairs(sailorBtnTable) do
		self:setButtonEffectLoop(v)
	end
end

function ButtonEffectSet:closeSailorButtonEffect()
	for k, v in pairs(sailorBtnTable) do
		self:closeButtonEffectStatus(v)
	end
end

return ButtonEffectSet