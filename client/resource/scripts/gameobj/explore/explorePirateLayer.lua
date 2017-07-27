-- 探索事件

local explore_event = require("game_config/explore/explore_event")
local commonBase = require("gameobj/commonFuns")
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local UI_WORD = require("game_config/ui_word")
local shipEntity = require("gameobj/explore/explorePirate")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local ExploreUtil = require("module/explore/exploreUtils")


local ClsExplorePirateLayer = class("ExplorePirateLayer", function() return CCLayer:create() end)

function ClsExplorePirateLayer:ctor(parent)

    self:registerScriptHandler(function(event)
        if event == "exit" then
            self:onExit()
        end
    end)
    self.is_pause = false
    self.parent = parent
    self.pirate_ships = {}
    self.boss_childs = {}
    local function update(dt)
        self:update(dt)
    end
    local scheduler = CCDirector:sharedDirector():getScheduler()
    self.hander_time = scheduler:scheduleScriptFunc(update, 0, false)
    self:createAlertBossView()
end

function ClsExplorePirateLayer:stopHandle()
    if self.hander_time then 
        local scheduler = CCDirector:sharedDirector():getScheduler()
        scheduler:unscheduleScriptEntry(self.hander_time) 
        self.hander_time = nil  
    end 
end

-- 更新掠夺船只的位置
function ClsExplorePirateLayer:update(dt)
    if self.pirate_ships == nil then return end
    
    if self.parent.showPortStart or self.parent.port_info_show or (self.is_pause) then
        return
    end

    local dx = 10
    local px, py = self.parent.player_ship:getPos()
    local DX = 600
    local s_Dx = 100
    for k, ship in pairs(self.pirate_ships) do
        ship:update(dt)
        if ship.event_id  then
            local x, y = ship:getPos()
            local dis = Math.distance(px, py, x, y)
            if dis < s_Dx then
                self:sendFightMessage(ship)
            elseif dis < DX then
                --暂停寻路，加速冲上玩家，进入战斗
                ship:showShipDialog()
                ship:stopFindPath()
                ship:setSpeed(200)
                ship:setChildShipSpeed()
                local rate = 1.0
                ship:setSpeedRate(rate)
                local translate1 = self.parent.player_ship.node:getTranslationWorld() --船
                local translate2 = ship.node:getTranslationWorld()
                local dir = Vector3.new()
                Vector3.subtract(translate1, translate2, dir)
                LookForward(ship.node, dir)
            else
                ship:autoPath()
            end
        end
    end

    --boss 跟随的小怪
    for _, child_table in pairs(self.boss_childs) do
        for _, child_ship in pairs(child_table) do
            child_ship:update(dt)
        end
    end

end

function ClsExplorePirateLayer:createPirateShip(event_id, isBoss)

    if self.pirate_ships[event_id] then
        print("下发了相同事件的ID--------------------")
        return 
    end
    local exploreData = getGameData():getExploreData()
    local eventItem = exploreData:getEventById(event_id)
    local jsonStrTable = json.decode(eventItem.jsonArgs)
    local pirate_id = jsonStrTable.pirateId
    local config = nil
    local exploreData = getGameData():getExploreData()

    local pirate_info = require("game_config/explore/pirate_main_info")
    local boss_info = require("game_config/explore/patrol_boss_info")
    print("pirate_id===========", pirate_id, isBoss)
    print("事件id --------", event_id)
    if isBoss then
        config = boss_info[pirate_id]
        local boss_name = config.name
        local sailor_info = require("game_config/sailor/sailor_info")
        local sailor_ID = tonumber(config.sailor_id)
        if sailor_ID < 1 then
            sailor_ID = 1
        end
        local icon = sailor_info[sailor_ID].res
        local scale = 0.4
        if sailor_info[sailor_ID].star >= 6 then
            scale = 0.2
        end
        local area_id = config.area
        self:showBossViewAction(icon, boss_name, false, scale, area_id)
    else
        config = pirate_info[pirate_id]
    end
    
    config = table.clone(config)
    local boat_id = config.boatId
    local start_pos = ExploreUtil:cocosToTile2(ccp(config.path[1][1], config.path[1][2]))
    local end_pos = ExploreUtil:cocosToTile2(ccp(config.path[2][1], config.path[2][2]))
    config.start_pos = start_pos
    config.end_pos = end_pos
   
    local speed = config.speed
    local name = config.name
    if boat_info[boat_id] == nil then
        print("船的表为空---------", boat_id)
        return
    end
    -- local ship_res_3d = boat_info[boat_id].res_3d_id
    local ship = self:_createShip({
    id = boat_id,
    name = name,
    pos = start_pos,
    speed = speed,
    turn_speed = boat_attr[boat_id].angle or 100,
    ship_ui = getShipUI(),
    event_id = event_id,
    config = config, 
    pirate_id = pirate_id, 
    is_boss = isBoss, 
    start_time = jsonStrTable.start_time,
    icon = config.sailor_id})

    ship.land = self.parent.land
    ship:setPos(start_pos.x, start_pos.y)
    ship:initPiratePos()
    ship:initPos()
    if isBoss then
        self:createBossChildShips(event_id, config, ship, speed)
    end
