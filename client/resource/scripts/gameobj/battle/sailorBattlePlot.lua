------ 单挑剧情相关
local sailor_info = require("game_config/sailor/sailor_info")
local commonBase = require("gameobj/commonFuns")
local m_control_sprite = require("ui/tools/sprite")
local char_mask_layer = require("gameobj/battle/CharMaskLayer")
local music_info = require("game_config/music_info")
local plotVoiceAudio=require("gameobj/plotVoiceAudio")

local sailorBattlePlot = {}

---------------------辅助函数------------------------

function sailorBattlePlot:createDialogLayer()
	local layer = CCLayer:create()
	local touch_priority = -127
	layer:registerScriptTouchHandler(function(eventType, x, y) 
		if eventType =="began" then 
			if self.curPlot == "dialog" then
				local no_skip = self.curPlotTab[6]
				if not no_skip then
					if self.dialog_delay_action  then
						local act_mgr = CCDirector:sharedDirector():getActionManager()
						act_mgr:removeAction( self.dialog_delay_action )
						self.dialog_delay_action = nil
					end
					self:endSayAction()
				end
			end
			return true 
		end
	end, false, touch_priority, true)
	layer:setTouchEnabled(true)
	return layer
end

function sailorBattlePlot:setPlotParentLayer(layer)
	self.plotParentLayer = layer
end

function sailorBattlePlot:getPlotParentLayer()
	return self.plotParentLayer
end

function sailorBattlePlot:showDialogLayer()    --对话层
	local polt_layer = self:getPlotParentLayer()
	if tolua.isnull(polt_layer) then 
		return
	end
	if tolua.isnull(self.dialogLayer) then 
		self.dialogLayer = self:createDialogLayer()
		polt_layer:addChild(self.dialogLayer)
	end 
end

function sailorBattlePlot:hideDialogLayer()
	if self.dialogLayer~=nil and not tolua.isnull(self.dialogLayer) then
		self.dialogLayer:removeFromParentAndCleanup(true)
		self.dialogLayer = nil
	end
end

-------------对话相关-------------
-- item = {seaman_id = 1, name = "", is_right = true, txt = "" }
function sailorBattlePlot:say(item)
	
	local seaman_id = item[1]
	local name = item[2]..":"
	local is_right = (item[3] == 2)
	local txt = item[4] or ""
	txt = commonBase:repString(txt)
	txt = "        " .. txt

	if self.seaman~=nil and not tolua.isnull(self.seaman) then
		self.seaman:removeFromParentAndCleanup(true)
		self.seaman = nil
	end

	if self.plot_black~=nil and not tolua.isnull(self.plot_black) then
		self.plot_black:removeFromParentAndCleanup(true)
		self.plot_black = nil
	end

	if not sailor_info[seaman_id] then  
		if type(seaman_id) == "string" then     --直接使用图片
			self.seaman = display.newSprite(seaman_id)
		else   ---- 用角色信息代替
			local playerData = getGameData():getPlayerData()
			local role_name = playerData:getName()
			name = string.format("%s%s", role_name, ":")
			local icon = playerData:getIcon()
			icon = string.format("ui/seaman/seaman_%s.png", icon)
			self.seaman = display.newSprite(icon)
		end
	else     --水手配置表
		local seaman_res = sailor_info[seaman_id].res
		self.seaman = display.newSprite(seaman_res)
	end 
	
	self.dialogLayer:addChild(self.seaman, 2)	
	local seaman_width = self.seaman:getContentSize().width
	local show_width = 130
	local scale = show_width/seaman_width
	self.seaman:setScale(scale)
	self.seaman:setAnchorPoint(ccp(0,0))
	
	local function act_call_back(is_right)
		if tolua.isnull(self.name) then
			self.name = createBMFont({text = name, size = 20, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),fontFile = FONT_MICROHEI_BOLD})
			self.name:setAnchorPoint(ccp(0, 1))
			self.plot_black:addChild(self.name)
		else
			self.name:setString(name)
		end
		
		if tolua.isnull(self.label) then 
			self.label = createBMFont({text = txt, size = 18, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),fontFile = FONT_MICROHEI_BOLD, width = 560})
			self.label:setAnchorPoint(ccp(0, 0.5))
			self.plot_black:addChild(self.label)
		else
			self.label:setString(txt)
		end 
		
		local lx_n, ly_n = 290, 120  -- name 
		local rx_n, ry_n = 100, 120
		local lx_l, ly_l = 290, 60   -- label 
		local rx_l, ry_l = 100, 60
		if is_right then
			self.name:setPosition(ccp(rx_n, ry_n))
			self.label:setPosition(ccp(rx_l, ry_l))
		else
			self.name:setPosition(ccp(lx_n, ly_n))
			self.label:setPosition(ccp(lx_l, ly_l))
		end 
	end 
	
	-- 剧情动画表现
	if tolua.isnull(self.plot_black) then
		self.plot_black = getChangeFormatSprite("ui/bg/bg_plot.png")
		self.dialogLayer:addChild(self.plot_black, 1)
	end 
	
	if not is_right then  -- 头像放左边   
		self.last_dir = 0
		local ac_time = 0.2
		-- 对话条
		self.plot_black:setAnchorPoint(ccp(0, 0))
		self.plot_black:setScaleX(0)
		self.plot_black:setOpacity(0)
		self.plot_black:setPosition(ccp(0, 50))	
		local scale = CCScaleTo:create(ac_time, 1)
		local fade  = CCFadeIn:create(ac_time)
		local ac1 = CCSpawn:createWithTwoActions(scale, fade)
		local ac2 = CCCallFunc:create(function() act_call_back(is_right) end)
		self.plot_black:runAction(CCSequence:createWithTwoActions(ac1, ac2))
		
		-- 头像
		self.seaman:setPosition(ccp(-200, 50))
		self.seaman:setOpacity(0)
		local ac1 = CCFadeIn:create(ac_time)
		local ac2 = CCMoveTo:create(ac_time, ccp(120, 50))
		self.seaman:runAction(CCSpawn:createWithTwoActions(ac1, ac2))
	
	else            -- 右边
		self.last_dir = 1
		local ac_time = 0.2	
		-- 对话条
		self.plot_black:setAnchorPoint(ccp(1, 0))
		self.plot_black:setScaleX(0)
		self.plot_black:setOpacity(0)
		self.plot_black:setPosition(ccp(display.width, 50))	
		local scale = CCScaleTo:create(ac_time, 1)
		local fade  = CCFadeIn:create(ac_time)
		local ac1 = CCSpawn:createWithTwoActions(scale, fade)
		local ac2 = CCCallFunc:create(function() act_call_back(is_right) end)
		self.plot_black:runAction(CCSequence:createWithTwoActions(ac1, ac2))
		
		-- 头像
		self.seaman:setPosition(ccp(display.width, 50))
		self.seaman:setOpacity(0)
		local ac1 = CCFadeIn:create(ac_time)
		local ac2 = CCMoveTo:create(ac_time, ccp(700, 50))
		self.seaman:runAction(CCSpawn:createWithTwoActions(ac1, ac2))
	end 
