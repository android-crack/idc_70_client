--2016/08/19
--create by wmh0497
--海域争霸的开战npc

local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsParticleProp = require ("gameobj/explore/exploreParticle")
local propEntity = require("gameobj/explore/exploreProp")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local rpc_down_info = require("game_config/rpc_down_info")
local ClsTips = require("game_config/tips")
local port_info = require("game_config/port/port_info")

local ClsExploreMineralPointNpc = class("ClsExploreMineralPointNpc", ClsExploreNpcBase)

local TIME_COUNT = 5
local CREATE_DIS2 = 1400*1400
local REMOVE_DIS2 = 1600*1600
local ATTACK_DIS2 = 320*320

function ClsExploreMineralPointNpc:initNpc(data)
    self.m_attr = data.attr
    self.m_dis2 = 0
    self.m_mineral_info_key = "firing_mineral_id"
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_cfg_item = data.cfg_item
    self.m_cfg_id = data.cfg_id
    self.m_create_tpos = {x = self.m_cfg_item.sea_pos[1], y = self.m_cfg_item.sea_pos[2]}
    self.m_offset_point = {x = self.m_cfg_item.mineral_size[1]*MAP_TILE_SIZE, y = self.m_cfg_item.mineral_size[2]*MAP_TILE_SIZE}
    local pos = self.m_explore_layer:getLand():cocosToTile2(self.m_create_tpos)
    self.m_create_pos = {x = pos.x + self.m_offset_point.x/2, y = pos.y + self.m_offset_point.y/2}
    self.m_item_model_node = nil
    self.m_is_update_btn = false
    self.m_fighting = false
end

function ClsExploreMineralPointNpc:update(dt)
    local px, py = self:getPlayerShipPos()
    self.m_dis2 = self:getDistance2(self.m_create_pos.x, self.m_create_pos.y, px, py)
    if self.m_item_model_node then
        if self.m_dis2 > REMOVE_DIS2 then
            TIME_COUNT = 5 
            self.m_fighting = false
            self:removeTimer()
            self:removeModel()
        else
            self:mineralUpdate(dt)
        end
    elseif self.m_dis2 < CREATE_DIS2 then
        self:createModel()
        self:mineralUpdate(dt)
    end
end

function ClsExploreMineralPointNpc:updateAttr(key, value, old_value)
    self.m_attr = getGameData():getExploreNpcData():getAllNpcData()[self.m_id].attr

    if not self.m_item_model_node then
        return
    end

    if "hp" == key then
        self:updateHpUi()
    elseif "port" == key then
        self.m_is_update_btn = true
        self:updatePortUI()
    end
end

function ClsExploreMineralPointNpc:mineralUpdate(dt)
    self:updateTimerHander(dt)
    
    local playerShipsData = getGameData():getExplorePlayerShipsData()
        
    if self.m_dis2 > ATTACK_DIS2 or (not playerShipsData:isTeamLeader(self.m_my_uid))then
        if self.m_item_ui.menu:isEnabled() then
            self.m_item_ui.menu:setEnabled(false)
            self.m_item_ui.attack_btn:setVisible(false)
            self.m_item_ui.defend_btn:setVisible(false)
            self.m_item_ui.tip_btn:setVisible(false)
        end
    else
        if (not self.m_item_ui.menu:isEnabled() or self.m_is_update_btn) then
            self.m_item_ui.menu:setEnabled(true)
            local is_same_camp = playerShipsData:isSameCampByValue(self.m_attr.port)
            self.m_item_ui.attack_btn:setVisible(not is_same_camp)
            self.m_item_ui.defend_btn:setVisible(is_same_camp)
            self.m_item_ui.tip_btn:setVisible(true)
            self.m_is_update_btn = false
        end
    end
end

function ClsExploreMineralPointNpc:showSubHpTips(attack_id)
    local area_competition_data = getGameData():getAreaCompetitionData()
    local sub_hp_lab = createBMFont({text = "-1", size = 20, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 0})
    local move_act = CCSequence:createWithTwoActions(CCMoveBy:create(0.4, ccp(0, 50)), CCCallFunc:create(function()
            sub_hp_lab:removeFromParentAndCleanup(true)
            local team_data = getGameData():getTeamData()
            if team_data:getTeamLeaderUid() == attack_id and attack_id == self.m_my_uid then
                area_competition_data:askTryRelayAttackMineral(self.m_id)
                TIME_COUNT = TIME_COUNT - 1
                if TIME_COUNT <= 0 then
                    getGameData():getAreaCompetitionData():askSubHp(self.m_id)
                    TIME_COUNT = 5
                end
            end
        end))
    self.m_item_ui:addChild(sub_hp_lab, 1)
    sub_hp_lab:runAction(move_act)
end

function ClsExploreMineralPointNpc:touch()
end

