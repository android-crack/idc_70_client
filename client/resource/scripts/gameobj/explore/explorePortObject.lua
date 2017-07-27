local port_info = require("game_config/port/port_info")
local exploreMapUtil = require("module/explore/exploreMapUtil")
local commonBase  = require("gameobj/commonFuns")
local ClsExploreObject = require("gameobj/explore/exploreObject")
local ui_word = require("game_config/ui_word")
local composite_effect = require("gameobj/composite_effect")
local port_power = require("game_config/mission/port_power")

--探索港口视野对象
local ExplorePortObject  = class("ExplorePortObject", ClsExploreObject)

function ExplorePortObject:ctor(port_id)
	ExplorePortObject.super.ctor(self)
	self.is_active = false
	self.key = "port_"..port_id
	self.menu_camera = nil
	self.port_id = port_id
	self.port_base = port_info[port_id]
	self.pos = exploreMapUtil.cocosToTileByLand(ccp(self.port_base.name_pos[1], self.port_base.name_pos[2]))
	self.node:setPosition(self.pos)
end

--进入视野
function ExplorePortObject:onInField()
	-- cclog(T("========================进入视野 port_name=")..(self.port_base.name))
	ExplorePortObject.super.onInField(self)
end

function ExplorePortObject:isWillActive()
	local explore_map_data = getGameData():getExploreMapData()
	local area_id = explore_map_data:getCurAreaId()
	if self.port_base.areaId == area_id then 
		return true
	end 
end 

--进入视野初始化
function ExplorePortObject:inFieldInit()
	self.is_active = true
	local market_data = getGameData():getMarketData()
	local portPveData = getGameData():getPortPveData()
	local port_data = getGameData():getPortData()

	local port_battle_data = getGameData():getPortBattleData()
    local owner_name = port_battle_data:getExploreOccupyInfo(self.port_id).group_name

	if owner_name then
        self.node.name_bg = display.newSprite("#explore_name2.png")
        self.node.owner_effer = composite_effect.new("tx_shanghui_liuguang", 0, -6, self.node)
        self.node.owner_effer:setZOrder(-1)
    else
        self.node.name_bg = display.newSprite("#explore_name1.png")
    end
	
	self.node.name_bg = display.newSprite("#explore_name1.png")
	self.node.name_bg:setPosition(0, -6)
	self.node:addChild(self.node.name_bg, -1)


	self.node.name_label = createBMFont({text = self.port_base.name, size = 24, fontFile = FONT_TITLE, color=ccc3(dexToColor3B(COLOR_CREAM)), align=ui.TEXT_ALIGN_CENTER})
	self.node.name_label:setPosition(0, 0)
	self.node:addChild(self.node.name_label, 1)


	local power_id = port_data:getPortPowerInfo()[self.port_id].power_id
	local power_pos_x = nil
	if port_power[power_id] then
		self.node.port_power = display.newSprite(port_power[power_id].flagship_port_res)
		autoScaleWithLength(self.node.port_power, 40)
		power_pos_x = - (self.node.name_label:getContentSize().width / 2) - 5 - self.node.port_power:getContentSize().width / 2
		self.node.port_power:setPosition(power_pos_x, 2)

		self.node:addChild(self.node.port_power, 1)
	end

	if owner_name then
        owner_name = owner_name .. ui_word.STR_GUILD_NAME
        self.node.name_label:setPosition(0, -15)
        if not tolua.isnull(self.node.port_power) then
        	self.node.port_power:setPosition(power_pos_x, -15)
    	end
        self.node.owner_name_label = createBMFont({text = owner_name, size = 24, fontFile = FONT_TITLE, color=ccc3(dexToColor3B(COLOR_WHITE_STROKE)), align=ui.TEXT_ALIGN_CENTER, anchor = ccp(0.5, 0.5)})
        self.node.owner_name_label:setPosition(ccp(0 , 15))
        self.node:addChild(self.node.owner_name_label, 1)
        self.node.owner_name_left = display.newSprite("#title_side.png")
        self.node.owner_name_left:setPosition(ccp(-(self.node.owner_name_label:getContentSize().width / 2) - 10 , 15))
        self.node:addChild(self.node.owner_name_left, 1)

        self.node.owner_name_right = display.newSprite("#title_side.png")
        self.node.owner_name_right:setScaleX(-1)
        self.node.owner_name_right:setPosition(ccp(self.node.owner_name_label:getContentSize().width / 2 + 10 , 15))
        self.node:addChild(self.node.owner_name_right, 1)
    end

	local explore_layer = getExploreLayer()
	local sword_effect = nil
	local wait_effect = nil
	self.node.pve_icon = explore_layer:createButton({sound = "",image = "#explore_attack.png",x = 0, y = 70})
	self.node.pve_icon:regCallBack(function()
		if self.is_pause and sword_effect then return end
		self.node.pve_icon:setTouchEnabled(false)
		local arr_action = CCArray:create()
		arr_action:addObject(CCCallFunc:create(function()
			sword_effect = composite_effect.new("tx_boss_fight_sword", 0, 0, self.node.pve_icon, nil, true)
	    	wait_effect = composite_effect.new("tx_boss_fight_wait", 0, 0, self.node.pve_icon, nil, true)

	    	local music_info = require("game_config/music_info")
	    	audioExt.playEffect(music_info.BATTLE_BEGIN.res, false)
		end))
		arr_action:addObject(CCDelayTime:create(0.3))
		arr_action:addObject(CCCallFunc:create(function()
			if sword_effect then
				sword_effect:removeFromParentAndCleanup(true)
				sword_effect = nil
		    	wait_effect:removeFromParentAndCleanup(true)
		    	wait_effect = nil
		    	self.node.pve_icon:setTouchEnabled(true)
		    end
		end))
		self.node.pve_icon:runAction(CCSequence:create(arr_action))
		EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = self.port_id, navType = EXPLORE_NAV_TYPE_PORT})
	end)
	self.node:addChild(self.node.pve_icon)
	self.node.pve_icon:setVisible(false)

	local mission_data = getGameData():getMissionData()
	local mission_list = mission_data:getMissionInfo()
	for k, v in pairs(mission_list) do
		if v.ask_battle and v.ask_battle == self.port_id then 
			self.node.pve_icon:setVisible(true)
		end
	end

	local port_data = getGameData():getPortData()
	local port_power_info = port_data:getPortPowerInfo()
	local port_name_color = ccc3(dexToColor3B(COLOR_CREAM))
	if port_power_info[self.port_id].port_status == PORT_POWER_STATUS_HOSTILITY then
		port_name_color = ccc3(dexToColor3B(COLOR_RED_STROKE))
	end
	self.node.name_label:setColor(port_name_color)

	self:updateUIByOwner()
