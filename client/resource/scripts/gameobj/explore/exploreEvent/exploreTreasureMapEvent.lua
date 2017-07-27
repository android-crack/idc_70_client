
----藏宝图

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local explore_event = require("game_config/explore/explore_event")
local explore_skill = require("game_config/explore/explore_skill")
local music_info = require("game_config/music_info")

local ClsExploreTreasureMapEvent = class("ClsExploreTreasureMapEvent", ClsExploreEventBase)

local DIS = 100*100
local explore_event_judian = 28 
local explore_event_baocang = 18
local BATTON_ID = 1070   ---按钮id
local TREASURE_ID = 80   ---藏宝图id
local TREASURE_VIP_ID = 164   ---高级藏宝图

function ClsExploreTreasureMapEvent:initEvent()

    self.explore_event_id = 0
    local treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
    if treasure_info and treasure_info.treasure_id == TREASURE_ID then
        self.explore_event_id = explore_event_baocang       
    elseif treasure_info.treasure_id == TREASURE_VIP_ID then
        self.explore_event_id = explore_event_judian
    end

	local event_config_item = explore_event[self.explore_event_id]
	self.m_event_type = event_config_item.event_type
	self.m_active_skill_item = explore_skill[event_config_item.effective_skill_id]
	local param = {}
    param.res = event_config_item.res
    param.animation_res = event_config_item.animation_res
    param.water_res = event_config_item.water_res
    param.sea_level = event_config_item.sea_level
    param.type = self.m_event_type
    param.item_id = self.m_eid
    param.sea_down = event_config_item.sea_down
    param.hit_radius = event_config_item.hit_radius

    self.m_item_model = propEntity.new(param)
    self.m_item_model.node:setTag("explore_event_id", tostring(self.m_eid))

    self.m_skill_id = BATTON_ID

    self.m_stop_reason = string.format("%s_ExploreTreasureMapEvent_id%s_getReward", self.m_event_type, tostring(self.m_eid))
    
    local pos = getGameData():getPropDataHandler():getTreasureCoordBig()

    local item = self.m_explore_layer:getLand():cocosToTile2(ccp(pos[1], pos[2]))
    
    self.m_item_model:setPos(item.x, item.y)
    -- --按钮
    if treasure_info.treasure_id == TREASURE_VIP_ID then
        self:createBtn()
    end

end

function ClsExploreTreasureMapEvent:createBtn()
    local skill_res = "#explore_pve1.png"
    local btn = MyMenuItem.new({image = "#explore_skill.png", isAudio = false, unSelectScale = 0.7, selectScale = 0.6})
    local skill_spr = display.newSprite(skill_res)
    local posY = 60
    local size = btn.m_pNormalImage:getContentSize()

    skill_spr:setPosition(ccp(size.width / 2, size.height / 2))
    btn.m_pNormalImage:addChild(skill_spr)
    btn:setPositionY(posY)
    btn:setScale(0.7)
    
    local fadeIn = CCFadeTo:create(0.5, 255 * 0.5)
    local fadeOut = CCFadeTo:create(0.5, 255)
    local actions = CCArray:create()
    actions:addObject(fadeIn)
    actions:addObject(fadeOut)
    local action = CCSequence:create(actions)
    btn.m_pNormalImage:setCascadeOpacityEnabled(true)
    btn.m_pNormalImage:runAction(CCRepeatForever:create(action))

    btn:regCallBack(function()
            self:touch()
        end)
    local btn_menu = MyMenu.new({btn})
    btn_menu.camera = getExploreLayer():getCamera()
    btn_menu:setCheckCanGetTouchFunc(function()
        local explore_ui = getExploreUI()
        if not tolua.isnull(explore_ui) then
            if not tolua.isnull(explore_ui.world_map) and explore_ui.world_map:getShowMax() then
                return false
            end
        end
        return true
        end)
    self.m_item_model.ui:addChild(btn_menu)
end

function ClsExploreTreasureMapEvent:isCreateTreasureMap()
    local treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
    if treasure_info and treasure_info.treasure_id ~= 0 then
        return true
    end
    return false
end

function ClsExploreTreasureMapEvent:touch()

    if self.m_is_firing or self.m_is_lock_touch then
        return
    end
    local x, y = self.m_item_model:getPos()
    local px, py = self.m_player_ship:getPos()
    local dis2 = self:getDistance2(x, y, px, py)
    if self.explore_event_id == explore_event_judian then
        getGameData():getPropDataHandler():arriveTreasureItem()
    end
end

function ClsExploreTreasureMapEvent:update(dt)
   if self.m_is_end or self.m_is_firing then
        return
    end
    local new_time = os.time()
    local treasure_info = getGameData():getPropDataHandler():getTreasureInfo()
    if treasure_info.end_time - new_time <= 0 then
        if self.m_item_model then
            self.m_item_model:setVisible(false)
        end
        self.m_is_end = true
    end

    local x, y = self.m_item_model:getPos()
    local px, py = self.m_player_ship:getPos()
    local dis2 = self:getDistance2(x, y, px, py)

    if self.explore_event_id == explore_event_baocang then
        if dis2 < DIS and not self.m_is_firing then
            self:showEventEffect()
        end       
    end

end

function ClsExploreTreasureMapEvent:showEventEffect()
    local team_data = getGameData():getTeamData()
    if team_data:isLock() then
        return
    end
        
    self.m_is_firing = true
    self.m_is_lock_touch  = true   
    local function tip_callBack()
        if self.m_item_model then
            self.m_item_model:setVisible(false)
        end
    end

    local function end_callBack()
        self.m_event_layer:removeCustomEventById(self.m_eid)
        self.m_is_end = true
        self.m_is_lock_touch  = false  
        self.m_is_firing = false
        ----清理数据
        -- local list = {treasure_id = 0, mapId = 0, positionId = 0, time = 0}
        -- getGameData():getPropDataHandler():setTreasureInfo(list)
        if IS_AUTO then
            local exploreLayer = getExploreLayer()
            if not tolua.isnull(exploreLayer) then
                exploreLayer:releaseTreasureAuto()
                exploreLayer:getLand():breakAuto(true)                
            end

        end
        getGameData():getPropDataHandler():arriveTreasureItem()
    end
    
    local ClsExploreSalvageSkill = require("gameobj/explore/exploreSalvageSkill")
    local target = {spItem = self.m_item_model}
    local params = {
        ship_id = self.m_player_ship.id,
        anim_call = "scripts/gameobj/gameplayFunc.lua#animationClipPlayEnd", 
        targetNode = target.spItem.node,
        targetData = target,
        ship = self.m_player_ship,
        num = 1,
        modelFile = "ex_salvage",
        animationFile = "ex_salvage",
        targetCallBack = end_callBack,
        tipCallBack = tip_callBack,
    }

    ClsExploreSalvageSkill.new(params)
    self.m_ships_layer:setStopShipReason(self.m_stop_reason)
    audioExt.playEffect(music_info[self.m_active_skill_item.fire_sound].res)
end

function ClsExploreTreasureMapEvent:release()
    if self.m_ships_layer then
        self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)   
    end
	if self.m_item_model then
		self.m_item_model:release()
		self.m_item_model = nil
	end
end

return ClsExploreTreasureMapEvent