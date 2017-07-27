--建造界面
local music_info = require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local boat_build = require("game_config/boat/boat_build")
local Alert = require("ui/tools/alert")
local nobility_data = require("game_config/nobility_data")
local ui_word = require("game_config/ui_word")
local equip_material_info = require("game_config/boat/equip_material_info")
local sailor_info = require("game_config/sailor/sailor_info")
local item_info = require("game_config/propItem/item_info")
local common_funs = require("gameobj/commonFuns")
local CompositeEffect = require("gameobj/composite_effect")
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()
local scheduler = CCDirector:sharedDirector():getScheduler()
local on_off_info = require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")

local Game3d = require("game3d")
local Main3d = require("gameobj/mainInit3d")

local MIN_NUM = 1 --最少使用图纸数量
local CONSUME_KIND_PAPER = 1
local CONSUME_KIND_GOLD = 2
local JOB_MAX_NUM = 2
local PARTNER_MAX_NUM = 4

local occup_txt = {
    [1] = ui_word.ROLE_OCCUP_1,
    [2] = ui_word.ROLE_OCCUP_2,
    [3] = ui_word.ROLE_OCCUP_3
}

local ClsBtnShipCell = class("ClsBtnShipCell", ClsScrollViewItem)

function ClsBtnShipCell:updateUI(cell_date, panel)
    local data = cell_date
    local cell_widget_info = {
        [1] = {name = "btn_ship_name"},
        [2] = {name = "btn_ship"},
        [3] = {name = "select_frame"}
    }
 
    local panel_size = panel:getContentSize()
    panel:setPosition(ccp((self.m_width - panel_size.width) / 2, (self.m_height - panel_size.height) / 2))

    for k, v in ipairs(cell_widget_info) do
        local item = getConvertChildByName(panel, v.name)
        panel[v.name] = item
    end
    panel.select_frame:setVisible(false)
    local job_icon = data.fi_type < 4 and data.fi_type  or 3
    panel.btn_ship:changeTexture(string.format("shipyard_type_bg%s.png",job_icon), UI_TEX_TYPE_PLIST)

    local name = data.name
    local len = common_funs:utfstrlen(name)
    if len > 4 then
        name = string.format("%s%s", common_funs:utf8sub(name, 1, 4), ui_word.SIGN_THREE_POINT)
    end
    
    panel.btn_ship_name:setText(name)
    self.panel = panel
end

function ClsBtnShipCell:onTap(x, y)--被点击
    local dock_ui = getUIManager():get('ClsDockUI')
    local current_list = dock_ui:getCurrentListView()
    local select_cell = current_list.select_cell
    local panel = nil
    if not tolua.isnull(select_cell) then
        panel = select_cell.panel
        panel.select_frame:setVisible(false)
    end
    audioExt.playEffect(music_info.COMMON_BUTTON.res)
    current_list.select_cell = self
    panel = self.panel
    panel.btn_ship:changeTexture(panel.btn_ship.select_img, UI_TEX_TYPE_PLIST)
    panel.select_frame:setVisible(true)
    dock_ui:setCurrentShip(self.m_cell_date)
    dock_ui:updateDataAndViewBySelectShip()
end

