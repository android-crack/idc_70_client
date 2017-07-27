----------- 探索副本的 layer ----------------------
local music_info = require("game_config/music_info")
local tips = require("game_config/tips")
local missionGuide = require("gameobj/mission/missionGuide")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local compositeEffect = require("gameobj/composite_effect")
local exploreUtil = require("module/explore/exploreUtils")
local UI_WORD = require("game_config/ui_word")
local SceneEffect = require("gameobj/battle/sceneEffect")
local shipEntity = require("gameobj/explore/exploreShip3d")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ClsBaseView = require("ui/view/clsBaseView")

local exploreWalk = require("gameobj/explore/exploreWalk")
local ClsSea3d = require("gameobj/sea3d")

-- z轴层次关系
local ORDE_SEA = 1
local ORDE_LAND = 3
local ORDE_ITEM_LAYER = 4
local ORDE_SHIP = 5
local ORDE_SHIP_UI = 6
local ORDE_EFFECT_LAYER = 7
local ORDE_EXCESSIVE_LAYER = 8
local ORDE_ANNOUNCE_LAYER = 9
local ORDE_SHAKE_LAYER = 100

local plotVoiceAudio = require("gameobj/plotVoiceAudio")
local voice_info = getLangVoiceInfo()

local Ship_UI = nil

function getSceneShipUI()
	return Ship_UI
end

local ClsCopySceneLayer = class("ClsCopySceneLayer", ClsBaseView)

function ClsCopySceneLayer:onEnter(map_layer)
	self.land = map_layer
	self.speed_rate = SPEED_NORNAL
	self:initData()

	self.player_ship = nil

	exploreWalk.init(self)

	self.m_event_layer = nil

	self:create2dLayer()
	self:create3dLayer()
	self:createPlayerShip()
	self:createShipLayer()
	self:initEvent()

	IS_AUTO = false      -- 是否自动导航
	self:createUILayer()
	audioExt.stopMusic()
	audioExt.stopAllEffects()
	local sound = music_info.EX_BGM   --音乐
	audioExt.playMusic(sound.res, true)

	self:regTouchEvent(self, function(...) return self:onTouch(...) end, -1)

	self:setMoveCamera(self:getCamera())
end

function ClsCopySceneLayer:getPlayerShip()
	return self.player_ship
end

function ClsCopySceneLayer:getShipsLayer()
	return self.m_ships_layer
end

function ClsCopySceneLayer:getLand()
	return self.land
end

function ClsCopySceneLayer:getSceneUI()
	return ClsSceneManage:getSceneUILayer()
end

function ClsCopySceneLayer:getSpeedRate()
	return self.speed_rate
end

function ClsCopySceneLayer:initData()
	local exploreData = getGameData():getExploreData()
	self.ship_info = exploreData:getShipInfo()
	self.ship_id = self.ship_info.id
	self.speed = self.ship_info.speed  -- 船的初始速度
	self.add_speed = self.ship_info.add_speed  -- 船的初始速度
end

function ClsCopySceneLayer:initEvent()
	self:regTouchEvent(self, function(...) return self:onTouch(...) end)
end

function ClsCopySceneLayer:create2dLayer()
	getUIManager():create("gameobj/copyScene/clsCopySceneEffectLayer")
	Ship_UI = require("gameobj/copyScene/clsCopySceneEventLayer").new(self, ORDE_EFFECT_LAYER)
	self.m_event_layer = Ship_UI
	self:addChild(Ship_UI, ORDE_SHIP_UI)
end

function ClsCopySceneLayer:create3dLayer()
	-- 3d layer
	Explore3D:initScene3D(self)
	
	local Game3d = require("game3d")
	local sea3d_layer = Game3d:getLayer2d(SCENE_ID.EXPLORE, 0)
	local ship3d_layer = Game3d:getLayer2d(SCENE_ID.EXPLORE, 10)
	
	sea3d_layer:setZOrder(ORDE_SEA)
	ship3d_layer:setZOrder(ORDE_SHIP)

	--3d sea
	local sea = ClsSea3d.new("res/sea_3d/exploreSea.conf")
	Explore3D:getLayerSea3d():addChild(sea.node)
	self.seaNode = sea.node
	self.sea = sea
