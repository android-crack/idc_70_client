--据点事件
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local ClsPropEntity = require("gameobj/copyScene/copySceneProp")
local guild_stronghold_config = require("game_config/guildExplore/group_battle_objects")
local ui_word = require("game_config/ui_word")
local rpc_down_info = require("game_config/rpc_down_info")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ClsAlert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local cfg_tips_info = require("game_config/tips")


local ATTACT_RES = "#explore_ore_attack.png"
local DENFENSE_RES = "#explore_ore_denfense.png"

local ClsJudianEvent = class("ClsJudianEvent", ClsCopySceneEventObject)

function ClsJudianEvent:initEvent(prop_data)
    self.event_data = prop_data
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    
    self.m_stop_reason = "is_firing_judian" --string.format("copy_JudianEvent_id_%d", self.event_id)
    
    self.m_attr = self.event_data.attr
    self.m_stronghold_item = guild_stronghold_config[self.m_attr.checkpoint_id]
    
    self.m_scene_layer = ClsSceneManage:getSceneLayer()
    self.m_ships_layer = self.m_scene_layer:getShipsLayer()
    self.m_player_ship = self.m_scene_layer:getPlayerShip()
    
    local pos_x, pos_y = self.m_ships_layer:tileToCocos(self.m_stronghold_item.name_pos[1], self.m_stronghold_item.name_pos[2])
    self.m_pos = {x = pos_x, y = pos_y}
    
    local judian_datas = ClsSceneManage:getSceneAttr("judian_datas")
    judian_datas[self.m_attr.checkpoint_id] = self.event_data
    
    self.m_name_ui = nil
    self.m_fire_data = {}
    self.m_is_update_btn = false
    self.bullets = {}

    self.m_qte_attack_key = string.format("copy_event_id_%s_qte_attack_key", tostring(self.event_id))
    self.m_qte_denfense_key = string.format("copy_event_id_%s_qte_denfense_key", tostring(self.event_id))
    self.m_wait_reason = string.format("copy_event_id_%s_wait_1s", tostring(self.event_id))
    self:updateShortName()
end

function ClsJudianEvent:initUI()
    self:updateNameUi()
    ClsSceneManage:doLogic("updateMap")
    self:createModel()
end

function ClsJudianEvent:getParams()
    local params = {}
    params.res = "bt_base_001"
    params.animation_res = {"move"}
    params.water_res = {"meshwave00"}
    params.sea_level = 0
    params.type = self.event_type
    params.hit_radius = 1
    return params
end

function ClsJudianEvent:createModel()
    if self.item_model_node then
        return
    end
    self.item_model_node = Node.create()
    local ship_layer3d = Explore3D:getLayerShip3d()
    ship_layer3d:addChild(self.item_model_node)
    local pos = CameraFollow:cocosToGameplayWorld(ccp(self.m_pos.x, self.m_pos.y))
    local down = 0
    --local vec3 = Vector3.new(pos:x(), down, pos:z())
    --self.item_model_node:setTranslation(vec3)
    self.item_model_node:setTranslation(pos:x(), down, pos:z())
end

function ClsJudianEvent:__endEvent()
    if self.item_model_node then
        if self.item_model_node:getParent() then 
            self.item_model_node:getParent():removeChild(self.item_model_node)
        end
        self.item_model_node = nil
    end
end

