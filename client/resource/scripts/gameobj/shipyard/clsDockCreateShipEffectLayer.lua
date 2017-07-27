--造船成功界面
local music_info = require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local ui_word = require("game_config/ui_word")
local CompositeEffect = require("gameobj/composite_effect")
local skill_info = require("game_config/skill/skill_info")
local base_attr_info = require("game_config/base_attr_info")
local scheduler = CCDirector:sharedDirector():getScheduler()
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local MAX_BASE_PROPERY_NUM = 9


local ClsBaseView = require("ui/view/clsBaseView")
local ClsDockCreateShipEffectLayer = class("ClsDockCreateShipEffectLayer", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsDockCreateShipEffectLayer:getViewConfig()
    return {
        name = "ClsDockCreateShipEffectLayer",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

--页面创建时调用
function ClsDockCreateShipEffectLayer:onEnter(parameter)
    self.boat_info = parameter.boat_info

    self.call_back = parameter.call_back
    self.is_create = parameter.is_create or false

    self.res_plist = {
        ["ui/shipyard_ui.plist"] = 1,
    }
    LoadPlist(self.res_plist)

    self.armature_tab = {
    }

    LoadArmature(self.armature_tab)

    self:configUI()
end

function ClsDockCreateShipEffectLayer:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_get_boat.json")
    self:addWidget(self.panel)
    self.bg = getConvertChildByName(self.panel, "bg")
    self:updateView()

    self.effect_layer = display.newLayer()
    self:addChild(self.effect_layer)
    if(not self.is_create)then
        self:showEffect()
    else
        self:showLightAct()
    end
    self:openScheduler()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            return true
        elseif event_type == "ended" then
            if self.effect_end then
                self:closeView()
            end
        end
    end)
end

function ClsDockCreateShipEffectLayer:showLightAct()
    self.bg:setVisible(false)

    local eff_name = {"tx_ship_build_lv","tx_ship_build_lan","tx_ship_build_zi","tx_ship_build_huang"}
    local quality = self.boat_info.quality

    local function lightCB(  )
        self.bg:setVisible(true)
        self:showEffect()
    end
     
    if(quality > 1 and quality < 6)then
        local effct_build = CompositeEffect.new(eff_name[quality - 1], 480, 270,self.effect_layer)
        effct_build:setZOrder(1)
        audioExt.playEffect(music_info.SHIPYARD_BUILD.res)
        local array_action = CCArray:create()
        array_action:addObject(CCDelayTime:create(0.9))
        array_action:addObject(CCCallFuncN:create(function() 
            lightCB()
        end))
        array_action:addObject(CCMoveBy:create(0.5, ccp(-15, 0)))
        effct_build:runAction(CCSequence:create(array_action))
    else
        lightCB()
    end
end

function ClsDockCreateShipEffectLayer:showEffect()
    local boat = boat_info[self.boat_info.id]
    local res_id = boat.armature
    self.res_armature = string.format("armature/ship/%s/%s.ExportJson", res_id, res_id)
    armature_manager:addArmatureFileInfo(self.res_armature)

    local function gafEndCallBack()
        self.effect_layer.gaf = nil
        self.effect_layer.zhuan = CompositeEffect.new("tx_0148zhuan", 442, 268, self.effect_layer, -1, nil, nil, nil)
        self.effect_layer.zhuan:setVisible(not self.is_create)
        self.effect_layer.zhuan:setZOrder(1)
        self.effect_layer.zhuan:setScale(0.6)
        local arr = CCArray:create()
        local move_action = CCMoveBy:create(0.5, ccp(-195, 0))
        arr:addObject(move_action)
        arr:addObject(CCCallFuncN:create(function() 
            self.effect_end = true
            self.effect_layer.zhuan = nil
        end))
        self.effect_layer:runAction(CCSequence:create(arr))
    end
    self.effect_layer.gaf = CompositeEffect.new("tx_0148", 442, 268, self.effect_layer, 0.5, gafEndCallBack, nil, nil)
    self.effect_layer.gaf:setVisible(not self.is_create)
    self.effect_layer.gaf:setZOrder(1)
    self.effect_layer.gaf:setScale(0.6)
    local ship_sprite = CCArmature:create(res_id)
    ship_sprite:getAnimation():playByIndex(0)
    ship_sprite:setScale(0)
    ship_sprite:setPosition(display.cx, display.cy - boat.boatPos[2])
    self.effect_layer:addChild(ship_sprite, 2)

    local ship_arr = CCArray:create()
    ship_arr:addObject(CCScaleTo:create(0.5, 0.6))
    ship_sprite:runAction(CCSequence:create(ship_arr))
    audioExt.playEffect(music_info.BOAT_REMAKE.res)

    self.bg:runAction(CCFadeIn:create(3))
end

function ClsDockCreateShipEffectLayer:updateView()
    local base_property_info = {
        [1] = {name = "ship_name"},
        [2] = {name = "level_info"},
        [3] = {name = "power_num"},
        [4] = {name = "range_num"},
        [5] = {name = "speed_num"},
        [6] = {name = "hurt_num"},
        [7] = {name = "near_num"},
        [8] = {name = "long_num"},
        [9] = {name = "defense_num"},
    }

    self.view_tab = {}
    for k, v in ipairs(base_property_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name].name = v.name
        self.view_tab[#self.view_tab + 1] = self[v.name]
    end

    local boat = self.boat_info

    local ship_property = {}

    if type(boat.base_attrs) ~= "table" then return end
    for k, v in ipairs(boat.base_attrs) do
        ship_property[v.attr] = v
    end

    boat.base_attrs = ship_property

    local quality_by_kind = {
        [2] = ui_word.SHIPYARD_SHIP_QUALITY_HIGHT,
        [3] = ui_word.SHIPYARD_SHIP_QUALITY_XIYOU,
        [4] = ui_word.SHIPYARD_SHIP_QUALITY_HISTORY,
    }

    local base_property_value = {
        [1] = boat.name,
        [2] = quality_by_kind[boat.quality],
        [3] = boat.power,
        [4] = boat.base_attrs.range.value,
        [5] = boat.base_attrs.speed.value,
        [6] = boat.base_attrs.remote.value,
        [7] = boat.base_attrs.melee.value,
        [8] = boat.base_attrs.durable.value,
        [9] = boat.base_attrs.defense.value,
    }

    for k = 1, MAX_BASE_PROPERY_NUM, 1 do
        self.view_tab[k]:setText(base_property_value[k])
    end

    setUILabelColor(self.ship_name, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[boat.quality])))
    setUILabelColor(self.level_info, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[boat.quality])))

    local random_property_info = {
        [1] = {name = "dodge_text", value = "dodge_num"},
        [2] = {name = "gun_text", value = "gun_num"},
        [3] = {name = "blood_text", value = "blood_num"},
        [4] = {name = "blood_text_1", value = "blood_num_1"},
        [5] = {name = "skill_name", value = "skill_desc", kind = "ran_skill"}
    }

    self.random_view = {}
    for k, v in ipairs(random_property_info) do
        local temp = {}
        temp.text = getConvertChildByName(self.panel, v.name)
        temp.value = getConvertChildByName(self.panel, v.value)
        temp.kind = ran_skill
        function temp:setVisible(enable)
            self.text:setVisible(enable)
            self.value:setVisible(enable)
        end
        temp:setVisible(false)
        self.random_view[#self.random_view + 1] = temp
    end

    local normal_attr = {}
    local skill_attr = {}
    for k, v in ipairs(boat.rand_attrs) do
        if v.attr == "boatSkill" then
            table.insert(skill_attr, v)
        else
            table.insert(normal_attr, v)
        end
    end

    local cur_line = 0
    for k, v in ipairs(normal_attr) do
        local item = self.random_view[k]
        cur_line = math.ceil(k / 2)

        item:setVisible(true)
        item.text:setText(base_attr_info[v.attr].name)
        item.value:setText(v.value)
        setUILabelColor(item.text, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
        setUILabelColor(item.value, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
    end

    for k, v in ipairs(skill_attr) do
        cur_line = cur_line + 1
        local item = self.random_view[2 * cur_line - 1]
        item:setVisible(true)
        local skill_attr = skill_info[v.value]
        local sailor_data = getGameData():getSailorData()
        local desc_tab = sailor_data:getSkillDescWithLv(v.value, 1)
        local name = skill_attr.name
        local value = desc_tab.base_desc
        item.text:setText(name)
        item.value:setText(value)
        setUILabelColor(item.text, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
        setUILabelColor(item.value, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
    end
end

function ClsDockCreateShipEffectLayer:openScheduler()
    self.count = 0
    local function update()
        self.count = self.count + 1
        if self.count >= 5 then
            self:closeView()
            self:closeScheduler()
        end
    end

    self:closeScheduler()
    self.update_scheduler = scheduler:scheduleScriptFunc(update, 1, false)
end

function ClsDockCreateShipEffectLayer:closeScheduler()
    if self.update_scheduler then
        scheduler:unscheduleScriptEntry(self.update_scheduler)
        self.update_scheduler = nil
    end
end

function ClsDockCreateShipEffectLayer:closeView()  
    if type(self.call_back) == "function" then
        self.call_back()
    end
    getUIManager():close("ClsDockCreateShipEffectLayer")
end

function ClsDockCreateShipEffectLayer:onTouchEnded(x, y)
    if self.drag.is_tap and self.effect_end then
        self:closeView()
    end
end

function ClsDockCreateShipEffectLayer:onExit()
    local dock_ui = getUIManager():get("ClsDockUI")
    if tolua.isnull(dock_ui) then
        UnLoadPlist(self.res_plist)
    end
    UnLoadArmature(self.armature_tab)
    ReleaseTexture()
    self:closeScheduler()
end

return ClsDockCreateShipEffectLayer
