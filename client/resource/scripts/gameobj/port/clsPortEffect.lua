-- 港口以及主界面的一些特效方法
-- Author: cls
-- Date: 2016-02-26 11:46:15
--
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local music_info = require("game_config/music_info")

PORT_EFFECT_EASEINOUT = 1
PORT_EFFECT_ZOOMINOUT = 2
PORT_EFFECT_EASE_ZOOM = 3
PORT_EFFECT_EASE_ROTATE = 4
PORT_EFFECT_EASE_PANEL_EFFECT = 5
PORT_EFFECT_FADEIN = 6
PORT_EFFECT_FADEOUT = 7
PORT_EFFECT_FADEOUT_ROTATE = 8
PORT_EFFECT_FADEIN_ROTATE = 9
PORT_EFFECT_FADEOUT_ZOOM = 10
PORT_EFFECT_FADEIN_ZOOM = 11
PORT_EFFECT_FADETO_ZOOM = 12

--缩放的效果
local function zoomInOutEffect(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	local node_pos = node:getPosition()
	node:setScaleX(effect_data.change[1])
	node:setScaleY(effect_data.change[2])
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	if effect_data.effect_res and not tolua.isnull(parent) then
		node_pos = ccp(node_pos.x + effect_data.effect_res[2], node_pos.y + effect_data.effect_res[3])
		arr:addObject(CCCallFunc:create(function()
			if effect_data.voice then
				audioExt.playEffect(music_info[effect_data.voice].res)
			end
			local composite_effect = require("gameobj/composite_effect")
			node.gaf = composite_effect.new(effect_data.effect_res[1], node_pos.x, node_pos.y, parent, 1, function()
				node.gaf = nil
			end, nil, nil, true)
		end))
	end
	for i,v in ipairs(effect_data.action) do
		arr:addObject(CCScaleTo:create(v[1], v[2], v[3]))
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--渐变显示的效果
local function fadeInEffect(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		arr:addObject(CCFadeIn:create(v[1]))
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--渐变消失的效果
local function fadeOutEffect(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		arr:addObject(CCFadeOut:create(v[1]))
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--渐变旋转消失的效果
local function fadeOutRotateEffefct(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	local cur_pos = node:getPosition()
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		if v[3] then --是否渐变
			arr:addObject(CCCallFunc:create(function()
				local ac = CCSpawn:createWithTwoActions(CCRotateTo:create(v[1], v[2]), CCFadeOut:create(v[1]))
				node:runAction(ac)
			end))
			arr:addObject(CCDelayTime:create(v[1]))
		else
			arr:addObject(CCRotateTo:create(v[1], v[2]))
		end
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--渐变旋转出现的效果
local function fadeInRotateEffefct(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	local cur_pos = node:getPosition()
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		if v[3] then --是否渐变
			arr:addObject(CCCallFunc:create(function()
				local ac = CCSpawn:createWithTwoActions(CCRotateTo:create(v[1], v[2]), CCFadeIn:create(v[1]))
				node:runAction(ac)
			end))
			arr:addObject(CCDelayTime:create(v[1]))
		else
			arr:addObject(CCRotateTo:create(v[1], v[2]))
		end
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--渐变缩放消失的效果
local function fadeOutZoomEffefct(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	node:setScaleX(effect_data.change[1])
	node:setScaleY(effect_data.change[2])
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		if v[4] then --是否渐变
			arr:addObject(CCCallFunc:create(function()
				local ac = CCSpawn:createWithTwoActions(CCScaleTo:create(v[1], v[2], v[3]), CCFadeOut:create(v[1]))
				node:runAction(ac)
			end))
			arr:addObject(CCDelayTime:create(v[1]))
		else
			arr:addObject(CCScaleTo:create(v[1], v[2], v[3]))
		end
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--渐变缩放出来的效果
local function fadeInZoomEffefct(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	node:setScaleX(effect_data.change[1])
	node:setScaleY(effect_data.change[2])
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		if v[4] then --是否渐变
			arr:addObject(CCCallFunc:create(function()
				local ac = CCSpawn:createWithTwoActions(CCScaleTo:create(v[1], v[2], v[3]), CCFadeIn:create(v[1]))
				node:runAction(ac)
			end))
			arr:addObject(CCDelayTime:create(v[1]))
		else
			arr:addObject(CCScaleTo:create(v[1], v[2], v[3]))
		end
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--透明度变化且缩放的效果
local function fadeToZoomEffefct(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	node:setOpacity(effect_data.change)
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		if v[3] then --是否缩放
			arr:addObject(CCCallFunc:create(function()
				local ac = CCSpawn:createWithTwoActions(CCScaleTo:create(v[1], v[3][1], v[3][2]), CCFadeTo:create(v[1], v[2]))
				node:runAction(ac)
			end))
			arr:addObject(CCDelayTime:create(v[1]))
		else
			arr:addObject(CCFadeTo:create(v[1], v[2]))
		end
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--移动并缩放的效果，建筑按钮使用到
local function easeAndZoomEffect(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	local cur_pos = node:getPosition()
	node:setPosition(ccp(cur_pos.x - effect_data.change[1], cur_pos.y - effect_data.change[2]))
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		if v[3] then
			arr:addObject(CCCallFunc:create(function()
				local ac = CCSpawn:createWithTwoActions(CCMoveBy:create(v[1], ccp(v[2][1], v[2][2])), CCScaleTo:create(v[1], v[3][1], v[3][2]))
				node:runAction(ac)
			end))
			arr:addObject(CCDelayTime:create(v[1]))
		else
			arr:addObject(CCMoveBy:create(v[1], ccp(v[2][1], v[2][2])))
		end
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--移动并旋转的效果，码头按钮使用到
local function easeAndRotateEffect(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	local cur_pos = node:getPosition()
	node:setPosition(ccp(cur_pos.x - effect_data.change[1], cur_pos.y - effect_data.change[2]))
	node:setRotation(effect_data.change[3])
	node:setCascadeOpacityEnabled(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		if v[3] then
			arr:addObject(CCCallFunc:create(function()
				local ac = CCSpawn:createWithTwoActions(CCRotateTo:create(v[1], v[2]), CCMoveBy:create(v[1], ccp(v[3][1], v[3][2])))
				node:runAction(ac)
			end))
			arr:addObject(CCDelayTime:create(v[1]))
		else
			arr:addObject(CCRotateTo:create(v[1], v[2]))
		end
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--移动坐标的效果
local function easeInOutEffect(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	local cur_pos = node:getPosition()
	node:setPosition(ccp(cur_pos.x - effect_data.change[1], cur_pos.y - effect_data.change[2]))
	node:setCascadeOpacityEnabled(true)
	local opacity 
	if effect_data.change[3] then
		opacity = node:getOpacity()
		node:setOpacity(0)
	end
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	arr:addObject(CCCallFunc:create(function()
		if opacity then
			node:setOpacity(opacity)
		end
	end))
	for i,v in ipairs(effect_data.action) do
		arr:addObject(CCMoveBy:create(v[1], ccp(v[2], v[3])))
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

--移动面板坐标的效果
local function easeInOutPanelEffect(node, effect_data, parent, callBack, delay)
	if tolua.isnull(node) then return end
	local cur_pos_x, cur_pos_y = node:getPosition()
	node:setPosition(cur_pos_x - effect_data.change[1], cur_pos_y - effect_data.change[2])
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(effect_data.delay + (delay or 0)))
	for i,v in ipairs(effect_data.action) do
		arr:addObject(CCMoveBy:create(v[1], ccp(v[2], v[3])))
	end
	if callBack then 
		arr:addObject(CCCallFunc:create(callBack))
	end
	node:runAction(CCSequence:create(arr))
end

local function showPortFogEffect( node, target, portConfig, callBack )
	local colorLayer = CCLayerColor:create(ccc4(255, 255, 255, 255))
	target:addChild(colorLayer, -10)

	local pos1 = {{130,172}, {749,145}, {508,478}, {751,427}, {337,32}, {154,337}, {600,-12}, {966,268}, {1076,108}}
	local pos2 = {{-422,192}, {1248,-191}, {524,811}, {1200,810}, {151,-272}, {-221,692}, {674,-284}, {1374,268}, {1352,268}}
	local sprites = {}
	for i = 1, 9 do
		sprites[i] = getChangeFormatSprite("ui/bg/bg_fog.png", pos1[i][1], pos1[i][2])
		sprites[i]:setScale(2)
		local ac = CCSpawn:createWithTwoActions(CCMoveTo:create(0.8, ccp(pos2[i][1],pos2[i][2])), CCFadeOut:create(2))
		sprites[i]:runAction(ac)
		node:addChild(sprites[i])
	end
	audioExt.playEffect(music_info.ENTER_PORT_FOG.res)
	
	--黑白
	local spriteCover = newQtzGraySprite(portConfig.res, 480, 270)
	spriteCover:setScale(target.bgScale)
	local portData = getGameData():getPortData()
	if portData:getPortFlipX() == 1 then spriteCover:setFlipX(true) end
	target:addChild(spriteCover, -1)
	target.fadeBgTimer = runFadeAction(spriteCover, 0.29, 1, 0.8)

	local arrCover = {}
	arrCover[1] = CCDelayTime:create(0.18)
	arrCover[2] = CCScaleTo:create(0.62, 1.3 * target.bgScale)
	arrCover[3] = CCScaleTo:create(0.1, 1 * target.bgScale)
	spriteCover:runAction(transition.sequence(arrCover))

	local function runBgEffect(node)
		if tolua.isnull(node) then return end
		if node:getOpacity() == 0 or not node:isVisible() then return end
		node:setOpacity(0)
		node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCFadeIn:create(0.8)))
	end

	runBgEffect(target.boatSprite)
	runBgEffect(target.reverseSprite)
	runBgEffect(target.wave)

	--小人
	if target.peoples then
		for k_, people in pairs(target.peoples) do
			runBgEffect(people)
			runBgEffect(people.shade)
		end
	end

	if not tolua.isnull(target.manSprite) then
		runBgEffect(target.manSprite.mark)
	end

	if target.effects then
		for k,v in pairs(target.effects) do
			runBgEffect(v)
		end
	end

	--背景
	runBgEffect(target.spriteBgPhoto)

	local arr2 = {}
	arr2[1] = CCDelayTime:create(0.28)
	arr2[2] = CCScaleTo:create(0.57, 1.27)
	arr2[3] = CCScaleTo:create(0.1, 1)
	target.spriteBg:runAction(transition.sequence(arr2))

	node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2.23), CCCallFunc:create(function()  --最长时间的为准
		spriteCover:removeFromParentAndCleanup(true)
		colorLayer:removeFromParentAndCleanup(true)
		node:removeFromParentAndCleanup(true)
		target.effecting = false  --特效完结了
		target.isEnter = false    --可以进建筑
		require("gameobj/mission/gamePlot"):resetPlot()
		if type(callBack) == "function" then callBack() end
		EventTrigger(EVENT_ENTER_PORT)
	end)))
end

local effect_fun = {
	[PORT_EFFECT_EASEINOUT] = easeInOutEffect,
	[PORT_EFFECT_ZOOMINOUT] = zoomInOutEffect,
	[PORT_EFFECT_EASE_ZOOM] = easeAndZoomEffect,
	[PORT_EFFECT_EASE_ROTATE] = easeAndRotateEffect,
	[PORT_EFFECT_EASE_PANEL_EFFECT] = easeInOutPanelEffect,
	[PORT_EFFECT_FADEIN] = fadeInEffect,
	[PORT_EFFECT_FADEOUT] = fadeOutEffect,
	[PORT_EFFECT_FADEOUT_ROTATE] = fadeOutRotateEffefct,
	[PORT_EFFECT_FADEIN_ROTATE] = fadeInRotateEffefct,
	[PORT_EFFECT_FADEOUT_ZOOM] = fadeOutZoomEffefct,
	[PORT_EFFECT_FADEIN_ZOOM] = fadeInZoomEffefct,
	[PORT_EFFECT_FADETO_ZOOM] = fadeToZoomEffefct,
}

--可用于多个列表特效播放
function playNodeListEffect(node_list, end_back)
	local node_len = #node_list
	for i,v in ipairs(node_list) do
		effect_fun[v.effect.type](v.node, v.effect, nil, function()
			node_len = node_len - 1
			if node_len == 0 and end_back then
				end_back()
			end
		end)
	end
end

-- local function showChatTaskUIEffect(target, callBack)
--     local chat_panel = chat_component:getPanelUI()
-- 	local effect_info = {
-- 		--1-3分别对应聊天界面中的底板，语音按钮以及聊天按钮
-- 		[1] = {node = chat_panel.action_bg, type = PORT_EFFECT_ZOOMINOUT, change = {0, 0}, delay = 0.53, action = {{0.17, 1.056, 1.056}, {0.1, 0.972, 0.972}, {0.1, 1.023, 1.023}, {0.13, 1, 1}}},
-- 		[2] = {node = chat_panel.btn_voice, type = PORT_EFFECT_ZOOMINOUT, change = {0, 0}, delay = 0.73, action = {{0.13, 1.1, 1.1}, {0.1, 0.9, 0.9}, {0.1, 1.02, 1.02}, {0.1, 1, 1}}},
-- 		[3] = {node = chat_panel.btn_chat, type = PORT_EFFECT_ZOOMINOUT, change = {0, 0}, delay = 0.86, action = {{0.14, 1.1, 1.1}, {0.1, 0.9, 0.9}, {0.1, 1.02, 1.02}, {0.1, 1, 1}}},
-- 		--第四对应任务面板的效果
-- 		[4] = {node = target.mision_port_ui, type = PORT_EFFECT_EASE_PANEL_EFFECT, change = {0, -339}, delay = 0.73, action = {{0.13, 0, -135.6}, {0.1, 0, -203.4}, {0.1, 0, -11}, {0.07, 0, 17}, {0.07, 0, -9}, {0.06, 0, 3}}},
-- 	}

-- 	for i,v in ipairs(effect_info) do
-- 		effect_fun[v.type](v.node, v)
-- 	end
-- end

--右下角按钮效果
BUTTOM_BTN_SAIL = 1
BUTTOM_BTN_HORIZONTAL_1 = 2
BUTTOM_BTN_HORIZONTAL_2 = 3
BUTTOM_BTN_HORIZONTAL_3 = 4
BUTTOM_BTN_HORIZONTAL_4 = 5
BUTTOM_BTN_VERTICAL_1 = 6

local BUTTOM_EFFECT_LIST = {
	[BUTTOM_BTN_SAIL] = {type = PORT_EFFECT_EASE_ROTATE, change = {-73.05, 159.55, -39.3}, delay = 0.36, action = {{0.27, 6.6, {-72.45, 140.05}}, {0.17, 15.4, {-0.1, 30.95}}, {0.16, 11, {-0.55, -15.8}}, {0.17, 12.2, {0.05, 4.35}}, {0.37, 0}}},
	[BUTTOM_BTN_HORIZONTAL_1] = {type = PORT_EFFECT_EASEINOUT, change = {-116, 0, 0}, delay = 0.7, action = {{0.26, -116, 0}, {0.1, -6, 0}, {0.1, 8, 0}, {0.07, -2, 0}}},
	[BUTTOM_BTN_HORIZONTAL_2] = {type = PORT_EFFECT_EASEINOUT, change = {-200, 0, 0}, delay = 0.76, action = {{0.23, -200, 0}, {0.1, -6, 0}, {0.1, 8, 0}, {0.07, -2, 0}}},
	[BUTTOM_BTN_HORIZONTAL_3] = {type = PORT_EFFECT_EASEINOUT, change = {-285, 0, 0}, delay = 0.8, action = {{0.24, -285, 0}, {0.1, -6, 0}, {0.1, 8, 0}, {0.06, -2, 0}}},
	[BUTTOM_BTN_HORIZONTAL_4] = {type = PORT_EFFECT_EASEINOUT, change = {-386, 0, 0}, delay = 0.83, action = {{0.23, -386, 0}, {0.1, -6, 0}, {0.1, 8, 0}, {0.07, -2, 0}}},
	[BUTTOM_BTN_VERTICAL_1] = {type = PORT_EFFECT_EASEINOUT, change = {-114, 0, 0}, delay = 0.53, action = {{0.1, -88.65, 0}, {0.2, -32.35, 0}, {0.17, 7, 0}}},
}
--左侧按钮效果
BUILDING_BTN_BG = 1
BUILDING_BTN_1 = 2
BUILDING_BTN_2 = 3
BUILDING_BTN_3 = 4
BUILDING_BTN_4 = 5
local BUILDING_EFFECT_LIST = {
	[BUILDING_BTN_BG] = {type = PORT_EFFECT_EASEINOUT, change = {107, 0}, delay = 0.73, action = {{0.13, 99.35, 0}, {0.3, 7.63, 0}}},
	[BUILDING_BTN_1] = {type = PORT_EFFECT_EASE_ZOOM, change = {139.5, 0}, delay = 0.63, action = {{0.1, {134.3, 0}}, {0.1, {1.75, 0}, {1.074, 0.941}}, {0.17, {2.9, 0}, {1, 1}}}}, 
	[BUILDING_BTN_2] = {type = PORT_EFFECT_EASE_ZOOM, change = {139.5, 0}, delay = 0.73, action = {{0.1, {134.3, 0}}, {0.1, {1.75, 0}, {1.074, 0.941}}, {0.17, {2.9, 0}, {1, 1}}}}, 
	[BUILDING_BTN_3] = {type = PORT_EFFECT_EASE_ZOOM, change = {139.5, 0}, delay = 0.83, action = {{0.1, {134.3, 0}}, {0.1, {1.75, 0}, {1.074, 0.941}}, {0.17, {2.9, 0}, {1, 1}}}}, 
	[BUILDING_BTN_4] = {type = PORT_EFFECT_EASE_ZOOM, change = {139.5, 0}, delay = 0.93, action = {{0.1, {134.3, 0}}, {0.1, {1.75, 0}, {1.074, 0.941}}, {0.17, {2.9, 0}, {1, 1}}}}, 
}
--顶部按钮效果,都从左侧开始算起1-3
TOP_BTN_LEFT_ROW_1_INDEX_1 = 1
TOP_BTN_LEFT_ROW_1_INDEX_2 = 2
TOP_BTN_LEFT_ROW_1_INDEX_3 = 3
TOP_BTN_RIGHT_ROW_1_INDEX_1 = 4
TOP_BTN_RIGHT_ROW_1_INDEX_2 = 5
TOP_BTN_RIGHT_ROW_1_INDEX_3 = 6
TOP_BTN_RIGHT_ROW_2_INDEX_1 = 7
TOP_BTN_RIGHT_ROW_2_INDEX_2 = 8
TOP_BTN_RIGHT_ROW_2_INDEX_3 = 9
TOP_BTN_LEFT_ROW_2_INDEX_1 = 10
TOP_BTN_LEFT_ROW_2_INDEX_2 = 11
TOP_BTN_LEFT_ROW_2_INDEX_3 = 12
local TOP_BTN_EFFECT_LIST = {
	[TOP_BTN_LEFT_ROW_1_INDEX_1] = {type = PORT_EFFECT_EASEINOUT, change = {0, -75}, delay = 0.6, action = {{0.2, 0, -83}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_LEFT_ROW_1_INDEX_2] = {type = PORT_EFFECT_EASEINOUT, change = {0, -75}, delay = 0.66, action = {{0.2, 0, -83}, {0.13, 0, 12}, {0.17, 0, -4}}}, 
	[TOP_BTN_LEFT_ROW_1_INDEX_3] = {type = PORT_EFFECT_EASEINOUT, change = {0, -75}, delay = 0.72, action = {{0.2, 0, -83}, {0.13, 0, 12}, {0.17, 0, -4}}}, 
	[TOP_BTN_RIGHT_ROW_1_INDEX_1] = {type = PORT_EFFECT_EASEINOUT, change = {0, -75}, delay = 0.8, action = {{0.2, 0, -83}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_RIGHT_ROW_1_INDEX_2] = {type = PORT_EFFECT_EASEINOUT, change = {0, -75}, delay = 0.88, action = {{0.2, 0, -83}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_RIGHT_ROW_1_INDEX_3] = {type = PORT_EFFECT_EASEINOUT, change = {0, -75}, delay = 0.96, action = {{0.2, 0, -83}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_RIGHT_ROW_2_INDEX_1] = {type = PORT_EFFECT_EASEINOUT, change = {0, -143}, delay = 0.8, action = {{0.2, 0, -151}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_RIGHT_ROW_2_INDEX_2] = {type = PORT_EFFECT_EASEINOUT, change = {0, -143}, delay = 0.88, action = {{0.2, 0, -151}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_RIGHT_ROW_2_INDEX_3] = {type = PORT_EFFECT_EASEINOUT, change = {0, -143}, delay = 0.96, action = {{0.2, 0, -151}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_LEFT_ROW_2_INDEX_1] = {type = PORT_EFFECT_EASEINOUT, change = {0, -143}, delay = 0.6, action = {{0.2, 0, -151}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_LEFT_ROW_2_INDEX_2] = {type = PORT_EFFECT_EASEINOUT, change = {0, -143}, delay = 0.66, action = {{0.2, 0, -151}, {0.13, 0, 12}, {0.17, 0, -4}}},
	[TOP_BTN_LEFT_ROW_2_INDEX_3] = {type = PORT_EFFECT_EASEINOUT, change = {0, -143}, delay = 0.72, action = {{0.2, 0, -151}, {0.13, 0, 12}, {0.17, 0, -4}}},
}


--港口特效，包含雾散开，ui等全效果
function mkPortEnterEffect(target, portConfig, callBack)
	ClsDialogSequene:pauseQuene("clsPortEffect")
	target.effecting = true
	local node = CCNode:create()
	target:addChild(node,10)
	
	showPortFogEffect(node, target, portConfig, callBack)

	local info_effect = target.mainLayer.info_effect_list
	for i,v in ipairs(info_effect) do
		if v.node:isVisible() then
			effect_fun[v.effect.type](v.node, v.effect, target.mainLayer)
		end
	end

	local top_btn_effect = target.mainLayer.top_btn_effect_list
	for i,v in ipairs(top_btn_effect) do
		if v.node:isVisible() then
			local effect = TOP_BTN_EFFECT_LIST[v.effect_index]
			effect_fun[effect.type](v.node, effect, target.mainLayer)
		end
	end

	local building_effect = target.mainLayer.building_effect_list
	for i,v in ipairs(building_effect) do
		if v.node:isVisible() then
			local effect = BUILDING_EFFECT_LIST[v.effect_index]
			effect_fun[effect.type](v.node, effect, target.mainLayer)
		end
	end

	local buttom_effect = target.mainLayer.buttom_effect_list
	for i,v in ipairs(buttom_effect) do
		if v.node:isVisible() then
			local effect = BUTTOM_EFFECT_LIST[v.effect_index]
			effect_fun[effect.type](v.node, effect, target.mainLayer)
		end
	end

	-- showChatTaskUIEffect(target)
end

--部分ui特效，用于已进入港口的微小效果
function mkPortUIEnterEffect(target, callBack)
	local node = CCNode:create()
	target:addChild(node,10)
	target.effecting = true
	
	local build_delay = -0.6
	local total_time = 1.32
	local building_effect = target.mainLayer.building_effect_list
	for i,v in ipairs(building_effect) do
		if v.node:isVisible() then
			local effect = BUILDING_EFFECT_LIST[v.effect_index]
			effect_fun[effect.type](v.node, effect, target.mainLayer, nil, build_delay)
		end
	end

	node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(total_time + build_delay), CCCallFunc:create(function()  --最长时间的为准
		node:removeFromParentAndCleanup(true)
		target.effecting = false  --特效完结了
		target.isEnter = false    --可以进建筑
		require("gameobj/mission/gamePlot"):resetPlot()
		if type(callBack) == "function" then callBack() end
		EventTrigger(EVENT_ENTER_PORT)
	end)))
end
