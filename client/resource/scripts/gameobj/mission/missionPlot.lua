------ 任务剧情相关特效
local sailor_info = require("game_config/sailor/sailor_info")
local commonBase = require("gameobj/commonFuns")
local skipToLayer = require("gameobj/mission/missionSkipLayer")
local plotVoiceAudio=require("gameobj/plotVoiceAudio")
local ui_word = require("game_config/ui_word")
local element_mgr = require("base/element_mgr")
local missionPlot = {}
local RichLabel = require("module/richLabel")

missionPlot.textureRes = {}

--公告处理
local dealAnnouncementView = function(enable)
	if isExplore then

	end
end

function missionPlot:judgeNextSubPlotIsDialog(nextIndex)
    local nextTab = self.plotTab[self.nextIndex]
    if nextTab ~= nil then
      if nextTab[1] == "dialog" then
	     return true
	  else
	    return false
	  end 
    end
end

function missionPlot:judgeNextDialogisHaveEffect(nextIndex)
    local nextTab = self.plotTab[self.nextIndex]
    if nextTab ~= nil then
       if nextTab[1] == "dialog" then
       	  if nextTab[2][7] ~= nil then
       	  	 return true
       	  else
	        return false
	      end
	   else
	      return false
	   end 
	end
end

-- 对话层
function missionPlot:showDialogLayer()    
	if self.notClick == nil then self.notClick = false end
	if self.curPlot == "dialog" and not self.notClick then
		if self.dialog_delay_action then
			local act_mgr = CCDirector:sharedDirector():getActionManager()
			act_mgr:removeAction( self.dialog_delay_action )
			self.dialog_delay_action = nil
		end
		self:endSayAction()
	end
end

--移动对话层
function missionPlot:hideDialogLayer()
	--释放资源
	for k,v in ipairs(self.textureRes) do
		RemoveTextureForKey(v)
	end
	ReleaseTexture(self)
	self.textureRes = {}
end

