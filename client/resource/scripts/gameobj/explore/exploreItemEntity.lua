-- 探索事件

local exploreAttrs = require("module/explore/exploreAttrs")
local on_off_info = require("game_config/on_off_info")
local Explore_Whirlpool = require("game_config/explore/explore_whirlpool")
local Alert = require("ui/tools/alert")
local ClsParticleProp = require ("gameobj/explore/exploreParticle")
local exploreUtil = require("module/explore/exploreUtils")

local EXPLORE_WHIRL_EFFECT1 = "tx_xuanwo"

local ExploreItem = class("ExploreItem", function() return CCLayer:create() end)

function ExploreItem:ctor(parent, player_ship)
	self.parent = parent
	self:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
	-- init
	self.player_ship = player_ship
	self.isMove  = 1
	self.hit_radius = 300
	--wmh todo 尽量移除这个文件
	exploreAttrs:initExploreAttrs()
	--TODO 创建漩涡
	self.item_whirl_pool = {}
	self.item_btn_menu = {}
	self:createWhirlPool()
	self:regFuns()
end

function ExploreItem:setWhilrMove(value)
	self.isMove  = value
end

function ExploreItem:setEnabledUI(is_enabled)
	if self.item_btn_menu then
		for _, v in pairs(self.item_btn_menu) do
			v:setEnabled(is_enabled)
		end
	end
end

function ExploreItem:createWhirlPool()
	------------------------------------------------------
	-- modify By Hal 2015-09-01, Type(BUG) - redmine 19518
	-- TODO: 随手处理的出海时一次全部漩涡被创建的性能消耗问题	
	self.item_whirl_pool = {}
	for i,v in ipairs(Explore_Whirlpool) do

		-- 获取在所在的海域
		local explore_map_data = getGameData():getExploreMapData()
		-- 只加载所在海域的漩涡
		--if tonumber( v.sea_index ) == explore_map_data:getCurAreaId() then

			if self.item_whirl_pool[i] == nil then

				print( string.format( T("创建漩涡 %s ----------------------------------- By Hal"), v.name ) );

				local sea_pos = exploreUtil:cocosToTile2(ccp(v.sea_pos[1], v.sea_pos[2]))
				local cfg = {res = EXPLORE_WHIRL_EFFECT1}
				local particle = ClsParticleProp.new(cfg)
				particle:setPos(sea_pos.x, sea_pos.y)
				local explore_layer = getExploreLayer()
				local btn = explore_layer:createButton({image = "#explore_name2.png",
					text = v.name, fsize = 24, fy = 6, fcolor=ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
				btn:setPositionY(80)
				btn:regCallBack(function()
					---todo 导航到漩涡
					local config = table.clone(v)
					config.id = i
					self:navgationToWhirlPool({[1] = v.sea_pos[1], [2] = v.sea_pos[2]}, config)
				end)
				
				self.item_btn_menu[i] = btn
				particle.ui:addChild(btn)
				particle:setVisible( false );

				-- 漩涡的出现时机交给系统开关控制
				local function open_sys_switch( isOpen )
					-- body
					if particle == nil then return end
					particle:setVisible( isOpen )
					if not tolua.isnull(btn) then
						btn:setVisible(isOpen)
					end
				end
				local onOffData = getGameData():getOnOffData();
				if onOffData ~= nil then
					local on_off_item = on_off_info[v.switch_key]
					onOffData:pushOpenBtn( on_off_item.value, { name = string.format( "Whirlpool_3d%0.2d", i ), callBack = open_sys_switch } );
				else
					assert( false, "getGameData():getOnOffData() == nil?????" );
				end
				self.item_whirl_pool[i] = particle
			end

		--end
	end
end

function ExploreItem:showConveyEffect(convey_id)	
	local seaCofig = Explore_Whirlpool[convey_id]
	self:setWhilrMove(0)
	local exploreUtil = require("module/explore/exploreUtils")
	local sea_pos = exploreUtil:cocosToTile2(ccp(seaCofig.sea_pos[1], seaCofig.sea_pos[2]))
	exploreUtil:navgationToPostion({pos = sea_pos})
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		explore_layer:getShipsLayer():fastUpMyShipPos()
	end
end

function ExploreItem:navgationToWhirlPool(goalPos, config)
	EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = config.id, navType = EXPLORE_NAV_TYPE_WHIRLPOOL})
end


function ExploreItem:removeItem3D()
	for key, value in ipairs(self.item_whirl_pool) do
		value:release()
	end
	self.item_whirl_pool = nil
	self.player_ship = nil
end


function ExploreItem:onExit()
	UnRegTrigger(EVENT_EXPLORE_SHOW_WHIRLPOOL_INFO)
	self.parent = nil
end

ExploreItem.regFuns = function(self)
	local function showWpInfo(id)
		local config = table.clone(Explore_Whirlpool[id])
		if not config then
			return
		end

		local exploreData = getGameData():getExploreData()
		local is_can_move = exploreData:isCanConveyMove()
		if not is_can_move then
			return
		end

		config.id = id
		local level = getGameData():getPlayerData():getLevel()
		local gold = level * 100
		local tips = require("game_config/tips")
		local str = string.format(tips[76].msg, config.name, gold)
		
		local function okClickCallBack()
			self.selectWhirlConig = config
			exploreData:whirlConvey(config.id, self.isMove) --发送传送协议
		end

		Alert:showAttention(str, okClickCallBack, function()
			EventTrigger(EVENT_EXPLORE_MYSHIP_PAUSE) 
		end, nil, {hide_cancel_btn = true})
	end
	RegTrigger(EVENT_EXPLORE_SHOW_WHIRLPOOL_INFO, showWpInfo)
end 

return ExploreItem