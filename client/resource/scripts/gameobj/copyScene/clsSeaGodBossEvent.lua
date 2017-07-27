--create by pyq0639 16/12/24
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
local ClsExploreShip3d = require("gameobj/explore/exploreShip3d")
local haishen_plot = require("game_config/haishen_plot")
local sceneEffect = require("gameobj/battle/sceneEffect")
local ClsSeaGodBoss = class("ClsSeaGodBoss", ClsCopySceneEventObject)
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local seagod_boss_data = require("game_config/seagod_boss_data")
local sailor_config = require("game_config/sailor/sailor_info")
local ParticleSystem = require("particle_system")

local EFFECT_NAME = "tx_0167"
local widget_name = {
    {res = "role_level", not_visible = true},
    {res = "role_name",},
    {res = "hp_bar",},
    {res = "role_title", not_visible = true},
    {res = "ship_type", not_visible = true},
    {res = "sailor_quality", not_visible = true},
    {res = "sailor_quality_icon", not_visible = true},
    {res = "head_bg",},
    {res = "head_pic",}
}

function ClsSeaGodBoss:initEvent(data)
	self.ship_data = data
    self.event_id = data.id
    self.action_radius = 500
    self.is_touch = false
end

function ClsSeaGodBoss:initUI()
	if self.m_ship then return end

    local copy_scene_land = getUIManager():get("ClsCopySceneLayer"):getLand()
    local ship_pos = copy_scene_land:tileSizeToCocos(ccp(self.ship_data.x, self.ship_data.y))
	local ship_id = ClsSceneConfig[self.ship_data.type].special_attr["boatId"]
    local copy_scene_data = getGameData():getCopySceneData()
    self.m_ship = ClsExploreShip3d.new({
        id = ship_id,
        pos = ship_pos,
        speed = 0,
        name_color = COLOR_RED_STROKE,
        ship_ui = getSceneShipUI(),
    })
    self.m_ship:setAngle(ClsSceneConfig[self.ship_data.type].dir)
    self.m_ship.node:setTag("scene_event_id", tostring(self.event_id))
    self.item_model = self.m_ship
    self:initBossPanel()
    copy_scene_data:setSeaGodBossId(self.event_id)

    if not self.effect_node then
        self.effect_node = CCNode:create()
        getSceneShipUI():addChild(self.effect_node)
    end
    if self.pEffect then return end --异常情况boss船已存在特效不重新创建

    local parent = nil
    local effect_time = nil
    local pos = Vector3.new(0, 0, 0)
    if copy_scene_data:getDialogPopSwitch() then
        self.m_stop_reason = string.format("ClsSeaGodBoss_id_%d", self.event_id)
        self.m_ships_layer = ClsSceneManage:getSceneLayer():getShipsLayer()
        self.m_ships_layer:setStopShipReason(self.m_stop_reason)
        effect_time = 2

        self.pEffect = ParticleSystem.new(EFFECT_3D_PATH..EFFECT_NAME..PARTICLE_3D_EXT)
        parent = self.m_ship.node
        self:createEventDialog()
        copy_scene_data:setDialogPopSwitch(false)
    else
        effect_time = 840
        self.pEffect = ParticleSystem.new(EFFECT_3D_PATH.."tx_selected"..PARTICLE_3D_EXT)
        parent = Explore3D:getLayerShip3d()
        local off_set = Vector3.new(0, 100, 100)
        off_set:add(self.m_ship.node:getTranslation())
        pos = off_set
    end
    if self.pEffect then
        parent:addChild(self.pEffect:GetNode())
        self.pEffect:GetNode():setTranslation(pos)
        self.pEffect:Start()
    end

    local array = CCArray:create()
    array:addObject(CCDelayTime:create(effect_time))  
    array:addObject(CCCallFunc:create(function()
        if self.pEffect then
            self.pEffect:Release()
            self.pEffect = nil
        end
    end))
    self.effect_node:runAction(CCSequence:create(array))
end

function ClsSeaGodBoss:initBossPanel()
    local size = 40
    local ui_layer = UILayer:create()
    local job_str = SAILOR_JOB_BG[seagod_boss_data[self.ship_data.type].head_ui].normal
    local head_str = sailor_config[seagod_boss_data[self.ship_data.type].sailor_id].res
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_hp_enemy_role.json")
    convertUIType(panel)
    for i,v in ipairs(widget_name) do
        self[v.res] = getConvertChildByName(panel, v.res)
        if v.not_visible then
            self[v.res]:setVisible(false)
        end
    end
    panel:setAnchorPoint(ccp(0.5,-0.5))
    panel:setPosition(ccp(0, 30))
    ui_layer:addWidget(panel)
    self.m_ship.ui:addChild(ui_layer)
    ui_layer:setTouchEnabled(false)

    self.role_name:setText(ClsSceneConfig[self.ship_data.type].name)
    self.head_bg:changeTexture(job_str, UI_TEX_TYPE_PLIST)
    self.head_pic:changeTexture(head_str)
    self.head_pic:setScale(size/self.head_pic:getContentSize().width)
    self.hp_bar:setPercent(100)
end

function ClsSeaGodBoss:interactCallBack()
    if self.is_touch then return end

    self.is_touch = true
    self:sendInteractiveMessage()
end

function ClsSeaGodBoss:touch(node)
    if not node then return end
    local event_id = node:getTag("scene_event_id")
    if not event_id then return end
    if event_id ~= self.m_ship.node:getTag("scene_event_id") then return end
    if getGameData():getTeamData():isLock() then
        return
    end
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_layer = ClsSceneManage:getSceneLayer()
    local x, y = self.m_ship:getPos()
    local px, py = scene_layer.player_ship:getPos()
    local dis = Math.distance(px, py, x, y)
    if dis < self.action_radius / 2 then
        self:interactCallBack()
    else
        local news = require("game_config/news")
        local Alert = require("ui/tools/alert")
        Alert:warning({msg = news.COPY_TREASURE_BOX_EVENT_TIP.msg})
    end
    return true
end

function ClsSeaGodBoss:createEventDialog()
	local dialog_tab = haishen_plot[self.ship_data.type].dialog
    dialog_tab.call_back = function()
        self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
        -- if not getGameData():getTeamData():isLock() then
            self:sendInteractiveMessage()
        -- end
    end
    getUIManager():close("PlotDialog")
    getUIManager():create("gameobj/mission/plotDialog", nil, dialog_tab)
end

function ClsSeaGodBoss:removeShip()
    if self.m_ship then
        self.m_ship:release()
    end
    self.m_ship = nil

    if self.pEffect then
        self.pEffect:Release()
        self.pEffect = nil
    end
end

function ClsSeaGodBoss:release()
    self:removeShip()
    if self.effect_node and not tolua.isnull(self.effect_node) then
        self.effect_node:removeFromParent()
        self.effect_node = nil
    end
    if getGameData():getTeamData():isTeamLeader() then
        getGameData():getCopySceneData():askMoveCamera()
    end
end

return ClsSeaGodBoss