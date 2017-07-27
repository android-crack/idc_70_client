local music_info=require("game_config/music_info")
local UITools=require("gameobj/uiTools")
local Tips={}

Tips.isShow=false  --是否正在显示
Tips.nodes={}      --显示东西池
Tips.layer=nil
Tips.tipsLayer = nil

function Tips:showNode(node, callBack, isNotQuick, zorder, is_notification) --isNotQuick 是否不要快速点击, 默认是false
	self.isNotQuick = isNotQuick or false
	if tolua.isnull(node) then return end
	
	local image_tab = {}
	if tolua.isnull(self.layer) then
		self.layer = CCLayerColor:create(ccc4(0, 0, 0, 180))
		
		self.parent = display.newLayer()
		self.layer:addChild(self.parent)
		if not node.noEffect then
			self.layer:setOpacity(0)
			self.layer:runAction(CCFadeTo:create(0.24 , 180))
			self:runAction(self.parent)
		end

		self.NodeContainer = CCNode:create()
		self.parent:addChild(self.NodeContainer)

		if not self.isNotQuick then
			self.layer:setTouchEnabled(true)
		end
		
		self.layer:registerScriptTouchHandler(function(eventType, x, y)
			if eventType == "began" then
				if #self.nodes>1 then
					if not tolua.isnull(self.nodes[1]) then
						local tipCallBack = self.nodes[1].tipCallBack
						self.nodes[1]:removeFromParentAndCleanup(true)
						if type(tipCallBack)=="function" then tipCallBack() end
					end
					table.remove(self.nodes,1)

					if not tolua.isnull(self.nodes[1]) then
						self.nodes[1]:setVisible(true)
					end
					if not self.nodes[1].noEffect then
						self:runAction(self.parent)
					end
					if not tolua.isnull(self.nodes[1]) then
						if type(self.nodes[1].callBack)=="function" then  self.nodes[1].callBack() end
					end
				elseif not tolua.isnull(self.layer) then
					local touchPos = self.parent:convertToNodeSpace(ccp(x, y))
					local lastNode = self.nodes[1]
					local tipCallBack
					if not tolua.isnull(lastNode) then
						tipCallBack = lastNode.tipCallBack
					end
					self.layer:removeFromParentAndCleanup(true)
					self.layer = nil
    				UnLoadImages(image_tab)
					
					self.nodes={}
					if type(callBack)=="function" then
						callBack()
					end
					
					if type(tipCallBack)=="function" then tipCallBack() end
				end
				return true
			end

	end,false, node.tipTouchPriority or TOUCH_PRIORITY_NORMAL, true)
		
		local running_scene = GameUtil.getRunningScene()
		if is_notification then
			running_scene = GameUtil.getNotification()
		end
		running_scene:addChild(self.layer, (zorder or ZORDER_PORT_LOADING))

		if type(node.callBack)=="function" then node.callBack() end
		if not tolua.isnull(node.ui_layer) then 
			node.ui_layer:setTouchPriority(node.tipTouchPriority)
		end
	else
		node:setVisible(false)
	end
	self.NodeContainer:addChild(node)

	table.insert(self.nodes, node)
end

function Tips:hideNode()
	if not tolua.isnull(self.layer) then
		if #self.nodes>1 then
			if not tolua.isnull(self.nodes[1]) then
				local tipCallBack = self.nodes[1].tipCallBack
				self.nodes[1]:removeFromParentAndCleanup(true)
				if type(tipCallBack)=="function" then tipCallBack() end
			end
			table.remove(self.nodes,1)
			
			if not tolua.isnull(self.nodes[1]) then
				self.nodes[1]:setVisible(true)
			end
			if not self.nodes[1].noEffect then
				self:runAction(self.parent)
			end
			if not tolua.isnull(self.nodes[1]) then
				if type(self.nodes[1].callBack)=="function" then  self.nodes[1].callBack() end
			end
		else
			local lastNode = self.nodes[1]
			local tipCallBack
			if not tolua.isnull(lastNode) then
				tipCallBack = lastNode.tipCallBack
			end
			self.layer:removeFromParentAndCleanup(true)
			self.layer = nil
    		
			self.nodes={}
			if type(tipCallBack)=="function" then tipCallBack() end
		end
	end
end

function Tips:runAction(target, non_music)
	local targetScaleX = target:getScaleX()
	local targetScaleY = target:getScaleY()
	target:setScale(0)
	-- target:setOpacity(0)
	local ac1 = CCScaleTo:create(0.05, targetScaleX * 0.8, targetScaleY * 0.8)
	local ac2 = CCScaleTo:create(0.05, targetScaleX * 0.93, targetScaleY * 1.05)
	local ac3 = CCScaleTo:create(0.09, targetScaleX * 1.01, targetScaleY * 0.99)
	local ac4 = CCScaleTo:create(0.05, targetScaleX, targetScaleY)
	local ac5 = CCCallFunc:create(function()
		if self.isNotQuick then
			if not tolua.isnull(self.layer) then
				self.layer:setTouchEnabled(true)
			end
		end
	end)
	local array = CCArray:create()
	array:addObject(ac1)
	array:addObject(ac2)
	array:addObject(ac3)
	array:addObject(ac4)
	array:addObject(ac5)
	target:runAction(CCSpawn:createWithTwoActions(CCSequence:create(array), CCFadeIn:create(0.19)))
	if not non_music then
		audioExt.playEffect(music_info.TOWN_CARD.res)
	end
end

function Tips:isShow()
	return not tolua.isnull(self.layer)
end

return Tips

























































