-------------对话相关-------------
-- item = {seaman_id = 1, name = "", is_right = true, txt = "" }
function missionPlot:say(item)
	local seaman_id = item[1]
	local name = item[2]..":"
	local is_right = (item[3] == 2)
	local txt = item[4] or ""
	txt = commonBase:repString(txt)

	--%p:玩家名 %j:爵位名
	if(string.find(txt,"%%"))then
		local nobilityData = getGameData():getNobilityData()
		local next_nobility_data = nobilityData:getNobilityDataByID(nobilityData:getNobilityID()+1) or {}
		txt = string.gsub(txt, "%%j", next_nobility_data.title or "");

		local player_data = getGameData():getPlayerData()
		txt = string.gsub(txt, "%%p",player_data:getName() or "");
	end

	if not tolua.isnull(self.seaman) then
		self.seaman:removeFromParentAndCleanup(true)
	end 
	if not tolua.isnull(self.name) then
        self.name:removeFromParentAndCleanup(true)
	end
	if not tolua.isnull(self.label) then
		self.label:removeFromParentAndCleanup(true)
	end
	if not sailor_info[seaman_id] then  --用角色信息代替
		print("get_current_head-----------------------------------")
		local playerData = getGameData():getPlayerData()
		local role_id = playerData:getRoleId()
		local role_name = playerData:getName()
		name = string.format("%s%s", role_name, ":")
		local icon = playerData:getIcon()
		icon = string.format("ui/seaman/seaman_%s.png", icon)
		self.textureRes[#self.textureRes + 1] = icon
		self.seaman = display.newSprite(icon)
	else
		print("get_asign_head-----------------------------------")
		local seaman_res = sailor_info[seaman_id].res
		self.textureRes[#self.textureRes + 1] = seaman_res
		self.seaman = display.newSprite(seaman_res)
	end
	self.plotView:addChild(self.seaman, -1)	
    local seaman_width = self.seaman:getContentSize().width
	local scale = 130/seaman_width
	self.seaman:setScale(scale)
	self.seaman:setAnchorPoint(ccp(0,0))
	self.seaman:setOpacity(0)
	local function act_call_back(is_right)
	    local ac1 = CCFadeIn:create(0.2)
	    if not tolua.isnull(self.seaman) then
			if not is_right then
				self.last_dir = 0
				-- 头像
				self.seaman:setPosition(ccp(120, 0))		
			else
				-- 头像
				self.last_dir = 1
				self.seaman:setPosition(ccp(700, 0))
			end
			self.seaman:runAction(ac1)
		end
		if not tolua.isnull(self.name) then
			self.name:removeFromParentAndCleanup(true)
		end
		self.name = createBMFont({text = name, fontFile = FONT_CFG_1, size = 20, 
					color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 0, y = 0})
		self.name:setAnchorPoint(ccp(0, 1))
		self.plot_black:addChild(self.name)

		if tolua.isnull(self.label) then 
			--self.label = RichLabel.new({str = txt,font = FONT_CFG_1,fontSize = 18,rowWidth = 560,rowSpace = 4,color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})	
		    local txt1 = "$(c:COLOR_CREAM_STROKE)" .. txt
			self.label = createRichLabel( txt1, 560, 34, 18, 4 );
			self.label:setAnchorPoint(ccp(0, 1))
		    local lx, ly = 270, math.floor(self.plot_black:getContentSize().height * 0.65) - 25
		    self.label:setPosition(lx, ly)	
			self.plot_black:addChild(self.label)
		else
			self.label:removeFromParentAndCleanup(true)
			local txt1 = "$(c:COLOR_CREAM_STROKE)" .. txt
			self.label = createRichLabel( txt1, 560, 34, 18, 4 );	
			self.label:setAnchorPoint(ccp(0, 1))
		    local lx, ly = 270, math.floor(self.plot_black:getContentSize().height * 0.65) - 25
		    self.label:setPosition(lx, ly)	
			self.plot_black:addChild(self.label)
		end 
		
		if is_right then
			self.name:setPosition(ccp(100, 120))
			self.label:setPosition(ccp(100, 85))
		else
			self.name:setPosition(ccp(290, 120))
			self.label:setPosition(ccp(290,85))
		end
		self.name:runAction(CCFadeIn:create(0.4))
	    self.label:runAction(CCFadeIn:create(1))
	end 
	
	local plotPosY = -3
	-- 剧情动画表现
	if tolua.isnull(self.plot_black) then
		self.plot_black = getChangeFormatSprite("ui/bg/bg_plot.png")
		self.plotView:addChild(self.plot_black, -2)
		local ac_time = 0.2	
			if not is_right then  -- 头像放左边   	
				-- 对话条
				self.plot_black:setAnchorPoint(ccp(0, 0))
				self.plot_black:setOpacity(0)
				self.plot_black:setPosition(ccp(0, plotPosY))	
				local ac1 = CCFadeIn:create(ac_time)
				local ac2 = CCCallFunc:create(function() act_call_back(is_right) end)
				self.plot_black:runAction(CCSequence:createWithTwoActions(ac1, ac2))
			else            -- 右边
				-- 对话条
				self.plot_black:setAnchorPoint(ccp(1, 0))
				self.plot_black:setOpacity(0)
				self.plot_black:setPosition(ccp(display.width, plotPosY))	
				local ac1 = CCFadeIn:create(ac_time)
				local ac2 = CCCallFunc:create(function() act_call_back(is_right) end)
				self.plot_black:runAction(CCSequence:createWithTwoActions(ac1, ac2))			
			end 
	else
	    act_call_back(is_right)
	end 	
end 

-- 结束对话动画
function missionPlot:endSayAction()
    local isDialog = self:judgeNextSubPlotIsDialog(self.nextIndex)
    if  isDialog ~=nil and isDialog == false then
    	local ac_time = 0.2
		local plotPosY = -8
		local ac1 = CCFadeOut:create(ac_time)
		local ac2 = CCCallFunc:create(function() 
			self.plot_black:removeFromParentAndCleanup(true)
			self:playSubPlot()

		end)
		self.plot_black:runAction(CCSequence:createWithTwoActions(ac1, ac2))
		self.label:removeFromParentAndCleanup(true)
		if not tolua.isnull(self.name) then
			self.name:removeFromParentAndCleanup(true)
		end
		self.seaman:removeFromParentAndCleanup(true)

	else
		self:playSubPlot()
    end
end 

-- 显示对话
function missionPlot:showDialog(dialogTab) 
	if tolua.isnull(self.plotView) then 
		return 
	end
	if not tolua.isnull(self.plotView.panel) then
		if not self.plotView.panel:isVisible() then
			self.plotView.panel:setVisible(true)
		end
	end
	if dialogTab then
		self:say(dialogTab)
		self.dialog_voice_key = dialogTab[7]
		if self.dialog_voice_key then
		   self.dialog_voice_handler = plotVoiceAudio.playVoiceEffect(self.dialog_voice_key)
		end
		if self.dialog_delay_action then
			local act_mgr = CCDirector:sharedDirector():getActionManager()
			act_mgr:removeAction( self.dialog_delay_action )
			self.dialog_delay_action = nil
		end

		local acTime = dialogTab[5] or 2
		local ac1 = CCDelayTime:create(acTime)
		local ac2 = CCCallFunc:create(function() 
			self.dialog_delay_action = nil
			self:endSayAction() 
		end)
		local seq = CCSequence:createWithTwoActions(ac1, ac2)
		self.dialog_delay_action = self.plotView:runAction(seq)
	end
end

------------------------------特效相关------------------------------
function missionPlot:play_effect(effectTab, spe_callback)	
	local effect_id = effectTab[1]
	local effect_pos = effectTab[2]
	if type(effect_pos[1]) == "number" and type(effect_pos[2]) == "number" then
		effect_pos = { {effect_pos[1], effect_pos[2]} }
	end
	local parent_id = effectTab[3]
	local parent = self.plotView
	
	if parent_id then
		parent = self.plot_sprite_list and self.plot_sprite_list[parent_id] or self.plotView
	end

	local composite_effect = require("gameobj/composite_effect")
	for k, pos in pairs(effect_pos) do
		self.click_sp = composite_effect.bollow(effect_id, pos[1], pos[2],  parent, nil,  function() 
		end)
	end

	if type(spe_callback) == "function" then
		spe_callback()
	else
		self:playSubPlot()
	end
end

------------------------------精灵相关------------------------------
function missionPlot:add_sprite(spriteTab)
	local sprite_path = spriteTab[1]
	local sprite_pos = spriteTab[2]
	local sprite_id = spriteTab[3]
	local sprite_scale = spriteTab[4]
	local sprite = display.newSprite(sprite_path)
	sprite:setOpacity(0)
	self.textureRes[#self.textureRes + 1] = sprite_path
	if sprite then
		sprite:setAnchorPoint(ccp(0,0))
		sprite:setPosition( sprite_pos[1], sprite_pos[2])
		if sprite_scale then
			sprite:setScale( sprite_scale )
		end
		
		self.plotView:addChild(sprite, -3)
		dealAnnouncementView(false)
		if sprite_id then
			self.plot_sprite_list = self.plot_sprite_list or {}
			self.plot_sprite_list[sprite_id] = sprite
		end

		self.add_sprite_voice_key = spriteTab[5]
		if self.add_sprite_voice_key then
			self.bg_voice_handle = plotVoiceAudio.playVoiceEffect(self.add_sprite_voice_key)
		end
	end	
	self:playSubPlot()
end


------------------------------对图片进行裁剪------------------------------
function missionPlot:addTailorImage(tailorTab)
	local image = tailorTab[1]
	local rectInfo = tailorTab[2]
	local pos = tailorTab[3]
	local spriteId = tailorTab[4]
	local spriteScale = tailorTab[5]
	
	local rect = CCRect(rectInfo[1], rectInfo[2], rectInfo[3], rectInfo[4])
	local imageSp = display.newSprite(image)
	self.textureRes[#self.textureRes + 1] = image
	local sprite  = CCSprite:createWithTexture(imageSp:getTexture(), rect)
	if sprite then
		self.plotView:addChild(sprite, -3)
		if spriteId then
			self.plot_sprite_list = self.plot_sprite_list or {}
			self.plot_sprite_list[spriteId] = sprite
		end
		if pos then
			sprite:setPosition(pos[1], pos[2])
		else
			sprite:setPosition(display.cx, display.cy)
		end
		if spriteScale then
			sprite:setScale( spriteScale )
		end
	end
	self:playSubPlot()
end

------------------------------精灵缩放------------------------------
function missionPlot:sprite_scaleTo(spriteTab)
	if self.plot_sprite_list then
		local spriteId = spriteTab[1]
		local isfindSpriteId = false
		for id, sprite in pairs(self.plot_sprite_list) do
			if id == spriteId then
				local scaleVal = spriteTab[2]
				local actionTime = spriteTab[3] or 0.8
				local immedia = spriteTab[4] or false
				
				local x, y = sprite:getPosition()
				local actScale = CCScaleTo:create(actionTime, scaleVal[1], scaleVal[2])
				if immedia then
					sprite:runAction( actScale )
					self:playSubPlot()
				else	
					local ac2 = CCCallFunc:create(function() self:playSubPlot()  end)
					sprite:runAction(CCSequence:createWithTwoActions(actScale, ac2))
				end
				isfindSpriteId = true
				break
			end
		end
		if not isfindSpriteId then self:playSubPlot() end
	end
end

------------------------------精灵移动------------------------------
function missionPlot:sprite_moveTo(spriteTab)
	if self.plot_sprite_list then
		local sprite_id = spriteTab[1]
		local isfindSpriteId = false
		for s_id, sprite in pairs(self.plot_sprite_list) do
			if s_id == sprite_id then
				local des_pos = spriteTab[2]
				local delay_time = spriteTab[3] or 0.8
				local immedia = spriteTab[4] or false
				
				local x, y = sprite:getPosition()
				local actMove = CCMoveTo:create(delay_time, CCPoint(des_pos[1], des_pos[2]))
				if immedia then
					sprite:runAction( actMove )
					self:playSubPlot()
				else	
					local ac2 = CCCallFunc:create(function() self:playSubPlot()  end)
					sprite:runAction(CCSequence:createWithTwoActions(actMove, ac2))
				end
				isfindSpriteId = true
			end
		end
		if not isfindSpriteId then self:playSubPlot() end
	end
end

------------------------------精灵来回移动------------------------------
function missionPlot:sprite_moveback(spriteTab)
	local isFindSprite = false
	if self.plot_sprite_list then
		local sprite_id = spriteTab[1]
		for s_id, sprite in pairs(self.plot_sprite_list) do
			if s_id == sprite_id then
				local des_pos = spriteTab[2]
				local delay_time = spriteTab[3] or 0.1
				
				local x, y = sprite:getPosition()
				local actMove = CCMoveBy:create(delay_time, CCPoint(x-des_pos[1], y-des_pos[2]))
				local actMoveBack = actMove:reverse()
				local actTravel = CCSequence:createWithTwoActions( actMove , actMoveBack )
				local actCallFun = CCCallFunc:create(function() self:playSubPlot() end)
				sprite:runAction(CCSequence:createWithTwoActions(actTravel, actCallFun))
				isFindSprite = true
			end
		end
	end
	
	if not isFindSprite then
		self:playSubPlot() 
	end
end

------------------------------精灵淡出------------------------------
function missionPlot:sprite_fadeout( sprite_tab )
	local sprite_id = sprite_tab[1]
	local time = sprite_tab[2] or 1
	local immedia = sprite_tab[3] or false
	local sprite = self.plot_sprite_list and self.plot_sprite_list[sprite_id]
	if not sprite then
		self:playSubPlot()
		return
	end

	local act = CCFadeOut:create(time)
	if immedia then
		sprite:runAction(act)
		self:playSubPlot()
	else
		local ac2 = CCCallFunc:create(function() 
			if self.dialog_voice_handler then
				audioExt.stopEffect(self.dialog_voice_handler)
			end
			audioExt.resumeMusic() 
		end)
		local ac3 = CCCallFunc:create(function() 
			dealAnnouncementView(true)
			self:playSubPlot()  
		end)
        local array = CCArray:create()
        array:addObject(act)
        array:addObject(ac2)
        array:addObject(ac3)
		sprite:runAction(CCSequence:create(array))		
	end
end

------------------------------精灵淡入------------------------------
function missionPlot:sprite_fadein( sprite_tab )
    audioExt.pauseMusic()
	local sprite_id = sprite_tab[1]
	local time = sprite_tab[2] or 1
	local immedia = sprite_tab[3] or false
	local sprite = self.plot_sprite_list and self.plot_sprite_list[sprite_id]
	if not sprite then
		self:playSubPlot()
		return
	end

	local act = CCFadeIn:create(time)
	if immedia then
		sprite:runAction(act)
		self:playSubPlot()
	else
		local ac2 = CCCallFunc:create(function() self:playSubPlot()  end)
		sprite:runAction(CCSequence:createWithTwoActions(act, ac2))		
	end
end
------------------------------添加层------------------------------
function missionPlot:add_layer(layer_tab)
	local layer_id = layer_tab[1]
	local layer = CCLayer:create()
	self.plotView:addChild(layer, -3)
	self.plot_layer_list = self.plot_layer_list or {}
	self.plot_layer_list[layer_id] = layer
	self:playSubPlot()
end

------------------------------延迟------------------------------
function missionPlot:delayTime(ticktab)
	local tick = ticktab[1]
	local ac1 = CCDelayTime:create(tick)
	local ac2 = CCCallFunc:create(function() 
		self:playSubPlot() 
	end)
	local seq = CCSequence:createWithTwoActions(ac1, ac2)
	self.plotView:runAction(seq)
end

------------------------------淡入------------------------------
function missionPlot:mask_fadeIn(fadeTab)
	if tolua.isnull(self.plotView) then
		return
	end
	if not tolua.isnull(self.mask_layer) then
		self.mask_layer:removeFromParentAndCleanup(true)
		self.mask_layer  = nil
	end

	self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255))
	self.plotView:addChild(self.mask_layer, -3)
		
	local fade_time = fadeTab and fadeTab[1] or 1
	local actions = {}
	actions[1] = CCFadeIn:create(fade_time)
	actions[2] = CCCallFunc:create( function()
		self:playSubPlot()
	end)
	local action = transition.sequence(actions)
	self.mask_layer:runAction(action)
end

------------------------------淡出------------------------------
function missionPlot:mask_fadeOut(fadeTab)
	if not self.mask_layer then
		self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255))
		self.plotView:addChild(self.mask_layer, -4)
	else
		self.mask_layer:setOpacity(255)
	end
	
	local fade_time = fadeTab and fadeTab[1] or 1	
	local actions = {}
	actions[1] = CCFadeOut:create(fade_time)
	actions[2] = CCCallFunc:create( function()
		self.plotView:removeChild( self.mask_layer )
		self.mask_layer = nil
		self:playSubPlot()
	end)
	local action = transition.sequence(actions)
	self.mask_layer:runAction(action)
