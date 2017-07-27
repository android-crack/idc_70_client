--
-- Author: lzg0496
-- Date: 2016-10-08 14:55:41
-- Function: 海域争霸休战期的守护者UI


local ClsAlert = require("ui/tools/alert")
local news = require("game_config/news")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local port_info = require("game_config/port/port_info")
local sailor_info = require("game_config/sailor/sailor_info")
local dataTools = require("module/dataHandle/dataTools")
local explore_objects_config = require("game_config/explore/explore_objects_config")
local nobility_config = require("game_config/nobility_data")
local ClsBaseView = require("ui/view/clsBaseView")

local clsMineralDefendView = class("clsMineralDefendView", ClsBaseView) 

function clsMineralDefendView:onEnter(id, can_get_reward)
    self.m_plist_tab = {
        ["ui/equip_icon.plist"] = 1,
    }
    LoadPlist(self.m_plist_tab)
    
    self.m_id = id
    self.can_get_reward = can_get_reward
    self:initUI()

    getGameData():getAreaCompetitionData():askMineralAttackData(self.m_id)
end

function clsMineralDefendView:initUI()
    self.m_panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_ore.json")
    convertUIType(self.m_panel)
    self:addWidget(self.m_panel)

    local need_widget_name = {
        lbl_port_name = "belong_port",
        spr_mineral_pic = "minerals_pic",
        btn_close = "btn_close",
        lbl_mineral_title = "title",
        lbl_level_num = "level",
        lbl_player_job = "job",
        pro_bar = "bar",
        lbl_lasting = "bar_num",
        spr_output_icon = "output_icon",
        lbl_output_num = "output_num",
        btn_get = "btn_get",
        btn_get_txt = "btn_get_text",
        panel_challenge = "challenge_panel",
        panel_posses = "posses_panel",
        btn_posses = "btn_posses",
        btn_challenge = "btn_challenge",
        spr_player_icon = "head_icon",
        spr_player_head_bg = "head_bg",
        lbl_player_name = "seaman_name",
        lbl_player_level = "level",
        spr_player_title = "player_title",
        lbl_power_txt = "power_num",
        lbl_time_info = "time_info",
        lbl_defense_time = "defense_time",
        spr_title_enemy = "tab_enemy",
        pal_consume = "pal_consume",

    }

    for k, v in pairs(need_widget_name) do
        self[k] = getConvertChildByName(self.m_panel, v)
    end

    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)

    self.btn_get:setPressedActionEnabled(true)
    self.btn_get:addEventListener(function()
        local attr = self.mineral_info.attr
        if attr.obtainLimit ~= -1 then
            local playerData = getGameData():getPlayerData()
            if playerData:getLevel() >= attr.obtainLimit then
                ClsAlert:warning({msg = string.format(ui_word.STR_OBTAINLIMIT_TIPS, attr.obtainLimit)})
                return
            end
        end
        
        local area_competition_data = getGameData():getAreaCompetitionData()
        area_competition_data:askTryHarvestMineral(self.m_id)
    end, TOUCH_EVENT_ENDED)

    self.btn_posses:setPressedActionEnabled(true)
    self.btn_posses:addEventListener(function()
        local area_competition_data = getGameData():getAreaCompetitionData()
        area_competition_data:askTryOccupiedMineral(self.m_id)
    end, TOUCH_EVENT_ENDED)

    self.btn_challenge:setPressedActionEnabled(true)
    self.btn_challenge:addEventListener(function()
        local player_data = getGameData():getPlayerData()
        local attr = self.mineral_info.attr
        if player_data:getPower() < attr.tiliNeed then
            local parms = {ignore_sea = true}
            ClsAlert:showJumpWindow(POWER_NOT_ENOUGH, self, parms)
            return
        end

        local area_competition_data = getGameData():getAreaCompetitionData()
        area_competition_data:askTryOccupiedMineral(self.m_id)
    end, TOUCH_EVENT_ENDED)

    self.lbl_mineral_title:setText("")
    self.lbl_level_num:setText("")
    
    self.panel_challenge:setVisible(false)
    self.btn_challenge:setVisible(false)
    self.btn_challenge:setEnabled(false)
    self.panel_posses:setVisible(false)
    self.btn_posses:setVisible(false)
    self.btn_posses:setEnabled(false)
    self.spr_title_enemy:setVisible(false)
    self.pal_consume:setVisible(false)
    self.pro_bar:setPercent(0)
    self.lbl_lasting:setText("")

    local area_competition_data = getGameData():getAreaCompetitionData()
    local mineral_reward_info = area_competition_data:getMineralRewardInfo(self.m_id)
    self.spr_mineral_pic:changeTexture(mineral_reward_info.mineral_res)
    self.spr_output_icon:changeTexture(convertResources(mineral_reward_info.reward_res), UI_TEX_TYPE_PLIST)
    self.lbl_output_num:setVisible(false)