function ClsExploreMineralPointNpc:touchMineral()
    if not self.m_item_model_node then
        return false
    end
    if self.m_dis2 > ATTACK_DIS2 then
        return false
    end

    local area_competition_data = getGameData():getAreaCompetitionData()
    local fight_open_level = area_competition_data:getFightOpenLevel()
    if not area_competition_data:tryToMineralInteractive() then
        ClsAlert:warning({msg = string.format(rpc_down_info[168].msg, fight_open_level)}) 
        return false
    end

    --防止在探索里面被会长提走，还是可以查看信息
    if not getGameData():getGuildInfoData():hasGuild() then
        ClsAlert:warning({msg = ClsTips[188].msg})
        return false
    end

    local playerShipsData = getGameData():getExplorePlayerShipsData()

    if not playerShipsData:isTeamLeader(self.m_my_uid) then
        return false
    end
    if not playerShipsData:hasTeamMember(self.m_my_uid, 2) then
        ClsAlert:warning({msg = rpc_down_info[134].msg})
        return false
    end

    local buff_state_data = getGameData():getBuffStateData()
    local contend_status_info = buff_state_data:getBuffStateByStatusId("contend_status")
    if not contend_status_info then
        ClsAlert:warning({msg = ui_word.STR_GO_PORT_ACTITY_TIPS})
        return false
    end

    if tolua.isnull(self.m_tips_view) then
        local is_same_camp = playerShipsData:isSameCampByValue(self.m_attr.port)
        
        local str = ui_word.AREA_COMPETITION_ATT_MINERAL_TIP
        if is_same_camp then
            str = ui_word.AREA_COMPETITION_DEF_MINERAL_TIP
        end
        self.m_tips_view = ClsAlert:showAttention(str, function()
                if is_same_camp then
                    self.m_fighting = false
                    getGameData():getAreaCompetitionData():askDefendMineral(self.m_cfg_id)
                else
                    if self.m_fighting then 
                        ClsAlert:warning({msg = ui_word.STR_MELEE_FIGHTING}) 
                        return false
                    end
                    self.m_fighting = true
                    self:startMineralAttack()
                end
                self.m_tips_view = nil
            end, function() 
                self.m_tips_view = nil
            end, nil, {is_hide_cancel_btn = true, touch_priority = TOUCH_PRIORITY_DIALOG_LAYER - 10})
        return true
    end
    return false
end


function ClsExploreMineralPointNpc:startMineralAttack()
    local playerShipsData = getGameData():getExplorePlayerShipsData()
    playerShipsData:setAttr(self.m_my_uid, self.m_mineral_info_key, self.m_id)
    self:removeTimer()
    
    local timer_callback = function()
        local mineral_id = playerShipsData:getAttr(self.m_my_uid, self.m_mineral_info_key) or 0
        if mineral_id ~= self.m_id then
            self.m_fighting = false
            self:removeTimer()
            return
        elseif playerShipsData:isSameCampByValue(self.m_attr.port) or (not playerShipsData:isTeamLeader(self.m_my_uid)) then
            playerShipsData:setAttr(self.m_my_uid, self.m_mineral_info_key, nil)
            self.m_fighting = false
            self:removeTimer()
            return
        end

        self:fireMineral()
    end
    self:addTimer(1, timer_callback, true)
    timer_callback()
    
    local explore_layer = getExploreLayer()
    local shipsLayer = explore_layer:getShipsLayer()
    if not tolua.isnull(shipsLayer) then
        shipsLayer:tryToBreakMove(true)
    end
    
end

function ClsExploreMineralPointNpc:fireMineral()
    if not self.m_item_model_node then return end

    local team_data = getGameData():getTeamData()
    local team_info = team_data:getMyTeamInfo().info
    local ClsExplorePlayerShipsData = getGameData():getExplorePlayerShipsData()
    local ClsExploreBullet = require("gameobj/explore/exploreBullet")
    for k, v in ipairs(team_data:getMyTeamInfo().info) do
        local player_ship = ClsExplorePlayerShipsData:getShipByUid(v.uid)
        if player_ship then
            local m_bullet = nil
            local function eff_action()
                m_bullet:Release()
                m_bullet = nil
                self:showSubHpTips(v.uid)
            end

            local bullet_param = {
                targetNode = self.m_item_model_node,
                ship = player_ship,
                targetCallBack = eff_action,
                down = 30, --炮弹打中的位置下移down单位
                speed = 700,
            }
            m_bullet = ClsExploreBullet.new(bullet_param)
        end
    end
end