local ClsBaseView = require("ui/view/clsBaseView")
local ClsDockUI = class("ClsDockUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsDockUI:getViewConfig()
    return {
        name = "ClsDockUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsDockUI:onEnter()
    self.m_plist_tab = {
        ["ui/material_icon.plist"] = 1,
    }
    LoadPlist(self.m_plist_tab)
    
    self:configUI()
    self:configEvent()
    self:init3D()

    self.select_paper_status = nil--没有做出选择

    local mission_data = getGameData():getMissionData()
    local goal_id = mission_data:getMissionSpecialBoatId()
    local nobilityData = getGameData():getNobilityData()
    local goal_nobility_id = nobilityData:getNobilityID()
    if goal_id then
        for k, v in pairs(boat_attr) do
            if k == goal_id then
                goal_nobility_id = v.nobility_id
            end
        end
    end

    local cur_nobility_info = nobilityData:getCurrentNobilityData()
    self.ship_level_text:setText(cur_nobility_info.title)
    self.ship_level_text:setUILabelColor(cur_nobility_info.level_color)
    self.level_icon:changeTexture(cur_nobility_info.icon, UI_TEX_TYPE_PLIST)
    self:updateDataAndViewBySelectNobility(goal_nobility_id, goal_id)
    local ship_data = getGameData():getShipData()
    ship_data:askBuildBoatDiscount()
end

function ClsDockUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_build.json")
    self:addWidget(self.panel)

    self.base_btns = {}
    local btn_info = {
        [1] = {name = "btn_close"},
        [2] = {name = "btn_build"},
    }

    for k, v in ipairs(btn_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name].name = v.name
        if type(self[v.name].setPressedActionEnabled) == "function" then
            self[v.name]:setPressedActionEnabled(true)
        end
        self.base_btns[#self.base_btns + 1] = self[v.name]
    end

    local other_widget_info = {
        [1] = {name = "ship_layer"},
        [2] = {name = "ship_name"},
        [3] = {name = "consume_drawing_num"},
        [4] = {name = "btn_exclamation"},
        [5] = {name = "btn_check"},
        [6] = {name = "has_paper_panel"},
        [7] = {name = "no_paper_panel"},
        [8] = {name = "level_icon"},
        [9] = {name = "ship_level_text"},
        [10] = {name = "drawing_name"},
        [11] = {name = "drawing_need"},
        [12] = {name = "ship_look_btn"},
        [13] = {name = "item_bg"},
        [14] = {name = "ship_panel"},
    }

    for k, v in ipairs(other_widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end

    local consume_info = {
        [1] = {icon = "drawing_icon", num = "drawing_has", kind = CONSUME_KIND_PAPER},
        [2] = {icon = "coin_icon", num = "consume_coin_num", discount = "consume_discount", kind = CONSUME_KIND_GOLD},
    }

    self.can_build_panel = {}
    local consumes = {}
    for k, v in ipairs(consume_info) do
        local temp = {}
        temp.icon = getConvertChildByName(self.panel, v.icon)
        temp.num = getConvertChildByName(self.panel, v.num)
        if v.discount then
            temp.discount = getConvertChildByName(self.panel, v.discount)
            temp.discount:setVisible(false)
        end

        function temp:setVisible(enable)
            self.icon:setVisible(enable)
            self.num:setVisible(enable)
        end 
        consumes[v.kind] = temp
    end
    self.can_build_panel.consume = consumes

    function self.can_build_panel:setVisible(enable)
        for k, v in pairs(self.consume) do
            v:setVisible(enable)
        end
    end

    self.ship_layer:setVisible(true)


    self.job_tab = {}
    for k = 1, JOB_MAX_NUM do
        local name = string.format("boat_job_info_%s", k)
        local job = getConvertChildByName(self.panel, name)
        table.insert(self.job_tab, job)
    end

    self.partner_tab = {}
    for k = 1, PARTNER_MAX_NUM do
        local item_name = string.format("seamen_bg_%d", k)
        local item = getConvertChildByName(self.panel, item_name)

        local head_name = string.format("seamen_head_%d", k)
        item.img = getConvertChildByName(item, head_name)

        item:setVisible(false)
        table.insert(self.partner_tab, item)
    end

    ClsGuideMgr:tryGuide("ClsDockUI")
end

function ClsDockUI:init3D()
    local layer_id = 1
    local scene_id = SCENE_ID.PREVIEW
    Main3d:createScene(scene_id) 
    local parent = CCNode:create()
    self.ship_panel:addCCNode(parent)
    
    Game3d:createLayer(scene_id,layer_id, parent)
    self.layer3d = Game3d:getLayer3d(scene_id,layer_id)
end

function ClsDockUI:getPaperInfo()
    local build_info = boat_build[self.current_ship.boat_id]
    local item_id = 0
    local need_num = 0
    for k,v in pairs(build_info.build_drawings) do
        item_id = k
        need_num = v
    end
    local propDataHandle = getGameData():getPropDataHandler()
    local get_item = propDataHandle:get_propItem_by_id(item_id) or {count = 0}
    local item = item_info[item_id]
    local res = item.res
    local name = item.name
    return get_item.count, convertResources(res), name,item.quality,need_num
end

local pos_by_boat_id = {
    [1] = ccp(340, 235),
    [9] = ccp(340, 200),
    [22] = ccp(340, 260),
    [109] = ccp(340, 200),
}

function ClsDockUI:updateDataAndViewBySelectShip()

    local partner_data = getGameData():getPartnerData()
    local sailors = partner_data:getBagEquipIds()

    --更新显示的船信息
    if not tolua.isnull(self.ship_model) then 
        self.ship_model:removeFromParentAndCleanup(true)
        self.ship_model = nil
    end

    local boat_id = self.current_ship.boat_id
    local boat = boat_info[boat_id]
    self.ship_name:setText(boat.name)
    self:showShip3D(boat_id)

    local cur_job = {}
    for k, v in ipairs(self.job_tab) do
        local job = self.current_ship.occup[k]
        v:setVisible(job ~= nil)
        if job then
            v:setText(occup_txt[job])
            cur_job[job] = true
        end
    end

    --找适合船的小伙伴
    local res = {}
    for i = 1, #sailors do
        if(sailors[i] > 0)then
            local info = sailor_info[sailors[i]] or {job = {}}
            for k = 1, #info.job do
                if(cur_job[info.job[k]])then
                    table.insert(res, info.res)
                    break
                end
            end
        end
    end

    for k, v in ipairs(self.partner_tab) do
        v:setVisible(res[k] ~= nil)
        if(res[k] ~= nil)then
            v.img:changeTexture(res[k], UI_TEX_TYPE_LOCAL)
        end
    end

    --更新消耗的金币
    local build_info = boat_build[self.current_ship.boat_id]
    self.base_cash = build_info.build_cash
    self.need_cash = self.base_cash
    local ship_data = getGameData():getShipData()
    local is_have_discount = ship_data:isHaveDiscount()
    if is_have_discount then
        local discount = ship_data:getBuildDiscount()
        self:updateComsumeGold(discount)
    else
        self.can_build_panel.consume[CONSUME_KIND_GOLD].discount:setVisible(false)
        self.can_build_panel.consume[CONSUME_KIND_GOLD].num:setText(self.base_cash)
        self:updateCashCallBack()
    end

    local nobilityData = getGameData():getNobilityData()
    local goal_nobility_id = nobilityData:getNobilityID()

    local current_nobility_level = nobility_data[goal_nobility_id].level
    local ship_nobility_level = nobility_data[self.current_ship.nobility_id].level
    if current_nobility_level < ship_nobility_level then
        self.btn_build:disable()
        self.can_build_panel:setVisible(false)
    else
        self.btn_build:active()
        self.can_build_panel:setVisible(true)
    end

    self:updateItemView()
    --更新材料信息
    self:updateMaterialView()
end

function ClsDockUI:updateComsumeGold(discount)
    if discount > 0 then
        self.need_cash = (100 - discount) / 100  * self.base_cash
        self.can_build_panel.consume[CONSUME_KIND_GOLD].discount:setVisible(true)
        self.can_build_panel.consume[CONSUME_KIND_GOLD].discount:setText(string.format(ui_word.BUILD_BOAT_DISCOUNT, discount))
    else
        self.need_cash = self.base_cash
        self.can_build_panel.consume[CONSUME_KIND_GOLD].discount:setVisible(false)
    end

    self.can_build_panel.consume[CONSUME_KIND_GOLD].num:setText(self.need_cash)
    self:updateCashCallBack()
end

function ClsDockUI:updateItemView()
    local current_paper_num, res, name, bg_color, need_num = self:getPaperInfo()
    local color = current_paper_num < need_num and  COLOR_RED or COLOR_COFFEE
    self.can_build_panel.consume[CONSUME_KIND_PAPER].num:setUILabelColor(color)
    self.can_build_panel.consume[CONSUME_KIND_PAPER].num:setText(current_paper_num)

    if self.select_paper_status == nil then
        if current_paper_num >= need_num then
            self.btn_check:setSelectedState(true)
            self:selectPaper(true)
        else
            self:selectPaper(false)
        end
    end

    --更新图纸
    self.can_build_panel.consume[CONSUME_KIND_PAPER].icon:changeTexture(res, UI_TEX_TYPE_PLIST)
    self.drawing_name:setText(name)
    self.drawing_need:setText("/"..need_num)
    self.item_bg:changeTexture(string.format("item_box_%s.png", bg_color), UI_TEX_TYPE_PLIST)
end

function ClsDockUI:updateCashCallBack()
    local player_data = getGameData():getPlayerData()
    local current_have_coin = player_data:getCash()
    local color = self.need_cash > current_have_coin and COLOR_RED_STROKE or COLOR_COFFEE
    self.can_build_panel.consume[CONSUME_KIND_GOLD].num:setUILabelColor(color)
end

function ClsDockUI:updateCreateRate()
end

--更新材料界面
function ClsDockUI:updateMaterialView()
    self:updateCreateRate()
end

function ClsDockUI:updateDataAndViewBySelectNobility(nobility_id, goal_id)
    self.nobility_id = nobility_id
    local base_data = nobility_data[nobility_id]
    if(not base_data)then return end

    local boat_infos = {}

    for k, v in ipairs(base_data.boat_ids) do
        local boat_info = boat_attr[v]
        boat_info.boat_id = v
        table.insert(boat_infos, boat_info)
    end

    table.sort(boat_infos, function(a, b)
        return a.fi_type < b.fi_type
    end)

    if not tolua.isnull(self.btn_ship_list) then
        self.btn_ship_list:removeFromParentAndCleanup(true)
        self.btn_ship_list = nil   
    end

    self.btn_ship_list = ClsScrollView.new(600, 60, false, function()
        local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_build_btn_list.json")
        return cell_ui
    end)
    self.btn_ship_list:setPosition(ccp(320, 414))
    self:addWidget(self.btn_ship_list)
    self.ship_list_cells = {}
    for k, v in ipairs(boat_infos) do
        local cell = ClsBtnShipCell.new(CCSize(200, 60), v)
        self.ship_list_cells[#self.ship_list_cells + 1] = cell
        if goal_id then
            if v.boat_id == goal_id then
                goal_cell = cell
                goal_index = k
            end
        elseif k == 1 then
            goal_cell = cell
        end
    end
    self.btn_ship_list:addCells(self.ship_list_cells)
    goal_cell:onTap()
end

function ClsDockUI:configEvent()
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        local shipyard_main_ui = getUIManager():get("ClsShipyardMainUI")
        if not tolua.isnull(shipyard_main_ui) then 
            shipyard_main_ui:closeView()
        end
    end, TOUCH_EVENT_ENDED)

    self.btn_build.last_time = 0
    self.btn_build:addEventListener(function()
        -- local boat_info = {
        --     ["base_attrs"] = {
        --         [1] = {
        --             ["attr"] = "defense",
        --             ["quality"] = 2.000000,
        --             ["value"] = 19.000000,
        --             },
        --         [2] = {
        --             ["attr"] = "range",
        --             ["quality"] = 2.000000,
        --             ["value"] = 400.000000,
        --             },
        --         [3] = {
        --             ["attr"] = "remote",
        --             ["quality"] = 2.000000,
        --             ["value"] = 19.000000,
        --             },
        --         [4] = {
        --             ["attr"] = "melee",
        --             ["quality"] = 2.000000,
        --             ["value"] = 19.000000,
        --             },
        --         [5] = {
        --             ["attr"] = "durable",
        --             ["quality"] = 2.000000,
        --             ["value"] = 197.000000,
        --             },
        --         [6] = {
        --             ["attr"] = "load",
        --             ["quality"] = 2.000000,
        --             ["value"] = 20.000000,
        --             },
        --         [7] = {
        --             ["attr"] = "speed",
        --             ["quality"] = 2.000000,
        --             ["value"] = 85.000000,
        --             },
        --         },
        --     ["guid"] = 4.000000,
        --     ["id"] = 3.000000,
        --     ["is_changed"] = 0.000000,
        --     ["name"] = "三桅卡拉维尔",
        --     ["power"] = 46.000000,
        --     ["quality"] = 2.000000,
        --     ["rand_amount"] = 2.000000,
        --     ["rand_attrs"] = {
        --         [1] = {
        --             ["attr"] = "boatSkill",
        --             ["quality"] = 5.000000,
        --             ["value"] = 2004.000000,
        --             },
        --         [2] = {
        --             ["attr"] = "antiCrits",
        --             ["quality"] = 1.000000,
        --             ["value"] = 2004.000000,
        --             },
        --         [3] = {
        --             ["attr"] = "range",
        --             ["quality"] = 1.000000,
        --             ["value"] = 2004.000000,
        --             },
        --         },
        -- }
        -- self:showShipEffect(boat_info)
        if CCTime:getmillistimeofCocos2d() - self.btn_build.last_time < 500 then return end
        self.btn_build.last_time = CCTime:getmillistimeofCocos2d()
        
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local use_paper = 0
        if(self.btn_check:getSelectedState())then 
            use_paper = 1 
            local current_have_paper, a, b,c,need_num = self:getPaperInfo()
            if(current_have_paper < need_num)then
                local shipyard_main_ui = getUIManager():get("ClsShipyardMainUI")
                Alert:showJumpWindow(PAPER_NOT_ENOUGH, shipyard_main_ui)
                return
            end
        end

        local player_data = getGameData():getPlayerData()
        local current_have_cash = player_data:getCash()
        if(current_have_cash < self.need_cash)then
            local shipyard_main_ui = getUIManager():get("ClsShipyardMainUI")
            Alert:showJumpWindow(CASH_NOT_ENOUGH, shipyard_main_ui, {need_cash = self.need_cash, come_type = Alert:getOpenShopType().VIEW_3D_TYPE, come_name = "shipyard_create"})
            return
        end

        local ship_data = getGameData():getShipData()
        local boat_id = self.current_ship.boat_id
        ship_data:askCreateBoat(boat_id,use_paper)
    end, TOUCH_EVENT_ENDED)

    self.btn_exclamation:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        getUIManager():create("gameobj/shipyard/clsDockIntroduce")
    end, TOUCH_EVENT_ENDED)

    self.ship_look_btn:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self:previewShipInfo()
    end, TOUCH_EVENT_ENDED)

    self.btn_check:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self:selectPaper(true)
    end, CHECKBOX_STATE_EVENT_SELECTED)

    self.btn_check:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self:selectPaper(false)
    end, CHECKBOX_STATE_EVENT_UNSELECTED)

    --点图纸
    self.can_build_panel.consume[CONSUME_KIND_PAPER].icon:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local shipyard_main_ui = getUIManager():get("ClsShipyardMainUI")
        Alert:showJumpWindow(PAPER_TIPS, shipyard_main_ui)
    end, TOUCH_EVENT_ENDED)

    RegTrigger(MATERIAL_UPDATE_EVENT, function() 
        if tolua.isnull(self) then return end
        self:updateMaterialView()
    end)

    RegTrigger(ITEM_UPDATE_EVENT, function()
        if tolua.isnull(self) then return end
        self:updateItemView()
    end)

    RegTrigger(CASH_UPDATE_EVENT, function()
        if tolua.isnull(self) then return end
        self:updateCashCallBack()
    end)