local TOUCH_DIS2 = 320*320
function ClsJudianEvent:update(dt)
    local px, py = self.m_player_ship:getPos()
    local dis2 = self:getDistance2(px, py, self.m_pos.x, self.m_pos.y)
    if dis2 > TOUCH_DIS2 then
        self.m_event_layer:removeActiveKey(self.m_qte_attack_key)
        self.m_event_layer:removeActiveKey(self.m_qte_denfense_key)
    else
        if getGameData():getExplorePlayerShipsData():isGhostStatus(self.m_my_uid) then
            return
        end

        local team_data = getGameData():getTeamData() 
        if team_data:isInTeam() and not team_data:isTeamLeader() then
            return
        end

        local is_same_camp = getGameData():getExplorePlayerShipsData():isSameCampByValue(self.m_attr.camp)
        if self.m_event_layer:hasActiveKey(self.m_qte_attack_key) or 
            self.m_event_layer:hasActiveKey(self.m_qte_denfense_key) then
            return
        end

        local tips = cfg_tips_info[tonumber(self.m_stronghold_item.dialog_def)]
        if is_same_camp then
            self.m_event_layer:addActiveKey(self.m_qte_denfense_key, function() 
                return self:getQteBtn(self.m_wait_reason, 0, function()
                            self:defendJudian()
                        end, DENFENSE_RES, nil, ui_word.STR_DEFEND) 
            end)
        else
            tips = cfg_tips_info[tonumber(self.m_stronghold_item.dialog_atk)]
            self.m_event_layer:addActiveKey(self.m_qte_attack_key, function() 
                return self:getQteBtn(self.m_wait_reason, 0, function()
                        self:fireJudian()
                    end, ATTACT_RES, nil, ui_word.STR_ATTACK) 
            end)
        end

        
        local tips_ui = self.m_player_ship:getTipsUI()

        if tolua.isnull(tips_ui.chat_bubble) then
            tips_ui.chat_bubble = require("gameobj/explore/clsExploreChatBubble").new({direction = DIRECTION_RIGHT, 
                sender = self.m_my_uid, show_msg = tips.msg})
            tips_ui:addChild(tips_ui.chat_bubble)
            tips_ui.chat_bubble:setPosition(ccp(35, -45))
            local z_order = tips_ui:getZOrder()
            tips_ui:setZOrder(z_order) --保证同层中最高的显示
        end
    end
end

function ClsJudianEvent:updateShortName()
    self.m_attr["short_name"] = self.m_stronghold_item.name
end

function ClsJudianEvent:updateNameUi()
    local is_same_camp = getGameData():getExplorePlayerShipsData():isSameCampByValue(self.m_attr.camp)
    local color_n = self.m_ships_layer:getCampColor(is_same_camp)
    local name_str = self.m_attr.short_name
    local hp_n = self.m_attr.hp or 0
    for _, v in pairs(self.m_fire_data) do
        if v then
            hp_n = hp_n + v
        end
    end
    local max_hp_n = self.m_attr.max_hp or 1
    local rate_n = math.floor(100*hp_n/max_hp_n)
    if not self.m_name_ui then
        self.m_name_ui = display.newSprite("#explore_name1.png")
        local ui_size = self.m_name_ui:getContentSize()
        getSceneShipUI():addChild(self.m_name_ui, -1)
        local pos_x, pos_y = self.m_ships_layer:tileToCocos(self.m_stronghold_item.name_pos[1], self.m_stronghold_item.name_pos[2])
        self.m_name_ui:setPosition(ccp(pos_x, pos_y - 10))
        
        local name_lab = createBMFont({text = name_str, size = 24, color = ccc3(dexToColor3B(color_n)), x = ui_size.width/2, y = ui_size.height/2 + 7})
        name_lab.name_color = color_n
        name_lab.name_str = name_str
        self.m_name_ui:addChild(name_lab)
        self.m_name_ui.name_lab = name_lab
        
        self.m_name_ui.hp_bg_spr = self:createHpProgress()
        self.m_name_ui.hp_bg_spr:setPosition(ui_size.width/2, ui_size.height + 20)
        self.m_name_ui.hp_bg_spr:setScaleX(1)
        self.m_name_ui.hp_bg_spr:setScaleY(1)
        self.m_name_ui:addChild(self.m_name_ui.hp_bg_spr)
        
        self.hpProgress:setPercentage(rate_n)
        self.hpProgress.progress_rate = rate_n
        
        self.m_name_ui.hp_lab = createBMFont({text = string.format("%d/%d", hp_n, max_hp_n), size = 18, x = ui_size.width/2, y = ui_size.height + 10})
        local size = self.m_name_ui.hp_bg_spr:getContentSize()
        self.m_name_ui.hp_lab:setPosition(ccp(ui_size.width/2, ui_size.height + 20))
        self.m_name_ui:addChild(self.m_name_ui.hp_lab, 1)
        self.m_name_ui.hp_lab.hp_num = hp_n
        return
    end
    local name_lab = self.m_name_ui.name_lab
    if name_str ~= name_lab.name_str then
        name_lab:setString(name_str)
        name_lab.name_str = name_str
    end
    if color_n ~= name_lab.name_color then
        name_lab:setColor(ccc3(dexToColor3B(color_n)))
        name_lab.name_color = color_n
    end
    if rate_n ~= self.hpProgress.progress_rate then
        self.hpProgress:setPercentage(rate_n)
        self.hpProgress.progress_rate = rate_n
    end
    if self.m_name_ui.hp_lab.hp_num ~= hp_n then
        self.m_name_ui.hp_lab:setString(string.format("%d/%d", hp_n, max_hp_n))
        self.m_name_ui.hp_lab.hp_num = hp_n
    end
