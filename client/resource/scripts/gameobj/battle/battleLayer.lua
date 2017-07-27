----------- Battle layer ---------------
local shipEntity = require("gameobj/battle/newShipEntity")
local battleResult = require("module/battleAttrs/battleResult")
local scene_cfg = require("gameobj/battle/battleSceneCfg")
local battlePlot = require("gameobj/battle/battlePlot")
local music_info = require("game_config/music_info") 
local battleEffect = require("gameobj/battle/battleEffectLayer")
local ui_word = require("game_config/ui_word")
local ClsSea3d = require("gameobj/sea3d")

local battleRecording = require("gameobj/battle/battleRecording")
BATTLE_SCALE_RATE =  0.95
local function getSceneSize()
	return BATTLE_SCENE_WIDTD ,BATTLE_SCENE_HEIGHT
end

local function setBattlePaused(is_paused)
	if battlePlot.isPlaying then
		return
	end
	local battle_data = getGameData():getBattleDataMt()
	battle_data:SetBattleRunning(not is_paused)

	if is_paused then
		local SHIPS = battle_data:GetShips()
		for k, ship_data in pairs(SHIPS) do
			if not ship_data.isDeaded and ship_data.body then 
				ship_data.body:updateUI()
			end
		end
	end
end

local function stepFunction(func, param, call_back)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	local count_time = 0
	local count_angle = 0 
	local sum_time = param.time 
	local sum_angle = param.rotateAngle
	local sum_scale = param.scale
	local angle_sec = sum_angle/sum_time
	local old_scale = CameraFollow:getScale()
	local scale_sec = (sum_scale-old_scale)/sum_time
	local battle_data = getGameData():getBattleDataMt()
	if sum_time <= 0 then 
		func(sum_angle, sum_scale)
		if call_back then call_back() end 
		return 
	end 
	
	local function step(dt)
		count_time = count_time + dt 
		count_angle = angle_sec*count_time
		if count_time >= sum_time then 
			battle_data:StopScheduler("stepFunction")
			battle_data:SetData("stepFunction", nil)
			func(count_angle-sum_angle, sum_scale)
			if call_back then call_back() end 
			return 
		end 
		func(angle_sec*dt, scale_sec*count_time+old_scale)
	end 
	battle_data:SetScheduler("stepFunction", step, 0, false)
	battle_data:SetData("stepFunction", true)
end 

local function hideUI()
	local battle_data = getGameData():getBattleDataMt()
	local battleEffectLayer = battle_data:GetLayer("effect_layer")
	battleEffectLayer:hideAllWeather()
	
	local battle_layer = battle_data:GetLayer("battle_scene_layer")
	if tolua.isnull(battle_layer) then
		return
	end
	battle_layer:setTouchEnabled(false)
	
	local ship_ui = battle_data:GetLayer("ship_ui")
	ship_ui:setVisible(false)
	
	local map_layer = battle_data:GetLayer("map_layer")
	map_layer:setVisible(false)
	
	local ships = battle_data:GetShips() 
	if ships and next(ships) then
		for k, v in pairs(ships) do
			if not v.isDeaded then
				v.body:delAttackRange()
				v.body:hideGuanquan()
			end
		end
	end
end

local function EndCallback(is_win)
	-- ResourceManager.debug_mode = false
	
	local battle_data = getGameData():getBattleDataMt()
	CameraFollow:cancelLockLockTarget()
	battle_data:StopAllScheduler()
	BattleInit3D:removeScene3D()

	local enter_port = battle_data:GetData("Already_Enter_Port")
	local current_scene_info = battle_data:GetData("rpc_client_current_scene")
	local enter_area_info = battle_data:GetData("rpc_client_enter_area")
	local scene_team_info = battle_data:GetData("rpc_client_scene_team_info")

	battle_data:ClearBattleData()

	getGameData():getSceneDataHandler():cleanInfo()

	setNetPause(false)

	getGameData():getAutoTradeAIHandler():setPause(false)

	if enter_port then
		rpc_client_port_enter(enter_port, 1, 0)
	end

	if current_scene_info then
		rpc_client_current_scene(unpack(current_scene_info))
	end

	if enter_area_info then
		for _, info in ipairs(enter_area_info) do
			rpc_client_enter_area(info)
		end
	end

	if scene_team_info then
		for _, info in ipairs(scene_team_info) do
			rpc_client_scene_team_info(info)
		end
	end
