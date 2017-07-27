--2016/05/23
--create by wmh0497
--用于处理探索玩家船的点击处理事件

local ui_word = require("scripts/game_config/ui_word")

local ClsExploreShipsTouchManage = class("ClsExploreShipsTouchManage")

function ClsExploreShipsTouchManage:init(explore_layer, ships_layer)
    self.m_ships_layer = ships_layer
    self.m_explore_layer = explore_layer
    self.m_player_ship = self.m_explore_layer:getPlayerShip()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
end

function ClsExploreShipsTouchManage:touchShip(uid, ship)
    if uid == self.m_my_uid then
        return true
    end

    local explore_ui = getExploreUI()
    if not tolua.isnull(explore_ui) then
        local explore_player_ui = explore_ui:getExplorePlayerUI()
        if not tolua.isnull(explore_player_ui) then
            explore_player_ui:setGetShipCallback(function(target_uid)
                    return self.m_ships_layer:getShipByUid(target_uid)
                end)
            explore_player_ui:showSelectUI(uid)
        end
    end
    return true
end

function ClsExploreShipsTouchManage:release()
    self.m_ships_layer = nil
    self.m_explore_layer = nil
    self.m_player_ship = nil
end

return ClsExploreShipsTouchManage