end

function clsMineralDefendView:updateUI()
    local area_competition_data = getGameData():getAreaCompetitionData()
    local attack_data = area_competition_data:getMineralAttackData()

    self.mineral_info = explore_objects_config[self.m_id]

    self.lbl_mineral_title:setText(self.mineral_info.name)

    local port_id = attack_data.attr.port
    local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
    if port_id == 0 then
        self.spr_title_enemy:setVisible(true)
        self.pal_consume:setVisible(true)
        self.lbl_port_name:setText(ui_word.STR_NO_PORT_OCCUPY_TIPS)
    else
        self.spr_title_enemy:setVisible(false)
        self.pal_consume:setVisible(false)
        if my_guild_port_id and (my_guild_port_id == 0 or port_id == 0 or port_id ~= my_guild_port_id) then
            self.spr_title_enemy:setVisible(true)
            self.pal_consume:setVisible(true)
        end
        self.lbl_port_name:setText(port_info[port_id].name)
    end

    self.lbl_level_num:setText(string.format(ui_word.STR_LV, self.mineral_info.grade))

    self.lbl_lasting:setText(attack_data.attr.hp .. "/" .. self.mineral_info.attr.enduring)
    self.pro_bar:setPercent((attack_data.attr.hp / self.mineral_info.attr.enduring) * 100)

    local is_has_defend = attack_data.attr.name and true or false

    self.panel_challenge:setVisible(is_has_defend)
    self.btn_challenge:setVisible(is_has_defend)
    self.btn_challenge:setEnabled(is_has_defend)
    self.panel_posses:setVisible(not is_has_defend)
    self.btn_posses:setVisible(not is_has_defend)
    self.btn_posses:setEnabled(not is_has_defend)

    if is_has_defend then
        self:updateDefendUI()
    end

    if self.can_get_reward then
        self.btn_get:active()
        self.btn_get_txt:setText(ui_word.STR_CAN_OBTAIN_TIPS)
    else
        self.btn_get:disable()
        self.btn_get_txt:setText(ui_word.STR_NOT_CAN_OBTAIN_TIPS)
        local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
        if my_guild_port_id and (my_guild_port_id == 0 or port_id == 0 or port_id ~= my_guild_port_id) then
            self.btn_get:setVisible(false)
        end
    end
end

function clsMineralDefendView:updateGetStatus()
    self.can_get_reward = false
    self.btn_get:disable()
    self.btn_get_txt:setText(ui_word.STR_NOT_CAN_OBTAIN_TIPS)
end

function clsMineralDefendView:updateDefendUI()
    local area_competition_data = getGameData():getAreaCompetitionData()
    local attack_data = area_competition_data:getMineralAttackData()

    self.defend_info = attack_data.attr
    local job_id = self.defend_info.profession

    self.lbl_player_job:setText(ROLE_OCCUP_NAME[job_id])
    self.spr_player_icon:changeTexture(sailor_info[tonumber(self.defend_info.icon)].res)
    self.spr_player_head_bg:changeTexture(SAILOR_JOB_BG[job_id].normal, UI_TEX_TYPE_PLIST)

    local str_title = nobility_config[self.defend_info.nobility].peerage_before
    self.spr_player_title:changeTexture(convertResources(str_title))
    self.lbl_player_level:setText(string.format(ui_word.STR_LV, self.defend_info.grade))

    self.lbl_player_name:setText(self.defend_info.name)

    self.lbl_power_txt:setText(self.defend_info.prestige)

    self.lbl_time_info:setText(string.format(ui_word.STR_DEFEND_TIME, 
                    dataTools:getCnTimeStr(self.defend_info.defendTimes, true)))

    self.lbl_defense_time:setText(string.format(ui_word.STR_ATTACK_TIME, 
                    self.defend_info.defendCounts))

    local playerData = getGameData():getPlayerData()
    if self.defend_info.owned == playerData:getUid() then
        self.btn_challenge:setVisible(false)
        self.btn_challenge:setEnabled(false)
    else
        self.btn_challenge:setVisible(true)
        self.btn_challenge:setEnabled(true)
    end
end

function clsMineralDefendView:onExit()
    UnLoadPlist(self.m_plist_tab)
end

return clsMineralDefendView