end 

local function calcCameraPos()
	local battle_data = getGameData():getBattleDataMt()

	local ship = battle_data:getCurClientControlShip()

	if ship and ship.body and ship.body.node then
		return ship.body.node:getTranslationWorld()
	end

	local team_ships = battle_data:GetTeamShips(ship:getTeamId(), true)
	for _, team_ship in ipairs(team_ships) do
		if team_ship:is_leader() and team_ship and team_ship.body and team_ship.body.node then
			return team_ship.body.node:getTranslationWorld()
		end
	end
end

-- 移动同时缩放镜头
local function moveScaleCamera(_duraction, _targetPos, _targetScale, _callBack)
	CameraFollow:StopShake()
	local battle_data = getGameData():getBattleDataMt()
	
	local pos = _targetPos
	local scale = _targetScale or BATTLE_SCALE_RATE 
	local duraction = _duraction or 1
	
	if duraction <= 0 then 
		CameraFollow:ScaleByScreenPos(scale, ccp(display.cx, display.cy))
		CameraFollow:SetFreeMove(pos)	
		if _callBack then _callBack() end 
		return 
	end 
	
	local scheduler = CCDirector:sharedDirector():getScheduler()
	local count_time = 0
	
	local old_scale = CameraFollow:getScale()
	local scale_sec = (scale-old_scale)/duraction
    local node = BattleInit3D:getScene():getActiveCamera():getNode()
	local camera_pos = node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(pos, camera_pos, dir)
	dir:scale(1/duraction)
	
	local function step(dt)
		count_time = count_time + dt
		
		if count_time >= duraction then 
			battle_data:StopScheduler("moveScaleCamera")
			CameraFollow:ScaleByScreenPos(scale, ccp(display.cx, display.cy))
			CameraFollow:SetFreeMove(pos)
			if _callBack then _callBack() end 
			return 
		end 
		
		CameraFollow:ScaleByScreenPos(scale_sec*count_time+old_scale, ccp(display.cx, display.cy))
		local camera_pos = node:getTranslationWorld()
		local tran = Vector3.new(dir:x()*dt, dir:y()*dt, dir:z()*dt)
		tran:add(camera_pos)
		CameraFollow:SetFreeMove(tran)		
	end
	
	battle_data:SetScheduler("moveScaleCamera", step, 0, false)
end

-- 3D场景旋转
local function showEndCamera(is_win)
	local battle_data = getGameData():getBattleDataMt()
	
	CameraFollow:StopShake()

	audioExt.playMusic(is_win and music_info.BATTLE_WIN.res or music_info.BATTLE_FAIL.res, false)

	-- 结算界面
	local function call_back()
		local seagod_data = battle_data:GetData("is_seagod")
		if seagod_data then
			local activity_data = getGameData():getActivityData()
			activity_data:showSeaGodActivityAlert(seagod_data.is_leader)
			EndCallback(is_win)
			return
		end
		if is_win then
			EndCallback(is_win)
			return
		end
		battleResult.showBattleResult()
	end

	local player_pos = calcCameraPos()

	if not player_pos then 
		call_back()
		return
	end

	local function rotateCamera(dangle, new_scale)
		local scene3D = BattleInit3D:getScene()
    	if not scene3D then return end
    	local cameraNode = scene3D:getActiveCamera():getNode()
    	if not cameraNode then return end
		local rotateAxis = WorldVector2Local(cameraNode, Vector3.new(0,1,0))
		if not rotateAxis then return end

		cameraNode:rotate(rotateAxis, math.rad(dangle))
		CameraFollow:ScaleByScreenPos(new_scale, ccp(display.cx, display.cy))
		if player_pos then
			CameraFollow:SetFreeMove(player_pos)
		end
	end 
	
	if not is_win then
		local function cb()
			CameraFollow:IgnoreBound(true)
			stepFunction(rotateCamera, {time = battle_config.battle_end_rotate_cam_tm, rotateAngle = 0, scale = 2}, call_back)
		end
		moveScaleCamera(1, player_pos, nil, cb)
	else
		CameraFollow:IgnoreBound(true)
		CameraFollow:ResetCenter()
		battleEffect.showWhale(gameplayToCocosWorld(player_pos))
		stepFunction(rotateCamera, {time = battle_config.battle_end_rotate_cam_tm, rotateAngle = 180, scale = 2}, call_back)
	end
