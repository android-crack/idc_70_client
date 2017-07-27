------ 战斗剧情相关
local ui_word = require("game_config/ui_word")
local commonBase = require("gameobj/commonFuns")
local plotVoiceAudio=require("gameobj/plotVoiceAudio")
local sailor_info = require("game_config/sailor/sailor_info")
local role_info = require("game_config/role/role_info")
local char_mask_layer = require("gameobj/battle/CharMaskLayer")
local battleRecording = require("gameobj/battle/battleRecording")

local battlePlot = {}

---------------------辅助函数------------------------
-- 判断下一个子剧情是否是dialog
function battlePlot:judgeNextSubPlotIsDialog(nextIndex)
    local nextTab = self.plotTab[self.nextIndex]
	if nextTab ~= nil then
		if nextTab["plot"] == "dialog" then
			return true
		end
	end
end

--判断上一个子剧情是否是dialog
function battlePlot:judgeForwardSubPlotIsDialog(forwardIndex)
	local forwardTab = self.plotTab[forwardIndex]
	if forwardTab ~= nil then
		if forwardTab["plot"] == "dialog" then
			return true
		end 
	end
end

function battlePlot:judgeNextDialogisHaveEffect(nextIndex)
    local nextTab = self.plotTab[self.nextIndex]
    if nextTab ~= nil then
		if nextTab["plot"] == "dialog" then
			if nextTab["param"][7] ~= nil then
				return true
			end
		end 
	end
end

function battlePlot:setSkipFlag(value)
	self.skip_flag = value
end

function battlePlot:getSkipFlag()
	return self.skip_flag
end

function battlePlot:createDialogLayer(parent)
	local layer = CCLayer:create()
	parent:regTouchEvent(layer, function(eventType, x, y) 
		if eventType =="began" then 
			self:setSkipFlag(true)

			if self.curPlot == "dialog" and getGameData():getBattleDataMt():isSkipPlot() then
				local no_skip = self.curPlotTab[6]
				if not no_skip then
					if self.dialog_delay_action  then
						local act_mgr = CCDirector:sharedDirector():getActionManager()
						act_mgr:removeAction( self.dialog_delay_action )
						self.dialog_delay_action = nil
					end
					
					if self.is_say_over then -- 对话完成
						self:endSayAction()
					end
				end
				return true 
			end
			if CCRect(0, 0, display.width / 3, display.height / 3):containsPoint(ccp(x, y)) then
				return false
			end
			return true
		end
	end)
	return layer
end

function battlePlot:setPlotParentLayer(layer)
	self.plotParentLayer = layer
end

function battlePlot:getPlotParentLayer()
	local battle_data = getGameData():getBattleDataMt()
	return self.plotParentLayer or getUIManager():get("battle_plot_ui")
end

function battlePlot:showDialogLayer()    --对话层
	local polt_layer = self:getPlotParentLayer()
	if tolua.isnull(self.dialogLayer) then 
		self.dialogLayer = self:createDialogLayer(polt_layer)
		polt_layer:addChild(self.dialogLayer, -1)
	end 
end

function battlePlot:hideDialogLayer()
	if not tolua.isnull(self.dialogLayer) then
		self.dialogLayer:removeFromParentAndCleanup(true)
		self.dialogLayer = nil
	end
end

-------------对话相关-------------
local function hideDialogIcon()
	if not tolua.isnull(battlePlot.dialogIcon) then 
		battlePlot.dialogIcon:stopAllActions()
		battlePlot.dialogIcon:removeFromParentAndCleanup(true)
		battlePlot.dialogIcon = nil 
	end 
end 

-- 剧情说话冒泡
local function showDialogIcon(ship_id)
	if not tolua.isnull(battlePlot.dialogIcon) then 
		if battlePlot.dialogIcon.ship_id == ship_id then 
			return
		else 
			hideDialogIcon()
		end 
	end 
	
	local sp = display.newSprite("#common_dialog.png", -40, 60)
	local p1 = display.newSprite("#common_dialog_point.png", 14, 30)
	local p2 = display.newSprite("#common_dialog_point.png", 24, 30)
	local p3 = display.newSprite("#common_dialog_point.png", 34, 30)
	sp:addChild(p1)
	sp:addChild(p2)
	sp:addChild(p3)
	battlePlot.dialogIcon = sp 
	
	local ani_tick = 0.4
	local actions = {}
	actions[1] = CCCallFunc:create(function() 
		p1:setVisible(true)
		p2:setVisible(true)
		p3:setVisible(true)
	end)
	actions[2] = CCDelayTime:create(ani_tick)
	actions[3] = CCCallFunc:create(function() 
		p1:setVisible(false)
		p2:setVisible(false)
		p3:setVisible(false)
	end)
	actions[4] = CCDelayTime:create(ani_tick)
	actions[5] = CCCallFunc:create(function()
		p1:setVisible(true)
	end)
	actions[6] = CCDelayTime:create(ani_tick)
	actions[7] = CCCallFunc:create(function()
		p2:setVisible(true)
	end)
	actions[8] = CCDelayTime:create(ani_tick)
	local action = transition.sequence(actions)
	local battle_data = getGameData():getBattleDataMt()
	local SHIPS = battle_data:GetShips()
	for k, ship_data in pairs(SHIPS) do
		if ship_data.baseData.id == ship_id then 
			if ship_data.isDeaded then return end 
			ship_data.body.ui:addChild(sp)
			sp:runAction(CCRepeatForever:create(action))	
			break 
		end 
	end 
