--
-- Author: lzg0496
-- Date: 2017-03-20 21:29:24
-- Function: 港口争夺报名信息tips

local ClsBaseView = require("ui/view/clsBaseView")
local ui_word = require("game_config/ui_word")

local ClsPortBattleTips = class("ClsPortBattleTips", ClsBaseView)

function ClsPortBattleTips:getViewConfig()
    return {
        name = "ClsPortBattleTips",   
        effect = UI_EFFECT.SCALE,  
    }
end

function ClsPortBattleTips:onEnter()
    self:mkUI()
end

local widget_name = {
    lbl_onwer_rank = "onwer_rank",
    lbl_onwer_guild = "guild_owner_name",
    lbl_challenger_rank_1 = "challenger_rank_1",
    lbl_challenger_guild_1 = "challenger_rank_2",
    lbl_challenger_rank_2 = "challenger_name_1",
    lbl_challenger_guild_2 = "challenger_name_2",
}
function ClsPortBattleTips:mkUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/worldmap_portfight.json")
    self:addWidget(self.panel)
    for k, v in pairs(widget_name) do
        self[k] = getConvertChildByName(self.panel, v)
    end
    self:regTouchEvent(self, function(eventType, x, y)  
        self:close()
    end)
    self.panel:setPosition(ccp(630, 330))
    self.lbl_onwer_rank:setText("")
    self.lbl_onwer_guild:setText("")
    self.lbl_challenger_rank_1:setText("")
    self.lbl_challenger_guild_1:setText("")
    self.lbl_challenger_rank_2:setText("")
    self.lbl_challenger_guild_2:setText("")
end

function ClsPortBattleTips:updataInfoUI(port_id)
    local str_empty = ui_word.STR_PORT_BATTLE_VACANCY
    local port_battle_data = getGameData():getPortBattleData()
    local onwer_info = port_battle_data:getOccupyInfo(port_id)
    if onwer_info.groupId and onwer_info.groupId ~= 0 then
        self.lbl_onwer_rank:setText(onwer_info.group_rank)
        self.lbl_onwer_guild:setText(onwer_info.group_name)
    else
        self.lbl_onwer_rank:setText(str_empty)
        self.lbl_onwer_guild:setText(str_empty)
    end

    local challenger_info = port_battle_data:getChallengeInfoList(port_id)
    if #challenger_info == 0 then
        self.lbl_challenger_rank_1:setText(str_empty)
        self.lbl_challenger_guild_1:setText(str_empty)
        self.lbl_challenger_rank_2:setText(str_empty)
        self.lbl_challenger_guild_2:setText(str_empty)
        return 
    end

    for i = 1, 2 do
        local guild_rank = getConvertChildByName(self.panel, "challenger_rank_" .. i)
        local guild_name = getConvertChildByName(self.panel, "challenger_name_" .. i)
        if challenger_info[i] and challenger_info[i].groupId and challenger_info[i].groupId ~= 0 then
            guild_rank:setText(challenger_info[i].group_rank)
            guild_name:setText(challenger_info[i].group_name)
        else
            guild_rank:setText(str_empty)
            guild_name:setText(str_empty)
        end
    end
end


function ClsPortBattleTips:onExit()
end

return ClsPortBattleTips
