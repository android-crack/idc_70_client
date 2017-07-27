--造船厂
local music_info = require("game_config/music_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local voice_info = getLangVoiceInfo()
local on_off_info = require("game_config/on_off_info")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsShipyardMainUI = class("ClsShipyardMainUI", ClsBaseView)

local main_tab_info = {
    [1] = { name = "btn_build", text = "btn_build_text", index = TAB_BUILD, task_keys = {
                on_off_info.SHIPYARD_CREATE.value,
            }, on_off_key = on_off_info.SHIPYARD_CREATE.value},
    [2] = { name = "btn_strengthen", text = "btn_strengthen_text", index = TAB_STRENGTHEN, task_keys = {
                on_off_info.ASSEMBLE_BOX1.value,
                on_off_info.ASSEMBLE_BOX2.value,
                on_off_info.ASSEMBLE_BOX3.value,
                on_off_info.ASSEMBLE_BOX4.value,
                on_off_info.ASSEMBLE_BOX5.value,
                on_off_key = on_off_info.SHIPYARD_QHPAGE.value
            }, on_off_key = on_off_info.SHIPYARD_QHPAGE.value},
    [3] = { name = "btn_xilian", text = "btn_xilian_text", index = TAB_REFINE},
    [4] = { name = "btn_equip", text = "btn_equip_text", index = TAB_EQUIP, task_keys = {
                on_off_info.SHIPYARD_EQUIP_BOX1.value,
                on_off_info.SHIPYARD_EQUIP_BOX2.value,
                on_off_info.SHIPYARD_EQUIP_BOX3.value,
                on_off_info.SHIPYARD_EQUIP_BOX4.value,
                on_off_info.SHIPYARD_EQUIP_BOX5.value,
            }, on_off_key = on_off_info.SHIPYARD_ZBPAGE.value},
    [5] = { name = "btn_shop", text = "btn_shop_text", index = TAB_SHOP, task_keys = {
                on_off_info.DARK_MARKET.value,
            }, on_off_key = on_off_info.DARK_MARKET.value},
}


--页面参数配置方法，注意，是静态方法
function ClsShipyardMainUI:getViewConfig()
    return {
        name = "ClsShipyardMainUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        hide_before_view = true,
        effect = UI_EFFECT.FADE,
    }
end

function ClsShipyardMainUI:onEnter(skip_tag, skip_param)
    self.skip_tag = skip_tag or TAB_BUILD
    self.is_finish_effect = false
    self.skip_param = skip_param
    self.plist_tab = {
        ["ui/shipyard_ui.plist"] = 1,
        ["ui/skill_icon.plist"] = 1,
        ["ui/item_box.plist"] = 1,
        ["ui/partner.plist"]  = 1,
    }
    LoadPlist(self.plist_tab)

    local partner_data = getGameData():getPartnerData()
    partner_data:askBagEquipInfo()

    self.main_tabs = {}
    self:configUI()
    self:enterAssignTab(self.skip_tag)
end

function ClsShipyardMainUI:onFadeFinish()
    self.is_finish_effect = true
    if not tolua.isnull(self.cur_panel) then
        self.cur_panel:setViewVisible(true)
    end
end

function ClsShipyardMainUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_tab.json")
    self:addWidget(self.panel)
    local task_data = getGameData():getTaskData()
    for k, v in ipairs(main_tab_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name].name = v.name
        self[v.name].index = v.index
        self[v.name].text = getConvertChildByName(self.panel, v.text)

        self[v.name]:addEventListener(function() 
            setUILabelColor(self[v.name].text, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))    
        end, TOUCH_EVENT_BEGAN)

        self[v.name]:addEventListener(function() 
            setUILabelColor(self[v.name].text, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))  
        end, TOUCH_EVENT_CANCELED)

        self[v.name]:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:executeSelectTabLogic(v.index)
        end, TOUCH_EVENT_ENDED)
        table.insert(self.main_tabs, self[v.name])

        if v.task_keys and v.on_off_key then
            self[v.name].task_keys = v.task_keys
            task_data:regTask(self[v.name], v.task_keys, KIND_RECTANGLE, v.on_off_key, 74, 33, true)
        end
    end
    self.tab_panel_layer = getConvertChildByName(self.panel, "tab_panel_layer")
    self.tab_panel_layer:setVisible(false)
    self.coin_panel = getConvertChildByName(self.panel, "coin_panel")
    local ClsPlayerInfoItem = require("ui/tools/clsPlayerInfoItem")
    local cash_layer = ClsPlayerInfoItem.new(ITEM_INDEX_CASH)
    self.coin_panel:addCCNode(cash_layer)

    ClsGuideMgr:tryGuide("ClsShipyardMainUI")
    audioExt.playEffect(voice_info.VOICE_SWITCH_1000.res)

    local onOffData = getGameData():getOnOffData()
    onOffData:pushOpenBtn(on_off_info.SHIPYARD_ZBPAGE.value, {openBtn = self.btn_equip, openEnable = true, addLock = true, btnRes = "#common_btn_tab7.png", parent = "ClsShipyardMainUI"})
    onOffData:pushOpenBtn(on_off_info.BOAT_WASH.value, {openBtn = self.btn_xilian, openEnable = true, addLock = true, btnRes = "#common_btn_tab7.png", parent = "ClsShipyardMainUI"})
