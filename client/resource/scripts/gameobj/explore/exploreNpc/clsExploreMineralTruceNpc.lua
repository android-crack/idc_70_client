--
-- Author: Your Name
-- Date: 2016-10-08 14:39:16
-- 海域争霸休战NPC

local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local rpc_down_info = require("game_config/rpc_down_info")
local dialog = require("ui/dialogLayer")
local sailor_info = require("game_config/sailor/sailor_info")
local ClsTips = require("game_config/tips")
local port_info = require("game_config/port/port_info")

local clsExploreMineralTruceNpc = class("clsExploreMineralTruceNpc", ClsExploreNpcBase)

function clsExploreMineralTruceNpc:initNpc(data)
    self.m_attr = data.attr
    self.m_dis2 = 0
    self.m_bullet = nil
    self.m_mineral_info_key = "firing_mineral_id"
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_cfg_item = data.cfg_item
    self.m_cfg_id = data.cfg_id
    self.m_create_tpos = {x = self.m_cfg_item.sea_pos[1], y = self.m_cfg_item.sea_pos[2]}
    self.m_offset_point = {x = self.m_cfg_item.mineral_size[1]*MAP_TILE_SIZE, y = self.m_cfg_item.mineral_size[2]*MAP_TILE_SIZE}
    local pos = self.m_explore_layer:getLand():cocosToTile2(self.m_create_tpos)
    self.m_create_pos = {x = pos.x + self.m_offset_point.x/2, y = pos.y + self.m_offset_point.y/2}
    
    self.m_item_model_node = nil

    self.has_guild = getGameData():getGuildInfoData():hasGuild()
    local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
    self.m_is_have_btn_get = (self.has_guild and my_guild_port_id and 
            self.m_attr.port and my_guild_port_id ~= 0 
            and self.m_attr.port == my_guild_port_id)


end

local CREATE_DIS2 = 1400*1400
local REMOVE_DIS2 = 1600*1600
local ATTACK_DIS2 = 320*320

function clsExploreMineralTruceNpc:update(dt)
    local px, py = self:getPlayerShipPos()
    self.m_dis2 = self:getDistance2(self.m_create_pos.x, self.m_create_pos.y, px, py)
    if self.m_item_model_node then
        if self.m_dis2 > REMOVE_DIS2 then
            self:removeModel()
        else
            self:mineralUpdate(dt)
        end
    elseif self.m_dis2 < CREATE_DIS2 then
        self:createModel()
        self:mineralUpdate(dt)
    end
end

function clsExploreMineralTruceNpc:updateAttr(key, value, old_value)
    if key == "port" then
        local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
        local area_competition_data = getGameData():getAreaCompetitionData()

        self.m_is_have_btn_get = (my_guild_port_id and 
                        my_guild_port_id ~= 0 and 
                        value == my_guild_port_id) and 
                        area_competition_data:isReceiveMineral(self.m_cfg_id)
    end
end

function clsExploreMineralTruceNpc:mineralUpdate(dt)
    self:updateTimerHander(dt)
    if self.m_dis2 > ATTACK_DIS2 then
        if self.m_item_ui.menu:isEnabled() then
            self.m_item_ui.menu:setEnabled(false)
            self.m_item_ui.btn_get:setVisible(false)
        end
    else
        local area_competition_data = getGameData():getAreaCompetitionData()
        if self.m_is_have_btn_get and area_competition_data:tryToMineralInteractive() then
            self.m_item_ui.menu:setEnabled(true)
            self.m_item_ui.menu:setEnabled(true)
            self.m_item_ui.btn_get:setVisible(true)
        end
    end
end

function clsExploreMineralTruceNpc:touch()
end

function clsExploreMineralTruceNpc:touchMineral()
    if not self.m_item_model_node then
        return false
    end
    if self.m_dis2 > ATTACK_DIS2 then
        return false
    end

    local area_competition_data = getGameData():getAreaCompetitionData()
    local wait_open_level = area_competition_data:getWaitOpenLevel()
    if not area_competition_data:tryToMineralInteractive() then
        ClsAlert:warning({msg = string.format(rpc_down_info[168].msg, wait_open_level)})
        return false
    end
    
    --防止在探索里面被会长提走，还是可以查看信息
    if not getGameData():getGuildInfoData():hasGuild() then
        ClsAlert:warning({msg = ClsTips[188].msg})
        return false
    end

    getUIManager():create("gameobj/mineral/clsMineralDefendView", nil, self.m_cfg_id, self.m_is_have_btn_get)
    return false
end