end

function ClsCopySceneLayer:getSea()
	return self.sea
end
function ClsCopySceneLayer:getSeaNode()
	return self.seaNode
end

function ClsCopySceneLayer:createPlayerShip() --创建玩家的船
	local param = self:initPlayerShipData()
	self.player_ship = shipEntity.new(param)
	self:shipRotate(180)
end

function ClsCopySceneLayer:createShipLayer()
	local copySceneManage = require("gameobj/copyScene/copySceneManage")
	self.m_ships_layer = copySceneManage:doLogic("createPlayerShip", self)
	self:addChild(self.m_ships_layer, ORDE_SHIP)
end

function ClsCopySceneLayer:getEventLayer()
	return self.m_event_layer
end

function ClsCopySceneLayer:initPlayerShipData() --创建玩家的船
	local function getExploreBoatParam()
		local param = {}

		local sceneDataHandler = getGameData():getSceneDataHandler()
		local ship_id = self.ship_id
		local boat_attr_item = boat_attr[ship_id]
		local boat_info_item = boat_info[ship_id]
		param.player_uid = sceneDataHandler:getMyUid()
		param.turn_speed = boat_attr_item.angle or 100
		param.id = ship_id
		param.is_player = true
		param.pos = ccp(0, 0)
		param.speed = self.speed * self:getSpeedRate() + self.add_speed
		param.gen_id = -1
		param.ship_ui = getSceneShipUI()
		param.star_level = 1

		--下面的数据可能没有，但是无所谓
		local playerData = getGameData():getPlayerData()
		param.icon = playerData:getIcon()
		param.role_id = playerData:getRoleId()

		return param
	end

	return getExploreBoatParam()
end

function ClsCopySceneLayer:initShipSeaPos(px, py)
	px = px or 26
	py = py or 24
	if px >= self.land:getTileWidth() then
		print("发送的位置超过了地图最大格子数xxx-------", px)
		px = 25
	end
	if py >= self.land:getTileHeight() then
		print("发送的位置超过了地图最大格子数yy-----------", py)
		py = 25
	end

	local pos = self.land:tileSizeToCocos2(ccp(px, py))

	self.player_ship.land = self.land
	self.player_ship:setPos(pos.x, pos.y)
end

function ClsCopySceneLayer:initUpdate()
	local seaNode = self.seaNode
	seaNode:setTranslation(self.player_ship.node:getTranslationWorld())
	CameraFollow:update(self.player_ship)
	local sea = seaNode:getSea()
	sea:setUnlimit(true)
end

-- 转动船
function ClsCopySceneLayer:shipRotate(angle)
	local angle = math.mod(angle + 360, 360)
	self.player_ship:setAngle(angle)
end

function ClsCopySceneLayer:createUILayer()
	getUIManager():create("gameobj/copyScene/clsCopyEffectLayer")
	local function tran()
		local layerColor = CCLayerColor:create(ccc4(0,0,0,255))
		local scene = GameUtil.getRunningScene()
		scene:addChild(layerColor, ZORDER_INDEX_EIGHT)
		local actions = {}
		local t = 1
		actions[1] = CCFadeOut:create(t)
		actions[2] = CCCallFunc:create( function()
			layerColor:removeFromParentAndCleanup(true)
			self:exploreTimer()
		end)
		local action = transition.sequence(actions)
		layerColor:runAction(action)
	end
	tran()
end

function ClsCopySceneLayer:updateScene(dt)
	ClsSceneManage:heartBeat(dt)
	self.m_ships_layer:update(dt)
	self.land:update(dt)
end

-- 心跳
function ClsCopySceneLayer:exploreTimer()
	local function exploreTimerCB(dt)
		self:updateScene(dt)
	end
	local scheduler = CCDirector:sharedDirector():getScheduler()
	self.hander_time = scheduler:scheduleScriptFunc(exploreTimerCB, 0, false)
end

-------------------------------------------------------------