end

local function clearBattleLayer()
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	audioExt.stopMusic()
	audioExt.stopAllEffects()

	battle_data:SetBattleStart(false)
	battle_data:SetBattleRunning(false)

	require("gameobj/battle/battleScene"):removeListener()

	--BATTLE_SCALE_RATE = battle_data:getBattleLayerScale() or 0.95
	hideUI()

	local ship = battle_data:getCurClientControlShip()
	if ship and ship.body then
		ship.body:removeEffModel()
	end
end 

local function QuickEndBattle(is_win, hide_camera)
	local battle_data = getGameData():getBattleDataMt()

	battle_data:SetBattleSwitch(false)

	-- 子弹要求先清
	require("gameobj/battle/bullet"):releaseAll()

	battlePlot:skipPlot(true)
	clearBattleLayer()

	if hide_camera or battle_data.direct_end then
		EndCallback(is_win)
	else
		showEndCamera(is_win)
	end
end

local function onTouchBegan(touch_layer, x, y, isMutilTouchMode)
	touch_layer.startMutilTouch = nil
end

local function onTouchMoved(touch_layer, x, y, isMutilTouchMode)
	if isMutilTouchMode then return end

	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	local ship = battle_data:getCurClientControlShip()
	if ship and not ship:is_deaded() then return end

	if touch_layer.touch_on_the_left then return end

	if touch_layer.touchLastPoint then 
		if math.abs(touch_layer.touchLastPoint.x - x) >= 15 or math.abs(touch_layer.touchLastPoint.y - y) >= 15 then
			local gx = display.cx + touch_layer.touchLastPoint.x - x
			local gy = display.cy + touch_layer.touchLastPoint.y - y
			local pos = ScreenToVector3(gx, gy, BattleInit3D:getScene():getActiveCamera())
			if pos then 
				CameraFollow:StopShake()
				if battle_data:GetLayer("battle_ui"):getLockCamera() then
					CameraFollow:setShakeSwitch(false)
				else
					CameraFollow:SetFreeMove(pos)
	                battle_data:GetLayer("battle_ui"):showBtnViewUnlock()
	            end
			end 
			touch_layer.touchLastPoint = {x = x, y = y}
			touch_layer.no_end_touch = true
		end
	else
		-- local ROCKER_BTN_STATUS = 1
		
		-- if battle_data:GetData("ui_attr").ce_test_rocker ~= ROCKER_BTN_STATUS then
		-- 	local rect = CCRect(0, 0, display.width/2, display.height)
		-- 	touch_layer.touch_on_the_left = rect:containsPoint(ccp(x, y))
		-- end

		touch_layer.touchLastPoint = {x = x, y = y}
	end
end

local function onTouchEnded(touch_layer, x, y, isMutilTouchMode)
	local battle_data = getGameData():getBattleDataMt()

	touch_layer.touch_on_the_left = false

	if touch_layer.no_end_touch and battle_data:GetLayer("battle_ui"):getLockCamera() then
		local ship = battle_data:getCurClientControlShip()
		if ship then
			CameraFollow:LockTarget(ship.body.node)
		end
		CameraFollow:setShakeSwitch(true)
	end

	if touch_layer.startMutilTouch then
		touch_layer.touchLastPoint = nil
		touch_layer.no_end_touch = nil
		return
	end

	if not isMutilTouchMode and not touch_layer.no_end_touch and battle_data:IsBattleStart() and
		not ((x > 730 and y < 185) or (x > 775 and  y < 230))-- 屏蔽技能区域触摸
	then
		BattleInit3D:touchScene3D(x, y)
		
		---------- 方便策划用工具,到时删掉
		if device.platform == "windows" then
			if not tolua.isnull(test_pos) then 
				test_pos:removeFromParentAndCleanup(true)
			end 

			local pos = touch_layer:getParent():convertToNodeSpace(ccp(x, y))
			
			local cam = touch_layer:getParent():getCamera()
			local x, y, z = cam:getEyeXYZ(0,0,0)
			--local scale = CameraFollow:getScale()
			pos.x = pos.x + x
			pos.y = pos.y + y
		
			local str = string.format("x = %d \ny = %d", pos.x, pos.y)
			test_pos = createBMFont({text = str, size = 18, fontFile = FONT_BUTTON})
			test_pos:setAnchorPoint(ccp(0, 0.5))
			test_pos:setPosition(20, 150)
			battle_data:GetLayer("battle_scene"):addChild(test_pos, 100)
		end 
	end
	
	touch_layer.touchLastPoint = nil
	touch_layer.no_end_touch = nil