function ClsExploreMineralPointNpc:createModel()
    if self.m_item_model_node then
        return
    end

    local playerShipsData = getGameData():getExplorePlayerShipsData()

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
    
    self.m_is_update_btn = false
    
    local progress_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_ore_progress.json")
    self.m_item_ui:addWidget(progress_ui)
    self.m_item_ui:setTouchEnabled(false)
    
    local bar_pos_list = self.m_cfg_item.other_pos.bar_pos
    local btn_pos_list = self.m_cfg_item.other_pos.btn_pos
    local bar_pos = self.m_explore_layer:getLand():cocosToTile(ccp(bar_pos_list[1], bar_pos_list[2]))
    bar_pos.y = bar_pos.y - MAP_TILE_SIZE
    progress_ui:setPosition(ccp(bar_pos.x - self.m_create_pos.x, bar_pos.y - self.m_create_pos.y))
    
    self.m_item_ui.hp_bar = getConvertChildByName(progress_ui, "progress_bar")
    self.m_item_ui.rate_num = 0
    
    self.m_item_ui.hp_lab = getConvertChildByName(progress_ui, "last_amount")
    self.m_item_ui.hp_lab.hp_num = -1

    self.m_item_ui.lbl_port = getConvertChildByName(progress_ui, "port_name")
    self.m_item_ui.lbl_port:setText(ui_word.STR_NO_PORT_OCCUPY_TIPS)
    setUILabelColor(self.m_item_ui.lbl_port, ccc3(dexToColor3B(COLOR_RED)))
    
    local is_same_camp = playerShipsData:isSameCampByValue(self.m_attr.port)
    if is_same_camp then
        setUILabelColor(self.m_item_ui.lbl_port, ccc3(dexToColor3B(COLOR_BLUE)))
    end

    if self.m_attr.port ~= 0 then
        self.m_item_ui.lbl_port:setText(string.format(ui_word.STR_PLAYER_OCCUPY_TIPS, port_info[self.m_attr.port].name))
    end

    self.m_item_ui.name_lab = getConvertChildByName(progress_ui, "ore_name")
    self.m_item_ui.name_lab:setText(self.m_cfg_item.name)
    
    local json_tip_btn = getConvertChildByName(progress_ui, "btn_tips")
    json_tip_btn:setEnabled(false)
    
    local btn_pos = self.m_explore_layer:getLand():cocosToTile2(ccp(btn_pos_list[1], btn_pos_list[2]))
    local btn_x = btn_pos.x - self.m_create_pos.x
    local btn_y = btn_pos.y - self.m_create_pos.y
    local attack_btn = MyMenuItem.new({image = "#explore_player_btn.png", x = btn_x, y = btn_y})
    local attack_img_spr = display.newSprite("#explore_ore_attack.png")
    attack_img_spr:setScale(0.8)
    attack_btn:addChild(attack_img_spr)
    local defend_btn = MyMenuItem.new({image = "#explore_player_btn.png", x = btn_x, y = btn_y})
    local defend_img_spr = display.newSprite("#explore_ore_denfense.png")
    defend_img_spr:setScale(0.8)
    defend_btn:addChild(defend_img_spr)
    
    local tip_x = bar_pos.x - self.m_create_pos.x + json_tip_btn:getPosition().x
    local tip_y = bar_pos.y - self.m_create_pos.y + json_tip_btn:getPosition().y
    local tip_btn = MyMenuItem.new({image = "#common_exclamation3.png", x = tip_x, y = tip_y})
    tip_btn:setVisible(false)
    tip_btn:regCallBack(function()
        getUIManager():create("gameobj/mineral/clsMineralHitView", nil, self.m_id)
    end)
    
    local menu = MyMenu.new({attack_btn, defend_btn, tip_btn})
    self.m_item_ui:addChild(menu, 1)
    
    attack_btn:regCallBack(function()
            self:touchMineral()
        end)
    attack_btn:setVisible(false)
    defend_btn:regCallBack(function()
            self:touchMineral()
        end)
    defend_btn:setVisible(false)
    menu:setEnabled(false)
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
    self.m_item_ui.attack_btn = attack_btn
    self.m_item_ui.defend_btn = defend_btn
    self.m_item_ui.tip_btn = tip_btn
    
    self:updateHpUi()
end

function ClsExploreMineralPointNpc:updateHpUi()
    local max_hp_n = self.m_cfg_item.attr.enduring or 1
    local hp_n = self.m_attr.hp or 0
    local rate_n = Math.floor(hp_n*100/max_hp_n)
    if self.m_item_ui.hp_lab.hp_num ~= hp_n then
        self.m_item_ui.hp_lab.hp_num = hp_n
        self.m_item_ui.hp_lab:setText(string.format("%d/%d", hp_n, max_hp_n))
    end
    if self.m_item_ui.hp_bar.rate_num ~= rate_n then
        self.m_item_ui.hp_bar.rate_num = rate_n
        self.m_item_ui.hp_bar:setPercent(rate_n)
    end
end

function ClsExploreMineralPointNpc:updatePortUI()
    self.m_item_ui.lbl_port:setText(ui_word.STR_NO_PORT_OCCUPY_TIPS)
    setUILabelColor(self.m_item_ui.lbl_port, ccc3(dexToColor3B(COLOR_RED)))
    local playerShipsData = getGameData():getExplorePlayerShipsData()
    local is_same_camp = playerShipsData:isSameCampByValue(self.m_attr.port)
    if is_same_camp then
        setUILabelColor(self.m_item_ui.lbl_port, ccc3(dexToColor3B(COLOR_BLUE)))
    end

    if self.m_attr.port ~= 0 then
        self.m_item_ui.lbl_port:setText(string.format(ui_word.STR_PLAYER_OCCUPY_TIPS, port_info[self.m_attr.port].name))
    end
end

function ClsExploreMineralPointNpc:removeModel()
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
        self:removeTimer()
    end
end


function ClsExploreMineralPointNpc:release()
    self:removeModel()
end

return ClsExploreMineralPointNpc