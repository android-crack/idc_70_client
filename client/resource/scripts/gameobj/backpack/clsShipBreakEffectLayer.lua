local music_info = require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local ui_word = require("game_config/ui_word")
local CompositeEffect = require("gameobj/composite_effect")
local scheduler = CCDirector:sharedDirector():getScheduler()
local boat_strengthening = require("game_config/boat/boat_strengthening")
local boat_breakthrough_xianshi = require("game_config/boat/boat_breakthrough_xianshi")
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local ClsBaseView = require("ui/view/clsBaseView")
local ClsShipBreakEffectLayer = class("ClsShipBreakEffectLayer", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsShipBreakEffectLayer:getViewConfig()
    return {
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsShipBreakEffectLayer:onEnter(parameter)
    self.boat_info = parameter.boat_info
    self.call_back = parameter.call_back

    self.res_plist = {
        ["ui/shipyard_ui.plist"] = 1,
    }
    LoadPlist(self.res_plist)

    self.armature_tab = {
        "effects/tx_0148zhuan.ExportJson",
        "effects/tx_chuanbo_tupo.ExportJson",
    }

    LoadArmature(self.armature_tab)
    self:configUI()
end

function ClsShipBreakEffectLayer:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_break.json")
    self:addWidget(self.panel)

    self.info_bg = getConvertChildByName(self.panel, "info_bg")
    self:updateView()
    self:showEffect()
    self:openScheduler()

    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            return true
        elseif event_type == "ended" then
            self:closeView()
        end
    end) 
end

function ClsShipBreakEffectLayer:showEffect()
    local effect_layer = display.newLayer()
    self:addChild(effect_layer)
    local boat = boat_info[self.boat_info.id]
    local res_id = boat.armature
    self.res_armature = string.format("armature/ship/%s/%s.ExportJson", res_id, res_id)
    armature_manager:addArmatureFileInfo(self.res_armature)
    
    effect_layer.txt_gaf = CompositeEffect.new("tx_chuanbo_tupo", 590, 420, effect_layer, -1)
    effect_layer.txt_gaf2 = CompositeEffect.new("tx_txt_break_success", 590, 545, effect_layer, -1)

    self.info_bg:runAction(CCFadeIn:create(3))
    effect_layer:performWithDelay(function()
        effect_layer.gaf = CompositeEffect.new("tx_0148zhuan", 342, 268, effect_layer, -1)
        effect_layer.gaf:setZOrder(1)
        effect_layer.gaf:setScale(0.6)
        local ship_sprite = CCArmature:create(res_id)
        ship_sprite:getAnimation():playByIndex(0)
        ship_sprite:setScale(0)
        ship_sprite:setPosition(350, display.cy - boat.boatPos[2])
        effect_layer:addChild(ship_sprite, 2)

        local ship_arr = CCArray:create()
        ship_arr:addObject(CCScaleTo:create(0.5, 0.6))
        ship_sprite:runAction(CCSequence:create(ship_arr))
        audioExt.playEffect(music_info.BOAT_REMAKE.res)
    end, 0.4)
end

local need_attr = {
    [ATTR_KEY_REMOTE] = "far_strengthening_num",
    [ATTR_KEY_MELEE] = "near_strengthening_num",
    [ATTR_KEY_DEFENSE] = "defense_strengthening_num",
    [ATTR_KEY_DURABLE] = "hpmax_strengthening_num",
}

function ClsShipBreakEffectLayer:updateView()
    local attr_info = {
        [1] = {base = "remote_damage_num", up = "remote_damage_plus", kind = ATTR_KEY_REMOTE},
        [2] = {base = "melee_damage_num", up = "melee_damage_plus", kind = ATTR_KEY_MELEE},
        [3] = {base = "durable_num", up = "durable_plus", kind = ATTR_KEY_DURABLE},
        [4] = {base = "defense_num", up = "defense_plus", kind = ATTR_KEY_DEFENSE},
    }

    local attr_values = {}
    for k, v in ipairs(self.boat_info.base_attrs) do
        if need_attr[v.attr] then
            attr_values[v.attr] = v
        end
    end

    local strengthening_info = boat_strengthening[self.boat_info.boat_level]
    for k, v in ipairs(attr_info) do
        local temp = {}
        local base = getConvertChildByName(self.panel, v.base)
        local up = getConvertChildByName(self.panel, v.up)
        base:setText(attr_values[v.kind].value)
        up:setText(string.format("+%s", strengthening_info[need_attr[v.kind]]))
        temp.up = up
        temp.base = base
        temp.kind = v.kind
    end

    self.attr_icon = getConvertChildByName(self.panel, "ship_skill_icon")
    self.attr_name = getConvertChildByName(self.panel, "attr_name")
    self.attr_info = getConvertChildByName(self.panel, "attr_info")

    local index = self.boat_info.boat_level / 10
    local info = boat_breakthrough_xianshi[index]
    self.attr_icon:changeTexture(convertResources(info.boat_breakthrough_icon), UI_TEX_TYPE_PLIST)
    self.attr_name:setText(info.boat_breakthrough_txt)
    self.attr_info:setText(string.format(ui_word.SHIPYARD_BREAK_DEC, info.boat_breakthrough_txt, info.boat_breakthrough_value))
end

function ClsShipBreakEffectLayer:openScheduler()
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

function ClsShipBreakEffectLayer:closeScheduler()
    if self.update_scheduler then
        scheduler:unscheduleScriptEntry(self.update_scheduler)
        self.update_scheduler = nil
    end
end

function ClsShipBreakEffectLayer:closeView()  
    if type(self.call_back) == "function" then
        self.call_back()
    end
    getUIManager():close("ClsShipBreakEffectLayer")
    getUIManager():close("AlertShowZhanDouLiEffect")
end

function ClsShipBreakEffectLayer:onExit()
    if tolua.isnull(self) then return end
    UnLoadArmature(self.armature_tab)
    ReleaseTexture()
    self:closeScheduler()
end

return ClsShipBreakEffectLayer