end

------------------------------淡入淡出------------------------------
function missionPlot:mask_fade(fadeTab)
	if self.mask_layer then
		self.plotView:removeChild( self.mask_layer  )
		self.mask_layer  = nil
	end

	self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255))
	self.plotView:addChild(self.mask_layer, -3)
	
	local fade_time = fadeTab and fadeTab[1] or 1
	local actions = {}
	actions[1] = CCFadeIn:create(fade_time)
	actions[2] = CCFadeOut:create(fade_time)
	actions[3] = CCCallFunc:create( function()
		self.plotView:removeChild( self.mask_layer )
		self.mask_layer = nil
		self:playSubPlot()
	end)
	local action = transition.sequence(actions)
	self.mask_layer:runAction(action)
end

----------------------------界面场景跳转--------------------------------------
function missionPlot:gotoLayer(layerName)
	if getUIManager():isLive("ClsTeamMissionPortUI") then
		local skipMissLayer = skipToLayer:skipLayerByName(layerName)
	else
		getGameData():getMissionData():addPanel2List(layerName)
	end
	-- if skipMissLayer then
	-- 	EventTrigger(EVENT_DEL_PORT_ITEM)
	-- 	EventTrigger(EVENT_ADD_PORT_ITEM, skipMissLayer, nil, false)
	-- else
	-- 	skipToLayer:isSkipPortLayer(layerName)
	-- end
	self:playSubPlot()