end

function ClsJudianEvent:release()
    self:__endEvent()
    for k, bullet in pairs(self.bullets) do
        if bullet then
            bullet:Release()
        end
    end
    self.bullets = {}
end

function ClsJudianEvent:updataAttr(key, value) --更新属性
    local update_b = false
    if key == "name" then
        self.m_is_update_btn = true
        update_b = true
    elseif key == "camp" then
        self.m_is_update_btn = true
        update_b = true
    elseif key == "hp" then
        self.m_attr["hit_time"] = os.clock()
    end
    --更新事件属性
    self.m_attr[key] = value
    self:updateNameUi()
    if update_b then
        self.m_fire_data = {}
        self:updateShortName()
        ClsSceneManage:doLogic("updateMap")
    end
end

function ClsJudianEvent:showEventEffect()
    
end

function ClsJudianEvent:fireFromShip(params, ship, is_sound)
    local target_uid = params.target
    if ship then
        self.m_fire_data[target_uid] = params.sub_hp
        local bullet = nil
        local function eff_action()
            self.bullets[bullet] = nil
            self:updateNameUi()
            if self.m_fire_data[target_uid] then
                self:subHpEffect(self.m_fire_data[target_uid])
            end
            self.m_fire_data[target_uid] = nil
        end

        if is_sound then
             audioExt.playEffect(music_info.FIRE_MEDIUM.res)
        end
        
        local ExploreBulletCls = require("gameobj/copyScene/copySceneBullet")
        local bullet_param = {
            targetNode = self.item_model_node,
            ship = ship,
            targetCallBack = eff_action,
            down = 30 --炮弹打中的位置下移down单位
        }
        bullet = ExploreBulletCls.new(bullet_param)
        self.bullets[bullet] = bullet
    else
        self.m_fire_data[target_uid] = nil
        self:subHpEffect(params.sub_hp)
    end
    
    for key, value in pairs(params) do
        if key == "hp" then
            self:updataAttr(key, value)
        end
    end
end

function ClsJudianEvent:subHpEffect(sub_hp_n)
    if tolua.isnull(self.m_name_ui) then
        return 
    end
    local ui_size = self.m_name_ui:getContentSize()
    local sub_hp_lab = createDamageWord(-sub_hp_n, nil, nil, nil, 1)
    sub_hp_lab:setPosition(ccp(ui_size.width/2, ui_size.height + 20))
    self.m_name_ui:addChild(sub_hp_lab)
end

function ClsJudianEvent:touch(node)
    return
end

function ClsJudianEvent:checkIsCanTouchBtn(is_attack)
    if getGameData():getExplorePlayerShipsData():isGhostStatus(self.m_my_uid) then
        local tip_str = ui_word.GUILD_STRONGHOLD_GHOST_CAN_NOT_DEFENSE
        if is_attack then
            tip_str = ui_word.GUILD_STRONGHOLD_GHOST_CAN_NOT_ATTACK
        end
        ClsAlert:warning({msg = tip_str})
        return false
    end
    return true
end

function ClsJudianEvent:fireJudian()
    if not self:checkIsCanTouchBtn(true) then
        return
    end

    if not ClsSceneManage:getMyShipAttr("is_firing_judian") then
        ClsSceneManage:setMyShipAttr("is_firing_judian", true)
        self.m_ships_layer:setStopShipReason(self.m_stop_reason)
        self.m_ships_layer:fastUpMyShipPos(true)
        self:sendSalvageMessage()
    end
end

function ClsJudianEvent:defendJudian()
    if not self:checkIsCanTouchBtn(false) then
        return
    end
    self:sendDefenseMessage()
end

return ClsJudianEvent