end

--建造
function ClsShipyardMainUI:clickDockTabEvent()
    if not getUIManager():isLive("ClsDockUI") then
        self.cur_panel = getUIManager():create("gameobj/shipyard/clsDockUI")
    end
    self.cur_panel:updateMaterialView()
end

--船只强化
function ClsShipyardMainUI:clickStrengthenTabEvent(skip_param)
    if not getUIManager():isLive("ClsFleetStrengthenUI") then
        self.cur_panel = getUIManager():create("gameobj/backpack/clsFleetStrengthenUI", nil, skip_param)
    end
end

--洗练
function ClsShipyardMainUI:clickRefineTabEvent(skip_param)
    if not getUIManager():isLive("ClsFleetRefineUI") then
        self.cur_panel = getUIManager():create("gameobj/backpack/clsFleetRefineUI", nil, skip_param)
    end
end

--船舶装备
function ClsShipyardMainUI:clickEquipTabEvent(skip_param)
    if not getUIManager():isLive('ClsFleetEquipUI') then
        self.cur_panel = getUIManager():create("gameobj/backpack/clsFleetEquipUI", nil, skip_param)
    end
end

--商店
function ClsShipyardMainUI:clickStoreTabEvent()
    if not getUIManager():isLive("ClsStoreList") then
        self.cur_panel = getUIManager():create("gameobj/shipyard/clsStoreList")
    end
end

--每个界面初始的操作可能存在不同，所以不建议统一
local tab_events = {
    [TAB_BUILD] = {fun = ClsShipyardMainUI.clickDockTabEvent, wait = true},
    [TAB_STRENGTHEN] = {fun = ClsShipyardMainUI.clickStrengthenTabEvent, wait = true},
    [TAB_REFINE] = {fun = ClsShipyardMainUI.clickRefineTabEvent, wait = true},
    [TAB_EQUIP] = {fun = ClsShipyardMainUI.clickEquipTabEvent, wait = true},
    [TAB_SHOP] = {fun = ClsShipyardMainUI.clickStoreTabEvent},
}

function ClsShipyardMainUI:executeSelectTabLogic(index, skip_param)
    self.select_index = index
    for k, v in ipairs(self.main_tabs) do
        v:setFocused(index == v.index)
        v:setTouchEnabled(index ~= v.index)
        if not tolua.isnull(self.cur_panel) then
            self.cur_panel:close()
        end
        local color = COLOR_BTN_SELECTED
        if index ~= v.index then
            color = COLOR_BTN_UNSELECTED
        end
        v.text:setUILabelColor(color)
    end
    self:showTabEvent()
    -- require("framework.scheduler").performWithDelayGlobal(function()
    --     ClsGuideMgr:tryGuide("ClsShipyardMainUI")
    -- end, 0.3)
end

function ClsShipyardMainUI:enterAssignTab(index)
    self:executeSelectTabLogic(index)
end

function ClsShipyardMainUI:showTabEvent()
    if tab_events[self.select_index].wait and not self.get_backpack_data then
        return
    end
    self.tab_panel_layer:setVisible(true)
    tab_events[self.select_index].fun(self, self.skip_param)
    self.skip_param = nil

    if not self.is_finish_effect and not tolua.isnull(self.cur_panel) then
        self.cur_panel:setViewVisible(false)
    end
end

--用于确定已经有背包数据了，否则界面点了不显示界面
function ClsShipyardMainUI:updateBackpackData()
    self.get_backpack_data = true
    self.tab_panel_layer:setVisible(true)
    if tab_events[self.select_index].wait then
        tab_events[self.select_index].fun(self, self.skip_param)
        self.skip_param = nil

        if not self.is_finish_effect and not tolua.isnull(self.cur_panel) then
            self.cur_panel:setViewVisible(false)
        end
    end
end

function ClsShipyardMainUI:updateLabelCallBack()
    if not tolua.isnull(self.cur_panel) then
        if type(self.cur_panel.updateLabelCallBack) == "function" then
            self.cur_panel:updateLabelCallBack()
        end
    end
end

function ClsShipyardMainUI:closeView()
    self:effectClose()
end

function ClsShipyardMainUI:onFinish()
    getUIManager():close("ClsDockUI")
    getUIManager():close("ClsFleetStrengthenUI")
    getUIManager():close("ClsFleetRefineUI")
    getUIManager():close("ClsFleetEquipUI")
    getUIManager():close("ClsStoreList")
end

function ClsShipyardMainUI:onExit()  -- 退出处理
    UnLoadPlist(self.plist_tab)
    ReleaseTexture(self)
end

return ClsShipyardMainUI