end


------------------------------播放音效------------------------------
function missionPlot:play_music_effect(tab)
   local voiceKey = tab[1]
   local isLoop = tab[2]
   plotVoiceAudio.playVoiceEffect(voiceKey,isLoop)
   self:playSubPlot()
end

------------------------------播放背景音乐------------------------------
function missionPlot:play_bgmusic(tab)
  local voiceKey = tab[1]
  local isLoop = tab[2]
  plotVoiceAudio.playVoiceBgMusice(voiceKey,isLoop)
  self:playSubPlot()
end

function missionPlot:play_3d_scene(tab)
	self:playSubPlot()
	-- require("gameobj/mission3d/clsMission3dUi").new(self.plotView, tab[1], function() self:playSubPlot() end)
end

------------------------------效果函数调用表------------------------------
local PLOT_FUNC_DICT = {
    ["music_effect"] = missionPlot.play_music_effect,
    ["bgmusic"] = missionPlot.play_bgmusic,
	["dialog"] = missionPlot.showDialog,
	["delay"] = missionPlot.delayTime,
	["sprite"] = missionPlot.add_sprite,
	["sprite_moveback"] = missionPlot.sprite_moveback,
	["sprite_moveto"] = missionPlot.sprite_moveTo,
	["sprite_fadeout"] = missionPlot.sprite_fadeout,
    ["sprite_fadein"] = missionPlot.sprite_fadein,
	["effect"] = missionPlot.play_effect,
	["layer"] = missionPlot.add_layer,
	["mask_fade"] = missionPlot.mask_fade,
	["mask_fadeIn"] = missionPlot.mask_fadeIn,
	["mask_fadeOut"] = missionPlot.mask_fadeOut,
	["tailor"] = missionPlot.addTailorImage,
	["sprite_scaleto"] = missionPlot.sprite_scaleTo,
	["goto_layer"] = missionPlot.gotoLayer,
	["play_3d_scene"] = missionPlot.play_3d_scene,
}

