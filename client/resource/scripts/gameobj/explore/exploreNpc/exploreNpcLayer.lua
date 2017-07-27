--2016/07/12
--create by wmh0497
--所有npc的总类
local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")

local ClsExploreNpcLayer = class("ClsExploreNpcLayer", function() return CCLayer:create() end)

function ClsExploreNpcLayer:ctor(parent)
    self.m_parent = parent
    self.m_npcs_tab = {}
	self.m_touch_xy = { x = 0,  y = 0}
    self.m_player_ship = self.m_parent:getPlayerShip()
    self.m_player_ship_pos = {x = 0, y = 0}
    self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)

    -- rpc_client_object_enter_scene({id = 32, type = EXPLORE_OBJECT_TYPE.MINERAL_POINT_TYPE_ID, iat = {{key = "cfgId", value = 32}}, cat = {}})
end

function ClsExploreNpcLayer:onEnter()

end

function ClsExploreNpcLayer:onExit()
	self:removeAllNpc()
	getGameData():getExploreNpcData():removeUselessNpcData()
	self.m_parent = nil
	self.m_player_ship = nil
end

function ClsExploreNpcLayer:getPlayerShipPos()
    return self.m_player_ship_pos.x, self.m_player_ship_pos.y
end

function ClsExploreNpcLayer:setTouchXY(x, y)
	self.m_touch_xy.x = x
	self.m_touch_xy.y = y
end

function ClsExploreNpcLayer:getTouchXY()
	return self.m_touch_xy.x, self.m_touch_xy.y
end

-- 更新
function ClsExploreNpcLayer:update(dt)
    local npc_datas = getGameData():getExploreNpcData():getAllNpcData()

    --记录位置信息，优化效率
    local px, py = self.m_player_ship:getPos()
    self.m_player_ship_pos.x = px
    self.m_player_ship_pos.y = py

    for id, npc_data in pairs(npc_datas) do
        local npc_obj = self.m_npcs_tab[id]
        if not npc_obj then
            npc_obj = self:createNpc(npc_data)
            self.m_npcs_tab[id] = npc_obj
        end
        if npc_obj then
            npc_obj:update(dt)
        end
    end
end

function ClsExploreNpcLayer:createNpc(npc_data)
    local npc_clazz = nil
    if (npc_data.type == exploreNpcType.PIRATE) or (npc_data.type == exploreNpcType.PIRATE_BOSS) then
        npc_clazz = require("gameobj/explore/exploreNpc/explorePirateEventNpc")
    elseif npc_data.type == exploreNpcType.REWARD_PIRATE then
        npc_clazz = require("gameobj/explore/exploreNpc/exploreRewardPirateEventNpc")
    elseif npc_data.type == exploreNpcType.MISSION_XUANWO then
        npc_clazz = require("gameobj/explore/exploreNpc/clsExploreCustomXuanwoNpc")
    -- elseif npc_data.type == exploreNpcType.MINERAL_POINT then
    --     npc_clazz = require("gameobj/explore/exploreNpc/clsExploreMineralManageNpc")
    elseif npc_data.type == exploreNpcType.WORLD_MISSION then
        npc_clazz = require("gameobj/explore/exploreNpc/clsExploreWorldMissionNpc")
    elseif npc_data.type == exploreNpcType.CONVOY_MISSION then
        npc_clazz = require("gameobj/explore/exploreNpc/clsExploreConvoyMissionNpc")
    elseif npc_data.type == exploreNpcType.MISSION_PIRATE then
        npc_clazz = require("gameobj/explore/exploreNpc/clsExploreMissionPirateNpc")
    elseif npc_data.type == exploreNpcType.PLUNDER_MISSION_PIRATE then
        npc_clazz = require("gameobj/explore/exploreNpc/clsExplorePlunderMissionPirateNpc")
    elseif npc_data.type == exploreNpcType.RELIC_EXPLORE_PIRATE then
        npc_clazz = require("gameobj/explore/exploreNpc/clsExploreRelicNpc")
    end

    -- print(debug.traceback())

    -- table.print(npc_data)

    if npc_clazz then
        return npc_clazz.new(self, npc_data.id, npc_data.type, npc_data)
    end
end

function ClsExploreNpcLayer:removeAllNpc()
    for _, npc_obj in pairs(self.m_npcs_tab) do
        npc_obj:release()
        npc_obj = nil
    end
    self.m_npcs_tab = {}
end

function ClsExploreNpcLayer:removeNpc(id)
    local npc_obj = self.m_npcs_tab[id]
    if npc_obj then
        npc_obj:release()
        npc_obj = nil
    end
    self.m_npcs_tab[id] = nil
end

function ClsExploreNpcLayer:touchNpc(node)
    if not node then return end
    local index = node:getTag("exploreNpcLayer")
    if not index then return end
    local _, _, match = string.find(index, "([^%d-]+)")
    local id = nil
    if match then
        id = index
    else
        id = tonumber(index)
    end
    local npc_obj = self.m_npcs_tab[id]
    if npc_obj then
        return npc_obj:touch()
    end
end

function ClsExploreNpcLayer:callNpc(id, func_str, ...)
    local npc_obj = self.m_npcs_tab[id]
    if npc_obj then
        local func = npc_obj[func_str]
        if type(func) == "function" then
            return func(npc_obj, ...)
        end
    end
end

return ClsExploreNpcLayer