end

local function onMutilTouchMoved( touch_layer, curPos, lastPos )
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	touch_layer.startMutilTouch = true
	local scale = touch_layer:getScale()
	local x, y = curPos.x, curPos.y
	local cur_scale = curPos.dis/lastPos.dis * scale
	local scale_min = battle_data:GetData("scale_min")
	local scale_max = battle_data:GetData("scale_max")

	if not scale_max or not scale_max then return end
	
	if cur_scale > scale_max then 
		cur_scale = scale_max
	elseif cur_scale < scale_min then 
		cur_scale = scale_min
	end 
	
	local curWidth = touch_layer.layer_width*cur_scale
	local curHeight = touch_layer.layer_height*cur_scale

	local battle_ui = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		battle_ui:setRadarFrameContentSize(curWidth, curHeight)
	end
		
	--把世界坐标转当前坐标系
	local pos = touch_layer:convertToNodeSpace(ccp(x, y))
	local curX = (x-lastPos.x)+(x-pos.x*cur_scale)
	local curY = (y-lastPos.y)+(y-pos.y*cur_scale)
		
	if curX < display.width - curWidth then
		curX = display.width - curWidth 
	elseif curX > 0 then
		curX = 0
	end		

	if curY < display.height - curHeight then
		curY = display.height - curHeight 
	elseif curY > 0 then
		curY = 0
	end	
	local x = (curPos.x + lastPos.x) / 2	
	local y = (curPos.y + lastPos.y) / 2
	-- battle_data:setBattleLayerScale(cur_scale)
	-- CameraFollow:ScaleByScreenPos(cur_scale, ccp(x,y))
end

local function initEvent(battle_layer)
	local touch_layer = CCLayer:create()
	battle_layer:addChild(touch_layer)

	local battle_data = getGameData():getBattleDataMt()
	local mult_touch = require("ui/tools/mult_touch_layer")
	touch_layer.onTouchBegan = function(x,y,isMutilTouchMode)  
		onTouchBegan(touch_layer, x, y, isMutilTouchMode) 
	end
	
	touch_layer.onTouchMoved = function(x,y,isMutilTouchMode) 
		onTouchMoved(touch_layer, x, y, isMutilTouchMode) 
	end
	
	touch_layer.onTouchEnded = function(x,y,isMutilTouchMode) 
		onTouchEnded(touch_layer, x, y, isMutilTouchMode) 
	end
	
	touch_layer.onMutilTouchMoved = function(curPos, lastPos) 
		onMutilTouchMoved(touch_layer, curPos, lastPos) 
	end
	
	mult_touch:initTouchLayer(touch_layer)
	if battle_layer.touch_layer_disable then
		touch_layer:setTouchEnabled(false)
	end

	battle_layer.touch_layer = touch_layer
	
	touch_layer.layer_width, touch_layer.layer_height = getSceneSize()
	battle_layer.layer_width, battle_layer.layer_height = getSceneSize()
	
	-- 缩放范围
	battle_data:SetData("scale_max", 1.5)
	battle_data:SetData("scale_min", 0.6)

	battle_layer:registerScriptHandler(function(event)
    	if event == "exit" then
			local battle_preload = require("module/preload/preload_battle")
			battle_preload.clear_preload()
			local battle_data = getGameData():getBattleDataMt()
			if battle_data then 
				battle_data:StopAllScheduler()
			end
			CameraFollow:cancelLockLockTarget()
			BattleInit3D:removeScene3D()
    	end
    end)