end 

function sailorBattlePlot:endSayAction()  -- 结束对话动画
	local ac_time = 0.2
	if self.last_dir == 0 then   -- 左边
		local scale = CCScaleTo:create(ac_time, 0, 1)
		local fade  = CCFadeOut:create(ac_time)
		local ac1 = CCSpawn:createWithTwoActions(scale, fade)
		local ac2 = CCCallFunc:create(function() 
			self:playSubPlot()
		end)
		local array0 = CCArray:create()
		array0:addObject(ac1)
		array0:addObject(ac2)
		self.plot_black:runAction(CCSequence:create(array0))

		local ac1 = CCFadeOut:create(ac_time)
		local ac2 = CCMoveTo:create(ac_time, ccp(-200, 50))
		local array1 = CCArray:create()
		array1:addObject(CCSpawn:createWithTwoActions(ac1, ac2))
		self.seaman:runAction(CCSequence:create(array1))
		
	elseif self.last_dir == 1 then  -- 右边
		local scale = CCScaleTo:create(ac_time, 0, 1)
		local fade  = CCFadeOut:create(ac_time)
		local ac1 = CCSpawn:createWithTwoActions(scale, fade)
		local ac2 = CCCallFunc:create(function() 
			self:playSubPlot()
		end)
		local array0 = CCArray:create()
		array0:addObject(ac1)
		array0:addObject(ac2)
		self.plot_black:runAction(CCSequence:create(array0))
		local ac1 = CCFadeOut:create(ac_time)
		local ac2 = CCMoveTo:create(ac_time, ccp(display.width, 50))
		local array1 = CCArray:create()
		array1:addObject(CCSpawn:createWithTwoActions(ac1, ac2))
		self.seaman:runAction(CCSequence:create(array1))
	end 
	
end 

