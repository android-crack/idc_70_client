--船坞船只预览
local music_info = require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local nobility_data = require("game_config/nobility_data")
local boat_attr = require("game_config/boat/boat_attr")
local ui_word = require("game_config/ui_word")

local Main3d = require("gameobj/mainInit3d")
local Game3d = require("game3d")

local ship_type = {
    [1] = ui_word.ROOM_CLOSE_COMBAT,
    [2] = ui_word.ROOM_LONG_DISTANCE,
    [3] = ui_word.ROOM_DURABLE,
    [4] = ui_word.SHIPYARD_TRANSFORM_BAOWU_ATTR_NAME4,
    [5] = ui_word.BUSINESS_SHIP,
}

local occup_txt = {
    [1] = ui_word.ROLE_OCCUP_1,
    [2] = ui_word.ROLE_OCCUP_2,
    [3] = ui_word.ROLE_OCCUP_3
}

local ClsBaseView = require("ui/view/clsBaseView")
local ClsDockShipPreview = class("ClsDockShipPreview", ClsBaseView)

local show_info = {
    [1] = {name = "introduce_info"},
    [2] = {name = "ship_name"},
    [3] = {name = "job_info"},
    [4] = {name = "flag_level_text"},
    [5] = {name = "gun_num"},
    [6] = {name = "near_num"},
    [7] = {name = "long_num"},
    [8] = {name = "defense_num"},
    [9] = {name = "range_num"},
    [10] = {name = "speed_num"},
}

--页面参数配置方法，注意，是静态方法
function ClsDockShipPreview:getViewConfig()
    return {
        name = "ClsDockShipPreview",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = false
    }
end

--页面创建时调用
function ClsDockShipPreview:onEnter(para)
    self.ship_info = para.ship_info
    self:makeData()
    self:configUI()
    self:configEvent()
    self:init3D()
    self:updateMsg()
end

function ClsDockShipPreview:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_build_ship_info.json")
    self:addWidget(self.panel)

    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_arrow_left = getConvertChildByName(self.panel, "btn_arrow_left")
    self.btn_arrow_right = getConvertChildByName(self.panel, "btn_arrow_right")
    self.type_icon = getConvertChildByName(self.panel, "type_icon")
    self.flag_level_icon = getConvertChildByName(self.panel, "flag_level_icon")
    self.boat_panel = getConvertChildByName(self.panel, "boat_panel")

    local bg = getConvertChildByName(self.panel, "ship_background")
    local black_bg_spr = CCLayerColor:create(ccc4(0, 0, 0, 230))
    bg:addCCNode(black_bg_spr)

    for k, v in ipairs(show_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end
end

function ClsDockShipPreview:configEvent()
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)

    self.btn_arrow_left:addEventListener(function()
    	audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self.m_select_index = self.m_select_index - 1
        self:updateMsg()
    end, TOUCH_EVENT_ENDED)

    self.btn_arrow_right:addEventListener(function()
    	audioExt.playEffect(music_info.COMMON_BUTTON.res)
        self.m_select_index = self.m_select_index + 1
        self:updateMsg()
    end, TOUCH_EVENT_ENDED)
end

function ClsDockShipPreview:init3D()
    local layer_id = 2
    local scene_id = SCENE_ID.PREVIEW
    Main3d:createScene(scene_id) 
    local parent = CCNode:create()
    self.boat_panel:addCCNode(parent)
    Game3d:createLayer(scene_id,layer_id, parent)
    self.layer3d = Game3d:getLayer3d(scene_id,layer_id)
end
function ClsDockShipPreview:makeData(  )
    local ship = self.ship_info
    local boat_id = ship.boat_id
    local job = ship.preview_occup

    --同职业的船
    local index = 0
    local same_job_list = {}
    local boat_build = require("game_config/boat/boat_build")
    for k,v in pairs(boat_attr) do
        if(v.preview_occup == job and boat_build[k].can_preview > 0)then
            v.boat_id = k
            table.insert(same_job_list,v)
        end
    end
    --按爵位排序
    table.sort( same_job_list,function ( a,b )
         return a.nobility_id < b.nobility_id
    end)
    for i,v in ipairs(same_job_list) do
        if(v.boat_id == boat_id)then
            index = i
            break
        end
    end
    self.m_same_job_ship = same_job_list
    self.m_select_index = index
end

function ClsDockShipPreview:updateMsg()

    self.btn_arrow_left:setVisible(self.m_select_index -1 > 0)
    self.btn_arrow_right:setVisible(self.m_select_index +1 <= #self.m_same_job_ship)

    local ship_attr = self.m_same_job_ship[self.m_select_index]
    local boat = boat_info[ship_attr.boat_id]
    local function count(a)
        return a * ship_attr.green_coeff[1] / 100, a * ship_attr.violet_coeff[2] / 100
    end

    local function format(a, b)
        return string.format("%d-%d", a, b)
    end

    local job_txt = occup_txt[ship_attr.preview_occup] or ""
    local nobility_info = nobility_data[ship_attr.nobility_id]

    local data_base = {
        [1] = boat.explain,
        [2] = boat.name,
        [3] = job_txt,
        [4] = nobility_info.title,
        [5] = format(count(ship_attr.remote)),
        [6] = format(count(ship_attr.melee)),
        [7] = format(count(ship_attr.durable)),
        [8] = format(count(ship_attr.defense)),
        [9] = ship_attr.range,
        [10] = ship_attr.speed,
    } 

    for k, v in ipairs(show_info) do
        self[v.name]:setText(data_base[k])
    end

    local job_icon = ship_attr.fi_type < 4 and ship_attr.fi_type  or 3
    self.type_icon:changeTexture(string.format("shipyard_type_bg%s.png",job_icon), UI_TEX_TYPE_PLIST)
    self.flag_level_text:setUILabelColor(nobility_info.level_color)
    self.flag_level_icon:changeTexture(nobility_info.icon, UI_TEX_TYPE_PLIST)

    self:showShip3D(ship_attr.boat_id)
end

function ClsDockShipPreview:showShip3D(boat_id)  
    if boat_info[boat_id] == nil then return end 
    
    self.layer3d:removeAllChildren()
    
    local path = SHIP_3D_PATH
    local node_name = string.format("boat%.2d", boat_info[boat_id].res_3d_id)
    local Sprite3D = require("gameobj/sprite3d")

 
    local item = {
        id = boat_id,
        key = boat_key,
        path = path,
        is_ship = true,
        node_name = node_name,
        ani_name = node_name,
        parent = self.layer3d,
        pos = {x = -170, y = -80, angle = -120},
    }
    local ship_3d = Sprite3D.new(item)
    ship_3d.node:scale(1.5)
end 

function ClsDockShipPreview:preClose()
    Main3d:removeScene(SCENE_ID.PREVIEW)
    self.layer3d = nil

    local dock_ui = getUIManager():get('ClsDockUI')
    if(not tolua.isnull(dock_ui))then
        dock_ui:init3D()
        dock_ui:showShip3D(self.ship_info.boat_id)
    end  
end

return ClsDockShipPreview