end

local function createBattleLayer()
	local bt_layer = getUIManager():create("gameobj/battle/clsBattleLayer")

	local battle_data = getGameData():getBattleDataMt()
	local battle_field_data = battle_data:GetData("battle_field_data")

	bt_layer:ignoreAnchorPointForPosition(false)
	bt_layer:setAnchorPoint(ccp(0,0))
	battle_data:SetLayer("battle_scene_layer", bt_layer)
	
	battle_data:SetData("scene_effect_pool", {})

	-- map
	local layer_id = battle_field_data.layerId
	local map_layer = scene_cfg.new(layer_id)
	battle_data:SetLayer("map_layer", map_layer)

	local size = map_layer:getContentSize()
	BATTLE_SCENE_WIDTD = size.width
	BATTLE_SCENE_HEIGHT = size.height

	-- 3d
	BattleInit3D:initScene3D(bt_layer)
		
	local width, height = CameraFollow:GetSceneBound()
	local sea = ClsSea3d.new("res/sea_3d/battleSea.conf", Vector3.new(width/2, 0, -height/2))
	BattleInit3D:getLayerSea3d():addChild(sea.node)
	local seaCfg = map_layer:getSeaCfg()
	if seaCfg then
		sea:setUniforms(seaCfg)
	end

	local ship_ui = CCLayer:create()
	battle_data:SetLayer("ship_ui", ship_ui)
	
	local dialog_node = CCLayer:create()
	battle_data:SetLayer("dialog_node", dialog_node)
	
	local cloud_layer = CCLayer:create()

	bt_layer:addChild(map_layer, 10)
	bt_layer:addChild(cloud_layer, 16)
	bt_layer:addChild(ship_ui, 20)
	bt_layer:addChild(dialog_node, 20)
	
	shipEntity.createShips(battle_field_data.ships)

	initEvent(bt_layer)
	
	local camera_scale = battle_data:getBattleLayerScale()
	BATTLE_SCALE_RATE = camera_scale
	CameraFollow:ScaleByScreenPos(camera_scale, ccp(display.cx, display.cy))
	
	return cloud_layer
end

local function battleTranCallBack()
	-- ResourceManager.debug_mode = true

	local battle_data = getGameData():getBattleDataMt()
	setBattlePaused(false)
	battle_data:resetHeartBeatTime()
	battle_data:runStartAi()
end

local function StartBattle()
	local index = math.random(1, 2)
	if index == 1 then
		audioExt.playMusic(music_info.BATTLE_BG2.res, true)
	else
		audioExt.playMusic(music_info.BATTLE_BG.res, true)
	end

	local battle_data = getGameData():getBattleDataMt()
	battle_data:SetBattleStart(true)
	battle_data:SetBattleRunning(true)

	setBattlePaused(true)
	
	local layerColor = CCLayerColor:create(ccc4(0,0,0,255))
	layerColor:registerScriptTouchHandler(function(eventType, x, y) 
		if eventType =="began" then 
			return true
		end
	end, false, TOUCH_PRIORITY_HIGHT, true)
	layerColor:setTouchEnabled(true)

	local battle_plot_ui = getUIManager():get("battle_plot_ui")
	if not tolua.isnull(battle_plot_ui) then
		battle_plot_ui:addChild(layerColor, 10)
	end

	local actions = {}

	actions[1] = CCFadeOut:create(1)
	actions[2] = CCCallFunc:create( function()
		battleTranCallBack()
		layerColor:removeFromParentAndCleanup(true)
	end)
	
	local action = transition.sequence(actions)
	layerColor:runAction(action)
end

local battleLayer = {
	createBattleLayer = createBattleLayer,
	getSceneSize = getSceneSize,
	onTouchEnded = onTouchEnded,
	setBattlePaused = setBattlePaused,
	StartBattle = StartBattle,
	EndCallback = EndCallback,
	QuickEndBattle = QuickEndBattle,
	stepFunction = stepFunction,
}
return battleLayer