function sailorBattlePlot:showDialog(dialogTab) -- 对话
	if tolua.isnull(self.dialogLayer) then 
		return 
	end
	if dialogTab then
		self:say(dialogTab)

		self.dialog_voice_key = dialogTab[7]
		plotVoiceAudio.playVoiceEffect(self.dialog_voice_key)

		local delay_time = dialogTab[5] or 4

		if self.dialog_delay_action then
			local act_mgr = CCDirector:sharedDirector():getActionManager()
			act_mgr:removeAction( self.dialog_delay_action )
			self.dialog_delay_action = nil
		end


		local ac1 = CCDelayTime:create(delay_time)
		local ac2 = CCCallFunc:create(function() 
			self.dialog_delay_action = nil
			self:endSayAction() 
		end)
		local seq = CCSequence:createWithTwoActions(ac1, ac2)
		self.dialog_delay_action = self.dialogLayer:runAction(seq)
	end
end 

-------------------延迟--------------------
function sailorBattlePlot:delayTime(ticktab)
	local tick = ticktab[1]
	local ac1 = CCDelayTime:create(tick)
	local ac2 = CCCallFunc:create(function() self:playSubPlot() end)
	local seq = CCSequence:createWithTwoActions(ac1, ac2)
	self.dialogLayer:runAction(seq)
end

function sailorBattlePlot:mask_fadeIn(fadeTab)
	if self.mask_layer then
		self.dialogLayer:removeChild( self.mask_layer  )
		self.mask_layer  = nil
	end

	self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255*0.5), display.width*1.5, display.height*1.5)
	self.dialogLayer:addChild( self.mask_layer )
		
	local fade_time = fadeTab and fadeTab[1] or 1
	local actions = {}
	actions[1] = CCFadeIn:create(fade_time)
	actions[2] = CCCallFunc:create( function()
		self:playSubPlot()
	end)
	local action = transition.sequence(actions)
	self.mask_layer:runAction(action)
end

function sailorBattlePlot:mask_fadeOut(fadeTab)
	if not self.mask_layer then
		self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255*0.5))
		self.dialogLayer:addChild( self.mask_layer, -1 )
	else
		self.mask_layer:setOpacity(255*0.5)
	end
	
	local fade_time = fadeTab and fadeTab[1] or 1	
	local actions = {}
	actions[1] = CCFadeOut:create(fade_time)
	actions[2] = CCCallFunc:create( function()
		self.dialogLayer:removeChild( self.mask_layer )
		self.mask_layer = nil
		self:playSubPlot()
	end)
	local action = transition.sequence(actions)
	self.mask_layer:runAction(action)
end

-----------------------------------------
local PLOT_FUNC_DICT = {
	["dialog"] = sailorBattlePlot.showDialog,
	["delay"] = sailorBattlePlot.delayTime,
	["mask_fadeIn"] = sailorBattlePlot.mask_fadeIn,
	["mask_fadeOut"] = sailorBattlePlot.mask_fadeOut,
}

function sailorBattlePlot:playSubPlot()     -- 每个子剧情
	if self.nextIndex > self.plot_count then --播完
		self:hidePlot()
		return 
	end 
	local curTab = self.plotTab[self.nextIndex]
	self.curPlot = curTab.plot
	self.curPlotTab = curTab.param
	self.last_dir = -1  -- 上一次对话的位置， -1为空，0为左， 1为右
	
	self.nextIndex = self.nextIndex + 1
	if PLOT_FUNC_DICT[self.curPlot] then	
		PLOT_FUNC_DICT[self.curPlot](self, curTab.param)
	else
		cclog( string.format("sailor battle play plot error:the plot type %s is nil", self.curPlot) )
	end
end 

function sailorBattlePlot:showPlot()
	--print("单挑剧情播放")
	if not self.isShow then 
		self:showDialogLayer()
		self.isShow = true

		self.start_call_back()
	end
end  

function sailorBattlePlot:hidePlot()
	if self.isShow then 
		self:hideDialogLayer()
		self.isShow = false

		if self.end_call_back~=nil then
			self.end_call_back()
			self.end_call_back = nil
		end
	end
end

function sailorBattlePlot:plotCallBack(call_back)  -- 剧情播放完毕后的回调
	if type(call_back) ~= "function" then
		return 
	end 
	
	self.end_call_back = call_back
end 

function sailorBattlePlot:playPlot(plotTab) -- 播放剧情
	if self.isShow then
		return
	end

	if self.plotParentLayer==nil or tolua.isnull(self.plotParentLayer) then
		cclog("====================plotParentLayer is null, sailor battle playPlot fail!")
		return
	end

	if type(plotTab) ~= "table" or #plotTab < 1 then
		cclog("sailor battle playPlot(plotTab) plotTab is error")
		return 
	end 

	self.plotTab = plotTab
	self.plot_count = #self.plotTab	
	self.curPlot = ""
	self.nextIndex = 1
	self.start_call_back = function() self:playSubPlot() end

	self:showPlot()
end 

return sailorBattlePlot