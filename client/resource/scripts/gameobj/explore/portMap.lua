-- 港口界面世界地图
local exploreMap = require("gameobj/explore/exploreMap")
local uiWord = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local onOffInfo=require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local astar = require("gameobj/explore/qAstar")
local ClsPirateIcon =  require("gameobj/explore/explorePirateIcon")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")

local TILE_HEIGHT = 960	
local TILE_WIDTH  = 1695

local PortMap = class("PortMap", exploreMap)

function PortMap.getViewConfig()
	return {
		hide_before_view = true, 
		effect = UI_EFFECT.FADE,
	}
end

PortMap.onEnter = function(self)
    local res = "res/explorer/map.bit"
    self.AStar = astar.new()
    self.AStar:initByBit(res, TILE_WIDTH, TILE_HEIGHT)
    
	PortMap.super.onEnter(self)

	ClsGuideMgr:tryGuide("PortMap")
end

PortMap.showMin = function(self,callBack)
	self:effectClose()
end

--前往交易所
PortMap.btnGotoMarketListener = function(self)
	local onOffData = getGameData():getOnOffData()
	local investData = getGameData():getInvestData()
	if not investData:isUnlock() or not onOffData:isOpen(onOffInfo.PORT_MARKET.value) then
		Alert:warning({msg = uiWord.MARKET_NOT_OPENED, size = 26})
		return
	end

	self:showMin(function()
		local portLayer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(portLayer) then
			local skipToLayer = require("gameobj/mission/missionSkipLayer")
			local skipMissLayer = skipToLayer:skipLayerByName("market")
		end
	end)
end

--立即起航
PortMap.btnGoNowListener = function(self, id, nav_type)
	self.widget_panel.btn_go:disable()
	local market_data = getGameData():getMarketData()
	market_data:showCurPortMarketDialog(function()
		self.widget_panel.btn_go:disable()
		self.is_go_explore = true
		local mapAttrs = getGameData():getWorldMapAttrsData()
		mapAttrs:goOutPort(id, nav_type, function()
			
		end, function()
			if tolua.isnull(self) then return end
			self.widget_panel.btn_go:active()
			self.is_go_explore = false
		end)
	end)
end

PortMap.btnCloseListener = function(self)
	PortMap.super.btnCloseListener(self)
	
end

--出海按钮
PortMap.btnGoSailingListener = function(self)
	self.widget_panel.btn_go:disable()
	local market_data = getGameData():getMarketData()
	market_data:showCurPortMarketDialog(function()
		self.widget_panel.btn_go:disable()
		self.is_go_explore = true
		local mapAttrs = getGameData():getWorldMapAttrsData()
		local portData = getGameData():getPortData()
		local port_id = portData:getPortId() -- 当前港口id
		mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE, function()
			
		end, function()
			if tolua.isnull(self) then return end
			self.widget_panel.btn_go:active()
			self.is_go_explore = false
		end)
	end)
end 

--一键补给
PortMap.oneKeySupplyListener = function(self)
	local supplyData = getGameData():getSupplyData()
    audioExt.playEffect(music_info.COMMON_CASH.res)
	supplyData:askSupply(SUPPLY_ONE_KEY)
end

PortMap.onExit = function(self)
	PortMap.super.onExit(self)
	self.AStar = nil
end

return PortMap