end

function battlePlot:say(item)
	if not self.dialogLayer then return end

	local seaman_id = item[1]
	local name = item[2] .. ":"
	local is_right = (item[3] == 2)
	local txt = item[4] or ""
	txt = commonBase:repString(txt)
	if not tolua.isnull(self.seaman) then
		self.seaman:removeFromParentAndCleanup(true)
	end 
	if not tolua.isnull(self.name) then
    	self.name:removeFromParentAndCleanup(true)
	end
	if not tolua.isnull(self.label) then
    	self.label:removeFromParentAndCleanup(true)
	end
	if not sailor_info[seaman_id] then  
		if type(seaman_id) == "string" then     --直接使用图片
			self.seaman = display.newSprite(seaman_id)
		else--用角色信息代替
			name = string.format("%s%s", self.sailor_name, ":")
			local icon = string.format("ui/seaman/seaman_%s.png", self.sailor_id)
			self.seaman = display.newSprite(icon)
		end
	else--水手配置表
		local seaman_res = sailor_info[seaman_id].res
		self.seaman = display.newSprite(seaman_res)
	end 
	self.seaman:setOpacity(0)
	self.dialogLayer:addChild(self.seaman, 2)
	local seaman_width = self.seaman:getContentSize().width
	local show_width = 130
	local scale = show_width/seaman_width
	self.seaman:setScale(scale)
	self.seaman:setAnchorPoint(ccp(0,0))
	
	if is_right then
		self.last_dir = 1
		self.seaman:setPosition(ccp(700, 0))
	else 
		self.last_dir = 0
		self.seaman:setPosition(ccp(120, 0))	
	end 
	
	local function act_call_back(is_right)
	    local ac1 = CCFadeIn:create(0.2)
		self.seaman:runAction(ac1)
		if not tolua.isnull(self.name) then
			self.name:removeFromParentAndCleanup(true)
		end

		self.name = createBMFont({text = name, size = 20, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),fontFile = FONT_CFG_1})
		self.name:setAnchorPoint(ccp(0, 1))
		self.plot_black:addChild(self.name)

		------------------------------------------------------
		-- modify By Hal 2015-09-06, Type(BUG) - redmine 19304
		-- 在富文本未能支持setString接口前，暂时此是处理。
		if not tolua.isnull( self.label ) then
			self.label:removeFromParentAndCleanup( true );
			self.label = nil;
		end
		------------------------------------------------------

		if tolua.isnull(self.label) then 
			local txt1 = "$(font:FONT_CFG_1)" .. txt
			self.label = createRichLabel( txt1, 560, 34, 18, 4 );
			self.plot_black:addChild(self.label)
		else
			self.label:setString(txt)
		end 
		local lab_height_n = self.label:getContentSize().height
		local lab_y = math.floor(self.plot_black:getContentSize().height * 0.5) + 4 - lab_height_n/2
		local offset  = 25 - lab_height_n

		--头像在左还是右
		local lx_n, ly_n = 290, 120  -- name 
		local rx_n, ry_n = 100, 120
		local lx_l, ly_l = 293, 60   -- label 
		local rx_l, ry_l = 100, 60
		if is_right then
			self.name:setPosition(ccp(rx_n, ry_n))
			self.label:setPosition(ccp(rx_l, ry_l + offset))
		else
			self.name:setPosition(ccp(lx_n, ly_n))
			self.label:setPosition(ccp(lx_l, ry_l + offset))
		end
		self.name:runAction(CCFadeIn:create(0.2))
	    self.label:runAction(CCFadeIn:create(1))

		self.is_say_over = true
	end 
	
	local plotPosY = -3
	local function plot_black_Armature()
		local ac_time = 0.2	
		if not is_right then  -- 头像放左边
			-- 对话条
			self.plot_black:setAnchorPoint(ccp(0, 0))
			self.plot_black:setOpacity(0)
			self.plot_black:setPosition(ccp(0, plotPosY))	
			local ac1 =  CCFadeIn:create(ac_time)
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
	end
	-- 剧情动画表现
	if tolua.isnull(self.plot_black) then
		self.plot_black = getChangeFormatSprite("ui/bg/bg_plot.png")
		self.dialogLayer:addChild(self.plot_black, 1)
	    plot_black_Armature()
	else
		local isDialog =  self:judgeForwardSubPlotIsDialog(self.nextIndex-2)
		if not isDialog then
			plot_black_Armature()
        else
			act_call_back(is_right)
		end
	end 	