------------------------------每个子剧情------------------------------
function missionPlot:playSubPlot()
	if self.dialog_voice_handler ~= nil and type(self.dialog_voice_handler) == "number" and self:judgeNextSubPlotIsDialog(self.nextIndex) then
		audioExt.stopEffect(self.dialog_voice_handler)
		self.dialog_voice_handler = nil
	end
	if self.nextIndex > self.plot_count then 
		self:hidePlot()
		return 
	end 
	local curTab = self.plotTab[self.nextIndex]
	self.curPlot = curTab[1]
	self.notClick = curTab[2][6] or false	  --为dialog时，判断点击背景是否能结束当前对话(false为可点击，true为不可点)
	self.last_dir = -1  -- 上一次对话的位置， -1为空，0为左， 1为右
	
	self.nextIndex = self.nextIndex + 1
	if PLOT_FUNC_DICT[self.curPlot] then	
		PLOT_FUNC_DICT[self.curPlot](self, curTab[2])
	else
		cclog( string.format("play plot error:the plot type %s is nil", self.curPlot) )
	end
end 

------------------------------剧情播放------------------------------
function missionPlot:showPlot()
	if not self.isShow then 
		if not tolua.isnull(self.plotView) then
			self.plotView:showDialog(self.noSkip, self.dialog_voice_handler, self.bg_voice_handle)
			self.isShow = true
		else
			self:plotEndCallBack()
		end
	end
