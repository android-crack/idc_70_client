

local music_info = require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local nobility_data = require("game_config/nobility_data")
local boat_attr = require("game_config/boat/boat_attr")
local ui_word = require("game_config/ui_word")

local Main3d = require("gameobj/mainInit3d")
local Game3d = require("game3d")


local ClsBaseView = require("ui/view/clsBaseView")
local ClsRechargeBoatTips = class("ClsRechargeBoatTips", ClsBaseView)


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

function ClsRechargeBoatTips:getViewConfig()
    return {
        is_back_bg = true
    }
end

function ClsRechargeBoatTips:onEnter(boat_id)
    self.boat_id = boat_id


   
    self:configUI()
    self:configEvent()
end

function ClsRechargeBoatTips:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_build_ship_info.json")
    self:addWidget(self.panel)

    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_arrow_left = getConvertChildByName(self.panel, "btn_arrow_left")
    self.btn_arrow_left:setVisible(false)
    self.btn_arrow_right = getConvertChildByName(self.panel, "btn_arrow_right")
    self.btn_arrow_right:setVisible(false)

    self.type_icon = getConvertChildByName(self.panel, "type_icon")
    self.type_icon:setVisible(false)
    self.flag_level_icon = getConvertChildByName(self.panel, "flag_level_icon")
    self.boat_panel = getConvertChildByName(self.panel, "boat_panel")

    local bg = getConvertChildByName(self.panel, "ship_background")
    local black_bg_spr = CCLayerColor:create(ccc4(0, 0, 0, 230))
    bg:addCCNode(black_bg_spr)

    for k, v in ipairs(show_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end

 	self:init3D()
    self:updateUI()
end

function ClsRechargeBoatTips:updateUI(  )
	local boat = boat_info[self.boat_id]
	local ship_attr = boat_attr[self.boat_id]
    local job_txt =  ""

    local function count(a)
        return a * ship_attr.orange_coeff[1] / 100, a * ship_attr.orange_coeff[2] / 100
    end

    local function format(a, b)
        return string.format("%d-%d", a, b)
    end

    --local nobility_title = ui_word.BACKPACK_BOAT_NOBILITY_STR
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

    self.flag_level_text:setUILabelColor(nobility_info.level_color)
    self.flag_level_icon:changeTexture(nobility_info.icon, UI_TEX_TYPE_PLIST)

    self:showShip3D(self.boat_id)
end


function ClsRechargeBoatTips:configEvent()
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)
end

function ClsRechargeBoatTips:init3D()
    local layer_id = 2
    local scene_id = SCENE_ID.PREVIEW
    Main3d:createScene(scene_id) 
    local parent = CCNode:create()
    self.boat_panel:addCCNode(parent)
    Game3d:createLayer(scene_id,layer_id, parent)
    self.layer3d = Game3d:getLayer3d(scene_id,layer_id)
end


function ClsRechargeBoatTips:showShip3D(boat_id)  
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

function ClsRechargeBoatTips:onExit()
    Main3d:removeScene(SCENE_ID.PREVIEW)
    self.layer3d = nil 
end

return ClsRechargeBoatTips