end 

function battlePlot:endSayAction()  -- 结束对话动画
    hideDialogIcon()
    self.is_say_over = false
    local isDialog = self:judgeNextSubPlotIsDialog(self.nextIndex)
	if not isDialog then
    	local ac_time = 0.1
		local ac1 = CCFadeOut:create(ac_time)
		local ac2 = CCCallFunc:create(function() 
			self:playSubPlot()
		end)
		self.label:removeFromParentAndCleanup(true)
		self.seaman:runAction(CCFadeOut:create(ac_time))
		if not tolua.isnull(self.name) then
			self.name:runAction(CCFadeOut:create(ac_time))
		end	
		self.plot_black:runAction(CCSequence:createWithTwoActions(ac1, ac2))
	else
		self:playSubPlot()
    end
end 

function battlePlot:showDialog(dialogTab) -- 对话
	if not self.dialogLayer or not dialogTab then return end

	self:say(dialogTab)
	if dialogTab.ship_id then 
		showDialogIcon(dialogTab.ship_id)
	end

	if sailor_info[dialogTab[1]]then
	   self.dialog_voice_key = dialogTab[7]
	   self.dialog_voice_handler = plotVoiceAudio.playVoiceEffect(self.dialog_voice_key)
	else
	
		local defaults_sex = tonumber(role_info[self.role_id].sex)
		if defaults_sex == 1 then --男
			self.dialog_voice_key = dialogTab[7]
		else
			self.dialog_voice_key = dialogTab[8]
		end
		
		self.dialog_voice_handler = plotVoiceAudio.playVoiceEffect(self.dialog_voice_key)

	end

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

-------------------延迟--------------------
function battlePlot:delayTime(ticktab)
	local tick = ticktab[1]
	local ac1 = CCDelayTime:create(tick)
	local ac2 = CCCallFunc:create(function() self:playSubPlot() end)
	local seq = CCSequence:createWithTwoActions(ac1, ac2)
	self.dialogLayer:runAction(seq)
end

-----------------镜头相关----------------
function battlePlot:playCamera(cameraTab, not_play_sub)
	local battle_data = getGameData():getBattleDataMt()
	
	local scene3D = BattleInit3D:getScene()
	local camNode = scene3D:findNode("CameraPlot")
	if not camNode then 
		camNode = scene3D:addNode("CameraPlot")
	end 
	local cPos = ScreenToVector3(display.cx, display.cy, scene3D:getActiveCamera())
	camNode:setTranslation(cPos)
	CameraFollow:LockTarget(camNode)
	
	local keyCount = #cameraTab+1
	local keyTimes = {0}
	local keyValues = {cPos:x(), 0, cPos:z()}
	local Time = 0
	
	if keyCount < 2 then return Time end 
	
	for k, v in ipairs (cameraTab) do
		local t = v[3] or 0.5    -- 时间
		local arg_four = v[4]
		if t <= 0 then t = 0.001 end 
		Time = Time + t
		local pos = cocosToGameplayWorld(ccp(v[1], v[2]))
		local ship = battle_data:getCurClientControlShip()
		if arg_four and ship then
			pos = ship:getPosition3D()
		end
		table.insert(keyTimes, Math.round(Time*1000))
		table.insert(keyValues, pos:x())
		table.insert(keyValues, 0)
		table.insert(keyValues, pos:z())
	end 
	
	local anim = camNode:createAnimation("camMove", Transform.ANIMATE_TRANSLATE(),
				keyCount, keyTimes, keyValues, "LINEAR")
	anim:play()  
	if not_play_sub then
		
	else
		local ac1 = CCDelayTime:create(Time)
		local ac2 = CCCallFunc:create(function()		
			self:playSubPlot()
		end)
		local ac = CCSequence:createWithTwoActions(ac1, ac2)
		getUIManager():get("battle_plot_ui"):runAction(ac)
	end
	return Time
end

