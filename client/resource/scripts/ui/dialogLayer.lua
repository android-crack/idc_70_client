---- 模态对话框
require("module/gameBases")

local dialog = {}

local dialogLayerTab = {}
local dialog_zorder = 0
local ZERO = 0
local layer_show_order = ZORDER_DIALOG_LAYER
local layer_touch_priority = TOUCH_PRIORITY_DIALOG_LAYER
local function createDialogLayer(color)
	local color = color or ccc4(0, 0, 0, 180)
	local layer = CCLayerColor:create(color)
	layer:setZOrder(layer_show_order + dialog_zorder)
	return layer
end

local function getDialogPriotity()
	layer_touch_priority = TOUCH_PRIORITY_DIALOG_LAYER - dialog_zorder * 5 --因为界面叠界面会有较多的层需要设置触摸优先级
	return layer_touch_priority
end

local function showDialog(node, color, actionType, touchPriority, sync, shake, touch_not_effect)    --对话层
	local running_scene = GameUtil.getRunningScene()
	if not running_scene then return end 
 	for index = dialog_zorder, 0, -1 do
 		dialog_zorder = index
 		if not tolua.isnull(dialogLayerTab[index]) then
 			break
 		end
 	end
 	local old_top_layer = dialogLayerTab[dialog_zorder]
	if not tolua.isnull(old_top_layer) and not tolua.isnull(old_top_layer.show_node) and
		type(old_top_layer.show_node.setTouch) == "function"
	then
		old_top_layer.show_node:setTouch(false)
	end

	dialog_zorder = dialog_zorder + 1
	dialogLayerTab[dialog_zorder] = createDialogLayer(color)
	
	local ret_layer = dialogLayerTab[dialog_zorder]
	ret_layer.show_node = node

	local function onTouch(eventType, x, y)
		if eventType == "began" then
			if tolua.isnull(node) or touch_not_effect then return true end
			local touchNode = node
			if not tolua.isnull(node.touchNode) then touchNode = node.touchNode end
			if not tolua.isnull(touchNode) and not tolua.isnull(touchNode:getParent()) then
				local touchPos = touchNode:getParent():convertToNodeSpace(ccp(x, y))
				
				if touchNode:boundingBox():containsPoint(touchPos) then
					if type(node.touchCallBack) == "function" then
						node:touchCallBack(touchPos)
						return true
					end
				else
					if type(node.nTouchCallBack) == "function" then
						node:nTouchCallBack()
					end
				end
			end
			return true
		end
	end
	
	layer_touch_priority = getDialogPriotity()
	ret_layer:registerScriptTouchHandler(onTouch, false, (layer_touch_priority), true)
	ret_layer:setTouchEnabled(true)
	ret_layer:registerScriptHandler(function(event)
		if event == "enter" then
            
        elseif event == "exit" then
            if type(node.nExitCallBack)=="function" then
				node.nExitCallBack()
			end
        elseif event == "enterTransitionFinish" then
			
		end
    end)

	running_scene:addChild(ret_layer)

	if not tolua.isnull(node) then 
		ret_layer:addChild(node)
		if type(actionType) == "function" then
			actionType(node)
		end
		ret_layer.dHideCallBack = node.dHideCallBack
	end
	if type(node.setTouchPriority) == "function" then
		node:setTouchPriority(layer_touch_priority)
	end

	if type(node.deliverTouchPriority) == "function" then
		node:deliverTouchPriority(layer_touch_priority)
	end

	if not tolua.isnull(node.ui_layer) then
		node.ui_layer:setTouchPriority(layer_touch_priority)
	else
		if type(node.getTouchLayer) == "function" then
			node.ui_layer = node:getTouchLayer()
			node.ui_layer:setTouchPriority(layer_touch_priority)
		end
	end

	if type(node.touch_priority_cb) == "function" then
		node:touch_priority_cb(layer_touch_priority - 1)
	end
    if shake then
        local Tips = require("ui/tools/Tips")
        local shake_layer = node
        if type(node.getShakeLayer) == "function" then
            shake_layer = node:getShakeLayer()
        end
        -- 时间为0.24秒
        ret_layer:setOpacity(0)
        ret_layer:runAction(CCFadeTo:create(0.24 , 0.5 * 255))
        Tips:runAction(shake_layer)
    end
    
	return ret_layer
end


local function hideDialog(hide_dialog_layer)
	if not hide_dialog_layer or hide_dialog_layer == dialog then
		if dialog_zorder < 1 then return end
		for index = dialog_zorder, 1, -1 do
			
			if not tolua.isnull(dialogLayerTab[dialog_zorder]) then
				local dialog_layer = dialogLayerTab[dialog_zorder]
				local dHideCallBack = dialogLayerTab[dialog_zorder].dHideCallBack
				dialogLayerTab[dialog_zorder] = nil
				dialog_zorder = dialog_zorder - 1
				dialog_layer:removeFromParentAndCleanup(true)
				if dHideCallBack ~= nil then
					dHideCallBack()
				end
				break
			else
				dialog_zorder = dialog_zorder - 1
			end
		end
		
		if dialog_zorder == ZERO then--防止别人自己传进来时改变最初的设置
			layer_touch_priority = TOUCH_PRIORITY_DIALOG_LAYER
		end
		local old_top_layer = dialogLayerTab[dialog_zorder]
		if not tolua.isnull(old_top_layer) and not tolua.isnull(old_top_layer.show_node) and
			type(old_top_layer.show_node.setTouch) == "function"
		then
			old_top_layer.show_node:setTouch(true)
		end
		

	else
		for k,v in pairs(dialogLayerTab) do
			if v.show_node == hide_dialog_layer then
				v:removeFromParentAndCleanup(true)
				local dHideCallBack = v.dHideCallBack
				if dHideCallBack ~= nil then
					dHideCallBack()
				end
				v = nil
			end
		end
	end
	
end

local function hideAllDialog() 
	dialog_count = 0
	for i, v in pairs(dialogLayerTab) do
		if not tolua.isnull(v) then 
			dialog_count = dialog_count + 1
		end 
	end 	
	
	for i=1,dialog_count do
		hideDialog()
	end
	dialog_zorder = 0
	dialogLayerTab = {}
end

local function getTopDialogNode()
	local layer = dialogLayerTab[dialog_zorder]
	if not tolua.isnull(layer) then
		return layer.show_node
	end
	return nil
end

local function dialogAction1(target)
	target:setScale(0.5)
	local ac1 = CCScaleTo:create(0.1, 1.0)
	local ac2 = CCScaleTo:create(0.1, 1.1, 0.9)
	local ac3 = CCScaleTo:create(0.1, 0.95, 1.05)
	local array = CCArray:create()
	array:addObject(ac1)
	array:addObject(ac2)
	array:addObject(ac3)
	array:addObject(ac1)
	target:runAction(CCSequence:create(array))
end

dialog.showDialog = showDialog
dialog.hideDialog = hideDialog
dialog.hideAllDialog = hideAllDialog
dialog.dialogActionType1 = dialogAction1
dialog.getDialogPriotity = getDialogPriotity
dialog.getTopDialogNode = getTopDialogNode


return dialog