end

function ClsDockUI:selectPaper(select_paper)
    self.select_paper_status = select_paper
    self.has_paper_panel:setVisible(select_paper)
    self.no_paper_panel:setVisible(not select_paper)
end

function ClsDockUI:previewShipInfo()
    Main3d:removeScene(SCENE_ID.PREVIEW)
    getUIManager():create("gameobj/shipyard/clsDockShipPreview", nil, {ship_info = self.current_ship})
end

function ClsDockUI:showShipEffect(boat_info)
    getUIManager():create("gameobj/shipyard/clsDockCreateShipEffectLayer", nil, {boat_info = boat_info,is_create = true})
end

function ClsDockUI:setCurrentShip(data)
    self.current_ship = data
end

function ClsDockUI:getCurrentShip()
    return self.current_ship
end

function ClsDockUI:getCurrentListView()
    return self.btn_ship_list
end

function ClsDockUI:showShip3D(boat_id)  
    if boat_info[boat_id] == nil then return end 
    
    self.layer3d:removeAllChildren()
    
    local path = SHIP_3D_PATH
    local node_name = string.format("boat%.2d", boat_info[boat_id].res_3d_id)
    local Sprite3D = require("gameobj/sprite3d")

    local pos_x = -140
    local ship_attr = boat_attr[boat_id]
    if #ship_attr.occup == 1 then
        if ship_attr.occup[1] == 3 then
            pos_x = -160
        end
    end

    local pos_ids = {
        [1] = 40,
        [2] = -30,
        [3] = -30,
        [12] = 40,
        [112] = 40,
    }
    if pos_ids[boat_id] then
        pos_x = pos_x + pos_ids[boat_id]
    end

    local item = {
        id = boat_id,
        key = boat_key,
        path = path,
        is_ship = true,
        node_name = node_name,
        ani_name = node_name,
        parent = self.layer3d,
        pos = {x = pos_x, y = -120, angle = 90},
    }

    local ship_3d = Sprite3D.new(item)
    ship_3d.node:scale(1.5)
end

function ClsDockUI:getBtnClose()
    return self.btn_close
end

function ClsDockUI:onExit(...)
    UnLoadPlist(self.m_plist_tab)
	UnRegTrigger(MATERIAL_UPDATE_EVENT)
	UnRegTrigger(ITEM_UPDATE_EVENT)
	UnRegTrigger(CASH_UPDATE_EVENT)
end

function ClsDockUI:preClose(...)
    self.layer3d = nil
    Main3d:removeScene(SCENE_ID.PREVIEW)
end

return ClsDockUI
