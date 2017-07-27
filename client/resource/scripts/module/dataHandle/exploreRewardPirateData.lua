--
-- Author: lzg0946
-- Date: 2016-07-20 20:42:51
-- Function 存放悬赏海盗pveNPC数据

local exploreRewardPirateData = class("exploreRewardPirateData")

function exploreRewardPirateData:ctor()
    self.m_npc_data = {}
end

local function updatePirateMapPoint()
    local explore_map_obj = getUIManager():get("ExploreMap")
    if not tolua.isnull(explore_map_obj) then
        explore_map_obj:resetPoint(EXPLORE_NAV_TYPE_TIME_PIRATE)
    end
end

function exploreRewardPirateData:addPirate(data)
    self.m_npc_data[1] = data
    updatePirateMapPoint()
end

function exploreRewardPirateData:updateAttr(attr_key, data)
    self.m_npc_data[1] = data
end

function exploreRewardPirateData:removePirate(data)
    self.m_npc_data[1] = nil
    updatePirateMapPoint()
end

function exploreRewardPirateData:getData()
    return self.m_npc_data[1]
end

function exploreRewardPirateData:getMapPos()
    local data = self.m_npc_data[1]
    table.print(data)
    if data then
        return ccp(data.attr.map_positon_x, data.attr.map_positon_y)
    end
end

function exploreRewardPirateData:askFightPirate(fight_id)
	GameUtil.callRpc("rpc_server_fight_pve",{fight_id, battle_config.fight_type_pve_bounty_battle, ""})
end

return exploreRewardPirateData