function battlePlot:cameraScale( cameraTab )
	local battle_data = getGameData():getBattleDataMt()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	local cameraPos = cameraTab[1]
	local scale = cameraTab[2]*BATTLE_SCALE_RATE
	local scale_time = cameraTab[3] or 1
	
	local scale_min = battle_data:GetData("scale_min")
	local scale_max = battle_data:GetData("scale_max")
	scale = Math.clamp(scale_min, scale_max, scale)
	
	local vec = cocosToGameplayWorld(ccp(cameraPos[1], cameraPos[2]))
	local screen_pos = Vector3ToScreen(vec, BattleInit3D:getScene():getActiveCamera())
	local pos = ccp(screen_pos:x(), screen_pos:y())
	
	if scale_time <= 0 then 
		CameraFollow:ScaleByScreenPos(scale, pos)
		self:playSubPlot()
	else 
		local battle_layer = battle_data:GetLayer("battle_scene_layer") 
		local old_scale = battle_layer:getScale()
		local Dscale = (scale - old_scale)/scale_time
		local time_count = 0
		local function doscale(dt)
			if time_count >= scale_time then 
				scheduler:unscheduleScriptEntry(self.hander_time) 
				self.hander_time = nil
				return 
			end 
			time_count = time_count + dt
			local new_scale = old_scale + Dscale*time_count
			CameraFollow:ScaleByScreenPos(new_scale, pos)	
		end 
		
		if self.hander_time then 
			scheduler:unscheduleScriptEntry(self.hander_time) 
			self.hander_time = nil
		end
		self.hander_time = scheduler:scheduleScriptFunc(doscale, 0, false)
		
		local ac1 = CCDelayTime:create(scale_time)
		local ac2 = CCCallFunc:create(function()
			self:playSubPlot()
			if self.hander_time then 
				scheduler:unscheduleScriptEntry(self.hander_time) 
				self.hander_time = nil
			end
		end)
		local ac = CCSequence:createWithTwoActions(ac1, ac2)
		getUIManager():get("battle_plot_ui"):runAction(ac)
	end 
end

function battlePlot:layerScale( layerScaleTab )
	local layer_id = layerScaleTab[1]
	local layer = self.plot_layer_list and self.plot_layer_list[layer_id]

	if tolua.isnull(layer) then
		return
	end

	if layer.scaleAc1~=nil then
		layer:stopAction(layer.scaleAc1)
		layer.scaleAc1 = nil
	end

	local oldScale = layer:getScale()
	local oldSize = layer:getContentSize()
	local newScale = layerScaleTab[2]*BATTLE_SCALE_RATE
	local newSize = CCSizeMake(oldSize.width*newScale,oldSize.height*newScale)
	local scaleTime = layerScaleTab[3]

	local oldPos = ccp(layer:getPositionX(),layer:getPositionY())
	local newPos = ccp(0,0)
	newPos.x = (oldSize.width - newSize.width)/2
	newPos.y = (oldSize.height - newSize.height)/2

	local array = CCArray:create()

	local array1 = CCArray:create()
	array1:addObject(CCScaleTo:create(scaleTime, newScale))
	array:addObject(CCSpawn:create(array1))
	array:addObject(CCCallFunc:create(function()
		self:playSubPlot()
	end))

	local ac = CCSequence:create(array)
	layer.scaleAc1 = ac
	layer:runAction(ac)
end

-----------------------------------------
--精灵相关
function battlePlot:add_sprite(spriteTab)
	local sprite_path = spriteTab[1]   -- 资源路径
	local sprite_pos = ccp(spriteTab[2][1], spriteTab[2][2])    -- 位置
	local sprite_id = spriteTab[3]     -- id（必须唯一）
	local sprite_scale = spriteTab[4] or 1 -- 缩放比例，默认不缩放
	local parent_layer_id = spriteTab[5]   -- 放哪一层，默认第一层
	local is_fadein = (spriteTab[6] ~= 0)         -- 是否淡入，默认不淡入
	local duraction = spriteTab[7] or 1    -- 淡入时间，不填默认1
	local texture_format = spriteTab[8]    -- 压缩格式，不填默认 RGBA8888
	--音效
	local voice_delay_time = 0
	local voice_key = ""
	if spriteTab[9] then
		voice_delay_time = spriteTab[9][1] or 0
		voice_key = spriteTab[9][2] or ""
	end

	local parent_layer = (parent_layer_id and self.plot_layer_list and self.plot_layer_list[parent_layer_id]) or self.dialogLayer
	local sprite = nil 
	if TextureFormat[texture_format] then 
		CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat[texture_format])
		sprite = display.newSprite(sprite_path)
		CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
	else
		sprite = display.newSprite(sprite_path)
	end 

	sprite:setAnchorPoint(ccp(0,0))
	sprite:setPosition(sprite_pos)
	sprite:setScale(sprite_scale)
	parent_layer:addChild(sprite)
	
	if sprite_id then
		self.plot_sprite_list = self.plot_sprite_list or {}
		self.plot_sprite_list[sprite_id] = sprite
	end
	
	if is_fadein then
		sprite:setOpacity(0)
		local ac1 = CCFadeIn:create(duraction)
		local ac2 = CCCallFunc:create(function()
			self:playSubPlot()
		end)
		local ac3 = CCDelayTime:create(voice_delay_time)
		local ac4 = CCCallFunc:create(function()
			if voice_key and voice_key ~="" then
				self.add_sprite_voice_handler = plotVoiceAudio.playVoiceEffect(voice_key)
			end
		end)

		sprite:runAction(CCSpawn:createWithTwoActions(CCSequence:createWithTwoActions(ac1, ac2), CCSequence:createWithTwoActions(ac3, ac4)))
	else
		local ac1 = CCDelayTime:create(0)
		local ac2 = CCCallFunc:create(function()
			self:playSubPlot()
		end)
		local ac3 = CCDelayTime:create(voice_delay_time)
		local ac4 = CCCallFunc:create(function()
			if voice_key and voice_key ~="" then
				self.add_sprite_voice_handler = plotVoiceAudio.playVoiceEffect(voice_key)
			end
		end)

		sprite:runAction(CCSpawn:createWithTwoActions(CCSequence:createWithTwoActions(ac1, ac2), CCSequence:createWithTwoActions(ac3, ac4)))
	end