end

--离开视野
function ExplorePortObject:onOutField()
	-- cclog(T("========================离开视野 port_name=")..(self.port_base.name))
	ExplorePortObject.super.onOutField(self)
end

--离开视野清除
function ExplorePortObject:outFieldClear()
	self.is_active = false
	self.node:removeAllChildrenWithCleanup(true)
end

function ExplorePortObject:updateUIByPve()
	if not self:canUpdateUI() then
		return
	end
	local portPveData = getGameData():getPortPveData()
	if portPveData:isPortOpen(self.port_id) then
		self.node.pve_icon:setVisible(true)
		self.node.name_label:setColor(ccc3(dexToColor3B(COLOR_RED)))
	else
		self.node.pve_icon:setVisible(false)
		self.node.name_label:setColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
	end

	local port_data = getGameData():getPortData()
	local port_power_info = port_data:getPortPowerInfo()
	local port_name_color = ccc3(dexToColor3B(COLOR_CREAM))
	if port_power_info[self.port_id].port_status == PORT_POWER_STATUS_HOSTILITY then
		port_name_color = ccc3(dexToColor3B(COLOR_RED_STROKE))
	end
	self.node.name_label:setColor(port_name_color)
end

function ExplorePortObject:setPause(is_pause)
	ExplorePortObject.super.setPause(self, is_pause)
	if not tolua.isnull(self.node.pve_icon) then
		local enable = true
		if is_pause then
			enable = false
		end
		self.node.pve_icon:setEnabled(enable)
	end
end

function ExplorePortObject:selectPveIcon()
	if not self.is_active then
		return
	end
	self.node.pve_icon:selected()
end

function ExplorePortObject:unSelectPveIcon()
	if not self.is_active then
		return
	end
	self.node.pve_icon:unselected()
end

function ExplorePortObject:updateUIByOwner()
    if not self:canUpdateUI() then
        return
    end
   	local port_battle_data = getGameData():getPortBattleData()
    local owner_name = port_battle_data:getExploreOccupyInfo(self.port_id).group_name
    if owner_name then
        owner_name = owner_name .. ui_word.STR_GUILD_NAME
        self.node.name_bg:removeFromParentAndCleanup(true)
        if owner_name then
            self.node.name_bg = display.newSprite("#explore_name2.png")
        else
            self.node.name_bg = display.newSprite("#explore_name1.png")
        end

        self.node.name_bg:setPosition(0, -6)
        self.node:addChild(self.node.name_bg, -1)
        self.node.name_label:setPosition(0, -15)
        
        if tolua.isnull(self.node.owner_name_label) then
            self.node.owner_name_label = createBMFont({text = owner_name, size = 24, fontFile = FONT_TITLE, color=ccc3(dexToColor3B(COLOR_WHITE_STROKE)), align=ui.TEXT_ALIGN_CENTER, anchor = ccp(0.5, 0.5)})
            self.node.owner_name_label:setPosition(ccp(0 , 15))
            self.node:addChild(self.node.owner_name_label, 1)
        else
            self.node.owner_name_label:setString(owner_name)
        end

        if self.node.owner_effer then
            self.node.owner_effer = composite_effect.new("tx_shanghui_liuguang", 0, -6, self.node)
            self.node.owner_effer:setZOrder(-1)
        end

        if tolua.isnull(self.node.owner_name_left) then
            self.node.owner_name_left = display.newSprite("#title_side.png")
            self.node:addChild(self.node.owner_name_left, 1)
            self.node.owner_name_right = display.newSprite("#title_side.png")
            self.node.owner_name_right:setScaleX(-1)
            self.node:addChild(self.node.owner_name_right, 1)
        end

        self.node.owner_name_left:setPosition(ccp(-(self.node.owner_name_label:getContentSize().width / 2) - 10 , 15))
        self.node.owner_name_right:setPosition(ccp(self.node.owner_name_label:getContentSize().width / 2 + 10 , 15))
    else
        if self.node.owner_effer then
            self.node.owner_effer:removeFromParentAndCleanup(true)
            self.node.owner_effer = nil
        end

        if not tolua.isnull(self.node.owner_name_left) then
            self.node.owner_name_label:removeFromParentAndCleanup(true)
            self.node.owner_name_left:removeFromParentAndCleanup(true)
            self.node.owner_name_right:removeFromParentAndCleanup(true)
        end
    end
end

function ExplorePortObject:onEnter()
	ExplorePortObject.super.onEnter(self)
end

function ExplorePortObject:onExit()
	ExplorePortObject.super.onExit(self)
	self.menu_camera = nil
end

function ExplorePortObject:setMenuCamera()
	self.menu_camera = camera
end

return ExplorePortObject