end

function ClsExplorePirateLayer:createBossChildShips(event_id, config, parent, speed)

    local pos = {}
    
    local px, py = parent:getPos()
    print("创建boss======================")
    local dist = 120
    local angle = 45
    for i = 0, 3 do
         local xAngle = angle + i * angle
         local x = dist * Math.sin(Math.rad(xAngle)) + px
         local y = dist * Math.cos(Math.rad(xAngle)) + py
         if self.parent:getMapState(x, y, true) ~= MAP_LAND then
             pos[#pos + 1] = ccp(x, y)
             break
         end
    end
    for i = 4, 7 do
         local xAngle = angle + i * angle
         local x = dist * Math.sin(Math.rad(xAngle)) + px
         local y = dist * Math.cos(Math.rad(xAngle)) + py
         if self.parent:getMapState(x, y, true) ~= MAP_LAND then
             pos[#pos + 1] = ccp(x, y)
             break
         end
    end

    local index = 1
    for _, info in pairs(config.follow) do
        local pirate_id = info[1]
        local x = info[2]
        local y = info[3]
        local pirate_info = require("game_config/explore/pirate_main_info")
        local child_info = pirate_info[pirate_id]
        local boat_id = child_info.boatId
        -- local ship_res_3d = boat_info[boat_id].res_3d_id

        local start_pos = ExploreUtil:cocosToTile2(ccp(x, y))

        if pos[index] then
            start_pos = pos[index]
        else
            return
        end
        local speed = speed
        local name = child_info.name

        local param = {
            id = id,
            name = name,
            pos = start_pos,
            speed = speed + 30,
            turn_speed = boat_attr[boat_id].angle,
            ship_ui = getShipUI(),
            pirate_id = pirate_id, 
            is_child = true,
        }
        local ship = shipEntity.new(param)
        ship.land = self.parent.land
        ship.node:setTag("parent_event_id", tostring(event_id))
        parent:addBossChild(ship)
        local childs = self.boss_childs[event_id] 
        if not childs then
            childs = {}
        end
        childs[#childs + 1] = ship
        self.boss_childs[event_id] = childs
        index = index + 1
    end
end

function ClsExplorePirateLayer:_createShip(param)
    local ship = shipEntity.new(param)
    local event_id = param.event_id
    ship.node:setTag("pirate_ship", tostring(event_id))
    self.pirate_ships[event_id] = ship
    return ship
end

function ClsExplorePirateLayer:removeShip(ship)
    if not ship then return end
    local event_id = ship.event_id
    --如果是boss，删除小怪
    local childs = self.boss_childs[event_id]
    if childs then
        for _, child_ship in pairs(childs) do
            child_ship:release()
        end
    end
    self.boss_childs[event_id] = nil
    ship:release()
    self.pirate_ships[event_id] = nil
end

function ClsExplorePirateLayer:removeShipByEventId(event_id)
   local ship = self.pirate_ships[event_id]
   if ship then
        self:removeShip(ship)
   end
end

function ClsExplorePirateLayer:removeAllPirates()
    --
    if not self.pirate_ships then return end
    for k, ship in pairs(self.pirate_ships) do
        self:removeShip(ship)
        ship = nil
    end
    self.pirate_ships = {}
end

function ClsExplorePirateLayer:onExit()
    self:stopHandle()
end

function ClsExplorePirateLayer:sendFightMessage(ship) --玩家和海盗的距离靠近了，发送进入战斗协议
    if not ship.sendMessage then
        self.parent:upShipPosToServer()
        local Alert = require("ui/tools/alert")
        local _msg = ""
        local name = ship.config.name
         _msg = string.format(UI_WORD.BE_ATTACK_TIPS, name)
        Alert:warning({msg = _msg, size = 26, color = ccc3(dexToColor3B(COLOR_RED))})
        ship.sendMessage = true
        local exploreData = getGameData():getExploreData()
        local pirate_id = ship.pirate_id
        print("发送给后端的事件id----------", ship.event_id, pirate_id)
        exploreData:exploreEventEnd(ship.event_id, pirate_id)
    end
end

function ClsExplorePirateLayer:showBossView(area_id)
    for k, ship in pairs(self.pirate_ships) do
        if ship.is_boss then
            if ship.config.area == area_id then
                    local boss_name = ship.config.name
                    local sailor_info = require("game_config/sailor/sailor_info")
                    local sailor_ID = tonumber(ship.config.sailor_id)
                    if sailor_ID < 1 then
                        sailor_ID = 1
                    end
                    local icon = sailor_info[sailor_ID].res
                    local scale = 0.4
                    if sailor_info[sailor_ID].star >= 6 then
                        scale = 0.2
                    end
                    self:showBossViewAction(icon, boss_name, false, scale, area_id)
                return;
            end
        end
    end
    self:showBossViewAction(nil, nil, true)
end

function ClsExplorePirateLayer:createAlertBossView()
    local scene = getExploreScene()
    self.ui_layer = UILayer:create()
    self.ui_layer:setTouchEnabled(false)
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_sea_boss.json")
    self.ui_layer:addWidget(self.panel)
    scene:addChild(self.ui_layer, ZORDER_UI_LAYER - 2)
    self.pirate_boss_name = getConvertChildByName(self.panel, "boss_name")
    self.pirate_boss_seaman_icon = getConvertChildByName(self.panel, "seaman_icon")
    self.ui_layer:setPosition(ccp(display.cx - 100, display.height))
end

function ClsExplorePirateLayer:setPirateBossViewVisible(value)
    self.ui_layer:setVisible(value)
end

function ClsExplorePirateLayer:showBossViewAction(icon, boss_name, up, scale, area_id)
    scale = scale or 0.4
    if icon and boss_name then
        self.pirate_boss_name:setText(boss_name)
        self.pirate_boss_seaman_icon:setTexture(icon)
        self.pirate_boss_seaman_icon:setScale(scale)
    end

    local down_pos = ccp(display.cx - 100, display.height - 100)
    local up_pos = ccp(display.cx - 100, display.height)
    local array = CCArray:create()
    local time = 0.1
    local pos = nil
    if up then
        pos = up_pos
    else
        pos = down_pos
        local _msg = ""
        local area_info = require("scripts/game_config/port/area_info")
        local area_name = area_info[area_id].name
         _msg = string.format(ui_word.BE_ATTACK_CARRZY_TIPS, boss_name, area_name )
        Alert:warning({msg = _msg, size = 26, color = ccc3(dexToColor3B(COLOR_RED))})
    end
    array:addObject(CCMoveTo:create(time, pos))
    self.ui_layer:runAction(CCSequence:create(array))
end

function ClsExplorePirateLayer:setPause(value)
    self.is_pause = value
end

local BOSS_CONFIG_ID = 27
local PIRATE_CONFIG_ID = 26
function ClsExplorePirateLayer:comeBackExplore() --战斗胜利后，回到海面上
    local exploreData = getGameData():getExploreData()

    local explore_pirate_ids = exploreData:getPirateShips()
    local pirate_boss = explore_pirate_ids.boss_pirate
    local pirates =  explore_pirate_ids.pirate
   
    for event_id, value in pairs(exploreData.eventLists) do
        if value.evType == BOSS_CONFIG_ID then
            local jsonStrTable = json.decode(value.jsonArgs)
            local pirate_id = jsonStrTable.pirateId
            local has = nil
            if pirate_boss then
                for _, item in pairs(pirate_boss) do
                    if item.id == pirate_id then
                        has = true
                        if (not self.pirate_ships[event_id]) then
                            self:createPirateShip(event_id, true)
                        end
                        break;
                    end
                end
            end
            if not has and (not self.pirate_ships[event_id]) then
                self:createPirateShip(event_id, true)
            end
        elseif value.evType == PIRATE_CONFIG_ID then
            local jsonStrTable = json.decode(value.jsonArgs)
            local pirate_id = jsonStrTable.pirateId
            local has = nil
            if pirates then
                for _, item in pairs(pirates) do
                    if item.id == pirate_id then
                        has = true
                        if (not self.pirate_ships[event_id]) then
                            self:createPirateShip(event_id, nil)
                        end
                        break
                    end
                end
            end
            if not self.pirate_ships[event_id] and not has then
                self:createPirateShip(event_id, nil)
            end
        end
    end
end

return ClsExplorePirateLayer