end

function battlePlot:remove_sprite(sprite_tab)
	local battle_data = getGameData():getBattleDataMt()
	local sprite_id = sprite_tab[1]           -- id 和 add_sprite的对应
	local is_fadeout = sprite_tab[2] ~= 0     --是否淡出
	local duraction = sprite_tab[3] or 1      --淡出时间
	local battle_break = sprite_tab[4] and (sprite_tab[4] == 1)
	
	if battle_break then 
		self:hidePlot(true)
		battleRecording:recordVarArgs("set_win_side", battle_config.our_win)
		return 
	end 
	
	local sprite = self.plot_sprite_list and self.plot_sprite_list[sprite_id]
	if not sprite then
		self:playSubPlot()
		return
	end

	if not is_fadeout then
		sprite:removeFromParentAndCleanup(true)
		self.plot_sprite_list[sprite_id] = nil
		self:playSubPlot()
	else
		local ac1 = CCFadeOut:create(duraction)
		local ac2 = CCCallFunc:create(function()
			sprite:removeFromParentAndCleanup(true)
			self.plot_sprite_list[sprite_id] = nil
			self:playSubPlot()  
		end)
		sprite:runAction(CCSequence:createWithTwoActions(ac1, ac2))		
	end
end

--layer
function battlePlot:add_layer(layer_tab)
	local layer_id = layer_tab[1]

	local layer = CCLayer:create()
	self.dialogLayer:addChild( layer )
	self.plot_layer_list = self.plot_layer_list or {}
	self.plot_layer_list[layer_id] = layer
	self:playSubPlot()
end

function battlePlot:mask_fade()
	if self.mask_layer then
		self.dialogLayer:removeChild( self.mask_layer  )
		self.mask_layer  = nil
	end

	self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255))
	self.dialogLayer:addChild( self.mask_layer )
		
	local actions = {}
	actions[1] = CCFadeIn:create(2)
	actions[2] = CCFadeOut:create(2)
	actions[3] = CCCallFunc:create( function()
		self.dialogLayer:removeChild( self.mask_layer )
		self.mask_layer = nil
		self:playSubPlot()
	end)
	local action = transition.sequence(actions)
	self.mask_layer:runAction(action)
end

function battlePlot:mask_fadeIn(fadeTab)
	local polt_layer = self:getPlotParentLayer()
	if tolua.isnull(polt_layer) then 
		return
	end
	if tolua.isnull(self.dialogLayer) then 
		self.dialogLayer = self:createDialogLayer(polt_layer)
		polt_layer:addChild(self.dialogLayer)
	end 
	if self.mask_layer then
		self.dialogLayer:removeChild( self.mask_layer  )
		self.mask_layer  = nil
	end
	
	self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255), display.width*1.5, display.height*1.5)
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

function battlePlot:mask_fadeOut(fadeTab)
	if not self.mask_layer then
		self.mask_layer = CCLayerColor:create(ccc4(0,0,0,255))
		self.dialogLayer:addChild( self.mask_layer, -1 )
	else
		self.mask_layer:setOpacity(255)
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


function battlePlot:text_display(text_tab)
	local text_list = text_tab[1]
	local text_delay = text_tab[2] or 1
	local text_skip = text_tab[3]
	local temp_pos = text_tab[4]
	local pos = nil
	if type(temp_pos) == "table" then
		pos = ccp(temp_pos[1], temp_pos[2])
	end
	self.text_voice_key = text_tab[4]

	self.text_layer = char_mask_layer.new()
	self.dialogLayer:addChild( self.text_layer )

	local func = function()
		self.dialogLayer:removeChild(self.text_layer)
		self.text_layer = nil
		self:playSubPlot()
	end

	plotVoiceAudio.playVoiceEffect(self.text_voice_key)
	self.text_layer:set_text_list( text_list, text_delay, func, text_skip, pos)