function clsExploreMineralTruceNpc:createModel()
    if self.m_item_model_node then
        return
    end

    local area_competition_data = getGameData():getAreaCompetitionData()
    area_competition_data:askMineralAttackData(self.m_cfg_id)

    self.m_item_model_node = Node.create()
    local ship_layer3d = Explore3D:getLayerShip3d()
    ship_layer3d:addChild(self.m_item_model_node)
    local pos = CameraFollow:cocosToGameplayWorld(ccp(self.m_create_pos.x, self.m_create_pos.y))
    local down = 0
    --local vec3 = Vector3.new(pos:x(), down, pos:z())
    --self.m_item_model_node:setTranslation(vec3)
    self.m_item_model_node:setTranslation(pos:x(), down, pos:z())
    
    self.m_item_ui = UILayer:create()
    self.m_item_ui:setPosition(self.m_create_pos.x, self.m_create_pos.y)
    getShipUI():addChild(self.m_item_ui, -1)
    
    local panel_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_ore_collect.json")
    self.m_item_ui:addWidget(panel_ui)
    
    local bar_pos_list = self.m_cfg_item.other_pos.bar_pos
    local btn_pos_list = self.m_cfg_item.other_pos.btn_pos
    local bar_pos = self.m_explore_layer:getLand():cocosToTile(ccp(bar_pos_list[1], bar_pos_list[2]))
    bar_pos.y = bar_pos.y - MAP_TILE_SIZE
    panel_ui:setPosition(ccp(bar_pos.x - self.m_create_pos.x, bar_pos.y - self.m_create_pos.y))
    
    self.m_item_ui.name_lab = getConvertChildByName(panel_ui, "ore_name")
    self.m_item_ui.name_lab:setText(self.m_cfg_item.name)

     self.m_item_ui.lbl_ore_owner = getConvertChildByName(panel_ui, "ore_owner")
    self.m_item_ui.lbl_ore_owner:setText("")

    self.m_item_ui.lbl_ore_port = getConvertChildByName(panel_ui, "ore_port")
    self.m_item_ui.lbl_ore_port:setText("")

    self.m_item_ui.spr_player_icon = getConvertChildByName(panel_ui, "head_pic")
    self.m_item_ui.spr_head_frame = getConvertChildByName(panel_ui, "head_frame")

    local btn_pos = self.m_explore_layer:getLand():cocosToTile2(ccp(btn_pos_list[1], btn_pos_list[2]))
    local btn_x = btn_pos.x - self.m_create_pos.x
    local btn_y = btn_pos.y - self.m_create_pos.y
    local btn_get = MyMenuItem.new({image = "#explore_player_btn.png", x = 229, y = 46})
    local spr_get = display.newSprite("#explore_ore_award.png")

    btn_get:addChild(spr_get)
    
    local menu = MyMenu.new({btn_get})
    panel_ui:addCCNode(menu)
    
    btn_get:regCallBack(function()
        local attr = self.m_cfg_item.attr
        if attr.obtainLimit ~= -1 then
            local playerData = getGameData():getPlayerData()
            if playerData:getLevel() >= attr.obtainLimit then
                ClsAlert:warning({msg = string.format(ui_word.STR_OBTAINLIMIT_TIPS, attr.obtainLimit)})
                return
            end
        end
        area_competition_data:askTryHarvestMineral(self.m_cfg_id)
    end)

    btn_get:setVisible(self.m_is_have_btn_get)
    menu:setEnabled(self.m_is_have_btn_get)
    menu.camera = self.m_explore_layer:getCamera()
    menu:setCheckCanGetTouchFunc(function()
        local explore_ui = getUIManager():get("ExploreUI")
        if not tolua.isnull(explore_ui) then
            if explore_ui:isEnabledUI() then
                return true
            end
        end
        return false
    end)
    
    self.m_item_ui.menu = menu
    self.m_item_ui.btn_get = btn_get
end

function clsExploreMineralTruceNpc:updataUI()
    if not self.m_item_ui then return end

    local area_competition_data = getGameData():getAreaCompetitionData()
    local attack_data = area_competition_data:getMineralAttackData()

    local is_has_defend = attack_data.attr.name and true or false
    self.m_item_ui.spr_player_icon:setVisible(is_has_defend)
    self.m_item_ui.btn_get:setVisible(self.m_is_have_btn_get)
    self.m_item_ui.menu:setEnabled(self.m_is_have_btn_get)

    if attack_data.attr.port == 0 then
        self.m_item_ui.lbl_ore_port:setText(ui_word.STR_NO_PORT_OCCUPY_TIPS)
    else
        self.m_item_ui.lbl_ore_port:setText(port_info[attack_data.attr.port].name)
    end

    if is_has_defend then
        self.m_item_ui.spr_player_icon:changeTexture(sailor_info[tonumber(attack_data.attr.icon)].res)
        local job_id = attack_data.attr.profession
        self.m_item_ui.spr_head_frame:changeTexture(SAILOR_JOB_BG[job_id].normal, UI_TEX_TYPE_PLIST)
        self.m_item_ui.lbl_ore_owner:setText(attack_data.attr.name)
    else
        self.m_item_ui.lbl_ore_owner:setText(ui_word.STR_NO_PLAYER_OCCUPY_TIPS)
    end
end

function clsExploreMineralTruceNpc:removeModel()
    if self.m_item_ui then
        if not tolua.isnull(self.m_item_ui) then
            self.m_item_ui:removeFromParentAndCleanup(true)
        end
        self.m_item_ui = nil
    end
    
    if self.m_item_model_node then
        if self.m_item_model_node:getParent() then 
            self.m_item_model_node:getParent():removeChild(self.m_item_model_node)
        end
        self.m_item_model_node = nil
    end
end

function clsExploreMineralTruceNpc:release()
    self:removeModel()
end

return clsExploreMineralTruceNpc