function ClsCopySceneLayer:onTouch(event, x, y)
	x, y = self:getOriginScreenXY(x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	elseif event == "moved" then
		self:onTouchMoved(x, y)
	elseif event == "ended" then
		self:onTouchEnded(x, y)
	end
end

function ClsCopySceneLayer:onTouchBegan(x, y)
	if true == ClsSceneManage:doLogic("isPassTouchEvent", x, y) then
		return false
	end
	if getGameData():getTeamData():isLock() then
		return false
	end
	return true
end

function ClsCopySceneLayer:onTouchMoved(x, y)

end

function ClsCopySceneLayer:onTouchEnded(x, y)
	local check_pos, map_pos = self.land:checkPos(x, y)

	local node = Explore3D:clickObject(x, y)
	if ClsSceneManage:touchObject(node) then
		return
	end
	if check_pos == MAP_LAND then
		if self:touchLand(map_pos, x, y) then
			return
		end
	else
		if IS_AUTO then
			--取消导航
			self:breakAuto()
		end
		if self.m_ships_layer:setMyShipMoveDir(x, y) then
			self.m_ships_layer:setIsWaitingTouch(false)
			local ui = ClsSceneManage:getSceneUILayer()
			if not tolua.isnull(ui) then
				ui:setIsDropAnchor(false)
			end
			local target_x, target_y = self:getLand():getPosInLand(x, y)
			exploreUtil:showClickEffect(target_x, target_y, self.m_ships_layer)
		end
	end

	self:endLogic()
end

function ClsCopySceneLayer:endLogic()
	local ui = ClsSceneManage:getSceneUILayer()
	if not tolua.isnull(ui) then
		ui:touchEndLogic()
	end

	ClsSceneManage:doLogic("touchEnd")
end

local function getTouch3dEff(vec3)
	local effect = SceneEffect.createEffect({parent = Explore3D:getLayerShip3d(), file = EFFECT_3D_PATH .. "tx_0149" .. PARTICLE_3D_EXT, pos = vec3, isStart = true})
	--effect:GetNode():setScale(Vector3.new(2, 2, 2))
	if not effect then return end
	effect:GetNode():setScale(2)
	return effect
end

function ClsCopySceneLayer:touchLand(map_pos, x, y)
	if ClsSceneManage:doLogic("isTouchSomething", map_pos) then
		return true
	end
	if self.land:checkIsBlock(map_pos) then
		local vec3 = ScreenToVector3(x, y , Explore3D:getScene():getActiveCamera())
		if self.block_effect then
			local new_eff = getTouch3dEff(vec3)
			SceneEffect.ReleaseParticle(self.block_effect)
			self.block_effect = new_eff
		else
			self.block_effect = getTouch3dEff(vec3)
		end
	end
	return true
end

function ClsCopySceneLayer:breakAuto(is_break)
	if is_break then
		self.land:breakAuto(true)
	else
		if IS_AUTO then
			self.land:breakAuto(true)
		end
	end
end

function ClsCopySceneLayer:regFuns()
end


--退出处理
function ClsCopySceneLayer:onExit()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time)
		self.hander_time = nil
	end

	if self.block_effect then
		SceneEffect.ReleaseParticle(self.block_effect)
		self.block_effect = nil
	end

	local ModuleExploreLoading = require("gameobj/explore/exploreLoading")
	ModuleExploreLoading:clearPreload()

	-- 删除3d资源
	Explore3D:removeScene3D()
	ClsSceneManage.model_objects:cleanAllModel()
end

-- 获取对应位置的地图状态（陆地、减速带、海）
function ClsCopySceneLayer:getMapState(x, y, is_world)
	local state = self.land:checkPos(x, y, is_world)
	return state
end

function ClsCopySceneLayer:removeScene3D()
	self.sea = nil
	self.seaNode = nil
	self.player_ship:release()
	self.player_ship = nil
	ClsSceneManage:removeAllSceneModel() --释放触摸
	ClsSceneManage:sceneEnd()

	if self.land then
		self.land:removeItem3D()
	end
end

return ClsCopySceneLayer