end

function battlePlot:guide(guide_tab)
	local guide_item = {}
	guide_item.radius = guide_tab[1] or 50
	guide_item.pos = { x = guide_tab[2][1], y = guide_tab[2][2]}
	guide_item.rotation = guide_tab[3] or 0
	guide_item.autoRelease = guide_tab[4] or true
	guide_item.guideType = 1

	local guide_layer = createMissionGuideLayer( guide_item )
	self.dialogLayer:addChild( guide_layer )
	guide_layer:setCallFunc(function()
     	self:playSubPlot()
    end)
end

-----------------------------------------------
--sound audio.playSound(sound)
function battlePlot:playSound(soundTab, no_action_next)
	local sound_path = soundTab[1]
	if sound_path then
		--audio.playSound(sound_path)
		audioExt.playEffect(sound_path)
	end

	if not(no_action_next) then
		self:playSubPlot()
	end
end

function battlePlot:btn_click( btn_tab )
	if not self.op_layer then
		self.op_layer = CCLayerColor:create(ccc4(0,0,0,255))
		self.dialogLayer:addChild( self.op_layer, -1 )
		self.op_layer:setOpacity(100)
	else
		self.op_layer:setOpacity(100)
	end

	local btn_pos = btn_tab[1]
	local btn_scale = btn_tab[2]
	local btn_res = btn_tab[3]
	local btn_text = btn_tab[4]
	local btn_effect = btn_tab[5]
	local btn_guid = btn_tab[6]
	self.btn_click_voice_key = btn_tab[7]
	local guild_pos = btn_tab[8] or btn_tab[1]

	if btn_res and btn_res[1] and btn_res[1] ~= "" then
		self.op_layer.btn_equip = MyMenuItem.new({image =btn_res[1],imageSelected=btn_res[2],imageDisabled =btn_res[2],x =btn_pos[1], y =btn_pos[2],
	        fontFile = FONT_SUBTITLE, text = btn_text, fx = 0, fy = -3})
		self.op_layer.btn_equip:setScale(btn_scale)
	end

	-- if btn_effect then
		-- local composite_effect = require("gameobj/composite_effect")
		-- composite_effect.bollow(btn_effect, 0, 0,  self.op_layer.btn_equip, nil,  function() 																	end)
	-- end

	if btn_guid then
		local guide_item = {}
		guide_item.radius = 50
		guide_item.pos = { x = guild_pos[1], y = guild_pos[2]}
		guide_item.rotation = 0
		guide_item.guideType = 1
		guide_item.autoRelease = true

		local guide_layer = createMissionGuideLayer( guide_item )
		self.dialogLayer:addChild( guide_layer )
		guide_layer:setCallFunc(function()
	     	plotVoiceAudio.playVoiceEffect(self.btn_click_voice_key)
			if not tolua.isnull(self.op_layer) then
				self.op_layer:removeFromParentAndCleanup(true)
				self.op_layer = nil
			end
			self:playSubPlot()
	    end)
	else
		self.op_layer.btn_equip:regCallBack( function()
			plotVoiceAudio.playVoiceEffect(self.btn_click_voice_key)
			if not tolua.isnull(self.op_layer) then
				self.op_layer:removeFromParentAndCleanup(true)
				self.op_layer = nil
			end
			self:playSubPlot()	
		end)

		self.op_layer.op_menu = MyMenu.new({self.op_layer.btn_equip})
		self.op_layer:addChild(self.op_layer.op_menu)
	end
end

function battlePlot:cameraMoveAndScale(param) --边移动变缩放
	local move_tab = {[1] = param[1], [2] = param[2]}
	local move_time = self:playCamera(move_tab, true)
	local cameraTab = param[3]

	local scheduler = CCDirector:sharedDirector():getScheduler()
	local scale = cameraTab[2] * BATTLE_SCALE_RATE
	local scale_time = cameraTab[3] or 1
	local battle_data = getGameData():getBattleDataMt()
	local scale_min = battle_data:GetData("scale_min")
	local scale_max = battle_data:GetData("scale_max")
	scale = Math.clamp(scale_min, scale_max, scale)
	
	local battle_layer = battle_data:GetLayer("battle_scene_layer") 
	local old_scale = battle_layer:getScale()
	local Dscale = (scale - old_scale)/scale_time
	local time_count = 0
	local function doscale(dt)
		if time_count >= scale_time then 
			if self.subHandle then
				scheduler:unscheduleScriptEntry(self.subHandle) 
				self.subHandle = nil
			end
			return 
		end 
		time_count = time_count + dt
		local new_scale = old_scale + Dscale*time_count
		CameraFollow:Scale(new_scale)
	end 
	
	self.subHandle = scheduler:scheduleScriptFunc(doscale, 0, false)
	
	local max = math.max(move_time, scale_time)
	local ac1 = CCDelayTime:create(max)
	local ac2 = CCCallFunc:create(function()
		self:playSubPlot()
	end)
	local ac = CCSequence:createWithTwoActions(ac1, ac2)
	getUIManager():get("battle_plot_ui"):runAction(ac)
