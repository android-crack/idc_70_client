--探索layer 的基类
--local ClsLand =  require("gameobj/explore/baseLand")
local exploreWalk = require("gameobj/explore/exploreWalk")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local shipEntity = require("gameobj/explore/exploreShip3d")
local ui_word = require("game_config/ui_word")
local dataTools = require("module/dataHandle/dataTools")
local scheduler = CCDirector:sharedDirector():getScheduler()
local ClsSea3d = require("gameobj/sea3d")

local ORDE_SEA = 1
local ORDE_LAND = 3
local ORDE_ITEM_LAYER = 4
local ORDE_SHIP = 5
local ORDE_SHIP_UI = 6
local ORDE_EFFECT_LAYER = 7
local ORDE_EXCESSIVE_LAYER = 8
local ORDE_ANNOUNCE_LAYER = 9
local ORDE_SHAKE_LAYER = 100

local Ship_UI = nil

function getShipUI()
	return Ship_UI
end

local ClsBaseView = require("ui/view/clsBaseView")

local ClsExploreBaseLayer = class("ExploreBaseLayer", ClsBaseView)

function ClsExploreBaseLayer:onEnter(param)
	self:initBaseData()
	self.player_ship = nil
	exploreWalk.init(self)
	self:create2dLayer()
	self:create3dLayer()
	self:createPlayerShip()
	self:initShipAttr()
	self:createMapLand()
end

function ClsExploreBaseLayer:initBaseData() --初始化要用到的数据
		--todo 子类一定要继承
end

function ClsExploreBaseLayer:initShipSeaPos() --初始化船的位置
		--todo 子类一定要继承
end

function ClsExploreBaseLayer:initShipAttr()
	self:initShipSeaPos()
	local seaNode = self.seaNode
	seaNode:setTranslation(self.player_ship.node:getTranslationWorld())
	CameraFollow:update(self.player_ship)
	local sea = seaNode:getSea()
	sea:setUnlimit(true)
end

function ClsExploreBaseLayer:initPlayerShipData() --创建玩家的船
    local function getExploreBoatParam()
        local param = {}

        local sceneDataHandler = getGameData():getSceneDataHandler()
        local ship_id = sceneDataHandler:getMyShipId()
        local boat_attr_item = boat_attr[ship_id]
        local boat_info_item = boat_info[ship_id]
        param.player_uid = sceneDataHandler:getMyUid()
        param.turn_speed = boat_attr_item.angle or 100
        param.id = ship_id
        param.is_player = true
        param.pos = ccp(0, 0)
        param.speed = EXPLORE_BASE_SPEED * 2 + sceneDataHandler:getMyAddSpeed()
        param.gen_id = -1
        param.ship_ui = getShipUI()
        
        --下面的数据可能没有，但是无所谓
        local playerData = getGameData():getPlayerData()
        param.icon = playerData:getIcon()
        param.role_id = playerData:getRoleId()
        
        return param
    end
    return getExploreBoatParam()
end

function ClsExploreBaseLayer:createPlayerShip() --创建玩家的船
    local param = self:initPlayerShipData()

    self.player_ship = shipEntity.new(param)
    self.player_ship:setSpeedRate(0)
end

function ClsExploreBaseLayer:create2dLayer()
    Ship_UI = CCNode:create()
    self:addChild(Ship_UI, ORDE_SHIP_UI)
end

function ClsExploreBaseLayer:createMapLand() --todo 重写, 用到不同的地图要重写这个方法
	-- todo
	--self.land = ClsLand.new()
	--self.land:initLandField()
end

function ClsExploreBaseLayer:breakAuto(is_break)
	if is_break then
		self.land:breakAuto(true)
	else 
		if IS_AUTO then
			self.land:breakAuto(true)
		end
	end
end

function ClsExploreBaseLayer:create3dLayer()
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
end

function ClsExploreBaseLayer:getSeaNode()
    return self.seaNode
end

function ClsExploreBaseLayer:getShipPos()
	local posX, posY = self.player_ship:getPos()
	return posX, posY
end

function ClsExploreBaseLayer:getPlayerShip()
	return self.player_ship
end

-- 获取对应位置的地图状态（陆地、减速带、海）
function ClsExploreBaseLayer:getMapState(x, y, is_world)
	local state = self.land:checkPos(x, y, is_world)
	return state
end

function ClsExploreBaseLayer:getSearchPath(pos_st, pos_end)
	local path = self.land:getSearchPath(pos_st, pos_end)
	return path
end

function ClsExploreBaseLayer:removeScene3D()	
	self.seaNode = nil 
	self.player_ship:release()
	self.player_ship = nil 
	if self.land then
		self.land:removeItem3D()
		self.land = nil
	end
	exploreWalk.init(nil)
end

function ClsExploreBaseLayer:touchEvent(x, y)
	--子类重写
	
end

function ClsExploreBaseLayer:setEnabledUI(is_enabled)
	--todo
	
end

function ClsExploreBaseLayer:heartBeat(dt)
	--场景心跳

end

function ClsExploreBaseLayer:continueAutoNavigation(ignore_auto)
	--打捞完后继续导航
	local exploreData = getGameData():getExploreData()
	local autoPos = exploreData:getAutoPos()
	local is_change_auto = false
	if (IS_AUTO or ignore_auto) and autoPos then
		is_change_auto = true
		if autoPos.portId then
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = autoPos.portId, navType = EXPLORE_NAV_TYPE_PORT})
		elseif autoPos.stronghoId then
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = autoPos.stronghoId, navType = EXPLORE_NAV_TYPE_SH})
		elseif autoPos.lootAuto then
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {navType = EXPLORE_NAV_TYPE_LOOT, pos = autoPos.lootAuto, callBack = autoPos.lootAutoCallBack})
		elseif autoPos.pos then
            if autoPos.is_reward_pirate then
                EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {navType = EXPLORE_NAV_TYPE_REWARD_PIRATE, pos = autoPos.pos, name = autoPos.name, callBack = autoPos.callBack})                
            elseif autoPos.is_salve_ship then
                EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {navType = EXPLORE_NAV_TYPE_SALVE_SHIP, pos = autoPos.pos, name = autoPos.name, callBack = autoPos.callBack})
            else
                EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {navType = EXPLORE_NAV_TYPE_POS, pos = autoPos.pos, name = autoPos.name, callBack = autoPos.callBack})
            end
		elseif autoPos.relicId then
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = autoPos.relicId, navType = EXPLORE_NAV_TYPE_RELIC})
		elseif autoPos.timePirateId then
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = autoPos.timePirateId, navType = EXPLORE_NAV_TYPE_TIME_PIRATE})
		elseif autoPos.mineralId then
			-- EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = autoPos.mineralId, navType = EXPLORE_NAV_TYPE_MINERAL_POINT})
		elseif autoPos.whirlPoolId then
			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = autoPos.whirlPoolId, navType = EXPLORE_NAV_TYPE_WHIRLPOOL})
		elseif autoPos.is_treasure_go then
			local layer = getExploreLayer()
			if not tolua.isnull(layer) then
				layer:autoTreasureGo()
				--EventTrigger(EVENT_EXPLORE_MYSHIP_PAUSE)
			end
		else
			is_change_auto = false
		end
		
		if is_change_auto then
			IS_AUTO = true
		end
		------------------------------------------------------
		-- modify By Hal 2015-09-07, Type(BUG) - redmine 19515
		--exploreData:setAutoPos(nil)
		------------------------------------------------------
	end
	return is_change_auto
end

function ClsExploreBaseLayer:onExit()
end

return ClsExploreBaseLayer  



