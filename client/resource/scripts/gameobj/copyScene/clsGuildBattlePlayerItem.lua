--
-- Author: lzg0496      
-- Date: 2017-03-31 15:23:20
-- Function: 商会战站前界面的玩家item

local cfg_ui_word = require("game_config/ui_word")
local cfg_title_info = require("game_config/title/info_title")
local ClsDataTools = require("module/dataHandle/dataTools")
local cfg_role_info = require("game_config/role/role_info")
local cfg_nobility_data = require("game_config/nobility_data")

local clsGuildBattlePlayerItem = class("clsGuildBattlePlayerItem", function() return UIWidget:create() end)


local APPLY_STATUS = 0
local FIGHT_STATUS = 1
local END_STATUS = 2

function clsGuildBattlePlayerItem:ctor(camp, index)
    self.m_camp = camp
    self.m_player_camp = getGameData():getSceneDataHandler():getMyCamp()
    self.m_index = index
    self:makeUI()
    self:initUI()
    self:configEvent()
    self.cur_status = nil
end

function clsGuildBattlePlayerItem:makeUI()
    self.panel = createPanelByJson("json/guild_stronghold_solo_player.json")
    self:addChild(self.panel)

    local need_widget_name = 
    {
        spr_head_bg = "head_bg",
        spr_head = "head",
        spr_nobility = "nobility",
        spr_nobility_bg = "nobility_bg",
        lbl_player_name = "player_name",
        lbl_player_level = "player_level",
        lbl_player_job = "player_job",
        lbl_player_prestige = "player_prestige",
        spr_player_prestige = "player_prestige_txt",
        lbl_hidden_name = "hidden_name",
        btn_change = "change",
        spr_lose = "lose",
        spr_win = "win",
        btn_enroll = "btn_enroll",
        spr_question = "question",
        lbl_point_reward = "point_reward",
    }

    for k, v in pairs(need_widget_name) do
        self[k] = getConvertChildByName(self.panel, v)
    end
end

function clsGuildBattlePlayerItem:initUI()
    self.spr_head_bg:setVisible(false)
    self.spr_head:setVisible(false)
    self.spr_nobility_bg:setVisible(false)
    self.btn_change:setVisible(false)
    self.btn_change:setTouchEnabled(false)
    self.spr_lose:setVisible(false)
    self.spr_win:setVisible(false)
    self.btn_enroll:setVisible(false)
    self.btn_enroll:setTouchEnabled(false)
    self.spr_question:setVisible(false)
    self.lbl_player_name:setText("")
    self.lbl_player_level:setText("")
    self.lbl_player_job:setText("")
    self.lbl_player_prestige:setText("")
    self.lbl_player_prestige:setVisible(true)
    self.spr_player_prestige:setVisible(false)
    self.lbl_point_reward:setText("")
    self.lbl_point_reward:setVisible(true)
    self.lbl_hidden_name:setText("")
end

function clsGuildBattlePlayerItem:configEvent()
    self.btn_change:setPressedActionEnabled(true)
    self.btn_change:addEventListener(function()
        local guild_fight_data = getGameData():getGuildFightData()
        guild_fight_data:askSoleApply(self.m_index)
    end, TOUCH_EVENT_ENDED)

    self.btn_enroll:setPressedActionEnabled(true)
    self.btn_enroll:addEventListener(function()
        local guild_fight_data = getGameData():getGuildFightData()
        guild_fight_data:askSoleApply(self.m_index)
    end, TOUCH_EVENT_ENDED)
end

function clsGuildBattlePlayerItem:updataUI(player_data, status)
    self:initUI()
    self.cur_status = status
    self.btn_enroll:setVisible(false)
    self.btn_enroll:setTouchEnabled(false)

    if self.cur_status == APPLY_STATUS then
        if self.m_camp == self.m_player_camp then
            if player_data then
                self:updataPlayerUI(player_data)
                local m_player_data = getGameData():getPlayerData()
                local is_can_change = m_player_data:getBattlePower() > player_data.prestige
                self.btn_change:setVisible(is_can_change)
                self.btn_change:setTouchEnabled(is_can_change)
                return
            else
                self.btn_enroll:setVisible(true)
                self.btn_enroll:setTouchEnabled(true)
            end
        else
            if player_data then
                self.spr_head_bg:setVisible(true)
                self.spr_question:setVisible(true)
                local str_hidden_name = cfg_ui_word["GUILD_FIGHT_SOLO_INFO_" .. self.m_index]
                self.lbl_hidden_name:setText(str_hidden_name)
            else      
                self.lbl_hidden_name:setText(cfg_ui_word.STR_PORT_BATTLE_VACANCY)
            end
        end

    else

        if player_data then
            self:updataPlayerUI(player_data)
            self.btn_change:setVisible(false)
            self.btn_change:setTouchEnabled(false)
            self.spr_question:setVisible(false)
            self.spr_win:setVisible(player_data.isWin == 1)
            self.spr_lose:setVisible(player_data.isWin == -1)
            local str_point_reward = string.format(cfg_ui_word.GUILD_FIGHT_SOLO_POINT_REWARD, 200)
            if player_data.isWin == 1 then
                str_point_reward = string.format(cfg_ui_word.GUILD_FIGHT_SOLO_POINT_REWARD, 500)
            end

            if player_data.isWin ~= 0 then
                self.lbl_point_reward:setText(str_point_reward)
            end
        else
             self.lbl_hidden_name:setText(cfg_ui_word.STR_PORT_BATTLE_VACANCY)
        end
    end
end

function clsGuildBattlePlayerItem:updataPlayerUI(player_data)
    self.spr_head_bg:setVisible(true)
    self.spr_head:setVisible(true)
    self.spr_head:changeTexture(cfg_role_info[player_data.roleId].res)
    self.lbl_player_name:setText(player_data.name)
    self.lbl_player_level:setText("Lv." .. player_data.level)
    self.lbl_player_job:setText(JOB_TITLE[player_data.roleId])
    self.lbl_player_prestige:setText(player_data.prestige)
    self.spr_player_prestige:setVisible(true)
    self.spr_nobility_bg:setVisible(true)
    local nobility_res = cfg_nobility_data[player_data.nobilityId].peerage_before
    nobility_res = convertResources(nobility_res)
    self.spr_nobility:changeTexture(nobility_res, UI_TEX_TYPE_PLIST)
end


return clsGuildBattlePlayerItem