end

-----------------------------------------
local PLOT_FUNC_DICT = {
	["dialog"] = battlePlot.showDialog,
	["camera"] = battlePlot.playCamera,
	["delay"] = battlePlot.delayTime,
	["add_sprite"] = battlePlot.add_sprite,
	["remove_sprite"] = battlePlot.remove_sprite,
	["layer"] = battlePlot.add_layer,
	["cameraScale"] = battlePlot.cameraScale,
	["layerScale"] = battlePlot.layerScale,
	["mask_fade"] = battlePlot.mask_fade,
	["mask_fadeIn"] = battlePlot.mask_fadeIn,
	["mask_fadeOut"] = battlePlot.mask_fadeOut,
	["text_display"] = battlePlot.text_display,
	["guide"] = battlePlot.guide,
	["btn_click"] = battlePlot.btn_click,
	["cameraMoveAndScale"] = battlePlot.cameraMoveAndScale
}

function battlePlot:pausePlot(plot_pause)
	if not plot_pause then plot_pause = false end
	if not self.is_pause then self.is_pause = false end

	if self.is_pause == plot_pause then return end

	self.is_pause = plot_pause

	if not plot_pause then
		if not self.pause_func then
			self:playSubPlot()
		else
			self.pause_func()
			self.pause_func = nil
		end
	end
end

function battlePlot:clearPlot( ... )
	-- body
	self.is_pause = nil;
	self.pause_func = nil;
end
-------------------------------------------------------

function battlePlot:playSubPlot()     -- 每个子剧情
	if self.is_skip or self.is_pause then return end

	local battle_data = getGameData():getBattleDataMt()
	if self.nextIndex > self.plotCount or not battle_data:IsBattleStart()then --播完
		self.curPlot = ""
		self:hidePlot()

		if self:getSkipFlag() then
			self:setSkipFlag(false)
			battleRecording:recordVarArgs("battle_skip_plot")
		end
		return 
	end 

	local curTab = self.plotTab[self.nextIndex]
	self.curPlot = curTab.plot
	self.curPlotTab = curTab.param
	self.last_dir = -1  -- 上一次对话的位置， -1为空，0为左， 1为右
	
    if self.dialog_voice_handler ~= nil and type(self.dialog_voice_handler) == "number" and self:judgeNextDialogisHaveEffect(self.nextIndex) then
		audioExt.stopEffect(self.dialog_voice_handler)
		self.dialog_voice_handler = nil
	end   

	self.nextIndex = self.nextIndex + 1

	if self.curPlot == "plot" then
		self:setSkipFlag(false)
	end

	if PLOT_FUNC_DICT[self.curPlot] then
		PLOT_FUNC_DICT[self.curPlot](self, curTab.param)
	else
		self:playSubPlot()
	end
end 

-- 剧情播放
function battlePlot:showPlot()
	if self.isShow then return end
	
	local battle_data = getGameData():getBattleDataMt()
	battle_data:GetTable("battle_layer").setBattlePaused(true)
	self:showDialogLayer()
	self.isShow = true
	self.isPlaying = true
end  

-- 剧情播完后，矫正镜头
function battlePlot:cameraCorrect(call_back)
	CameraFollow:StopShake()
	CameraFollow:cancelLockLockTarget()
	
	local battle_data = getGameData():getBattleDataMt()

	local ship = battle_data:getCurClientControlShip()
	if not (ship and ship.body and ship.body.node) or ship.body.node == CameraFollow:getLockTarget() then 
		call_back()
		return 
	end

	cameraTarget = ship.body.node
	
	local scene3D = BattleInit3D:getScene()
	local camNode = scene3D:findNode("CameraPlot")
	if not self.cameraStop then 
		if cameraTarget and camNode then
			CameraFollow:setShakeSwitch(false)
			CameraFollow:LockTarget(camNode)
			local cPos = ScreenToVector3(display.cx, display.cy, scene3D:getActiveCamera())
			camNode:setTranslation(cPos)
			local pos1 = camNode:getTranslationWorld()
			local pos2 = cameraTarget:getTranslationWorld()
			local keyCount = 2
			local keyTimes = {0, 1000}
			local keyValues = {pos1:x(), pos1:y(), pos1:z(), pos2:x(), pos2:y(), pos2:z()}
			
			local anim = camNode:createAnimation("camMove", Transform.ANIMATE_TRANSLATE(),
						keyCount, keyTimes, keyValues, "LINEAR")
			anim:play()
				
			local ac1 = CCDelayTime:create(1.0)
			local ac2 = CCCallFunc:create(function()
				CameraFollow:setShakeSwitch(true)
				CameraFollow:LockTarget(cameraTarget)
				CameraFollow:ScaleByScreenPos(self.lastScale, ccp(display.cx, display.cy))
				call_back() 
			end)
			local ac = CCSequence:createWithTwoActions(ac1, ac2)
			getUIManager():get("battle_plot_ui"):runAction(ac)	
		else
			CameraFollow:ScaleByScreenPos(self.lastScale, ccp(display.cx, display.cy))
			call_back()
		end 
	else 
		CameraFollow:ScaleByScreenPos(self.lastScale, ccp(display.cx, display.cy))
		call_back()
		CameraFollow:SetFreeMove(ScreenToVector3(display.cx, display.cy, scene3D:getActiveCamera()))
	end 
