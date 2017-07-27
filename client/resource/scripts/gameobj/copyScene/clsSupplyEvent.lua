--
-- Author: lzg0496
-- Date: 2017-01-21 10:31:27
-- Function: 补给堆事件

local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local cfg_copy_scene_prototype = require("game_config/copyScene/copy_scene_prototype")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local cfg_music_info = require("game_config/music_info")
local cfg_ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local cfg_qte_config = require("game_config/copyScene/qte_config")

local clsSupplyEvent = class("clsSupplyEvent", ClsCopySceneEventObject)

local QTE_ACTION_CONFIG = {
    COLLECT = 3,
}

local SUPPLY_CD = 60

function clsSupplyEvent:initEvent(prop_data)
    if (device.platform == "windows") then
        table.print(prop_data)
    end
    self.event_data = prop_data
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    self.m_stop_reason = "is_supply"
    self.m_attr = self.event_data.attr
    self.hit_radius = 300
    self.m_pos = ccp(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.m_qte_supply_key = string.format("copy_event_id_%s_qte_supply_key", tostring(self.event_id))
    self.m_wait_reason = string.format("copy_event_id_%s_wait_1s", tostring(self.event_id))
    local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
    port_battle_datas[self.m_attr.index] = self.m_attr
    port_battle_datas[self.m_attr.index].event_obj = self
    self.collect_dis = nil
    self.is_supply_cd = false
end

function clsSupplyEvent:initUI()
    self:updateNameUi()
    self:createModel()
    ClsSceneManage:doLogic("updateMap")
end

function clsSupplyEvent:createModel()
    if self.item_model then
        return
    end
    self.item_model = Node.create()
    local ship_layer3d = Explore3D:getLayerShip3d()
    ship_layer3d:addChild(self.item_model)
    local pos = CameraFollow:cocosToGameplayWorld(ccp(self.m_pos.x, self.m_pos.y))
    local down = 0
    self.item_model:setTranslation(pos:x(), down, pos:z())
end

function clsSupplyEvent:updateNameUi(time)
    local name = cfg_copy_scene_prototype[self.event_type].name
    if not self.m_name_ui then
        self.m_name_ui = display.newSprite("#explore_name1.png")
        local ui_size = self.m_name_ui:getContentSize()
        getSceneShipUI():addChild(self.m_name_ui, -1)
        self.m_name_ui:setPosition(ccp(self.m_pos.x + 40, self.m_pos.y + 40))
        self.m_name_ui.progress = self:createHpProgress()
        self.m_name_ui:addChild( self.m_name_ui.progress)
        self.m_name_ui.progress:setPosition(ccp(ui_size.width / 2, -50))
        self.m_name_ui.progress:setVisible(false)

        self.m_name_ui.lbl_name = createBMFont({text = name, size = 20, color = ccc3(dexToColor3B(COLOR_WHITE)), x = ui_size.width/2, y = ui_size.height/2 + 7})
        self.m_name_ui:addChild(self.m_name_ui.lbl_name)
        return
    end

    if time then
        self.is_supply_cd = true
        self.m_name_ui.lbl_name:stopAllActions()
        local arr_action = CCArray:create()
        arr_action:addObject(CCCallFunc:create(function()
            time = time - 1
            local str = string.format("%s(%ds)", name, time)
            self.m_name_ui.lbl_name:setString(str)
            if time == 0 then
                self.m_name_ui.lbl_name:setString(name)
                self.m_name_ui.lbl_name:stopAllActions()
                self.is_supply_cd = false
                return
            end
        end))
        arr_action:addObject(CCDelayTime:create(1))
        self.m_name_ui.lbl_name:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
    else
        self.m_name_ui.lbl_name:setString(name)
        self.m_name_ui.lbl_name:stopAllActions()
    end
end

function clsSupplyEvent:showCollectionEffect()
    local value = 0
    self.hpProgress:setPercentage(value)
    self.m_name_ui.progress:stopAllActions()
    self.m_name_ui.progress:setVisible(true)
    local arr_action = CCArray:create()
    arr_action:addObject(CCCallFunc:create(function()
        value = value + 1
        self.hpProgress:setPercentage(value)
        if value == 100 then
            self.m_name_ui.progress:stopAllActions()
            self:sendSalvageMessage()
            ClsAlert:warning({msg = cfg_ui_word.STR_COLLECTION_SUCCESS})
            self.m_name_ui.progress:setVisible(false)
            self:showAllSupplyCD()
        end
    end))
    arr_action:addObject(CCDelayTime:create(0.01))
    self.m_name_ui.progress:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

function clsSupplyEvent:showAllSupplyCD()
    local event_objs = ClsSceneManage:getAllEventObj()
    for k, v in pairs(event_objs) do
        if v.event_type == self.event_type then
            v:updateNameUi(SUPPLY_CD)
        end
    end
end

function clsSupplyEvent:cancelCollection()
    self.m_name_ui.progress:stopAllActions()
    self.m_name_ui.progress:setVisible(false)
end

function clsSupplyEvent:update(dt)
    local scene_layer = ClsSceneManage:getSceneLayer()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, self.m_pos.x, self.m_pos.y) 
    if dis < self.hit_radius then
        if not self.is_supply and not self.is_supply_cd and not ClsSceneManage:doLogic("isHasSupply") then
            self.is_supply = true
            self.m_event_layer:addActiveKey(self.m_qte_supply_key, function() 
                return self:getQteBtn(self.m_wait_reason, 0, function()
                        if ClsSceneManage:doLogic("isNotCanInteractive") then
                            self.is_supply = false
                            return
                        end

                        if ClsSceneManage:doLogic("isNotCanSailing") then
                            ClsAlert:warning({msg = cfg_ui_word.STR_NOT_SAILING_TIP})
                            self.is_supply = false
                            return
                        end
                        self.collect_dis = dis
                        self:showCollectionEffect()
                    end, cfg_qte_config[QTE_ACTION_CONFIG.COLLECT].res) 
            end)
        end
    else
        self.is_supply = false
        self.m_event_layer:removeActiveKey(self.m_qte_supply_key)
    end

    if self.collect_dis and dis - self.collect_dis > MAP_TILE_SIZE then
        self.collect_dis = nil
        self:cancelCollection()
    end
end

function clsSupplyEvent:updataAttr(key, value)
    local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
    port_battle_datas[self.m_attr.index].attr = self.m_attr
end

function clsSupplyEvent:release()
    self:__endEvent()
end

function clsSupplyEvent:__endEvent()
    self.hp = 0
    self.m_attr.hp = 0
    local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
    port_battle_datas[self.m_attr.index].attr = self.m_attr

    if self.item_model then
        if self.item_model:getParent() then 
            self.item_model:getParent():removeChild(self.item_model)
        end
        self.item_model_node = nil
    end
end

return clsSupplyEvent
