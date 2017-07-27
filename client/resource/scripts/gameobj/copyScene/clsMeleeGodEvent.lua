-- Author: pyq0639
-- Date: 2017-03-14 14:09:55
-- Function: 乱斗副本海神像
local ui_word = require("game_config/ui_word")
local cfg_copy_scene_melee_objects = require("game_config/copyScene/top_fight_objects")
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local cfg_copy_scene_prototype = require("game_config/copyScene/copy_scene_prototype")
local ClsPropEntity = require("gameobj/copyScene/copySceneProp")
local ClsMeleeGodEvent = class("ClsMeleeGodEvent", ClsCopySceneEventObject)
local ParticleSystem = require("particle_system")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")

local EFFECT_NAME = "tx_attack_up"

function ClsMeleeGodEvent:initEvent(prop_data)
    self.is_touch = false
    self.m_in_buff_cd = false
	self.event_data = prop_data
    self.event_create_time = prop_data.create_time
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    self.config = cfg_copy_scene_melee_objects[prop_data.attr.index]
    local res = cfg_copy_scene_prototype[self.event_type].res
    local item = ClsPropEntity.new({res = cfg_copy_scene_prototype[self.event_type].res, 
    	hit_radius = cfg_copy_scene_prototype[self.event_type].hit_radius})
    item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.item_model = item
    self.item_model.id = self.event_id
    self.item_model.node:setTag("scene_event_id", tostring(self.event_id))

    self.m_ships_layer = ClsSceneManage:getSceneLayer():getShipsLayer()
end

function ClsMeleeGodEvent:initUI()
    if not self.m_name_ui then
        self.m_name_ui = display.newSprite("#explore_name1.png")
        local ui_size = self.m_name_ui:getContentSize()
        getSceneShipUI():addChild(self.m_name_ui)
        local pos_x, pos_y = self.event_data.sea_pos.x, self.event_data.sea_pos.y
        self.m_name_ui:setPosition(ccp(pos_x, pos_y - 10))

        local name_lab = createBMFont({text = self.config.name, size = 24, x = ui_size.width/2, y = ui_size.height/2 + 7})
        self.m_name_ui:addChild(name_lab)
        self.m_name_ui:setScale(0.6)
        if not self.time_label then
            self.time_label = createBMFont({text = "", size = 20, color = ccc3(dexToColor3B(COLOR_WHITE)), x = ui_size.width/2 + 6, y = ui_size.height/2 + 42})
            self.m_name_ui:addChild(self.time_label)
            self.time_label:setVisible(false)
        end
    end
    if not self.effect_node then
        self.effect_node = CCNode:create()
        getSceneShipUI():addChild(self.effect_node)
    end
    if self.end_cd_time then
        self:updateBuffCD(self.end_cd_time)
    end
end

function ClsMeleeGodEvent:showBuffEffect()
    local uid = getGameData():getPlayerData():getUid()
    local user_ship = getUIManager():get("ClsCopySceneLayer"):getShipsLayer():getShipWithMyShip(uid)
    if user_ship and not self.pEffect then
        self.pEffect = ParticleSystem.new(EFFECT_3D_PATH..EFFECT_NAME..PARTICLE_3D_EXT)
        local parent = Explore3D:getLayerShip3d()
        local off_set = Vector3.new(0, 100, 100)
        off_set:add(user_ship.node:getTranslation())

        if self.pEffect then
            parent:addChild(self.pEffect:GetNode())
            self.pEffect:GetNode():setTranslation(off_set)
            self.pEffect:Start()
            self.m_ships_layer:setStopShipReason(EFFECT_NAME)
        end
    end

    local array = CCArray:create()
    array:addObject(CCDelayTime:create(4))  
    array:addObject(CCCallFunc:create(function()
        self.m_ships_layer:releaseStopShipReason(EFFECT_NAME)
        if self.pEffect then
            self.pEffect:Release()
            self.pEffect = nil
        end
    end))
    self.effect_node:runAction(CCSequence:create(array))
end

function ClsMeleeGodEvent:updataInteractiveResult(interactive_type, result)
    if result == 0 then
        self:showBuffEffect()
    end
end

function ClsMeleeGodEvent:touch(node)
	if not node then return end
	local event_id = node:getTag("scene_event_id")
    if not event_id then return end
    event_id = tonumber(event_id)
    if event_id ~= self:getEventId() then
        return
    end

    local Alert = require("ui/tools/alert")
    local melee_status = getGameData():getCopySceneData():getMeleeStatus()
    if melee_status == MELEE_WRECK_STATUS then 
        Alert:warning({msg = ui_word.STR_MELEE_WRECK_CLICK})
        return 
    end
    if melee_status == WAIT_STATUS or melee_status == PVE_STATUS then
        Alert:warning({msg = ui_word.STR_MELEE_GOD_PRE_TIP})
        return
    end
    if self.m_in_buff_cd then
        local left_time = self.end_cd_time - (os.time() + getGameData():getPlayerData():getTimeDelta())
        if left_time > 0 then
            Alert:warning({msg = string.format(ui_word.STR_MELEE_GOD_CD_TIP, left_time)})
        end
    else
        self:sendSalvageMessage()
    end
end

function ClsMeleeGodEvent:disposeSchedule()
    if self.updateTimeHandle then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
end

function ClsMeleeGodEvent:updateBuffCD(end_time)
    self.is_touch = false
    self.m_in_buff_cd = true
    self.end_cd_time = end_time

    local function updateTime()
        if tolua.isnull(self.time_label) then
            self:disposeSchedule()
            return
        end
        self.time_label:setVisible(true)
        local cur_time = os.time() + getGameData():getPlayerData():getTimeDelta()
        self.remain_time = math.ceil(self.end_cd_time - cur_time)
        if self.remain_time <= 0 then
            self.m_in_buff_cd = false 
            self.time_label:setVisible(false)
            self:disposeSchedule()
        else
            local time_str = string.format("%02d:%02d", math.floor(self.remain_time/60), self.remain_time - (math.floor(self.remain_time/60)*60))
            self.time_label:setString(time_str)
        end
    end

    local scheduler = CCDirector:sharedDirector():getScheduler()
    self:disposeSchedule()
    self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime, 1, false)
end

function ClsMeleeGodEvent:release()
	if self.item_model then
		self.item_model:release()
		self.item_model = nil
	end
    if self.pEffect then
        self.pEffect:Release()
        self.pEffect = nil
    end
end

return ClsMeleeGodEvent