end 

function battlePlot:hidePlot(isBreak)
	if not self.isShow then return end

	local function endPlot()
		if self.is_pause then
			self.pause_func = endPlot
			return
		end
		self.is_pause = nil
		self.pause_func = nil

		self.isShow = nil
		self:hideDialogLayer()
		self.isPlaying = nil
		local battle_data = getGameData():getBattleDataMt()
		if battle_data:IsBattleStart() then 
			battleRecording:recordVarArgs("battle_play_plot_end")
			battle_data:GetTable("battle_layer").setBattlePaused(false)

			local ship = battle_data:getCurClientControlShip()
			if ship and ship.body and ship.body.node then 
				CameraFollow:LockTarget(ship.body.node)
			end
		end

		if self.skip_button and not tolua.isnull(self.skip_button) then
			self.skip_button:removeFromParentAndCleanup(true)
			self.skip_button = nil
		end

		-- 必须先清数据，后执行回调
		local end_call_back = self.end_call_back
		self.end_call_back = nil 
		self.plot_layer_list = nil
		self.plot_sprite_list = nil
		if end_call_back then 
			end_call_back() 
		end
	end

	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then 
		scheduler:unscheduleScriptEntry(self.hander_time) 
		self.hander_time = nil
	end
	
	if self.subHandle then
		scheduler:unscheduleScriptEntry(self.subHandle) 
		self.subHandle = nil
	end

	if isBreak then 
		endPlot()
		return
	end

	self:cameraCorrect(endPlot)
end

function battlePlot:plotCallBack(call_back)  -- 剧情播放完毕后的回调
	if type(call_back) ~= "function" then
		return 
	end 
	
	if self.isShow then -- 正在播放剧情, 完毕后回调
		self.end_call_back = call_back
	else
		call_back()     -- 没有剧情，直接回调
	end
end

function battlePlot:skipPlot(is_Break)
	if self.skip_button and not tolua.isnull(self.skip_button) then
		self.skip_button:removeFromParentAndCleanup(true)
		self.skip_button = nil
	end

	self.is_skip = true
	hideDialogIcon()
	self:hidePlot(is_Break)
end

function battlePlot:skipButton()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_skip.json")
	convertUIType(panel)
	panel:setPosition(ccp(-400, -380))
	panel:setZOrder(1)
	self:getPlotParentLayer():addWidget(panel)
	local skip_bg = getConvertChildByName(panel, "skip_bg")
	skip_bg:setTouchEnabled(true)
	skip_bg:addEventListener(function()
		battleRecording:recordVarArgs("battle_skip_plot")
		
		self:skipPlot() 
	end, TOUCH_EVENT_ENDED)
	
	self.skip_button = panel
end

function battlePlot:playPlot(plotTab, cameraStop, call_back, plots, sailor_id, name, role_id) -- 播放剧情
	if type(plotTab) ~= "table" or #plotTab < 1 then
		cclog("playPlot(plotTab) plotTab is error")
		return 
	end

	local battle_data = getGameData():getBattleDataMt()

	self.sailor_id = sailor_id or battle_data:getCurClientControlShip():getSailorID()
	self.sailor_name = name or battle_data:getCurClientControlShip():getFighterName()
	self.role_id = role_id or battle_data:getLeaderShip(battle_data:getCurClientUid()):getRole()

	local attr = battle_data:GetData("ui_attr")
    if attr and attr.can_skip_plot == 1 then
		self:skipButton()
	end
	
	self.cameraStop = cameraStop
	self.lastScale = CameraFollow:getScale()
	self.plotTab = plotTab
	self.plotCount = #self.plotTab	
	self.curPlot = ""
	self.nextIndex = 1
	self.end_call_back = call_back
	self.isPlaying = nil
	self.is_skip = nil
	self.isShow = nil
	self:showPlot()
	self:playSubPlot()
end 

return battlePlot
