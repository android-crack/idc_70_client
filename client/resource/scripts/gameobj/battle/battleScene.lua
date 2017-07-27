----------------- Battle Scene -----------------------
require("gameobj/battle/battleInit3d")

local loginRelinkUI = require("ui/loginRelinkUI")
local battleLayer = require("gameobj/battle/battleLayer")
local battleRecording = require("gameobj/battle/battleRecording")
local BattleEffectLayer = require("gameobj/battle/battleEffectLayer")

local lastHeartBeatFrame = getCurrentFrame()
local lastHeartBeatTime = getCurrentLogicTime()

local battle_main = {}

local startBattleScene
startBattleScene = function(battle_field_data, battle_end_callback)
	lastHeartBeatTime = getCurrentLogicTime()

	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	ClsDialogSequence:pauseQuene("battle_scene")

	local battle_data = getGameData():getBattleDataMt()

	if type(battle_end_callback) == "function" then
		battle_data:SetData("battle_end_callback", battle_end_callback)
	end

	local createLayer
	createLayer = function()
		local battle_data = getGameData():getBattleDataMt()
		local battle_field_data = battle_data:GetData("battle_field_data")

		if not battle_field_data then 
			battle_main:removeListener()

			require("gameobj/ClsbattleLoadingUI"):remove()
			
			battle_data:ClearBattleData()
			
			setNetPause(false)

			local reLinkUI = loginRelinkUI:maintainObj()
			reLinkUI:mkReLoginDialog(nil, nil, true)
			return
		end

		local runScene = GameUtil.getRunningScene()
		battle_data:SetLayer("battle_scene", runScene)

		battle_data:SetTable("battle_layer", battleLayer)

		local cloud_layer = battleLayer.createBattleLayer()

		local effect_layer = getUIManager():create("gameobj/battle/battleEffectLayer")
		battle_data:SetLayer("effect_layer", effect_layer)
		effect_layer:setCloudLayer(cloud_layer)

		local battle_ui = getUIManager():create("gameobj/battle/battleUI")
		battle_ui:setIsWidgetTouchFirst(true)
		battle_data:SetLayer("battle_ui", battle_ui)

		local plot_ui = getUIManager():create("gameobj/battle/clsBattleVirLayer", nil, "battle_plot_ui")
		plot_ui:setIsWidgetTouchFirst(true)

		local skill_effect_layer = getUIManager():create("gameobj/battle/clsBattleVirLayer", nil, "skill_effect_layer")
		local skill_mask_layer = CCLayerColor:create(ccc4(0,0,0,255*0.45))
		skill_mask_layer:setVisible(false)
		skill_effect_layer:addChild(skill_mask_layer, -1)
		skill_effect_layer.maskLayer = skill_mask_layer
		battle_data:SetLayer("skill_effect_layer", skill_effect_layer)

		local battle_data = getGameData():getBattleDataMt()
		battle_data:setAlreadyLoad(true)
		require("gameobj/battle/battleRecording"):recordVarArgs("state_client_ready")
		
		setNetPause(false)
	end

	local mkBattleScene
	mkBattleScene = function()
		local battle_preload = require("module/preload/preload_battle").start_preload(battle_field_data, createLayer)
	end

	-- 显示loading 界面
	require("gameobj/ClsbattleLoadingUI"):show(function()
		GameUtil.runScene(mkBattleScene, SCENE_TYPE_BATTLE)
	end)
end

battle_main.startBattle = function(battle_field_data, callback)
	if not battle_field_data then return end

	battle_main:addListener()

	-- 开始战斗场景
	startBattleScene(battle_field_data, callback)
end
------------------------------------------------------------------------------------------------------------------------
-- 战斗每秒心跳
local updateTimer
updateTimer = function()
	local curFrame = getCurrentFrame()
	local now = getCurrentLogicTime()

	if (curFrame - lastHeartBeatFrame) < FRAME_CNT_PER_SEC then return end
	-- print("updateTimer:", curFrame - lastHeartBeatFrame)

	local battle_data = getGameData():getBattleDataMt()

	battleRecording:recordVarArgs("frame_sync")

	-- 战斗停止心跳帧数照跳，这样就不会因为剧情暂停导致，各种心跳不合理
	lastHeartBeatFrame = curFrame
	local delta_time = now - lastHeartBeatTime
	lastHeartBeatTime = now

	local battle_ui = battle_data:GetLayer("battle_ui")
	battle_ui:refreshSeaGodUI()

	if not battle_data:BattleIsRunning() then return end

	local ship = battle_data:getCurClientControlShip()
	if ship and ship:getUid() == 10100 then
		table.print(ship.values)
	end

	local battle_time = battle_data:GetData("battle_time") or 0
	battle_time = battle_time - delta_time
	battle_data:SetData("battle_time", battle_time)

	battle_data:checkIsLostNet()

	-- ui 倒计时
	battle_ui:Timer(battle_time)
	battle_ui:updataRadar(battle_data:GetShips())
end

local battleHeartBeat
battleHeartBeat = function(event)
	-- 战斗没有开始直接返回
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	local battle_ui = battle_data:GetLayer("battle_ui")
	if tolua.isnull(battle_ui) then return end

	-- 战斗心跳
	updateTimer()
	battle_data:GetLayer("battle_ui"):showPartnerTips()

	-- 战斗场景心跳
	battle_data:HeartBeat()
end

------------------------------------------------------------------------------------------------------------------------

battle_main.addListener = function(self)
	battle_main:removeListener()

	self.handle = getSystemContext():addEventListener("frame_update", battleHeartBeat)
end

battle_main.removeListener = function(self)
	getSystemContext():removeEventListener("frame_update", self.handle)
end

return battle_main