end 

function missionPlot:hidePlot()
	if self.isShow then 
		self.plotView:hideDialog()
		-- self:plotEndCallBack()
	end

	if self.isSpecialShow then
		self:plotEndCallBack()
	end 
end

function missionPlot:plotEndCallBack()
	if self.isShow then self.isShow = false end
	if self.isSpecialShow then self.isSpecialShow = false end
	if type(self.end_call_back) == "function" then
		self.end_call_back()
		self.end_call_back = nil			
	end 
end

----------------------------设置剧情播放完毕后的回调--------------------
function missionPlot:plotCallBack(call_back)  
	if type(call_back) ~= "function" then
		return 
	end 
	
	if self.isShow then 
		-- 正在播放剧情, 完毕后回调
		self.end_call_back = call_back
	else
		-- 没有剧情，直接回调
		call_back()     
	end
end 

----------------------------播放剧情----------------------------
function missionPlot:playPlot(plotTab, noSkip) 
	if type(plotTab) ~= "table" or #plotTab < 1 then
		return 
	end 
	--plotTab表示mission_x_info表中的mission_plot字段
	self.plotTab = plotTab
	self.plot_count = #self.plotTab	
	self.curPlot = ""
	self.nextIndex = 1
	self.textureRes = {}
	self.noSkip = noSkip
	--TODO 运行容错
	if not tolua.isnull(getUIManager():get("ClsPlotView")) then
		getUIManager():close("ClsPlotView")
	end
	audioExt.pauseMusic()
	self.plotView = getUIManager():create("gameobj/mission/clsPlotView")
	self:showPlot()
	self:playSubPlot()
end

function missionPlot:playSpecialPlot(plotTab, noSkip)
	if type(plotTab) ~= "table" or #plotTab < 1 then return end
	self.isSpecialShow = true
	getUIManager():create("gameobj/mission/clsPlotMission", nil, plotTab, noSkip)
end 

return missionPlot
